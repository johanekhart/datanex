-- ============================================================
-- Datanex.nl — Startdata (seed)
-- Voer dit bestand uit ná schema.sql
-- ============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- Leeg alle tabellen zodat het bestand opnieuw uitvoerbaar is
TRUNCATE TABLE `hype_scores`;
TRUNCATE TABLE `privacy_metrics`;
TRUNCATE TABLE `agent_metrics`;
TRUNCATE TABLE `project_stats`;
TRUNCATE TABLE `projects`;

-- ============================================================
-- PROJECTEN
-- ============================================================

-- ------------------------------------------------------------
-- Agent projecten — autonome AI-agents op de blockchain
-- ------------------------------------------------------------
INSERT INTO `projects` (`naam`, `ticker`, `slug`, `categorie`, `beschrijving`, `website`, `coingecko_id`, `actief`) VALUES
(
    'Virtuals Protocol', 'VIRTUAL', 'virtuals', 'agent',
    'Gedecentraliseerd platform voor het lanceren en beheren van AI-agents op de blockchain. Agents verdienen autonome inkomsten via on-chain economieën.',
    'https://app.virtuals.io', 'virtual-protocol', 1
),
(
    'Bittensor', 'TAO', 'bittensor', 'agent',
    'Gedecentraliseerd netwerk van machine-learning subnets dat AI-capaciteit verhandelt als commodity. Validators en miners beloond met TAO.',
    'https://bittensor.com', 'bittensor', 1
),
(
    'Fetch.ai', 'FET', 'fetch-ai', 'agent',
    'Platform voor autonome AI-agents die taken uitvoeren, data delen en economische beslissingen nemen. Onderdeel van de Artificial Superintelligence Alliance.',
    'https://fetch.ai', 'fetch-ai', 1
),
(
    'Ocean Protocol', 'OCEAN', 'ocean-protocol', 'agent',
    'Gedecentraliseerde datamarktplaats waarmee AI-modellen en datasets veilig verhandeld kunnen worden. Data tokeniseren als NFT.',
    'https://oceanprotocol.com', 'ocean-protocol', 1
),
(
    'SingularityNET', 'AGIX', 'singularitynet', 'agent',
    'Open platform voor het creëren, delen en verhandelen van AI-diensten op een gedecentraliseerde marktplaats. Opgericht door de makers van Sophia de robot.',
    'https://singularitynet.io', 'singularitynet', 1
);

-- ------------------------------------------------------------
-- Compute projecten — gedecentraliseerde rekenkracht
-- ------------------------------------------------------------
INSERT INTO `projects` (`naam`, `ticker`, `slug`, `categorie`, `beschrijving`, `website`, `coingecko_id`, `actief`) VALUES
(
    'Render Network', 'RNDR', 'render', 'compute',
    'Gedecentraliseerd GPU-rendernetwerk dat idle rekenkracht verbindt met makers en AI-workloads. Gebouwd op Solana voor hoge doorvoer.',
    'https://rendernetwork.com', 'render-token', 1
),
(
    'Akash Network', 'AKT', 'akash', 'compute',
    'Open source gedecentraliseerde cloudmarktplaats voor het huren en verhuren van compute-resources. Alternatief voor AWS en Google Cloud.',
    'https://akash.network', 'akash-network', 1
),
(
    'io.net', 'IO', 'io-net', 'compute',
    'Gedecentraliseerd GPU-netwerk dat idle rekenkracht bundelt tot clusters voor AI- en ML-workloads. Verbindt datacenter- en consumentGPU''s.',
    'https://io.net', 'io-net', 1
),
(
    'Nosana', 'NOS', 'nosana', 'compute',
    'Gedecentraliseerd CI/CD en GPU-compute platform gebouwd op Solana, gericht op AI-inference workloads voor ontwikkelaars en teams.',
    'https://nosana.io', 'nosana', 1
);

-- ------------------------------------------------------------
-- Privacy projecten — vertrouwelijke en privé blockchain-tech
-- ------------------------------------------------------------
INSERT INTO `projects` (`naam`, `ticker`, `slug`, `categorie`, `beschrijving`, `website`, `coingecko_id`, `actief`) VALUES
(
    'NEAR Protocol', 'NEAR', 'near', 'privacy',
    'Layer-1 blockchain met native privacy-features via chain signatures en TEE-integratie voor vertrouwelijke smart contracts en private AI-inference.',
    'https://near.org', 'near', 1
),
(
    'Oasis Network', 'ROSE', 'oasis', 'privacy',
    'Privacy-first blockchain met Trusted Execution Environments voor vertrouwelijk smart contract gebruik en private data tokenisering.',
    'https://oasisprotocol.org', 'oasis-network', 1
),
(
    'Zcash', 'ZEC', 'zcash', 'privacy',
    'Privacy-munt met zero-knowledge proofs (zk-SNARKs) voor volledig afgeschermde transacties. Een van de langstlopende ZK-implementaties in productie.',
    'https://z.cash', 'zcash', 1
),
(
    'Aleph Zero', 'AZERO', 'aleph-zero', 'privacy',
    'Privacy-blockchain met ZK-proofs en TEE die instant finality combineert met vertrouwelijke smart contracts. Gericht op enterprise privacy-use cases.',
    'https://alephzero.org', 'aleph-zero', 1
);

SET FOREIGN_KEY_CHECKS = 1;
