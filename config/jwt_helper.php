<?php
// filepath: c:\xampp\htdocs\sikap_api\config\jwt_helper.php
require_once 'env_loader.php';

class JWTHelper
{

    private static function getSecretKey()
    {
        // Try both methods to ensure compatibility
        $secret = $_ENV['JWT_SECRET'] ?? getenv('JWT_SECRET') ?? null;

        if (!$secret || empty($secret)) {
            error_log("JWT_SECRET not found. Available ENV keys: " . implode(', ', array_keys($_ENV)));
            throw new Exception('JWT_SECRET not found in environment variables');
        }

        return $secret;
    }

    public static function generateToken($userData)
    {
        try {
            $secretKey = self::getSecretKey();

            $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
            $payload = json_encode([
                'iss' => 'sikap_app',
                'aud' => 'sikap_users',
                'iat' => time(),
                'exp' => time() + (30 * 24 * 60 * 60), // 30 days
                'data' => $userData
            ]);

            $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
            $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

            $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, $secretKey, true);
            $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

            return $base64Header . "." . $base64Payload . "." . $base64Signature;
        } catch (Exception $e) {
            error_log("JWT Generation Error: " . $e->getMessage());
            throw $e;
        }
    }

    public static function validateToken($token)
    {
        try {
            $secretKey = self::getSecretKey();
            $tokenParts = explode('.', $token);

            if (count($tokenParts) !== 3) {
                return ['success' => false, 'message' => 'Invalid token: Wrong number of segments'];
            }

            $header = $tokenParts[0];
            $payload = $tokenParts[1];
            $signatureProvided = $tokenParts[2];

            // Verify signature
            $expectedSignature = hash_hmac('sha256', $header . "." . $payload, $secretKey, true);
            $base64ExpectedSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($expectedSignature));

            if (!hash_equals($base64ExpectedSignature, $signatureProvided)) {
                return ['success' => false, 'message' => 'Invalid token: Signature verification failed'];
            }

            // Decode and validate payload
            $payloadData = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $payload)));

            if (!$payloadData) {
                return ['success' => false, 'message' => 'Invalid token: Cannot decode payload'];
            }

            if ($payloadData->exp < time()) {
                return ['success' => false, 'message' => 'Token has expired'];
            }

            return ['success' => true, 'data' => $payloadData->data];
        } catch (Exception $e) {
            error_log("JWT Validation Error: " . $e->getMessage());
            return ['success' => false, 'message' => 'Invalid token: ' . $e->getMessage()];
        }
    }

    public static function isTokenExpired($token)
    {
        try {
            $tokenParts = explode('.', $token);
            if (count($tokenParts) !== 3) {
                return true;
            }

            $payload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $tokenParts[1])));
            return $payload->exp < time();
        } catch (Exception $e) {
            return true;
        }
    }
}
