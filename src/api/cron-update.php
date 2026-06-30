<?php
/* ══════════════════════════════════════════
   Datanex — Cron update endpoint
   Wordt elk uur aangeroepen via de cron job op mijn.host.
   Beveiligd met een token om willekeurige aanroepen te blokkeren.

   Cron URL: https://datanex.nl/api/cron-update.php?token=datanex_cron_2026
   Frequentie: elk uur (0 * * * *)
══════════════════════════════════════════ */

require_once __DIR__ . '/../config.php';

/* ── Tokenvalidatie: blokkeer aanroepen zonder geldig token ── */
$ontvangen_token = $_GET['token'] ?? '';

if ($ontvangen_token !== CRON_TOKEN) {
    http_response_code(403);
    header('Content-Type: text/plain');
    echo 'Toegang geweigerd.';
    exit;
}

/* ── CoinGecko marktdata ophalen ── */
require_once __DIR__ . '/fetch-data.php';
$coingecko = fetchCoinGeckoData();

/* ── GitHub commit-data ophalen ── */
require_once __DIR__ . '/fetch-github.php';
$github = fetchGitHubData();

/* ── Utility Scores berekenen op basis van verse data ── */
require_once __DIR__ . '/calculate-scores.php';
$scores = berekenUtilityScores();

/* ── Logboek wegschrijven ── */
$alle_fouten = array_merge($coingecko['fouten'] ?? [], $github['fouten'] ?? []);
$status      = ($coingecko['succes'] && $github['succes'] && $scores['succes']) ? 'OK' : 'FOUT';

$log_regel = sprintf(
    "[%s] coingecko: %d/%d | github: %d/%d | scores: %d | fouten: %d | %s\n",
    date('Y-m-d H:i:s'),
    $coingecko['bijgewerkt'] ?? 0,
    $coingecko['totaal']     ?? 0,
    $github['bijgewerkt']    ?? 0,
    $github['totaal']        ?? 0,
    $scores['bijgewerkt']    ?? 0,
    count($alle_fouten),
    $status
);

$log_pad = __DIR__ . '/cron.log';
file_put_contents($log_pad, $log_regel, FILE_APPEND | LOCK_EX);

/* ── Geef gecombineerd resultaat terug als JSON ── */
jsonHeaders();
echo json_encode([
    'coingecko' => $coingecko,
    'github'    => $github,
    'scores'    => $scores,
], JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
