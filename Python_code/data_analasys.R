##########################################
### Datenanalyse Skript###################
##########################################
base_path   <- "/home/theo/PycharmProjects/Masterprojekt-Chatbots"
data_path   <- file.path(base_path, "data/processed/analysis_dataset.rds")
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
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "Geschlecht", x = NULL, y = "Anzahl") +
  theme(axis.text.x = element_text(angle = 20, hjust = 1))

p2 <- ggplot(data, aes(x = age)) +
  geom_histogram(binwidth = 1, fill = BLUE, colour = "white", linewidth = 0.5) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "Alter",
       subtitle = paste0("M = ", round(mean(data$age),1),
                         ", SD = ", round(sd(data$age),1)),
       x = "Alter in Jahren", y = "Anzahl")

p3 <- ggplot(data, aes(y = field_f)) +
  geom_bar(fill = BLUE, width = 0.6) +
  geom_text(stat = "count", aes(label = after_stat(count)),
            hjust = -0.4, size = 3.2, colour = INK_2) +
  scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(title = "Fächergruppe", x = "Anzahl", y = NULL)

p4 <- ggplot(data, aes(x = degree_f)) +
  geom_bar(fill = BLUE, width = 0.6) +
  geom_text(stat = "count", aes(label = after_stat(count)),
            vjust = -0.4, size = 3.5, colour = INK_2) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
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
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "Mittlere Diskrepanz pro Person (SA − BE)",
       subtitle = "Werte > 0: Überschätzung der eigenen Nutzung · Werte < 0: Unterschätzung",
       x = "Mittlere Diskrepanz", y = "Anzahl Personen")
ggsave("plots/01_hist_Dmean.png", p_dmean, width = 7, height = 4.5, dpi = 150, bg = "white")

p_mad <- ggplot(data, aes(x = D_MAD)) +
  geom_histogram(bins = 15, fill = BLUE, colour = "white", linewidth = 0.5) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.08))) +
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
                     breaks = function(l) unique(floor(pretty(l)))) +
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
                     breaks = function(l) unique(floor(pretty(l)))) +
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

sil_avg <- sapply(2:10, function(k) {
  pm <- pam(gower_dist, k = k, diss = TRUE)
  pm$silinfo$avg.width
})
names(sil_avg) <- 2:10
k_opt <- as.integer(names(which.max(sil_avg)))

sil_df <- data.frame(k = 2:10, silhouette = sil_avg)
p_sil <- ggplot(sil_df, aes(x = k, y = silhouette)) +
  geom_hline(yintercept = c(0.5, 0.7), linetype = "dotted", colour = INK_MUTED) +
  geom_line(colour = AXISLINE, linewidth = 0.7) +
  geom_point(size = 3, colour = BLUE) +
  geom_point(data = sil_df[sil_df$k == k_opt, ], size = 5, colour = DIV_HIGH) +
  geom_text(data = sil_df[sil_df$k == k_opt, ],
            aes(label = paste0("k = ", k)), vjust = -1.2, size = 3.5, colour = INK_2) +
  scale_x_continuous(breaks = 2:10) +
  labs(title = "Durchschnittliche Silhouette je Clusterzahl",
       subtitle = paste0("Gewähltes k = ", k_opt,
                         " (rot markiert) · gepunktete Linien: Richtwerte 0.5 / 0.7"),
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
  geom_text(aes(label = sprintf("%+.2f", value)), size = 3.5, colour = INK) +
  scale_fill_gradient2(low = DIV_LOW, mid = DIV_MID, high = DIV_HIGH, midpoint = 0) +
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
  labs(title = "MDS-Projektion der Gower-Distanzen",
       subtitle = "Umkreiste Punkte = Medoide (Cluster-Zentren)",
       x = "MDS-Dimension 1", y = "MDS-Dimension 2")
ggsave("plots/09_mds.png", p_mds, width = 7, height = 5, dpi = 150, bg = "white")

## 2h) Kategoriale Diskrepanzen je Cluster (gestapelte Balken)
p_sent_cl <- ggplot(data, aes(x = cluster, fill = S_Diskrepanz_plot)) +
  geom_bar(position = "fill", width = 0.6, colour = "white", linewidth = 0.6) +
  scale_fill_manual(values = COL_DISKREPANZ, name = "Sentiment-\nDiskrepanz") +
  scale_y_continuous(labels = percent) +
  labs(title = "Sentiment-Diskrepanz je Cluster",
       x = "Cluster", y = "Anteil der Personen")
ggsave("plots/10_sentiment_cluster.png", p_sent_cl, width = 7, height = 4.5, dpi = 150, bg = "white")

p_krit_cl <- ggplot(data, aes(x = cluster, fill = K_Diskrepanz_plot)) +
  geom_bar(position = "fill", width = 0.6, colour = "white", linewidth = 0.6) +
  scale_fill_manual(values = COL_DISKREPANZ, name = "Kritik-\nDiskrepanz") +
  scale_y_continuous(labels = percent) +
  labs(title = "Kritik-Diskrepanz je Cluster",
       x = "Cluster", y = "Anteil der Personen")
ggsave("plots/11_kritik_cluster.png", p_krit_cl, width = 7, height = 4.5, dpi = 150, bg = "white")

# =====================================================================
# 3) CLUSTERVERGLEICH: Kontextvariablen (nicht im Clustering verwendet)
# =====================================================================

## Hilfsfunktion: p-Wert dezent formatieren
fmt_p <- function(p) ifelse(p < 0.001, "< 0.001", sprintf("%.3f", p))

## 3a) Soziale Erwuenschtheit (metrisch-nah) -> ANOVA + Boxplot -------
aov_sd <- oneway.test(social_desir_mean ~ cluster, data = data, var.equal = FALSE)
p_sd <- ggplot(data, aes(x = cluster, y = social_desir_mean, fill = cluster)) +
  geom_boxplot(alpha = 0.55, colour = INK_2, width = 0.55,
               linewidth = 0.4, outlier.shape = NA) +
  geom_jitter(width = 0.12, size = 1.6, alpha = 0.6, colour = INK) +
  scale_fill_manual(values = cluster_cols, guide = "none") +
  labs(title = "Soziale Erwünschtheit je Cluster",
       subtitle = paste0("Welch-ANOVA: p = ", fmt_p(aov_sd$p.value)),
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
         subtitle = paste0("Kruskal-Wallis-Test: p = ", fmt_p(kw$p.value)),
         x = "Cluster", y = NULL)
  ggsave(sprintf("plots/13_context_%s.png", v), p_ord, width = 7, height = 4.5, dpi = 150, bg = "white")
}

## 3c) Nominale Variablen -> Chi-Quadrat + gestapelte Balken
# _f-Faktoren verwenden, damit Legenden Klartext statt Zahlencodes zeigen
nom_vars   <- c("gender_f","field_f","degree_f")
nom_files  <- c("gender","field","degree")
nom_labels <- c("Geschlecht","Fächergruppe","Abschluss")

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
    scale_y_continuous(labels = percent) +
    labs(title = paste(nom_labels[i], "je Cluster"),
         subtitle = paste0("Chi-Quadrat-Test (simulierter p-Wert): p = ", fmt_p(chi$p.value)),
         x = "Cluster", y = "Anteil der Personen")
  ggsave(sprintf("plots/14_context_%s.png", nom_files[i]), p_nom, width = 7.5, height = 4.5, dpi = 150, bg = "white")
}

cat("Clustervergleich: Grafiken erstellt (soz. Erwuenschtheit, 4 ordinale, 3 nominale)\n")

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
png("plots/15_dendrogram_average.png", width = 1100, height = 650, res = 120)
par(mar = c(3, 4, 3, 1), col.main = INK, col.axis = INK_2, col.lab = INK_2,
    family = "sans", cex.main = 1.1)
plot(hc, labels = paste("ID", data$id), main = "Hierarchisches Clustering (Average Linkage, Gower-Distanz)",
     xlab = "", sub = "", ylab = "Distanz", cex = 0.75, frame.plot = FALSE)
rect.hclust(hc, k = k_opt, border = PAL_CAT[seq_len(k_opt)])
dev.off()

# Uebereinstimmung PAM vs. hierarchisch als Kreuztabellen-Grafik
tab_df <- as.data.frame(tab_hc)
p_agree <- ggplot(tab_df, aes(x = PAM, y = factor(Hierarchisch), fill = Freq)) +
  geom_tile(colour = "white", linewidth = 1.5) +
  geom_text(aes(label = Freq), size = 4, colour = INK) +
  scale_fill_gradient(low = "#cde2fb", high = "#184f95") +
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
save_tab(data.frame(k = 2:10, Durchschnittliche_Silhouette = round(sil_avg,3)),
         "T06_silhouette_k.csv", "T06 – Durchschnittliche Silhouette je Clusterzahl k")
save_tab(data.frame(Person_ID = data$id, Cluster = data$cluster,
                    Silhouette = round(sil_obj[,3],3)), "T07_silhouette_person.csv",
         "T07 – Silhouettenwerte pro Person")
prof_tab <- aggregate(cbind(D_info,D_schreiben,D_praktisch,D_technisch,D_lernen) ~ cluster,
                      data = data, FUN = function(x) round(mean(x),3))
names(prof_tab) <- c("Cluster", unname(TASK_LABELS[D_cols]))
save_tab(prof_tab, "T08_cluster_profile.csv",
         "T08 – Cluster-Profile: mittlere Diskrepanz je Aufgabe")
save_tab(data.frame(Cluster = levels(data$cluster),
                    Groesse = as.integer(table(data$cluster)),
                    Medoid_Person_ID = data$id[pam_fit$id.med]), "T08b_cluster_groessen.csv",
         "T08b – Clustergrößen und Medoide")
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
sd_out$Welch_p <- round(aov_sd$p.value, 4)
save_tab(sd_out, "T12_socialdesir_cluster.csv",
         "T12 – Soziale Erwünschtheit je Cluster (Welch-ANOVA)")

ord_res <- do.call(rbind, lapply(seq_along(ord_vars), function(i) {
  v  <- ord_vars[i]
  kw <- kruskal.test(data[[v]] ~ data$cluster)
  data.frame(Variable = ord_labels[i], Chi2 = round(unname(kw$statistic),3),
             df = unname(kw$parameter), p_Kruskal_Wallis = round(kw$p.value,4))
}))
save_tab(ord_res, "T13_ordinale_kruskal.csv",
         "T13 – Ordinale Kontextvariablen: Kruskal-Wallis-Tests")

nom_res <- do.call(rbind, lapply(seq_along(nom_vars), function(i) {
  v   <- nom_vars[i]
  chi <- suppressWarnings(chisq.test(table(data$cluster, data[[v]]),
                                     simulate.p.value = TRUE, B = 2000))
  data.frame(Variable = nom_labels[i], Chi2 = round(unname(chi$statistic),3),
             p_simuliert = round(chi$p.value,4))
}))
save_tab(nom_res, "T14_nominale_chi2.csv",
         "T14 – Nominale Kontextvariablen: Chi-Quadrat-Tests")

### Robustheit (zu Grafiken 15-16)##

save_tab(data.frame(
  Check = c("1: ohne Tie-Sentiment","2: ohne Gewichtung","3: Average-Linkage"),
  Beschreibung = c(paste(sum(tie_sent),"Fälle ausgeschlossen"),
                   paste("k =", k_r2), paste("k =", k_opt)),
  Durchschnittliche_Silhouette = c(round(pam_r1$silinfo$avg.width,3), round(max(sil_r2),3), NA)),
  "T15_robustheit_uebersicht.csv", "T15 – Robustheitschecks: Übersicht")
save_tab(as.data.frame(table(PAM = data$cluster, Ungewichtet = pam_r2$clustering)),
         "T15b_pam_vs_ungewichtet.csv", "T15b – PAM (gewichtet) vs. PAM (ungewichtet)")
save_tab(as.data.frame(table(PAM = data$cluster, Hierarchisch = hc_cl)),
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
                    knitr::kable(t$df, format = "pipe", row.names = FALSE),
                    "",
                    paste0("*Datei: `tabs/", t$name, "`*"),
                    "")
}
writeLines(report_lines, file.path(tab_dir, "tabellen_report.md"))
cat("Markdown-Report:", file.path("tabs", "tabellen_report.md"), "\n")