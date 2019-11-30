<?php

if (is_file(__DIR__ . '/public/index.php')) {
    require __DIR__ . '/public/index.php';

    return;
}

echo "<p>If you see this, that means it works!</p>\n";

$db = new PDO(
    'mysql:unix_socket=/run/mysqld/mysqld.sock;dbname=' . getenv('MYSQL_DATABASE'),
    getenv('MYSQL_USER'),
    getenv('MYSQL_PASSWORD')
);

echo "<p>MySQL NOW(): " . $db->query('SELECT NOW() FROM DUAL')->fetchColumn() . "</p>\n";
