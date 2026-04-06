# Pays de la Zone Euro
## Date d'entrée dans la zone et PIB par habitant

```js
{
  const topojson = await import("https://cdn.jsdelivr.net/npm/topojson-client@3/+esm")

  // Parse CSV to extract PIB par habitant
  const csvText = await FileAttachment("data.csv").text()
  const csvLines = csvText.trim().split("\n").map(l => l.split(","))
  const csvCodes = csvLines[0].slice(4) // AUT, BEL, DEU, ...
  const pibRows = csvLines.filter(l => l[2]?.trim() === "PIB par habitant")
  const latestPib = {}
  const codeToId = { AUT: "040", BEL: "056", DEU: "276", ESP: "724", EST: "233", FIN: "246", FRA: "250", GRC: "300", IRL: "372", ITA: "380", LTU: "440", LUX: "442", LVA: "428", NLD: "528", PRT: "620", SVK: "703" }
  for (const row of pibRows) {
    csvCodes.forEach((code, i) => {
      const v = parseFloat(row[4 + i])
      if (!isNaN(v)) latestPib[codeToId[code.trim()]] = Math.round(v * 1000)
    })
  }

  const css = `
  .coins-map { font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; color: #1a1a2e; display: flex; flex-direction: column; align-items: center; }
  .coins-map .map { position: relative; background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,0.08), 0 4px 20px rgba(0,0,0,0.06); }
  .coins-map svg { display: block; }
  .coins-map .country { fill: #f0f0f4; stroke: #d8d8e0; stroke-width: 0.5; transition: fill 0.2s; }
  .coins-map .country.eurozone { stroke: #99a; stroke-width: 0.8; }
  .coins-map .country.eurozone.active { stroke: #446; stroke-width: 1.5; filter: brightness(0.9); }
  .coins-map .coin { position: absolute; border-radius: 50%; border: 3px solid #c9a84c; box-shadow: 0 2px 8px rgba(0,0,0,0.2), 0 0 0 1px rgba(201,168,76,0.15); overflow: hidden; cursor: pointer; transition: transform 0.2s ease, box-shadow 0.2s ease, z-index 0s; z-index: 5; }
  .coins-map .coin:hover { transform: scale(2); box-shadow: 0 6px 24px rgba(201,168,76,0.5), 0 0 0 2px #c9a84c; z-index: 20; }
  .coins-map .coin img { width: 100%; height: 100%; object-fit: cover; display: block; }
  .coins-map .tooltip { position: fixed; background: rgba(20,20,40,0.92); color: #fff; padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 500; pointer-events: none; opacity: 0; transition: opacity 0.15s; z-index: 100; white-space: nowrap; border: 1px solid rgba(201,168,76,0.3); }
  .coins-map .legend { display: flex; align-items: center; gap: 8px; margin-top: 14px; font-size: 11px; color: #666; }
  .coins-map .legend-bar { width: 200px; height: 10px; border-radius: 5px; border: 1px solid #ddd; }
  .coins-map .legend-label { font-weight: 600; color: #444; }
  .coins-map .source { font-size: 11px; color: #999; margin-top: 10px; }
  .coins-map .source a { color: #5566aa; text-decoration: none; }
  .coins-map .source a:hover { text-decoration: underline; }
  `

  const width = 900, height = 700

  const imgBase = "https://www.ecb.europa.eu/euro/coins/common/shared/img/"

  const allCoinData = [
    { id: "040", name: "Autriche",    year: 1999, img: "at/Austria_1Euro.jpg",           lon: 13.3, lat: 47.6 },
    { id: "056", name: "Belgique",    year: 1999, img: "be/Belgium_1999_1euro.gif",      lon: 4.4,  lat: 50.6 },
    { id: "100", name: "Bulgarie",    year: 2025, img: "bg/Bulgaria_1euro.jpg",          lon: 25.5, lat: 42.7 },
    { id: "191", name: "Croatie",     year: 2023, img: "hr/Croatia_1euro.jpg",           lon: 16.0, lat: 45.0 },
    { id: "196", name: "Chypre",      year: 2008, img: "cy/Cyprus_1euro.jpg",            lon: 33.4, lat: 35.1 },
    { id: "233", name: "Estonie",     year: 2011, img: "et/Estonia_1Euro.jpg",           lon: 25.0, lat: 58.6 },
    { id: "246", name: "Finlande",    year: 1999, img: "fi/Finland_1euro.jpg",           lon: 26.0, lat: 64.0 },
    { id: "250", name: "France",      year: 1999, img: "fr/France_1Euro.jpg",            lon: 2.5,  lat: 46.6 },
    { id: "276", name: "Allemagne",   year: 1999, img: "de/Germany_1euro.jpg",           lon: 10.4, lat: 51.2 },
    { id: "300", name: "Grèce",       year: 2001, img: "gr/Greece_1euro.jpg",            lon: 22.0, lat: 39.0 },
    { id: "372", name: "Irlande",     year: 1999, img: "ie/Ireland_1euro.jpg",           lon: -8.0, lat: 53.4 },
    { id: "380", name: "Italie",      year: 1999, img: "it/Italy_1euro.jpg",             lon: 12.0, lat: 43.0 },
    { id: "428", name: "Lettonie",    year: 2014, img: "lv/Latvia_1euro.jpg",            lon: 24.6, lat: 56.9 },
    { id: "440", name: "Lituanie",    year: 2015, img: "lt/Lithuania_1euro_2015.jpg",    lon: 23.9, lat: 55.2 },
    { id: "442", name: "Luxembourg",  year: 1999, img: "lu/Luxembourg_1Euro.jpg",        lon: 6.1,  lat: 49.8 },
    { id: "470", name: "Malte",       year: 2008, img: "mt/Malta_1Euro.jpg",             lon: 14.4, lat: 35.9 },
    { id: "528", name: "Pays-Bas",    year: 1999, img: "nl/Netherlands_1euro_2000.jpg",  lon: 5.3,  lat: 52.3 },
    { id: "620", name: "Portugal",    year: 1999, img: "pt/Portugal_1Euro.jpg",          lon: -8.0, lat: 39.6 },
    { id: "703", name: "Slovaquie",   year: 2009, img: "sk/Slovakia_1Euro.jpg",          lon: 19.5, lat: 48.7 },
    { id: "705", name: "Slovénie",    year: 2007, img: "sl/Slovenia_1Euro.jpg",          lon: 14.8, lat: 46.1 },
    { id: "724", name: "Espagne",     year: 1999, img: "es/Spain_1Euro_1999.jpg",        lon: -3.7, lat: 40.0 },
    { id: "020", name: "Andorre",     year: 2013, img: "ad/Andorra_1euro.jpg",           lon: 1.6,  lat: 42.5, micro: true },
    { id: "492", name: "Monaco",      year: 2002, img: "mo/Monaco_1euro_2001.jpg",       lon: 7.4,  lat: 43.7, micro: true },
    { id: "674", name: "Saint-Marin", year: 2002, img: "sm/SanMarino_1euro_2010.jpg",    lon: 12.5, lat: 43.9, micro: true },
    { id: "336", name: "Vatican",     year: 2002, img: "va/Vatican_1euro_2002.jpg",      lon: 12.3, lat: 41.5, micro: true },
  ]

  // Only keep countries that have PIB data
  const coinData = allCoinData.filter(d => latestPib[d.id] != null).map(d => ({ ...d, pib: latestPib[d.id] }))

  const euroIds = new Set(allCoinData.map(d => d.id))
  const yearById = Object.fromEntries(allCoinData.map(d => [d.id, d.year]))

  // Scale coin size by PIB (sqrt scale: 10k€ → 10px radius, 100k€ → 50px)
  const pibRadiusScale = d3.scaleSqrt().domain([10000, 100000]).range([10, 50])

  const colorScale = d3.scaleSequential(d3.interpolateBlues).domain([2026, 1998])

  const projection = d3.geoMercator().center([15, 54]).scale(600).translate([width / 2, height / 2])
  const path = d3.geoPath(projection)

  const world = await d3.json("https://cdn.jsdelivr.net/npm/world-atlas@2/countries-50m.json")
  const countries = topojson.feature(world, world.objects.countries)

  const root = document.createElement("div")
  root.className = "coins-map"
  const style = document.createElement("style")
  style.textContent = css
  root.appendChild(style)

  const container = document.createElement("div")
  container.className = "map"
  container.style.width = width + "px"
  container.style.height = height + "px"
  container.style.position = "relative"
  root.appendChild(container)

  const svg = d3.select(container).append("svg").attr("width", width).attr("height", height)

  const countryPaths = svg.selectAll("path")
    .data(countries.features)
    .join("path")
    .attr("d", path)
    .attr("class", d => euroIds.has(d.id) ? "country eurozone" : "country")
    .style("fill", d => euroIds.has(d.id) ? colorScale(yearById[d.id]) : null)

  const nodes = coinData.map(d => {
    const [tx, ty] = projection([d.lon, d.lat])
    const r = d.micro ? pibRadiusScale(d.pib) * 0.7 : pibRadiusScale(d.pib)
    return { ...d, x: tx, y: ty, targetX: tx, targetY: ty, r }
  })

  const sim = d3.forceSimulation(nodes)
    .force("x", d3.forceX(d => d.targetX).strength(0.8))
    .force("y", d3.forceY(d => d.targetY).strength(0.8))
    .force("collide", d3.forceCollide(d => d.r + 3).iterations(4))
    .stop()

  for (let i = 0; i < 200; i++) sim.tick()

  const tooltip = document.createElement("div")
  tooltip.className = "tooltip"
  root.appendChild(tooltip)

  nodes.forEach(d => {
    const size = d.r * 2
    const div = document.createElement("div")
    div.className = "coin"
    div.style.width = size + "px"
    div.style.height = size + "px"
    div.style.left = (d.x - d.r) + "px"
    div.style.top = (d.y - d.r) + "px"
    if (d.micro) div.style.borderWidth = "2px"
    div.innerHTML = `<img src="${imgBase}${d.img}" alt="${d.name}">`

    div.addEventListener("mouseenter", () => {
      tooltip.textContent = `${d.name} (${d.year}) — PIB : ${d.pib.toLocaleString("fr-FR")} €/hab.`
      tooltip.style.opacity = "1"
      countryPaths.classed("active", f => f.id === d.id)
    })
    div.addEventListener("mousemove", e => {
      tooltip.style.left = (e.clientX + 14) + "px"
      tooltip.style.top = (e.clientY - 32) + "px"
    })
    div.addEventListener("mouseleave", () => {
      tooltip.style.opacity = "0"
      countryPaths.classed("active", false)
    })

    container.appendChild(div)
  })

  const legend = document.createElement("div")
  legend.className = "legend"
  const years = allCoinData.map(d => d.year)
  const minY = Math.min(...years), maxY = Math.max(...years)
  const gradStops = d3.range(0, 1.01, 0.1).map(t => {
    const y = minY + t * (maxY - minY)
    return `${colorScale(y)} ${(t * 100).toFixed(0)}%`
  }).join(", ")
  legend.innerHTML = `
    <span class="legend-label">Année d'entrée dans l'euro</span>
    <span class="legend-label">${minY}</span>
    <div class="legend-bar" style="background: linear-gradient(to right, ${gradStops})"></div>
    <span class="legend-label">${maxY}</span>
  `
  root.appendChild(legend)

  // Size legend (PIB par habitant)
  const sizeLegend = document.createElement("div")
  sizeLegend.className = "legend"
  const sizeSamples = [20000, 40000, 60000]
  sizeLegend.innerHTML = `<span class="legend-label">PIB / habitant</span>` + sizeSamples.map(v => {
    const r = pibRadiusScale(v)
    const d = Math.round(r * 2)
    return `<span style="display:inline-flex;align-items:center;gap:4px;"><span style="width:${d}px;height:${d}px;border-radius:50%;border:2px solid #c9a84c;background:#f5f0e0;flex-shrink:0;"></span><span style="font-size:11px;color:#666;">${(v/1000).toFixed(0)}k€</span></span>`
  }).join('')
  root.appendChild(sizeLegend)

  root.insertAdjacentHTML("beforeend", `<div class="source">Source : <a target="_blank" href="https://www.ecb.europa.eu/euro/coins/1euro/html/index.en.html">Banque Centrale Européenne</a></div>`)

  return root
}
```

# Panorama de la Zone Euro
## 16 indicateurs normalisés comparant éducation, finances publiques et démographie — survolez un drapeau pour les détails

```js
{
  const css = `
  * { margin: 0; padding: 0; box-sizing: border-box; }
  .hz { font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; color: #1a1a2e; }
  .hz h1 { font-size: 28px; font-weight: 800; letter-spacing: -0.5px; margin: 0 0 6px; }
  .hz h2 { font-size: 14px; font-weight: 400; color: #7a7a8e; line-height: 1.5; margin: 0 0 32px; }
  .hz .chart { position: relative; background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.06), 0 4px 16px rgba(0,0,0,0.04); overflow: hidden; isolation: isolate; }
  .hz .row { display: flex; align-items: center; height: 50px; position: relative; transition: background 0.15s, box-shadow 0.15s; }
  .hz .row:nth-child(even) { background: #f8f9fb; }
  .hz .row:hover { background: #eef1f8; }
  .hz .row:hover .dot { opacity: 0.3; }
  .hz .row:hover .dot:hover { opacity: 1; }
  .hz .row.highlighted { background: #eef1f8; box-shadow: inset 4px 0 0 var(--hl-color, #44b); }
  .hz .category-row { height: 28px; background: #f0f1f6; border-top: 2px solid #d8dae5; }
  .hz .category-row:hover { background: #f0f1f6; }
  .hz .category-label { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 1.5px; color: #7a7a8e; padding-left: 20px; line-height: 28px; }
  .hz .label { width: 210px; min-width: 210px; font-size: 13px; font-weight: 500; text-align: right; padding-right: 20px; color: #3a3a4e; white-space: nowrap; }
  .hz .track { flex: 1; position: relative; height: 50px; border-left: 1px solid #e8e8ee; padding: 0 18px; }
  .hz .track-inner { position: relative; width: calc(100% - 20px); height: 100%; }
  .hz .track::before { content: ''; position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 56px) * 0.25); width: 1px; background: #ecedf2; pointer-events: none; }
  .hz .track::after { content: ''; position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 56px) * 0.50); width: 1px; background: #e4e5ec; pointer-events: none; }
  .hz .grid-75 { position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 56px) * 0.75); width: 1px; background: #ecedf2; pointer-events: none; }
  .hz .grid-100 { position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 36px)); width: 1px; background: #ecedf2; pointer-events: none; }
  .hz .rank { width: 28px; min-width: 28px; font-size: 20px; font-weight: 600; text-align: center; color: #7a7a8e; opacity: 0; transition: opacity 0.15s; display: flex; align-items: center; justify-content: center; padding: 0; }
  .hz .chart.has-highlight .rank { opacity: 1; }
  .hz .value { width: 100px; min-width: 100px; font-size: 11px; color: #3a3a4e; opacity: 0; transition: opacity 0.15s; white-space: nowrap; display: flex; align-items: center; justify-content: flex-end; gap: 4px; padding-right: 8px; }
  .hz .value .num { min-width: 50px; text-align: right; font-variant-numeric: tabular-nums; }
  .hz .value .unit { min-width: 30px; text-align: left; color: #999; }
  .hz .chart.has-highlight .value { opacity: 1; }
  .hz .chart-header .value { opacity: 1; font-weight: 600; color: #aaa; border-left: none; }
  .hz .sparkline { width: 80px; min-width: 80px; height: 50px; display: flex; align-items: center; justify-content: center; border-left: 1px solid #e8e8ee; padding: 8px 6px; }
  .hz .dot { position: absolute; width: 30px; height: 20px; border-radius: 3px; transform: translate(-50%, -50%); top: 50%; font-size: 17px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: opacity 0.15s, transform 0.15s, box-shadow 0.15s; border: 1.5px solid rgba(0,0,0,0.08); background: #fff; z-index: 3; user-select: none; overflow: hidden; }
  .hz .dot img { width: 100%; height: 100%; object-fit: cover; pointer-events: none; }
  .hz .dot.fallback { border-style: dashed; }
  .hz .dot:hover, .hz .dot.highlight { transform: translate(-50%, -50%) scale(1.25); box-shadow: 0 3px 12px rgba(0,0,0,0.18); z-index: 10; opacity: 1 !important; filter: none; }
  .hz .chart-header { display: flex; align-items: center; height: 38px; background: #f4f5f9; border-bottom: 1px solid #e8e8ee; }
  .hz .chart-header:hover { background: #f4f5f9; }
  .hz .chart-header .label { width: 210px; min-width: 210px; }
  .hz .chart-header .spacer { flex: 1; border-left: 1px solid #e8e8ee; }
  .hz .chart-header .rank { opacity: 1; border: none; font-size: 11px; color: #aaa; line-height: normal; display: flex; align-items: center; justify-content: center; }
  .hz .chart-header-info { display: flex; align-items: center; border-left: 1px solid #e8e8ee; }
  .hz .chart-header-info .col-label { width: 80px; min-width: 80px; text-align: center; font-size: 12px; font-weight: 600; color: #3a3a4e; white-space: nowrap; padding: 0 6px; border-left: 1px solid #e8e8ee; }
  .hz .chart-header-info .col-label:first-child { border-left: none; }
  .hz .chart-header-info .col-label.muted { font-weight: 400; color: #aaa; }
  .hz .source { font-size: 11px; color: #b0b0b8; margin-top: 12px; }
  `

  // === Data ===
  const countries = [
    { code: "AUT", cc: "at", name: "Autriche" },
    { code: "BEL", cc: "be", name: "Belgique" },
    { code: "DEU", cc: "de", name: "Allemagne" },
    { code: "ESP", cc: "es", name: "Espagne" },
    { code: "EST", cc: "ee", name: "Estonie" },
    { code: "FIN", cc: "fi", name: "Finlande" },
    { code: "FRA", cc: "fr", name: "France" },
    { code: "GRC", cc: "gr", name: "Grèce" },
    { code: "IRL", cc: "ie", name: "Irlande" },
    { code: "ITA", cc: "it", name: "Italie" },
    { code: "LTU", cc: "lt", name: "Lituanie" },
    { code: "LUX", cc: "lu", name: "Luxembourg" },
    { code: "LVA", cc: "lv", name: "Lettonie" },
    { code: "NLD", cc: "nl", name: "Pays-Bas" },
    { code: "PRT", cc: "pt", name: "Portugal" },
    { code: "SVK", cc: "sk", name: "Rép. Slovaque" },
    { code: "EU", cc: "eu", name: "Moy. UE" },
  ]

  const colors = {
    AUT: "#d44", BEL: "#222", DEU: "#e8a", ESP: "#f80", EST: "#48c", FIN: "#69c",
    FRA: "#44b", GRC: "#6b6", IRL: "#3a3", ITA: "#c44", LTU: "#b93", LUX: "#59c",
    LVA: "#933", NLD: "#e60", PRT: "#494", SVK: "#b4b", EU: "#039",
  }

  function parseCSV(text) {
    const lines = text.trim().split("\n").map(l => l.split(","))
    if (lines.length < 2) return null
    const countryCodes = lines[0].slice(5) // skip Année,Catégorie,Variable,Unité,Inverse
    const raw = {}, labels = [], categories = {}, units = {}, inverse = {}
    for (let i = 1; i < lines.length; i++) {
      const year = parseInt(lines[i][0])
      const cat = (lines[i][1] || "").trim()
      const label = (lines[i][2] || "").trim()
      const unit = (lines[i][3] || "").trim()
      const inv = (lines[i][4] || "").trim() === "1"
      if (!label || isNaN(year)) continue
      const values = lines[i].slice(5).map(v => { const n = parseFloat(v); return isNaN(n) ? null : n })
      if (!raw[label]) { raw[label] = {}; labels.push(label); categories[label] = cat; units[label] = unit; inverse[label] = inv }
      raw[label][year] = values
    }
    // Compute EU average and append as last column
    for (const label of labels) {
      for (const [year, values] of Object.entries(raw[label])) {
        const nonNull = values.filter(v => v != null)
        raw[label][year] = [...values, nonNull.length ? nonNull.reduce((a, b) => a + b, 0) / nonNull.length : null]
      }
    }
    const dataMap = {}
    for (const label of labels) {
      const all = Object.values(raw[label]).flat().filter(v => v != null)
      const min = Math.min(...all), max = Math.max(...all)
      const range = max - min || 1
      const inv = inverse[label]
      dataMap[label] = {}
      for (const [year, values] of Object.entries(raw[label])) {
        dataMap[label][year] = values.map(v => v == null ? null : inv ? +(1 - (v - min) / range).toFixed(3) : +((v - min) / range).toFixed(3))
      }
    }
    return { countryCodes, dataMap, rawMap: raw, labels, categories, units, inverse }
  }

  const csvText = await FileAttachment("data.csv").text()
  const data = parseCSV(csvText)
  const { dataMap, labels, categories, units, rawMap, inverse } = data

  // Global year range for consistent sparklines
  const allYears = [...new Set(labels.flatMap(l => Object.keys(rawMap[l]).map(Number)))].sort((a, b) => a - b)

  function getLatestValues(label) {
    const raw = getRawLatestValues(label)
    const inv = inverse[label]
    const nonNull = raw.filter(v => v != null)
    if (!nonNull.length) return raw.map(() => null)
    const min = Math.min(...nonNull), max = Math.max(...nonNull)
    const range = max - min || 1
    return raw.map(v => v == null ? null : inv ? +(1 - (v - min) / range).toFixed(3) : +((v - min) / range).toFixed(3))
  }

  function getLatestFallbackFlags(label) {
    const entry = dataMap[label]
    if (!entry) return []
    const years = Object.keys(entry).map(Number).sort()
    if (!years.length) return []
    const last = entry[years[years.length - 1]]
    return last.map((v, ci) => v == null)
  }

  function getRawLatestValues(label) {
    const entry = rawMap[label]
    if (!entry) return []
    const years = Object.keys(entry).map(Number).sort()
    if (!years.length) return []
    const last = entry[years[years.length - 1]]
    return last.map((v, ci) => {
      if (v != null) return v
      for (let yi = years.length - 2; yi >= 0; yi--) {
        const prev = entry[years[yi]][ci]
        if (prev != null) return prev
      }
      return null
    })
  }

  function formatValue(v, unit) {
    if (v == null) return "–"
    if ((unit === "%" || unit === "% PIB") && Math.abs(v) < 1) v = v * 100
    const abs = Math.abs(v)
    let str
    if (abs >= 10000) str = Math.round(v).toLocaleString("fr-FR")
    else if (abs >= 100) str = v.toFixed(1)
    else if (abs >= 1) str = v.toFixed(1)
    else if (abs >= 0.01) str = v.toFixed(2)
    else if (abs > 0) {
      const e = v.toExponential(1)
      const [coef, exp] = e.split('e')
      str = `${coef}×10<sup>${exp.replace('+', '')}</sup>`
    }
    else str = "0"
    return `<span class="num">${str}</span><span class="unit">${unit}</span>`
  }

  function getYearSeries(label, ci) {
    const entry = dataMap[label]
    if (!entry) return allYears.map(y => ({ year: y, value: null }))
    return allYears.map(y => ({ year: y, value: entry[y]?.[ci] ?? null }))
  }

  // === Viz helpers ===
  const svgNS = "http://www.w3.org/2000/svg"

  function trendDir(series) {
    const vals = series.filter(s => s.value != null).map(s => s.value)
    if (vals.length < 2) return "flat"
    const half = Math.max(1, Math.floor(vals.length / 2))
    const first = vals.slice(0, half).reduce((a, b) => a + b, 0) / half
    const last = vals.slice(-half).reduce((a, b) => a + b, 0) / half
    if (last - first > 0.03) return "up"
    if (last - first < -0.03) return "down"
    return "flat"
  }

  function waterfallSVG(series) {
    const w = 68, h = 30, mid = h / 2
    const vals = series.map(s => s.value)
    if (!vals.some(v => v != null) || vals.filter(v => v != null).length < 2) {
      return `<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}"><line x1="4" y1="${mid}" x2="${w - 4}" y2="${mid}" stroke="#e0e0e4" stroke-width="1" stroke-dasharray="3,2"/></svg>`
    }
    const n = vals.length
    const gap = 2
    const barW = Math.max(3, (w - 8 - (n - 1) * gap) / n)
    const deltas = vals.map((v, i) => {
      if (i === 0 || v == null) return null
      for (let j = i - 1; j >= 0; j--) { if (vals[j] != null) return v - vals[j] }
      return null
    })
    const maxD = Math.max(0.02, ...deltas.filter(d => d != null).map(d => Math.abs(d)))
    let svg = `<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">`
    svg += `<line x1="2" y1="${mid}" x2="${w - 2}" y2="${mid}" stroke="#ecedf2" stroke-width="0.5"/>`
    vals.forEach((v, i) => {
      const x = 4 + i * (barW + gap)
      if (v == null) {
        svg += `<rect x="${x}" y="${mid - 1}" width="${barW}" height="2" rx="0.5" fill="#e0e0e4" opacity="0.6"/>`
      } else if (deltas[i] == null) {
        svg += `<circle cx="${x + barW / 2}" cy="${mid}" r="1.5" fill="#bbb"/>`
      } else {
        const d = deltas[i]
        const barH = Math.max(2, Math.abs(d) / maxD * (mid - 3))
        const color = d >= 0 ? "#22a06b" : "#cf3b3b"
        const y = d >= 0 ? mid - barH : mid
        svg += `<rect x="${x}" y="${y}" width="${barW}" height="${barH}" rx="1" fill="${color}"/>`
      }
    })
    svg += `</svg>`
    return svg
  }

  // === Build ===
  const root = document.createElement("div")
  root.className = "hz"
  const style = document.createElement("style")
  style.textContent = css
  root.appendChild(style)

  const chart = document.createElement("div")
  chart.className = "chart"
  root.appendChild(chart)

  let _dots = [], _linesSvg = null, highlightedCountry = null

  // Header
  const hdr = document.createElement("div")
  hdr.className = "row chart-header"
  hdr.innerHTML = `<div class="label"></div><div class="spacer"></div><div class="rank">Rang</div><div class="value">Valeur</div><div class="chart-header-info" id="chart-header-info"><div class="col-label muted"></div></div>`
  chart.appendChild(hdr)

  // Rows
  let lastCat = null
  labels.forEach((label, ri) => {
    const cat = categories[label]
    if (cat !== lastCat) {
      const sep = document.createElement("div")
      sep.className = "row category-row"
      sep.innerHTML = `<div class="category-label">${cat}</div>`
      chart.appendChild(sep)
      lastCat = cat
    }
    const values = getLatestValues(label)
    const fallbackFlags = getLatestFallbackFlags(label)
    const row = document.createElement("div")
    row.className = "row"
    const inv = inverse[label] ? ' <span style="color:#cf3b3b;font-size:10px" title="Inversé : moins = mieux">◄</span>' : ''
    row.innerHTML = `<div class="label">${label}${inv}</div><div class="track"><div class="track-inner"></div><div class="grid-75"></div><div class="grid-100"></div></div><div class="rank" data-row="${ri}"></div><div class="value" data-row="${ri}"></div><div class="sparkline" data-row="${ri}"></div>`
    chart.appendChild(row)

    const trackInner = row.querySelector(".track-inner")
    values.forEach((v, ci) => {
      if (v == null) return
      const c = countries[ci]
      if (!c) return
      const series = getYearSeries(label, ci)
      const isFallback = fallbackFlags[ci]
      const dot = document.createElement("div")
      dot.className = `dot trend-${trendDir(series)}${isFallback ? ' fallback' : ''}`
      dot.dataset.code = c.code
      dot.style.left = (v * 100) + "%"
      dot.innerHTML = `<img src="https://flagcdn.com/w40/${c.cc}.png" alt="${c.name}">`
      dot.addEventListener("mouseenter", () => setHighlight(c.code))
      dot.addEventListener("mouseleave", () => setHighlight(null))
      trackInner.appendChild(dot)
      _dots.push({ el: dot, code: c.code, row: ri, x: v, ci })
    })
  })

  // SVG overlay
  _linesSvg = document.createElementNS(svgNS, "svg")
  _linesSvg.style.cssText = "position:absolute;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:2;"
  chart.appendChild(_linesSvg)

  function drawLines() {
    if (!_linesSvg) return
    _linesSvg.innerHTML = ""
    const r = chart.getBoundingClientRect()
    _linesSvg.setAttribute("viewBox", `0 0 ${r.width} ${r.height}`)
    _linesSvg.setAttribute("width", r.width)
    _linesSvg.setAttribute("height", r.height)
    countries.forEach(c => {
      if (c.code === "EU") return
      const cd = _dots.filter(d => d.code === c.code).sort((a, b) => a.row - b.row)
      if (cd.length < 2) return
      for (let i = 0; i < cd.length - 1; i++) {
        const r1 = cd[i].el.getBoundingClientRect()
        const r2 = cd[i + 1].el.getBoundingClientRect()
        const line = document.createElementNS(svgNS, "line")
        line.setAttribute("x1", r1.left + r1.width / 2 - r.left)
        line.setAttribute("y1", r1.top + r1.height / 2 - r.top)
        line.setAttribute("x2", r2.left + r2.width / 2 - r.left)
        line.setAttribute("y2", r2.top + r2.height / 2 - r.top)
        line.setAttribute("stroke", colors[c.code])
        line.setAttribute("stroke-width", highlightedCountry === c.code ? "2" : "1")
        line.setAttribute("stroke-dasharray", "3,3")
        line.setAttribute("opacity", highlightedCountry === c.code ? "0.7" : highlightedCountry ? "0.03" : "0.12")
        line.dataset.code = c.code
        _linesSvg.appendChild(line)
      }
    })
  }

  function scheduleDrawLines() { requestAnimationFrame(() => requestAnimationFrame(drawLines)) }

  function setHighlight(code) {
    highlightedCountry = code
    chart.classList.add("has-highlight")
    _dots.forEach(d => {
      d.el.classList.toggle("highlight", code === d.code)
      d.el.style.opacity = code && code !== d.code ? "0.2" : "1"
      const row = d.el.closest(".row")
      if (code === d.code) {
        row.classList.add("highlighted")
        row.style.setProperty("--hl-color", colors[code])
      } else {
        row.classList.remove("highlighted")
      }
    })
    if (_linesSvg) _linesSvg.querySelectorAll("line").forEach(l => {
      l.setAttribute("opacity", code === l.dataset.code ? "0.7" : code ? "0.03" : "0.12")
      l.setAttribute("stroke-width", code === l.dataset.code ? "2" : "1")
    })
    const activeCode = code || "EU"
    const activeCi = countries.findIndex(c => c.code === activeCode)
    const medals = ['🥇', '🥈', '🥉']
    chart.querySelectorAll(".rank[data-row]").forEach(el => {
      const ri = +el.dataset.row
      const values = getLatestValues(labels[ri])
      const sorted = values.map((v, i) => ({ v, i })).filter(s => s.v != null).sort((a, b) => b.v - a.v)
      const rank = sorted.findIndex(s => s.i === activeCi) + 1
      el.innerHTML = rank > 0 ? (rank <= 3 ? medals[rank - 1] : `<span style="font-size:11px">${rank}<sup>e</sup></span>`) : "–"
    })
    chart.querySelectorAll(".value[data-row]").forEach(el => {
      const ri = +el.dataset.row
      const raw = getRawLatestValues(labels[ri])
      const v = raw[activeCi]
      el.innerHTML = formatValue(v, units[labels[ri]])
    })
    chart.querySelectorAll(".sparkline[data-row]").forEach(el => {
      const ri = +el.dataset.row
      el.innerHTML = waterfallSVG(getYearSeries(labels[ri], activeCi))
    })
    const info = chart.querySelector(".chart-header-info")
    if (!info) return
    const activeC = countries.find(c => c.code === activeCode)
    info.innerHTML = `<div class="col-label${!code ? ' muted' : ''}">${activeC.name}</div>`
  }

  setHighlight(null)
  scheduleDrawLines()
  chart.querySelectorAll(".dot img").forEach(img => img.addEventListener("load", scheduleDrawLines, { once: true }))
  window.addEventListener("resize", drawLines)

  root.insertAdjacentHTML("beforeend", `<div class="source">Sources : Eurostat, Mankieur 2026</div>`)

  return root
}
```
