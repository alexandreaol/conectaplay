<?php

declare(strict_types=1);

/**
 * Configuracao do MySQL.
 *
 * Na Hostinger, ajuste CP_DB_HOST e CP_DB_PASS no ambiente quando possivel.
 * Se preferir, edite diretamente os valores abaixo.
 */
return [
    'host' => getenv('CP_DB_HOST') ?: 'localhost',
    'port' => getenv('CP_DB_PORT') ?: '3306',
    'database' => getenv('CP_DB_NAME') ?: 'u308598921_conecta_play',
    'username' => getenv('CP_DB_USER') ?: 'u308598921_conecta_play',
    'password' => getenv('CP_DB_PASS') ?: 'Mesmox400#',
    'charset' => 'utf8mb4',
    'options' => [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ],
];
