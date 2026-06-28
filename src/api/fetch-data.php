<?php
/* ══════════════════════════════════════════
   Datanex — CoinGecko data ophalen en opslaan
   Haalt prijzen en marktdata op via de CoinGecko API
   en slaat ze op in de project_stats tabel.
   Kan direct aangeroepen worden (geeft JSON terug)
   of geïnclude worden door cron-update.php.
══════════════════════════════════════════ */

require_once __DIR__ . '/../config.php';

/* CoinGecko gratis API basis-URL */
const COINGECKO_API = 'https://api.coingecko.com/api/v3';

/**
 * Haalt marktdata op van CoinGecko en slaat het op in de database.
 * Geeft een array terug met het resultaat.
 */
function fetchCoinGeckoData(): array {
    $pdo     = dbVerbinding();
    $fouten  = [];
    $bijgewerkt = 0;
    $vandaag = date('Y-m-d');

    /* ── Actieve projecten ophalen met hun CoinGecko ID uit de database ── */
    $projecten = $pdo->query(
        "SELECT id, coingecko_id FROM projects WHERE actief = 1 AND coingecko_id IS NOT NULL"
    )->fetchAll();

    /* Bouw de lijst van coin IDs en de terugkoppeling naar project ID */
    $coin_ids = [];
    $slug_naar_project_id = [];

    foreach ($projecten as $p) {
        $coingecko_id = $p['coingecko_id'];
        $coin_ids[] = $coingecko_id;
        $slug_naar_project_id[$coingecko_id] = (int) $p['id'];
    }

    if (empty($coin_ids)) {
        return ['succes' => false, 'fout' => 'Geen projecten met CoinGecko ID gevonden'];
    }

    /* ── CoinGecko API aanroepen ── */
    $ids_param = implode(',', $coin_ids);
    $url = COINGECKO_API . '/coins/markets?' . http_build_query([
        'vs_currency' => 'usd',
        'ids'         => $ids_param,
        'order'       => 'market_cap_desc',
        'per_page'    => 100,
        'page'        => 1,
        'sparkline'   => 'false',
    ]);

    $context = stream_context_create([
        'http' => [
            'method'  => 'GET',
            'timeout' => 15,
            'header'  => "User-Agent: Datanex.nl/1.0\r\n",
        ]
    ]);

    $response = @file_get_contents($url, false, $context);

    if ($response === false) {
        return ['succes' => false, 'fout' => 'CoinGecko API niet bereikbaar'];
    }

    $coins = json_decode($response, true);

    if (!is_array($coins)) {
        return ['succes' => false, 'fout' => 'Ongeldig antwoord van CoinGecko API'];
    }

    /* ── Data opslaan in project_stats ── */
    $upsert = $pdo->prepare("
        INSERT INTO project_stats
            (project_id, datum, marktcap, prijs, volume_24h, prijs_wijziging_24h)
        VALUES
            (:project_id, :datum, :marktcap, :prijs, :volume_24h, :prijs_wijziging_24h)
        ON DUPLICATE KEY UPDATE
            marktcap            = VALUES(marktcap),
            prijs               = VALUES(prijs),
            volume_24h          = VALUES(volume_24h),
            prijs_wijziging_24h = VALUES(prijs_wijziging_24h),
            bijgewerkt_op       = CURRENT_TIMESTAMP
    ");

    foreach ($coins as $coin) {
        $coingecko_id = $coin['id'] ?? '';

        if (!isset($slug_naar_project_id[$coingecko_id])) {
            continue; /* Onbekende coin overslaan */
        }

        $project_id = $slug_naar_project_id[$coingecko_id];

        try {
            $upsert->execute([
                ':project_id'          => $project_id,
                ':datum'               => $vandaag,
                ':marktcap'            => $coin['market_cap']                    ?? null,
                ':prijs'               => $coin['current_price']                 ?? null,
                ':volume_24h'          => $coin['total_volume']                  ?? null,
                ':prijs_wijziging_24h' => $coin['price_change_percentage_24h']   ?? null,
            ]);
            $bijgewerkt++;
        } catch (PDOException $e) {
            $fouten[] = "Project ID {$project_id}: " . $e->getMessage();
        }
    }

    return [
        'succes'     => true,
        'bijgewerkt' => $bijgewerkt,
        'totaal'     => count($coin_ids),
        'fouten'     => $fouten,
        'timestamp'  => date('c'),
    ];
}

/* Als dit bestand direct in de browser/cURL aangeroepen wordt, direct uitvoeren */
if (basename($_SERVER['PHP_SELF'] ?? '') === 'fetch-data.php') {
    jsonHeaders();
    echo json_encode(fetchCoinGeckoData(), JSON_UNESCAPED_UNICODE);
}
