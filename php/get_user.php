<?php 

require_once 'config/db_config.php';

$sql = "SELECT * FROM users";
$results = $conn->query($sql);

$users = [];
while ($row = $results->fetch_assoc()) {
    $users[] = [
        'id' => $row['id'],
        'name' => $row['name'],
        'email' => $row['email'],
        'status' => $row['status'],
        'created_at' => $row['created_at']
    ];
}

echo json_encode($users);

?>