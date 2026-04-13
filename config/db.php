<?php
/**
 * Returns a singleton PDO connection to the baceEstimates database.
 * Configure credentials via environment variables or edit the defaults below.
 */
function get_pdo(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $host    = getenv('DB_HOST') ?: 'localhost';
        $db      = getenv('DB_NAME') ?: 'baceEstimates';
        $user    = getenv('DB_USER') ?: 'root';
        $pass    = getenv('DB_PASS') ?: '';
        $charset = 'utf8mb4';
        $dsn     = "mysql:host={$host};dbname={$db};charset={$charset}";
        $pdo     = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]);
    }
    return $pdo;
}
