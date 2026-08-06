#####################################################
##### Datenaufbereitung und Opperationalisierung#####
#####################################################

#mfaje dateset 

data <- data.frame(
  id                       = c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30),
  gender                   = c(1,2,1,2,3,1,2,1,2,-1,1,1,1,1,2,2,2,2,2,2,1,1,2,3,1,1,2,2,3,1),
  age                      = c(22,24,21,23,26,20,29,22,25,23,23,24,24,28,26,27,28,21,27,23,30,27,21,29,19,24,20,24,19,28),
  degree                   = c(1,2,1,1,2,1,1,2,1,1,2,1,2,2,1,1,2,1,1,2,2,2,1,1,2,2,1,1,2,1),
  field                    = c(3,8,5,1,4,8,3,2,5,7,10,8,5,10,3,4,7,9,7,6,11,11,7,3,1,7,6,2,4,6),
  sd_1                     = c(4,3,5,3,4,2,4,3,5,3,1,2,4,3,2,5,5,1,5,4,4,1,5,4,5,4,4,2,1,1),
  sd_2                     = c(4,3,5,2,3,3,4,3,4,4,2,5,2,5,2,2,4,2,3,4,5,3,1,4,3,4,5,2,4,5),
  sd_3                     = c(5,4,5,3,4,3,4,3,5,3,5,5,5,5,2,4,3,4,3,5,1,4,2,1,4,2,2,2,2,3),
  sd_4                     = c(2,2,1,3,2,4,2,3,1,2,4,1,4,1,4,5,2,3,3,2,3,5,4,3,1,1,5,1,4,1),
  sd_5                     = c(1,2,1,3,2,3,1,2,2,2,3,4,5,3,2,4,3,4,5,4,3,2,1,2,3,3,1,3,5,2),
  sd_6                     = c(2,3,1,3,2,4,2,3,1,3,1,2,4,2,4,5,5,3,1,4,1,1,2,3,5,2,3,1,4,3),
  ai_experience            = c(4,3,5,2,4,3,5,3,4,2,5,1,3,4,3,3,4,1,2,4,3,2,2,2,5,3,4,2,5,4),
  uses_gemini              = c(1,0,1,0,0,1,1,0,0,0,0,0,1,0,0,1,0,0,0,1,0,1,0,1,1,1,0,0,1,0),
  uses_copilot             = c(0,1,0,0,1,0,0,0,1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,1,0,1,0,0),
  uses_deepseek            = c(0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0),
  uses_claude              = c(1,0,0,0,0,1,0,0,1,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
  freq                     = c(5,4,6,3,5,4,6,3,5,2,5,4,2,2,4,3,2,2,2,2,6,4,6,5,3,5,3,6,2,3),
  info_literacy_where      = c(4,3,5,2,4,4,5,3,4,2,3,2,2,5,1,5,5,5,3,4,1,2,5,3,3,4,2,2,4,3),
  info_literacy_how        = c(4,4,5,3,4,3,5,3,4,3,3,1,1,5,4,4,5,5,1,1,1,5,3,2,4,1,2,1,5,3),
  info_use_1               = c(4,3,5,2,4,4,5,3,4,2,5,1,5,4,3,3,4,2,1,3,4,5,1,1,3,2,2,1,1,3), ##??? Falsche ausprägung addiert sich nicht auf 10 ist aus einer älteren version
  info_use_2               = c(5,3,4,2,5,3,4,4,3,2,5,2,5,1,2,2,1,3,4,5,2,5,5,1,3,5,1,1,1,3),
  info_use_3               = c(3,4,3,2,3,4,3,3,4,2,3,3,5,4,4,4,3,1,1,1,3,1,3,4,4,4,5,5,2,3),
  info_use_4               = c(2,2,4,1,2,5,2,2,1,1,2,5,1,5,5,4,3,4,4,1,4,3,5,2,2,2,3,3,2,1),
  info_use_5               = c(4,3,4,3,3,2,4,3,4,3,4,2,2,3,4,4,1,3,4,2,1,5,4,1,5,2,4,3,4,3),
  inter_style              = c(1,2,2,3,1,4,2,3,1,2,2,3,4,4,4,2,3,2,4,5,1,5,2,2,4,1,4,4,5,3),
  crit_visible_chat        = c(4,2,3,1,4,3,2,2,4,1,4,1,2,3,1,1,2,4,2,2,4,2,3,3,2,2,4,4,1,2),
  n_chats_valid            = c(5,5,5,5,5,4,5,5,4,5,5,5,5,4,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5),
  obs_info_n               = c(1,2,1,1,2,0,1,1,1,0,1,0,1,0,0,1,0,1,0,0,0,1,4,2,0,0,2,1,1,0),
  obs_schreiben_n          = c(2,1,1,0,2,1,1,2,1,1,1,0,0,2,0,1,2,1,2,2,3,1,1,1,1,1,0,0,1,2),
  obs_praktisch_n          = c(1,1,1,1,0,1,1,1,1,1,0,4,1,1,1,2,1,0,1,0,1,0,0,2,0,1,0,1,0,0),
  obs_technisch_n          = c(0,0,2,0,0,2,0,0,0,0,2,1,2,1,2,0,0,1,2,1,1,2,0,0,1,1,2,2,1,2),
  obs_lernen_n             = c(1,1,0,3,1,0,2,1,1,3,1,0,1,0,2,1,2,2,0,2,0,1,0,0,3,2,1,1,2,1),
  obs_sent_freundlich_n    = c(4,2,3,1,4,0,2,1,1,2,0,1,3,4,5,2,2,0,3,1,2,3,1,3,3,2,3,5,3,2),
  obs_sent_neutral_n       = c(1,2,2,3,1,2,2,2,2,3,1,4,2,0,0,2,3,3,1,3,2,0,2,1,1,2,2,0,1,3),
  obs_sent_unfreundlich_n  = c(0,1,0,1,0,2,1,2,1,0,4,0,0,0,0,1,0,2,1,1,1,2,2,1,1,1,0,0,1,0),
  obs_kritisch_ja_n        = c(4,1,2,0,3,1,1,2,1,0,2,2,0,3,3,0,1,3,1,3,3,2,2,2,1,1,1,2,1,2),
  obs_kritisch_nein_n      = c(1,4,3,5,2,3,4,3,3,5,3,3,5,1,2,5,4,2,4,2,2,3,3,3,4,4,4,3,4,3),
  self_assess_1            = c(4,3,5,2,4,3,4,3,5,2,1,1,1,3,1,4,4,3,1,1,3,2,3,1,4,3,3,3,5,4),
  self_assess_2            = c(3,4,2,4,3,4,2,3,2,4,4,2,2,3,3,5,1,4,4,2,4,5,1,2,4,4,3,2,3,2),
  self_assess_3            = c(4,3,4,3,4,3,4,3,5,2,2,5,2,2,3,4,3,4,2,1,4,3,2,4,1,3,4,2,3,5)
)






#Daten laden

data <- read.csv("/home/theo/PycharmProjects/Masterprojekt-Chatbots/data/processed/perp_dataset.csv")

# info_use_1-5 ist eine 10-Punkte-Verteilungsaufgabe: leeres Feld = 0 vergebene
# Punkte, kein echtes Missing -> NA auf 0 rekodieren
info_use_cols <- paste0("info_use_", 1:5)
data[info_use_cols][is.na(data[info_use_cols])] <- 0

# Absicherung: pro Person muessen genau 10 Punkte vergeben sein
stopifnot(all(rowSums(data[info_use_cols]) == 10))


# Konsistenzcheck: Rohcounts muessen sich zu n_chats_valid summieren
stopifnot(all(rowSums(data[,c("obs_info_n","obs_schreiben_n","obs_praktisch_n",
                                "obs_technisch_n","obs_lernen_n")]) == data$n_chats_valid))
stopifnot(all(rowSums(data[,c("obs_sent_freundlich_n","obs_sent_neutral_n",
                                "obs_sent_unfreundlich_n")]) == data$n_chats_valid))
stopifnot(all(data$obs_kritisch_ja_n + data$obs_kritisch_nein_n == data$n_chats_valid))


################################
#Aggregation der Chat_varibalen#
################################

###Aufgaben###
n_chats_derived <- rowSums(data[, c("obs_info_n","obs_schreiben_n","obs_praktisch_n",
                                    "obs_technisch_n","obs_lernen_n")])
stopifnot(all(n_chats_derived == data$n_chats_valid))

data$n_chats_valid <- n_chats_derived

#Inhalt: Rohcounts -> Anteile (BE_i)
data$BE_info       <- data$obs_info_n       / data$n_chats_valid
data$BE_schreiben  <- data$obs_schreiben_n  / data$n_chats_valid
data$BE_praktisch  <- data$obs_praktisch_n  / data$n_chats_valid
data$BE_technisch  <- data$obs_technisch_n  / data$n_chats_valid
data$BE_lernen     <- data$obs_lernen_n     / data$n_chats_valid


###Sentiment####

#codeirung von sentiment 0 ist neutral
sent_codes <- c(-1, 0, 1)

get_modus_sentiment <- function(counts) {
  max_n <- max(counts)
  tied  <- which(counts == max_n)
  if (length(tied) == 1) {
    return(sent_codes[tied])
  }
  # Tie-Break: neutraö 0 wählen
  dists <- abs(sent_codes[tied])
  if (length(unique(dists)) == 1) return(0)
  sent_codes[tied][which.min(dists)]
}


sent_counts <- data[, c("obs_sent_freundlich_n","obs_sent_neutral_n","obs_sent_unfreundlich_n")]
data$Modus_Sentiment <- apply(sent_counts, 1, get_modus_sentiment)
data$Modus_Sentiment_Label <- factor(data$Modus_Sentiment, levels = c(-1,0,1),
                                     labels = c("freundlich","neutral","unfreundlich"),
                                     ordered = TRUE)


###Kritisches Nachfragen###

get_modus_kritik <- function(ja, nein) {
  if (ja > nein)  return(1)
  if (nein > ja)  return(0)
  return(NA)   
}

data$Modus_Kritik <- mapply(get_modus_kritik, data$obs_kritisch_ja_n, data$obs_kritisch_nein_n)
data$Modus_Kritik_Label <- factor(data$Modus_Kritik, levels = c(0,1), labels = c("Nein","Ja"))

# Wie viele Cases waren nicht eindeutig
n_tied_sentiment <- sum(apply(sent_counts, 1, function(x) sum(x == max(x)) > 1))
n_tied_kritik     <- sum(is.na(data$Modus_Kritik))
cat("Gleichstaende bei Sentiment:", n_tied_sentiment, "von", nrow(data), "\n")
cat("Gleichstaende bei Kritik:   ", n_tied_kritik, "von", nrow(data), "\n")

data[, c("id","n_chats_valid","Modus_Sentiment_Label","Modus_Kritik_Label")]


###########################
# Diskrepanzmaße berechnen#
###########################


####Aufgaben/Inhalt######

#SAi Reskalieren: 10-Punkte-Verteilung -> Anteil [0,1]
data$SA_info      <- data$info_use_1 / 10
data$SA_schreiben <- data$info_use_2 / 10
data$SA_praktisch <- data$info_use_3 / 10
data$SA_technisch <- data$info_use_4 / 10
data$SA_lernen    <- data$info_use_5 / 10

#D_i = SA_i - BE_i, je Inhaltskategorie ----
data$D_info      <- data$SA_info      - data$BE_info
data$D_schreiben <- data$SA_schreiben - data$BE_schreiben
data$D_praktisch <- data$SA_praktisch - data$BE_praktisch
data$D_technisch <- data$SA_technisch - data$BE_technisch
data$D_lernen    <- data$SA_lernen    - data$BE_lernen


####Sentiment####

# SA auf dieselbe 3-Kategorien kodiern wie Modus_Sentiment
data$SA_sent_code <- cut(data$inter_style,
                         breaks = c(-Inf, 2, 3, Inf),
                         labels = c(-1, 0, 1))
data$SA_sent_code <- as.numeric(as.character(data$SA_sent_code))

data$S_Diskrepanz <- sign(data$SA_sent_code - data$Modus_Sentiment)
data$S_Diskrepanz_Label <- factor(data$S_Diskrepanz, levels = c(-1, 0, 1),
                                  labels = c("unfreundlicher", "korrekt", "freundlicher"),
                                  ordered = TRUE)

#########Kritisches Nachfragen##


# SA: crit_visible_chat (1-4) dichotomisieren (1-2 -> Nein, 3-4 -> Ja)
data$SA_krit_code <- ifelse(data$crit_visible_chat >= 3, 1, 0)

# -1 = falsches positiv (SA=Ja, BE=Nein), 
# 0 = korrekt, 
# 1 = falsches negativ (SA=Nein, BE=Ja)

data$K_Diskrepanz <- data$Modus_Kritik - data$SA_krit_code
data$K_Diskrepanz_Label <- factor(data$K_Diskrepanz, levels = c(-1, 0, 1),
                                  labels = c("falsches positiv", "korrekt", "falsches negativ"))

data[, c("id", "D_info","D_schreiben","D_praktisch","D_technisch","D_lernen",
         "S_Diskrepanz_Label","K_Diskrepanz_Label")]

########################
#soziale Erwünschtheit#
#######################

# Negativ kodierte Items umpolen 
data$sd_4_rec <- 6 - data$sd_4
data$sd_5_rec <- 6 - data$sd_5
data$sd_6_rec <- 6 - data$sd_6

# Summen- und Mittelwertscore über alle 6 Items
data$social_desir_sum  <- data$sd_1 + data$sd_2 + data$sd_3 +
  data$sd_4_rec + data$sd_5_rec + data$sd_6_rec
data$social_desir_mean <- data$social_desir_sum / 6

# install.packages("psych")  # falls nicht vorhanden
#library(psych)
#alpha(data[, c("sd_1","sd_2","sd_3","sd_4_rec","sd_5_rec","sd_6_rec")])




######################
# Variablenlabels#
#######################
#install.packages("labelled")  # falls noch nicht installiert
library(labelled)

var_labels_list <- list(
  id     = "Personen-ID",
  gender = "Geschlecht",
  age    = "Alter in Jahren",
  degree = "Angestrebter Studienabschluss",
  field  = "Fächergruppe des Studienfachs",
  
  sd_1 = "Soz. Erwünschtheit: sachlich im Streit (PQ+)",
  sd_2 = "Soz. Erwünschtheit: freundlich trotz Stress (PQ+)",
  sd_3 = "Soz. Erwünschtheit: aufmerksames Zuhören (PQ+)",
  sd_4 = "Soz. Erwünschtheit: jemanden ausgenutzt (PQ-)",
  sd_5 = "Soz. Erwünschtheit: Müll weggeworfen (PQ-)",
  sd_6 = "Soz. Erwünschtheit: Hilfe nur mit Gegenleistung (PQ-)",
  
  sd_4_rec = "Soz. Erwünschtheit: jemanden ausgenutzt, umgepolt",
  sd_5_rec ="Soz. Erwünschtheit: Müll weggeworfen, umgepolt",
  sd_6_rec = "Soz. Erwünschtheit: Hilfe nur mit Gegenleistung, umgepolt",
  social_desir_sum = "Soziale Erwünschtheit: Summenscore (6 Items, Range 6-30)",
  social_desir_mean ="Soziale Erwünschtheit: Mittelwert (6 Items, Range 1-5)",
  
  ai_experience = "Vertrautheit mit generativen KI-Chatbots",
  uses_gemini   = "Nutzung Google Gemini",
  uses_copilot  = "Nutzung Microsoft/Bing Copilot",
  uses_deepseek = "Nutzung DeepSeek",
  uses_claude   = "Nutzung Claude",
  
  freq = "Nutzungshäufigkeit von ChatGPT im Studium",
  
  info_literacy_where = "Weiß, wo/wie relevante Infos mit KI zu finden sind",
  info_literacy_how   = "Weiß, wie Eingaben zu formulieren sind",
  
  info_use_1 = "SA Nutzungszweck: Informationssuche und Verständnis",
  info_use_2 = "SA Nutzungszweck: Schreiben und Textarbeit",
  info_use_3 = "SA Nutzungszweck: Praktische Unterstützung/Strukturierung",
  info_use_4 = "SA Nutzungszweck: Technische/analytische Unterstützung",
  info_use_5 = "SA Nutzungszweck: Lernen und Prüfungsvorbereitung",
  
  inter_style       = "SA: typischer Interaktionsstil",
  crit_visible_chat = "SA: fordert Hinweise zur kritischen Prüfung ein",
  
  n_chats_valid = "Anzahl gültiger gespendeter Chats",
  
  obs_info_n      = "Rohcount: Chats = Informationssuche",
  obs_schreiben_n = "Rohcount: Chats = Schreiben/Textarbeit",
  obs_praktisch_n = "Rohcount: Chats = Praktische Unterstützung",
  obs_technisch_n = "Rohcount: Chats = Technische Unterstützung",
  obs_lernen_n    = "Rohcount: Chats = Lernen/Prüfungsvorbereitung",
  
  obs_sent_freundlich_n   = "Rohcount: Chats mit Sentiment freundlich",
  obs_sent_neutral_n      = "Rohcount: Chats mit Sentiment neutral",
  obs_sent_unfreundlich_n = "Rohcount: Chats mit Sentiment unfreundlich",
  
  obs_kritisch_ja_n   = "Rohcount: Chats mit kritischem Nachfragen = Ja",
  obs_kritisch_nein_n = "Rohcount: Chats mit kritischem Nachfragen = Nein",
  
  self_assess_1 = "SE: Angaben spiegeln tatsächl. Nutzung gut wider",
  self_assess_2 = "SE: Nutzung unterscheidet sich stark je Aufgabe",
  self_assess_3 = "SE: Chatlogs spiegeln typische Nutzung gut wider",
  
  BE_info = "Beobachteter Anteil: Informationssuche",
  BE_schreiben = "Beobachteter Anteil: Schreiben/Textarbeit",
  BE_praktisch = "Beobachteter Anteil: Praktische Unterstützung",
  BE_technisch = "Beobachteter Anteil: Technische Unterstützung",
  BE_lernen = "Beobachteter Anteil: Lernen/Prüfungsvorbereitung",
  BE_sent_freundlich = "Beobachteter Anteil: Sentiment freundlich",
  BE_sent_neutral = "Beobachteter Anteil: Sentiment neutral",
  BE_sent_unfreundlich = "Beobachteter Anteil: Sentiment unfreundlich",
  BE_kritisch = "Beobachteter Anteil: kritisches Nachfragen = Ja",
  
  Modus_Sentiment       = "Modus-Sentiment über alle Chats",
  Modus_Sentiment_Label = "Modus-Sentiment über alle Chats (Faktor, geordnet)",
  Modus_Kritik          = "Modus kritisches Nachfragen über alle Chats",
  Modus_Kritik_Label    = "Modus kritisches Nachfragen über alle Chats (Faktor)",
  
  SA_info      = "SA reskaliert [0,1]: Informationssuche",
  SA_schreiben = "SA reskaliert [0,1]: Schreiben/Textarbeit",
  SA_praktisch = "SA reskaliert [0,1]: Praktische Unterstützung",
  SA_technisch = "SA reskaliert [0,1]: Technische Unterstützung",
  SA_lernen    = "SA reskaliert [0,1]: Lernen/Prüfungsvorbereitung",
  
  D_info      = "Diskrepanz (SA-BE): Informationssuche",
  D_schreiben = "Diskrepanz (SA-BE): Schreiben/Textarbeit",
  D_praktisch = "Diskrepanz (SA-BE): Praktische Unterstützung",
  D_technisch = "Diskrepanz (SA-BE): Technische Unterstützung",
  D_lernen    = "Diskrepanz (SA-BE): Lernen/Prüfungsvorbereitung",
  
  SA_sent_code = "SA-Sentiment, 3-kategorial kodiert (-1/0/1)",
  S_Diskrepanz = "Diskrepanz Sentiment (kategorial)",
  S_Diskrepanz_Label = "Diskrepanz Sentiment: Richtung der Abweichung",
  
  SA_krit_code = "SA kritisches Nachfragen, dichotomisiert (0=Nein,1=Ja)",
  K_Diskrepanz = "Diskrepanz kritisches Nachfragen (kategorial)",
  K_Diskrepanz_Label = "Diskrepanz kritisches Nachfragen: Fehlertyp"
  
)

# Nur Labels fuer tatsaechlich vorhandene Spalten setzen
var_label(data) <- var_labels_list[names(var_labels_list) %in% names(data)]


###################
#Ausprägungslables#
###################

zustimmung_5 <- c("stimme überhaupt nicht zu"=1, "stimme eher nicht zu"=2,
                  "teils/teils"=3, "stimme eher zu"=4, "stimme voll und ganz zu"=5)
trifft_zu_5  <- c("trifft gar nicht zu"=1, "trifft eher nicht zu"=2,
                  "teils/teils"=3, "trifft eher zu"=4, "trifft voll und ganz zu"=5)

#hilfsfunktion zum setzen von labels nur wenn diese auch im Datensatz sind

setzen_falls_vorhanden <- function(df, var, labels) {
  if (var %in% names(df)) val_labels(df[[var]]) <- labels
  df
}

data <- setzen_falls_vorhanden(data, "gender",
                               c("männlich"=1,"weiblich"=2,"non-binär/divers"=3,"keine Angabe"=-1))
data <- setzen_falls_vorhanden(data, "degree",
                               c("Bachelor"=1,"Master"=2,"Staatsexamen/Lehramt"=3,"Promotion"=4,"anderer Abschluss"=5))
data <- setzen_falls_vorhanden(data, "field",
                               c("Geistes-/Kulturwiss."=1,"Sprach-/Literaturwiss."=2,"Sozialwiss."=3,
                                 "Rechts-/Wirtschaftswiss."=4,"Mathematik/Naturwiss."=5,"Medizin/Gesundheitswiss."=6,
                                 "Ingenieurwiss."=7,"Informatik"=8,"Kunst/Musik/Gestaltung"=9,"Lehramt"=10,"anderes Fach"=11))

for (v in c("sd_1","sd_2","sd_3","sd_4","sd_5","sd_6")) data <- setzen_falls_vorhanden(data, v, trifft_zu_5)

data <- setzen_falls_vorhanden(data, "ai_experience",
                               c("gar nicht vertraut"=1,"eher nicht vertraut"=2,"teils/teils"=3,
                                 "eher vertraut"=4,"sehr vertraut"=5))

for (v in c("uses_gemini","uses_copilot","uses_deepseek","uses_claude"))
  data <- setzen_falls_vorhanden(data, v, c("nein"=0,"ja"=1))

data <- setzen_falls_vorhanden(data, "freq",
                               c("seltener als 1x/Monat"=2,"1-3x/Monat"=3,"1x/Woche bis mehrmals/Woche"=4,
                                 "täglich/fast täglich"=5,"mehrmals täglich"=6))

# info_use_1-5 sind Punktwerte (0-10), keine Zustimmungsskala -> keine Wertelabels
for (v in c("info_literacy_where","info_literacy_how",
            "self_assess_1","self_assess_2","self_assess_3"))
  data <- setzen_falls_vorhanden(data, v, zustimmung_5)

data <- setzen_falls_vorhanden(data, "inter_style",
                               c("sehr freundlich"=1,"eher freundlich"=2,"neutral"=3,"eher unfreundlich"=4,"sehr unfreundlich"=5))

data <- setzen_falls_vorhanden(data, "crit_visible_chat",
                               c("stimme überhaupt nicht zu"=1,"stimme eher nicht zu"=2,
                                 "stimme eher zu"=3,"stimme voll und ganz zu"=4))

data <- setzen_falls_vorhanden(data, "Modus_Sentiment", c("freundlich"=-1,"neutral"=0,"unfreundlich"=1))
data <- setzen_falls_vorhanden(data, "Modus_Kritik", c("Nein"=0,"Ja"=1))

val_label(data$S_Diskrepanz, -1) <- "unfreundlicher"
val_label(data$S_Diskrepanz, 0)  <- "korrekt"
val_label(data$S_Diskrepanz, 1)  <- "freundlicher"

val_label(data$K_Diskrepanz, -1) <- "falsches positiv"
val_label(data$K_Diskrepanz, 0)  <- "korrekt"
val_label(data$K_Diskrepanz, 1)  <- "falsches negativ"

val_label(data$SA_krit_code, 0) <- "Nein"
val_label(data$SA_krit_code, 1) <- "Ja"



#################
#Sampling########
#################

###Fälle ausschließen die keine 5 gültgen Chats haben 
n_vorher <- nrow(data)
ausgeschlossen <- data[data$n_chats_valid < 5, "id"]

data <- data[data$n_chats_valid == 5, ]

cat("n vorher:", n_vorher, "-> n nachher:", nrow(data))

write.csv(data, "/home/theo/PycharmProjects/Masterprojekt-Chatbots/data/processed/analysis_dataset.csv", row.names = FALSE)
saveRDS(data, "/home/theo/PycharmProjects/Masterprojekt-Chatbots/data/processed/analysis_dataset.rds")


