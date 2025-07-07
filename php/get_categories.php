<?php
// filepath: c:\xampp\htdocs\sikap_api\php\get_categories.php
require_once '../config/cors-headers.php'; // ✅ Fix filename (remove dash)
require_once '../config/db_config.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

try {
    if (!$conn) {
        throw new Exception('Database connection failed');
    }

    // ✅ Fixed query - use correct table names
    $stmt = $conn->prepare("
        SELECT 
            jc.job_category_id as category_id,
            jc.category_name,
            COUNT(jp.job_id) as job_count
        FROM job_category jc
        LEFT JOIN job_post jp ON jc.job_category_id = jp.job_category_id 
            AND jp.job_status = 'open'
        GROUP BY jc.job_category_id, jc.category_name
        ORDER BY jc.category_name ASC
    ");

    if (!$stmt) {
        throw new Exception('Prepare statement failed: ' . $conn->error);
    }

    $stmt->execute();
    
    // ✅ Fix: Use get_result() for MySQLi, not fetchAll()
    $result = $stmt->get_result();
    
    $categories = [];
    while ($row = $result->fetch_assoc()) {
        // ✅ Fix: Ensure data types are correct
        $row['job_count'] = (int)$row['job_count'];
        $row['category_id'] = (int)$row['category_id'];
        $categories[] = $row;
    }

    // ✅ Return success response
    echo json_encode([
        'success' => true,
        'categories' => $categories,
        'total_categories' => count($categories),
        'message' => count($categories) > 0 ? 'Categories loaded successfully' : 'No categories found'
    ]);

    $stmt->close();

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage(),
        'categories' => []
    ]);
    error_log("Categories API Error: " . $e->getMessage());
}

if (isset($conn)) {
    $conn->close();
}
?>