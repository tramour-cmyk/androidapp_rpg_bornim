# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136).

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [72.10a](entscheiden/7210a-kampf-ideen.md) | **Muss** | E Kampf | 17.10. | Neuer Kampf – 14 Ideen (Zaubern, wer ist dran, Positionieren, Klassen, Ausrüstung, Gegenstände, Animation); Empfehlung: .1, .4, .6, .10 jetzt | Homer |
| [130](entscheiden/130-kampfgefuehl.md) | Kür | G Balance | 17.10. | Kampfgefühl und Name – zurückgestellt für ein ruhiges Gespräch mit Sokrates (Chef 17.10., 15:2x) | Sokrates |
| [142](entscheiden/142-pflichttest-play-store.md) | Kür | M Veröffentlichung | 17.10. | Play-Store-Konto und Pflichttest – ab wann (Empfehlung A: Konto jetzt, Tester sammeln ab Durchspielen 13.5) | Sokrates |
| [72s.1](entscheiden/72s1-gefaehrte-kapitel2.md) | Kür | E Kampf | 15.10. | Gefährte für Kapitel 2: wer und ab wann (Empfehlung A: Jäger Garrick ab Beginn) | Homer |

## Anzusehen

Reihenfolge = Version aufsteigend (Android installiert nur höhere Nummern über niedrigere).

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.1.828](ansehen/t17-feedback-build16.md) | Build 17 | 131 Gehen und Rennen mit Feedback Build 16 (131.1, 151, 152, 153), D23.2, 26 | Tom | 17.10. |
| 2 | [–](ansehen/137-ideenspeicher.md) | – | Ideenspeicher | Perikles | 17.10. |
| 3 | [–](ansehen/154-155-test.md) | – | – | Jerry | 17.10. |

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen: Zeile 1 `# <Team> · <Version> · <Thema> · <PR>`, Sammelseite je Build `## Build <n> · <Version> · <Thema> · <PR>`; die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich> · …` (Bereich wie „B Abläufe“, 136); Vorrang = Klasse der Nummer in `LISTE-VORGAENGE.md`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
