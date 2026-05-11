-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Tempo de geração: 11/05/2026 às 18:39
-- Versão do servidor: 11.8.6-MariaDB-log
-- Versão do PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `u308598921_conecta_play`
--

-- --------------------------------------------------------

--
-- Estrutura para tabela `clientes_app`
--

CREATE TABLE `clientes_app` (
  `id` int(10) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `nome` varchar(120) NOT NULL,
  `email` varchar(160) NOT NULL,
  `telefone` varchar(30) DEFAULT NULL,
  `documento` varchar(30) DEFAULT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `clientes_app`
--

INSERT INTO `clientes_app` (`id`, `empresa_id`, `nome`, `email`, `telefone`, `documento`, `senha_hash`, `ativo`, `criado_em`, `atualizado_em`) VALUES
(1, 1, 'Cliente Conecta', 'cliente@conectabrasil.online', '(31) 90000-0001', NULL, '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO', 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(2, 2, 'Cliente Vianet', 'cliente@vianetminas.com.br', '(31) 90000-0002', NULL, '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO', 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03');

-- --------------------------------------------------------

--
-- Estrutura para tabela `cliques_parceiros`
--

CREATE TABLE `cliques_parceiros` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `parceiro_id` int(10) UNSIGNED NOT NULL,
  `cliente_id` int(10) UNSIGNED DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `cliques_parceiros`
--

INSERT INTO `cliques_parceiros` (`id`, `empresa_id`, `parceiro_id`, `cliente_id`, `ip`, `user_agent`, `criado_em`) VALUES
(1, 1, 1, NULL, '200.5.35.26', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36', '2026-05-11 04:11:46');

-- --------------------------------------------------------

--
-- Estrutura para tabela `dominios_empresas`
--

CREATE TABLE `dominios_empresas` (
  `id` int(10) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `dominio` varchar(180) NOT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `dominios_empresas`
--

INSERT INTO `dominios_empresas` (`id`, `empresa_id`, `dominio`, `ativo`, `criado_em`) VALUES
(1, 1, 'play.conectabrasil.online', 1, '2026-05-11 03:44:03'),
(2, 2, 'play.vianetminas.com.br', 1, '2026-05-11 03:44:03');

-- --------------------------------------------------------

--
-- Estrutura para tabela `empresas`
--

CREATE TABLE `empresas` (
  `id` int(10) UNSIGNED NOT NULL,
  `nome` varchar(120) NOT NULL,
  `slug` varchar(80) NOT NULL,
  `cor_primaria` varchar(20) DEFAULT '#00a8ff',
  `cor_secundaria` varchar(20) DEFAULT '#16c784',
  `logo_url` varchar(255) DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `empresas`
--

INSERT INTO `empresas` (`id`, `nome`, `slug`, `cor_primaria`, `cor_secundaria`, `logo_url`, `ativo`, `criado_em`, `atualizado_em`) VALUES
(1, 'Conecta Brasil', 'conecta-brasil', '#00a8ff', '#16c784', NULL, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(2, 'Vianet Minas', 'vianet-minas', '#2f80ed', '#f2c94c', NULL, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03');

-- --------------------------------------------------------

--
-- Estrutura para tabela `pagamentos_app`
--

CREATE TABLE `pagamentos_app` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `cliente_id` int(10) UNSIGNED NOT NULL,
  `descricao` varchar(180) NOT NULL,
  `valor` decimal(10,2) NOT NULL,
  `status` enum('pendente','pago','vencido','cancelado') NOT NULL DEFAULT 'pendente',
  `vencimento` date DEFAULT NULL,
  `pago_em` datetime DEFAULT NULL,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `pagamentos_app`
--

INSERT INTO `pagamentos_app` (`id`, `empresa_id`, `cliente_id`, `descricao`, `valor`, `status`, `vencimento`, `pago_em`, `criado_em`, `atualizado_em`) VALUES
(1, 1, 1, 'Mensalidade ConectaPlay', 59.90, 'pendente', '2026-05-18', NULL, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(2, 2, 2, 'Mensalidade Vianet Minas', 69.90, 'pendente', '2026-05-18', NULL, '2026-05-11 03:44:03', '2026-05-11 03:44:03');

-- --------------------------------------------------------

--
-- Estrutura para tabela `parceiros`
--

CREATE TABLE `parceiros` (
  `id` int(10) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `nome` varchar(140) NOT NULL,
  `descricao` text DEFAULT NULL,
  `categoria` varchar(80) DEFAULT 'Beneficio',
  `logo_url` varchar(255) DEFAULT NULL,
  `site_url` varchar(255) DEFAULT NULL,
  `cupom` varchar(60) DEFAULT NULL,
  `destaque` tinyint(1) NOT NULL DEFAULT 0,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `parceiros`
--

INSERT INTO `parceiros` (`id`, `empresa_id`, `nome`, `descricao`, `categoria`, `logo_url`, `site_url`, `cupom`, `destaque`, `ativo`, `criado_em`, `atualizado_em`) VALUES
(1, 1, 'Conecta Store', 'Descontos em acessorios, roteadores e itens para casa conectada.', 'Tecnologia', NULL, 'https://conectabrasil.online', 'CONECTA10', 1, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(2, 1, 'Clube Local', 'Beneficios em comercios selecionados para clientes Conecta Brasil.', 'Beneficios', NULL, 'https://conectabrasil.online', 'CLUBE15', 0, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(3, 2, 'Vianet Shop', 'Condicoes especiais em roteadores e servicos de instalacao.', 'Internet', NULL, 'https://vianetminas.com.br', 'VIANET10', 1, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(4, 2, 'Minas Beneficios', 'Ofertas em parceiros regionais para clientes Vianet Minas.', 'Local', NULL, 'https://vianetminas.com.br', 'MINAS15', 0, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03');

-- --------------------------------------------------------

--
-- Estrutura para tabela `pedidos`
--

CREATE TABLE `pedidos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `cliente_id` int(10) UNSIGNED NOT NULL,
  `tipo` enum('suporte','beneficio','financeiro','outro') NOT NULL DEFAULT 'suporte',
  `mensagem` text NOT NULL,
  `status` enum('aberto','em_atendimento','resolvido','cancelado') NOT NULL DEFAULT 'aberto',
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estrutura para tabela `usuarios_empresas`
--

CREATE TABLE `usuarios_empresas` (
  `id` int(10) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `nome` varchar(120) NOT NULL,
  `email` varchar(160) NOT NULL,
  `senha_hash` varchar(255) NOT NULL,
  `perfil` enum('admin','editor','financeiro','suporte') NOT NULL DEFAULT 'admin',
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `usuarios_empresas`
--

INSERT INTO `usuarios_empresas` (`id`, `empresa_id`, `nome`, `email`, `senha_hash`, `perfil`, `ativo`, `criado_em`, `atualizado_em`) VALUES
(1, 1, 'Admin Conecta Brasil', 'admin@conectabrasil.online', '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO', 'admin', 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(2, 2, 'Admin Vianet Minas', 'admin@vianetminas.com.br', '$2y$10$9NiT4RLBZqTJtCP725davuo3.EvL4a25I7FqsbTQly3X5rTjBw8OO', 'admin', 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03');

-- --------------------------------------------------------

--
-- Estrutura para tabela `videos`
--

CREATE TABLE `videos` (
  `id` int(10) UNSIGNED NOT NULL,
  `empresa_id` int(10) UNSIGNED NOT NULL,
  `titulo` varchar(160) NOT NULL,
  `descricao` text DEFAULT NULL,
  `categoria` varchar(80) DEFAULT 'Trailer',
  `thumbnail_url` varchar(255) DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `gratuito` tinyint(1) NOT NULL DEFAULT 1,
  `destaque` tinyint(1) NOT NULL DEFAULT 0,
  `ordem` int(11) NOT NULL DEFAULT 0,
  `duracao_segundos` int(10) UNSIGNED DEFAULT NULL,
  `ativo` tinyint(1) NOT NULL DEFAULT 1,
  `criado_em` timestamp NOT NULL DEFAULT current_timestamp(),
  `atualizado_em` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Despejando dados para a tabela `videos`
--

INSERT INTO `videos` (`id`, `empresa_id`, `titulo`, `descricao`, `categoria`, `thumbnail_url`, `video_url`, `gratuito`, `destaque`, `ordem`, `duracao_segundos`, `ativo`, `criado_em`, `atualizado_em`) VALUES
(1, 1, 'Boas-vindas ao ConectaPlay', 'Conheca a plataforma de videos, beneficios e servicos da Conecta Brasil.', 'Institucional', 'https://images.unsplash.com/photo-1497015289639-54688650d173?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/conecta-boas-vindas.mp4', 1, 1, 1, 94, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(2, 1, 'Como usar seus beneficios', 'Veja como acessar cupons, parceiros e suporte pelo aplicativo.', 'Tutorial', 'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/conecta-beneficios.mp4', 1, 0, 2, 130, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(3, 2, 'Vianet Minas Play', 'Conteudos gratuitos e vantagens exclusivas para clientes Vianet Minas.', 'Institucional', 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/vianet-play.mp4', 1, 1, 1, 88, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03'),
(4, 2, 'Dicas para melhorar seu Wi-Fi', 'Aprenda cuidados simples para ter uma conexao melhor em casa.', 'Internet', 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?auto=format&fit=crop&w=900&q=80', 'https://example.com/videos/vianet-wifi.mp4', 1, 0, 2, 156, 1, '2026-05-11 03:44:03', '2026-05-11 03:44:03');

--
-- Índices para tabelas despejadas
--

--
-- Índices de tabela `clientes_app`
--
ALTER TABLE `clientes_app`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_cliente_empresa_email` (`empresa_id`,`email`);

--
-- Índices de tabela `cliques_parceiros`
--
ALTER TABLE `cliques_parceiros`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_cliques_empresa` (`empresa_id`,`criado_em`),
  ADD KEY `fk_cliques_parceiro` (`parceiro_id`),
  ADD KEY `fk_cliques_cliente` (`cliente_id`);

--
-- Índices de tabela `dominios_empresas`
--
ALTER TABLE `dominios_empresas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `dominio` (`dominio`),
  ADD KEY `fk_dominios_empresa` (`empresa_id`);

--
-- Índices de tabela `empresas`
--
ALTER TABLE `empresas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Índices de tabela `pagamentos_app`
--
ALTER TABLE `pagamentos_app`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pagamentos_empresa_cliente` (`empresa_id`,`cliente_id`,`status`),
  ADD KEY `fk_pagamentos_cliente` (`cliente_id`);

--
-- Índices de tabela `parceiros`
--
ALTER TABLE `parceiros`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_parceiros_empresa` (`empresa_id`,`ativo`,`destaque`);

--
-- Índices de tabela `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_pedidos_empresa_cliente` (`empresa_id`,`cliente_id`,`status`),
  ADD KEY `fk_pedidos_cliente` (`cliente_id`);

--
-- Índices de tabela `usuarios_empresas`
--
ALTER TABLE `usuarios_empresas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_usuario_empresa_email` (`empresa_id`,`email`);

--
-- Índices de tabela `videos`
--
ALTER TABLE `videos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_videos_empresa` (`empresa_id`,`ativo`,`destaque`);

--
-- AUTO_INCREMENT para tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `clientes_app`
--
ALTER TABLE `clientes_app`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `cliques_parceiros`
--
ALTER TABLE `cliques_parceiros`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de tabela `dominios_empresas`
--
ALTER TABLE `dominios_empresas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `empresas`
--
ALTER TABLE `empresas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `pagamentos_app`
--
ALTER TABLE `pagamentos_app`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `parceiros`
--
ALTER TABLE `parceiros`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `usuarios_empresas`
--
ALTER TABLE `usuarios_empresas`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de tabela `videos`
--
ALTER TABLE `videos`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restrições para tabelas despejadas
--

--
-- Restrições para tabelas `clientes_app`
--
ALTER TABLE `clientes_app`
  ADD CONSTRAINT `fk_clientes_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `cliques_parceiros`
--
ALTER TABLE `cliques_parceiros`
  ADD CONSTRAINT `fk_cliques_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes_app` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_cliques_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cliques_parceiro` FOREIGN KEY (`parceiro_id`) REFERENCES `parceiros` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `dominios_empresas`
--
ALTER TABLE `dominios_empresas`
  ADD CONSTRAINT `fk_dominios_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `pagamentos_app`
--
ALTER TABLE `pagamentos_app`
  ADD CONSTRAINT `fk_pagamentos_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes_app` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pagamentos_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `parceiros`
--
ALTER TABLE `parceiros`
  ADD CONSTRAINT `fk_parceiros_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_pedidos_cliente` FOREIGN KEY (`cliente_id`) REFERENCES `clientes_app` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_pedidos_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `usuarios_empresas`
--
ALTER TABLE `usuarios_empresas`
  ADD CONSTRAINT `fk_usuarios_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE;

--
-- Restrições para tabelas `videos`
--
ALTER TABLE `videos`
  ADD CONSTRAINT `fk_videos_empresa` FOREIGN KEY (`empresa_id`) REFERENCES `empresas` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
