<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        json_response(['erro' => 'Metodo nao permitido.'], 405);
    }

    $tenant = current_tenant();
    $data = request_json();
    $email = strtolower(trim((string) ($data['email'] ?? '')));
    $senha = (string) ($data['senha'] ?? '');

    if ($email === '' || $senha === '') {
        json_response(['erro' => 'Informe email e senha.'], 422);
    }

    $stmt = db()->prepare(
        'SELECT id, nome, email, senha_hash
           FROM clientes_app
          WHERE empresa_id = :empresa_id
            AND email = :email
            AND ativo = 1
          LIMIT 1'
    );
    $stmt->execute([
        'empresa_id' => $tenant['id'],
        'email' => $email,
    ]);
    $cliente = $stmt->fetch();

    if (!$cliente || !password_verify($senha, $cliente['senha_hash'])) {
        json_response(['erro' => 'Email ou senha invalidos.'], 401);
    }

    start_app_session();
    session_regenerate_id(true);
    $_SESSION['empresa_id'] = (int) $tenant['id'];
    $_SESSION['cliente_id'] = (int) $cliente['id'];
    $_SESSION['cliente_nome'] = $cliente['nome'];

    json_response([
        'ok' => true,
        'cliente' => [
            'id' => (int) $cliente['id'],
            'nome' => $cliente['nome'],
            'email' => $cliente['email'],
        ],
        'empresa' => [
            'id' => (int) $tenant['id'],
            'nome' => $tenant['nome'],
        ],
    ]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha no login.'], 500);
}
