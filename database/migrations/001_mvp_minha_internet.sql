ALTER TABLE pagamentos_app
  ADD COLUMN codigo_pix TEXT NULL AFTER vencimento,
  ADD COLUMN link_boleto VARCHAR(255) NULL AFTER codigo_pix;

CREATE TABLE IF NOT EXISTS contratos_app (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  cliente_id INT UNSIGNED NOT NULL,
  plano VARCHAR(140) NOT NULL,
  velocidade_download VARCHAR(40) NULL,
  velocidade_upload VARCHAR(40) NULL,
  status ENUM('ativo', 'bloqueado', 'suspenso', 'cancelado') NOT NULL DEFAULT 'ativo',
  endereco_instalacao VARCHAR(255) NULL,
  vencimento_dia TINYINT UNSIGNED NULL,
  suporte_whatsapp VARCHAR(30) NULL,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_contratos_empresa_cliente (empresa_id, cliente_id, status),
  CONSTRAINT fk_contratos_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_contratos_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes_app(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO contratos_app (empresa_id, cliente_id, plano, velocidade_download, velocidade_upload, status, endereco_instalacao, vencimento_dia, suporte_whatsapp)
SELECT 1, 1, 'Conecta Fibra Start', '300 Mbps', '150 Mbps', 'ativo', 'Endereco demonstrativo Conecta Brasil', 10, '5531900000001'
WHERE NOT EXISTS (
  SELECT 1 FROM contratos_app WHERE empresa_id = 1 AND cliente_id = 1
);

INSERT INTO contratos_app (empresa_id, cliente_id, plano, velocidade_download, velocidade_upload, status, endereco_instalacao, vencimento_dia, suporte_whatsapp)
SELECT 2, 2, 'Vianet Fibra Plus', '500 Mbps', '250 Mbps', 'ativo', 'Endereco demonstrativo Vianet Minas', 10, '5531900000002'
WHERE NOT EXISTS (
  SELECT 1 FROM contratos_app WHERE empresa_id = 2 AND cliente_id = 2
);
