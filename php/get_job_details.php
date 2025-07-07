<?php
// filepath: c:\xampp\htdocs\sikap_api\php\get_job_details.php
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
    // Get specific job post with detailed information
    $stmt = $conn->prepare("
        SELECT 
            jp.job_id,
            jp.job_title,
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
            e.employer_id,
            e.first_name as employer_first_name,
            e.last_name as employer_last_name,
            e.company_name,
            e.position as employer_position,
            e.contact_no as employer_contact,
            eb.business_name,
            eb.business_logo,
            eb.business_address,
            eb.business_type,
            eb.business_size,
            eb.business_desc,
            eb.business_email,
            eb.business_contact,
            eb.business_industry,
            eb.business_team_size,
            eb.business_established_year,
            eb.business_website,
            jc.category_name,
            GROUP_CONCAT(DISTINCT jps.skill_name) as required_skills
        FROM job_post jp
        LEFT JOIN employer e ON jp.employer_id = e.employer_id
        LEFT JOIN employers_business eb ON e.employer_id = eb.employer_id
        LEFT JOIN job_category jc ON jp.job_category_id = jc.job_category_id
        LEFT JOIN job_post_skills jps ON jp.job_id = jps.job_id
        WHERE jp.job_id = ?
        GROUP BY jp.job_id
    ");
    
    $stmt->bind_param("i", $job_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['success' => false, 'message' => 'Job post not found']);
        exit;
    }
    
    $job = $result->fetch_assoc();
    
    // Get job attachments/documents
    $attachments_stmt = $conn->prepare("
        SELECT attachment_id, file_path 
        FROM job_post_attachments 
        WHERE job_id = ?
    ");
    $attachments_stmt->bind_param("i", $job_id);
    $attachments_stmt->execute();
    $attachments_result = $attachments_stmt->get_result();
    
    $attachments = [];
    while ($attachment_row = $attachments_result->fetch_assoc()) {
        $attachments[] = [
            'attachment_id' => (int)$attachment_row['attachment_id'],
            'file_path' => $attachment_row['file_path'],
            'file_url' => 'http://192.168.1.4/sikap_api/' . $attachment_row['file_path']
        ];
    }
    
    // Format the response
    $job_post = [
        'job_id' => (int)$job['job_id'],
        'job_title' => $job['job_title'],
        'job_status' => $job['job_status'],
        'job_type' => $job['job_type'],
        'salary' => $job['salary'],
        'location' => $job['location'],
        'workplace_option' => $job['workplace_option'],
        'pay_type' => $job['pay_type'],
        'pay_range' => $job['pay_range'],
        'show_pay' => (bool)$job['show_pay'],
        'job_summary' => $job['job_summary'],
        'full_description' => $job['full_description'],
        'application_start' => $job['application_start'],
        'application_deadline' => $job['application_deadline'],
        'created_at' => $job['created_at'],
        'updated_at' => $job['updated_at'],
        'employer' => [
            'employer_id' => (int)$job['employer_id'],
            'name' => trim($job['employer_first_name'] . ' ' . $job['employer_last_name']),
            'position' => $job['employer_position'],
            'contact' => $job['employer_contact'],
            'company_name' => $job['company_name']
        ],
        'business' => [
            'business_name' => $job['business_name'],
            'business_logo' => $job['business_logo'],
            'business_address' => $job['business_address'],
            'business_type' => $job['business_type'],
            'business_size' => $job['business_size'],
            'business_desc' => $job['business_desc'],
            'business_email' => $job['business_email'],
            'business_contact' => $job['business_contact'],
            'business_industry' => $job['business_industry'],
            'business_team_size' => $job['business_team_size'],
            'business_established_year' => $job['business_established_year'],
            'business_website' => $job['business_website']
        ],
        'category' => $job['category_name'],
        'required_skills' => $job['required_skills'] ? explode(',', $job['required_skills']) : [],
        'attachments' => $attachments
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $job_post
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
