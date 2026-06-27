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
