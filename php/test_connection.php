<?php
require_once '../config/cors-headers.php';
require_once '../config/db_config.php';

echo json_encode([
    'status' => 'success',
    'message' => 'Database connection successful',
    'timestamp' => date('Y-m-d H:i:s'),
    'server_info' => $conn->server_info ?? 'Unknown'
]);

$conn->close();
?>
