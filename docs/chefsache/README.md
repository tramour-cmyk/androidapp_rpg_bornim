# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136).

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [167.10](entscheiden/167-10-uebersicht-offen.md) | **Muss** | B Abläufe | 18.10. | Abschnitt „Offen je Rolle“ in der Chefsache-Übersicht, schreibt das vorhandene Werkzeug bei jedem Push | Sokrates |

## Anzusehen

Reihenfolge = Version aufsteigend (Android installiert nur höhere Nummern über niedrigere).

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.1.828](ansehen/26-kapitel1-durchspielen.md) | – | 26 | Tom | 17.10. |
| 2 | [0.1.837](ansehen/t20-72-10a-texte-reihen.md) | Build 20 | MARS-Texte, Reihen, Betrunken | Jerry | 18.10. |

## Lücken

Vom Werkzeug gefunden (D21.3): steht im Vorrat, hat hier keine Datei.

Nicht gestellt: 167.8 (Projekt), 167.5 (Projekt)

Ohne Datei: 72s.1 (Kreativ)

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen (nur mit Build, Datei `ansehen/t<build>-<stichwort>.md`): Zeile 1 `# <Team> · Build <n> · <Version> · <Thema> · <PR>`, Zeile 2 `<Bereich, z. B. E Kampf> · <Team> · <TT.MM.>, <HH:MM> · <APK-Link>`, dann Tabelle `| # | Nr. | Wo und wie | Richtig | Falsch |` mit konkreten Schritten („Tippe …, erwarte …“). Sammelseite je Build: `## Build <n> · <Version> · <Thema> · <PR>`. Die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127); Abweichungen stehen unter „Lücken“.
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich> · …` (Bereich wie „B Abläufe“, 136); Vorrang = Klasse der Nummer in `LISTE-VORGAENGE.md`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
