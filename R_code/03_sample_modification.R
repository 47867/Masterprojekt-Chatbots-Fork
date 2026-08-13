library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

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
  "Keine vollständige Einwilligung zur Chatlogspende",
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


# sample_table <- df_sample_reasons %>%
#   count(Ausschlussgrund, .drop = FALSE, name = "N") %>%
#   mutate(
#     Prozent = round(100 * N / nrow(df_sample), 1)
#   ) %>%
#   filter(N > 0) %>%
#   bind_rows(
#     tibble(
#       Ausschlussgrund = factor(
#         "Gesamtstichprobe",
#         levels = c("Gesamtstichprobe", reason_levels)
#       ),
#       N = nrow(df_sample),
#       Prozent = 100
#     ),
#     .
#   ) %>%
#   mutate(
#     Ausschlussgrund = as.character(Ausschlussgrund)
#   )
#
# sample_table


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
    complete.cases(DE01, DE02, DE05, DE06)
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
