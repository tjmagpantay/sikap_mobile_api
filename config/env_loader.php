<?php
// filepath: c:\xampp\htdocs\sikap_api\config\env_loader.php
function loadEnv($path = __DIR__ . '/../.env') {
    if (!file_exists($path)) {
        error_log("ENV file not found at: " . $path);
        return;
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue; // skip comments

        list($name, $value) = explode('=', $line, 2);
        putenv(trim($name) . '=' . trim($value));
    }
}
?>
