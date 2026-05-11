ALTER TABLE clientes_app
  ADD COLUMN origem VARCHAR(40) NOT NULL DEFAULT 'conectaplay' AFTER documento,
  ADD COLUMN origem_id VARCHAR(80) NULL AFTER origem,
  ADD COLUMN ultimo_acesso_em DATETIME NULL AFTER origem_id,
  ADD INDEX idx_cliente_empresa_documento (empresa_id, documento),
  ADD INDEX idx_cliente_origem (empresa_id, origem, origem_id);

CREATE TABLE IF NOT EXISTS acessos_clientes (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  cliente_id INT UNSIGNED NULL,
  evento VARCHAR(60) NOT NULL,
  pagina VARCHAR(180) NULL,
  detalhes JSON NULL,
  ip VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_acessos_empresa_cliente (empresa_id, cliente_id, criado_em),
  INDEX idx_acessos_empresa_evento (empresa_id, evento, criado_em),
  CONSTRAINT fk_acessos_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_acessos_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes_app(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
