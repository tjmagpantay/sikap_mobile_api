<?php
// filepath: c:\xampp\htdocs\sikap_api\php\unsave_job.php
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

$jobseeker_id = $_POST['jobseeker_id'] ?? '';
$job_id = $_POST['job_id'] ?? '';

if (empty($jobseeker_id) || empty($job_id)) {
    echo json_encode(['success' => false, 'message' => 'Jobseeker ID and Job ID are required']);
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
?>