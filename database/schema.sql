CREATE DATABASE IF NOT EXISTS u308598921_conecta_play
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE u308598921_conecta_play;

CREATE TABLE empresas (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(120) NOT NULL,
  slug VARCHAR(80) NOT NULL UNIQUE,
  cor_primaria VARCHAR(20) DEFAULT '#00a8ff',
  cor_secundaria VARCHAR(20) DEFAULT '#16c784',
  logo_url VARCHAR(255) NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE dominios_empresas (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  dominio VARCHAR(180) NOT NULL UNIQUE,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_dominios_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE usuarios_empresas (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  senha_hash VARCHAR(255) NOT NULL,
  perfil ENUM('admin', 'editor', 'financeiro', 'suporte') NOT NULL DEFAULT 'admin',
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_usuario_empresa_email (empresa_id, email),
  CONSTRAINT fk_usuarios_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE clientes_app (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  nome VARCHAR(120) NOT NULL,
  email VARCHAR(160) NOT NULL,
  telefone VARCHAR(30) NULL,
  documento VARCHAR(30) NULL,
  origem VARCHAR(40) NOT NULL DEFAULT 'conectaplay',
  origem_id VARCHAR(80) NULL,
  ultimo_acesso_em DATETIME NULL,
  senha_hash VARCHAR(255) NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_cliente_empresa_email (empresa_id, email),
  INDEX idx_cliente_empresa_documento (empresa_id, documento),
  INDEX idx_cliente_origem (empresa_id, origem, origem_id),
  CONSTRAINT fk_clientes_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE videos (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  titulo VARCHAR(160) NOT NULL,
  descricao TEXT NULL,
  categoria VARCHAR(80) DEFAULT 'Trailer',
  thumbnail_url VARCHAR(255) NULL,
  video_url VARCHAR(255) NULL,
  gratuito TINYINT(1) NOT NULL DEFAULT 1,
  destaque TINYINT(1) NOT NULL DEFAULT 0,
  ordem INT NOT NULL DEFAULT 0,
  duracao_segundos INT UNSIGNED NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_videos_empresa (empresa_id, ativo, destaque),
  CONSTRAINT fk_videos_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE parceiros (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  nome VARCHAR(140) NOT NULL,
  descricao TEXT NULL,
  categoria VARCHAR(80) DEFAULT 'Beneficio',
  logo_url VARCHAR(255) NULL,
  site_url VARCHAR(255) NULL,
  cupom VARCHAR(60) NULL,
  destaque TINYINT(1) NOT NULL DEFAULT 0,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_parceiros_empresa (empresa_id, ativo, destaque),
  CONSTRAINT fk_parceiros_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE cliques_parceiros (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  parceiro_id INT UNSIGNED NOT NULL,
  cliente_id INT UNSIGNED NULL,
  ip VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_cliques_empresa (empresa_id, criado_em),
  CONSTRAINT fk_cliques_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_cliques_parceiro
    FOREIGN KEY (parceiro_id) REFERENCES parceiros(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_cliques_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes_app(id)
    ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pedidos (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  cliente_id INT UNSIGNED NOT NULL,
  tipo ENUM('suporte', 'beneficio', 'financeiro', 'outro') NOT NULL DEFAULT 'suporte',
  mensagem TEXT NOT NULL,
  status ENUM('aberto', 'em_atendimento', 'resolvido', 'cancelado') NOT NULL DEFAULT 'aberto',
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_pedidos_empresa_cliente (empresa_id, cliente_id, status),
  CONSTRAINT fk_pedidos_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_pedidos_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes_app(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE pagamentos_app (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id INT UNSIGNED NOT NULL,
  cliente_id INT UNSIGNED NOT NULL,
  descricao VARCHAR(180) NOT NULL,
  valor DECIMAL(10,2) NOT NULL,
  status ENUM('pendente', 'pago', 'vencido', 'cancelado') NOT NULL DEFAULT 'pendente',
  vencimento DATE NULL,
  codigo_pix TEXT NULL,
  link_boleto VARCHAR(255) NULL,
  pago_em DATETIME NULL,
  criado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  atualizado_em TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_pagamentos_empresa_cliente (empresa_id, cliente_id, status),
  CONSTRAINT fk_pagamentos_empresa
    FOREIGN KEY (empresa_id) REFERENCES empresas(id)
    ON DELETE CASCADE,
  CONSTRAINT fk_pagamentos_cliente
    FOREIGN KEY (cliente_id) REFERENCES clientes_app(id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE contratos_app (
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

CREATE TABLE acessos_clientes (
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

INSERT INTO empresas (id, nome, slug, cor_primaria, cor_secundaria)
VALUES
  (1, 'Conecta Brasil', 'conecta-brasil', '#00a8ff', '#16c784'),
  (2, 'Vianet Minas', 'vianet-minas', '#2f80ed', '#f2c94c')
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  cor_primaria = VALUES(cor_primaria),
  cor_secundaria = VALUES(cor_secundaria);

INSERT INTO dominios_empresas (empresa_id, dominio)
VALUES
  (1, 'play.conectabrasil.online'),
  (2, 'play.vianetminas.com.br')
ON DUPLICATE KEY UPDATE
  empresa_id = VALUES(empresa_id),
  ativo = 1;

INSERT INTO clientes_app (empresa_id, nome, email, telefone, senha_hash)
VALUES
  (1, 'Cliente Conecta', 'cliente@conectabrasil.online', '(31) 90000-0001', '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO'),
  (2, 'Cliente Vianet', 'cliente@vianetminas.com.br', '(31) 90000-0002', '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO')
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  telefone = VALUES(telefone),
  ativo = 1;

INSERT INTO usuarios_empresas (empresa_id, nome, email, senha_hash, perfil)
VALUES
  (1, 'Admin Conecta Brasil', 'admin@conectabrasil.online', '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO', 'admin'),
  (2, 'Admin Vianet Minas', 'admin@vianetminas.com.br', '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO', 'admin')
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  perfil = VALUES(perfil),
  ativo = 1;

INSERT INTO videos (empresa_id, titulo, descricao, categoria, thumbnail_url, video_url, gratuito, destaque, ordem, duracao_segundos)
VALUES
  (1, 'Boas-vindas ao ConectaPlay', 'Conheca a plataforma de videos, beneficios e servicos da Conecta Brasil.', 'Institucional', 'https://images.unsplash.com/photo-1497015289639-54688650d173?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/conecta-boas-vindas.mp4', 1, 1, 1, 94),
  (1, 'Como usar seus beneficios', 'Veja como acessar cupons, parceiros e suporte pelo aplicativo.', 'Tutorial', 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/conecta-beneficios.mp4', 1, 0, 2, 130),
  (2, 'Vianet Minas Play', 'Conteudos gratuitos e vantagens exclusivas para clientes Vianet Minas.', 'Institucional', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/vianet-play.mp4', 1, 1, 1, 88),
  (2, 'Dicas para melhorar seu Wi-Fi', 'Aprenda cuidados simples para ter uma conexao melhor em casa.', 'Internet', 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/vianet-wifi.mp4', 1, 0, 2, 156);

INSERT INTO parceiros (empresa_id, nome, descricao, categoria, site_url, cupom, destaque)
VALUES
  (1, 'Conecta Store', 'Descontos em acessorios, roteadores e itens para casa conectada.', 'Tecnologia', 'https://conectabrasil.online', 'CONECTA10', 1),
  (1, 'Clube Local', 'Beneficios em comercios selecionados para clientes Conecta Brasil.', 'Beneficios', 'https://conectabrasil.online', 'CLUBE15', 0),
  (2, 'Vianet Shop', 'Condicoes especiais em roteadores e servicos de instalacao.', 'Internet', 'https://vianetminas.com.br', 'VIANET10', 1),
  (2, 'Minas Beneficios', 'Ofertas em parceiros regionais para clientes Vianet Minas.', 'Local', 'https://vianetminas.com.br', 'MINAS15', 0);

INSERT INTO pagamentos_app (empresa_id, cliente_id, descricao, valor, status, vencimento)
VALUES
  (1, 1, 'Mensalidade ConectaPlay', 59.90, 'pendente', DATE_ADD(CURDATE(), INTERVAL 7 DAY)),
  (2, 2, 'Mensalidade Vianet Minas', 69.90, 'pendente', DATE_ADD(CURDATE(), INTERVAL 7 DAY));

INSERT INTO contratos_app (empresa_id, cliente_id, plano, velocidade_download, velocidade_upload, status, endereco_instalacao, vencimento_dia, suporte_whatsapp)
VALUES
  (1, 1, 'Conecta Fibra Start', '300 Mbps', '150 Mbps', 'ativo', 'Endereco demonstrativo Conecta Brasil', 10, '5531900000001'),
  (2, 2, 'Vianet Fibra Plus', '500 Mbps', '250 Mbps', 'ativo', 'Endereco demonstrativo Vianet Minas', 10, '5531900000002');
