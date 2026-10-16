# Dein Zug

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [99g](entscheiden/99g-dokumente-pro.md) | 16.10. | Alle lebenden Artefakte ins Repo, gestaffelt: Kampf jetzt, Rest nach Sa 21:00; nur Marktvergleich bleibt auf Max (Empfehlung) | Sokrates Projekt |
| [72s.1](entscheiden/72s1-gefaehrte-kapitel2.md) | 15.10. | Gefährte für Kapitel 2: wer und ab wann (Empfehlung A: Jäger Garrick ab Beginn) | Sokrates |

## Anzusehen

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [Jerry](ansehen/jerry-testreihe.md) | 16.10. | Elf Builds von Jerry, Reihenfolge nach Toms 0.1.757 (#71): Keuchen, Rauchbündel, Lautstärke, Umweltklang, Fluss, Intro-Klang, Glocke, Sterbehaltung, Krogg, Zustände, Absturz Klang | Jerry |

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · …`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](dz:72s1)` führt auf die Datei (`tools/meldung.sh`).
