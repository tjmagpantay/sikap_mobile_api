<?php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$job_id = $_GET['job_id'] ?? '';

if (empty($job_id)) {
    echo json_encode(['success' => false, 'message' => 'Job ID is required']);
    exit;
}

try {
    // Get job attachments/documents
    $stmt = $conn->prepare("
        SELECT 
            jpa.attachment_id,
            jpa.file_path,
            jp.job_title
        FROM job_post_attachments jpa
        INNER JOIN job_post jp ON jpa.job_id = jp.job_id
        WHERE jpa.job_id = ?
        ORDER BY jpa.attachment_id ASC
    ");
    
    $stmt->bind_param("i", $job_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $documents = [];
    while ($row = $result->fetch_assoc()) {
        $file_name = basename($row['file_path']);
        $file_extension = pathinfo($file_name, PATHINFO_EXTENSION);
        
        $documents[] = [
            'attachment_id' => (int)$row['attachment_id'],
            'file_path' => $row['file_path'],
            'file_url' => 'http://192.168.1.4/sikap_api/' . $row['file_path'],
            'file_name' => $file_name,
            'file_extension' => $file_extension,
            'file_type' => strtoupper($file_extension)
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $documents,
        'count' => count($documents),
        'job_title' => $result->num_rows > 0 ? $documents[0]['job_title'] ?? null : null
    ]);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false, 
        'message' => 'Server error: ' . $e->getMessage()
    ]);
}

$conn->close();
?>