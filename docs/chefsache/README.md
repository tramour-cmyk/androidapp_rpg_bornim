# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [129a](entscheiden/129a-build13-umfang.md) | 17.10. | Build 13: gilt „passt“ auch für 13.4 und 13.5? (Empfehlung: :) | Ford |
| [72s.1](entscheiden/72s1-gefaehrte-kapitel2.md) | 15.10. | Gefährte für Kapitel 2: wer und ab wann (Empfehlung A: Jäger Garrick ab Beginn) | Homer |

## Anzusehen

Reihenfolge = Version aufsteigend (Android installiert nur höhere Nummern über niedrigere).

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.1.812](ansehen/jerry-testreihe.md) | Build 8 | Probe 72.10: Held und Söldner gegen Grak | Jerry | 16.10. |
| 2 | [0.1.813](ansehen/jerry-testreihe.md) | Build 11 | 86: Rennen laut | Jerry | 16.10. |
| 3 | [0.1.815](ansehen/jerry-testreihe.md) | Build 12 | D3: Kampfgeheul aus Aufnahmen | Jerry | 16.10. |
| 4 | [0.1.816](ansehen/t13-huehner.md) | Build 13 | 129: Hühner nie zwei auf einem Platz | Tom | 16.10. |

## Lücken

Vom Werkzeug gefunden (D21.3): steht im Vorrat, hat hier keine Datei.

Nicht gestellt: 24.6 (Team Jerry), 9i (Team Jerry), 19e (Team Jerry)

Ohne Datei: 39.1 (Kreativ)

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen: Zeile 1 `# <Team> · <Version> · <Thema> · <PR>`, Sammelseite je Build `## Build <n> · <Version> · <Thema> · <PR>`; die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · …`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
