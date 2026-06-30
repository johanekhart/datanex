<?php
/* ══════════════════════════════════════════
   Datanex — GitHub commit-data ophalen
   Telt commits van de afgelopen 30 dagen per project
   via de GitHub REST API en slaat het op in hype_scores.

   Gratis tier: 60 req/uur (voldoende voor 13 projecten per uur)
   Met GITHUB_TOKEN in config.php: 5000 req/uur
══════════════════════════════════════════ */

require_once __DIR__ . '/../config.php';

const GITHUB_API = 'https://api.github.com';

/**
 * Haalt GitHub commit-aantallen op voor alle actieve projecten met een github_repo.
 * Slaat resultaat op in hype_scores.github_commits.
 */
function fetchGitHubData(): array {
    $pdo        = dbVerbinding();
    $fouten     = [];
    $bijgewerkt = 0;
    $vandaag    = date('Y-m-d');
    $since      = date('Y-m-d\T00:00:00\Z', strtotime('-30 days'));

    /* ── Actieve projecten met een GitHub-repo ophalen ── */
    $projecten = $pdo->query(
        "SELECT id, naam, github_repo FROM projects WHERE actief = 1 AND github_repo IS NOT NULL"
    )->fetchAll();

    if (empty($projecten)) {
        return ['succes' => false, 'fout' => 'Geen projecten met GitHub-repo gevonden'];
    }

    /* ── HTTP-headers voor GitHub API ── */
    $headers = "User-Agent: Datanex.nl/1.0\r\nAccept: application/vnd.github.v3+json";

    /* Optioneel token verhoogt rate limit van 60 naar 5000 req/uur */
    if (defined('GITHUB_TOKEN') && GITHUB_TOKEN !== '') {
        $headers .= "\r\nAuthorization: Bearer " . GITHUB_TOKEN;
    }

    $context = stream_context_create([
        'http' => [
            'method'        => 'GET',
            'timeout'       => 10,
            'header'        => $headers,
            'ignore_errors' => true,
        ]
    ]);

    /* ── Prepared statement voor upsert in hype_scores ── */
    $upsert = $pdo->prepare("
        INSERT INTO hype_scores (project_id, datum, github_commits)
        VALUES (:project_id, :datum, :github_commits)
        ON DUPLICATE KEY UPDATE
            github_commits = VALUES(github_commits),
            bijgewerkt_op  = CURRENT_TIMESTAMP
    ");

    foreach ($projecten as $p) {
        $url = GITHUB_API . '/repos/' . $p['github_repo'] . '/commits?' . http_build_query([
            'since'    => $since,
            'per_page' => 100,
        ]);

        $response = @file_get_contents($url, false, $context);

        /* HTTP-statuscode uitlezen uit de response headers */
        $http_code = 0;
        if (!empty($http_response_header)) {
            foreach ($http_response_header as $header) {
                if (preg_match('#^HTTP/\S+\s+(\d+)#', $header, $m)) {
                    $http_code = (int) $m[1];
                }
            }
        }

        if ($response === false || $http_code !== 200) {
            $fouten[] = "{$p['naam']}: HTTP {$http_code}";
            continue;
        }

        $commits = json_decode($response, true);

        if (!is_array($commits)) {
            $fouten[] = "{$p['naam']}: Ongeldig antwoord van GitHub";
            continue;
        }

        /* Aantal commits in de afgelopen 30 dagen (max 100 per pagina) */
        $aantal_commits = count($commits);

        try {
            $upsert->execute([
                ':project_id'     => (int) $p['id'],
                ':datum'          => $vandaag,
                ':github_commits' => $aantal_commits,
            ]);
            $bijgewerkt++;
        } catch (PDOException $e) {
            $fouten[] = "{$p['naam']}: DB-fout — " . $e->getMessage();
        }
    }

    return [
        'succes'     => true,
        'bijgewerkt' => $bijgewerkt,
        'totaal'     => count($projecten),
        'fouten'     => $fouten,
        'timestamp'  => date('c'),
    ];
}

/* Direct aanroepen via browser of cURL voor testen */
if (basename($_SERVER['PHP_SELF'] ?? '') === 'fetch-github.php') {
    jsonHeaders();
    echo json_encode(fetchGitHubData(), JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
