<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';

try {
    $auth = require_login();

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = request_json();
        $valor = (float) ($data['valor'] ?? 0);
        $descricao = trim((string) ($data['descricao'] ?? 'Pagamento ConectaPlay'));

        if ($valor <= 0) {
            json_response(['erro' => 'Valor invalido.'], 422);
        }

        $stmt = db()->prepare(
            'INSERT INTO pagamentos_app (empresa_id, cliente_id, descricao, valor, status, vencimento)
             VALUES (:empresa_id, :cliente_id, :descricao, :valor, "pendente", CURDATE())'
        );
        $stmt->execute([
            'empresa_id' => $auth['tenant']['id'],
            'cliente_id' => $auth['cliente_id'],
            'descricao' => $descricao,
            'valor' => $valor,
        ]);

        json_response(['ok' => true, 'id' => (int) db()->lastInsertId()], 201);
    }

    $stmt = db()->prepare(
        'SELECT id, descricao, valor, status, vencimento, pago_em, criado_em
           FROM pagamentos_app
          WHERE empresa_id = :empresa_id
            AND cliente_id = :cliente_id
          ORDER BY criado_em DESC'
    );
    $stmt->execute([
        'empresa_id' => $auth['tenant']['id'],
        'cliente_id' => $auth['cliente_id'],
    ]);

    json_response(['pagamentos' => $stmt->fetchAll()]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao processar pagamentos.'], 500);
}
