-- ============================================================
-- Datanex.nl — Databaseschema
-- MySQL / MariaDB
--
-- Gebruik: voer dit bestand uit in phpMyAdmin om de database
-- opnieuw aan te maken. Daarna seed.sql uitvoeren.
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Verwijder bestaande tabellen in omgekeerde FK-volgorde
DROP TABLE IF EXISTS `hype_scores`;
DROP TABLE IF EXISTS `privacy_metrics`;
DROP TABLE IF EXISTS `agent_metrics`;
DROP TABLE IF EXISTS `project_stats`;
DROP TABLE IF EXISTS `projects`;

-- ------------------------------------------------------------
-- 1. projects
--    Één rij per bijgehouden AI crypto-project
-- ------------------------------------------------------------
CREATE TABLE `projects` (
    `id`            INT UNSIGNED        NOT NULL AUTO_INCREMENT,
    `naam`          VARCHAR(100)        NOT NULL,
    `ticker`        VARCHAR(20)         NOT NULL,
    `slug`          VARCHAR(100)        NOT NULL UNIQUE,
    `categorie`     ENUM('agent','compute','privacy') NOT NULL,
    `beschrijving`  TEXT,
    `website`       VARCHAR(255),
    `logo_url`      VARCHAR(255),
    `coingecko_id`  VARCHAR(100)        DEFAULT NULL COMMENT 'ID voor CoinGecko API-aanroepen',
    `actief`        TINYINT(1)          NOT NULL DEFAULT 1,
    `aangemaakt_op` DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_categorie`   (`categorie`),
    INDEX `idx_slug`        (`slug`),
    INDEX `idx_coingecko`   (`coingecko_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. project_stats
--    Dagelijkse marktdata per project (prijs, marktcap, volume)
-- ------------------------------------------------------------
CREATE TABLE `project_stats` (
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
--    On-chain metrics voor AI Agent én Compute projecten
-- ------------------------------------------------------------
CREATE TABLE `agent_metrics` (
    `id`               INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `project_id`       INT UNSIGNED    NOT NULL,
    `datum`            DATE            NOT NULL,
    `protocol_revenue` DECIMAL(20,2)   DEFAULT NULL COMMENT 'USD, maandelijks',
    `active_wallets`   BIGINT UNSIGNED DEFAULT NULL COMMENT 'Unieke actieve wallets (dagelijks)',
    `agent_gdp`        DECIMAL(20,2)   DEFAULT NULL COMMENT 'Agent GDP / aGDP in USD',
    `completed_jobs`   BIGINT UNSIGNED DEFAULT NULL COMMENT 'Voltooide agent-jobs of compute-taken',
    `agent_volume`     DECIMAL(20,2)   DEFAULT NULL COMMENT 'Agent-to-agent of compute transactievolume USD',
    `bijgewerkt_op`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
CREATE TABLE `privacy_metrics` (
    `id`                       INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `project_id`               INT UNSIGNED    NOT NULL,
    `datum`                    DATE            NOT NULL,
    `private_inference_volume` BIGINT UNSIGNED DEFAULT NULL COMMENT 'Aantal private inference-verzoeken',
    `tee_nodes`                INT UNSIGNED    DEFAULT NULL COMMENT 'Actieve Trusted Execution Environment nodes',
    `zk_transacties`           BIGINT UNSIGNED DEFAULT NULL COMMENT 'Zero-knowledge proof transacties',
    `compute_nodes`            INT UNSIGNED    DEFAULT NULL COMMENT 'Confidential compute nodes',
    `data_volume`              DECIMAL(20,2)   DEFAULT NULL COMMENT 'Data marketplace volume in USD',
    `bijgewerkt_op`            DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
CREATE TABLE `hype_scores` (
    `id`             INT UNSIGNED    NOT NULL AUTO_INCREMENT,
    `project_id`     INT UNSIGNED    NOT NULL,
    `datum`          DATE            NOT NULL,
    `utility_score`  TINYINT UNSIGNED DEFAULT NULL COMMENT '0–100: hoe nuttig is het project echt',
    `hype_score`     TINYINT UNSIGNED DEFAULT NULL COMMENT '0–100: sociale hype (sentiment, mentions)',
    `github_commits` INT UNSIGNED    DEFAULT NULL COMMENT 'Commits in de afgelopen 30 dagen',
    `bijgewerkt_op`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uq_hs_project_datum` (`project_id`, `datum`),
    INDEX `idx_hs_datum`      (`datum`),
    INDEX `idx_hs_project_id` (`project_id`),
    CONSTRAINT `fk_hs_project`
        FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
