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
    $evento = trim((string) ($data['evento'] ?? 'page_view'));
    $pagina = trim((string) ($data['pagina'] ?? ''));
    $details = is_array($data['detalhes'] ?? null) ? $data['detalhes'] : [];

    start_app_session();
    $clienteId = null;

    if (
        !empty($_SESSION['cliente_id']) &&
        !empty($_SESSION['empresa_id']) &&
        (int) $_SESSION['empresa_id'] === (int) $tenant['id']
    ) {
        $clienteId = (int) $_SESSION['cliente_id'];
    }

    log_client_access((int) $tenant['id'], $clienteId, $evento ?: 'page_view', $pagina ?: null, $details);

    json_response(['ok' => true], 201);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao registrar evento.'], 500);
}
