<?php

if (is_file(__DIR__ . '/public/index.php')) {
    require __DIR__ . '/public/index.php';

    return;
}

echo "<p>If you see this, that means it works!</p>\n";

$db = new PDO(
    'mysql:host=127.0.0.1;port=3306;dbname=' . (getenv('MYSQL_DATABASE') ?: 'test'),
    getenv('MYSQL_USER') ?: 'root',
    getenv('MYSQL_PASSWORD') ?: '1234567890'
);

echo "<p>MySQL NOW(): " . $db->query('SELECT NOW() FROM DUAL')->fetchColumn() . "</p>\n";

// -----
echo '<pre>';
echo 'PHP: ', phpversion(), "\n";
echo "Extensions:\n";
echo implode("\n - ", get_loaded_extensions()), "\n";
echo '</pre>';
