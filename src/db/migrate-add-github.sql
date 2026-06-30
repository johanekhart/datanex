-- ============================================================
-- Datanex.nl — Migratie: github_repo kolom toevoegen
-- Voer dit EENMALIG uit in phpMyAdmin op de bestaande database.
-- Herstart daarna de cron of test via de cron URL.
-- ============================================================

ALTER TABLE `projects`
    ADD COLUMN `github_repo` VARCHAR(100) DEFAULT NULL
    COMMENT 'GitHub owner/repo voor commit-data (bijv. near/nearcore)'
    AFTER `coingecko_id`;

-- ------------------------------------------------------------
-- GitHub-repos instellen per project
-- Geverifieerde repos:
-- ------------------------------------------------------------
UPDATE `projects` SET `github_repo` = 'opentensor/bittensor'              WHERE `slug` = 'bittensor';
UPDATE `projects` SET `github_repo` = 'fetchai/uagents'                   WHERE `slug` = 'fetch-ai';
UPDATE `projects` SET `github_repo` = 'oceanprotocol/ocean.py'            WHERE `slug` = 'ocean-protocol';
UPDATE `projects` SET `github_repo` = 'singnet/snet-daemon'               WHERE `slug` = 'singularitynet';
UPDATE `projects` SET `github_repo` = 'akash-network/akash'               WHERE `slug` = 'akash';
UPDATE `projects` SET `github_repo` = 'nosana-ci/nosana-node'             WHERE `slug` = 'nosana';
UPDATE `projects` SET `github_repo` = 'near/nearcore'                     WHERE `slug` = 'near';
UPDATE `projects` SET `github_repo` = 'oasisprotocol/oasis-node'          WHERE `slug` = 'oasis';
UPDATE `projects` SET `github_repo` = 'zcash/zcash'                       WHERE `slug` = 'zcash';
UPDATE `projects` SET `github_repo` = 'Cardinal-Cryptography/aleph-node'  WHERE `slug` = 'aleph-zero';
UPDATE `projects` SET `github_repo` = 'rendernetwork/foundation-apps'     WHERE `slug` = 'render';

-- ------------------------------------------------------------
-- Onzeker — verifieer op GitHub voordat je deze instelt:
-- Virtuals Protocol: mogelijk Virtual-Protocol/virtuals-protocol
-- io.net:            mogelijk ionet-official/io-net
-- Voeg toe met: UPDATE projects SET github_repo = '...' WHERE slug = '...';
-- ------------------------------------------------------------
