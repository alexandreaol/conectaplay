<?php

declare(strict_types=1);

if (!function_exists('env_value')) {
    function env_value(string $key, ?string $default = null): ?string
    {
        $value = getenv($key);

        if ($value === false) {
            return $default;
        }

        return $value;
    }
}

if (!function_exists('load_env')) {
    function load_env(string $path): void
    {
        if (!is_file($path) || !is_readable($path)) {
            return;
        }

        foreach (file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES) as $line) {
            $line = trim($line);

            if ($line === '' || str_starts_with($line, '#') || !str_contains($line, '=')) {
                continue;
            }

            [$key, $value] = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);
            $value = trim($value, "\"'");

            if ($key !== '' && getenv($key) === false) {
                putenv($key . '=' . $value);
                $_ENV[$key] = $value;
                $_SERVER[$key] = $value;
            }
        }
    }
}

load_env(dirname(__DIR__) . '/.env');

return [
    'host' => env_value('DB_HOST', env_value('CP_DB_HOST', 'localhost')),
    'port' => env_value('DB_PORT', env_value('CP_DB_PORT', '3306')),
    'database' => env_value('DB_NAME', env_value('CP_DB_NAME', 'u308598921_conecta_play')),
    'username' => env_value('DB_USER', env_value('CP_DB_USER', 'u308598921_conecta_play')),
    'password' => env_value('DB_PASS', env_value('CP_DB_PASS', '')),
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ],
];
