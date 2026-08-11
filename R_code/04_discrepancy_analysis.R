library(here)
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

df_analysis <- read_csv(
  here("data", "processed", "analysis_dataset.csv"),
  show_col_types = FALSE
)

global_digits <- 2


### Label vergeben

SA_cols <- c(
  "SA_info",
  "SA_schreiben",
  "SA_praktisch",
  "SA_technisch",
  "SA_lernen"
)

BE_cols <- c(
  "BE_info",
  "BE_schreiben",
  "BE_praktisch",
  "BE_technisch",
  "BE_lernen"
)

D_cols <- c(
  "D_info",
  "D_schreiben",
  "D_praktisch",
  "D_technisch",
  "D_lernen"
)

##
df_analysis <- df_analysis |>
  mutate(
    SA_krit_code = case_when(
      crit_visible_chat %in% c(1, 2) ~ 0L,
      crit_visible_chat %in% c(4, 5) ~ 1L,
      TRUE ~ NA_integer_
    )
  )

df_analysis <- df_analysis |>
  mutate(
    K_Diskrepanz =
      Modus_Kritik - SA_krit_code,

    K_Diskrepanz_Label = case_when(
      K_Diskrepanz == -1 ~ "falsches positiv",
      K_Diskrepanz == 0  ~ "korrekt",
      K_Diskrepanz == 1  ~ "falsches negativ",
      TRUE ~ NA_character_
    )
  )



### Long-format

task_long <- bind_rows(
  df_analysis |>
    transmute(
      id,
      task = "Informationssuche und Verständnis",
      self_report = SA_info,
      observed = BE_info,
      difference = D_info
    ),

  df_analysis |>
    transmute(
      id,
      task = "Schreiben und Textarbeit",
      self_report = SA_schreiben,
      observed = BE_schreiben,
      difference = D_schreiben
    ),

  df_analysis |>
    transmute(
      id,
      task = "Praktische Unterstützung und Strukturierung",
      self_report = SA_praktisch,
      observed = BE_praktisch,
      difference = D_praktisch
    ),

  df_analysis |>
    transmute(
      id,
      task = "Technische und analytische Unterstützung",
      self_report = SA_technisch,
      observed = BE_technisch,
      difference = D_technisch
    ),

  df_analysis |>
    transmute(
      id,
      task = "Lernen und Prüfungsvorbereitung",
      self_report = SA_lernen,
      observed = BE_lernen,
      difference = D_lernen
    )
)

## Reihenfolge festlegen

task_levels <- c(
  "Informationssuche und Verständnis",
  "Schreiben und Textarbeit",
  "Praktische Unterstützung und Strukturierung",
  "Technische und analytische Unterstützung",
  "Lernen und Prüfungsvorbereitung"
)

task_long <- task_long |>
  mutate(
    task = factor(
      task,
      levels = task_levels
    )
  )



## Nutzungsarten Chatlogs und Survey

aggregate_comparison <- task_long |>
  group_by(task) |>
  summarise(
    Survey = mean(
      self_report,
      na.rm = TRUE
    ),

    Chatlogs = mean(
      observed,
      na.rm = TRUE
    ),

    Differenz = Survey - Chatlogs,

    .groups = "drop"
  ) |>
  arrange(Differenz)

aggregate_comparison

## Vergleichstabelle erzeugen

task_summary <- task_long |>
  group_by(task) |>
  summarise(
    N = n(),

    mean_self_report = mean(self_report),
    sd_self_report = sd(self_report),

    mean_observed = mean(observed),
    sd_observed = sd(observed),

    mean_difference = mean(difference),
    median_difference = median(difference),

    mean_absolute_difference = mean(abs(difference)),

    exact_agreement_n = sum(abs(difference) < 1e-10),
    exact_agreement_percent =
      100 * exact_agreement_n / N,

    .groups = "drop"
  )

task_summary
## Zusammenfassung

task_agreement_summary <- task_long |>
  group_by(task) |>
  summarise(
    N = sum(!is.na(difference)),

    exact_agreement_n = sum(
      dplyr::near(difference, 0),
      na.rm = TRUE
    ),

    exact_agreement_percent = mean(
      dplyr::near(difference, 0),
      na.rm = TRUE
    ) * 100,

    mean_absolute_difference_pp = mean(
      abs(difference),
      na.rm = TRUE
    ) * 100,

    .groups = "drop"
  ) |>
  arrange(desc(exact_agreement_percent))

task_agreement_summary

## Personenbezogenes Gesamtdiskrepanz

person_discrepancy <- task_long |>
  group_by(id) |>
  summarise(
    total_variation =
      0.5 * sum(abs(difference)),

    mean_absolute_difference =
      mean(abs(difference)),

    largest_difference =
      max(abs(difference)),

    .groups = "drop"
  )

person_discrepancy |>
  summarise(
    N = n(),
    mean = mean(total_variation),
    sd = sd(total_variation),
    median = median(total_variation),
    minimum = min(total_variation),
    maximum = max(total_variation)
  )

## Visualisierung

task_means_long <- task_summary |>
  dplyr::select(
    task,
    mean_self_report,
    mean_observed
  ) |>
  tidyr::pivot_longer(
    cols = c(
      mean_self_report,
      mean_observed
    ),
    names_to = "source",
    values_to = "mean"
  ) |>
  dplyr::mutate(
    source = dplyr::recode(
      source,
      mean_self_report = "Selbstauskunft",
      mean_observed = "Chatlogs"
    )
  )

task_means_long

plot_task_means <- ggplot(
  task_means_long,
  aes(
    x = mean,
    y = task,
    color = source
  )
) +
  geom_line(
    aes(group = task),
    color = "grey70",
    linewidth = 1
  ) +
  geom_point(size = 3) +
  scale_x_continuous(
    labels = label_percent(),
    limits = c(0, 0.40)
  ) +
  labs(
    x = "Mittlerer Anteil",
    y = NULL,
    color = "Datenquelle"
  ) +
  theme_minimal()

plot_task_means


### Individuelle Differenzen

task_long_plot <- task_long |>
  mutate(
    task = forcats::fct_reorder(
      task,
      difference,
      .fun = mean,
      .na_rm = TRUE,
      .desc = TRUE
    )
  )

plot_task_differences <- ggplot(
  task_long_plot,
  aes(
    x = difference,
    y = task
  )
) +
  geom_vline(
    xintercept = 0,
    linetype = "dashed",
    color = "grey50"
  ) +
  geom_violin(
    orientation = "y",
    scale = "width",
    trim = TRUE,
    adjust = 1.1,
    width = 0.85,
    alpha = 0.1
  ) +
  geom_boxplot(
    orientation = "y",
    width = 0.14,
    outlier.shape = NA,
    fill = "white",
    color = "black",
    alpha = 0.9,
    linewidth = 0.4
  ) +
  # Mittelwert als Raute
  stat_summary(
    orientation = "y",
    fun = mean,
    geom = "point",
    shape = 23,
    size = 2.8,
    color = "black",
    stroke = 0.4
  ) +
  scale_y_discrete(
    labels = \(x) stringr::str_wrap(x, width = 28)
  ) +
  scale_x_continuous(
    labels = scales::label_percent(),
    breaks = seq(-0.6, 0.4, 0.2),
    limits = c(-0.62, 0.42),
    expand = expansion(mult = c(0.01, 0.02))
  ) +
  labs(
    x = "Selbstauskunft minus beobachteter Anteil",
    y = NULL,
    title = "Individuelle Differenzen zwischen Selbstauskunft und beobachtetem Anteil",
    subtitle = "Mittelwert als Raute, Boxplot zeigt Median und Quartile, Violinplot zeigt Dichte",
    caption = paste(
      "Eigene Erhebung\n N =",
      n_distinct(task_long_plot$id)
      )
  ) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid.minor = element_blank(),
    axis.text.y = element_text(
      size = 9,
      lineheight = 0.95
    ),
    axis.subtitle.x = element_text(
      size = 5,
      margin = margin(t = 4)
    ),
    axis.title.x = element_text(
      size = 10,
      margin = margin(t = 8)
    ),
    plot.margin = margin(
      t = 5,
      r = 10,
      b = 5,
      l = 5
    )
  )

plot_task_differences


### Interaktionsstil

sentiment_results <- df_analysis |>
  transmute(
    id,

    self_report = factor(
      SA_sent_code,
      levels = c(-1, 0, 1),
      labels = c(
        "Freundlich",
        "Neutral",
        "Unfreundlich"
      )
    ),

    observed = factor(
      Modus_Sentiment,
      levels = c(-1, 0, 1),
      labels = c(
        "Freundlich",
        "Neutral",
        "Unfreundlich"
      )
    ),

    discrepancy = factor(
      S_Diskrepanz_Label,
      levels = c(
        "unfreundlicher",
        "korrekt",
        "freundlicher"
      )
    )
  )

# Kreuztabelle
sentiment_cross_table <- sentiment_results |>
  count(self_report, observed) |>
  complete(
    self_report,
    observed,
    fill = list(n = 0)
  )

sentiment_cross_table

# Zusammenfassung Kreuztabelle

sentiment_summary <- sentiment_results |>
  count(discrepancy, name = "N") |>
  mutate(
    Prozent = 100 * N / sum(N)
  )

sentiment_summary

### Kritisches Prüfen

critical_results <- df_analysis |>
  transmute(
    id,

    self_report = factor(
      SA_krit_code,
      levels = c(0, 1),
      labels = c("Nein", "Ja")
    ),

    observed = factor(
      Modus_Kritik,
      levels = c(0, 1),
      labels = c("Nein", "Ja")
    ),

    discrepancy = factor(
      K_Diskrepanz_Label,
      levels = c(
        "falsches positiv",
        "korrekt",
        "falsches negativ"
      ),
      labels = c(
        "Nur in Selbstauskunft",
        "Übereinstimmung",
        "Nur in Chatlogs"
      )
    )
  )

### Kreuztabelle
critical_cross_table <- critical_results |>
  count(self_report, observed) |>
  complete(
    self_report,
    observed,
    fill = list(n = 0)
  )

critical_cross_table <- critical_cross_table |>
  mutate(
    percent = n / 21 * 100
  )

critical_cross_table


### Zusammenfassung der Kreuztabelle
critical_summary <- critical_results |>
  count(discrepancy, name = "N") |>
  mutate(
    Prozent = 100 * N / sum(N)
  )

critical_summary


# Nutzungsarten-Diskrepanzen nach Charakteristiken

df_discrepancy <- df_analysis |>
  mutate(
    discrepancy_total = 0.5 * (
      abs(D_info) +
        abs(D_schreiben) +
        abs(D_praktisch) +
        abs(D_technisch) +
        abs(D_lernen)
    ),

    gender_label = factor(
      gender,
      levels = c(1, 2),
      labels = c("Männlich", "Weiblich")
    )
  )


### Kontinuierliche Merkmale

continuous_associations <- df_discrepancy |>
  select(
    discrepancy_total,
    age,
    ai_experience,
    social_desir_mean
  ) |>
  pivot_longer(
    cols = -discrepancy_total,
    names_to = "variable",
    values_to = "value"
  ) |>
  mutate(
    variable = recode(
      variable,
      age = "Alter",
      ai_experience = "KI-Erfahrung",
      social_desir_mean = "Soziale Erwünschtheit"
    )
  )

association_summary <- continuous_associations |>
  group_by(variable) |>
  summarise(
    N = sum(complete.cases(value, discrepancy_total)),

    rho = cor(
      value,
      discrepancy_total,
      method = "spearman",
      use = "complete.obs"
    ),

    p_value = cor.test(
      value,
      discrepancy_total,
      method = "spearman",
      exact = FALSE
    )$p.value,

    .groups = "drop"
  )

association_summary

# Zusammenhänge als Plot

plot_personal_associations <- ggplot(
  continuous_associations,
  aes(
    x = value,
    y = discrepancy_total
  )
) +
  geom_point(
    size = 2.2,
    alpha = 0.6
  ) +
  geom_jitter(
    width = 0.2,
    height = 0.2,
    alpha = 0.6
  ) +
  geom_smooth(
    method = "lm",
    formula = y ~ x,
    se = TRUE,
    alpha = 0.15,
    linewidth = 0.7
  ) +
  facet_wrap(
    ~ variable,
    scales = "free_x",
    nrow = 3
  ) +
  scale_y_continuous(
    labels = scales::label_percent()
  ) +
  labs(
    title = "Zusammenhänge zwischen persönlichen Merkmalen und Gesamtausmaß der Diskrepanz",
    subtitle = "Linie zeigt linearen Trend mit 95%-Konfidenzintervall",
    caption = paste(
      "Eigene Erhebung\n N =",
      n_distinct(df_discrepancy$id)
    ),
    x = NULL,
    y = "Gesamtausmaß der Diskrepanz"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    panel.grid.minor = element_blank()
  )

plot_personal_associations

## Geschlecht vergleichen

gender_summary <- df_discrepancy |>
  group_by(gender_label) |>
  summarise(
    N = n(),
    mean_discrepancy = mean(discrepancy_total, na.rm = TRUE),
    median_discrepancy = median(discrepancy_total, na.rm = TRUE),
    sd_discrepancy = sd(discrepancy_total, na.rm = TRUE),
    .groups = "drop"
  )

gender_summary

gender_mean_difference <- gender_summary |>
  summarise(
    difference =
      mean_discrepancy[gender_label == "Männlich"] -
      mean_discrepancy[gender_label == "Weiblich"]
  ) |>
  pull(difference)

gender_test <- wilcox.test(
  discrepancy_total ~ gender_label,
  data = df_discrepancy,
  exact = FALSE
)

gender_test


# Geschlecht plot

plot_gender_discrepancy <- ggplot(
  df_discrepancy,
  aes(
    x = gender_label,
    y = discrepancy_total
  )
) +
  geom_boxplot(
    width = 0.45,
    outlier.shape = NA,
    fill = "grey90"
  ) +
  stat_summary(
    fun = mean,
    geom = "point",
    shape = 23,
    size = 2.8
  ) +
  scale_y_continuous(
    labels = scales::label_percent()
  ) +
  labs(
    title = "Gesamtausmaß der Diskrepanz nach Geschlecht",
    subtitle = "Mittelwert als Raute, Boxplot zeigt Median und Quartile",
    caption = paste(
      "Eigene Erhebung\n N =",
      n_distinct(df_discrepancy$id)
    ),
    x = NULL,
    y = "Gesamtausmaß der Diskrepanz"
  ) +
  theme_minimal(base_size = 10) +
  coord_flip()

plot_gender_discrepancy


# Kritisches-Prüfen-Diskrepanzen nach Charakteristiken

df_characteristics <- df_analysis |>
  mutate(
    critical_group = factor(
      if_else(
        K_Diskrepanz == 0,
        "Übereinstimmung",
        "Diskrepanz"
      ),
      levels = c("Übereinstimmung", "Diskrepanz")
    ),

    interaction_group = factor(
      if_else(
        S_Diskrepanz == 0,
        "Übereinstimmung",
        "Diskrepanz"
      ),
      levels = c("Übereinstimmung", "Diskrepanz")
    ),

    gender_label = factor(
      gender,
      levels = c(1, 2),
      labels = c("Männlich", "Weiblich")
    )
  )

# long format
characteristics_long <- df_characteristics |>
  select(
    id,
    critical_group,
    interaction_group,
    ai_experience,
    age,
    social_desir_mean,
    gender_label
  ) |>
  pivot_longer(
    cols = c(
      critical_group,
      interaction_group
    ),
    names_to = "dimension",
    values_to = "agreement"
  ) |>
  mutate(
    dimension = recode(
      dimension,
      critical_group = "Kritisches Prüfen",
      interaction_group = "Interaktionsstil"
    )
  )

# deskriptive kennwerte

characteristics_summary <- characteristics_long |>
  pivot_longer(
    cols = c(
      ai_experience,
      age,
      social_desir_mean
    ),
    names_to = "characteristic",
    values_to = "value"
  ) |>
  mutate(
    characteristic = recode(
      characteristic,
      ai_experience = "KI-Erfahrung",
      age = "Alter",
      social_desir_mean = "Soziale Erwünschtheit"
    )
  ) |>
  group_by(
    dimension,
    agreement,
    characteristic
  ) |>
  summarise(
    N = sum(!is.na(value)),
    Mittelwert = mean(value, na.rm = TRUE),
    SD = sd(value, na.rm = TRUE),
    Median = median(value, na.rm = TRUE),
    IQR = IQR(value, na.rm = TRUE),
    .groups = "drop"
  )

characteristics_summary

## wilcoxon

continuous_tests <- characteristics_long |>
  pivot_longer(
    cols = c(
      ai_experience,
      age,
      social_desir_mean
    ),
    names_to = "characteristic",
    values_to = "value"
  ) |>
  mutate(
    characteristic = recode(
      characteristic,
      ai_experience = "KI-Erfahrung",
      age = "Alter",
      social_desir_mean = "Soziale Erwünschtheit"
    )
  ) |>
  group_by(dimension, characteristic) |>
  summarise(
    p_value = wilcox.test(
      value ~ agreement,
      exact = FALSE
    )$p.value,
    .groups = "drop"
  ) |>
  mutate(
    p_adjusted = p.adjust(
      p_value,
      method = "BH"
    )
  )

continuous_tests

# Geschlechterunterschiede

gender_summary_sentiment_critical <- characteristics_long |>
  count(
    dimension,
    gender_label,
    agreement
  ) |>
  group_by(dimension, gender_label) |>
  mutate(
    percent = n / sum(n) * 100
  ) |>
  ungroup()

gender_summary_sentiment_critical


# Fisher test

gender_tests <- characteristics_long |>
  filter(!is.na(gender_label)) |>
  group_by(dimension) |>
  summarise(
    p_value = fisher.test(
      table(agreement, gender_label)
    )$p.value,
    .groups = "drop"
  )

gender_tests


# visualisierung

plot_characteristics <- characteristics_long |>
  pivot_longer(
    cols = c(
      ai_experience,
      age,
      social_desir_mean
    ),
    names_to = "characteristic",
    values_to = "value"
  ) |>
  mutate(
    characteristic = recode(
      characteristic,
      ai_experience = "KI-Erfahrung",
      age = "Alter",
      social_desir_mean = "Soziale Erwünschtheit"
    )
  ) |>
  ggplot(
    aes(
      x = agreement,
      y = value,
      fill = agreement
    )
  ) +
  geom_boxplot(
    width = 0.55,
    outlier.shape = NA,
    alpha = 0.65
  ) +
  geom_jitter(
    width = 0.10,
    alpha = 0.75
  ) +
  facet_grid(
    characteristic ~ dimension,
    scales = "free_y"
  ) +
  labs(
    x = NULL,
    y = NULL,
    fill = NULL,
    caption = "Daten: Eigene Erhebung; N = 21"
  ) +
  theme_minimal() +
  theme(
    legend.position = "none",
    axis.text.x = element_text(
      angle = 25,
      hjust = 1
    )
  ) +
  coord_flip()

plot_characteristics

## spearman corr

association_summary_critical_style <- characteristics_long |>
  mutate(
    discrepancy = if_else(
      agreement == "Diskrepanz",
      1,
      0
    )
  ) |>
  pivot_longer(
    cols = c(
      ai_experience,
      age,
      social_desir_mean
    ),
    names_to = "characteristic",
    values_to = "value"
  ) |>
  filter(
    !is.na(value),
    !is.na(discrepancy)
  ) |>
  mutate(
    characteristic = recode(
      characteristic,
      ai_experience = "KI-Erfahrung",
      age = "Alter",
      social_desir_mean = "Soziale Erwünschtheit"
    )
  ) |>
  group_by(dimension, characteristic) |>
  summarise(
    N = n(),

    rho = cor(
      value,
      discrepancy,
      method = "spearman"
    ),

    p_value = cor.test(
      value,
      discrepancy,
      method = "spearman",
      exact = FALSE
    )$p.value,

    .groups = "drop"
  ) |>
  mutate(
    p_adjusted = p.adjust(
      p_value,
      method = "BH"
    )
  ) |>
  arrange(dimension, rho)

association_summary_critical_style

### kombinierte tabelle

association_table <- bind_rows(
  association_summary |>
    transmute(
      Dimension = "Informationsnutzung",
      Merkmal = variable,
      N,
      rho,
      p_value
    ),

  association_summary_critical_style |>
    transmute(
      Dimension = dimension,
      Merkmal = characteristic,
      N,
      rho,
      p_value
    )
) |>
  ungroup() |>
  mutate(
    # Auf Basis der ungerundeten Werte berechnen
    p_adjusted = p.adjust(
      p_value,
      method = "BH"
    )
  )

association_table
