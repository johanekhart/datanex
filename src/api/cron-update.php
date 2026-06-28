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

/* ── Voer de data-ophaalroutine uit ── */
require_once __DIR__ . '/fetch-data.php';

$resultaat = fetchCoinGeckoData();

/* ── Sla het logboek op naast dit bestand ── */
$log_regel = sprintf(
    "[%s] bijgewerkt: %d/%d | fouten: %d | %s\n",
    date('Y-m-d H:i:s'),
    $resultaat['bijgewerkt'] ?? 0,
    $resultaat['totaal']     ?? 0,
    count($resultaat['fouten'] ?? []),
    $resultaat['succes'] ? 'OK' : ('FOUT: ' . ($resultaat['fout'] ?? 'onbekend'))
);

/* Log schrijven naar cron.log naast dit bestand */
$log_pad = __DIR__ . '/cron.log';
file_put_contents($log_pad, $log_regel, FILE_APPEND | LOCK_EX);

/* ── Geef resultaat terug als JSON ── */
jsonHeaders();
echo json_encode($resultaat, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
