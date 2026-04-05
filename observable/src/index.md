---
toc: false
---

```js
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
.hz .track-inner { position: relative; width: 100%; height: 100%; }
.hz .track::before { content: ''; position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 36px) * 0.25); width: 1px; background: #ecedf2; pointer-events: none; }
.hz .track::after { content: ''; position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 36px) * 0.50); width: 1px; background: #e4e5ec; pointer-events: none; }
.hz .grid-75 { position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 36px) * 0.75); width: 1px; background: #ecedf2; pointer-events: none; }
.hz .grid-100 { position: absolute; top: 0; bottom: 0; left: calc(18px + (100% - 36px)); width: 1px; background: #ecedf2; pointer-events: none; }
.hz .rank { width: 40px; min-width: 40px; font-size: 20px; font-weight: 600; text-align: center; color: #7a7a8e; opacity: 0; transition: opacity 0.15s; border-left: 1px solid #e8e8ee; line-height: 1; }
.hz .chart.has-highlight .rank { opacity: 1; }
.hz .value { width: 80px; min-width: 80px; font-size: 11px; text-align: center; color: #3a3a4e; opacity: 0; transition: opacity 0.15s; border-left: 1px solid #e8e8ee; white-space: nowrap; }
.hz .chart.has-highlight .value { opacity: 1; }
.hz .chart-header .value { opacity: 1; font-weight: 600; color: #aaa; border-left: none; }
.hz .sparkline { width: 80px; min-width: 80px; height: 50px; display: flex; align-items: center; justify-content: center; border-left: 1px solid #e8e8ee; padding: 8px 6px; }
.hz .dot { position: absolute; width: 30px; height: 20px; border-radius: 3px; transform: translate(-50%, -50%); top: 50%; font-size: 17px; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: opacity 0.15s, transform 0.15s, box-shadow 0.15s; border: 1.5px solid rgba(0,0,0,0.08); background: #fff; z-index: 3; user-select: none; overflow: hidden; }
.hz .dot img { width: 100%; height: 100%; object-fit: cover; pointer-events: none; }
.hz .dot:hover, .hz .dot.highlight { transform: translate(-50%, -50%) scale(1.25); box-shadow: 0 3px 12px rgba(0,0,0,0.18); z-index: 10; opacity: 1 !important; }
.hz .chart-header { display: flex; align-items: center; height: 38px; background: #f4f5f9; border-bottom: 1px solid #e8e8ee; }
.hz .chart-header:hover { background: #f4f5f9; }
.hz .chart-header .label { width: 210px; min-width: 210px; }
.hz .chart-header .spacer { flex: 1; border-left: 1px solid #e8e8ee; }
.hz .chart-header .rank { opacity: 1; border: none; font-size: 11px; color: #aaa; line-height: normal; }
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
]

const colors = {
  AUT: "#d44", BEL: "#222", DEU: "#e8a", ESP: "#f80", EST: "#48c", FIN: "#69c",
  FRA: "#44b", GRC: "#6b6", IRL: "#3a3", ITA: "#c44", LTU: "#b93", LUX: "#59c",
  LVA: "#933", NLD: "#e60", PRT: "#494", SVK: "#b4b",
}

function parseCSV(text) {
  const lines = text.trim().split("\n").map(l => l.split(","))
  if (lines.length < 2) return null
  const countryCodes = lines[0].slice(4)
  const raw = {}, labels = [], categories = {}, units = {}
  for (let i = 1; i < lines.length; i++) {
    const year = parseInt(lines[i][0])
    const cat = (lines[i][1] || "").trim()
    const label = (lines[i][2] || "").trim()
    const unit = (lines[i][3] || "").trim()
    if (!label || isNaN(year)) continue
    const values = lines[i].slice(4).map(v => { const n = parseFloat(v); return isNaN(n) ? null : n })
    if (!raw[label]) { raw[label] = {}; labels.push(label); categories[label] = cat; units[label] = unit }
    raw[label][year] = values
  }
  const dataMap = {}
  for (const label of labels) {
    const all = Object.values(raw[label]).flat().filter(v => v != null)
    const min = Math.min(...all), max = Math.max(...all)
    const range = max - min || 1
    dataMap[label] = {}
    for (const [year, values] of Object.entries(raw[label])) {
      dataMap[label][year] = values.map(v => v == null ? null : +((v - min) / range).toFixed(3))
    }
  }
  return { countryCodes, dataMap, rawMap: raw, labels, categories, units }
}

const csvText = await FileAttachment("data.csv").text()
const data = parseCSV(csvText)
const { dataMap, labels, categories, units, rawMap } = data

function getLatestValues(label) {
  const entry = dataMap[label]
  if (!entry) return []
  const years = Object.keys(entry).map(Number).sort()
  return years.length ? entry[years[years.length - 1]] : []
}

function getRawLatestValues(label) {
  const entry = rawMap[label]
  if (!entry) return []
  const years = Object.keys(entry).map(Number).sort()
  return years.length ? entry[years[years.length - 1]] : []
}

function getYearSeries(label, ci) {
  const entry = dataMap[label]
  if (!entry) return []
  return Object.keys(entry).map(Number).sort().map(y => ({ year: y, value: entry[y][ci] ?? null }))
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
      svg += `<rect x="${x}" y="${y}" width="${barW}" height="${barH}" rx="1" fill="${color}" opacity="0.85"/>`
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

root.insertAdjacentHTML("beforeend", `
  <h1>Panorama de la Zone Euro</h1>
  <h2>16 indicateurs normalisés comparant éducation, finances publiques et démographie — survolez un drapeau pour les détails</h2>
`)

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
  const row = document.createElement("div")
  row.className = "row"
  row.innerHTML = `<div class="label">${label}</div><div class="track"><div class="track-inner"></div><div class="grid-75"></div><div class="grid-100"></div></div><div class="rank" data-row="${ri}"></div><div class="value" data-row="${ri}"></div><div class="sparkline" data-row="${ri}"></div>`
  chart.appendChild(row)

  const trackInner = row.querySelector(".track-inner")
  values.forEach((v, ci) => {
    if (v == null) return
    const c = countries[ci]
    if (!c) return
    const series = getYearSeries(label, ci)
    const dot = document.createElement("div")
    dot.className = `dot trend-${trendDir(series)}`
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
  chart.classList.toggle("has-highlight", !!code)
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
  const medals = ['🥇', '🥈', '🥉']
  chart.querySelectorAll(".rank[data-row]").forEach(el => {
    const ri = +el.dataset.row
    if (!code) { el.textContent = ""; return }
    const ci = countries.findIndex(c => c.code === code)
    const values = getLatestValues(labels[ri])
    const sorted = values.map((v, i) => ({ v, i })).filter(s => s.v != null).sort((a, b) => b.v - a.v)
    const rank = sorted.findIndex(s => s.i === ci) + 1
    el.innerHTML = rank > 0 ? (rank <= 3 ? medals[rank - 1] : `<span style="font-size:11px">${rank}<sup>e</sup></span>`) : "–"
  })
  chart.querySelectorAll(".value[data-row]").forEach(el => {
    const ri = +el.dataset.row
    if (!code) { el.textContent = ""; return }
    const ci = countries.findIndex(c => c.code === code)
    const raw = getRawLatestValues(labels[ri])
    const v = raw[ci]
    el.textContent = v != null ? `${v} ${units[labels[ri]]}` : "–"
  })
  chart.querySelectorAll(".sparkline[data-row]").forEach(el => {
    const ri = +el.dataset.row
    if (!code) { el.innerHTML = ""; return }
    const ci = countries.findIndex(c => c.code === code)
    el.innerHTML = waterfallSVG(getYearSeries(labels[ri], ci))
  })
  const info = chart.querySelector(".chart-header-info")
  if (!info) return
  if (!code) {
    info.innerHTML = `<div class="col-label muted"></div>`
  } else {
    const c = countries.find(c => c.code === code)
    info.innerHTML = `<div class="col-label">${c.name}</div>`
  }
}

scheduleDrawLines()
chart.querySelectorAll(".dot img").forEach(img => img.addEventListener("load", scheduleDrawLines, { once: true }))
window.addEventListener("resize", drawLines)

root.insertAdjacentHTML("beforeend", `<div class="source">Sources : Eurostat, Mankieur 2026</div>`)

display(root)
```
