<?php
// filepath: c:\xampp\htdocs\sikap_api\config\db_config.php
require_once 'env_loader.php';

try {
    $host = $_ENV['DB_HOST'] ?? getenv('DB_HOST') ?? 'localhost';
    $db   = $_ENV['DB_NAME'] ?? getenv('DB_NAME') ?? 'sikap_db';
    $user = $_ENV['DB_USER'] ?? getenv('DB_USER') ?? 'root';
    $pass = $_ENV['DB_PASS'] ?? getenv('DB_PASS') ?? '';

    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    
    // Keep mysqli for backward compatibility if needed
    $conn = new mysqli($host, $user, $pass, $db);
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    
    error_log("Database connected successfully");
} catch (PDOException $e) {
    error_log("Database connection failed: " . $e->getMessage());
    die("Database connection failed");
}
?>