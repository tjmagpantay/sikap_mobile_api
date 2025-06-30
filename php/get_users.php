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

try {
    // Get all users with their profile information
    $sql = "
        SELECT 
            u.user_id,
            u.email,
            u.status,
            r.role_name,
            CASE 
                WHEN r.role_name = 'jobseeker' THEN CONCAT(j.first_name, ' ', j.last_name)
                WHEN r.role_name = 'employer' THEN CONCAT(e.first_name, ' ', e.last_name)
                WHEN r.role_name = 'admin' THEN a.admin_name
                ELSE 'Unknown User'
            END as full_name,
            CASE 
                WHEN r.role_name = 'jobseeker' THEN j.first_name
                WHEN r.role_name = 'employer' THEN e.first_name
                WHEN r.role_name = 'admin' THEN a.admin_name
                ELSE 'Unknown'
            END as first_name,
            CASE 
                WHEN r.role_name = 'jobseeker' THEN j.last_name
                WHEN r.role_name = 'employer' THEN e.last_name
                ELSE ''
            END as last_name
        FROM users u
        JOIN user_roles ur ON u.user_id = ur.user_id
        JOIN roles r ON ur.role_id = r.role_id
        LEFT JOIN jobseeker j ON u.user_id = j.user_id AND r.role_name = 'jobseeker'
        LEFT JOIN employer e ON u.user_id = e.user_id AND r.role_name = 'employer'
        LEFT JOIN admin a ON u.user_id = a.user_id AND r.role_name = 'admin'
        ORDER BY u.user_id
    ";
    
    $result = $conn->query($sql);
    
    if (!$result) {
        throw new Exception("Query failed: " . $conn->error);
    }
    
    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = [
            'user_id' => (int)$row['user_id'],
            'email' => $row['email'],
            'status' => $row['status'],
            'role' => $row['role_name'],
            'full_name' => $row['full_name'],
            'first_name' => $row['first_name'],
            'last_name' => $row['last_name']
        ];
    }
    
    echo json_encode([
        'success' => true,
        'data' => $users,
        'count' => count($users),
        'message' => 'Users retrieved successfully'
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
