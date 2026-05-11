<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';
require __DIR__ . '/../config/via_ccm.php';

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

    $localClient = local_client_origin((int) $auth['tenant']['id'], $auth['cliente_id']);

    if (($localClient['origem'] ?? '') === 'via_ccm' && !empty($localClient['origem_id'])) {
        $payments = array_map(static function (array $item): array {
            return [
                'id' => (int) $item['id'],
                'descricao' => $item['referencia'] ?: ucfirst((string) $item['tipo_recebimento']),
                'valor' => (float) $item['saldo_restante'],
                'status' => $item['status'],
                'vencimento' => $item['data_vencimento'],
                'codigo_pix' => null,
                'link_boleto' => null,
                'pago_em' => null,
                'criado_em' => null,
                'origem' => 'via_ccm',
                'numero_contrato' => $item['numero_contrato'],
                'competencia' => $item['competencia'],
            ];
        }, via_ccm_open_payments((int) $localClient['origem_id']));

        json_response(['pagamentos' => $payments]);
    }

    $stmt = db()->prepare(
        'SELECT id, descricao, valor, status, vencimento, codigo_pix, link_boleto, pago_em, criado_em
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
