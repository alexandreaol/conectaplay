<?php

declare(strict_types=1);

require __DIR__ . '/../config/tenant.php';

try {
    $auth = require_login();

    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        json_response(['erro' => 'Metodo nao permitido.'], 405);
    }

    $stmt = db()->prepare(
        "SELECT c.id,
                c.nome,
                c.email,
                c.telefone,
                c.documento,
                ct.plano,
                ct.velocidade_download,
                ct.velocidade_upload,
                ct.status,
                ct.endereco_instalacao,
                ct.vencimento_dia,
                ct.suporte_whatsapp
           FROM clientes_app c
      LEFT JOIN contratos_app ct
             ON ct.cliente_id = c.id
            AND ct.empresa_id = c.empresa_id
          WHERE c.id = :cliente_id
            AND c.empresa_id = :empresa_id
          ORDER BY ct.status = 'ativo' DESC, ct.criado_em DESC
          LIMIT 1"
    );
    $stmt->execute([
        'cliente_id' => $auth['cliente_id'],
        'empresa_id' => $auth['tenant']['id'],
    ]);

    $conta = $stmt->fetch();

    if (!$conta) {
        json_response(['erro' => 'Cliente nao encontrado.'], 404);
    }

    json_response([
        'cliente' => [
            'id' => (int) $conta['id'],
            'nome' => $conta['nome'],
            'email' => $conta['email'],
            'telefone' => $conta['telefone'],
            'documento' => $conta['documento'],
        ],
        'internet' => [
            'plano' => $conta['plano'],
            'velocidade_download' => $conta['velocidade_download'],
            'velocidade_upload' => $conta['velocidade_upload'],
            'status' => $conta['status'] ?? 'sem_contrato',
            'endereco_instalacao' => $conta['endereco_instalacao'],
            'vencimento_dia' => $conta['vencimento_dia'] ? (int) $conta['vencimento_dia'] : null,
            'suporte_whatsapp' => $conta['suporte_whatsapp'],
        ],
    ]);
} catch (Throwable $e) {
    json_response(['erro' => 'Falha ao carregar sua internet.'], 500);
}
