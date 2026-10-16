# Dein Zug

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [108a](entscheiden/108a-neubau-testreihe.md) | 16.10. | Jerrys 12 Test-Builds mit `main` neu bauen (Empfehlung A: ja, nur wenn du 0.1.773 installiert hast) | Jerry |
| [99g.1](entscheiden/99g1-name-beschluesse.md) | 16.10. | Beschlüsse heißen künftig Vorgangsarchiv, Datei `docs/VORGANGSARCHIV.md`, nur Text, Umzug nach Sa 21:00 (Empfehlung) | Sokrates Projekt |
| [D1.14](entscheiden/d114-hoehlen-klangbett.md) | 16.10. | Hörner aus dem Höhlen-Klangbett nehmen (Empfehlung: ja, zehn Betten bleiben) | Jerry |
| [72s.1](entscheiden/72s1-gefaehrte-kapitel2.md) | 15.10. | Gefährte für Kapitel 2: wer und ab wann (Empfehlung A: Jäger Garrick ab Beginn) | Sokrates |

## Anzusehen

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [Jerry](ansehen/jerry-testreihe.md) | 16.10. | 14 Builds von Jerry nach Toms #71: Keuchen, Rauchbündel, Lautstärke, Umweltklang, Türklang, Fluss, Intro-Klang, Glocke, Sterbehaltung, Krogg, Zustände, Absturz Klang, betrunken, Raumklang | Jerry |

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · …`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](dz:72s1)` führt auf die Datei (`tools/meldung.sh`).
