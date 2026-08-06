"""

Klassifiziert die aufbereiteten Chat-Daten (chats_long.csv aus der Data-Pipeline)
mit GPT-5.5 über einen kombinierten Prompt nach drei Kriterien:
  - task      (Aufgabentyp, 5 Klassen)
  - sentiment (Ton, 3 Klassen)
  - critical  (kritische Überprüfung, 2 Klassen)

Eingabe : df_chats (long, eine Zeile pro Nachricht) mit Spalten
          chat_id, teilnehmer_id, frage_code, turn, role, content
Ausgabe : df_labeled (eine Zeile pro Chat) mit Spalten
          chat_id, teilnehmer_id, frage_code, task, sentiment, critical,
          chat_text (an das Modell geschickter Text, zum Prüfen der Labels),
          raw_response (unveränderte Modellantwort)
"""
from __future__ import annotations

import hashlib
import json
import os
import time
from pathlib import Path
from typing import List, Optional

import pandas as pd
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_openai import ChatOpenAI


# ============================================================
# Labels
# ============================================================
LABELS_TASK = [
    "Informationssuche und Verständnis",
    "Schreiben und Textarbeit",
    "Praktische Unterstützung und Strukturierung",
    "Technische und analytische Unterstützung",
    "Lernen und Prüfungsvorbereitung",
]
LABELS_SENTIMENT = ["Unfreundlich", "Neutral", "Freundlich"]
LABELS_CRITICAL  = ["Ja", "Nein"]


# ============================================================
# Kombinierter Prompt (identisch zur Evaluations-Pipeline)
# ============================================================
prompt_combined = ChatPromptTemplate.from_messages([
    ("system", """Du bist ein Klassifikationssystem für akademische Chat-Logs.
Analysiere das folgende Chat-Log und klassifiziere es nach drei Kriterien.

KRITERIUM 1 – Aufgabentyp:
(1) Informationssuche und Verständnis, z. B. um Literaturhinweise, Suchbegriffe oder Rechercheansätze zu erhalten, Theorien und Konzepte erklären zu lassen oder Verständnisfragen zu Studieninhalten zu klären.

(2) Schreiben und Textarbeit, z. B. um Feedback zu eigenen Texten zu erhalten, Gliederungen zu erstellen, Texte zusammenfassen zu lassen, Textbausteine oder Formulierungsvorschläge zu erstellen oder Texte zu übersetzen bzw. sprachlich zu überarbeiten.

(3) Praktische Unterstützung und Strukturierung, z. B. um Ideen für eine Hausarbeit, einen Essay oder eine Präsentation zu entwickeln, ein Projekt zu strukturieren, nächste Arbeitsschritte zu planen oder Unterstützung bei Problemlösung und Entscheidungsfindung zu erhalten.

(4) Technische und analytische Unterstützung, z. B. um Code zu erstellen oder zu überarbeiten, Datenanalysen oder Datenvisualisierungen vorzubereiten oder Ergebnisse aus Statistik- und Analyseprogrammen wie R, Stata oder SPSS interpretieren zu lassen.

(5) Lernen und Prüfungsvorbereitung, z. B. um sich auf Prüfungen vorzubereiten oder Lernfragen, Übungsaufgaben oder Karteikarten zu erstellen.

KRITERIUM 2 – Ton/Sentiment:
Bewerte den Ton als:

"Unfreundlich" wenn die Person:
- Sehr kurze, befehlsartige Nachrichten schreibt
- Ungeduld oder Frustration zeigt
- fordernd oder abweisend wirkt

 "Freundlich"  wenn die Person:
- Begrüßungen verwendet
- Explizit "bitte" oder "danke" schreibt
- Wertschätzung oder positive Rückmeldung ausdrückt

"Neutral"  die Person:
- Sachlich und aufgabenorientiert schreibt
- Technische Fragen oder Code ohne emotionalen Ton stellt
- Direkt zur Sache kommt ohne besondere Freundlichkeit oder Unfreundlichkeit
- Im Zweifel: Neutral ist der Standard für akademisch-technische Chats

KRITERIUM 3 – Kritische Überprüfung:
Überprüft oder hinterfragt die Person die KI-Antworten, anstatt sie einfach zu übernehmen.
Gehe dabei in drei Schritten vor:

SCHRITT 1 – Prüfe ob die Person eines der folgenden Signale zeigt:
  (a) Meldet einen Fehler in der KI-Antwort
  (b) Hinterfragt ein Ergebnis direkt
  (c) Korrigiert oder verfeinert eine vorherige Antwort iterativ
  (d) Bittet explizit um Quellen, Belege oder Gegenargumente
  (e) Gibt die KI-Antwort als neuen Input zurück um sie weiterzuverarbeiten

SCHRITT 2 – Prüfe Gegenargumente:
  Könnte das Signal auch einfach eine neue unabhängige Frage sein?
  Delegiert die Person nur neue Aufgaben ohne frühere Antworten zu bewerten?

SCHRITT 3 – Entscheide durch Abwägung:
  Vergib "Ja" nur wenn:
    - Mindestens ein Signal aus Schritt 1 vorliegt UND
    - Das Signal aus Schritt 2 klar als Überprüfung erkennbar ist
      und NICHT als neue unabhängige Aufgabe erklärbar ist
  Vergib "Nein" wenn:
    - Kein Signal aus Schritt 1 vorliegt ODER
    - Das Signal aus Schritt 1 durch Schritt 2 entkräftet wird,
      weil es sich um eine neue unabhängige Frage handelt


Antworte NUR in diesem exakten Format (drei Zeilen, nichts anderes):
TASK: <Label>
SENTIMENT: <Label>
CRITICAL: <Label>"""),
    ("human", "Chat-Log:\n{text}"),
])


# ============================================================
# Label-Bereinigung & Parsing (identisch zur Evaluations-Pipeline)
# ============================================================
def clean_label(raw: str, valid_labels: List[str]) -> str:
    raw = raw.strip()
    for label in valid_labels:               # exakter Match
        if label.lower() == raw.lower():
            return label
    for label in valid_labels:               # Teilstring-Match
        if label.lower() in raw.lower():
            return label
    return "unknown"


def parse_combined(raw: str) -> dict:
    result = {"task": "unknown", "sentiment": "unknown", "critical": "unknown"}
    for line in raw.strip().splitlines():
        line = line.strip()
        if line.startswith("TASK:"):
            result["task"]      = clean_label(line.replace("TASK:", "").strip(), LABELS_TASK)
        elif line.startswith("SENTIMENT:"):
            result["sentiment"] = clean_label(line.replace("SENTIMENT:", "").strip(), LABELS_SENTIMENT)
        elif line.startswith("CRITICAL:"):
            result["critical"]  = clean_label(line.replace("CRITICAL:", "").strip(), LABELS_CRITICAL)
    return result


# ============================================================
# Chat-Text zusammenbauen (nur User-Nachrichten, wie im Eval-Notebook)
# ============================================================
def build_chat_text(group: pd.DataFrame) -> str:

    user_msgs = group.loc[group["role"] == "user", "content"].tolist()
    return "\n".join(f"User_Nachricht_{i+1}: {msg}" for i, msg in enumerate(user_msgs))


# ============================================================
# Cache: Ergebnisse pro Chat persistieren, damit ein erneuter
# Lauf keine bereits klassifizierten Chats nochmal anfragt.
# Key = Hash aus Modellname + Chat-Text (robust gegen neue
# chat_ids, wenn der Datensatz neu aufgebaut wird).
# ============================================================
def _cache_key(model: str, text: str) -> str:
    return hashlib.sha256(f"{model}\n{text}".encode("utf-8")).hexdigest()


def _load_cache(cache_path: Path) -> dict:
    if cache_path.exists():
        try:
            return json.loads(cache_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError) as e:
            print(f"WARNUNG: Cache {cache_path} nicht lesbar ({e}) - starte mit leerem Cache")
    return {}


def _save_cache(cache: dict, cache_path: Path) -> None:
    cache_path.parent.mkdir(parents=True, exist_ok=True)
    tmp = cache_path.with_suffix(cache_path.suffix + ".tmp")
    tmp.write_text(json.dumps(cache, ensure_ascii=False, indent=1), encoding="utf-8")
    tmp.replace(cache_path)   # atomar: kein kaputter Cache bei Abbruch mitten im Schreiben


# ============================================================
# Hauptfunktion
# ============================================================
def classify_chats(
    df_chats: pd.DataFrame,
    model: str = "gpt-5.5",
    temperature: float = 0.0,
    api_key_path: Optional[Path] = None,
    cache_path: Optional[Path] = None,
    verbose: bool = True,
) -> pd.DataFrame:

    # API-Key setzen
    if api_key_path is not None:
        key_path = Path(api_key_path)
        if key_path.exists():
            os.environ["OPENAI_API_KEY"] = key_path.read_text().strip()
        elif verbose:
            print(f"Key-Datei nicht gefunden: {key_path}")

    llm = ChatOpenAI(model=model, temperature=temperature)
    chain = prompt_combined | llm | StrOutputParser()

    # Cache laden
    cache: dict = {}
    if cache_path is not None:
        cache_path = Path(cache_path)
        cache = _load_cache(cache_path)
        if verbose and cache:
            print(f"Cache geladen: {len(cache)} Einträge aus {cache_path}")
    n_hits = 0

    # Meta pro Chat (chat_id -> teilnehmer_id, frage_code)
    meta = (df_chats.groupby("chat_id")
                    .agg(teilnehmer_id=("teilnehmer_id", "first"),
                         frage_code=("frage_code", "first"))
                    .reset_index())

    rows = []
    chat_ids = sorted(df_chats["chat_id"].unique())

    for n, cid in enumerate(chat_ids, start=1):
        group = df_chats[df_chats["chat_id"] == cid]
        text  = build_chat_text(group)

        raw = ""
        key = _cache_key(model, text)
        if not text.strip():
            parsed = {"task": "unknown", "sentiment": "unknown", "critical": "unknown"}
        elif key in cache:
            # Ergebnis aus dem Cache (kein API-Call)
            entry  = cache[key]
            raw    = entry.get("raw_response", "")
            parsed = {k: entry.get(k, "unknown") for k in ("task", "sentiment", "critical")}
            n_hits += 1
        else:
            try:
                raw    = chain.invoke({"text": text})
                parsed = parse_combined(raw)
            except Exception as e:
                if verbose:
                    print(f"    Fehler bei chat_id {cid}: {e}")
                parsed = {"task": "unknown", "sentiment": "unknown", "critical": "unknown"}
            # nur erfolgreiche Klassifikationen cachen; nach jeder Prediction
            # speichern, damit bei Abbruch nichts verloren geht
            if cache_path is not None and parsed["task"] != "unknown":
                cache[key] = {**parsed, "raw_response": raw,
                              "teilnehmer_id": str(df_chats.loc[df_chats["chat_id"] == cid,
                                                                "teilnehmer_id"].iloc[0]),
                              "frage_code": str(df_chats.loc[df_chats["chat_id"] == cid,
                                                             "frage_code"].iloc[0])}
                _save_cache(cache, cache_path)

        m = meta[meta["chat_id"] == cid].iloc[0]
        rows.append({
            "chat_id":       cid,
            "teilnehmer_id": m["teilnehmer_id"],
            "frage_code":    m["frage_code"],
            "task":          parsed["task"],
            "sentiment":     parsed["sentiment"],
            "critical":      parsed["critical"],
            "chat_text":     text,
            "raw_response":  raw,
        })

        if verbose and n % 10 == 0:
            print(f"    {n}/{len(chat_ids)} Chats klassifiziert ...")

    df_labeled = pd.DataFrame(rows)
    if verbose:
        info = f", davon {n_hits} aus dem Cache" if cache_path is not None else ""
        print(f"Fertig: {len(df_labeled)} Chats klassifiziert{info}.")
    return df_labeled
