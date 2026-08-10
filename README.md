# Selbstauskunft und beobachtete Nutzung generativer KI-Chatbots

Dieses Repositorium enthält Materialien und Analyseskripte eines Masterprojekts zur studienbezogenen Nutzung generativer KI-Chatbots. 
Untersucht wird, inwiefern sich die Selbstauskünfte Studierender von den Nutzungsmustern unterscheiden, die in freiwillig gespendeten ChatGPT-Chatlogs beobachtet werden können.

Die Chatlogs werden dabei nicht als vollständiges Abbild der „tatsächlichen“ Nutzung verstanden. 
Sie bilden einen von den Teilnehmenden ausgewählten Ausschnitt ab, der mit den Surveyangaben verglichen wird.

## Forschungsfragen

Das Projekt behandelt insbesondere folgende Fragen:

1. Inwiefern unterscheiden sich Selbstauskünfte und beobachtete Nutzung insgesamt?
2. Bei welchen Dimensionen der Informationsnutzung treten besonders häufig Übereinstimmungen oder Diskrepanzen auf?
3. Welche Arten studienbezogener Informationsnutzung lassen sich in den Chatlogs identifizieren und wie stimmen sie mit den Surveyangaben überein?
4. Inwiefern stimmen Selbstauskünfte zum kritischen Prüfen von KI-Antworten mit dem in den Chatlogs beobachtbaren Verhalten überein?
5. Inwiefern stimmt der berichtete Interaktionsstil mit dem in den Chatlogs beobachtbaren Stil überein?
6. Welche typischen personenbezogenen Diskrepanzmuster lassen sich explorativ über die untersuchten Dimensionen hinweg identifizieren?

## Datengrundlage

Die finale Analysestichprobe umfasst 21 Studierende. Pro Person liegen fünf gültige, freiwillig gespendete ChatGPT-Chatlogs vor, insgesamt also 105 Chats. 
Verglichen werden Survey- und Chatlogmerkmale in drei Bereichen:

- Art der studienbezogenen Informationsnutzung,
- kritisches Prüfen von KI-Antworten,
- Interaktionsstil gegenüber ChatGPT.

Die Chatlogs wurden mithilfe eines Large Language Models klassifiziert. 
Die Güte dieser Klassifikation wurde anhand eines manuell codierten Goldstandards geprüft. 
Aus den Klassifikationen wurden anschließend personenbezogene Indikatoren gebildet und mit den Surveyangaben verglichen.

## Analyseablauf

1. Export und Aufbereitung der Survey- und Chatlogdaten
2. Validierung der LLM-basierten Klassifikation anhand eines Goldstandards
3. Klassifikation und Aggregation der fünf Chatlogs je Person
4. Verknüpfung der Chatlogmerkmale mit den Surveyangaben
5. Bildung der Survey-, Beobachtungs- und Diskrepanzmaße
6. Deskriptiver Vergleich und explorative Clusteranalyse
7. Erstellung von Tabellen, Abbildungen und Manuskript

## Struktur des Repositoriums

| Pfad | Inhalt |
|---|---|
| `index.qmd` | Hauptdokument des Projektberichts |
| `_quarto.yml` | Quarto-Konfiguration für die PDF-Ausgabe |
| `R_code/data_prep.R` | Aufbereitung und Verknüpfung der Analysedaten |
| `R_code/04_discrepancy_analysis.R` | Deskriptive Analyse der Diskrepanzen |
| `R_code/data_analasys.R` | Clusteranalyse und ergänzende Auswertungen |
| `Python_code/Gold_standard.ipynb` | Erstellung und Aufbereitung des Goldstandards |
| `Python_code/llm_pipeline_openai_gold.ipynb` | Evaluation der LLM-Klassifikation |
| `Python_code/Data_pipeline.ipynb` | Aufbereitung und Klassifikation der Chatlogs |
| `data/raw/` | Nicht veröffentlichte Rohdaten |
| `data/processed/` | Bereinigte und abgeleitete Datensätze |
| `plots/` | Erzeugte Abbildungen |
| `tabs/` | Erzeugte Tabellen |
| `manuscript/` | Literatur, Vorlagen und weitere Manuskriptmaterialien |
| `WORKFLOW.md` | Ausführlichere technische Dokumentation des Datenworkflows |

Der Dateiname `data_analasys.R` wird hier entsprechend dem gegenwärtigen Stand des Projekts wiedergegeben.

## Reproduktion der R-Analysen

### Voraussetzungen

- R und RStudio
- Quarto
- eine LaTeX-Installation mit XeLaTeX, beispielsweise TinyTeX
- das R-Paket `renv`

Nach dem Klonen des Repositoriums werden zunächst die dokumentierten R-Paketversionen wiederhergestellt:

```r
renv::restore()
```

Vorausgesetzt, die benötigten aufbereiteten Daten liegen in `data/processed/`, kann anschließend der vollständige Bericht aus dem Projektverzeichnis gerendert werden:

```bash
quarto render index.qmd --to pdf
```

Das Quarto-Dokument führt die erforderlichen R-Skripte in der vorgesehenen Reihenfolge aus. Für die schrittweise Fehlersuche können sie auch einzeln ausgeführt werden:

```bash
Rscript R_code/data_prep.R
Rscript R_code/data_analasys.R
Rscript R_code/04_discrepancy_analysis.R
```

Die vollständige Verarbeitung ab den Rohdaten erfordert zusätzlich Python, Zugriff auf die privaten Erhebungsdaten und lokal hinterlegte Zugangsdaten. Einzelheiten enthält [`WORKFLOW.md`](WORKFLOW.md).

## Zentrale erzeugte Dateien

- `data/processed/analysis_dataset.csv` und `analysis_dataset.rds`: personenbezogener Analysedatensatz
- `plots/`: Abbildungen der deskriptiven Analysen und Clusteranalyse
- `tabs/`: exportierte Ergebnistabellen
- `index.pdf`: gerenderter Projektbericht

Erzeugte Dateien sollten möglichst über die zugehörigen Skripte aktualisiert und nicht manuell verändert werden.

## Datenschutz und Datenzugang

Die Rohdaten enthalten freiwillig gespendete Chatverläufe und potenziell sensible Surveyangaben. Deshalb gilt:

- Rohdaten aus `data/raw/` werden nicht veröffentlicht oder in Git eingecheckt.
- API-Schlüssel und andere Zugangsdaten werden ausschließlich lokal gespeichert.
- Veröffentlichte oder weitergegebene Datensätze dürfen nur anonymisierte beziehungsweise ausreichend aggregierte Informationen enthalten.
- Eine Reproduktion ab den Rohdaten ist nur mit entsprechender Zugangsberechtigung möglich.

## Grenzen der Analyse

Die Ergebnisse sind explorativ zu interpretieren. Die Stichprobe ist klein und nicht repräsentativ. 
Zudem stellen die gespendeten Chats lediglich einen ausgewählten Ausschnitt der individuellen Nutzung dar. 
Auch die LLM-basierte Klassifikation ist mit Messunsicherheit verbunden. 

## Weitere Materialien

- Präregistrierung und Projektmaterialien: [OSF](https://osf.io/pqdhb)
- Technische Dokumentation: [`WORKFLOW.md`](WORKFLOW.md)
- Lizenzinformationen: [`LICENSE`](LICENSE)

## Projektteam

Laura Kiemes, Hannah Laier und Theo Wiesholler, Ludwig-Maximilians-Universität München
