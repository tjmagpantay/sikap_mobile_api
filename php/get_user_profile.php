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

$user_id = $_GET['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(['success' => false, 'message' => 'User ID is required']);
    exit;
}

try {
    // Get user basic info and role
    $stmt = $conn->prepare("
        SELECT u.user_id, u.email, u.status, r.role_name
        FROM users u
        JOIN user_roles ur ON u.user_id = ur.user_id
        JOIN roles r ON ur.role_id = r.role_id
        WHERE u.user_id = ?
    ");
    
    $stmt->bind_param("i", $user_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        echo json_encode(['success' => false, 'message' => 'User not found']);
        exit;
    }
    
    $user = $result->fetch_assoc();
    $profile_data = [];
    
    // Get role-specific profile data
    if ($user['role_name'] === 'jobseeker') {
        // Get jobseeker profile
        $profile_stmt = $conn->prepare("
            SELECT * FROM jobseeker WHERE user_id = ?
        ");
        $profile_stmt->bind_param("i", $user_id);
        $profile_stmt->execute();
        $profile_result = $profile_stmt->get_result();
        
        if ($profile_result->num_rows > 0) {
            $profile_data = $profile_result->fetch_assoc();
            
            // Get education
            $edu_stmt = $conn->prepare("SELECT * FROM jobseeker_education WHERE jobseeker_id = ?");
            $edu_stmt->bind_param("i", $profile_data['jobseeker_id']);
            $edu_stmt->execute();
            $edu_result = $edu_stmt->get_result();
            $education = [];
            while ($edu_row = $edu_result->fetch_assoc()) {
                $education[] = $edu_row;
            }
            $profile_data['education'] = $education;
            
            // Get work experience
            $exp_stmt = $conn->prepare("SELECT * FROM jobseeker_work_experience WHERE jobseeker_id = ?");
            $exp_stmt->bind_param("i", $profile_data['jobseeker_id']);
            $exp_stmt->execute();
            $exp_result = $exp_stmt->get_result();
            $experience = [];
            while ($exp_row = $exp_result->fetch_assoc()) {
                $experience[] = $exp_row;
            }
            $profile_data['work_experience'] = $experience;
            
            // Get skills
            $skills_stmt = $conn->prepare("SELECT * FROM jobseeker_skills WHERE jobseeker_id = ?");
            $skills_stmt->bind_param("i", $profile_data['jobseeker_id']);
            $skills_stmt->execute();
            $skills_result = $skills_stmt->get_result();
            $skills = [];
            while ($skill_row = $skills_result->fetch_assoc()) {
                $skills[] = $skill_row;
            }
            $profile_data['skills'] = $skills;
            
            // Get documents
            $docs_stmt = $conn->prepare("SELECT * FROM jobseeker_documents WHERE jobseeker_id = ?");
            $docs_stmt->bind_param("i", $profile_data['jobseeker_id']);
            $docs_stmt->execute();
            $docs_result = $docs_stmt->get_result();
            $documents = [];
            while ($doc_row = $docs_result->fetch_assoc()) {
                $documents[] = $doc_row;
            }
            $profile_data['documents'] = $documents;
        }
        
    } elseif ($user['role_name'] === 'employer') {
        // Get employer profile
        $profile_stmt = $conn->prepare("
            SELECT * FROM employer WHERE user_id = ?
        ");
        $profile_stmt->bind_param("i", $user_id);
        $profile_stmt->execute();
        $profile_result = $profile_stmt->get_result();
        
        if ($profile_result->num_rows > 0) {
            $profile_data = $profile_result->fetch_assoc();
            
            // Get business information
            $business_stmt = $conn->prepare("SELECT * FROM employers_business WHERE employer_id = ?");
            $business_stmt->bind_param("i", $profile_data['employer_id']);
            $business_stmt->execute();
            $business_result = $business_stmt->get_result();
            
            if ($business_result->num_rows > 0) {
                $profile_data['business'] = $business_result->fetch_assoc();
            }
            
            // Get employer documents
            $docs_stmt = $conn->prepare("SELECT * FROM employer_documents WHERE employer_id = ?");
            $docs_stmt->bind_param("i", $profile_data['employer_id']);
            $docs_stmt->execute();
            $docs_result = $docs_stmt->get_result();
            
            if ($docs_result->num_rows > 0) {
                $profile_data['documents'] = $docs_result->fetch_assoc();
            }
        }
        
    } elseif ($user['role_name'] === 'admin') {
        // Get admin profile
        $profile_stmt = $conn->prepare("
            SELECT * FROM admin WHERE user_id = ?
        ");
        $profile_stmt->bind_param("i", $user_id);
        $profile_stmt->execute();
        $profile_result = $profile_stmt->get_result();
        
        if ($profile_result->num_rows > 0) {
            $profile_data = $profile_result->fetch_assoc();
        }
    }
    
    // In your jobseeker profile section, update the profile_picture field:
    if (!empty($profile_data['profile_picture'])) {
        $profile_data['profile_picture'] = 'your_website_project/' . $profile_data['profile_picture'];
    }
    
    $response = [
        'success' => true,
        'user' => [
            'user_id' => (int)$user['user_id'],
            'email' => $user['email'],
            'status' => $user['status'],
            'role' => $user['role_name'],
            'profile' => $profile_data
        ]
    ];
    
    echo json_encode($response);
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}

$conn->close();
?>