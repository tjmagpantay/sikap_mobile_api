<?php
// filepath: c:\xampp\htdocs\sikap_api\php\unsave_job.php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';
require_once '../config/auth_middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// JWT AUTHENTICATION REQUIRED
$authenticated_user = requireAuth();

// Get input data (handle both JSON and form-data)
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

if (empty($jobseeker_id) || empty($job_id)) {
    echo json_encode(['success' => false, 'message' => 'Jobseeker ID and Job ID are required']);
    exit;
}

// Validate that authenticated user can unsave jobs for this jobseeker
if ($authenticated_user->role !== 'jobseeker') {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'Only jobseekers can unsave jobs']);
    exit;
}

if ($authenticated_user->profile->jobseeker_id != $jobseeker_id) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'You can only unsave jobs for your own profile']);
    exit;
}

try {
    // Delete from jobseeker_saved_jobs table
    $stmt = $conn->prepare("
        DELETE FROM jobseeker_saved_jobs 
        WHERE jobseeker_id = ? AND job_id = ?
    ");

    $stmt->bind_param("ii", $jobseeker_id, $job_id);

    if ($stmt->execute()) {
        if ($stmt->affected_rows > 0) {
            echo json_encode(['success' => true, 'message' => 'Job unsaved successfully']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Job not found in saved list']);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Failed to unsave job']);
    }
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}

$conn->close();
