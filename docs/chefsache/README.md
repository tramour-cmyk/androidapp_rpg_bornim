# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [132](entscheiden/132-spieldauer-vierter-platz.md) | 17.10. | beides klein, ein Build; Empfehlung: ja, mit Toms nächstem eigenen Build | Tom |
| [134](entscheiden/134-ausrufezeichen-gesten.md) | 17.10. | machbar und passt; Empfehlung: ja, in zwei Schritten (erst goldenes „!“, dann Gesten), Kür | Tom |
| [99](entscheiden/99-ford2-entfaellt.md) | 17.10. | Ford 2 kostete am 16.10. etwa 20 % von Jerry (Grenze 10 %); vier Sparvorschläge jetzt, neue Messung Ford 2 und Ford 20.–21.10. | Perikles |
| [D23.1](entscheiden/d231-weg-zu-morwen.md) | 17.10. | Rauchbündel wirkt, aber zielstrebig kommt man mit Stufe 1 zu Krogg (Ziel Stufe 2–3); Empfehlung: erst du einmal am Gerät, dann ändern | Tom (für Jerry, Übernahme) |
| [72s.1](entscheiden/72s1-gefaehrte-kapitel2.md) | 15.10. | Gefährte für Kapitel 2: wer und ab wann (Empfehlung A: Jäger Garrick ab Beginn) | Homer |

## Anzusehen

Reihenfolge = Version aufsteigend (Android installiert nur höhere Nummern über niedrigere).

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.1.816](ansehen/t13-huehner.md) | – | 26: Kapitel 1 durchspielen | Tom | 17.10. |

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen: Zeile 1 `# <Team> · <Version> · <Thema> · <PR>`, Sammelseite je Build `## Build <n> · <Version> · <Thema> · <PR>`; die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · …`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
