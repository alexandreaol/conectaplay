<?php

declare(strict_types=1);

require_once __DIR__ . '/database.php';

function via_ccm_db(): PDO
{
    static $pdo = null;

    if ($pdo instanceof PDO) {
        return $pdo;
    }

    $host = env_value('VIA_CCM_DB_HOST', env_value('DB_HOST', 'localhost'));
    $port = env_value('VIA_CCM_DB_PORT', env_value('DB_PORT', '3306'));
    $database = env_value('VIA_CCM_DB_NAME', 'u308598921_via_ccm');
    $username = env_value('VIA_CCM_DB_USER', 'u308598921_via_ccm');
    $password = env_value('VIA_CCM_DB_PASS', '');
    $dsn = sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', $host, $port, $database);

    $pdo = new PDO($dsn, $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}

function only_digits(string $value): string
{
    return preg_replace('/\D+/', '', $value) ?? '';
}

function sql_identifier(string $value, string $fallback): string
{
    $value = trim($value);

    if ($value === '') {
        return $fallback;
    }

    if (!preg_match('/^[a-zA-Z0-9_]+$/', $value)) {
        return $fallback;
    }

    return $value;
}

function sql_optional_identifier(?string $value): string
{
    $value = trim((string) $value);

    if ($value === '' || !preg_match('/^[a-zA-Z0-9_]+$/', $value)) {
        return '';
    }

    return $value;
}

function via_ccm_config(): array
{
    return [
        'table' => sql_identifier((string) env_value('VIA_CCM_CLIENT_TABLE', 'clientes'), 'clientes'),
        'id' => sql_identifier((string) env_value('VIA_CCM_CLIENT_ID_COLUMN', 'id'), 'id'),
        'name' => sql_identifier((string) env_value('VIA_CCM_CLIENT_NAME_COLUMN', 'nome'), 'nome'),
        'document' => sql_identifier((string) env_value('VIA_CCM_CLIENT_DOCUMENT_COLUMN', 'cpf'), 'cpf'),
        'email' => sql_identifier((string) env_value('VIA_CCM_CLIENT_EMAIL_COLUMN', 'email'), 'email'),
        'phone' => sql_identifier((string) env_value('VIA_CCM_CLIENT_PHONE_COLUMN', 'telefone'), 'telefone'),
        'status' => sql_optional_identifier(env_value('VIA_CCM_CLIENT_STATUS_COLUMN', '')),
        'active_value' => env_value('VIA_CCM_ACTIVE_VALUE', ''),
        'company_column' => sql_optional_identifier(env_value('VIA_CCM_COMPANY_COLUMN', 'id_empresa')),
        'company_value' => env_value('VIA_CCM_COMPANY_VALUE', '2'),
    ];
}

function via_ccm_find_client_by_document(string $document): ?array
{
    $documentDigits = only_digits($document);

    if ($documentDigits === '') {
        return null;
    }

    $cfg = via_ccm_config();
    $where = "REPLACE(REPLACE(REPLACE({$cfg['document']}, '.', ''), '-', ''), '/', '') = :document";
    $params = ['document' => $documentDigits];

    if ($cfg['status'] !== '' && $cfg['active_value'] !== '') {
        $where .= " AND {$cfg['status']} = :active_value";
        $params['active_value'] = $cfg['active_value'];
    }

    if ($cfg['company_column'] !== '' && $cfg['company_value'] !== '') {
        $where .= " AND {$cfg['company_column']} = :company_value";
        $params['company_value'] = $cfg['company_value'];
    }

    $sql = "SELECT {$cfg['id']} AS origem_id,
                   {$cfg['name']} AS nome,
                   {$cfg['document']} AS documento,
                   {$cfg['email']} AS email,
                   {$cfg['phone']} AS telefone
              FROM {$cfg['table']}
             WHERE {$where}
             LIMIT 1";

    $stmt = via_ccm_db()->prepare($sql);
    $stmt->execute($params);
    $client = $stmt->fetch();

    return $client ?: null;
}

function sync_external_client(array $tenant, array $externalClient): array
{
    $document = only_digits((string) ($externalClient['documento'] ?? ''));
    $originId = (string) ($externalClient['origem_id'] ?? $document);
    $name = trim((string) ($externalClient['nome'] ?? 'Cliente Vianet'));
    $phone = trim((string) ($externalClient['telefone'] ?? '')) ?: null;
    $email = strtolower(trim((string) ($externalClient['email'] ?? '')));

    if ($email === '') {
        $email = $document . '@cliente.vianetminas.local';
    }

    $stmt = db()->prepare(
        'SELECT *
           FROM clientes_app
          WHERE empresa_id = :empresa_id
            AND (
              (origem = "via_ccm" AND origem_id = :origem_id)
              OR documento = :documento
            )
          LIMIT 1'
    );
    $stmt->execute([
        'empresa_id' => $tenant['id'],
        'origem_id' => $originId,
        'documento' => $document,
    ]);
    $client = $stmt->fetch();

    if ($client) {
        $update = db()->prepare(
            'UPDATE clientes_app
                SET nome = :nome,
                    email = :email,
                    telefone = :telefone,
                    documento = :documento,
                    origem = "via_ccm",
                    origem_id = :origem_id,
                    ultimo_acesso_em = NOW(),
                    ativo = 1
              WHERE id = :id'
        );
        $update->execute([
            'nome' => $name,
            'email' => $email,
            'telefone' => $phone,
            'documento' => $document,
            'origem_id' => $originId,
            'id' => $client['id'],
        ]);
    } else {
        $insert = db()->prepare(
            'INSERT INTO clientes_app (empresa_id, nome, email, telefone, documento, origem, origem_id, ultimo_acesso_em, senha_hash, ativo)
             VALUES (:empresa_id, :nome, :email, :telefone, :documento, "via_ccm", :origem_id, NOW(), :senha_hash, 1)'
        );
        $insert->execute([
            'empresa_id' => $tenant['id'],
            'nome' => $name,
            'email' => $email,
            'telefone' => $phone,
            'documento' => $document,
            'origem_id' => $originId,
            'senha_hash' => password_hash(bin2hex(random_bytes(16)), PASSWORD_DEFAULT),
        ]);
    }

    $stmt = db()->prepare(
        'SELECT id, nome, email, documento
           FROM clientes_app
          WHERE empresa_id = :empresa_id
            AND origem = "via_ccm"
            AND origem_id = :origem_id
          LIMIT 1'
    );
    $stmt->execute([
        'empresa_id' => $tenant['id'],
        'origem_id' => $originId,
    ]);

    return $stmt->fetch();
}

function local_client_origin(int $empresaId, int $clienteId): ?array
{
    $stmt = db()->prepare(
        'SELECT id, origem, origem_id, documento
           FROM clientes_app
          WHERE id = :cliente_id
            AND empresa_id = :empresa_id
          LIMIT 1'
    );
    $stmt->execute([
        'cliente_id' => $clienteId,
        'empresa_id' => $empresaId,
    ]);
    $client = $stmt->fetch();

    return $client ?: null;
}

function via_ccm_find_contract(int $externalClientId): ?array
{
    $stmt = via_ccm_db()->prepare(
        "SELECT c.id,
                c.numero,
                c.status_contrato,
                c.status_provisionamento,
                c.dia_vencimento,
                c.data_vencimento,
                c.valor,
                c.valor_plano,
                p.nome AS plano,
                p.download,
                p.upload
           FROM contratos c
      LEFT JOIN planos p
             ON p.id = c.id_plano
            AND p.id_empresa = c.id_empresa
          WHERE c.id_empresa = :empresa_id
            AND c.id_cliente = :cliente_id
            AND c.status_contrato <> 'excluido'
          ORDER BY c.status_contrato = 'ativo' DESC, c.id DESC
          LIMIT 1"
    );
    $stmt->execute([
        'empresa_id' => (int) env_value('VIA_CCM_COMPANY_VALUE', '2'),
        'cliente_id' => $externalClientId,
    ]);
    $contract = $stmt->fetch();

    return $contract ?: null;
}

function via_ccm_open_payments(int $externalClientId): array
{
    $stmt = via_ccm_db()->prepare(
        "SELECT id,
                referencia,
                tipo_recebimento,
                data_vencimento,
                valor_final,
                saldo_restante,
                status,
                numero_contrato,
                competencia
           FROM recebimentos
          WHERE id_empresa = :empresa_id
            AND id_cliente = :cliente_id
            AND status IN ('aberto', 'gerado', 'parcial', 'vencido')
            AND saldo_restante > 0
          ORDER BY data_vencimento ASC, id ASC"
    );
    $stmt->execute([
        'empresa_id' => (int) env_value('VIA_CCM_COMPANY_VALUE', '2'),
        'cliente_id' => $externalClientId,
    ]);

    return $stmt->fetchAll();
}

function log_client_access(int $empresaId, ?int $clienteId, string $evento, ?string $pagina = null, array $details = []): void
{
    $stmt = db()->prepare(
        'INSERT INTO acessos_clientes (empresa_id, cliente_id, evento, pagina, detalhes, ip, user_agent)
         VALUES (:empresa_id, :cliente_id, :evento, :pagina, :detalhes, :ip, :user_agent)'
    );
    $stmt->execute([
        'empresa_id' => $empresaId,
        'cliente_id' => $clienteId,
        'evento' => $evento,
        'pagina' => $pagina,
        'detalhes' => $details ? json_encode($details, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) : null,
        'ip' => $_SERVER['REMOTE_ADDR'] ?? null,
        'user_agent' => substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255),
    ]);
}
