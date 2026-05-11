<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';

try {
    $auth = require_login();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = request_json();
        $tipo = trim((string) ($data['tipo'] ?? 'suporte'));
        $mensagem = trim((string) ($data['mensagem'] ?? ''));

        if ($mensagem === '') {
            json_response(['erro' => 'Mensagem obrigatoria.'], 422);
        }

        $stmt = db()->prepare(
            'INSERT INTO pedidos (empresa_id, cliente_id, tipo, mensagem, status)
             VALUES (:empresa_id, :cliente_id, :tipo, :mensagem, "aberto")'
        );
        $stmt->execute([
            'empresa_id' => $auth['tenant']['id'],
            'cliente_id' => $auth['cliente_id'],
            'tipo' => $tipo,
            'mensagem' => $mensagem,
        ]);

        json_response(['ok' => true, 'id' => (int) db()->lastInsertId()], 201);
    }

    $stmt = db()->prepare(
        'SELECT id, tipo, mensagem, status, criado_em, atualizado_em
           FROM pedidos
          WHERE empresa_id = :empresa_id
            AND cliente_id = :cliente_id
          ORDER BY criado_em DESC'
    );
    $stmt->execute([
        'empresa_id' => $auth['tenant']['id'],
        'cliente_id' => $auth['cliente_id'],
    ]);

    json_response(['pedidos' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao processar pedidos.'], 500);
}
