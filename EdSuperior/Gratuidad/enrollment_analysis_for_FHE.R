# =============================================================================
# Analysis: Impact of age cap on Higher Education in Chile
# Variables of Interest: Age 30+, Gender, FHE (Gratuidad)
# Years: 2014, 2015, 2024, 2025
# =============================================================================

library(dplyr)
library(readr)
library(stringr)
library(tidyr)

# -----------------------------------------------------------------------------
# CONFIGURACIÓN
# -----------------------------------------------------------------------------

base_path <- "C:/Users/mc72574/Dropbox/EdSuperior"

mat_path <- file.path(base_path, "Matricula")
ben_path <- file.path(base_path, "Beneficios")
years    <- c(2014, 2015, 2024, 2025)

mat_files <- setNames(
  file.path(mat_path, paste0("20250729_Matrícula_Ed_Superior_", years, "_PUBL_MRUN.csv")),
  years
)

ben_files <- setNames(
  file.path(ben_path, paste0("Asignacion ", years, "_PA_PUBL.csv")),
  years
)


# -----------------------------------------------------------------------------
# CONSTANTES
# -----------------------------------------------------------------------------

edades_30plus <- c("30 a 34 años", "35 a 39 años", "40 y más años")

# Etiquetas de grupos institucionales
GRUPOS <- list(
  Total       = NULL,   # sin filtro
  Universidad = "Universidades",
  `CFT+IP`    = c("Centros de Formación Técnica", "Institutos Profesionales")
)

# -----------------------------------------------------------------------------
# 1. CARGAR Y PREPARAR DATOS POR AÑO
# -----------------------------------------------------------------------------

process_year <- function(yr) {
  
  cat(sprintf("  Procesando %d...\n", yr))
  
  # --- Matrícula ---
  mat_raw <- read_delim(
    mat_files[as.character(yr)],
    delim          = ";",
    locale         = locale(encoding = "UTF-8"),
    show_col_types = FALSE
  )
  names(mat_raw) <- toupper(names(mat_raw))
  
  mat <- mat_raw %>%
    filter((ANIO_ING_CARR_ORI == yr) & (NIVEL_GLOBAL == "Pregrado")) %>%
    mutate(
      # 30+: NA si sin información (excluidos del denominador)
      edad_30plus = case_when(
        RANGO_EDAD %in% edades_30plus ~ 1L,
        str_detect(str_to_lower(RANGO_EDAD), "sin") ~ NA_integer_,
        TRUE ~ 0L
      ),
      es_mujer = if_else(as.integer(GEN_ALU) == 2L, 1L, 0L),
      # Grupo institucional
      grupo_inst = case_when(
        TIPO_INST_1 == "Universidades" ~ "Universidad",
        TIPO_INST_1 %in% c("Centros de Formación Técnica", "Institutos Profesionales")  ~ "CFT+IP",
        TRUE ~ "Otro"
      )
    )
  
  # --- Beneficios ---
  ben_raw <- read_delim(
    ben_files[as.character(yr)],
    delim          = ";",
    locale         = locale(encoding = "UTF-8"),
    show_col_types = FALSE
  )
  names(ben_raw) <- toupper(names(ben_raw))
  
  ben <- ben_raw %>%
    filter(ANIO_BENEFICIO == yr) %>%
    mutate(is_gratuidad = str_to_upper(BENEFICIO_BECA_FSCU) == "GRATUIDAD") %>%
    arrange(MRUN, desc(is_gratuidad)) %>%   # GRATUIDAD rows float to the top
    distinct(MRUN, .keep_all = TRUE) %>%    # keep first row per MRUN
    select(-is_gratuidad)

  # Left join: sin beneficio --> gratuidad = 0
  merged <- mat %>%
    left_join(ben, by = "MRUN") %>%
    mutate(
      tiene_gratuidad = if_else(
        !is.na(BENEFICIO_BECA_FSCU) & str_to_upper(BENEFICIO_BECA_FSCU) == "GRATUIDAD",
        1L, 0L
      )
    )
  
  merged$anio <- yr
  merged
}

datos <- lapply(years, process_year)
names(datos) <- years
cat("\n✓ Datos cargados.\n\n")

# -----------------------------------------------------------------------------
# 2. FUNCIÓN DE ESTADÍSTICAS (acepta cualquier subconjunto + etiqueta)
# -----------------------------------------------------------------------------

calcular_stats <- function(d, yr, grupo_label) {
  
  d_con_edad <- filter(d, !is.na(edad_30plus))
  d_30plus   <- filter(d_con_edad, edad_30plus == 1L)
  
  n_total         <- nrow(d)
  n_con_edad      <- nrow(d_con_edad)
  n_30plus        <- nrow(d_30plus)
  pct_30plus      <- if (n_con_edad > 0) n_30plus / n_con_edad * 100 else NA_real_
  
  n_muj_30plus    <- sum(d_30plus$es_mujer,        na.rm = TRUE)
  pct_muj_30plus  <- if (n_30plus > 0) n_muj_30plus / n_30plus * 100 else NA_real_
  
  n_grat_total    <- sum(d$tiene_gratuidad,         na.rm = TRUE)
  pct_grat_total  <- if (n_total > 0) n_grat_total / n_total * 100 else NA_real_
  
  n_grat_30plus   <- sum(d_30plus$tiene_gratuidad,  na.rm = TRUE)
  pct_grat_30plus <- if (n_30plus > 0) n_grat_30plus / n_30plus * 100 else NA_real_
  
  res <- tibble(
    Año                           = yr,
    Grupo                         = grupo_label,
    `N total 1er año`             = n_total,
    `N con edad informada`        = n_con_edad,
    `N 30+ años`                  = n_30plus,
    `% 30+`                       = round(pct_30plus,     2),
    `N mujeres 30+`               = n_muj_30plus,
    `% mujeres entre 30+`         = round(pct_muj_30plus, 2),
    `N Gratuidad (total)`         = n_grat_total,
    `% Gratuidad (total)`         = round(pct_grat_total, 2),
    `N 30+ con Gratuidad`         = n_grat_30plus,
    `% Gratuidad entre 30+`       = round(pct_grat_30plus, 2)
  )
  
  # Columnas extra para 2024–2025
  if (yr >= 2024) {
    n_muj30_grat   <- sum(d_30plus$es_mujer == 1L & d_30plus$tiene_gratuidad == 1L,
                          na.rm = TRUE)
    pct_muj30_grat <- if (n_muj_30plus > 0) n_muj30_grat / n_muj_30plus * 100 else NA_real_
    
    res <- res %>%
      mutate(
        `N mujeres 30+ con Gratuidad` = n_muj30_grat,
        `% Gratuidad entre muj. 30+`  = round(pct_muj30_grat, 2)
      )
  }
  
  res
}

# -----------------------------------------------------------------------------
# 3. APLICAR FUNCIÓN A CADA AÑO × GRUPO
# -----------------------------------------------------------------------------

resultados_lista <- lapply(years, function(yr) {
  
  d_all <- datos[[as.character(yr)]]
  
  lapply(names(GRUPOS), function(g) {
    # Filtrar si el grupo tiene restricción institucional
    d_sub <- if (is.null(GRUPOS[[g]])) {
      d_all
    } else {
      filter(d_all, grupo_inst == g)
    }
    calcular_stats(d_sub, yr, g)
  })
})

tabla_final <- bind_rows(unlist(resultados_lista, recursive = FALSE)) %>%
  # Orden: Total primero, luego Universidad, luego CFT+IP
  mutate(Grupo = factor(Grupo, levels = c("Total", "Universidad", "CFT+IP"))) %>%
  arrange(Año, Grupo)

# -----------------------------------------------------------------------------
# 4. IMPRIMIR RESULTADOS
# -----------------------------------------------------------------------------

sep  <- strrep("─", 80)
sep2 <- strrep("═", 80)

cat("\n", sep2, "\n", sep = "")
cat("  ANÁLISIS PRIMER AÑO ED. SUPERIOR – CHILE (2014, 2015, 2024, 2025)\n")
cat("  Desagregación: Total | Universidades | CFT+IP\n")
cat(sep2, "\n\n", sep = "")

cat(sep, "\n")
cat("TABLA 1 · % estudiantes de 1er año con 30+ años\n")
cat("  (denominador = estudiantes con edad informada; excluye Sin Información)\n")
cat(sep, "\n")
tabla_final %>%
  select(Año, Grupo,
         `N con edad informada`,
         `N 30+ años`,
         `% 30+`) %>%
  print(n = Inf)

cat("\n", sep, "\n", sep = "")
cat("TABLA 2 · % femenino entre estudiantes de 1er año de 30+ años\n")
cat(sep, "\n")
tabla_final %>%
  select(Año, Grupo,
         `N 30+ años`,
         `N mujeres 30+`,
         `% mujeres entre 30+`) %>%
  print(n = Inf)

cat("\n", sep, "\n", sep = "")
cat("TABLA 3 · Gratuidad y 30+ en estudiantes de primer año\n")
cat(sep, "\n")
tabla_final %>%
  select(Año, Grupo,
         `N total 1er año`,
         `N Gratuidad (total)`,
         `% Gratuidad (total)`,
         `N con edad informada`,
         `N 30+ años`,
         `% 30+`,
         `N 30+ con Gratuidad`,
         `% Gratuidad entre 30+`) %>%
  print(n = Inf, width = Inf)

cat("\n", sep, "\n", sep = "")
cat("TABLA 4 · % Gratuidad entre mujeres de 30+ (sólo 2024–2025)\n")
cat(sep, "\n")
tabla_final %>%
  filter(Año >= 2024) %>%
  select(Año, Grupo,
         `N mujeres 30+`,
         `N mujeres 30+ con Gratuidad`,
         `% Gratuidad entre muj. 30+`) %>%
  print(n = Inf)

cat("\n", sep2, "\n", sep = "")
cat("  TABLA RESUMEN COMPLETA\n")
cat(sep2, "\n\n", sep = "")
print(tabla_final, n = Inf, width = Inf)

# -----------------------------------------------------------------------------
# EXPORTAR A CSV
# -----------------------------------------------------------------------------
write_csv(tabla_final,
           file.path(base_path, "Codigo", "resultados_primer_anio.csv"))
 cat("\n✓ Resultados exportados a Codigo/resultados_primer_anio.csv\n")
 