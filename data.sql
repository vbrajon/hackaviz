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
  sum(CASE WHEN "Cde_Dépense" IN ('GF01','GF02','GF03','GF04','GF05','GF06','GF07','GF08','GF09','GF10') THEN Montant ELSE 0 END) AS Depenses_totales,
  sum(CASE WHEN "Cde_Dépense" = 'GF09' THEN Montant ELSE 0 END) AS Depenses_educ_montant,
  sum(CASE WHEN "Cde_Dépense" = 'GF09' THEN Montant ELSE 0 END)
    / nullif(sum(CASE WHEN "Cde_Dépense" IN ('GF01','GF02','GF03','GF04','GF05','GF06','GF07','GF08','GF09','GF10') THEN Montant ELSE 0 END), 0) AS Depenses_educ_part,
  sum(CASE WHEN "Cde_Dépense" = 'GF0901' THEN Montant ELSE 0 END)
    / nullif(sum(CASE WHEN "Cde_Dépense" = 'GF01' THEN Montant ELSE 0 END), 0) AS Part_Primaire,
  sum(CASE WHEN "Cde_Dépense" = 'GF0902' THEN Montant ELSE 0 END)
    / nullif(sum(CASE WHEN "Cde_Dépense" = 'GF01' THEN Montant ELSE 0 END), 0) AS Part_Secondaire,
  (sum(CASE WHEN "Cde_Dépense" = 'GF0903' THEN Montant ELSE 0 END) + sum(CASE WHEN "Cde_Dépense" = 'GF0904' THEN Montant ELSE 0 END))
    / nullif(sum(CASE WHEN "Cde_Dépense" = 'GF01' THEN Montant ELSE 0 END), 0) AS "Part_Supérieur"
FROM hackaviz('depenses_euro')
WHERE "Cde_Dépense" IN ('GF01','GF02','GF03','GF04','GF05','GF06','GF07','GF08','GF09','GF10','GF0901','GF0902','GF0903','GF0904')
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
-- 1b. Agrégats UE (Cde_Pays = 'EU')
-- Règle : somme des montants bruts → calcul de l'indicateur
-- Sauf Part Jeunes → pondération par population (≡ somme PS / somme pop)
-- Sauf PISA / compétences → moyenne simple des pays ayant des notes
-- ============================================================

INSERT INTO impot_filtre
SELECT "Année", 'EU', 'UE-16', sum(Montant_Impots)
FROM impot_filtre GROUP BY "Année";

INSERT INTO pib_filtre
SELECT "Année", 'EU', 'UE-16', sum(Montant_PIB)
FROM pib_filtre GROUP BY "Année";

INSERT INTO population_filtre
SELECT "Année", 'EU', sum(Total_Pop), sum(Femmes), sum(Hommes), 1.0
FROM population_filtre GROUP BY "Année";

-- Dépenses : somme des montants bruts, recalcul des ratios
INSERT INTO depenses_euro_filtre
SELECT
  "Année", 'EU' AS Cde_Pays,
  sum(CASE WHEN "Cde_Dépense" IN ('GF01','GF02','GF03','GF04','GF05','GF06','GF07','GF08','GF09','GF10') THEN Montant ELSE 0 END),
  sum(CASE WHEN "Cde_Dépense" = 'GF09' THEN Montant ELSE 0 END),
  sum(CASE WHEN "Cde_Dépense" = 'GF09' THEN Montant ELSE 0 END)
    / nullif(sum(CASE WHEN "Cde_Dépense" IN ('GF01','GF02','GF03','GF04','GF05','GF06','GF07','GF08','GF09','GF10') THEN Montant ELSE 0 END), 0),
  sum(CASE WHEN "Cde_Dépense" = 'GF0901' THEN Montant ELSE 0 END)
    / nullif(sum(CASE WHEN "Cde_Dépense" = 'GF01' THEN Montant ELSE 0 END), 0),
  sum(CASE WHEN "Cde_Dépense" = 'GF0902' THEN Montant ELSE 0 END)
    / nullif(sum(CASE WHEN "Cde_Dépense" = 'GF01' THEN Montant ELSE 0 END), 0),
  (sum(CASE WHEN "Cde_Dépense" = 'GF0903' THEN Montant ELSE 0 END) + sum(CASE WHEN "Cde_Dépense" = 'GF0904' THEN Montant ELSE 0 END))
    / nullif(sum(CASE WHEN "Cde_Dépense" = 'GF01' THEN Montant ELSE 0 END), 0)
FROM hackaviz('depenses_euro')
WHERE Cde_Pays IN (SELECT DISTINCT Cde_Pays FROM impot_filtre WHERE Cde_Pays != 'EU')
  AND "Cde_Dépense" IN ('GF01','GF02','GF03','GF04','GF05','GF06','GF07','GF08','GF09','GF10','GF0901','GF0902','GF0903','GF0904')
GROUP BY "Année";

-- Dette UE : pondérée par le PIB (≡ somme dette_montant / somme PIB)
INSERT INTO dette_filtre
SELECT dt."Année", 'EU', 'UE-16',
  sum(dt.Dette_PIB * p.Montant_PIB) / nullif(sum(p.Montant_PIB), 0)
FROM dette_filtre dt
JOIN pib_filtre p ON dt."Année" = p."Année" AND dt.Cde_Pays = p.Cde_Pays
WHERE dt.Cde_Pays != 'EU'
GROUP BY dt."Année";

-- Part Jeunes UE : pondérée par la population (≡ somme jeunes PS / somme population)
INSERT INTO pyramide_age_filtre
SELECT pa."Année", 'EU', 'UE-16',
  sum(pa.Part_Moins_15ans * pop.Total_Pop) / nullif(sum(pop.Total_Pop), 0)
FROM pyramide_age_filtre pa
JOIN population_filtre pop ON pa."Année" = pop."Année" AND pa.Cde_Pays = pop.Cde_Pays
WHERE pa.Cde_Pays != 'EU'
GROUP BY pa."Année";

-- Bien-être / PISA / compétences UE : moyenne simple des pays ayant des notes
INSERT INTO bien_etre_filtre
SELECT "Année", 'EU', 'UE-16',
  avg(Adultes_FaiblesCompetences_calcul),
  avg(Adultes_Competences_calcul),
  avg(Adultes_Competences_lecture_ecriture),
  avg(Eleves_Comp_Ecrit),
  avg(Eleves_Score_Maths),
  avg(Eleves_Score_Sciences),
  avg(Adultes_Part_Faible_Comp_3PISA),
  avg(Jeunes_Sans_Emploi)
FROM bien_etre_filtre
GROUP BY "Année";

-- ============================================================
-- 2. Jointures + indicateurs
-- ============================================================

CREATE TEMP TABLE donnees_indic AS
SELECT
  i.Cde_Pays,
  i."Année",
  -- Économie
  p.Montant_PIB / pop.Total_Pop * 1000000     AS PIB_Par_Hab,
  d.Depenses_totales * 1000 / p.Montant_PIB          AS Depenses_PIB,
  d.Depenses_educ_montant * 1000 / p.Montant_PIB      AS "Depenses_ens._PIB",
  d.Depenses_educ_part                                AS Part_Depenses_Educ,
  pop.Total_Pop                                AS Population,
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
  b.Jeunes_Sans_Emploi / 100 AS Jeunes_Sans_Emploi,
  -- Répartition dépenses enseignement
  d.Part_Primaire,
  d.Part_Secondaire,
  d."Part_Supérieur"
FROM impot_filtre i
LEFT JOIN bien_etre_filtre b     USING ("Année", Cde_Pays)
LEFT JOIN depenses_euro_filtre d USING ("Année", Cde_Pays)
LEFT JOIN dette_filtre dt        USING ("Année", Cde_Pays)
LEFT JOIN pib_filtre p           USING ("Année", Cde_Pays)
LEFT JOIN population_filtre pop  USING ("Année", Cde_Pays)
LEFT JOIN pyramide_age_filtre pa USING ("Année", Cde_Pays);

-- Fix EU Depenses_PIB / Depenses_ens_PIB: PIB-weighted average of country ratios
-- (avoids mismatch when some countries lack depenses data for a given year)
UPDATE donnees_indic SET
  Depenses_PIB = eu_fix.dep_pib,
  "Depenses_ens._PIB" = eu_fix.dep_ens_pib,
  Part_Depenses_Educ = eu_fix.educ_part
FROM (
  SELECT d."Année",
    sum(d.Depenses_PIB * p.Montant_PIB) / nullif(sum(CASE WHEN d.Depenses_PIB IS NOT NULL THEN p.Montant_PIB END), 0) AS dep_pib,
    sum(d."Depenses_ens._PIB" * p.Montant_PIB) / nullif(sum(CASE WHEN d."Depenses_ens._PIB" IS NOT NULL THEN p.Montant_PIB END), 0) AS dep_ens_pib,
    sum(d.Part_Depenses_Educ * p.Montant_PIB) / nullif(sum(CASE WHEN d.Part_Depenses_Educ IS NOT NULL THEN p.Montant_PIB END), 0) AS educ_part
  FROM donnees_indic d
  JOIN pib_filtre p ON d."Année" = p."Année" AND d.Cde_Pays = p.Cde_Pays
  WHERE d.Cde_Pays != 'EU'
  GROUP BY d."Année"
) eu_fix
WHERE donnees_indic.Cde_Pays = 'EU' AND donnees_indic."Année" = eu_fix."Année";

-- ============================================================
-- 3. Pivot → table_historique (Variable × Année, pays en colonnes)
-- ============================================================

CREATE TEMP TABLE long_form AS
SELECT Cde_Pays, "Année", Variable, Valeur
FROM donnees_indic
UNPIVOT (
  Valeur FOR Variable IN (
    Population, PIB_Par_Hab, Depenses_PIB, "Depenses_ens._PIB", Part_Depenses_Educ,
    Part_Pop, Part_Jeunes, Tx_Prelevements_Oblig, Dette_PIB,
    Adultes_FaiblesCompetences_calcul, Adultes_Competences_calcul,
    Adultes_Competences_lecture_ecriture, Eleves_Comp_Ecrit,
    Eleves_Score_Maths, Eleves_Score_Sciences,
    Adultes_Part_Faible_Comp_3PISA, Jeunes_Sans_Emploi,
    Part_Primaire, Part_Secondaire, "Part_Supérieur"
  )
)
WHERE Valeur IS NOT NULL;

-- Métadonnées indicateurs
CREATE TEMP TABLE meta AS
SELECT *, row_number() OVER () AS Ordre FROM (VALUES
  ('Population',                          'Démographie',  'Population',                 'hab',    NULL),
  ('Part_Pop',                            'Démographie',  'Population & Part',      '%',      NULL),
  ('Part_Jeunes',                         'Démographie',  'Part des jeunes',            '%',      NULL),
  ('PIB_Par_Hab',                         'Démographie',  'PIB par habitant',           '€',      NULL),
  ('Jeunes_Sans_Emploi',                  'Démographie',  'Jeunes sans emploi',         '%',      '1'),
  ('Depenses_PIB',                        'Économie',     'Dépenses pub. / PIB',        '% PIB',  '1'),
  ('Depenses_ens._PIB',                   'Économie',     'Dépenses ens. / PIB',        '% PIB',  '1'),
  ('Part_Depenses_Educ',                  'Économie',     'Part dép. éducation',        '%',      NULL),
  ('Tx_Prelevements_Oblig',               'Économie',     'Taux prélèv. obligatoires',  '% PIB',  '1'),
  ('Dette_PIB',                           'Économie',     'Dette / PIB',                '% PIB',  '1'),
  ('Adultes_FaiblesCompetences_calcul',   'Compétences Adultes',      'Faibles comp. en calcul',    '%',      '1'),
  ('Adultes_Competences_calcul',          'Compétences Adultes',      'Compétences en calcul',      'pts',    NULL),
  ('Adultes_Competences_lecture_ecriture', 'Compétences Adultes',     'Compétences en lecture',     'pts',    NULL),
  ('Adultes_Part_Faible_Comp_3PISA',      'Compétences Adultes',      'Faible comp. PISA',          '%',      '1'),
  ('Eleves_Comp_Ecrit',                   'Compétences Élèves',       'Score en lecture',           'pts',    NULL),
  ('Eleves_Score_Maths',                  'Compétences Élèves',       'Score en maths',             'pts',    NULL),
  ('Eleves_Score_Sciences',               'Compétences Élèves',       'Score en sciences',          'pts',    NULL),
  ('Part_Primaire',                        'Enseignement', 'Part primaire',              '% ens',      NULL),
  ('Part_Secondaire',                      'Enseignement', 'Part secondaire',            '% ens',      NULL),
  ('Part_Supérieur',                       'Enseignement', 'Part supérieur',             '% ens',      NULL)
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
  h.IRL, h.ITA, h.LTU, h.LUX, h.LVA, h.NLD, h.PRT, h.SVK, h.EU
FROM table_historique h
LEFT JOIN meta m ON h.Variable = m.Cle
ORDER BY m.Ordre, h."Année";

-- ============================================================
-- 5. CLI only — export to CSV (do NOT paste this in the playground)
-- ============================================================

COPY (
  SELECT
    h."Année", m."Catégorie", m.Variable, m."Unité", m.Inverse,
    h.AUT, h.BEL, h.DEU, h.ESP, h.EST, h.FIN, h.FRA, h.GRC,
    h.IRL, h.ITA, h.LTU, h.LUX, h.LVA, h.NLD, h.PRT, h.SVK, h.EU
  FROM table_historique h
  LEFT JOIN meta m ON h.Variable = m.Cle
  ORDER BY m.Ordre, h."Année"
) TO 'data.csv' (HEADER, DELIMITER ',');
