<?php
// filepath: c:\xampp\htdocs\sikap_api\config\env_loader.php
function loadEnv($path = __DIR__ . '/../.env') {
    if (!file_exists($path)) {
        error_log("ENV file not found at: " . $path);
        // Set default values if .env doesn't exist
        $_ENV['JWT_SECRET'] = 'your-super-secret-jwt-key-here-make-it-long-and-random-12345';
        $_ENV['DB_HOST'] = 'localhost';
        $_ENV['DB_NAME'] = 'sikap_db';
        $_ENV['DB_USER'] = 'root';
        $_ENV['DB_PASS'] = '';
        return false;
    }

    if (!is_readable($path)) {
        error_log("ENV file not readable at: " . $path);
        return false;
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    
    if ($lines === false) {
        error_log("Could not read ENV file");
        return false;
    }

    foreach ($lines as $line) {
        $line = trim($line);
        
        // Skip comments and empty lines
        if (empty($line) || strpos($line, '#') === 0 || strpos($line, '//') === 0) {
            continue;
        }

        // Parse key=value pairs
        if (strpos($line, '=') !== false) {
            list($name, $value) = explode('=', $line, 2);
            $name = trim($name);
            $value = trim($value);
            
            // Remove quotes if present
            $value = trim($value, '"\'');
            
            // Set both putenv() (for getenv()) and $_ENV (for direct access)
            putenv($name . '=' . $value);
            $_ENV[$name] = $value;
        }
    }
    
    // Debug logging
    error_log("Environment loaded successfully. JWT_SECRET: " . (isset($_ENV['JWT_SECRET']) ? 'SET' : 'NOT SET'));
    
    return true;
}

// Auto-load environment if not already loaded
if (!isset($_ENV['JWT_SECRET'])) {
    loadEnv();
}
?>