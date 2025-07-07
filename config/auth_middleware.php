<?php
require_once 'jwt_helper.php';

function requireAuth()
{
    $headers = getallheaders();
    $auth_header = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (empty($auth_header)) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => 'Authorization token required']);
        exit;
    }

    // Extract token from "Bearer <token>"
    if (strpos($auth_header, 'Bearer ') === 0) {
        $token = substr($auth_header, 7);
    } else {
        $token = $auth_header;
    }

    $validation = JWTHelper::validateToken($token);

    if (!$validation['success']) {
        http_response_code(401);
        echo json_encode(['success' => false, 'message' => $validation['message']]);
        exit;
    }

    return $validation['data'];
}

function requireRole($required_role)
{
    $user = requireAuth();

    if ($user->role !== $required_role) {
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => "Access denied: $required_role role required. Your role: " . $user->role
        ]);
        exit;
    }

    return $user;
}

function requireRoleId($required_role_id)
{
    $user = requireAuth();

    if ($user->role_id !== $required_role_id) {
        // Map role IDs to names for better error messages
        $role_names = [
            1 => 'admin',
            2 => 'employer',
            3 => 'jobseeker'
        ];

        $required_role_name = $role_names[$required_role_id] ?? 'unknown';
        $user_role_name = $role_names[$user->role_id] ?? 'unknown';

        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => "Access denied: $required_role_name role required. Your role: $user_role_name"
        ]);
        exit;
    }

    return $user;
}

function requireAnyRole($allowed_roles)
{
    $user = requireAuth();

    if (!in_array($user->role, $allowed_roles)) {
        $allowed_roles_str = implode(', ', $allowed_roles);
        http_response_code(403);
        echo json_encode([
            'success' => false,
            'message' => "Access denied. Allowed roles: $allowed_roles_str. Your role: " . $user->role
        ]);
        exit;
    }

    return $user;
}
