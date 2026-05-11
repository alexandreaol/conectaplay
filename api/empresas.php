<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';

try {
    $tenant = current_tenant();

    json_response([
        'empresa' => [
            'id' => (int) $tenant['id'],
            'nome' => $tenant['nome'],
            'slug' => $tenant['slug'],
            'cor_primaria' => $tenant['cor_primaria'],
            'cor_secundaria' => $tenant['cor_secundaria'],
            'logo_url' => $tenant['logo_url'],
        ],
        'dominio' => current_domain(),
    ]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao carregar empresa.'], 500);
}
