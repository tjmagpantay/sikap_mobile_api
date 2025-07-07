<?php
// filepath: c:\xampp\htdocs\sikap_api\php\get_user.php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';
require_once '../config/auth_middleware.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// ADD JWT AUTHENTICATION (admin only for viewing all users)
$authenticated_user = requireRole('admin');

try {
    $sql = "SELECT u.user_id, u.email, u.status, u.created_at, r.role_name 
            FROM users u
            JOIN user_roles ur ON u.user_id = ur.user_id
            JOIN roles r ON ur.role_id = r.role_id
            ORDER BY u.created_at DESC";

    $results = $conn->query($sql);

    $users = [];
    while ($row = $results->fetch_assoc()) {
        $users[] = [
            'user_id' => $row['user_id'],
            'email' => $row['email'],
            'role' => $row['role_name'],
            'status' => $row['status'],
            'created_at' => $row['created_at']
        ];
    }

    echo json_encode([
        'success' => true,
        'users' => $users
    ]);
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}

$conn->close();
