# Dein Zug

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

| Nr. | Seit | Was | Wer |
|---|---|---|---|
| [106.1](entscheiden/1061-rollen-ergebnis.md) | 16.10. | je Rolle „gutes Ergebnis“ mit Beispiel und „dein typischer Fehler“, Abläufe raus; keine neue Rolle; Probe an ROLLE-TEAM nach Sa 21:00 | Sokrates Projekt |
| [124](entscheiden/124-vorgaenge-gliedern-preis.md) | 16.10. | fünf Hauptthemen mit Buchstaben; Preis je Vorgang aus den Sitzungskosten, Ford trägt ihn beim Neustart ein; Probe eine Woche ab So 18.10., Bilanz 23.10. | Sokrates Projekt |
| [125](entscheiden/125-drei-namen.md) | 16.10. | ja, drei Namen; getrennt sind die Rollen schon (Datei, Vorrat, Sitzung), nur der Name ist gemeinsam; Umbenennung im Samstagsumbau (117) | Sokrates Projekt |
| [126](entscheiden/126-muss-und-kuer.md) | 16.10. | M = steht im Wochenziel oder vom Chef „jetzt“, sonst Kür; Ersteller trägt ein, Ford prüft; Kür nur, wenn nichts Muss startbar ist; Wochenziel vom Projektmanager, Anteil Muss als Kennzahl (124) | Sokrates Projekt |
| [72s.1](entscheiden/72s1-gefaehrte-kapitel2.md) | 15.10. | Gefährte für Kapitel 2: wer und ab wann (Empfehlung A: Jäger Garrick ab Beginn) | Sokrates |

## Anzusehen

Reihenfolge = Version aufsteigend (Android installiert nur höhere Nummern über niedrigere).

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.1.799](ansehen/jerry-testreihe.md) | Build 8 | Probe 72.10: Held und Söldner gegen Grak | Jerry | 16.10. |

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen: Zeile 1 `# <Team> · <Version> · <Thema> · <PR>`, Sammelseite je Build `## Build <n> · <Version> · <Thema> · <PR>`; die Übersicht zeigt jeden Build als Zeile, nach Version sortiert (127).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · …`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`).
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.
- Telegram-Sprungmarke `[72s.1](dz:72s1)` führt auf die Datei (`tools/meldung.sh`).
