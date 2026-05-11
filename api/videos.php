<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';

try {
    $tenant = current_tenant();
    $stmt = db()->prepare(
        'SELECT id, titulo, descricao, categoria, thumbnail_url, video_url, gratuito, destaque, duracao_segundos
           FROM videos
          WHERE empresa_id = :empresa_id
            AND ativo = 1
          ORDER BY destaque DESC, ordem ASC, criado_em DESC'
    );
    $stmt->execute(['empresa_id' => $tenant['id']]);

    json_response(['videos' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao carregar videos.'], 500);
}
