<?php
/* ══════════════════════════════════════════
   Datanex — API: Alle projecten ophalen
   Geeft alle actieve projecten terug als JSON,
   inclusief laatste marktdata, metrics en hype scores.
   Optionele filter: ?categorie=agent|privacy|compute|data
══════════════════════════════════════════ */

require_once __DIR__ . '/../config.php';
jsonHeaders();

try {
    $pdo = dbVerbinding();

    /* ── Filter op categorie indien meegegeven ── */
    $categorie = $_GET['categorie'] ?? null;
    $categorie_where = '';
    $params = [];

    if ($categorie && in_array($categorie, ['agent', 'privacy', 'compute', 'data'], true)) {
        $categorie_where = 'AND p.categorie = :categorie';
        $params[':categorie'] = $categorie;
    }

    /* ── Alle actieve projecten met laatste statistieken ── */
    $sql = "
        SELECT
            p.id,
            p.naam,
            p.slug,
            p.categorie,
            p.beschrijving,
            p.website,

            /* Laatste marktdata */
            ps.marktcap,
            ps.prijs,
            ps.volume_24h,
            ps.prijs_wijziging_24h,

            /* Hype vs utility */
            hs.utility_score,
            hs.hype_score,
            hs.github_commits,

            /* Agent metrics */
            am.protocol_revenue,
            am.active_wallets,
            am.agent_gdp,
            am.completed_jobs,
            am.agent_volume,

            /* Privacy metrics */
            pm.private_inference_volume,
            pm.tee_nodes,
            pm.zk_transacties,
            pm.compute_nodes,
            pm.data_volume

        FROM projects p

        LEFT JOIN project_stats ps
            ON ps.project_id = p.id
            AND ps.datum = (
                SELECT MAX(datum) FROM project_stats WHERE project_id = p.id
            )

        LEFT JOIN hype_scores hs
            ON hs.project_id = p.id
            AND hs.datum = (
                SELECT MAX(datum) FROM hype_scores WHERE project_id = p.id
            )

        LEFT JOIN agent_metrics am
            ON am.project_id = p.id
            AND am.datum = (
                SELECT MAX(datum) FROM agent_metrics WHERE project_id = p.id
            )

        LEFT JOIN privacy_metrics pm
            ON pm.project_id = p.id
            AND pm.datum = (
                SELECT MAX(datum) FROM privacy_metrics WHERE project_id = p.id
            )

        WHERE p.actief = 1
        $categorie_where
        ORDER BY ps.marktcap DESC
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $projecten = $stmt->fetchAll();

    /* Zet getallen om naar floats/ints zodat JSON correct is */
    foreach ($projecten as &$p) {
        $p['id']                        = (int)   $p['id'];
        $p['marktcap']                  = $p['marktcap']                  !== null ? (float) $p['marktcap']                  : null;
        $p['prijs']                     = $p['prijs']                     !== null ? (float) $p['prijs']                     : null;
        $p['volume_24h']                = $p['volume_24h']                !== null ? (float) $p['volume_24h']                : null;
        $p['prijs_wijziging_24h']       = $p['prijs_wijziging_24h']       !== null ? (float) $p['prijs_wijziging_24h']       : null;
        $p['utility_score']             = $p['utility_score']             !== null ? (int)   $p['utility_score']             : null;
        $p['hype_score']                = $p['hype_score']                !== null ? (int)   $p['hype_score']                : null;
        $p['github_commits']            = $p['github_commits']            !== null ? (int)   $p['github_commits']            : null;
        $p['protocol_revenue']          = $p['protocol_revenue']          !== null ? (float) $p['protocol_revenue']          : null;
        $p['active_wallets']            = $p['active_wallets']            !== null ? (int)   $p['active_wallets']            : null;
        $p['agent_gdp']                 = $p['agent_gdp']                 !== null ? (float) $p['agent_gdp']                 : null;
        $p['completed_jobs']            = $p['completed_jobs']            !== null ? (int)   $p['completed_jobs']            : null;
        $p['agent_volume']              = $p['agent_volume']              !== null ? (float) $p['agent_volume']              : null;
        $p['private_inference_volume']  = $p['private_inference_volume']  !== null ? (int)   $p['private_inference_volume']  : null;
        $p['tee_nodes']                 = $p['tee_nodes']                 !== null ? (int)   $p['tee_nodes']                 : null;
        $p['zk_transacties']            = $p['zk_transacties']            !== null ? (int)   $p['zk_transacties']            : null;
        $p['compute_nodes']             = $p['compute_nodes']             !== null ? (int)   $p['compute_nodes']             : null;
        $p['data_volume']               = $p['data_volume']               !== null ? (float) $p['data_volume']               : null;
    }
    unset($p);

    /* ── Sectortotalen voor de key-stats balk ── */
    $sector_sql = "
        SELECT
            SUM(ps.marktcap)        AS totaal_marktcap,
            COUNT(DISTINCT p.id)    AS actieve_projecten,
            SUM(am.agent_gdp)       AS totaal_agent_gdp,
            SUM(am.active_wallets)  AS totaal_wallets
        FROM projects p
        LEFT JOIN project_stats ps
            ON ps.project_id = p.id
            AND ps.datum = (SELECT MAX(datum) FROM project_stats WHERE project_id = p.id)
        LEFT JOIN agent_metrics am
            ON am.project_id = p.id
            AND am.datum = (SELECT MAX(datum) FROM agent_metrics WHERE project_id = p.id)
        WHERE p.actief = 1
    ";
    $sector = $pdo->query($sector_sql)->fetch();

    echo json_encode([
        'succes'     => true,
        'sector'     => [
            'totaal_marktcap'    => $sector['totaal_marktcap']   !== null ? (float) $sector['totaal_marktcap']   : null,
            'actieve_projecten'  => (int) $sector['actieve_projecten'],
            'totaal_agent_gdp'   => $sector['totaal_agent_gdp']  !== null ? (float) $sector['totaal_agent_gdp']  : null,
            'totaal_wallets'     => $sector['totaal_wallets']     !== null ? (int)   $sector['totaal_wallets']    : null,
        ],
        'projecten'  => $projecten,
        'bijgewerkt' => date('c'),
    ], JSON_UNESCAPED_UNICODE);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['succes' => false, 'fout' => 'Serverfout bij ophalen projecten']);
}
