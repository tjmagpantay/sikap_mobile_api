<?php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';
require_once '../config/jwt_helper.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// Get input data - handle both JSON and form-data
$input_data = null;

// Check if request is JSON
$content_type = $_SERVER['CONTENT_TYPE'] ?? '';
if (strpos($content_type, 'application/json') !== false) {
    // Handle JSON input
    $json_input = file_get_contents('php://input');
    $input_data = json_decode($json_input, true);
    
    if ($input_data === null) {
        echo json_encode(['success' => false, 'message' => 'Invalid JSON format']);
        exit;
    }
    
    $first_name = $input_data['first_name'] ?? '';
    $last_name = $input_data['last_name'] ?? '';
    $email = $input_data['email'] ?? '';
    $password = $input_data['password'] ?? '';
} else {
    // Handle form-data input
    $first_name = $_POST['first_name'] ?? '';
    $last_name = $_POST['last_name'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
}

// Validate required fields
if (empty($first_name) || empty($last_name) || empty($email) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'All fields are required']);
    exit;
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['success' => false, 'message' => 'Invalid email format']);
    exit;
}

// Validate password length
if (strlen($password) < 8) {
    echo json_encode(['success' => false, 'message' => 'Password must be at least 8 characters long']);
    exit;
}

try {
    // Start transaction
    $conn->begin_transaction();
    
    // Check if email already exists
    $check_stmt = $conn->prepare("SELECT user_id FROM users WHERE email = ?");
    $check_stmt->bind_param("s", $email);
    $check_stmt->execute();
    $result = $check_stmt->get_result();
    
    if ($result->num_rows > 0) {
        $conn->rollback();
        echo json_encode(['success' => false, 'message' => 'Email already exists']);
        exit;
    }
    
    // Hash the password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // Insert into users table
    $user_stmt = $conn->prepare("
        INSERT INTO users (email, password, status, created_at) 
        VALUES (?, ?, 'active', NOW())
    ");
    $user_stmt->bind_param("ss", $email, $hashed_password);
    
    if (!$user_stmt->execute()) {
        $conn->rollback();
        echo json_encode(['success' => false, 'message' => 'Failed to create user account']);
        exit;
    }
    
    $user_id = $conn->insert_id;
    
    // Insert into jobseeker table
    $jobseeker_stmt = $conn->prepare("
        INSERT INTO jobseeker (
            user_id, 
            first_name, 
            last_name, 
            profile_completion, 
            profile_completed,
            created_at, 
            updated_at
        ) VALUES (?, ?, ?, 0, 0, NOW(), NOW())
    ");
    $jobseeker_stmt->bind_param("iss", $user_id, $first_name, $last_name);
    
    if (!$jobseeker_stmt->execute()) {
        $conn->rollback();
        echo json_encode(['success' => false, 'message' => 'Failed to create jobseeker profile']);
        exit;
    }
    
    $jobseeker_id = $conn->insert_id;
    
    // Insert into user_roles table (role_id = 3 for jobseeker)
    $role_stmt = $conn->prepare("
        INSERT INTO user_roles (user_id, role_id) 
        VALUES (?, 3)
    ");
    $role_stmt->bind_param("i", $user_id);
    
    if (!$role_stmt->execute()) {
        $conn->rollback();
        echo json_encode(['success' => false, 'message' => 'Failed to assign user role']);
        exit;
    }
    
    // Commit transaction
    $conn->commit();
    
    // Prepare user data for JWT
    $user_data = [
        'user_id' => $user_id,
        'email' => $email,
        'role' => 'jobseeker',
        'role_id' => 3,
        'profile' => [
            'jobseeker_id' => $jobseeker_id,
            'first_name' => $first_name,
            'last_name' => $last_name,
            'profile_completed' => 0
        ]
    ];
    
    // Generate JWT token
    $token = JWTHelper::generateToken($user_data);
    
    // Return success response with token
    echo json_encode([
        'success' => true,
        'message' => 'Registration successful',
        'token' => $token,
        'user' => $user_data
    ]);
    
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}

$conn->close();
?>
