<?php
// filepath: c:\xampp\htdocs\sikap_api\php\save_job.php
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