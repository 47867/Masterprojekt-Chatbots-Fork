library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)
library(gtsummary)

gtsummary::theme_gtsummary_language(
  language = "de",
  decimal.mark = ",",
  big.mark = "."
)

global_digits <- 2

# # Voller Datensatz (nicht öffentlich)
# df_sample <- read_csv(
#   here::here("data", "processed", "all_raw_full.csv")
# ) |>
#   select(-c(CH02s, CH06s, CH07s, CH08s, CH09s, CO04_BID))
#
#
# # Bereinigter Datensatz der finalen Stichprobe
# df_sample_excluded <- read_csv(
#   here::here("data", "processed", "excluded_final_vars.csv")
# )
#
# # IDs der ausgeschlossenen Personen
# ids_excluded <- df_sample_excluded %>%
#   pull(id)
#
# # Variable, ob die Person in der finalen Stichprobe ist oder nicht
# df_sample <- df_sample %>%
#   mutate(
#     final_sample = ifelse(CASE %in% ids_excluded, 0, 1)
#   )
#
# write_csv(
#   df_sample,
#   here::here("data", "raw", "analysis_data.csv")
# )

# Anonymisierten Datensatz einlesen
df_sample <- read_csv(
  here::here("data", "raw", "analysis_data.csv")
)

df_sample <- df_sample |>
  mutate(
    DE02 = DE02 + 15 # Alter in Jahren
  )

df_sample <- df_sample %>%
  mutate(
    exclusion_reason = case_when(
      final_sample == 1 ~ "Finale Analysestichprobe",

      is.na(CH01) | CH01 != 5 ~
        "Keine Einwilligung zur Teilnahme",

      is.na(FINISHED) | FINISHED == FALSE ~
        "Fragebogen nicht abgeschlossen",

      STATUS == "screenout" ~
        "Durch Screeningfragen ausgeschlossen",

      is.na(CO03) | CO03 != 4 ~
        "Keine Einwilligung zur Chatlogspende",

      is.na(n_chats_valid) | n_chats_valid != 5 ~
        "Nicht alle erforderlichen Chats hochgeladen",

      TRUE ~
        "Sonstiger Ausschlussgrund"
    )
  )

df_sample %>%
  count(exclusion_reason) %>%
  mutate(
    Prozent = round(100 * n / sum(n), digits = global_digits)
  )

reason_levels <- c(
  "Keine Einwilligung zur Teilnahme",
  "Fragebogen nicht abgeschlossen",
  "Ausschluss durch Screeningfragen",
  "Keine Einwilligung zur Chatlogspende",
  "Nicht alle erforderlichen Chats hochgeladen",
  "Sonstiger Ausschlussgrund",
  "Finale Analysestichprobe"
)

df_sample_reasons <- df_sample |>
  mutate(
    Ausschlussgrund = case_when(
      is.na(CO03) | CO03 != 4 ~
        "Keine Einwilligung zur Teilnahme",

      is.na(FINISHED) | FINISHED == FALSE ~
        "Fragebogen nicht abgeschlossen",

      STATUS == "screenout" ~
        "Ausschluss durch Screeningfragen",

      is.na(CH01) | CH01 != 5 ~
        "Keine Einwilligung zur Chatlogspende",

      is.na(n_chats_valid) | n_chats_valid != 5 ~
        "Nicht alle erforderlichen Chats hochgeladen",

      final_sample == 1 ~
        "Finale Analysestichprobe",

      TRUE ~
        "Sonstiger Ausschlussgrund"
    ),

    Ausschlussgrund = factor(
      Ausschlussgrund,
      levels = reason_levels
    )
  )

sample_profile_data <- df_sample_reasons |>
  filter(
    final_sample == 1 |
      (
        final_sample == 0 &
          complete.cases(
            DE01,
            DE02,
            DE05,
            DE06
          )
      )
  ) |>
  mutate(
    sample_group = factor(
      final_sample,
      levels = c(1, 0),
      labels = c(
        "Analysestichprobe",
        "Ausgeschlossene Fälle mit vollständigen Angaben"
      )
    ),

    age = DE02,

    survey_duration = TIME_SUM / 60, # Dauer in Minuten

    gender = factor(
      DE01,
      levels = c(1, 2),
      labels = c(
        "Männlich",
        "Weiblich"
      )
    ),

    degree = factor(
      DE05,
      levels = c(1, 2, 3),
      labels = c(
        "Bachelor",
        "Master",
        "Staatsexamen oder Lehramtsprüfung"
      )
    ),

    field = droplevels(
      factor(
        DE06,
        levels = 1:11,
        labels = c(
          "Geistes- und Kulturwissenschaften",
          "Sprach- und Literaturwissenschaften",
          "Sozialwissenschaften",
          "Rechts- und Wirtschaftswissenschaften",
          "Mathematik und Naturwissenschaften",
          "Medizin und Gesundheitswissenschaften",
          "Ingenieurwissenschaften",
          "Informatik",
          "Kunst, Musik und Gestaltung",
          "Lehramt",
          "Anderes Fach"
        )
      )
    ),

    ai_experience = NU01,

    use_frequency = SC05,

    info_literacy_where = NU04_01,

    info_literacy_how = NU04_02,

    social_desirability = rowMeans(
      cbind(
        sd_argument,
        sd_stressed,
        sd_listening,
        6 - sd_advantage,
        6 - sd_litter,
        6 - sd_help
      ),
      na.rm = FALSE
    )
  ) |>
  select(
    sample_group,
    age,
    survey_duration,
    gender,
    degree,
    field,
    ai_experience,
    use_frequency,
    info_literacy_where,
    info_literacy_how,
    social_desirability
  )


sample_table <- df_sample_reasons |>
  count(
    Ausschlussgrund,
    .drop = FALSE,
    name = "N"
  ) |>
  filter(N > 0) |>
  mutate(
    Ausschlussgrund = as.character(Ausschlussgrund),
    Prozent = 100 * N / nrow(df_sample)
  ) |>
  tibble::add_row(
    Ausschlussgrund = "Gesamtstichprobe",
    N = nrow(df_sample),
    Prozent = 100,
    .before = 1
  )

sample_table



table_sample_comparison <- sample_profile_data |>
  tbl_summary(
    by = sample_group,

    type = list(
      c(
        age,
        survey_duration,
        ai_experience,
        use_frequency,
        info_literacy_where,
        info_literacy_how,
        social_desirability
      ) ~ "continuous"
    ),

    statistic = list(
      all_continuous() ~
        "{median} ({p25}; {p75})",

      all_categorical() ~
        "{n} ({p}%)"
    ),

    digits = list(
      all_continuous() ~ global_digits,
      all_categorical() ~ c(0, 1)
    ),

    label = list(
      age ~ "Alter in Jahren",
      survey_duration ~ "Dauer der Befragung in Minuten",
      gender ~ "Geschlecht",
      degree ~ "Angestrebter Abschluss",
      field ~ "Studienrichtung",
      ai_experience ~ "KI-Erfahrung (1–5)",
      use_frequency ~ "Nutzungshäufigkeit (2–6)",
      info_literacy_where ~
        "Informationskompetenz: geeignete Quellen finden (1–5)",
      info_literacy_how ~
        "Informationskompetenz: Anfragen formulieren (1–5)",
      social_desirability ~
        "Soziale Erwünschtheit (1–5)"
    ),

    missing = "ifany",
    missing_text = "Fehlend"
  ) |>
  modify_header(
    label ~ "**Charakteristik**",
    all_stat_cols() ~ "**{level}**, N = {n}"
  )

table_sample_comparison



demographic_n <- df_sample_reasons |>
  mutate(
    sample_group = if_else(
      final_sample == 1,
      "Analysestichprobe",
      "Ausgeschlossene Fälle"
    )
  ) |>
  group_by(sample_group) |>
  summarise(
    N_gesamt = n(),
    n_alter = sum(!is.na(DE02)),
    n_geschlecht = sum(!is.na(DE01)),
    n_abschluss = sum(!is.na(DE05)),
    n_studienfach = sum(!is.na(DE06)),
    n_demografie_vollständig = sum(
      complete.cases(DE02, DE01, DE05, DE06)
    ),
    .groups = "drop"
  )

demographic_n



sample_comparison <- df_sample_reasons |>
  mutate(
    sample_group = factor(
      final_sample,
      levels = c(0, 1),
      labels = c(
        "Ausgeschlossene Fälle",
        "Analysestichprobe"
      )
    )
  ) |>
  filter(
    complete.cases(DE01, DE02, DE05) & DE06 %in% c(1:11)
  ) |>
  group_by(sample_group) |>
  summarise(
    N = n(),

    mean_age = mean(DE02),

    female_percent = mean(DE01 == 2) * 100,

    bachelor_percent = mean(DE05 == 1) * 100,
    master_percent = mean(DE05 == 2) * 100,

    social_science_percent = mean(DE06 == 3) * 100,

    .groups = "drop"
  )

sample_comparison



sample_differences <- sample_comparison |>
  summarise(
    age_difference =
      mean_age[sample_group == "Analysestichprobe"] -
      mean_age[sample_group == "Ausgeschlossene Fälle"],

    female_difference =
      female_percent[sample_group == "Analysestichprobe"] -
      female_percent[sample_group == "Ausgeschlossene Fälle"],

    bachelor_difference =
      bachelor_percent[sample_group == "Analysestichprobe"] -
      bachelor_percent[sample_group == "Ausgeschlossene Fälle"],

    master_difference =
      master_percent[sample_group == "Analysestichprobe"] -
      master_percent[sample_group == "Ausgeschlossene Fälle"],

    field_social_difference =
      social_science_percent[sample_group == "Analysestichprobe"] -
      social_science_percent[sample_group == "Ausgeschlossene Fälle"]
  )

sample_differences



## Export in den Tabellenordner

level_rows <-
  table_sample_comparison$table_body$row_type %in%
  c("level", "missing")

sample_comparison_export <- table_sample_comparison |>
  gtsummary::as_tibble(
    col_labels = FALSE
  ) |>
  mutate(
    label = stringr::str_remove_all(
      label,
      "__"
    ),

    label = if_else(
      level_rows,
      paste0(
        "\u00A0\u00A0\u00A0",
        label
      ),
      label
    )
  ) |>
  rename(
    Charakteristik = label,
    "Analysestichprobe (N = 21)" = stat_1,
    "Ausgeschlossene Fälle (N = 17)" = stat_2
  )

readr::write_csv(
  sample_comparison_export,
  here::here(
    "tabs",
    "T21_sample_comparison.csv"
  ),
  na = ""
)
