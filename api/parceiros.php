<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';

try {
    $tenant = current_tenant();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = request_json();
        $parceiroId = (int) ($data['parceiro_id'] ?? 0);

        if ($parceiroId < 1) {
            json_response(['erro' => 'Parceiro invalido.'], 422);
        }

        $stmt = db()->prepare(
            'INSERT INTO cliques_parceiros (empresa_id, parceiro_id, ip, user_agent)
             VALUES (:empresa_id, :parceiro_id, :ip, :user_agent)'
        );
        $stmt->execute([
            'empresa_id' => $tenant['id'],
            'parceiro_id' => $parceiroId,
            'ip' => $_SERVER['REMOTE_ADDR'] ?? null,
            'user_agent' => substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255),
        ]);

        json_response(['ok' => true], 201);
    }

    $stmt = db()->prepare(
        'SELECT id, nome, descricao, categoria, logo_url, site_url, cupom, destaque
           FROM parceiros
          WHERE empresa_id = :empresa_id
            AND ativo = 1
          ORDER BY destaque DESC, nome ASC'
    );
    $stmt->execute(['empresa_id' => $tenant['id']]);

    json_response(['parceiros' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao carregar parceiros.'], 500);
}
