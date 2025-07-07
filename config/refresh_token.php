<?php
// filepath: c:\xampp\htdocs\sikap_api\php\refresh_token.php
require_once '../config/cors_headers.php';
require_once '../config/db_config.php';
require_once '../config/jwt_helper.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
    exit;
}

// Get current token from header
$headers = getallheaders();
$auth_header = $headers['Authorization'] ?? $headers['authorization'] ?? '';

if (empty($auth_header)) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Authorization token required']);
    exit;
}

// Extract token
if (strpos($auth_header, 'Bearer ') === 0) {
    $token = substr($auth_header, 7);
} else {
    $token = $auth_header;
}

try {
    // Validate current token (even if expired, we'll check)
    $validation = JWTHelper::validateToken($token);

    if (!$validation['success']) {
        // If token is expired, try to extract user data anyway for refresh
        $tokenParts = explode('.', $token);
        if (count($tokenParts) === 3) {
            $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[1])));

            // Check if token expired recently (within 7 days)
            if ($payload->exp > (time() - (7 * 24 * 60 * 60))) {
                $user_data = $payload->data;

                // Generate new token
                $new_token = JWTHelper::generateToken((array)$user_data);

                echo json_encode([
                    'success' => true,
                    'message' => 'Token refreshed successfully',
                    'token' => $new_token,
                    'user' => $user_data
                ]);
                exit;
            }
        }

        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Token cannot be refreshed']);
        exit;
    }

    // Token is still valid, generate new one anyway
    $user_data = (array)$validation['data'];
    $new_token = JWTHelper::generateToken($user_data);

    echo json_encode([
        'success' => true,
        'message' => 'Token refreshed successfully',
        'token' => $new_token,
        'user' => $user_data
    ]);
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['success' => false, 'message' => 'Server error: ' . $e->getMessage()]);
}

$conn->close();
