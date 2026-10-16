# Dein Zug

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [106.1](entscheiden/1061-rollen-ergebnis.md) | 16.10. | je Rolle „gutes Ergebnis“ mit Beispiel und „dein typischer Fehler“, Abläufe raus; keine neue Rolle; Probe an ROLLE-TEAM nach Sa 21:00 | Sokrates Projekt |
| [124](entscheiden/124-vorgaenge-gliedern-preis.md) | 16.10. | fünf Hauptthemen mit Buchstaben; Preis je Vorgang aus den Sitzungskosten, Ford trägt ihn beim Neustart ein; Probe eine Woche ab So 18.10., Bilanz 23.10. | Sokrates Projekt |
| [125](entscheiden/125-drei-namen.md) | 16.10. | ja, drei Namen; getrennt sind die Rollen schon (Datei, Vorrat, Sitzung), nur der Name ist gemeinsam; Umbenennung im Samstagsumbau (117) | Sokrates Projekt |
| [72s.1](entscheiden/72s1-gefaehrte-kapitel2.md) | 15.10. | Gefährte für Kapitel 2: wer und ab wann (Empfehlung A: Jäger Garrick ab Beginn) | Sokrates |

## Anzusehen

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [Jerry](ansehen/jerry-testreihe.md) | 16.10. | 4 Sammelbuilds statt 14 Einzel-APKs, je Build eine Prüfliste; Reihenfolge 1 → 4 | Jerry |
| [Tom](ansehen/t806-92-bram-schubsen.md) | 16.10. | Dauerlaufen gegen Dorfleute schiebt sie zur Seite (Test 0.1.791 nicht bestanden, Ursache behoben) | Tom |

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · …`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](dz:72s1)` führt auf die Datei (`tools/meldung.sh`).
