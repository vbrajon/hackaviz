# Toulouse DataViz / Hackaviz

Règlement: https://toulouse-dataviz.fr/hackaviz/reglement/

Github: https://github.com/Toulouse-Dataviz/hackaviz-2026

Viz 1: Carte
Viz 2: Rang sur plusieurs catégories
Viz 3: 

---

Pour le moment je vais faire la structure à la main et prompter, et avoir une seul branche et un seul fichier.
Mais ça pourrait être dans un mini v0/tldraw d'exploration.

Idée playground d'exploration / Val:
- un prompt - avec un prompt system et template de base, HTML, JSON, modulaire
- qui te dessine 3 variants "fast" et ajoute un bouton "+" pour des variants "high" (settings réglables, models, nb)
- canvas comme magic path / tldraw
- avec des iframes/sandbox arrow-js pour chaque prompt
- a tout moment on peut faire la "aigle view" comme dans tldraw et retourner dans une branche précédente
- tout ça correpond à une session avec filesystem, /tree dans pi

Tech explorateur:
- sqlite / duckdb
- agentfs / agentos
- iframe / arrow-js
- canvas / tldraw
- spreadsheet / supabase

Tech output:
- chaque iframe est un seul fichier HTML self-contained, aggregé data/app/vendor
<title>Hackaviz - [PROJECT_NAME]</title>
<textarea id="data" style="display:none;" contenteditable>[PROJECT_DATA in CSV or JSON]</textarea>
<script type="module"></script>
<script type="importmap"></script><script src="tailwindcdn"></script>

<!--  -->

data:text/html,
<title contenteditable>Panorama de la Zone Euro</title>
<style contenteditable>head,[contenteditable]{display:block;}body{margin:0;height:fit-content}</style>
<script contenteditable type="module" oninput="eval(this.innerText)"></script>
<textarea id="data"></textarea>
