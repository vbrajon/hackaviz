-- ============================================================
-- Hackaviz 2026 — chargement et jointure (DuckDB)
-- Paste in https://shell.duckdb.org or run: duckdb < data.sql
-- ============================================================

-- INSTALL httpfs; LOAD httpfs;
-- COPY (SELECT * FROM read_parquet('https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/impots.parquet'))          TO 'parquet/impots.parquet';
-- COPY (SELECT * FROM read_parquet('https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/bien_etre.parquet'))       TO 'parquet/bien_etre.parquet';
-- COPY (SELECT * FROM read_parquet('https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/depenses_euro.parquet'))   TO 'parquet/depenses_euro.parquet';
-- COPY (SELECT * FROM read_parquet('https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/dette.parquet'))           TO 'parquet/dette.parquet';
-- COPY (SELECT * FROM read_parquet('https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/pyramide_age.parquet'))    TO 'parquet/pyramide_age.parquet';
-- COPY (SELECT * FROM read_parquet('https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/pib.parquet'))             TO 'parquet/pib.parquet';
-- COPY (SELECT * FROM read_parquet('https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/population.parquet'))      TO 'parquet/population.parquet';
-- CREATE MACRO hackaviz(f) AS TABLE (
--   SELECT * FROM read_parquet('parquet/' || f || '.parquet')
-- );

INSTALL httpfs; LOAD httpfs;
CREATE MACRO hackaviz(f) AS TABLE (
  SELECT * FROM read_parquet(
    'https://raw.githubusercontent.com/Toulouse-Dataviz/hackaviz-2026/main/data/parquet_long/' || f || '.parquet'
  )
);

-- ============================================================
-- 1. Filtres par table
-- ============================================================

CREATE TEMP TABLE impot_filtre AS
SELECT "Année", Cde_Pays, Pays, Montant AS Montant_Impots
FROM hackaviz('impots')
WHERE Cde_Transaction = 'D2_D5_D91_D611_D613';

CREATE TEMP TABLE bien_etre_filtre AS
SELECT "Année", Cde_Pays, Pays,
  first("Valeur_Mesurée") FILTER (Mesure = 'Adultes ayant de faibles compétences en calcul') AS Adultes_FaiblesCompetences_calcul,
  first("Valeur_Mesurée") FILTER (Mesure = 'Compétences des adultes en calcul') AS Adultes_Competences_calcul,
  first("Valeur_Mesurée") FILTER (Mesure = 'Compétences des adultes en lecture et écriture') AS Adultes_Competences_lecture_ecriture,
  first("Valeur_Mesurée") FILTER (Mesure LIKE '%compréhension de l%écrit' AND Mesure LIKE 'Compétences des élèves%') AS Eleves_Comp_Ecrit,
  first("Valeur_Mesurée") FILTER (Mesure = 'Compétences des élèves en mathématiques') AS Eleves_Score_Maths,
  first("Valeur_Mesurée") FILTER (Mesure = 'Compétences des élèves en sciences') AS Eleves_Score_Sciences,
  first("Valeur_Mesurée") FILTER (Mesure LIKE 'Faible compétences dans les trois domaines%') AS Adultes_Part_Faible_Comp_3PISA,
  first("Valeur_Mesurée") FILTER (Mesure LIKE 'Jeunes sans emploi%') AS Jeunes_Sans_Emploi
FROM hackaviz('bien_etre')
WHERE Cde_Domaine = 'HSL_6' OR "Cde_Unité" = 'PT_POP_Y15T24'
GROUP BY "Année", Cde_Pays, Pays;

CREATE TEMP TABLE depenses_euro_filtre AS
SELECT
  "Année", Cde_Pays,
  sum(Montant) AS Depenses_totales,
  sum(CASE WHEN "Cde_Dépense" = 'GF09' THEN Montant ELSE 0 END)
    / nullif(sum(Montant), 0) AS Depenses_educ
FROM hackaviz('depenses_euro')
WHERE "Cde_Dépense" IN ('GF01','GF02','GF03','GF04','GF05','GF06','GF07','GF08','GF09','GF10')
GROUP BY "Année", Cde_Pays;

CREATE TEMP TABLE dette_filtre AS
SELECT "Année", Cde_Pays, Pays, "Valeur_Mesurée" AS Dette_PIB
FROM hackaviz('dette')
WHERE "Cde_Unité" = 'PT_B1GQ';

CREATE TEMP TABLE pyramide_age_filtre AS
SELECT "Année", Cde_Pays, Pays, "Valeur_Mesurée" AS Part_Moins_15ans
FROM hackaviz('pyramide_age')
WHERE Cde_Mesure = 'PT' AND "Cde_Sexe" = '_T' AND "Cde_Âge" = 'Y_LT15';

CREATE TEMP TABLE pib_filtre AS
SELECT "Année", Cde_Pays, Pays, Montant AS Montant_PIB
FROM hackaviz('pib');

CREATE TEMP TABLE population_filtre AS
SELECT
  "Année", Cde_Pays, Total AS Total_Pop, Femmes, Hommes,
  Total / sum(Total) OVER (PARTITION BY "Année") AS part_population_eu
FROM hackaviz('population');

-- ============================================================
-- 2. Jointures + indicateurs
-- ============================================================

CREATE TEMP TABLE donnees_indic AS
SELECT
  i.Cde_Pays,
  i."Année",
  -- Économie
  p.Montant_PIB / pop.Total_Pop * 1000        AS PIB_Par_Hab,
  d.Depenses_totales / p.Montant_PIB          AS Depenses_PIB,
  d.Depenses_educ / p.Montant_PIB             AS "Depenses_ens._PIB",
  d.Depenses_educ / d.Depenses_totales        AS Part_Depenses_Educ,
  pop.part_population_eu                       AS Part_Pop,
  pa.Part_Moins_15ans / 100                    AS Part_Jeunes,
  i.Montant_Impots / p.Montant_PIB            AS Tx_Prelevements_Oblig,
  dt.Dette_PIB,
  -- Compétences (bien-être pivot columns)
  b.Adultes_FaiblesCompetences_calcul,
  b.Adultes_Competences_calcul,
  b.Adultes_Competences_lecture_ecriture,
  b.Eleves_Comp_Ecrit,
  b.Eleves_Score_Maths,
  b.Eleves_Score_Sciences,
  b.Adultes_Part_Faible_Comp_3PISA,
  b.Jeunes_Sans_Emploi / 100 AS Jeunes_Sans_Emploi
FROM impot_filtre i
LEFT JOIN bien_etre_filtre b     USING ("Année", Cde_Pays)
LEFT JOIN depenses_euro_filtre d USING ("Année", Cde_Pays)
LEFT JOIN dette_filtre dt        USING ("Année", Cde_Pays)
LEFT JOIN pib_filtre p           USING ("Année", Cde_Pays)
LEFT JOIN population_filtre pop  USING ("Année", Cde_Pays)
LEFT JOIN pyramide_age_filtre pa USING ("Année", Cde_Pays);

-- ============================================================
-- 3. Pivot → table_historique (Variable × Année, pays en colonnes)
-- ============================================================

CREATE TEMP TABLE long_form AS
SELECT Cde_Pays, "Année", Variable, Valeur
FROM donnees_indic
UNPIVOT (
  Valeur FOR Variable IN (
    PIB_Par_Hab, Depenses_PIB, "Depenses_ens._PIB", Part_Depenses_Educ,
    Part_Pop, Part_Jeunes, Tx_Prelevements_Oblig, Dette_PIB,
    Adultes_FaiblesCompetences_calcul, Adultes_Competences_calcul,
    Adultes_Competences_lecture_ecriture, Eleves_Comp_Ecrit,
    Eleves_Score_Maths, Eleves_Score_Sciences,
    Adultes_Part_Faible_Comp_3PISA, Jeunes_Sans_Emploi
  )
)
WHERE Valeur IS NOT NULL;

-- Métadonnées indicateurs
CREATE TEMP TABLE meta AS
SELECT * FROM (VALUES
  ('Part_Pop',                            'Démographie',  'Part de la population',      '%',      '0'),
  ('Part_Jeunes',                         'Démographie',  'Part des jeunes',            '%',      '0'),
  ('PIB_Par_Hab',                         'Démographie',  'PIB par habitant',           'USD',    '0'),
  ('Jeunes_Sans_Emploi',                  'Démographie',  'Jeunes sans emploi',         '%',      '1'),
  ('Depenses_PIB',                        'Finances',     'Dépenses pub. / PIB',        '% PIB',  '1'),
  ('Depenses_ens._PIB',                   'Finances',     'Dépenses ens. / PIB',        '% PIB',  '1'),
  ('Part_Depenses_Educ',                  'Finances',     'Part dép. éducation',        '%',      '0'),
  ('Tx_Prelevements_Oblig',               'Finances',     'Taux prélèv. obligatoires',  '% PIB',  '0'),
  ('Dette_PIB',                           'Finances',     'Dette / PIB',                '% PIB',  '1'),
  ('Adultes_FaiblesCompetences_calcul',   'Adultes',      'Faibles comp. en calcul',    '%',      '1'),
  ('Adultes_Competences_calcul',          'Adultes',      'Compétences en calcul',      'score',  '0'),
  ('Adultes_Competences_lecture_ecriture', 'Adultes',      'Compétences en lecture',     'score',  '0'),
  ('Adultes_Part_Faible_Comp_3PISA',      'Adultes',      'Faible comp. PISA',          '%',      '1'),
  ('Eleves_Comp_Ecrit',                   'Élèves',       'Score en lecture',           'points', '0'),
  ('Eleves_Score_Maths',                  'Élèves',       'Score en maths',             'points', '0'),
  ('Eleves_Score_Sciences',               'Élèves',       'Score en sciences',          'points', '0')
) AS t(Cle, "Catégorie", Variable, "Unité", Inverse);

CREATE TEMP TABLE table_historique AS
PIVOT long_form
ON Cde_Pays
USING first(Valeur)
GROUP BY Variable, "Année";

-- ============================================================
-- 4. Results — works in both WASM playground and CLI
-- ============================================================

SELECT
  h."Année", m."Catégorie", m.Variable, m."Unité", m.Inverse,
  h.AUT, h.BEL, h.DEU, h.ESP, h.EST, h.FIN, h.FRA, h.GRC,
  h.IRL, h.ITA, h.LTU, h.LUX, h.LVA, h.NLD, h.PRT, h.SVK
FROM table_historique h
LEFT JOIN meta m ON h.Variable = m.Cle
ORDER BY m.Variable, h."Année";

-- ============================================================
-- 5. CLI only — export to CSV (do NOT paste this in the playground)
-- ============================================================

COPY (
  SELECT
    h."Année", m."Catégorie", m.Variable, m."Unité", m.Inverse,
    h.AUT, h.BEL, h.DEU, h.ESP, h.EST, h.FIN, h.FRA, h.GRC,
    h.IRL, h.ITA, h.LTU, h.LUX, h.LVA, h.NLD, h.PRT, h.SVK
  FROM table_historique h
  LEFT JOIN meta m ON h.Variable = m.Cle
  ORDER BY m.Variable, h."Année"
) TO 'data.csv' (HEADER, DELIMITER ',');
