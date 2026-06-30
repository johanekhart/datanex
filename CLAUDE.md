# Datanex — Project Instructies voor Claude Code

## Over het project

Datanex.nl is een data-dashboard dat inzicht geeft in AI crypto projecten.
De focus ligt op drie categorieën:

* **Agent** — autonome AI-agents op de blockchain (Virtuals, Bittensor, Fetch.ai, Ocean, SingularityNET)
* **Compute** — gedecentraliseerde rekenkracht (Render, Akash, io.net, Nosana)
* **Privacy** — vertrouwelijke blockchain-tech (NEAR, Oasis, Zcash, Aleph Zero)

Het doel: hype van echte utiliteit scheiden met verifieerbare on-chain statistieken.

---

## Technische stack

| Laag        | Technologie              |
|-------------|--------------------------|
| Frontend    | HTML5, CSS3, Vanilla JavaScript |
| Backend     | PHP 8+                   |
| Database    | MySQL / MariaDB          |
| Beheer DB   | phpMyAdmin               |
| Hosting     | mijn.host                |
| Domein      | datanex.nl (www → non-www redirect via .htaccess) |
| Versiebeheer| GitHub → auto-deploy via FTP Action |

---

## Bestandsstructuur

```
datanex/
├── CLAUDE.md
├── brand/
│   └── datanex-brand-identity.html  ← read-only huisstijl referentie
└── src/
    ├── index.html             ← homepage met drie secties
    ├── favicon.svg
    ├── .htaccess              ← redirect www → non-www
    ├── css/
    │   └── style.css
    ├── js/
    │   └── main.js            ← rendert drie grids: agent, compute, privacy
    ├── api/
    │   ├── fetch-data.php     ← CoinGecko marktdata (elk uur)
    │   ├── fetch-github.php   ← GitHub commits 30d (elk uur)
    │   ├── calculate-scores.php ← Utility Score berekening (elk uur)
    │   ├── get-projects.php   ← levert projectdata als JSON aan frontend
    │   ├── cron-update.php    ← cron endpoint: roept alle fetchers aan
    │   └── cron.log           ← logbestand van de cron runs
    └── db/
        ├── schema.sql         ← volledige databasestructuur (DROP + CREATE)
        ├── seed.sql           ← 13 projecten als startdata
        └── migrate-add-github.sql ← eenmalige migratie uitgevoerd op 2026-06-30
```

* Schrijf **alle** websitebestanden in `/src/`
* Schrijf **nooit** bestanden naar de root of naar `/brand/`
* `config.php` staat in `.gitignore` — nooit committen, bevat DB-wachtwoord en tokens

---

## Huisstijl

Raadpleeg altijd `/brand/datanex-brand-identity.html` voor de volledige huisstijl.
Hieronder een samenvatting voor snelle referentie.

### Kleuren (CSS variabelen)

```css
:root {
  --white:      #FFFFFF;
  --off-white:  #F7F7F8;
  --light-gray: #E8E8EC;
  --mid-gray:   #9999AA;
  --dark-gray:  #333344;
  --black:      #0A0A0F;
  --cyan:       #00D4FF;
  --cyan-dim:   rgba(0, 212, 255, 0.10);
  --cyan-mid:   rgba(0, 212, 255, 0.35);
}
```

### Typografie

```html
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
```

| Rol           | Font          | Gewicht | Grootte  | Letter-spacing |
|---------------|---------------|---------|----------|----------------|
| Hero headline | Space Grotesk | 700     | 48–56px  | -0.04em        |
| Section heading | Space Grotesk | 700   | 28–32px  | -0.03em        |
| Card title    | Space Grotesk | 600     | 18–20px  | -0.02em        |
| Body tekst    | Space Grotesk | 400     | 14–15px  | normaal        |
| Data waarden  | Space Grotesk | 700     | 24–36px  | -0.05em        |
| Labels / meta | Space Mono    | 400     | 10–11px  | 0.15em UC      |

### Logo

```html
<span style="font-family:'Space Grotesk',sans-serif; font-weight:700;
  font-size:18px; letter-spacing:-0.04em; color:#0A0A0F;">
  datanex<span style="color:#00D4FF;">.</span>
</span>
```

### Spacing & borders

| Element          | Waarde          |
|------------------|-----------------|
| Page padding     | 48px zijkanten  |
| Section padding  | 56px boven/onder|
| Card padding     | 20–24px         |
| Border-radius    | 6px max         |
| Dividers         | 1px solid #E8E8EC |
| Max content width| 1280px          |
| Card grid gap    | 20px            |

---

## Do's & Don'ts

### ✓ Do
* Witte achtergrond (#FFFFFF) als basis
* Cyan (#00D4FF) alleen als accent
* Space Mono voor labels, data-waarden en metadata
* Getallen groot en bold met negatieve letter-spacing
* Borders: 1px solid #E8E8EC — geen schaduwen
* Logo altijd: `datanex.` (lowercase, punt is #00D4FF)
* 3D wireframe animatie als hero-achtergrond

### ✗ Don't
* Geen gekleurde achtergronden buiten het palet
* Geen gradiënten of box-shadows
* Geen andere fonts dan Space Grotesk + Space Mono
* Geen border-radius groter dan 6px
* Geen emoji's of illustraties
* Logo nooit in hoofdletters

---

## Huidige stand van zaken (bijgewerkt 2026-06-30)

### Wat werkt
- **Homepage** met drie secties: Agent / Compute / Privacy
- **CoinGecko** marktdata: 12/13 projecten (io.net ontbreekt — CoinGecko gratis tier)
- **GitHub commits (30d)**: 9/11 projecten met repo (Render en io.net geen publieke repo)
- **Utility Score** berekend op basis van GitHub activiteit + Volume/MarktCap ratio
- **Cron job** draait elk uur op mijn.host
- **www redirect** via .htaccess → datanex.nl

### Wat nog leeg is (toont —)
- `protocol_revenue`, `active_wallets`, `agent_gdp`, `completed_jobs` (agent_metrics)
- `private_inference_volume`, `tee_nodes`, `zk_transacties` (privacy_metrics)
- `hype_score` (nog geen sociale data bron)

### Volgende stappen (prioriteitsvolgorde)
1. **Projectdetailpagina's** — `/project/[slug]` met uitgebreidere metrics per project
2. **Dune Analytics** koppelen voor on-chain metrics (vereist API-key van de gebruiker)
3. **Hype Score** berekenen (vereist sociale data zoals Twitter/X mentions)
4. **Agent Economy pagina** en **Privacy pagina** als aparte secties
5. **Meer projecten toevoegen** — simpel via INSERT in de projects tabel

---

## Projecten (13 actief)

| Naam | Ticker | Slug | Categorie | CoinGecko ID | GitHub Repo |
|------|--------|------|-----------|--------------|-------------|
| Virtuals Protocol | VIRTUAL | virtuals | agent | virtual-protocol | — |
| Bittensor | TAO | bittensor | agent | bittensor | opentensor/bittensor |
| Fetch.ai | FET | fetch-ai | agent | fetch-ai | fetchai/uagents |
| Ocean Protocol | OCEAN | ocean-protocol | agent | ocean-protocol | oceanprotocol/ocean.py |
| SingularityNET | AGIX | singularitynet | agent | singularitynet | singnet/snet-daemon |
| Render Network | RNDR | render | compute | render-token | — |
| Akash Network | AKT | akash | compute | akash-network | akash-network/node |
| io.net | IO | io-net | compute | io-net | — |
| Nosana | NOS | nosana | compute | nosana | nosana-io/nosana-node |
| NEAR Protocol | NEAR | near | privacy | near | near/nearcore |
| Oasis Network | ROSE | oasis | privacy | oasis-network | oasisprotocol/oasis-core |
| Zcash | ZEC | zcash | privacy | zcash | zcash/zcash |
| Aleph Zero | AZERO | aleph-zero | privacy | aleph-zero | Cardinal-Cryptography/aleph-node |

**Nieuw project toevoegen:**
```sql
INSERT INTO projects (naam, ticker, slug, categorie, beschrijving, website, coingecko_id, github_repo, actief)
VALUES ('Naam', 'TICKER', 'slug', 'agent', 'Omschrijving', 'https://...', 'coingecko-id', 'owner/repo', 1);
```

---

## Data-architectuur

```
CoinGecko API  → fetch-data.php     ─┐
GitHub API     → fetch-github.php   ─┼→ MySQL → get-projects.php → main.js
Berekening     → calculate-scores.php ┘
```

Cron URL (elk uur): `https://datanex.nl/api/cron-update.php?token=datanex_cron_2026`

### Utility Score formule (0–100)
- **GitHub score (0–50):** `min(50, log(commits+1) / log(101) * 50)` — logaritmisch
- **Volume score (0–50):** `min(50, (volume_24h / marktcap) * 500)` — 10% ratio = 50pt

### Database tabellen
| Tabel | Inhoud |
|-------|--------|
| `projects` | Projectinfo: naam, ticker, slug, categorie, coingecko_id, github_repo |
| `project_stats` | Dagelijkse marktdata: prijs, marktcap, volume_24h |
| `agent_metrics` | Protocol revenue, wallets, GDP, jobs (nog leeg) |
| `privacy_metrics` | TEE nodes, ZK-transacties, inference volume (nog leeg) |
| `hype_scores` | Utility score, hype score, github_commits |

### config.php (niet in git — handmatig beheren via FTP)
Bevat: DB_HOST, DB_NAME, DB_USER, DB_PASS, CRON_TOKEN, GITHUB_TOKEN

---

## Externe API's

```
CoinGecko  → https://api.coingecko.com/api/v3/coins/markets
  Gratis tier: 30 calls/minuut — data opgeslagen in MySQL
  Ontbrekend: io.net (io-net) — niet beschikbaar op gratis tier

GitHub     → https://api.github.com/repos/{owner}/{repo}/commits
  Token vereist voor >60 req/uur — GITHUB_TOKEN in config.php op server

Dune Analytics → https://api.dune.com/
  Nog niet gekoppeld — vereist API-key en query-IDs per project
```

---

## Paginastructuur

| Pagina | URL | Status |
|--------|-----|--------|
| Homepage | / | ✅ Live |
| Dashboard | /dashboard | 🔲 Nog te bouwen |
| Agent Economy | /agent-economy | 🔲 Nog te bouwen |
| Privacy | /privacy | 🔲 Nog te bouwen |
| Project detail | /project/[slug] | 🔲 Nog te bouwen |
| Over Datanex | /over | 🔲 Nog te bouwen |

---

## Coderichtlijnen

* Nederlandse comments in de code
* CSS variabelen uit de huisstijl, nooit hardcoded kleuren
* JavaScript: Vanilla JS, geen frameworks
* PHP: PDO voor database verbindingen
* Aparte CSS en JS bestanden — geen inline styles
* Responsive: mobile-first

---

## GitHub workflow

```bash
git add src/bestand.ext
git commit -m "beschrijving van de wijziging"
git push origin main
```

* Branch `main` is productie — elke push deployt automatisch via FTP Action
* `config.php` nooit committen (staat in .gitignore)
* Commit messages in Nederlands of Engels
