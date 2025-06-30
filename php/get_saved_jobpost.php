<?php
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
    // Get job applications for the jobseeker
    $sql = "
        SELECT 
            ja.application_id,
            ja.application_status,
            ja.applied_at,
            ja.reviewed_at,
            jp.job_id,
            jp.job_title,
            jp.job_type,
            jp.location,
            jp.workplace_option,
            jp.pay_range,
            jp.application_deadline,
            e.company_name,
            eb.business_name,
            eb.business_logo,
            jc.category_name
        FROM job_application ja
        JOIN job_post jp ON ja.job_id = jp.job_id
        LEFT JOIN employer e ON jp.employer_id = e.employer_id
        LEFT JOIN employers_business eb ON e.employer_id = eb.employer_id
        LEFT JOIN job_category jc ON jp.job_category_id = jc.job_category_id
        WHERE ja.jobseeker_id = ?
        ORDER BY ja.applied_at DESC
    ";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $jobseeker_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $applications = [];
    while ($row = $result->fetch_assoc()) {
        $applications[] = [
            'application_id' => (int)$row['application_id'],
            'application_status' => $row['application_status'],
            'applied_at' => $row['applied_at'],
            'reviewed_at' => $row['reviewed_at'],
            'job' => [
                'job_id' => (int)$row['job_id'],
                'job_title' => $row['job_title'],
                'job_type' => $row['job_type'],
                'location' => $row['location'],
                'workplace_option' => $row['workplace_option'],
                'pay_range' => $row['pay_range'],
                'application_deadline' => $row['application_deadline'],
                'company_name' => $row['company_name'] ?: $row['business_name'],
                'business_logo' => $row['business_logo'],
                'category' => $row['category_name']
            ]
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $applications,
        'count' => count($applications)
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