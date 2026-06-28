-- ============================================================
-- Datanex.nl — Databaseschema
-- MySQL / MariaDB
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ------------------------------------------------------------
-- 1. projects
--    Één rij per bijgehouden AI-project
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `projects` (
    `id`            INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    `naam`          VARCHAR(100)        NOT NULL,
    `slug`          VARCHAR(100)        NOT NULL UNIQUE,
    `categorie`     ENUM('agent','privacy','compute','data') NOT NULL,
    `beschrijving`  TEXT,
    `website`       VARCHAR(255),
    `logo_url`      VARCHAR(255),
    `actief`        TINYINT(1)          NOT NULL DEFAULT 1,
    `aangemaakt_op` DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_categorie` (`categorie`),
    INDEX `idx_slug`      (`slug`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. project_stats
--    Dagelijkse marktdata per project (prijs, marktcap, volume)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `project_stats` (
    `id`                  INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    `project_id`          INT UNSIGNED   NOT NULL,
    `datum`               DATE           NOT NULL,
    `marktcap`            DECIMAL(20,2)  DEFAULT NULL COMMENT 'USD',
    `prijs`               DECIMAL(20,8)  DEFAULT NULL COMMENT 'USD',
    `volume_24h`          DECIMAL(20,2)  DEFAULT NULL COMMENT 'USD',
    `prijs_wijziging_24h` DECIMAL(10,4)  DEFAULT NULL COMMENT 'Percentage',
    `bijgewerkt_op`       DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_project_datum` (`project_id`, `datum`),
    INDEX `idx_ps_datum`      (`datum`),
    INDEX `idx_ps_project_id` (`project_id`),
    CONSTRAINT `fk_ps_project`
        FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. agent_metrics
--    On-chain metrics voor AI Agent projecten
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `agent_metrics` (
    `id`                   INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    `project_id`           INT UNSIGNED   NOT NULL,
    `datum`                DATE           NOT NULL,
    `protocol_revenue`     DECIMAL(20,2)  DEFAULT NULL COMMENT 'USD, maandelijks',
    `active_wallets`       BIGINT UNSIGNED DEFAULT NULL COMMENT 'Unieke actieve wallets (dagelijks)',
    `agent_gdp`            DECIMAL(20,2)  DEFAULT NULL COMMENT 'Agent GDP / aGDP in USD',
    `completed_jobs`       BIGINT UNSIGNED DEFAULT NULL COMMENT 'Voltooide agent-jobs',
    `agent_volume`         DECIMAL(20,2)  DEFAULT NULL COMMENT 'Agent-to-agent transactievolume USD',
    `bijgewerkt_op`        DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_am_project_datum` (`project_id`, `datum`),
    INDEX `idx_am_datum`      (`datum`),
    INDEX `idx_am_project_id` (`project_id`),
    CONSTRAINT `fk_am_project`
        FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. privacy_metrics
--    On-chain metrics voor AI Privacy projecten
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `privacy_metrics` (
    `id`                       INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    `project_id`               INT UNSIGNED   NOT NULL,
    `datum`                    DATE           NOT NULL,
    `private_inference_volume` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Aantal private inference-verzoeken',
    `tee_nodes`                INT UNSIGNED   DEFAULT NULL COMMENT 'Actieve Trusted Execution Environment nodes',
    `zk_transacties`           BIGINT UNSIGNED DEFAULT NULL COMMENT 'Zero-knowledge proof transacties',
    `compute_nodes`            INT UNSIGNED   DEFAULT NULL COMMENT 'Confidential compute nodes',
    `data_volume`              DECIMAL(20,2)  DEFAULT NULL COMMENT 'Data marketplace volume in USD',
    `bijgewerkt_op`            DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_pm_project_datum` (`project_id`, `datum`),
    INDEX `idx_pm_datum`      (`datum`),
    INDEX `idx_pm_project_id` (`project_id`),
    CONSTRAINT `fk_pm_project`
        FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 5. hype_scores
--    Utility vs Hype score + GitHub activiteit
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `hype_scores` (
    `id`             INT UNSIGNED   NOT NULL AUTO_INCREMENT,
    `project_id`     INT UNSIGNED   NOT NULL,
    `datum`          DATE           NOT NULL,
    `utility_score`  TINYINT UNSIGNED DEFAULT NULL COMMENT '0–100: hoe nuttig is het project echt',
    `hype_score`     TINYINT UNSIGNED DEFAULT NULL COMMENT '0–100: sociale hype (sentiment, mentions)',
    `github_commits` INT UNSIGNED   DEFAULT NULL COMMENT 'Commits in de afgelopen 30 dagen',
    `bijgewerkt_op`  DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_hs_project_datum` (`project_id`, `datum`),
    INDEX `idx_hs_datum`      (`datum`),
    INDEX `idx_hs_project_id` (`project_id`),
    CONSTRAINT `fk_hs_project`
        FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- DUMMY DATA
-- ============================================================

-- ------------------------------------------------------------
-- projects
-- ------------------------------------------------------------
INSERT INTO `projects` (`naam`, `slug`, `categorie`, `beschrijving`, `website`, `logo_url`, `actief`) VALUES
('Virtuals Protocol', 'virtuals',   'agent',   'Gedecentraliseerd platform voor het lanceren en beheren van AI-agents op de blockchain.',            'https://app.virtuals.io',     NULL, 1),
('Bittensor',         'bittensor',  'agent',   'Gedecentraliseerd netwerk van machine-learning subnets dat AI-capaciteit verhandelt als commodity.',  'https://bittensor.com',       NULL, 1),
('Render Network',    'render',     'compute', 'Gedecentraliseerd GPU-rendernetwerk dat rekenkracht verbindt met makers en AI-workloads.',             'https://rendernetwork.com',   NULL, 1),
('NEAR Protocol',     'near',       'privacy', 'Layer-1 blockchain met native privacy-features via chain signatures en TEE-integratie.',               'https://near.org',            NULL, 1),
('Oasis Network',     'oasis',      'privacy', 'Privacy-first blockchain met Trusted Execution Environments voor vertrouwelijk smart contract gebruik.','https://oasisprotocol.org',  NULL, 1),
('Zcash',             'zcash',      'privacy', 'Privacy-munten met zero-knowledge proofs (zk-SNARKs) voor afgeschermde transacties.',                  'https://z.cash',              NULL, 1);

-- ------------------------------------------------------------
-- project_stats — meest recente dag
-- ------------------------------------------------------------
INSERT INTO `project_stats` (`project_id`, `datum`, `marktcap`, `prijs`, `volume_24h`, `prijs_wijziging_24h`) VALUES
(1, '2026-06-28',  950000000.00,  1.14,    62000000.00,   3.20),   -- Virtuals
(2, '2026-06-28', 3800000000.00, 26.40,   185000000.00,  -1.50),   -- Bittensor
(3, '2026-06-28', 1450000000.00,  5.82,    98000000.00,   2.10),   -- Render
(4, '2026-06-28', 6200000000.00,  5.91,   310000000.00,   0.80),   -- NEAR
(5, '2026-06-28',  540000000.00,  0.22,    34000000.00,  -0.60),   -- Oasis
(6, '2026-06-28',  870000000.00, 37.50,    55000000.00,   1.10);   -- Zcash

-- ------------------------------------------------------------
-- agent_metrics — Virtuals & Bittensor
-- ------------------------------------------------------------
INSERT INTO `agent_metrics` (`project_id`, `datum`, `protocol_revenue`, `active_wallets`, `agent_gdp`, `completed_jobs`, `agent_volume`) VALUES
(1, '2026-06-28',  480000.00, 92000,  1200000.00, 4500000, 28000000.00),  -- Virtuals
(1, '2026-06-27',  460000.00, 88000,  1150000.00, 4200000, 26500000.00),
(2, '2026-06-28', 1200000.00, 45000, 22000000.00,  320000, 95000000.00),  -- Bittensor
(2, '2026-06-27', 1150000.00, 43000, 21000000.00,  310000, 91000000.00);

-- ------------------------------------------------------------
-- privacy_metrics — NEAR, Oasis, Zcash
-- ------------------------------------------------------------
INSERT INTO `privacy_metrics` (`project_id`, `datum`, `private_inference_volume`, `tee_nodes`, `zk_transacties`, `compute_nodes`, `data_volume`) VALUES
(4, '2026-06-28', 850000, 320,  NULL,    NULL, 1200000.00),  -- NEAR
(4, '2026-06-27', 810000, 315,  NULL,    NULL, 1150000.00),
(5, '2026-06-28', 120000, 180,  45000,   180,   320000.00),  -- Oasis
(5, '2026-06-27', 115000, 178,  43000,   178,   310000.00),
(6, '2026-06-28',   NULL, NULL, 98000,  NULL,          NULL),  -- Zcash (alleen zk-txs)
(6, '2026-06-27',   NULL, NULL, 94000,  NULL,          NULL);

-- ------------------------------------------------------------
-- hype_scores — alle zes projecten
-- ------------------------------------------------------------
INSERT INTO `hype_scores` (`project_id`, `datum`, `utility_score`, `hype_score`, `github_commits`) VALUES
(1, '2026-06-28', 62, 85, 38),  -- Virtuals:  hoog gehyped, redelijke utility
(2, '2026-06-28', 78, 72, 95),  -- Bittensor: sterke utility + actieve dev
(3, '2026-06-28', 71, 65, 62),  -- Render:    solide utility, minder hype
(4, '2026-06-28', 69, 58, 110), -- NEAR:      mature chain, stabiele scores
(5, '2026-06-28', 74, 44, 74),  -- Oasis:     niche focus, lage hype
(6, '2026-06-28', 66, 40, 29);  -- Zcash:     bewezen tech, weinig buzz

SET FOREIGN_KEY_CHECKS = 1;
