<?php

declare(strict_types=1);

function db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $config = require_once __DIR__ . '/database.php';
    $dsn = sprintf(
        'mysql:host=%s;port=%s;dbname=%s;charset=%s',
        $config['host'],
        $config['port'],
        $config['database'],
        $config['charset']
    );

    $pdo = new PDO($dsn, $config['username'], $config['password'], $config['options']);

    return $pdo;
}

function current_domain(): string
{
    $host = $_SERVER['HTTP_HOST'] ?? 'play.conectabrasil.online';
    $host = strtolower(trim(explode(':', $host)[0]));

    return $host ?: 'play.conectabrasil.online';
}

function current_tenant(): array
{
    static $tenant = null;

    if (is_array($tenant)) {
        return $tenant;
    }

    $stmt = db()->prepare(
        'SELECT e.*
           FROM dominios_empresas d
           INNER JOIN empresas e ON e.id = d.empresa_id
          WHERE d.dominio = :dominio
            AND d.ativo = 1
            AND e.ativo = 1
          LIMIT 1'
    );
    $stmt->execute(['dominio' => current_domain()]);
    $tenant = $stmt->fetch();

    if (!$tenant) {
        json_response(['erro' => 'Empresa nao encontrada para este dominio.'], 404);
    }

    return $tenant;
}

function json_response(array $data, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit;
}

function request_json(): array
{
    $payload = file_get_contents('php://input');

    if (!$payload) {
        return $_POST ?: [];
    }

    $data = json_decode($payload, true);

    return is_array($data) ? $data : [];
}

function start_app_session(): void
{
    if (session_status() === PHP_SESSION_ACTIVE) {
        return;
    }

    session_name('conectaplay_session');
    session_start();
}

function require_login(): array
{
    start_app_session();
    $tenant = current_tenant();

    if (
        empty($_SESSION['cliente_id']) ||
        empty($_SESSION['empresa_id']) ||
        (int) $_SESSION['empresa_id'] !== (int) $tenant['id']
    ) {
        json_response(['erro' => 'Login necessario.'], 401);
    }

    return [
        'tenant' => $tenant,
        'cliente_id' => (int) $_SESSION['cliente_id'],
    ];
}
