##########################################
### Datenanalyse Skript###################
##########################################
# Projektwurzel wird über die .Rproj-Datei gefunden - funktioniert im interaktiven
# Skript wie auch beim Quarto-Render von index.qmd
# if (!requireNamespace("here", quietly = TRUE)) install.packages("here")
library(here)

data_path   <- file.path(
  here::here("data", "processed", "analysis_dataset.rds")
)

plot_dir    <- file.path(base_path, "plots")
setwd(base_path)
#Daten laden

data <- readRDS(data_path)

############################
#Packete installieren######
###########################

pakete <- c("cluster", "ggplot2", "patchwork", "labelled", "scales", "knitr")

for (p in pakete) {
  if (!requireNamespace(p, quietly = TRUE)) {
    # Beim Quarto-Render (nicht interaktiv) nicht stillschweigend installieren:
    # der Download bricht sonst mitten im Rendern ab
    if (!interactive()) {
      stop(sprintf("Paket '%s' fehlt in der Projekt-Library. In RStudio ausfuehren: renv::install('%s'); renv::snapshot()", p, p))
    }
    install.packages(p)
  }
  library(p, character.only = TRUE)
}

# Ausgabeordner für Grafiken
dir.create("plots", showWarnings = FALSE)
SEED <- 404

#######################################################
# Design-System: Farben, Theme und Beschriftungen######
#######################################################
# Validierte Palette (CVD-sicher, feste Slot-Reihenfolge - nie umsortieren)
PAL_CAT <- c("#2a78d6", "#1baf7a", "#eda100", "#008300",
             "#4a3aa7", "#e34948", "#e87ba4", "#eb6834")
BLUE      <- PAL_CAT[1]                       # Einzelserien-Farbe (Slot 1)
INK       <- "#0b0b0b"                        # Primaertext
INK_2     <- "#52514e"                        # Sekundaertext
INK_MUTED <- "#898781"                        # Achsen/gedaempft
GRID      <- "#e1e0d9"                        # Hairline-Gitter
AXISLINE  <- "#c3c2b7"

# Divergierend (Richtung einer Abweichung): blau <-> rot, neutrale Mitte grau
DIV_LOW  <- "#2a78d6"
DIV_MID  <- "#f0efec"
DIV_HIGH <- "#e34948"

# Feste Farben fuer die kategorialen Diskrepanz-Level
COL_DISKREPANZ <- c("unfreundlicher"   = DIV_LOW,
                    "freundlicher"     = DIV_HIGH,
                    "falsches positiv" = DIV_LOW,
                    "falsches negativ" = DIV_HIGH,
                    "korrekt"          = INK_MUTED,
                    "uneindeutig"      = AXISLINE)

# Einheitliche Aufgaben-Labels (statt D_info etc.)
TASK_LABELS <- c(D_info      = "Informationssuche",
                 D_schreiben = "Schreiben/Textarbeit",
                 D_praktisch = "Praktische Unterstützung",
                 D_technisch = "Technische Unterstützung",
                 D_lernen    = "Lernen/Prüfungsvorb.")

# Gemeinsames Theme: ruhiges Gitter, klare Titel, keine Deko
theme_projekt <- function(base_size = 12) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title        = element_text(face = "bold", colour = INK, size = base_size + 2),
      plot.subtitle     = element_text(colour = INK_2, margin = margin(b = 8)),
      plot.caption      = element_text(colour = INK_MUTED, size = base_size - 3),
      axis.title        = element_text(colour = INK_2),
      axis.text         = element_text(colour = INK_2),
      panel.grid.major  = element_line(colour = GRID, linewidth = 0.4),
      panel.grid.minor  = element_blank(),
      legend.title      = element_text(colour = INK_2),
      legend.text       = element_text(colour = INK_2),
      plot.title.position = "plot"
    )
}
theme_set(theme_projekt())

#############################################
# Zahlformat: Komma statt Punkt (deutsch)####
#############################################
# Alle Zahlen in Grafiken und Tabellen werden mit Dezimalkomma ausgegeben
# (0,50 statt 0.50). Achsen/Legenden ueber die Label-Funktionen, Texte und
# Tabellen ueber komma_chr()/komma_df().

# Achsen- und Legendenbeschriftungen
lbl_komma   <- scales::label_number(decimal.mark = ",", big.mark = ".")
lbl_prozent <- scales::label_percent(decimal.mark = ",", big.mark = ".")

# Punkt -> Komma in bereits formatierten Zeichenketten (z. B. aus sprintf)
komma_chr <- function(x) gsub(".", ",", as.character(x), fixed = TRUE)

# Zahl -> Zeichenkette mit Komma; drop0trailing haelt die Darstellung
# identisch zur bisherigen (0.5 wird zu 0,5 und nicht zu 0,50)
komma_num <- function(x) {
  vapply(x, function(v) {
    if (is.na(v)) return(NA_character_)
    format(v, decimal.mark = ",", big.mark = "", trim = TRUE,
           scientific = FALSE, drop0trailing = TRUE)
  }, character(1), USE.NAMES = FALSE)
}

# Alle numerischen Spalten eines Data Frames auf Komma-Schreibweise umstellen
komma_df <- function(df) {
  num <- vapply(df, is.numeric, logical(1))
  df[num] <- lapply(df[num], komma_num)
  df
}

# Spalten mit Zahlen (auch bereits als Text mit Komma) rechtsbuendig ausrichten,
# damit die Tabellen trotz Textformatierung wie zuvor gesetzt werden
komma_align <- function(df) {
  ifelse(vapply(df, function(col) {
    if (is.numeric(col)) return(TRUE)
    col <- as.character(col)
    val <- col[!is.na(col)]
    length(val) > 0 && all(grepl("^[-+]?[0-9]+([,.][0-9]+)?%?$", val))
  }, logical(1)), "r", "l")
}

# Hilfsfunktion: NA-Faelle (Gleichstaende) als eigenes Level "uneindeutig"
mit_uneindeutig <- function(x) {
  lev <- c(levels(x), "uneindeutig")
  factor(ifelse(is.na(x), "uneindeutig", as.character(x)), levels = lev)
}

#################################
# 0) STICHPROBENBESCHREIBUNG#####
#############################

# Faktoren mit lesbaren Labels versehen
data$gender_f <- factor(data$gender, levels = c(1,2,3,-1),
                        labels = c("männlich","weiblich","non-binär/divers","keine Angabe"))
data$degree_f <- factor(data$degree, levels = c(1,2,3,4,5),
                        labels = c("Bachelor","Master","Staatsex./Lehramt","Promotion","anderer"))
field_labels <- c("Geistes-/Kultur","Sprach-/Lit.","Sozialwiss.","Recht/Wirtschaft",
                  "Mathe/Naturwiss.","Medizin/Gesundheit","Ingenieurwiss.","Informatik",
                  "Kunst/Musik","Lehramt","anderes")
data$field_f <- factor(data$field, levels = 1:11, labels = field_labels)

p1 <- ggplot(data, aes(x = gender_f)) +
  geom_bar(fill = BLUE, width = 0.6) +
  geom_text(stat = "count", aes(label = after_stat(count)),
            vjust = -0.4, size = 3.5, colour = INK_2) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12)), labels = lbl_komma) +
  labs(title = "Geschlecht", x = NULL, y = "Anzahl") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

p2 <- ggplot(data, aes(x = age)) +
  geom_histogram(binwidth = 1, fill = BLUE, colour = "white", linewidth = 0.5) +
  scale_x_continuous(labels = lbl_komma) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08)), labels = lbl_komma) +
  labs(title = "Alter",
       subtitle = paste0("M = ", komma_num(round(mean(data$age),1)),
                         ", SD = ", komma_num(round(sd(data$age),1))),
       x = "Alter in Jahren", y = "Anzahl")

p3 <- ggplot(data, aes(y = field_f)) +
  geom_bar(fill = BLUE, width = 0.6) +
  geom_text(stat = "count", aes(label = after_stat(count)),
            hjust = -0.4, size = 3.2, colour = INK_2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.12)), labels = lbl_komma) +
  labs(title = "Fächergruppe", x = "Anzahl", y = NULL)

p4 <- ggplot(data, aes(x = degree_f)) +
  geom_bar(fill = BLUE, width = 0.6) +
  geom_text(stat = "count", aes(label = after_stat(count)),
            vjust = -0.4, size = 3.5, colour = INK_2) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12)), labels = lbl_komma) +
  labs(title = "Angestrebter Abschluss", x = NULL, y = "Anzahl") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

combined <- (p1 | p2) / (p3 | p4) +
  plot_annotation(title = paste0("Stichprobenbeschreibung (N = ", nrow(data), ")"),
                  theme = theme(plot.title = element_text(size = 15, face = "bold", colour = INK)))

ggsave("plots/00_stichprobe.png", combined, width = 11, height = 8, dpi = 150, bg = "white")

#descriptives der diskrepan zmaße

## 1a) Mittlere Diskrepanz + MAD pro Persom
D_cols <- c("D_info","D_schreiben","D_praktisch","D_technisch","D_lernen")
data$D_mean <- rowMeans(data[, D_cols])                 # Richtung (Ueber-/Unterschaetzung)
data$D_MAD  <- rowMeans(abs(data[, D_cols]))            # Ausmass, ohne Neutralisierung

## 1b) Verteilung von D_mean und MAD (Histogramme)
p_dmean <- ggplot(data, aes(x = D_mean)) +
  geom_histogram(bins = 15, fill = BLUE, colour = "white", linewidth = 0.5) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = INK_MUTED) +
  scale_x_continuous(labels = lbl_komma) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08)), labels = lbl_komma) +
  labs(title = "Mittlere Diskrepanz pro Person (SA − BE)",
       subtitle = "Werte > 0: Überschätzung der eigenen Nutzung · Werte < 0: Unterschätzung",
       x = "Mittlere Diskrepanz", y = "Anzahl Personen")
ggsave("plots/01_hist_Dmean.png", p_dmean, width = 7, height = 4.5, dpi = 150, bg = "white")

p_mad <- ggplot(data, aes(x = D_MAD)) +
  geom_histogram(bins = 15, fill = BLUE, colour = "white", linewidth = 0.5) +
  scale_x_continuous(labels = lbl_komma) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08)), labels = lbl_komma) +
  labs(title = "Mittlere absolute Diskrepanz (MAD) pro Person",
       subtitle = "Ausmaß der Fehleinschätzung, unabhängig von der Richtung",
       x = "MAD", y = "Anzahl Personen")
ggsave("plots/02_hist_MAD.png", p_mad, width = 7, height = 4.5, dpi = 150, bg = "white")

## 1c) Diskrepanz je Aufgabe (Boxplots, alle 5 Kategorienn)
D_long <- data.frame(
  id   = rep(data$id, times = length(D_cols)),
  task = factor(rep(TASK_LABELS[D_cols], each = nrow(data)),
                levels = TASK_LABELS[D_cols]),
  D    = unlist(data[, D_cols])
)
p_box <- ggplot(D_long, aes(x = task, y = D)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = INK_MUTED) +
  geom_boxplot(fill = BLUE, alpha = 0.55, colour = INK_2,
               width = 0.55, outlier.size = 1, linewidth = 0.4) +
  scale_y_continuous(labels = lbl_komma) +
  labs(title = "Diskrepanz je Aufgabentyp",
       subtitle = "Selbstauskunft (SA) minus beobachteter Anteil (BE); 0 = korrekte Einschätzung",
       x = NULL, y = "Diskrepanz (SA − BE)") +
  theme(axis.text.x = element_text(angle = 15, hjust = 1))
ggsave("plots/03_box_tasks.png", p_box, width = 8, height = 4.5, dpi = 150, bg = "white")

## 1d) Verteilung der kategorialen Diskrepanzen (Balken)
data$S_Diskrepanz_plot <- mit_uneindeutig(data$S_Diskrepanz_Label)
data$K_Diskrepanz_plot <- mit_uneindeutig(data$K_Diskrepanz_Label)

p_sent <- ggplot(data, aes(x = S_Diskrepanz_plot, fill = S_Diskrepanz_plot)) +
  geom_bar(width = 0.6) +
  geom_text(stat = "count", aes(label = after_stat(count)),
            vjust = -0.4, size = 3.5, colour = INK_2) +
  scale_fill_manual(values = COL_DISKREPANZ, guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12)),
                     breaks = function(l) unique(floor(pretty(l))),
                     labels = lbl_komma) +
  labs(title = "Sentiment-Diskrepanz",
       subtitle = "Selbst eingeschätzter Ton im Vergleich zum beobachteten Ton der Chats",
       x = NULL, y = "Anzahl Personen")
ggsave("plots/04_bar_sentiment.png", p_sent, width = 6, height = 4, dpi = 150, bg = "white")

p_krit <- ggplot(data, aes(x = K_Diskrepanz_plot, fill = K_Diskrepanz_plot)) +
  geom_bar(width = 0.6) +
  geom_text(stat = "count", aes(label = after_stat(count)),
            vjust = -0.4, size = 3.5, colour = INK_2) +
  scale_fill_manual(values = COL_DISKREPANZ, guide = "none") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12)),
                     breaks = function(l) unique(floor(pretty(l))),
                     labels = lbl_komma) +
  labs(title = "Kritik-Diskrepanz",
       subtitle = "Selbstauskunft zum kritischen Nachfragen im Vergleich zur Beobachtung",
       x = NULL, y = "Anzahl Personen")
ggsave("plots/05_bar_kritik.png", p_krit, width = 6, height = 4, dpi = 150, bg = "white")

cat("Deskriptiv: D_mean Range [", round(min(data$D_mean),2), ",",
    round(max(data$D_mean),2), "], MAD Mittel", round(mean(data$D_MAD),2), "\n")

############################################
# 2) PAM-CLUSTERANALYSE (Gower-Distanz)#####
###########################################

## 2a) Cluster-Input: 5 kontinuierlich + 2 ordinal (geordnete Faktoren)
cluster_df <- data.frame(
  D_info       = data$D_info,
  D_schreiben  = data$D_schreiben,
  D_praktisch  = data$D_praktisch,
  D_technisch  = data$D_technisch,
  D_lernen     = data$D_lernen,
  S_Diskrepanz = factor(data$S_Diskrepanz, levels = c(-1,0,1), ordered = TRUE),
  K_Diskrepanz = factor(data$K_Diskrepanz, levels = c(-1,0,1), ordered = TRUE)
)

## 2b) Gewichtung: 5 Aufgaben je 0.2, Sentiment & Kritik je 1
gower_weights <- c(0.2, 0.2, 0.2, 0.2, 0.2, 1, 1)

gower_dist <- daisy(cluster_df, metric = "gower", weights = gower_weights)

## 2c) Optimales k ueber durchschnittliche Silhouette (k = 2..10)
#??? musss man sich nichmal anschauen wie hoch k sein soll
#optimum muss nicht automatisch das beste sein
#villeicht geringeres k wählen wenn dafür keine kleinen cluster entstehen

k_range <- 2:10
sil_avg <- sapply(k_range, function(k) {
  pm <- pam(gower_dist, k = k, diss = TRUE)
  pm$silinfo$avg.width
})
min_size <- sapply(k_range, function(k) {
  pm <- pam(gower_dist, k = k, diss = TRUE)
  min(table(pm$clustering))
})
names(sil_avg) <- names(min_size) <- k_range

# k-Wahl: beste Silhouette unter den Loesungen ohne Mini-Cluster (n >= 3),
# damit die Cluster interpretierbar bleiben und die Gruppenvergleiche
# (Welch-ANOVA etc.) genug Beobachtungen pro Gruppe haben
MIN_CLUSTER_N <- 3
k_zulaessig <- k_range[min_size >= MIN_CLUSTER_N]
k_opt <- k_zulaessig[which.max(sil_avg[as.character(k_zulaessig)])]

sil_df <- data.frame(k = k_range, silhouette = sil_avg, min_size = min_size)
p_sil <- ggplot(sil_df, aes(x = k, y = silhouette)) +
  geom_hline(yintercept = c(0.5, 0.7), linetype = "dotted", colour = INK_MUTED) +
  geom_line(colour = AXISLINE, linewidth = 0.7) +
  geom_point(size = 3, colour = BLUE) +
  geom_point(data = sil_df[sil_df$k == k_opt, ], size = 5, colour = DIV_HIGH) +
  geom_text(data = sil_df[sil_df$k == k_opt, ],
            aes(label = paste0("k = ", k)), vjust = -1.2, size = 3.5, colour = INK_2) +
  scale_x_continuous(breaks = k_range) +
  scale_y_continuous(labels = lbl_komma) +
  labs(title = "Durchschnittliche Silhouette je Clusterzahl",
       subtitle = paste0("Gewähltes k = ", k_opt, " (rot markiert): beste Silhouette ohne Cluster < ",
                         MIN_CLUSTER_N, " Personen · gepunktete Linien: Richtwerte 0,5 / 0,7"),
       x = "Anzahl Cluster (k)", y = "Durchschnittliche Silhouettenweite")
ggsave("plots/06_silhouette_k.png", p_sil, width = 7, height = 4.5, dpi = 150, bg = "white")

## 2d) Finales PAM-Modell
set.seed(SEED)
pam_fit <- pam(gower_dist, k = k_opt, diss = TRUE)
data$cluster <- factor(pam_fit$clustering)
cluster_cols <- setNames(PAL_CAT[seq_len(k_opt)], levels(data$cluster))

cat("Optimales k:", k_opt, "| avg. Silhouette:", round(max(sil_avg),3),
    "| Clustergroessen:", paste(table(data$cluster), collapse="/"), "\n")

## 2e) Silhouette-Plot pro Person
sil_obj <- silhouette(pam_fit$clustering, gower_dist)
sil_pdf <- data.frame(cluster = factor(sil_obj[,1]),
                      sil_width = sil_obj[,3])
sil_pdf <- sil_pdf[order(sil_pdf$cluster, sil_pdf$sil_width), ]
sil_pdf$idx <- 1:nrow(sil_pdf)
p_silperson <- ggplot(sil_pdf, aes(x = idx, y = sil_width, fill = cluster)) +
  geom_col(width = 0.75) +
  geom_hline(yintercept = 0, colour = AXISLINE) +
  coord_flip() +
  scale_fill_manual(values = cluster_cols, name = "Cluster") +
  scale_y_continuous(labels = lbl_komma) +
  labs(title = "Silhouettenwerte pro Person",
       subtitle = "Werte nahe 1 = klar zugeordnet · Werte < 0 = eher zum Nachbarcluster passend",
       x = "Person (nach Cluster sortiert)", y = "Silhouettenweite") +
  theme(axis.text.y = element_blank(), panel.grid.major.y = element_blank())
ggsave("plots/07_silhouette_person.png", p_silperson, width = 7, height = 6, dpi = 150, bg = "white")

## 2f) Cluster-Profile: mittlere Diskrepanz je Variable (Heatmap) -----
prof <- aggregate(cbind(D_info, D_schreiben, D_praktisch, D_technisch, D_lernen) ~ cluster,
                  data = data, FUN = mean)
prof_long <- reshape(prof, direction = "long",
                     varying = D_cols, v.names = "value",
                     timevar = "variable", times = D_cols, idvar = "cluster")
prof_long$task <- factor(TASK_LABELS[prof_long$variable], levels = TASK_LABELS[D_cols])
p_heat <- ggplot(prof_long, aes(x = task, y = cluster, fill = value)) +
  geom_tile(colour = "white", linewidth = 1.5) +
  geom_text(aes(label = komma_chr(sprintf("%+.2f", value))), size = 3.5, colour = INK) +
  scale_fill_gradient2(low = DIV_LOW, mid = DIV_MID, high = DIV_HIGH, midpoint = 0,
                       labels = lbl_komma) +
  labs(title = "Cluster-Profile: mittlere Diskrepanz je Aufgabe",
       subtitle = "Rot = Überschätzung (SA > BE) · Blau = Unterschätzung (SA < BE)",
       x = NULL, y = "Cluster", fill = "Mittlere\nDiskrepanz") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1),
        panel.grid = element_blank())
ggsave("plots/08_cluster_heatmap.png", p_heat, width = 8.5, height = 4.5, dpi = 150, bg = "white")

## 2g) MDS-Projektion der Distanzmatrix, eingefaerbt nach Cluste
mds <- cmdscale(gower_dist, k = 2)
mds_df <- data.frame(Dim1 = mds[,1], Dim2 = mds[,2], cluster = data$cluster)
medoid_idx <- pam_fit$id.med
p_mds <- ggplot(mds_df, aes(Dim1, Dim2, colour = cluster)) +
  geom_point(size = 3, alpha = 0.85) +
  geom_point(data = mds_df[medoid_idx, ], size = 6, shape = 1, stroke = 1.2,
             colour = INK) +
  scale_colour_manual(values = cluster_cols, name = "Cluster") +
  scale_x_continuous(labels = lbl_komma) +
  scale_y_continuous(labels = lbl_komma) +
  labs(title = "MDS-Projektion der Gower-Distanzen",
       subtitle = "Umkreiste Punkte = Medoide (Cluster-Zentren)",
       x = "MDS-Dimension 1", y = "MDS-Dimension 2")
ggsave("plots/09_mds.png", p_mds, width = 7, height = 5, dpi = 150, bg = "white")

## 2h) Kategoriale Diskrepanzen je Cluster (gestapelte Balken)
p_sent_cl <- ggplot(data, aes(x = cluster, fill = S_Diskrepanz_plot)) +
  geom_bar(position = "fill", width = 0.6, colour = "white", linewidth = 0.6) +
  scale_fill_manual(values = COL_DISKREPANZ, name = "Sentiment-\nDiskrepanz") +
  scale_y_continuous(labels = lbl_prozent) +
  labs(title = "Sentiment-Diskrepanz je Cluster",
       x = "Cluster", y = "Anteil der Personen")
ggsave("plots/10_sentiment_cluster.png", p_sent_cl, width = 7, height = 4.5, dpi = 150, bg = "white")

p_krit_cl <- ggplot(data, aes(x = cluster, fill = K_Diskrepanz_plot)) +
  geom_bar(position = "fill", width = 0.6, colour = "white", linewidth = 0.6) +
  scale_fill_manual(values = COL_DISKREPANZ, name = "Kritik-\nDiskrepanz") +
  scale_y_continuous(labels = lbl_prozent) +
  labs(title = "Kritik-Diskrepanz je Cluster",
       x = "Cluster", y = "Anteil der Personen")
ggsave("plots/11_kritik_cluster.png", p_krit_cl, width = 7, height = 4.5, dpi = 150, bg = "white")

## 2i) Cluster-Zentren (Medoide) im direkten Vergleich
# PAM-Zentren sind echte Personen: je Cluster das Diskrepanzprofil des Medoids,
# Sentiment-/Kritik-Diskrepanz des Medoids steht in der Legende
med <- data[pam_fit$id.med, ]
med_lab <- paste0("Cluster ", levels(data$cluster), " (ID ", med$id, ")\n",
                  "Sentiment: ", med$S_Diskrepanz_plot,
                  " · Kritik: ", med$K_Diskrepanz_plot)
med_long <- data.frame(
  cluster = factor(rep(levels(data$cluster), times = length(D_cols)),
                   levels = levels(data$cluster)),
  task    = factor(rep(TASK_LABELS[D_cols], each = nrow(med)),
                   levels = TASK_LABELS[D_cols]),
  D       = unlist(med[, D_cols])
)
p_med <- ggplot(med_long, aes(x = task, y = D, colour = cluster)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = INK_MUTED) +
  geom_point(size = 3.5, alpha = 0.9,
             position = position_jitter(width = 0.12, height = 0, seed = SEED)) +
  scale_colour_manual(values = cluster_cols, labels = med_lab, name = NULL) +
  scale_y_continuous(labels = lbl_komma) +
  labs(title = "Cluster-Zentren im Vergleich (Medoide)",
       subtitle = "Diskrepanzprofil der repräsentativsten Person je Cluster · 0 = korrekte Selbsteinschätzung",
       x = NULL, y = "Diskrepanz (SA − BE)") +
  theme(axis.text.x = element_text(angle = 15, hjust = 1),
        legend.key.height = grid::unit(2.2, "lines"))
ggsave("plots/09b_medoid_profil.png", p_med, width = 9, height = 5, dpi = 150, bg = "white")

## 2j) Cluster-Zentren im Vergleich: Kontextvariablen
# Werte der Medoide auf den Kontrollvariablen, je Variable auf den
# Skalenbereich [0,1] reskaliert, damit alles in ein Panel passt
ctx_vars   <- c("social_desir_mean","ai_experience","freq",
                "info_literacy_where","info_literacy_how")
ctx_labels <- c("Soziale\nErwünschtheit","KI-Erfahrung","Nutzungs-\nhäufigkeit",
                "Info-Literacy\n(wo suchen)","Info-Literacy\n(wie formulieren)")
ctx_range  <- list(social_desir_mean = c(1, 5), ai_experience = c(1, 5),
                   freq = c(2, 6), info_literacy_where = c(1, 5),
                   info_literacy_how = c(1, 5))
med_ctx <- do.call(rbind, lapply(seq_along(ctx_vars), function(i) {
  v <- ctx_vars[i]; r <- ctx_range[[v]]
  data.frame(variable = factor(ctx_labels[i], levels = ctx_labels),
             cluster  = factor(levels(data$cluster), levels = levels(data$cluster)),
             wert01   = (med[[v]] - r[1]) / (r[2] - r[1]))
}))
p_medctx <- ggplot(med_ctx, aes(x = variable, y = wert01, colour = cluster)) +
  geom_point(size = 3.5, alpha = 0.9,
             position = position_jitter(width = 0.12, height = 0, seed = SEED)) +
  scale_colour_manual(values = cluster_cols, labels = med_lab, name = NULL) +
  scale_y_continuous(limits = c(0, 1), labels = lbl_prozent) +
  labs(title = "Cluster-Zentren im Vergleich: Kontextvariablen",
       subtitle = "Werte der Medoide, je Variable auf den Skalenbereich [0 %, 100 %] reskaliert",
       x = NULL, y = "Wert (Anteil am Skalenbereich)") +
  theme(legend.key.height = grid::unit(2.2, "lines"))
ggsave("plots/09c_medoid_kontext.png", p_medctx, width = 9, height = 5, dpi = 150, bg = "white")

# =====================================================================
# 3) CLUSTERVERGLEICH: Kontextvariablen (nicht im Clustering verwendet)
# =====================================================================

## Hilfsfunktion: p-Wert dezent formatieren
fmt_p <- function(p) ifelse(p < 0.001, "< 0,001", komma_chr(sprintf("%.3f", p)))

## 3a) Soziale Erwuenschtheit (metrisch-nah) -> Welch-ANOVA + Boxplot -------
# Voraussetzung: jeder Cluster braucht n >= 2 und Varianz > 0
# (durch MIN_CLUSTER_N = 3 bei der k-Wahl abgesichert)
aov_sd <- oneway.test(social_desir_mean ~ cluster, data = data, var.equal = FALSE)
p_sd <- ggplot(data, aes(x = cluster, y = social_desir_mean, fill = cluster)) +
  geom_boxplot(alpha = 0.55, colour = INK_2, width = 0.55,
               linewidth = 0.4, outlier.shape = NA) +
  geom_jitter(width = 0.12, size = 1.6, alpha = 0.6, colour = INK) +
  scale_fill_manual(values = cluster_cols, guide = "none") +
  scale_y_continuous(labels = lbl_komma) +
  labs(title = "Soziale Erwünschtheit je Cluster",
       x = "Cluster", y = "Soziale Erwünschtheit (Mittelwert, 1–5)")
ggsave("plots/12_context_socialdesir.png", p_sd, width = 7, height = 4.5, dpi = 150, bg = "white")

## 3b) Ordinale Variablen -> Kruskal-Wallis + Boxplots
ord_vars   <- c("ai_experience","freq","info_literacy_where","info_literacy_how")
ord_labels <- c("KI-Erfahrung","Nutzungshäufigkeit","Info-Literacy (wo suchen)","Info-Literacy (wie formulieren)")

# Lesbare Achsenbeschriftung statt nackter Zahlencodes
ord_scales <- list(
  ai_experience = list(breaks = 1:5,
                       labels = c("gar nicht\nvertraut","eher nicht\nvertraut","teils/teils",
                                  "eher\nvertraut","sehr\nvertraut")),
  freq          = list(breaks = 2:6,
                       labels = c("seltener als\n1×/Monat","1–3×/Monat","1×– mehrmals\npro Woche",
                                  "(fast)\ntäglich","mehrmals\ntäglich")),
  info_literacy_where = list(breaks = 1:5,
                       labels = c("stimme überhaupt\nnicht zu","stimme eher\nnicht zu","teils/teils",
                                  "stimme\neher zu","stimme voll\nund ganz zu")),
  info_literacy_how   = list(breaks = 1:5,
                       labels = c("stimme überhaupt\nnicht zu","stimme eher\nnicht zu","teils/teils",
                                  "stimme\neher zu","stimme voll\nund ganz zu"))
)

ord_plots <- list()   # fuer die Uebersichtsgrafik in 3d
ord_pvals <- c()

for (i in seq_along(ord_vars)) {
  v  <- ord_vars[i]
  kw <- kruskal.test(data[[v]] ~ data$cluster)
  sc <- ord_scales[[v]]
  p_ord <- ggplot(data, aes(x = cluster, y = .data[[v]], fill = cluster)) +
    geom_boxplot(alpha = 0.55, colour = INK_2, width = 0.55,
                 linewidth = 0.4, outlier.shape = NA) +
    geom_jitter(width = 0.12, height = 0.08, size = 1.6, alpha = 0.6, colour = INK) +
    scale_fill_manual(values = cluster_cols, guide = "none") +
    scale_y_continuous(breaks = sc$breaks, labels = sc$labels,
                       limits = range(sc$breaks) + c(-0.35, 0.35)) +
    labs(title = paste(ord_labels[i], "je Cluster"),
         x = "Cluster", y = NULL)
  ggsave(sprintf("plots/13_context_%s.png", v), p_ord, width = 7, height = 4.5, dpi = 150, bg = "white")
  ord_plots[[v]] <- p_ord
  ord_pvals[v]   <- kw$p.value
}

## 3c) Nominale Variablen -> Chi-Quadrat + gestapelte Balken
# _f-Faktoren verwenden, damit Legenden Klartext statt Zahlencodes zeigen
nom_vars   <- c("gender_f","field_f","degree_f")
nom_files  <- c("gender","field","degree")
nom_labels <- c("Geschlecht","Fächergruppe","Abschluss")

nom_plots <- list()   # fuer die Uebersichtsgrafik in 3d

for (i in seq_along(nom_vars)) {
  v <- nom_vars[i]
  tab <- table(data$cluster, data[[v]])
  # Chi-Quadrat mit simuliertem p-Wert (robust bei kleinen erwarteten Haeufigkeiten)
  chi <- suppressWarnings(chisq.test(tab, simulate.p.value = TRUE, B = 2000))
  data$nom_grp <- droplevels(data[[v]])
  # Maximal 8 Farbslots: seltene Kategorien fuer die Darstellung zu "andere" buendeln
  # (der Chi-Quadrat-Test oben laeuft weiterhin ueber alle Original-Kategorien)
  if (nlevels(data$nom_grp) > 8) {
    haeufig <- names(sort(table(data$nom_grp), decreasing = TRUE))[1:7]
    data$nom_grp <- factor(ifelse(as.character(data$nom_grp) %in% haeufig,
                                  as.character(data$nom_grp), "andere"),
                           levels = c(haeufig, "andere"))
  }
  n_lev <- nlevels(data$nom_grp)
  p_nom <- ggplot(data, aes(x = cluster, fill = nom_grp)) +
    geom_bar(position = "fill", width = 0.6, colour = "white", linewidth = 0.6) +
    scale_fill_manual(values = PAL_CAT[seq_len(n_lev)], name = nom_labels[i]) +
    scale_y_continuous(labels = lbl_prozent) +
    labs(title = paste(nom_labels[i], "je Cluster"),
         x = "Cluster", y = "Anteil der Personen")
  ggsave(sprintf("plots/14_context_%s.png", nom_files[i]), p_nom, width = 7.5, height = 4.5, dpi = 150, bg = "white")
  nom_plots[[nom_files[i]]] <- p_nom
}

## 3d) Uebersichtsgrafiken: Cluster im Vergleich auf allen Kontextvariablen

### Profil-Plot: Cluster-Mittelwerte aller metrisch/ordinalen Kontextvariablen,
### auf [0,1] reskaliert (Minimum/Maximum der jeweiligen Skala), damit alle
### Variablen in einem Panel vergleichbar sind
profil_vars <- c("social_desir_mean", ord_vars)
profil_labels <- c("Soziale Erwünschtheit", ord_labels)
profil_range <- list(social_desir_mean = c(1, 5), ai_experience = c(1, 5),
                     freq = c(2, 6), info_literacy_where = c(1, 5),
                     info_literacy_how = c(1, 5))
profil_df <- do.call(rbind, lapply(seq_along(profil_vars), function(i) {
  v  <- profil_vars[i]
  m  <- tapply(data[[v]], data$cluster, mean)
  r  <- profil_range[[v]]
  data.frame(variable = profil_labels[i],
             cluster  = factor(names(m), levels = levels(data$cluster)),
             wert01   = (m - r[1]) / (r[2] - r[1]))
}))
profil_df$var_lab <- factor(profil_df$variable,
                            levels = rev(unique(profil_df$variable)))

# Punkte pro Variable leicht vertikal versetzen, damit aehnliche
# Cluster-Mittelwerte nicht uebereinander liegen
profil_df$y_base <- as.numeric(profil_df$var_lab)
offsets <- seq(0.17, -0.17, length.out = nlevels(profil_df$cluster))
profil_df$y_pos  <- profil_df$y_base + offsets[as.numeric(profil_df$cluster)]

# grauer Spannweiten-Balken: min bis max der Cluster-Mittelwerte je Variable
spann_df <- do.call(rbind, lapply(split(profil_df, profil_df$var_lab), function(d)
  data.frame(y_base = d$y_base[1], von = min(d$wert01), bis = max(d$wert01))))

p_profil <- ggplot(profil_df) +
  geom_segment(data = spann_df, aes(x = von, xend = bis, y = y_base, yend = y_base),
               colour = GRID, linewidth = 2.5, lineend = "round") +
  geom_point(aes(x = wert01, y = y_pos, colour = cluster), size = 3.5) +
  scale_colour_manual(values = cluster_cols, name = "Cluster") +
  scale_x_continuous(limits = c(0, 1), labels = lbl_prozent,
                     expand = expansion(mult = c(0.02, 0.02))) +
  scale_y_continuous(breaks = seq_len(nlevels(profil_df$var_lab)),
                     labels = levels(profil_df$var_lab)) +
  labs(title = "Kontextvariablen-Profil der Cluster",
       subtitle = "Cluster-Mittelwerte, je Variable auf den Skalenbereich [0 %, 100 %] reskaliert",
       x = "Mittelwert (Anteil am Skalenbereich)", y = NULL) +
  theme(panel.grid.major.y = element_blank())
ggsave("plots/17_kontext_profil.png", p_profil, width = 8.5, height = 5.5, dpi = 150, bg = "white")

### Panel 1: Boxplots (soziale Erwuenschtheit + 4 ordinale) in einer Grafik
p_kontext_ord <- (p_sd | ord_plots[["ai_experience"]] | ord_plots[["freq"]]) /
  (ord_plots[["info_literacy_where"]] | ord_plots[["info_literacy_how"]] | plot_spacer()) +
  plot_annotation(
    title = "Kontextvariablen je Cluster - Überblick",
    theme = theme(plot.title = element_text(size = 15, face = "bold", colour = INK)))
ggsave("plots/18_kontext_uebersicht_ordinal.png", p_kontext_ord,
       width = 16, height = 9, dpi = 150, bg = "white")

### Panel 2: nominale Variablen (gestapelte Anteile) in einer Grafik
p_kontext_nom <- (nom_plots[["gender"]] | nom_plots[["field"]] | nom_plots[["degree"]]) +
  plot_annotation(
    title = "Soziodemografie je Cluster - Überblick",
    theme = theme(plot.title = element_text(size = 15, face = "bold", colour = INK)))
ggsave("plots/19_kontext_uebersicht_nominal.png", p_kontext_nom,
       width = 16, height = 5, dpi = 150, bg = "white")

cat("Clustervergleich: Grafiken erstellt (soz. Erwuenschtheit, 4 ordinale, 3 nominale, 3 Uebersichten)\n")

# =====================================================================
# 4) ROBUSTHEITSCHECKS
# =====================================================================

## 4a) Ausschluss uneindeutiger Sentiment-Faelle
# uneindeutig = Gleichstand in den Sentiment-Rohcounts
tie_sent <- apply(data[, c("obs_sent_freundlich_n","obs_sent_neutral_n",
                           "obs_sent_unfreundlich_n")], 1,
                  function(x) sum(x == max(x)) > 1)
data_r1 <- data[!tie_sent, ]

cl_r1 <- data.frame(
  data_r1$D_info, data_r1$D_schreiben, data_r1$D_praktisch,
  data_r1$D_technisch, data_r1$D_lernen,
  S = factor(data_r1$S_Diskrepanz, levels=c(-1,0,1), ordered=TRUE),
  K = factor(data_r1$K_Diskrepanz, levels=c(-1,0,1), ordered=TRUE)
)
gd_r1 <- daisy(cl_r1, metric = "gower", weights = gower_weights)
set.seed(SEED)
pam_r1 <- pam(gd_r1, k = k_opt, diss = TRUE)
cat("Robustheit 1 (ohne", sum(tie_sent), "Tie-Sentiment):",
    "avg.sil =", round(pam_r1$silinfo$avg.width, 3), "\n")

## 4b) Ohne Gewichtung der Aufgaben-Diskrepanzen
gd_r2 <- daisy(cluster_df, metric = "gower")   # Default: alle Variablen gleich
sil_r2 <- sapply(2:6, function(k) pam(gd_r2, k=k, diss=TRUE)$silinfo$avg.width)
k_r2 <- (2:6)[which.max(sil_r2)]
set.seed(SEED)
pam_r2 <- pam(gd_r2, k = k_r2, diss = TRUE)
# Vergleich mit Hauptloesung: Uebereinstimmung der Clusterzuordnung
tab_r2 <- table(Haupt = data$cluster, Ungewichtet = factor(pam_r2$clustering))
cat("Robustheit 2 (ohne Gewichtung): k =", k_r2,
    "| avg.sil =", round(max(sil_r2),3), "\n")

## 4c) Hierarchisches Clustering (average linkage
hc <- hclust(gower_dist, method = "average")
hc_cl <- cutree(hc, k = k_opt)
tab_hc <- table(PAM = data$cluster, Hierarchisch = hc_cl)

# Dendrogramm als Grafik
# Basisgrafik: Achsenbeschriftung kommt aus format(), daher OutDec kurzzeitig
# auf Komma stellen und danach wieder zuruecksetzen
png("plots/15_dendrogram_average.png", width = 1100, height = 650, res = 120)
old_outdec <- options(OutDec = ",")
par(mar = c(3, 4, 3, 1), col.main = INK, col.axis = INK_2, col.lab = INK_2,
    family = "sans", cex.main = 1.1)
plot(hc, labels = paste("ID", data$id), main = "Hierarchisches Clustering (Average Linkage, Gower-Distanz)",
     xlab = "", sub = "", ylab = "Distanz", cex = 0.75, frame.plot = FALSE)
rect.hclust(hc, k = k_opt, border = PAL_CAT[seq_len(k_opt)])
options(old_outdec)
dev.off()

# Uebereinstimmung PAM vs. hierarchisch als Kreuztabellen-Grafik
tab_df <- as.data.frame(tab_hc)
p_agree <- ggplot(tab_df, aes(x = PAM, y = factor(Hierarchisch), fill = Freq)) +
  geom_tile(colour = "white", linewidth = 1.5) +
  geom_text(aes(label = Freq), size = 4, colour = INK) +
  scale_fill_gradient(low = "#cde2fb", high = "#184f95", labels = lbl_komma) +
  labs(title = "Übereinstimmung: PAM vs. Average-Linkage",
       subtitle = "Anzahl Personen je Kombination der Clusterzuordnungen",
       x = "PAM-Cluster", y = "Hierarchisches Cluster", fill = "Anzahl") +
  theme(panel.grid = element_blank())
ggsave("plots/16_agreement_pam_hc.png", p_agree, width = 6.5, height = 5, dpi = 150, bg = "white")

cat("Robustheit 3 (Average-Linkage): Dendrogramm + Uebereinstimmung erstellt\n")

cat("Erzeugte Grafiken:", length(list.files("plots")), "\n")

#######################################
# ANHANG: TABELLEN ZU ALLEN GRAFIKEN##
######################################
# Jede Tabelle wird doppelt gespeichert:
#   1) als CSV (fuer Weiterverarbeitung)
#   2) gesammelt als Markdown-Report tabs/tabellen_report.md (huebsch formatiert)
tab_dir <- file.path(base_path, "tabs")
dir.create(tab_dir, showWarnings = FALSE, recursive = TRUE)

tab_report <- list()   # sammelt (Titel, Tabelle) fuer den Markdown-Report

save_tab <- function(df, name, titel = NULL) {
  # Zahlen als Text mit Dezimalkomma; das Trennzeichen der CSV bleibt das
  # Komma, die Werte werden von write.csv in Anfuehrungszeichen gesetzt
  df <- komma_df(df)
  write.csv(df, file.path(tab_dir, name), row.names = FALSE)
  if (!is.null(titel)) {
    tab_report[[length(tab_report) + 1]] <<- list(titel = titel, name = name, df = df)
  }
  cat("  ", name, "\n")
}

##Stichprobe (zu Grafik 00)
save_tab(as.data.frame(table(Geschlecht = data$gender_f)), "T00a_geschlecht.csv",
         "T00a – Stichprobe: Geschlecht")
save_tab(as.data.frame(table(Abschluss  = data$degree_f)), "T00b_abschluss.csv",
         "T00b – Stichprobe: Angestrebter Abschluss")
save_tab(as.data.frame(table(Fach       = data$field_f)),  "T00c_fach.csv",
         "T00c – Stichprobe: Fächergruppe")
save_tab(data.frame(Statistik = c("N","Mittelwert","SD","Min","Max"),
                    Alter = c(nrow(data), round(mean(data$age),1), round(sd(data$age),1),
                              min(data$age), max(data$age))), "T00d_alter.csv",
         "T00d – Stichprobe: Alter")

### Diskrepanz (zu Grafiken 01-05)
save_tab(data.frame(Person_ID = data$id, D_mean = round(data$D_mean,3),
                    D_MAD = round(data$D_MAD,3)), "T01_dmean_mad_person.csv",
         "T01 – Mittlere Diskrepanz (D_mean) und MAD pro Person")
save_tab(data.frame(
  Aufgabe = unname(TASK_LABELS[D_cols]),
  Mittelwert = round(sapply(data[,D_cols], mean),3),
  SD         = round(sapply(data[,D_cols], sd),3),
  Median     = round(sapply(data[,D_cols], median),3),
  Min        = round(sapply(data[,D_cols], min),3),
  Max        = round(sapply(data[,D_cols], max),3)), "T03_diskrepanz_je_aufgabe.csv",
  "T03 – Diskrepanz (SA − BE) je Aufgabentyp")
save_tab(as.data.frame(table(Sentiment_Diskrepanz = data$S_Diskrepanz_plot)),
         "T04_sentiment_diskrepanz.csv", "T04 – Sentiment-Diskrepanz (Häufigkeiten)")
save_tab(as.data.frame(table(Kritik_Diskrepanz    = data$K_Diskrepanz_plot)),
         "T05_kritik_diskrepanz.csv", "T05 – Kritik-Diskrepanz (Häufigkeiten)")

###Clustering (zu Grafiken 06-11)
# min_size dokumentiert, warum k mit besserer Silhouette verworfen wurde
# (Mini-Cluster unterhalb MIN_CLUSTER_N)
save_tab(data.frame(k = 2:10, `Ø Silhouette` = round(sil_avg,3),
                    `kleinstes Cluster (n)` = as.integer(min_size),
                    check.names = FALSE),
         "T06_silhouette_k.csv", "T06 – Durchschnittliche Silhouette je Clusterzahl k")
save_tab(data.frame(`Person-ID` = data$id, Cluster = data$cluster,
                    Silhouette = round(sil_obj[,3],3), check.names = FALSE),
         "T07_silhouette_person.csv",
         "T07 – Silhouettenwerte pro Person")
# Aufgaben als Zeilen, Cluster als Spalten: die Aufgabenlabels sind lang, als
# Spaltenkoepfe waere die Tabelle im PDF zu breit
prof_tab <- aggregate(cbind(D_info,D_schreiben,D_praktisch,D_technisch,D_lernen) ~ cluster,
                      data = data, FUN = function(x) round(mean(x),3))
prof_tab_t <- data.frame(Aufgabe = unname(TASK_LABELS[D_cols]),
                         check.names = FALSE)
for (r in seq_len(nrow(prof_tab)))
  prof_tab_t[[paste("Cluster", prof_tab$cluster[r])]] <-
    unlist(prof_tab[r, D_cols], use.names = FALSE)
save_tab(prof_tab_t, "T08_cluster_profile.csv",
         "T08 – Cluster-Profile: mittlere Diskrepanz je Aufgabe")
save_tab(data.frame(Cluster = levels(data$cluster),
                    `Größe (n)` = as.integer(table(data$cluster)),
                    `Medoid (Person-ID)` = data$id[pam_fit$id.med],
                    check.names = FALSE), "T08b_cluster_groessen.csv",
         "T08b – Clustergrößen und Medoide")
med_tab <- data.frame(Cluster = levels(data$cluster), Person_ID = med$id,
                      round(med[, D_cols], 3),
                      Sentiment = as.character(med$S_Diskrepanz_plot),
                      Kritik    = as.character(med$K_Diskrepanz_plot))
names(med_tab)[3:7] <- unname(TASK_LABELS[D_cols])
save_tab(med_tab, "T09b_medoid_profile.csv",
         "T09b – Cluster-Zentren (Medoide): Diskrepanzprofile")
med_ctx_tab <- data.frame(Cluster = levels(data$cluster), Person_ID = med$id,
                          round(med[, ctx_vars], 2))
names(med_ctx_tab)[3:7] <- c("Soz. Erwünschtheit","KI-Erfahrung","Nutzungshäufigkeit",
                             "Info-Literacy (wo)","Info-Literacy (wie)")
save_tab(med_ctx_tab, "T09c_medoid_kontext.csv",
         "T09c – Cluster-Zentren (Medoide): Kontextvariablen (Originalskalen)")
save_tab(cbind(Cluster = rownames(table(data$cluster, data$S_Diskrepanz_plot)),
               as.data.frame.matrix(table(data$cluster, data$S_Diskrepanz_plot))),
         "T10_sentiment_je_cluster.csv", "T10 – Sentiment-Diskrepanz je Cluster")
save_tab(cbind(Cluster = rownames(table(data$cluster, data$K_Diskrepanz_plot)),
               as.data.frame.matrix(table(data$cluster, data$K_Diskrepanz_plot))),
         "T11_kritik_je_cluster.csv", "T11 – Kritik-Diskrepanz je Cluster")

### Clustervergleich (zu Grafiken 12-14) ----
sd_summary <- aggregate(social_desir_mean ~ cluster, data = data,
                        FUN = function(x) round(c(M = mean(x), SD = sd(x), n = length(x)),2))
sd_out <- data.frame(Cluster = sd_summary$cluster, sd_summary$social_desir_mean)
names(sd_out) <- c("Cluster", "M", "SD", "n")
sd_out$`p (Welch)` <- round(aov_sd$p.value, 4)
save_tab(sd_out, "T12_socialdesir_cluster.csv",
         "T12 – Soziale Erwünschtheit je Cluster (Welch-ANOVA)")

ord_res <- do.call(rbind, lapply(seq_along(ord_vars), function(i) {
  v  <- ord_vars[i]
  kw <- kruskal.test(data[[v]] ~ data$cluster)
  data.frame(Variable = ord_labels[i], `Chi²` = round(unname(kw$statistic),3),
             df = unname(kw$parameter), `p (Kruskal-Wallis)` = round(kw$p.value,4),
             check.names = FALSE)
}))
save_tab(ord_res, "T13_ordinale_kruskal.csv",
         "T13 – Ordinale Kontextvariablen: Kruskal-Wallis-Tests")

nom_res <- do.call(rbind, lapply(seq_along(nom_vars), function(i) {
  v   <- nom_vars[i]
  # droplevels: unbesetzte Faktorstufen ergeben erwartete Haeufigkeiten von 0
  # und damit ein NaN als Teststatistik
  chi <- suppressWarnings(chisq.test(table(data$cluster, droplevels(data[[v]])),
                                     simulate.p.value = TRUE, B = 2000))
  data.frame(Variable = nom_labels[i], `Chi²` = round(unname(chi$statistic),3),
             `p (simuliert)` = round(chi$p.value,4), check.names = FALSE)
}))
save_tab(nom_res, "T14_nominale_chi2.csv",
         "T14 – Nominale Kontextvariablen: Chi-Quadrat-Tests")

# Numerische Werte zur Profil-Grafik (17_kontext_profil): Cluster-Mittelwerte
# auf der Originalskala, plus Spannweite in Prozentpunkten des Skalenbereichs
kontext_prof_tab <- do.call(rbind, lapply(seq_along(profil_vars), function(i) {
  v <- profil_vars[i]; r <- profil_range[[v]]
  m <- tapply(data[[v]], data$cluster, mean)
  out <- data.frame(Variable = profil_labels[i],
                    Skala    = paste0(r[1], "–", r[2]),
                    check.names = FALSE)
  for (cl in levels(data$cluster)) out[[paste("Cluster", cl)]] <- round(m[[cl]], 2)
  out$`Spannweite (PP)` <- round(100 * (max(m) - min(m)) / (r[2] - r[1]), 1)
  out
}))
save_tab(kontext_prof_tab, "T17_kontext_profil.csv",
         "T17 – Kontextvariablen-Profil der Cluster (Mittelwerte, Originalskalen)")

# Numerische Werte zu den Soziodemografie-Grafiken (14_/19_): Kreuztabellen.
# Kategorien als Zeilen, Cluster als Spalten - sonst wird v. a. die
# Faechergruppe mit 11 Auspraegungen im PDF zu breit. droplevels(), damit
# unbesetzte Kategorien die Tabelle nicht mit Nullzeilen aufblaehen.
for (i in seq_along(nom_vars)) {
  tb  <- t(table(data$cluster, droplevels(data[[nom_vars[i]]])))
  out <- as.data.frame.matrix(tb)
  names(out) <- paste("Cluster", names(out))
  save_tab(data.frame(Kategorie = rownames(tb), out, check.names = FALSE),
           sprintf("T19%s_%s_je_cluster.csv", letters[i], nom_files[i]),
           sprintf("T19%s – %s je Cluster (Häufigkeiten)", letters[i], nom_labels[i]))
}

### Robustheit (zu Grafiken 15-16)##

save_tab(data.frame(
  Check = c("1: ohne Tie-Sentiment","2: ohne Gewichtung","3: Average-Linkage"),
  Beschreibung = c(paste(sum(tie_sent),"Fälle ausgeschlossen"),
                   paste("k =", k_r2), paste("k =", k_opt)),
  `Ø Silhouette` = c(round(pam_r1$silinfo$avg.width,3), round(max(sil_r2),3), NA),
  check.names = FALSE),
  "T15_robustheit_uebersicht.csv", "T15 – Robustheitschecks: Übersicht")
# Kreuztabellen breit speichern (Zeilen = PAM-Cluster), damit sie im Anhang
# ohne weiteres Umformen lesbar sind
kreuz_breit <- function(tb, spalten_praefix) {
  out <- as.data.frame.matrix(tb)
  names(out) <- paste(spalten_praefix, names(out))
  data.frame(`PAM-Cluster` = rownames(tb), out, check.names = FALSE)
}
save_tab(kreuz_breit(table(data$cluster, pam_r2$clustering), "Ungewichtet"),
         "T15b_pam_vs_ungewichtet.csv", "T15b – PAM (gewichtet) vs. PAM (ungewichtet)")
save_tab(kreuz_breit(table(data$cluster, hc_cl), "Hierarchisch"),
         "T16_pam_vs_hierarchisch.csv", "T16 – PAM vs. hierarchisches Clustering")

### Markdown-Report mit allen Tabellen schreiben ----
report_lines <- c("# Tabellenanhang",
                  "",
                  paste0("Automatisch erzeugt von `Python_code/data_analasys.R` am ",
                         format(Sys.Date(), "%d.%m.%Y"), " (N = ", nrow(data), ")."),
                  "")
for (t in tab_report) {
  report_lines <- c(report_lines,
                    paste("##", t$titel),
                    "",
                    knitr::kable(t$df, format = "pipe", row.names = FALSE,
                                 align = komma_align(t$df)),
                    "",
                    paste0("*Datei: `tabs/", t$name, "`*"),
                    "")
}
writeLines(report_lines, file.path(tab_dir, "tabellen_report.md"))
cat("Markdown-Report:", file.path("tabs", "tabellen_report.md"), "\n")
