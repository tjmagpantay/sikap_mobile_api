<?php
// filepath: c:\xampp\htdocs\sikap_api\php\get_users.php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';
require_once '../config/auth_middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// JWT AUTHENTICATION REQUIRED (admin only - role_id = 1)
$authenticated_user = requireRoleId(1); // Admin role ID

try {
    $stmt = $conn->prepare("
        SELECT u.user_id, u.email, u.status, u.created_at, r.role_name,
               CASE 
                   WHEN r.role_name = 'jobseeker' THEN CONCAT(j.first_name, ' ', j.last_name)
                   WHEN r.role_name = 'employer' THEN CONCAT(e.first_name, ' ', e.last_name)
                   WHEN r.role_name = 'admin' THEN a.admin_name
                   ELSE 'Unknown'
               END as full_name
        FROM users u
        JOIN user_roles ur ON u.user_id = ur.user_id
        JOIN roles r ON ur.role_id = r.role_id
        LEFT JOIN jobseeker j ON u.user_id = j.user_id
        LEFT JOIN employer e ON u.user_id = e.user_id
        LEFT JOIN admin a ON u.user_id = a.user_id
        ORDER BY u.created_at DESC
    ");

    $stmt->execute();
    $result = $stmt->get_result();

    $users = [];
    while ($row = $result->fetch_assoc()) {
        $users[] = $row;
    }

    echo json_encode([
        'success' => true,
        'users' => $users
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}

$conn->close();
