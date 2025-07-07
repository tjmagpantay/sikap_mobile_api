<?php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';
require_once '../config/jwt_helper.php';

// JWT Authentication Middleware
function requireAuth() {
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
    
    $validation = JWTHelper::validateToken($token);
    
    if (!$validation['success']) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => $validation['message']]);
        exit;
    }
    
    return $validation['data'];
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// REQUIRE JWT AUTHENTICATION
$authenticated_user = requireAuth();

// Get input data
$content_type = $_SERVER['CONTENT_TYPE'] ?? '';
if (strpos($content_type, 'application/json') !== false) {
    $json_input = file_get_contents('php://input');
    $input_data = json_decode($json_input, true);
    $jobseeker_id = $input_data['jobseeker_id'] ?? '';
    $job_id = $input_data['job_id'] ?? '';
} else {
    $jobseeker_id = $_POST['jobseeker_id'] ?? '';
    $job_id = $_POST['job_id'] ?? '';
}

// Validate that authenticated user can save jobs for this jobseeker
if ($authenticated_user->role !== 'jobseeker') {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Only jobseekers can save jobs']);
    exit;
}

if ($authenticated_user->profile->jobseeker_id != $jobseeker_id) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'You can only save jobs for your own profile']);
    exit;
}

try {
    // Check if already saved in jobseeker_saved_jobs table
    $checkStmt = $conn->prepare("
        SELECT saved_id FROM jobseeker_saved_jobs 
        WHERE jobseeker_id = ? AND job_id = ?
    ");
    $checkStmt->bind_param("ii", $jobseeker_id, $job_id);
    $checkStmt->execute();
    $result = $checkStmt->get_result();
    
    if ($result->num_rows > 0) {
        echo json_encode(['success' => false, 'message' => 'Job already saved']);
        exit;
    }
    
    // Insert into jobseeker_saved_jobs table
    $stmt = $conn->prepare("
        INSERT INTO jobseeker_saved_jobs (jobseeker_id, job_id, saved_at)
        VALUES (?, ?, NOW())
    ");
    
    $stmt->bind_param("ii", $jobseeker_id, $job_id);
    
    if ($stmt->execute()) {
        echo json_encode([
            'success' => true,
            'message' => 'Job saved successfully',
            'saved_id' => $conn->insert_id
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to save job']);
    }
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}

$conn->close();
?>