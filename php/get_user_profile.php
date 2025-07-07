<?php
// filepath: c:\xampp\htdocs\sikap_api\php\get_user_profile.php

// Add error reporting at the top to see what's wrong
error_reporting(E_ALL);
ini_set('display_errors', 0); // Don't display errors, but log them
ini_set('log_errors', 1);

require_once '../config/cors-headers.php';
require_once '../config/db_config.php';
require_once '../config/jwt_helper.php';

// Set content type to JSON immediately
header('Content-Type: application/json');

function requireAuth()
{
    $headers = getallheaders();
    $auth_header = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (empty($auth_header)) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Authorization token required']);
        exit;
    }

    if (strpos($auth_header, 'Bearer ') === 0) {
        $token = substr($auth_header, 7);
    } else {
        $token = $auth_header;
    }

    try {
        $validation = JWTHelper::validateToken($token);
        if (!$validation['success']) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid or expired token: ' . $validation['message']]);
            exit;
        }
        return $validation['data'];
    } catch (Exception $e) {
        error_log("JWT validation error: " . $e->getMessage());
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Token validation failed']);
        exit;
    }
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$user_id = $_GET['user_id'] ?? '';
if (empty($user_id)) {
    echo json_encode(['success' => false, 'message' => 'User ID is required']);
    exit;
}

try {
    $authenticated_user = requireAuth();
    error_log("Authentication successful for user: " . json_encode($authenticated_user));
} catch (Exception $e) {
    error_log("Authentication failed: " . $e->getMessage());
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Authentication failed: ' . $e->getMessage()]);
    exit;
}

try {
    // Check if $pdo exists
    if (!isset($pdo)) {
        throw new Exception("Database connection not available");
    }

    // Get user basic data with role
    $user_stmt = $pdo->prepare("
        SELECT u.user_id, u.email, u.status, r.role_name 
        FROM users u
        JOIN user_roles ur ON u.user_id = ur.user_id
        JOIN roles r ON ur.role_id = r.role_id
        WHERE u.user_id = ?
    ");
    $user_stmt->execute([$user_id]);
    $user_data = $user_stmt->fetch(PDO::FETCH_ASSOC);

    if ($user_data) {
        if ($user_data['role_name'] === 'jobseeker') {
            // Get jobseeker profile
            $profile_stmt = $pdo->prepare("SELECT * FROM jobseeker WHERE user_id = ?");
            $profile_stmt->execute([$user_id]);
            $profile_data = $profile_stmt->fetch(PDO::FETCH_ASSOC);

            if ($profile_data) {
                $jobseeker_id = $profile_data['jobseeker_id'];

                // Initialize empty arrays
                $education = [];
                $skills = [];
                $work_experience = [];

                // Try to get education data
                try {
                    $education_stmt = $pdo->prepare("
                        SELECT * FROM jobseeker_education 
                        WHERE jobseeker_id = ? 
                        ORDER BY start_date DESC
                    ");
                    $education_stmt->execute([$jobseeker_id]);
                    $education = $education_stmt->fetchAll(PDO::FETCH_ASSOC);
                } catch (Exception $e) {
                    error_log("Education query failed: " . $e->getMessage());
                    // Continue with empty array
                }

                // Try to get skills data
                try {
                    $skills_stmt = $pdo->prepare("
                        SELECT * FROM jobseeker_skills 
                        WHERE jobseeker_id = ?
                        ORDER BY skill_name ASC
                    ");
                    $skills_stmt->execute([$jobseeker_id]);
                    $skills = $skills_stmt->fetchAll(PDO::FETCH_ASSOC);
                } catch (Exception $e) {
                    error_log("Skills query failed: " . $e->getMessage());
                    // Continue with empty array
                }

                // Try to get work experience data
                try {
                    $work_experience_stmt = $pdo->prepare("
                        SELECT * FROM jobseeker_work_experience 
                        WHERE jobseeker_id = ? 
                        ORDER BY start_date DESC
                    ");
                    $work_experience_stmt->execute([$jobseeker_id]);
                    $work_experience = $work_experience_stmt->fetchAll(PDO::FETCH_ASSOC);
                } catch (Exception $e) {
                    error_log("Work experience query failed: " . $e->getMessage());
                    // Continue with empty array
                }

                // Add the arrays to profile data
                $profile_data['education'] = $education;
                $profile_data['skills'] = $skills;
                $profile_data['work_experience'] = $work_experience;

                // Convert numeric fields
                $profile_data['jobseeker_id'] = (int)$profile_data['jobseeker_id'];
                $profile_data['user_id'] = (int)$profile_data['user_id'];
                $profile_data['profile_completion'] = (int)($profile_data['profile_completion'] ?? 0);
                $profile_data['profile_completed'] = (int)($profile_data['profile_completed'] ?? 0);

                echo json_encode([
                    'success' => true,
                    'message' => 'Profile data retrieved successfully',
                    'user' => [
                        'user_id' => (int)$user_data['user_id'],
                        'email' => $user_data['email'],
                        'role' => $user_data['role_name'],
                        'profile' => $profile_data
                    ],
                    'debug' => [
                        'jobseeker_id' => $jobseeker_id,
                        'education_count' => count($education),
                        'skills_count' => count($skills),
                        'work_experience_count' => count($work_experience)
                    ]
                ]);
            } else {
                echo json_encode(['success' => false, 'message' => 'Jobseeker profile not found']);
            }
        } else {
            // For non-jobseeker users
            echo json_encode([
                'success' => true,
                'user' => [
                    'user_id' => (int)$user_data['user_id'],
                    'email' => $user_data['email'],
                    'role' => $user_data['role_name'],
                    'profile' => null
                ]
            ]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'User not found']);
    }
} catch (Exception $e) {
    error_log("Error in get_user_profile.php: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error occurred',
        'error' => $e->getMessage(),
        'debug' => [
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ]);
}
