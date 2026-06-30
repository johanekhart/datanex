<?php
/* ══════════════════════════════════════════
   Datanex — Utility Score berekening

   Score bestaat uit twee componenten (elk 0–50 punten):

   1. GitHub activiteit (0–50)
      Logaritmische schaal op commits in de afgelopen 30 dagen.
      10 commits ≈ 30pt | 50 commits ≈ 42pt | 100+ commits = 50pt

   2. Volume/MarktCap ratio (0–50)
      Dagelijks handelsvolume als percentage van de marktcap.
      Hoge ratio = actief gebruik, niet alleen speculatie.
      5% ratio = 25pt | 10% ratio = 50pt
══════════════════════════════════════════ */

require_once __DIR__ . '/../config.php';

/**
 * Berekent de Utility Score voor alle actieve projecten
 * op basis van GitHub activiteit en Volume/MarktCap ratio.
 * Slaat het resultaat op in hype_scores.utility_score.
 */
function berekenUtilityScores(): array {
    $pdo        = dbVerbinding();
    $vandaag    = date('Y-m-d');
    $bijgewerkt = 0;
    $resultaten = [];

    /* ── Haal marktdata en GitHub-commits op per project ── */
    $projecten = $pdo->query("
        SELECT
            p.id,
            p.naam,
            ps.volume_24h,
            ps.marktcap,
            hs.github_commits
        FROM projects p
        LEFT JOIN project_stats ps
            ON ps.project_id = p.id
            AND ps.datum = (SELECT MAX(datum) FROM project_stats WHERE project_id = p.id)
        LEFT JOIN hype_scores hs
            ON hs.project_id = p.id
            AND hs.datum = (SELECT MAX(datum) FROM hype_scores WHERE project_id = p.id)
        WHERE p.actief = 1
    ")->fetchAll();

    /* ── Upsert: voeg utility_score toe zonder github_commits te overschrijven ── */
    $upsert = $pdo->prepare("
        INSERT INTO hype_scores (project_id, datum, utility_score)
        VALUES (:project_id, :datum, :utility_score)
        ON DUPLICATE KEY UPDATE
            utility_score = VALUES(utility_score),
            bijgewerkt_op = CURRENT_TIMESTAMP
    ");

    foreach ($projecten as $p) {

        /* GitHub activiteitsscore (0–50) — logaritmische schaal */
        $github_score = 0;
        if (!empty($p['github_commits']) && $p['github_commits'] > 0) {
            $github_score = (int) min(50, round(log($p['github_commits'] + 1) / log(101) * 50));
        }

        /* Volume/MarktCap score (0–50) — hoog volume t.o.v. marktcap = actief gebruik */
        $volume_score = 0;
        if (!empty($p['marktcap']) && (float) $p['marktcap'] > 0 && !empty($p['volume_24h'])) {
            $ratio = (float) $p['volume_24h'] / (float) $p['marktcap'];
            $volume_score = (int) min(50, round($ratio * 500));
        }

        $utility_score = $github_score + $volume_score;

        $upsert->execute([
            ':project_id'    => (int) $p['id'],
            ':datum'         => $vandaag,
            ':utility_score' => $utility_score,
        ]);

        $resultaten[$p['naam']] = [
            'github'  => $github_score,
            'volume'  => $volume_score,
            'totaal'  => $utility_score,
        ];

        $bijgewerkt++;
    }

    return [
        'succes'     => true,
        'bijgewerkt' => $bijgewerkt,
        'scores'     => $resultaten,
        'timestamp'  => date('c'),
    ];
}

/* Direct aanroepen via browser voor testen */
if (basename($_SERVER['PHP_SELF'] ?? '') === 'calculate-scores.php') {
    jsonHeaders();
    echo json_encode(berekenUtilityScores(), JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);
}
