<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';
require __DIR__ . '/../config/via_ccm.php';

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        json_response(['erro' => 'Metodo nao permitido.'], 405);
    }

    $tenant = current_tenant();
    $data = request_json();
    $login = trim((string) ($data['login'] ?? $data['email'] ?? $data['documento'] ?? ''));
    $documento = only_digits($login);
    $senha = (string) ($data['senha'] ?? '');

    if ($login === '') {
        json_response(['erro' => 'Informe CPF ou CNPJ.'], 422);
    }

    $cliente = null;

    if (($tenant['slug'] ?? '') === 'vianet-minas' && $documento !== '') {
        $externalClient = via_ccm_find_client_by_document($documento);

        if ($externalClient) {
            $cliente = sync_external_client($tenant, $externalClient);
        }
    }

    if (!$cliente) {
        $stmt = db()->prepare(
            'SELECT id, nome, email, documento, senha_hash
           FROM clientes_app
          WHERE empresa_id = :empresa_id
            AND (
              email = :login
              OR REPLACE(REPLACE(REPLACE(documento, ".", ""), "-", ""), "/", "") = :documento
            )
            AND ativo = 1
          LIMIT 1'
        );
        $stmt->execute([
            'empresa_id' => $tenant['id'],
            'login' => strtolower($login),
            'documento' => $documento,
        ]);
        $cliente = $stmt->fetch();

        if (!$cliente || $senha === '' || !password_verify($senha, $cliente['senha_hash'])) {
            json_response(['erro' => 'CPF/CNPJ ou senha invalidos.'], 401);
        }
    }

    start_app_session();
    session_regenerate_id(true);
    $_SESSION['empresa_id'] = (int) $tenant['id'];
    $_SESSION['cliente_id'] = (int) $cliente['id'];
    $_SESSION['cliente_nome'] = $cliente['nome'];

    log_client_access((int) $tenant['id'], (int) $cliente['id'], 'login', 'login');

    json_response([
        'ok' => true,
        'cliente' => [
            'id' => (int) $cliente['id'],
            'nome' => $cliente['nome'],
            'email' => $cliente['email'],
            'documento' => $cliente['documento'] ?? null,
        ],
        'empresa' => [
            'id' => (int) $tenant['id'],
            'nome' => $tenant['nome'],
        ],
    ]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha no login.'], 500);
}
