/* ══════════════════════════════════════════
   Datanex — Frontend JavaScript
══════════════════════════════════════════ */

/* ── 3D WIREFRAME ANIMATIE ── */
(function () {
  const canvas = document.getElementById('hero-canvas');
  if (!canvas) return;

  const ctx = canvas.getContext('2d');

  function resize() {
    canvas.width  = canvas.offsetWidth  * window.devicePixelRatio;
    canvas.height = canvas.offsetHeight * window.devicePixelRatio;
    ctx.scale(window.devicePixelRatio, window.devicePixelRatio);
  }
  resize();
  window.addEventListener('resize', resize);

  const W = () => canvas.offsetWidth;
  const H = () => canvas.offsetHeight;

  const NODE_COUNT = 38;
  const nodes = Array.from({ length: NODE_COUNT }, () => ({
    x:     Math.random() * 2 - 1,
    y:     Math.random() * 2 - 1,
    z:     Math.random() * 2 - 1,
    vx:    (Math.random() - 0.5) * 0.003,
    vy:    (Math.random() - 0.5) * 0.003,
    vz:    (Math.random() - 0.5) * 0.003,
    r:     Math.random() < 0.15 ? 3.5 : 1.8,
    pulse: Math.random() * Math.PI * 2,
  }));

  let angle = 0;

  function project(x, y, z) {
    const fov   = 800;
    const dist  = 2.5;
    const scale = fov / (fov + z * dist * W() * 0.002);
    return {
      sx:    W() / 2 + x * scale * W() * 0.38,
      sy:    H() / 2 + y * scale * H() * 0.38,
      scale,
    };
  }

  function rotY(x, z, a) {
    return {
      x: x * Math.cos(a) - z * Math.sin(a),
      z: x * Math.sin(a) + z * Math.cos(a),
    };
  }

  function draw(t) {
    ctx.clearRect(0, 0, W(), H());
    angle += 0.003;

    const proj = nodes.map(n => {
      const r = rotY(n.x, n.z, angle);
      return { ...project(r.x, n.y, r.z), r: n.r, pulse: n.pulse };
    });

    /* Verbindingslijnen tussen nabije nodes */
    for (let i = 0; i < proj.length; i++) {
      for (let j = i + 1; j < proj.length; j++) {
        const dx   = nodes[i].x - nodes[j].x;
        const dy   = nodes[i].y - nodes[j].y;
        const dz   = nodes[i].z - nodes[j].z;
        const dist = Math.sqrt(dx * dx + dy * dy + dz * dz);
        if (dist < 0.9) {
          ctx.beginPath();
          ctx.moveTo(proj[i].sx, proj[i].sy);
          ctx.lineTo(proj[j].sx, proj[j].sy);
          ctx.strokeStyle = `rgba(0,212,255,${(1 - dist / 0.9) * 0.22})`;
          ctx.lineWidth   = 0.8;
          ctx.stroke();
        }
      }
    }

    /* Nodes tekenen */
    proj.forEach((p, i) => {
      const pulse = Math.sin(t * 0.002 + nodes[i].pulse) * 0.5 + 0.5;
      const r     = p.r * p.scale;

      /* Glow voor grote nodes */
      if (p.r > 2) {
        const g = ctx.createRadialGradient(p.sx, p.sy, 0, p.sx, p.sy, r * 5);
        g.addColorStop(0, `rgba(0,212,255,${0.4 * pulse})`);
        g.addColorStop(1, 'rgba(0,212,255,0)');
        ctx.beginPath();
        ctx.arc(p.sx, p.sy, r * 5, 0, Math.PI * 2);
        ctx.fillStyle = g;
        ctx.fill();
      }

      ctx.beginPath();
      ctx.arc(p.sx, p.sy, r, 0, Math.PI * 2);
      ctx.fillStyle = p.r > 2
        ? '#00D4FF'
        : `rgba(0,212,255,${0.5 + 0.5 * pulse})`;
      ctx.fill();
    });

    /* Node posities bijwerken */
    nodes.forEach(n => {
      n.x += n.vx; n.y += n.vy; n.z += n.vz;
      if (Math.abs(n.x) > 1) n.vx *= -1;
      if (Math.abs(n.y) > 1) n.vy *= -1;
      if (Math.abs(n.z) > 1) n.vz *= -1;
    });

    requestAnimationFrame(draw);
  }

  requestAnimationFrame(draw);
})();


/* ══════════════════════════════════════════
   DASHBOARD — Data ophalen en renderen
══════════════════════════════════════════ */
(function () {

  /* ── Hulpfuncties voor getalopmaak ── */

  function formatValuta(n) {
    if (n == null) return '—';
    if (n >= 1e12) return '$' + (n / 1e12).toFixed(1) + 'T';
    if (n >= 1e9)  return '$' + (n / 1e9).toFixed(1)  + 'B';
    if (n >= 1e6)  return '$' + (n / 1e6).toFixed(1)  + 'M';
    if (n >= 1e3)  return '$' + (n / 1e3).toFixed(1)  + 'K';
    return '$' + Number(n).toFixed(2);
  }

  function formatGetal(n) {
    if (n == null) return '—';
    if (n >= 1e9)  return (n / 1e9).toFixed(1) + 'B';
    if (n >= 1e6)  return (n / 1e6).toFixed(1) + 'M';
    if (n >= 1e3)  return (n / 1e3).toFixed(0) + 'K';
    return Number(n).toLocaleString('nl-NL');
  }

  function formatDelta(n, suffix) {
    if (n == null) return '';
    const pijl  = n >= 0 ? '↑' : '↓';
    const teken = n >= 0 ? '+' : '';
    return pijl + ' ' + teken + Number(n).toFixed(1) + (suffix || '%');
  }

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  /* ── Project kaart renderen op basis van categorie ── */
  function renderKaart(p) {
    const cat = p.categorie;

    let primaireLabel, primaireHtml, secondaire;

    if (cat === 'agent') {
      const heeftRevenue = p.protocol_revenue != null;
      primaireLabel = heeftRevenue ? 'Protocol Revenue' : 'Agent GDP';
      const primVal = heeftRevenue ? p.protocol_revenue : p.agent_gdp;
      primaireHtml  = formatValuta(primVal) + ' <span class="card-value-unit">/ maand</span>';
      secondaire = [
        { label: 'Active Wallets',  val: formatGetal(p.active_wallets)  },
        { label: 'Completed Jobs',  val: formatGetal(p.completed_jobs)  },
      ];

    } else if (cat === 'compute') {
      primaireLabel = 'Protocol Revenue';
      primaireHtml  = formatValuta(p.protocol_revenue) + ' <span class="card-value-unit">/ maand</span>';
      secondaire = [
        { label: 'Active Wallets',  val: formatGetal(p.active_wallets)  },
        { label: 'Completed Jobs',  val: formatGetal(p.completed_jobs)  },
      ];

    } else { /* privacy */
      const heeftInference = p.private_inference_volume != null;
      if (heeftInference) {
        primaireLabel = 'Private Inference';
        primaireHtml  = formatGetal(p.private_inference_volume) + ' <span class="card-value-unit">req</span>';
      } else {
        primaireLabel = 'ZK-Proof Transacties';
        primaireHtml  = formatGetal(p.zk_transacties);
      }
      secondaire = [
        { label: 'TEE Nodes',      val: formatGetal(p.tee_nodes)     },
        { label: 'Data Volume',    val: formatValuta(p.data_volume)  },
      ];
    }

    const delta      = p.prijs_wijziging_24h;
    const deltaKlasse = delta != null && delta < 0 ? 'neg' : '';
    const deltaHtml   = delta != null
      ? `<div class="card-delta ${deltaKlasse}">${escapeHtml(formatDelta(delta, '% 24h'))}</div>`
      : '';

    const utilityScore = p.utility_score ?? 0;
    const barKlasse    = cat === 'privacy' ? 'bar-fill privacy' : 'bar-fill';

    const tagLabels = { agent: 'Agent', compute: 'Compute', privacy: 'Privacy' };
    const tagLabel  = tagLabels[cat] || escapeHtml(cat);

    /* Ticker uit de database, slug.toUpperCase() als fallback */
    const ticker = p.ticker || p.slug.toUpperCase();

    /* Marktdata altijd tonen als beschikbaar */
    const marktdataHtml = `
      <div class="card-secondary">
        <div class="card-secondary-item">
          <div class="card-label">Marktcap</div>
          <div class="card-secondary-val">${formatValuta(p.marktcap)}</div>
        </div>
        <div class="card-secondary-item">
          <div class="card-label">Volume 24u</div>
          <div class="card-secondary-val">${formatValuta(p.volume_24h)}</div>
        </div>
      </div>
    `;

    return `
      <div class="project-card">
        <div class="project-card-header">
          <div>
            <div class="project-name">${escapeHtml(p.naam)}</div>
            <div class="project-ticker">${escapeHtml(ticker)}</div>
          </div>
          <span class="tag tag-${escapeHtml(cat)}">${tagLabel}</span>
        </div>
        <div class="card-label">${escapeHtml(primaireLabel)}</div>
        <div class="card-value">${primaireHtml}</div>
        ${deltaHtml}
        ${marktdataHtml}
        <div class="card-secondary">
          ${secondaire.map(s => `
            <div class="card-secondary-item">
              <div class="card-label">${escapeHtml(s.label)}</div>
              <div class="card-secondary-val">${s.val}</div>
            </div>
          `).join('')}
        </div>
        <div class="card-label">Utility Score</div>
        <div class="bar"><div class="${barKlasse}" style="width: ${utilityScore}%"></div></div>
      </div>
    `;
  }

  /* ── Foutmelding tonen in een grid ── */
  function toonFout(id, tekst) {
    const el = document.getElementById(id);
    if (el) el.innerHTML = `<div class="grid-laadt" style="color:var(--mid-gray)">${escapeHtml(tekst)}</div>`;
  }

  /* ── Hoofd laadlogica ── */
  async function laadDashboard() {
    try {
      const resp = await fetch('api/get-projects.php');
      if (!resp.ok) throw new Error('HTTP ' + resp.status);

      const data = await resp.json();
      if (!data.succes) throw new Error(data.fout || 'API fout');

      /* Sector statistieken invullen */
      const s = data.sector || {};
      const vulIn = (id, waarde) => {
        const el = document.getElementById(id);
        if (el) el.textContent = waarde;
      };

      vulIn('stat-marktcap',  formatValuta(s.totaal_marktcap));
      vulIn('stat-projecten', s.actieve_projecten ?? '—');
      vulIn('stat-gdp',       formatValuta(s.totaal_agent_gdp));
      vulIn('stat-wallets',   formatGetal(s.totaal_wallets));

      /* Project grids vullen — één per categorie */
      const agentProjecten   = (data.projecten || []).filter(p => p.categorie === 'agent');
      const computeProjecten = (data.projecten || []).filter(p => p.categorie === 'compute');
      const privacyProjecten = (data.projecten || []).filter(p => p.categorie === 'privacy');

      const gridAgent   = document.getElementById('grid-agent');
      const gridCompute = document.getElementById('grid-compute');
      const gridPrivacy = document.getElementById('grid-privacy');

      if (gridAgent) {
        gridAgent.innerHTML = agentProjecten.length > 0
          ? agentProjecten.map(renderKaart).join('')
          : '<div class="grid-laadt">Geen agent-projecten gevonden</div>';
      }

      if (gridCompute) {
        gridCompute.innerHTML = computeProjecten.length > 0
          ? computeProjecten.map(renderKaart).join('')
          : '<div class="grid-laadt">Geen compute-projecten gevonden</div>';
      }

      if (gridPrivacy) {
        gridPrivacy.innerHTML = privacyProjecten.length > 0
          ? privacyProjecten.map(renderKaart).join('')
          : '<div class="grid-laadt">Geen privacy-projecten gevonden</div>';
      }

    } catch (fout) {
      console.error('Dashboard laad fout:', fout);
      toonFout('grid-agent',   'Data tijdelijk niet beschikbaar');
      toonFout('grid-compute', 'Data tijdelijk niet beschikbaar');
      toonFout('grid-privacy', 'Data tijdelijk niet beschikbaar');
    }
  }

  /* Start nadat de DOM geladen is */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', laadDashboard);
  } else {
    laadDashboard();
  }

})();
