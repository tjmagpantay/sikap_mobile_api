<?php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';
require_once '../config/jwt_helper.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($email) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Email and password are required']);
    exit;
}

try {
    // Check if user exists and get user data
    $stmt = $conn->prepare("
        SELECT u.user_id, u.email, u.password, u.status, r.role_name, ur.role_id
        FROM users u
        JOIN user_roles ur ON u.user_id = ur.user_id
        JOIN roles r ON ur.role_id = r.role_id
        WHERE u.email = ? AND u.status = 'active'
    ");
    
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['success' => false, 'message' => 'Invalid email or password']);
        exit;
    }
    
    $user = $result->fetch_assoc();
    
    // Verify password
    if (!password_verify($password, $user['password'])) {
        echo json_encode(['success' => false, 'message' => 'Invalid email or password']);
        exit;
    }
    
    // Get additional user profile data based on role
    $profile_data = [];
    
    if ($user['role_name'] === 'jobseeker') {
        $profile_stmt = $conn->prepare("
            SELECT jobseeker_id, first_name, middle_name, last_name, 
                   profile_picture, profile_completed
            FROM jobseeker 
            WHERE user_id = ?
        ");
        $profile_stmt->bind_param("i", $user['user_id']);
        $profile_stmt->execute();
        $profile_result = $profile_stmt->get_result();
        
        if ($profile_result->num_rows > 0) {
            $profile_data = $profile_result->fetch_assoc();
        }
    } elseif ($user['role_name'] === 'employer') {
        $profile_stmt = $conn->prepare("
            SELECT employer_id, first_name, middle_name, last_name, 
                   company_name, profile_picture, profile_completed, status
            FROM employer 
            WHERE user_id = ?
        ");
        $profile_stmt->bind_param("i", $user['user_id']);
        $profile_stmt->execute();
        $profile_result = $profile_stmt->get_result();
        
        if ($profile_result->num_rows > 0) {
            $profile_data = $profile_result->fetch_assoc();
        }
    } elseif ($user['role_name'] === 'admin') {
        $profile_stmt = $conn->prepare("
            SELECT admin_id, admin_name
            FROM admin 
            WHERE user_id = ?
        ");
        $profile_stmt->bind_param("i", $user['user_id']);
        $profile_stmt->execute();
        $profile_result = $profile_stmt->get_result();
        
        if ($profile_result->num_rows > 0) {
            $profile_data = $profile_result->fetch_assoc();
        }
    }
    
    // Prepare user data for JWT
    $user_data = [
        'user_id' => $user['user_id'],
        'email' => $user['email'],
        'role' => $user['role_name'],
        'role_id' => $user['role_id'],
        'profile' => $profile_data
    ];
    
    // Generate JWT token
    $token = JWTHelper::generateToken($user_data);
    
    // Prepare response
    $response = [
        'success' => true,
        'message' => 'Login successful',
        'token' => $token,
        'user' => $user_data
    ];
    
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}

$conn->close();
?>
