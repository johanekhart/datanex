<?php
/* ══════════════════════════════════════════
   Datanex — API: Statistieken per project
   Geeft historische data terug voor één project.
   Verplichte parameter: ?project=slug
   Optioneel: ?dagen=30 (standaard 30 dagen terug)
══════════════════════════════════════════ */

require_once __DIR__ . '/../config.php';
jsonHeaders();

/* ── Invoervalidatie ── */
$slug = trim($_GET['project'] ?? '');
$dagen = max(1, min(365, (int) ($_GET['dagen'] ?? 30)));

if ($slug === '' || !preg_match('/^[a-z0-9\-]+$/', $slug)) {
    http_response_code(400);
    echo json_encode(['succes' => false, 'fout' => 'Geef een geldig project-slug mee (?project=slug)']);
    exit;
}

try {
    $pdo = dbVerbinding();

    /* ── Project ophalen ── */
    $project_stmt = $pdo->prepare(
        'SELECT id, naam, slug, categorie, beschrijving, website
         FROM projects WHERE slug = :slug AND actief = 1 LIMIT 1'
    );
    $project_stmt->execute([':slug' => $slug]);
    $project = $project_stmt->fetch();

    if (!$project) {
        http_response_code(404);
        echo json_encode(['succes' => false, 'fout' => 'Project niet gevonden']);
        exit;
    }

    $project_id = (int) $project['id'];
    $vanaf = date('Y-m-d', strtotime("-{$dagen} days"));

    /* ── Marktdata (laatste N dagen) ── */
    $stats_stmt = $pdo->prepare(
        'SELECT datum, marktcap, prijs, volume_24h, prijs_wijziging_24h, bijgewerkt_op
         FROM project_stats
         WHERE project_id = :id AND datum >= :vanaf
         ORDER BY datum ASC'
    );
    $stats_stmt->execute([':id' => $project_id, ':vanaf' => $vanaf]);
    $stats = $stats_stmt->fetchAll();

    /* ── Agent metrics (indien van toepassing) ── */
    $agent_stmt = $pdo->prepare(
        'SELECT datum, protocol_revenue, active_wallets, agent_gdp,
                completed_jobs, agent_volume, bijgewerkt_op
         FROM agent_metrics
         WHERE project_id = :id AND datum >= :vanaf
         ORDER BY datum ASC'
    );
    $agent_stmt->execute([':id' => $project_id, ':vanaf' => $vanaf]);
    $agent_metrics = $agent_stmt->fetchAll();

    /* ── Privacy metrics (indien van toepassing) ── */
    $privacy_stmt = $pdo->prepare(
        'SELECT datum, private_inference_volume, tee_nodes, zk_transacties,
                compute_nodes, data_volume, bijgewerkt_op
         FROM privacy_metrics
         WHERE project_id = :id AND datum >= :vanaf
         ORDER BY datum ASC'
    );
    $privacy_stmt->execute([':id' => $project_id, ':vanaf' => $vanaf]);
    $privacy_metrics = $privacy_stmt->fetchAll();

    /* ── Hype scores ── */
    $hype_stmt = $pdo->prepare(
        'SELECT datum, utility_score, hype_score, github_commits, bijgewerkt_op
         FROM hype_scores
         WHERE project_id = :id AND datum >= :vanaf
         ORDER BY datum ASC'
    );
    $hype_stmt->execute([':id' => $project_id, ':vanaf' => $vanaf]);
    $hype_scores = $hype_stmt->fetchAll();

    echo json_encode([
        'succes'          => true,
        'project'         => $project,
        'dagen'           => $dagen,
        'stats'           => $stats,
        'agent_metrics'   => $agent_metrics,
        'privacy_metrics' => $privacy_metrics,
        'hype_scores'     => $hype_scores,
        'bijgewerkt'      => date('c'),
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['succes' => false, 'fout' => 'Serverfout bij ophalen statistieken']);
}
