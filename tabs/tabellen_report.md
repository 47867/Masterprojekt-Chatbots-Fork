# Tabellenanhang

Automatisch erzeugt von `Python_code/data_analasys.R` am 15.08.2026 (N = 21).

## T00a – Stichprobe: Geschlecht

|Geschlecht       | Freq|
|:----------------|----:|
|männlich         |   12|
|weiblich         |    9|
|non-binär/divers |    0|
|keine Angabe     |    0|

*Datei: `tabs/T00a_geschlecht.csv`*

## T00b – Stichprobe: Angestrebter Abschluss

|Abschluss         | Freq|
|:-----------------|----:|
|Bachelor          |    4|
|Master            |   14|
|Staatsex./Lehramt |    3|
|Promotion         |    0|
|anderer           |    0|

*Datei: `tabs/T00b_abschluss.csv`*

## T00c – Stichprobe: Fächergruppe

|Fach               | Freq|
|:------------------|----:|
|Geistes-/Kultur    |    0|
|Sprach-/Lit.       |    0|
|Sozialwiss.        |   11|
|Recht/Wirtschaft   |    2|
|Mathe/Naturwiss.   |    3|
|Medizin/Gesundheit |    0|
|Ingenieurwiss.     |    0|
|Informatik         |    2|
|Kunst/Musik        |    0|
|Lehramt            |    3|
|anderes            |    0|

*Datei: `tabs/T00c_fach.csv`*

## T00d – Stichprobe: Alter

|Statistik  | Alter|
|:----------|-----:|
|N          |    21|
|Mittelwert |  24,7|
|SD         |   3,7|
|Min        |    19|
|Max        |    37|

*Datei: `tabs/T00d_alter.csv`*

## T01 – Mittlere Diskrepanz (D_mean) und MAD pro Person

| Person_ID| D_mean| D_MAD|
|---------:|------:|-----:|
|       241|      0|   0,2|
|       244|      0|   0,2|
|       257|      0|  0,24|
|       258|      0|   0,2|
|       259|      0|  0,08|
|       278|      0|  0,12|
|       314|      0|   0,2|
|       328|      0|  0,24|
|       334|      0|  0,04|
|       339|      0|  0,04|
|       340|      0|  0,24|
|       341|      0|  0,12|
|       350|      0|   0,2|
|       360|      0|  0,24|
|       361|      0|   0,2|
|       362|      0|  0,04|
|       363|      0|  0,12|
|       364|      0|   0,2|
|       365|      0|  0,24|
|       366|      0|  0,04|
|       367|      0|   0,2|

*Datei: `tabs/T01_dmean_mad_person.csv`*

## T03 – Diskrepanz (SA − BE) je Aufgabentyp

|Aufgabe                  | Mittelwert|    SD| Median|  Min| Max|
|:------------------------|----------:|-----:|------:|----:|---:|
|Informationssuche        |     -0,005| 0,252|      0| -0,6| 0,4|
|Schreiben/Textarbeit     |      0,048|  0,15|      0| -0,2| 0,4|
|Praktische Unterstützung |      0,014| 0,267|    0,1| -0,6| 0,3|
|Technische Unterstützung |     -0,067| 0,289|      0| -0,6| 0,3|
|Lernen/Prüfungsvorb.     |       0,01| 0,179|      0| -0,5| 0,4|

*Datei: `tabs/T03_diskrepanz_je_aufgabe.csv`*

## T04 – Sentiment-Diskrepanz (Häufigkeiten)

|Sentiment_Diskrepanz | Freq|
|:--------------------|----:|
|unfreundlicher       |    7|
|korrekt              |    9|
|freundlicher         |    5|
|uneindeutig          |    0|

*Datei: `tabs/T04_sentiment_diskrepanz.csv`*

## T05 – Kritik-Diskrepanz (Häufigkeiten)

|Kritik_Diskrepanz | Freq|
|:-----------------|----:|
|falsches positiv  |    8|
|korrekt           |   12|
|falsches negativ  |    1|
|uneindeutig       |    0|

*Datei: `tabs/T05_kritik_diskrepanz.csv`*

## T06 – Durchschnittliche Silhouette je Clusterzahl k

|  k| Ø Silhouette| kleinstes Cluster (n)|
|--:|------------:|---------------------:|
|  2|        0,203|                    10|
|  3|        0,379|                     6|
|  4|        0,458|                     4|
|  5|        0,531|                     2|
|  6|        0,525|                     1|
|  7|        0,534|                     1|
|  8|        0,508|                     1|
|  9|        0,385|                     1|
| 10|        0,307|                     1|

*Datei: `tabs/T06_silhouette_k.csv`*

## T07 – Silhouettenwerte pro Person

| Person-ID| Cluster| Silhouette|
|---------:|-------:|----------:|
|       241|       1|      0,577|
|       244|       2|      0,529|
|       257|       3|      0,457|
|       258|       1|      0,482|
|       259|       2|      0,549|
|       278|       2|      0,607|
|       314|       4|      0,526|
|       328|       2|       0,61|
|       334|       1|     -0,144|
|       339|       3|      0,391|
|       340|       3|      0,306|
|       341|       2|       0,64|
|       350|       1|       0,59|
|       360|       2|      -0,09|
|       361|       1|       0,58|
|       362|       4|      0,547|
|       363|       4|       0,59|
|       364|       3|      0,437|
|       365|       4|      0,581|
|       366|       1|      0,649|
|       367|       4|      0,206|

*Datei: `tabs/T07_silhouette_person.csv`*

## T08 – Cluster-Profile: mittlere Diskrepanz je Aufgabe

|Aufgabe                  | Cluster 1| Cluster 2| Cluster 3| Cluster 4|
|:------------------------|---------:|---------:|---------:|---------:|
|Informationssuche        |     0,083|    -0,217|      0,15|      0,02|
|Schreiben/Textarbeit     |     0,067|     0,083|     0,025|         0|
|Praktische Unterstützung |     -0,05|       0,1|      -0,2|      0,16|
|Technische Unterstützung |    -0,133|      0,05|    -0,025|     -0,16|
|Lernen/Prüfungsvorb.     |     0,033|    -0,017|      0,05|     -0,02|

*Datei: `tabs/T08_cluster_profile.csv`*

## T08b – Clustergrößen und Medoide

| Cluster| Größe (n)| Medoid (Person-ID)|
|-------:|---------:|------------------:|
|       1|         6|                366|
|       2|         6|                341|
|       3|         4|                257|
|       4|         5|                363|

*Datei: `tabs/T08b_cluster_groessen.csv`*

## T09b – Cluster-Zentren (Medoide): Diskrepanzprofile

| Cluster| Person_ID| Informationssuche| Schreiben/Textarbeit| Praktische Unterstützung| Technische Unterstützung| Lernen/Prüfungsvorb.|Sentiment      |Kritik           |
|-------:|---------:|-----------------:|--------------------:|------------------------:|------------------------:|--------------------:|:--------------|:----------------|
|       1|       366|               0,1|                    0|                        0|                     -0,1|                    0|unfreundlicher |korrekt          |
|       2|       341|              -0,2|                  0,2|                      0,1|                     -0,1|                    0|korrekt        |falsches positiv |
|       3|       257|               0,4|                    0|                     -0,6|                      0,2|                    0|korrekt        |korrekt          |
|       4|       363|               0,2|                 -0,2|                      0,1|                     -0,1|                    0|freundlicher   |korrekt          |

*Datei: `tabs/T09b_medoid_profile.csv`*

## T09c – Cluster-Zentren (Medoide): Kontextvariablen (Originalskalen)

| Cluster| Person_ID| Soz. Erwünschtheit| KI-Erfahrung| Nutzungshäufigkeit| Info-Literacy (wo)| Info-Literacy (wie)|
|-------:|---------:|------------------:|------------:|------------------:|------------------:|-------------------:|
|       1|       366|                  3|            3|                  4|                  3|                   3|
|       2|       341|               3,33|            5|                  4|                  5|                   4|
|       3|       257|               3,17|            5|                  5|                  4|                   4|
|       4|       363|                  4|            3|                  4|                  4|                   3|

*Datei: `tabs/T09c_medoid_kontext.csv`*

## T10 – Sentiment-Diskrepanz je Cluster

| Cluster| unfreundlicher| korrekt| freundlicher| uneindeutig|
|-------:|--------------:|-------:|------------:|-----------:|
|       1|              6|       0|            0|           0|
|       2|              1|       5|            0|           0|
|       3|              0|       4|            0|           0|
|       4|              0|       0|            5|           0|

*Datei: `tabs/T10_sentiment_je_cluster.csv`*

## T11 – Kritik-Diskrepanz je Cluster

| Cluster| falsches positiv| korrekt| falsches negativ| uneindeutig|
|-------:|----------------:|-------:|----------------:|-----------:|
|       1|                1|       5|                0|           0|
|       2|                6|       0|                0|           0|
|       3|                0|       3|                1|           0|
|       4|                1|       4|                0|           0|

*Datei: `tabs/T11_kritik_je_cluster.csv`*

## T12 – Soziale Erwünschtheit je Cluster (Welch-ANOVA)

| Cluster|    M|   SD|  n| p (Welch)|
|-------:|----:|----:|--:|---------:|
|       1| 3,39| 0,97|  6|    0,0706|
|       2| 3,78| 0,66|  6|    0,0706|
|       3| 2,46| 0,82|  4|    0,0706|
|       4|  3,9| 0,28|  5|    0,0706|

*Datei: `tabs/T12_socialdesir_cluster.csv`*

## T13 – Ordinale Kontextvariablen: Kruskal-Wallis-Tests

|Variable                        |  Chi²| df| p (Kruskal-Wallis)|
|:-------------------------------|-----:|--:|------------------:|
|KI-Erfahrung                    | 1,372|  3|             0,7122|
|Nutzungshäufigkeit              | 7,149|  3|             0,0673|
|Info-Literacy (wo suchen)       | 0,944|  3|             0,8148|
|Info-Literacy (wie formulieren) | 2,487|  3|             0,4777|

*Datei: `tabs/T13_ordinale_kruskal.csv`*

## T14 – Nominale Kontextvariablen: Chi-Quadrat-Tests

|Variable     |   Chi²| p (simuliert)|
|:------------|------:|-------------:|
|Geschlecht   |  6,913|         0,086|
|Fächergruppe | 16,005|        0,1729|
|Abschluss    |  5,558|        0,5807|

*Datei: `tabs/T14_nominale_chi2.csv`*

## T17 – Kontextvariablen-Profil der Cluster (Mittelwerte, Originalskalen)

|Variable                        |Skala | Cluster 1| Cluster 2| Cluster 3| Cluster 4| Spannweite (PP)|
|:-------------------------------|:-----|---------:|---------:|---------:|---------:|---------------:|
|Soziale Erwünschtheit           |1–5   |      3,39|      3,78|      2,46|       3,9|              36|
|KI-Erfahrung                    |1–5   |         4|      3,83|       4,5|       3,8|            17,5|
|Nutzungshäufigkeit              |2–6   |      4,17|       3,5|         5|       4,6|            37,5|
|Info-Literacy (wo suchen)       |1–5   |      4,17|         4|       4,5|       4,4|            12,5|
|Info-Literacy (wie formulieren) |1–5   |         4|         4|       4,5|       4,4|            12,5|

*Datei: `tabs/T17_kontext_profil.csv`*

## T19a – Geschlecht je Cluster (Häufigkeiten)

|Kategorie | Cluster 1| Cluster 2| Cluster 3| Cluster 4|
|:---------|---------:|---------:|---------:|---------:|
|männlich  |         3|         6|         1|         2|
|weiblich  |         3|         0|         3|         3|

*Datei: `tabs/T19a_gender_je_cluster.csv`*

## T19b – Fächergruppe je Cluster (Häufigkeiten)

|Kategorie        | Cluster 1| Cluster 2| Cluster 3| Cluster 4|
|:----------------|---------:|---------:|---------:|---------:|
|Sozialwiss.      |         3|         1|         4|         3|
|Recht/Wirtschaft |         0|         2|         0|         0|
|Mathe/Naturwiss. |         0|         2|         0|         1|
|Informatik       |         1|         0|         0|         1|
|Lehramt          |         2|         1|         0|         0|

*Datei: `tabs/T19b_field_je_cluster.csv`*

## T19c – Abschluss je Cluster (Häufigkeiten)

|Kategorie         | Cluster 1| Cluster 2| Cluster 3| Cluster 4|
|:-----------------|---------:|---------:|---------:|---------:|
|Bachelor          |         1|         2|         0|         1|
|Master            |         3|         3|         4|         4|
|Staatsex./Lehramt |         2|         1|         0|         0|

*Datei: `tabs/T19c_degree_je_cluster.csv`*

## T15 – Robustheitschecks: Übersicht

|Check                 |Beschreibung           | Ø Silhouette|
|:---------------------|:----------------------|------------:|
|1: ohne Tie-Sentiment |3 Fälle ausgeschlossen |        0,411|
|2: ohne Gewichtung    |k = 4                  |        0,258|
|3: Average-Linkage    |k = 4                  |           NA|

*Datei: `tabs/T15_robustheit_uebersicht.csv`*

## T15b – PAM (gewichtet) vs. PAM (ungewichtet)

| PAM-Cluster| Ungewichtet 1| Ungewichtet 2| Ungewichtet 3| Ungewichtet 4|
|-----------:|-------------:|-------------:|-------------:|-------------:|
|           1|             5|             0|             1|             0|
|           2|             0|             6|             0|             0|
|           3|             2|             0|             2|             0|
|           4|             0|             0|             0|             5|

*Datei: `tabs/T15b_pam_vs_ungewichtet.csv`*

## T16 – PAM vs. hierarchisches Clustering

| PAM-Cluster| Hierarchisch 1| Hierarchisch 2| Hierarchisch 3| Hierarchisch 4|
|-----------:|--------------:|--------------:|--------------:|--------------:|
|           1|              5|              1|              0|              0|
|           2|              0|              6|              0|              0|
|           3|              0|              0|              4|              0|
|           4|              0|              0|              0|              5|

*Datei: `tabs/T16_pam_vs_hierarchisch.csv`*

