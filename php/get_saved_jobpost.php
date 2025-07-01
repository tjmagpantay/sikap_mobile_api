<?php
// filepath: c:\xampp\htdocs\sikap_api\php\get_saved_jobpost.php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');

require_once '../config/db_config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

$jobseeker_id = $_GET['jobseeker_id'] ?? '';

if (empty($jobseeker_id)) {
    echo json_encode(['success' => false, 'message' => 'Jobseeker ID is required']);
    exit;
}

try {
    // Get saved jobs from jobseeker_saved_jobs table with correct table structure
    $stmt = $conn->prepare("
        SELECT 
            sj.saved_id,
            sj.jobseeker_id,
            sj.job_id,
            sj.saved_at,
            jp.job_title,
            jp.job_type,
            jp.location,
            jp.workplace_option,
            jp.pay_range,
            jp.application_deadline,
            e.company_name,
            eb.business_logo,
            eb.business_name,
            jc.category_name as category
        FROM jobseeker_saved_jobs sj
        INNER JOIN job_post jp ON sj.job_id = jp.job_id
        INNER JOIN employer e ON jp.employer_id = e.employer_id
        LEFT JOIN employers_business eb ON e.employer_id = eb.employer_id
        LEFT JOIN job_category jc ON jp.job_category_id = jc.job_category_id
        WHERE sj.jobseeker_id = ?
        ORDER BY sj.saved_at DESC
    ");
    
    $stmt->bind_param("i", $jobseeker_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $savedJobs = [];
    while ($row = $result->fetch_assoc()) {
        $savedJobs[] = [
            'saved_id' => (int)$row['saved_id'],
            'jobseeker_id' => (int)$row['jobseeker_id'],
            'job_id' => (int)$row['job_id'],
            'saved_at' => $row['saved_at'],
            'job' => [
                'job_id' => (int)$row['job_id'],
                'job_title' => $row['job_title'] ?? 'Unknown Job',
                'job_type' => $row['job_type'] ?? 'Full-time',
                'location' => $row['location'] ?? 'Location not specified',
                'workplace_option' => $row['workplace_option'] ?? 'On-site',
                'pay_range' => $row['pay_range'],
                'application_deadline' => $row['application_deadline'],
                'company_name' => $row['company_name'] ?: ($row['business_name'] ?? 'Unknown Company'),
                'business_logo' => $row['business_logo'],
                'category' => $row['category'] ?? 'General'
            ]
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $savedJobs,
        'count' => count($savedJobs)
    ]);
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}

$conn->close();
?>