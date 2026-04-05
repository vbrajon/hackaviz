# ============================================================
# Chargement et jointure des tables parquet
# ============================================================

library(here)
library(arrow)
library(dplyr)
library(stringr)
library(tidyr)

# ── Répertoire des données (2 niveaux au-dessus de la racine du projet) ────────
data_dir <- here("..", "..", "data","parquet_long")

# ── Fonction utilitaire : lire un fichier parquet ──────────────────────────────
lire_parquet <- function(nom_fichier) {
  chemin <- file.path(data_dir, paste0(nom_fichier, ".parquet"))
  message("Lecture de : ", chemin)
  read_parquet(chemin)
}

# ============================================================
# 1. Chargement des 7 tables
# ============================================================

impot        <- lire_parquet("impots")
bien_etre    <- lire_parquet("bien_etre")
depenses_euro <- lire_parquet("depenses_euro")
dette        <- lire_parquet("dette")
pib          <- lire_parquet("pib")
population   <- lire_parquet("population")
pyramide_age <- lire_parquet("pyramide_age")

# ============================================================
# 2. Filtres par table
# ============================================================

# -- impot : Cde_Transaction dans {"ODC", "ODA", "D2_D5_D91_D611_D613"} --------
impot_filtre <- impot |>
 # filter(Cde_Transaction %in% c("ODC", "ODA", "D2_D5_D91_D611_D613"))
  filter(Cde_Transaction == "D2_D5_D91_D611_D613") |> 
  rename(Montant_Impots=Montant) |>
  select(Année,Cde_Pays,Pays,Montant_Impots)


# -- bien_etre : Cde_Unité dans {"USD_PPP_PS", "PT_POP", "PT_POP_Y15T24"}
#               OU Domain == "HSL_6" -----------------------------------------------
bien_etre_filtre <- bien_etre |>
  filter( Cde_Domaine == "HSL_6" | Cde_Unité=="PT_POP_Y15T24") |>
  rename(Val_Indic_Competence=Valeur_Mesurée,
         Mesure_Competence=Mesure) |>
  select(Année,Cde_Pays,Pays,Val_Indic_Competence,Mesure_Competence)

# -- Libelles PISA attendus dans Mesure_Competence ----------------------------

LBL_FAIBLE_CALCUL   <- "Adultes ayant de faibles compétences en calcul"
LBL_CALCUL          <- "Compétences des adultes en calcul"
LBL_LECT            <- "Compétences des adultes en lecture et écriture"
LBL_ELEVES_ECRIT    <- "Compétences des élèves en compréhension de l’écrit"
LBL_ELEVES_MATHS    <- "Compétences des élèves en mathématiques"
LBL_ELEVES_SCI      <- "Compétences des élèves en sciences"
LBL_ADULTES_SUP_CALCUL      <- "Décile supérieur des résultats des adultes en calcul" 
LBL_ADULTES_SUP_LECTURE      <- "Décile supérieur des résultats des adultes en lecture et écriture" 
LBL_ADULTES_SUP_ECRIT   <- "Décile supérieur des résultats en compréhension de l’écrit"
LBL_DEC_SUP_MATHS   <- "Décile supérieur des résultats en mathématiques"
LBL_DEC_SUP_SCI     <- "Décile supérieur des résultats en sciences"
LBL_FAIBLE_3PISA    <- "Faible compétences dans les trois domaines évalués par le PISA"
LBL_JEUNES_SANSEMPLOI    <- "Jeunes sans emploi et sortis du système éducatif"

bien_etre_filtre <- bien_etre_filtre |>
  pivot_wider(
    id_cols     = c(Année, Cde_Pays, Pays),
    names_from  = Mesure_Competence,
    values_from = Val_Indic_Competence
  ) |>
  rename(
    Adultes_FaiblesCompetences_calcul     = all_of(LBL_FAIBLE_CALCUL),
    Adultes_Competences_calcul            = all_of(LBL_CALCUL),
    Adultes_Competences_lecture_ecriture  = all_of(LBL_LECT),
    Eleves_Comp_Ecrit                     = all_of(LBL_ELEVES_ECRIT),
    Eleves_Score_Maths                    = all_of(LBL_ELEVES_MATHS),
    Eleves_Score_Sciences                 = all_of(LBL_ELEVES_SCI), 
    Adultes_Decile_Sup_Calcul           = all_of(LBL_ADULTES_SUP_CALCUL),
    Adultes_Decile_Sup_Lecture           = all_of(LBL_ADULTES_SUP_LECTURE),
    Adultes_Decile_Sup_Ecrit           = all_of(LBL_ADULTES_SUP_ECRIT),
    Adultes_Decile_Sup_Maths              = all_of(LBL_DEC_SUP_MATHS),
    Adultes_Decile_Sup_Sciences           = all_of(LBL_DEC_SUP_SCI),
    Adultes_Part_Faible_Comp_3PISA        = all_of(LBL_FAIBLE_3PISA),
    Jeunes_Sans_Emploi        = all_of(LBL_JEUNES_SANSEMPLOI)
  )


# -- depenses_euro : Cde_Dépense dans la liste GF01 … GF10 + sous-codes --------
codes_depenses <- c(
  "GF01", "GF02", "GF03", "GF04", "GF05",
  "GF06", "GF07", "GF08", "GF09", "GF10",
  "GF0901", "GF0902", "GF0903", "GF0904",
  "GF0905", "GF0906", "GF0907", "GF0908"
)

#   I1_part_GF09 = GF09 / total(GF01:GF10)   -> part sante/total
#   GF09_valeur                               -> montant brut GF09
#
#   On exclut les sous-codes GF090x du total pour eviter le double-comptage.
#
#   !! Ajustez col_valeur_dep si votre colonne valeur s'appelle autrement
#      (ex. "OBS_VALUE", "Montant", "value"...)


col_valeur_dep <- "Montant_Depense"

codes_total <- c("GF01","GF02","GF03","GF04","GF05",
                 "GF06","GF07","GF08","GF09","GF10")

depenses_euro_filtre <- depenses_euro |> 
  rename(Montant_Depense=Montant) |>
  filter(`Cde_Dépense` %in% codes_total) |>
  summarise(
    Depenses_totales = sum(.data[[col_valeur_dep]], na.rm = TRUE),
    Depenses_educ     = sum(
      ifelse(`Cde_Dépense` == "GF09", .data[[col_valeur_dep]], 0),
      na.rm = TRUE
    ),
    .by = c("Année", "Cde_Pays")
  ) |>
  mutate(
    Depenses_educ = Depenses_educ / Depenses_totales
  )

# -- dette : Cde_Unité == "PT_B1GQ" --------------------------------------------
dette_filtre <- dette |>
  filter(`Cde_Unité` == "PT_B1GQ") |>
  rename(Dette_PIB=Valeur_Mesurée) |>
  select(Année,Cde_Pays,Pays,Dette_PIB)
  
# -- pyramide_age : Cde_Mesure == "PT_POP"
#                   ET Cde_Sexe == "_T"
#                   ET Cde_Âge  == "Y_LT15" ------------------------------------
pyramide_age_filtre <- pyramide_age |>
  filter(
    Cde_Mesure == "PT_POP",
    `Cde_Sexe` == "_T",
    `Cde_Âge`  == "Y_LT15"
  )|>
  rename(Part_Moins_15ans=Valeur_Mesurée) |>
  select(Année,Cde_Pays,Pays,Part_Moins_15ans)


# ── pib : pas de filtre spécifié, juste renommage ─────
pib_filtre        <- pib |> 
  rename(Montant_PIB=Montant)

# ── population  : total population en Europe ─────
population_filtre <- population |> 
  rename(Total_Pop=Total)|>
  mutate(
    part_population_eu = Total_Pop / sum(Total_Pop, na.rm = TRUE),
    .by = Année
  )

# ============================================================
# 3. Clés de jointure
# ============================================================
cles <- c("Année", "Cde_Pays")

# ============================================================
# 4. Jointures successives (left_join sur la base impot)
# ============================================================

joindre <- function(base, nouvelle_table, suffixe) {
  # Déterminer les clés réellement disponibles dans les deux tables
  cles_dispo <- intersect(cles, intersect(names(base), names(nouvelle_table)))
  if (length(cles_dispo) == 0) {
    warning("Aucune clé commune avec la table '", suffixe, "' — jointure ignorée.")
    return(base)
  }
  message("Jointure sur : ", paste(cles_dispo, collapse = ", "), " (table : ", suffixe, ")")
  left_join(base, nouvelle_table, by = cles_dispo, suffix = c("", paste0(".", suffixe)))
}



donnees_jointes <- impot_filtre |>
  joindre(bien_etre_filtre,    "bien_etre")    |>
  joindre(depenses_euro_filtre, "depenses")    |>
  joindre(dette_filtre,        "dette")        |>
  joindre(pib_filtre,          "pib")          |>
  joindre(population_filtre,   "population")   |>
  joindre(pyramide_age_filtre, "pyramide_age")

# ============================================================
# 5. Aperçu du résultat
# ============================================================
message("\nDimensions du jeu de données final : ",
        nrow(donnees_jointes), " lignes × ",
        ncol(donnees_jointes), " colonnes")

glimpse(donnees_jointes)


# ============================================================
# 6. Traitements de quelques indicateurs
# ============================================================


donnees_indic <- donnees_jointes |>
  mutate(
    PIB_Par_Hab            = Montant_PIB / Total_Pop*1000,
    Depenses_PIB           = Depenses_totales / Montant_PIB,
    `Depenses_ens._PIB`    = Depenses_educ / Montant_PIB,
    Part_Depenses_Educ     = Depenses_educ / Depenses_totales,
    Part_Pop               = part_population_eu,
    Part_Jeunes            = Part_Moins_15ans/100,
    Jeunes_Sans_Emploi     = Jeunes_Sans_Emploi/100,
    Tx_Prelevements_Oblig  = Montant_Impots / Montant_PIB
  )|>
  select(Cde_Pays, Année,
         PIB_Par_Hab, Depenses_PIB, `Depenses_ens._PIB`, Part_Depenses_Educ,
         Part_Pop, Part_Jeunes, Tx_Prelevements_Oblig, Dette_PIB,
         Adultes_FaiblesCompetences_calcul,
         Adultes_Competences_calcul,
         Adultes_Competences_lecture_ecriture,
         Eleves_Comp_Ecrit,
         Eleves_Score_Maths ,
         Eleves_Score_Sciences  , 
         Adultes_Decile_Sup_Calcul  ,
         Adultes_Decile_Sup_Lecture   ,
         Adultes_Decile_Sup_Ecrit ,
         Adultes_Decile_Sup_Maths,
         Adultes_Decile_Sup_Sciences ,
         Adultes_Part_Faible_Comp_3PISA,
         Jeunes_Sans_Emploi)



# Variables indicateurs qui nous intéressent
    # PIB_Par_Hab  ,          
    # Depenses_PIB      ,     
    # `Depenses_ens._PIB,    
    # Part_Depenses_Educ    ,
    # Part_Pop       ,
    # Part_Jeunes         ,
    # Tx_Prelevements_Oblig,
    # Dette_PIB,
    # Adultes_Part_Faible_Comp_3PISA , 
    # Adultes_Decile_Sup_Sciences,
    # Adultes_Decile_Sup_Maths,
    # Adultes_Decile_Sup_Comp_Ecrit,
    # Eleves_Comp_Ecrit,
    # Eleves_Score_Maths,
    # Eleves_Score_Sciences,
    # Adultes_FaiblesCompetences_calcul,
    # Adultes_Competences_calcul       

# 
# donnees_last <- donnees_indic |>
#   select(Cde_Pays, Année,
#          PIB_Par_Hab, Depenses_PIB, `Depenses_ens._PIB`, Part_Depenses_Educ,
#          Part_Pop, Part_Jeunes, Tx_Prelevements_Oblig, Dette_PIB,
#          Adultes_Part_Faible_Comp_3PISA, Adultes_Decile_Sup_Sciences,
#          Adultes_Decile_Sup_Maths, Adultes_Decile_Sup_Comp_Ecrit,
#          Eleves_Comp_Ecrit, Eleves_Score_Maths, Eleves_Score_Sciences,
#          Adultes_FaiblesCompetences_calcul, Adultes_Competences_calcul,
#          Adultes_Competences_lecture_ecriture
#   ) |>
#   pivot_longer(
#     cols = -c(Cde_Pays, Année),
#     names_to  = "Variable",
#     values_to = "Valeur"
#   ) |>
#   filter(!is.na(Valeur)) |>
#   group_by(Cde_Pays, Variable) |>
#   slice_max(Année, n = 1, with_ties = FALSE) |>
#   ungroup() |>
#   pivot_wider(
#     names_from  = Variable,
#     values_from = c(Valeur, Année),
#     names_glue  = "{.value}_{Variable}"
#   )
# 


# ============================================================
# 7. Creation des indicateurs normalisés par Cde_Pays pour la dernière année dispo pour l'affichage
# ============================================================

vars_indicateurs <- c("Part_Pop", 
                      "Part_Jeunes",
                      "PIB_Par_Hab", 
                      "Depenses_PIB",
                      "Depenses_ens._PIB", 
                      "Part_Depenses_Educ",  
                      "Tx_Prelevements_Oblig", 
                      "Dette_PIB",
                      "Adultes_FaiblesCompetences_calcul",
                      "Adultes_Competences_calcul",
                      "Adultes_Competences_lecture_ecriture",
                      "Eleves_Comp_Ecrit",
                      "Eleves_Score_Maths" ,
                      "Eleves_Score_Sciences", 
                 #     "Adultes_Decile_Sup_Calcul",
                #      "Adultes_Decile_Sup_Lecture",
                #      "Adultes_Decile_Sup_Ecrit",
                #      "Adultes_Decile_Sup_Maths",
                #      "Adultes_Decile_Sup_Sciences",
                      "Adultes_Part_Faible_Comp_3PISA",
                      "Jeunes_Sans_Emploi")


# -- Table de métadonnées des indicateurs ----------------------------------
# Ajout catégorie, Unité et si on doit inverser la variable


vars_a_inverser <- c("Depenses_PIB", "Depenses_ens._PIB", "Dette_PIB",
                     "Adultes_Part_Faible_Comp_3PISA", "Adultes_FaiblesCompetences_calcul",
                     "Jeunes_Sans_Emploi")


meta_indicateurs <- tibble(
  Variable   = vars_indicateurs,
  Categorie  = c(
    # Économie
    "Démographie",       # Part_Pop
    "Démographie",       # Part_Jeunes
    "Économie",          # PIB_Par_Hab
    "Économie",          # Depenses_PIB
    "Économie",         # Depenses_ens._PIB
    "Économie",         # Part_Depenses_Educ
    "Économie",          # Tx_Prelevements_Oblig
    "Économie",          # Dette_PIB
    # Compétences adultes
    "Compétences adultes", # Adultes_FaiblesCompetences_calcul
    "Compétences adultes", # Adultes_Competences_calcul
    "Compétences adultes", # Adultes_Competences_lecture_ecriture
    # Compétences élèves (PISA)
    "Compétences élèves",  # Eleves_Comp_Ecrit
    "Compétences élèves",  # Eleves_Score_Maths
    "Compétences élèves",  # Eleves_Score_Sciences
    # Déciles supérieurs
    # "Compétences adultes", # Adultes_Decile_Sup_Calcul
    # "Compétences adultes", # Adultes_Decile_Sup_Lecture
    # "Compétences adultes", # Adultes_Decile_Sup_Ecrit
    # "Compétences adultes", # Adultes_Decile_Sup_Maths
    # "Compétences adultes", # Adultes_Decile_Sup_Sciences
    "Compétences adultes",  # Adultes_Part_Faible_Comp_3PISA
    "Jeunes_Sans_Emploi"  #Jeunes_Sans_Emploi
  ),
  Unite      = c(
    "%",         # Part_Pop
    "%",         # Part_Jeunes
    "USD PPA",   # PIB_Par_Hab
    "% PIB",     # Depenses_PIB
    "% PIB",     # Depenses_ens._PIB
    "%",         # Part_Depenses_Educ
    "% PIB",     # Tx_Prelevements_Oblig
    "% PIB",     # Dette_PIB
    "%",         # Adultes_FaiblesCompetences_calcul
    "Points PISA",     # Adultes_Competences_calcul
    "Points PISA",     # Adultes_Competences_lecture_ecriture
    "Points PISA",     # Eleves_Comp_Ecrit
    "Points PISA",     # Eleves_Score_Maths
    "Points PISA",     # Eleves_Score_Sciences
    # "",         # Adultes_Decile_Sup_Calcul
    # "",         # Adultes_Decile_Sup_Lecture
    # "",         # Adultes_Decile_Sup_Ecrit
    # "",         # Adultes_Decile_Sup_Maths
    # "",         # Adultes_Decile_Sup_Sciences
    "%",         # Adultes_Part_Faible_Comp_3PISA
    "%"         #Jeunes_Sans_Emploi
  ),
  Inverse    = Variable %in% vars_a_inverser
)



table_historique <- donnees_indic |>
  select(Cde_Pays, Année, all_of(vars_indicateurs)) |>
  pivot_longer(
    cols      = -c(Cde_Pays, Année),
    names_to  = "Variable",
    values_to = "Valeur"
  ) |>
  filter(!is.na(Valeur)) |>
  pivot_wider(
    names_from  = Cde_Pays,
    values_from = Valeur
  ) |>
  left_join(meta_indicateurs, by = "Variable") |>   # <-- ici
  arrange(Variable, Année)


# 
# donnees_last_norm <- donnees_last |>
#   mutate(across(
#     .cols  = paste0("Valeur_", vars_indicateurs),
#     .fns   = ~ (. - min(., na.rm = TRUE)) / (max(., na.rm = TRUE) - min(., na.rm = TRUE)),
#     .names = "{.col}_norm"
#   )) |>
#   mutate(across(
#     .cols = paste0("Valeur_", vars_a_inverser, "_norm"),
#     .fns  = ~ 1 - .
#   ))


# ============================================================
# 8. Mise en forme finale des 3 tables
# ============================================================

# # -- 1. Valeurs normalisées : indicateurs en lignes, pays en colonnes ----------
# table_norm <- donnees_last_norm |>
#   select(Cde_Pays, starts_with("Valeur_") & ends_with("_norm")) |>
#   pivot_longer(
#     cols      = -Cde_Pays,
#     names_to  = "Variable",
#     values_to = "Valeur_norm"
#   ) |>
#   mutate(Variable = str_remove(Variable, "^Valeur_") |> str_remove("_norm$")) |>
#   pivot_wider(
#     names_from  = Cde_Pays,
#     values_from = Valeur_norm
#   )
# 
# # -- 2. Dernière année dispo : même format ------------------------------------
# table_annees <- donnees_last_norm |>
#   select(Cde_Pays, starts_with("Année_")) |>
#   pivot_longer(
#     cols      = -Cde_Pays,
#     names_to  = "Variable",
#     values_to = "Derniere_Annee"
#   ) |>
#   mutate(Variable = str_remove(Variable, "^Année_")) |>
#   pivot_wider(
#     names_from  = Cde_Pays,
#     values_from = Derniere_Annee
#   )

# # -- 3. Historique complet : toutes années, pays en colonnes ------------------
# table_historique <- donnees_indic |>
#   select(Cde_Pays, Année, all_of(vars_indicateurs)) |>
#   pivot_longer(
#     cols      = -c(Cde_Pays, Année),
#     names_to  = "Variable",
#     values_to = "Valeur"
#   ) |>
#   filter(!is.na(Valeur)) |>
#   pivot_wider(
#     names_from  = Cde_Pays,
#     values_from = Valeur
#   ) |>
#   arrange(Variable, Année)


# ============================================================
# 6. (Optionnel) Sauvegarde du résultat en parquet
# ============================================================
# write_parquet(donnees_jointes, file.path(data_dir, "donnees_jointes.parquet"))

library(readr)

output_dir <- here("csv_output")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

# Export CSV
write_csv(table_historique, file.path(output_dir, "table_historique.csv"))

# Export du spec de colonnes pour relecture typée
spec_cols <- capture.output(spec(table_historique))
writeLines(spec_cols, file.path(output_dir, "table_historique_spec.txt"))

message("Export terminé dans : ", output_dir)

# Relecture typée grâce au spec
col_spec <- cols(
  Variable  = col_character(),
  Année     = col_double(),
  Categorie = col_character(),
  Unite     = col_character(),
  Inverse   = col_logical(),
  # colonnes pays (numériques) → détectées automatiquement
  .default  = col_double()
)

table_historique <- read_csv(
  file.path(output_dir, "table_historique.csv"),
  col_types = col_spec
)
