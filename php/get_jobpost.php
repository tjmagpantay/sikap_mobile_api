<?php
// filepath: c:\xampp\htdocs\sikap_api\php\get_jobpost.php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    // Get job posts with related information
    $sql = "
        SELECT 
            jp.job_id,
            jp.job_title,
            jp.job_category_id,
            jp.job_status,
            jp.job_type,
            jp.salary,
            jp.location,
            jp.workplace_option,
            jp.pay_type,
            jp.pay_range,
            jp.show_pay,
            jp.job_summary,
            jp.full_description,
            jp.application_start,
            jp.application_deadline,
            jp.created_at,
            jp.updated_at,
            e.company_name,
            e.first_name as employer_first_name,
            e.last_name as employer_last_name,
            eb.business_logo,
            eb.business_name,
            jc.category_name,
            GROUP_CONCAT(jps.skill_name) as required_skills
        FROM job_post jp
        LEFT JOIN employer e ON jp.employer_id = e.employer_id
        LEFT JOIN employers_business eb ON e.employer_id = eb.employer_id
        LEFT JOIN job_category jc ON jp.job_category_id = jc.job_category_id
        LEFT JOIN job_post_skills jps ON jp.job_id = jps.job_id
        WHERE jp.job_status = 'open' 
        AND jp.application_deadline >= NOW()
        GROUP BY jp.job_id
        ORDER BY jp.created_at DESC
    ";
    
    $result = $conn->query($sql);
    
    if (!$result) {
        throw new Exception("Query failed: " . $conn->error);
    }
    
    $job_posts = [];
    while ($row = $result->fetch_assoc()) {
        $job_posts[] = [
            'job_id' => (int)$row['job_id'],
            'job_title' => $row['job_title'],
            'job_category_id' => (int)$row['job_category_id'], // ← This is the key fix!
            'job_status' => $row['job_status'],
            'job_type' => $row['job_type'],
            'salary' => $row['salary'],
            'location' => $row['location'],
            'workplace_option' => $row['workplace_option'],
            'pay_type' => $row['pay_type'],
            'pay_range' => $row['pay_range'],
            'show_pay' => (bool)$row['show_pay'],
            'job_summary' => $row['job_summary'],
            'full_description' => $row['full_description'],
            'application_start' => $row['application_start'],
            'application_deadline' => $row['application_deadline'],
            'created_at' => $row['created_at'],
            'updated_at' => $row['updated_at'],
            'company' => [
                'company_name' => $row['company_name'] ?: $row['business_name'],
                'business_logo' => $row['business_logo'],
                'employer_name' => trim($row['employer_first_name'] . ' ' . $row['employer_last_name'])
            ],
            'category' => $row['category_name'],
            'required_skills' => $row['required_skills'] ? explode(',', $row['required_skills']) : []
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $job_posts,
        'count' => count($job_posts)
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