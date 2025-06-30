<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/db_config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$email = $_POST['email'] ?? '';
$password = $_POST['password'] ?? '';
$role = $_POST['role'] ?? 'jobseeker'; // Default to jobseeker
$first_name = $_POST['first_name'] ?? '';
$last_name = $_POST['last_name'] ?? '';

if (empty($email) || empty($password) || empty($first_name) || empty($last_name)) {
    echo json_encode(['success' => false, 'message' => 'Email, password, first name, and last name are required']);
    exit;
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['success' => false, 'message' => 'Invalid email format']);
    exit;
}

// Validate role
$valid_roles = ['jobseeker', 'employer'];
if (!in_array($role, $valid_roles)) {
    echo json_encode(['success' => false, 'message' => 'Invalid role. Must be jobseeker or employer']);
    exit;
}

try {
    // Check if email already exists
    $check_stmt = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
    $check_stmt->bind_param("s", $email);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();
    
    if ($check_result->num_rows > 0) {
        echo json_encode(['success' => false, 'message' => 'Email already exists']);
        exit;
    }
    
    $conn->begin_transaction();
    
    try {
        // Hash password
        $hashed_password = password_hash($password, PASSWORD_DEFAULT);
        
        // Get role ID
        $role_stmt = $conn->prepare("SELECT role_id FROM roles WHERE role_name = ?");
        $role_stmt->bind_param("s", $role);
        $role_stmt->execute();
        $role_result = $role_stmt->get_result();
        $role_data = $role_result->fetch_assoc();
        $role_id = $role_data['role_id'];
        
        // Insert user
        $user_stmt = $conn->prepare("
            INSERT INTO users (email, password, status, created_at)
            VALUES (?, ?, 'active', NOW())
        ");
        $user_stmt->bind_param("ss", $email, $hashed_password);
        $user_stmt->execute();
        
        $user_id = $conn->insert_id;
        
        // Insert user role
        $user_role_stmt = $conn->prepare("
            INSERT INTO user_roles (user_id, role_id)
            VALUES (?, ?)
        ");
        $user_role_stmt->bind_param("ii", $user_id, $role_id);
        $user_role_stmt->execute();
        
        // Create role-specific profile
        if ($role === 'jobseeker') {
            $profile_stmt = $conn->prepare("
                INSERT INTO jobseeker (user_id, first_name, last_name, created_at, updated_at)
                VALUES (?, ?, ?, NOW(), NOW())
            ");
            $profile_stmt->bind_param("iss", $user_id, $first_name, $last_name);
            $profile_stmt->execute();
            
            $profile_id = $conn->insert_id;
            
        } elseif ($role === 'employer') {
            $profile_stmt = $conn->prepare("
                INSERT INTO employer (user_id, first_name, last_name, status, created_at, updated_at)
                VALUES (?, ?, ?, 'incomplete', NOW(), NOW())
            ");
            $profile_stmt->bind_param("iss", $user_id, $first_name, $last_name);
            $profile_stmt->execute();
            
            $profile_id = $conn->insert_id;
        }
        
        $conn->commit();
        
        echo json_encode([
            'success' => true,
            'message' => 'Registration successful',
            'user' => [
                'user_id' => $user_id,
                'email' => $email,
                'role' => $role,
                'profile_id' => $profile_id
            ]
        ]);
        
    } catch (Exception $e) {
        $conn->rollback();
        throw $e;
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}

$conn->close();
?>
