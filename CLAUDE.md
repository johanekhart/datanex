# Datanex — Project Instructies voor Claude Code

## Over het project
Datanex.nl is een data-dashboard dat inzicht geeft in AI crypto projecten.
De focus ligt op twee categorieën:
- **AI Agent projecten** — protocol revenue, active wallets, agent GDP, jobs completed
- **AI Privacy projecten** — private inference volume, TEE nodes, ZK-proof transacties

Het doel: hype van echte utiliteit scheiden met verifieerbare on-chain statistieken.

---

## Technische stack

| Laag       | Technologie         |
|------------|---------------------|
| Frontend   | HTML5, CSS3, Vanilla JavaScript |
| Backend    | PHP 8+              |
| Database   | MySQL / MariaDB     |
| Beheer DB  | phpMyAdmin          |
| Hosting    | mijn.host           |
| Domein     | datanex.nl          |
| Versiebeheer | GitHub            |

---

## Bestandsstructuur

```
datanex/
├── CLAUDE.md                  ← dit bestand (projectinstructies)
├── brand/
│   └── datanex-brand-identity.html  ← volledige huisstijl referentie
├── public/
│   └── favicon.svg            ← favicon: kleine d + cyaan stip
└── src/
    ├── index.html             ← homepage / dashboard
    ├── css/
    │   └── style.css          ← alle stijlen
    ├── js/
    │   └── main.js            ← frontend JavaScript
    ├── api/
    │   ├── fetch-data.php     ← haalt data op van externe crypto API's
    │   ├── get-projects.php   ← levert projectdata aan de frontend
    │   └── cron-update.php    ← wordt periodiek aangeroepen om data te vernieuwen
    └── db/
        └── schema.sql         ← database structuur
```

- Schrijf **alle** websitebestanden in `/src/`
- Schrijf **nooit** bestanden naar de root of naar `/brand/`
- Houd `/brand/datanex-brand-identity.html` als read-only referentie

---

## Huisstijl

Raadpleeg altijd `/brand/datanex-brand-identity.html` voor de volledige huisstijl.
Hieronder een samenvatting voor snelle referentie.

### Kleuren (CSS variabelen)
```css
:root {
  --white:      #FFFFFF;   /* primaire achtergrond */
  --off-white:  #F7F7F8;   /* sectie / card achtergrond */
  --light-gray: #E8E8EC;   /* borders / dividers */
  --mid-gray:   #9999AA;   /* labels / metadata */
  --dark-gray:  #333344;   /* body tekst */
  --black:      #0A0A0F;   /* headlines / primary tekst */
  --cyan:       #00D4FF;   /* enige accentkleur */
  --cyan-dim:   rgba(0, 212, 255, 0.10);
  --cyan-mid:   rgba(0, 212, 255, 0.35);
}
```

### Typografie
```html
<!-- Altijd deze Google Fonts import gebruiken -->
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@300;400;500;600;700&family=Space+Mono:wght@400;700&display=swap" rel="stylesheet">
```

| Rol             | Font           | Gewicht | Grootte      | Letter-spacing |
|-----------------|----------------|---------|--------------|----------------|
| Hero headline   | Space Grotesk  | 700     | 48–56px      | -0.04em        |
| Section heading | Space Grotesk  | 700     | 28–32px      | -0.03em        |
| Card title      | Space Grotesk  | 600     | 18–20px      | -0.02em        |
| Body tekst      | Space Grotesk  | 400     | 14–15px      | normaal        |
| Data waarden    | Space Grotesk  | 700     | 24–36px      | -0.05em        |
| Labels / meta   | Space Mono     | 400     | 10–11px      | 0.15em UC      |

### Logo
```html
<!-- Altijd exact zo implementeren — lowercase, punt is cyan -->
<span style="font-family:'Space Grotesk',sans-serif; font-weight:700;
  font-size:18px; letter-spacing:-0.04em; color:#0A0A0F;">
  datanex<span style="color:#00D4FF;">.</span>
</span>
```

### Favicon
```html
<!-- In de <head> van elke pagina -->
<link rel="icon" type="image/svg+xml" href="/public/favicon.svg">
```

```svg
<!-- /public/favicon.svg -->
<svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg">
  <text x="1" y="26" font-family="'Space Grotesk', sans-serif"
    font-weight="700" font-size="26" fill="#0A0A0F">d</text>
  <circle cx="27" cy="7" r="4.5" fill="#00D4FF"/>
</svg>
```

### Spacing & borders
| Element            | Waarde                    |
|--------------------|---------------------------|
| Page padding       | 48px zijkanten            |
| Section padding    | 56px boven/onder          |
| Card padding       | 20–24px                   |
| Border-radius card | 6px max                   |
| Border-radius btn  | 4px                       |
| Dividers           | 1px solid #E8E8EC         |
| Max content width  | 1280px                    |
| Card grid gap      | 20px                      |

---

## Do's & Don'ts

### ✓ Do
- Witte achtergrond (#FFFFFF) als basis voor alle pagina's
- Cyan (#00D4FF) alleen als accent — nooit als achtergrond
- Space Mono voor alle labels, data-waarden en metadata
- Getallen groot en bold met negatieve letter-spacing
- Borders: 1px solid #E8E8EC — geen schaduwen
- Logo altijd: `datanex.` (lowercase, punt is #00D4FF)
- Favicon altijd: kleine d + cyaan stip rechtsboven
- 3D wireframe animatie gebruiken als hero-achtergrond (zie brand bestand)

### ✗ Don't
- Geen gekleurde achtergronden buiten het palet
- Geen gradiënten
- Geen andere lettertypes dan Space Grotesk + Space Mono
- Geen border-radius groter dan 6px
- Geen box-shadow — alleen borders
- Geen emoji's of illustraties
- Cyan nooit op grote vlakken of als achtergrond
- Logo nooit in hoofdletters (DATANEX.) schrijven

---

## Data & API's

### Externe API's voor crypto data
```
CoinGecko API  → https://api.coingecko.com/api/v3/
  Gebruik voor: prijzen, marktcap, volume, historische data
  Gratis tier:  30 calls/minuut — sla data op in MySQL om limiet te respecteren

CoinMarketCap  → https://pro-api.coinmarketcap.com/
  Gebruik voor: aanvullende marktdata

Dune Analytics → https://api.dune.com/
  Gebruik voor: on-chain statistieken, wallet data, protocol revenue
```

### Datacategorieën om bij te houden

**AI Agent projecten**
- Protocol revenue (maandelijks)
- Active wallets (dagelijks)
- Agent GDP / aGDP
- Completed agent jobs
- Agent-to-agent transactievolume
- Subnet groei (Bittensor)

**AI Privacy projecten**
- Private inference volume
- TEE node count
- ZK-proof transacties
- Confidential compute nodes
- Data marketplace volume

**Algemeen per project**
- Marktcap, prijs, 24h volume
- GitHub commits (activiteit)
- Hype vs Utility score (eigen berekening)
- Categorie: Agent / Privacy / Compute / Data Layer

### PHP data-architectuur
```
crypto API → fetch-data.php → MySQL → get-projects.php → frontend JS
```

- `fetch-data.php` — haalt ruwe data op van externe API's
- `cron-update.php` — draait periodiek (elk uur via cron job op mijn.host)
- `get-projects.php` — levert JSON aan de frontend
- Frontend JS — haalt data op via fetch() en rendert het

### Database richtlijnen
- Gebruik MySQL / MariaDB
- Maak een `schema.sql` aan in `/src/db/` met alle CREATE TABLE statements
- Sla API-responses op zodat je niet elke pageload de API aanroept
- Houd een `updated_at` timestamp bij op elke tabel

---

## Paginastructuur (te bouwen)

| Pagina           | URL                  | Beschrijving                              |
|------------------|----------------------|-------------------------------------------|
| Homepage         | /                    | Hero + sector overzicht + key stats       |
| Dashboard        | /dashboard           | Volledig overzicht alle projecten         |
| Agent Economy    | /agent-economy       | AI Agent projecten + agent GDP tracker    |
| Privacy          | /privacy             | AI Privacy projecten + metrics            |
| Project detail   | /project/[naam]      | Detailpagina per project                  |
| Over Datanex     | /over                | Uitleg methodologie + data bronnen        |

---

## Coderichtlijnen

- Schrijf schone, goed gedocumenteerde code met Nederlandse comments
- Gebruik CSS variabelen uit de huisstijl, nooit hardcoded kleuren
- JavaScript: Vanilla JS, geen frameworks
- PHP: gebruik PDO voor database verbindingen (veilig tegen SQL injection)
- Maak aparte CSS en JS bestanden — geen inline styles behalve voor uitzonderingen
- Responsive: mobile-first, werkt op alle schermformaten
- Laad externe fonts en scripts asynchroon waar mogelijk

---

## GitHub workflow

```bash
# Wijzigingen opslaan
git add .
git commit -m "beschrijving van de wijziging"
git push origin main
```

- Branch: `main` is de productie branch
- Commit messages in het Nederlands of Engels, altijd beschrijvend
- Push naar GitHub na elke betekenisvolle wijziging
