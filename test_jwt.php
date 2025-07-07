<?php
// filepath: c:\xampp\htdocs\sikap_api\test_jwt.php
require_once 'config/jwt_helper.php';

echo "<h2>JWT Debug Test</h2>";

// Test data
$testUser = [
    'user_id' => 999,
    'email' => 'test@example.com',
    'role' => 'jobseeker'
];

echo "<h3>1. Environment Check</h3>";
echo "JWT_SECRET exists: " . (isset($_ENV['JWT_SECRET']) ? "YES" : "NO") . "<br>";
echo "JWT_SECRET length: " . (isset($_ENV['JWT_SECRET']) ? strlen($_ENV['JWT_SECRET']) : "0") . "<br>";
echo "JWT_SECRET value: " . ($_ENV['JWT_SECRET'] ?? "NOT SET") . "<br><br>";

echo "<h3>2. Generate Token</h3>";
try {
    $token = JWTHelper::generateToken($testUser);
    echo "✅ Token generated successfully<br>";
    echo "Token: <textarea rows='3' cols='80'>$token</textarea><br><br>";
    
    echo "<h3>3. Validate Same Token</h3>";
    $validation = JWTHelper::validateToken($token);
    
    if ($validation['success']) {
        echo "✅ Token validation successful<br>";
        echo "Decoded data: <pre>" . print_r($validation['data'], true) . "</pre>";
    } else {
        echo "❌ Token validation failed<br>";
        echo "Error: " . $validation['message'] . "<br>";
    }
    
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "<br>";
}

echo "<h3>4. Manual Token Test</h3>";
echo "Paste a token to test: <br>";
echo "<form method='POST'>";
echo "<textarea name='test_token' rows='3' cols='80'>" . ($_POST['test_token'] ?? '') . "</textarea><br>";
echo "<button type='submit'>Test Token</button>";
echo "</form>";

if (isset($_POST['test_token']) && !empty($_POST['test_token'])) {
    $testToken = trim($_POST['test_token']);
    echo "<br>Testing token: " . substr($testToken, 0, 50) . "...<br>";
    
    $result = JWTHelper::validateToken($testToken);
    if ($result['success']) {
        echo "✅ Token is valid<br>";
        echo "Data: <pre>" . print_r($result['data'], true) . "</pre>";
    } else {
        echo "❌ Token validation failed<br>";
        echo "Error: " . $result['message'] . "<br>";
    }
}
?>