# 650.1 · Liste für `docs/alt/` nach zwei Gegenprüfungen · Sokrates · 08.11., 13:3x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/main/docs

**Frage:** Verschieben wie unten? Von 15 Kandidaten: **10 verschieben**, **2 erst nach Umzug ihrer gültigen Regeln**, **3 bleiben**.
**Votum Sokrates: ja.** Prüfer A (je Datei bewertet) und Prüfer B (gezielt „was ginge verloren, was bräche“), beide 13:29–13:30; wo sie sich widersprechen, steht mein Urteil mit Grund.

## Verschieben (10)

| Datei | warum erledigt | vorher tun | Prüfer |
|---|---|---|---|
| `LISTE-ABLAUF-274` | überholt durch 275.2 | Link in `LISTE-ZENTRALE-VORGAENGE-275` zieht mit | A ja, B ja |
| `LISTE-ZENTRALE-VORGAENGE-275` | umgesetzt als 275.2 | **erst nach Diogenes' Prüfung von 275 (09.11.)**; erledigte Idee `LISTE-IDEEN.md:148` streichen | A ja, B schwach dagegen |
| `LISTE-GRUNDSTAND-461` | nur noch Wegweiser, Inhalt in DESIGN-STIL/-KAMPF/-ABNAHME | zwei Code-Kommentare auf `DESIGN-STIL.md` umschreiben | A ja, B gering |
| `LISTE-FORD2` | Ford 2 ruht | Links in `ARBEIT-BETRIEB`, `LISTE-BETRIEB`, `FIRMA`, `README` anpassen | A ja, B dagegen (ruht, nicht erledigt) |
| `LISTE-PROXMOX-RUNNER` | 264 ruht | Kommentar in `tools/runner/einrichten.sh` | A ja, B dagegen (ruht) |
| `LISTE-ARBEITSORTE` | 264 ruht | – | A ja, B dagegen (ruht) |
| `LISTE-PRUEFBOGEN-TESTER` | Wortlaut steht in `tools/pruefbogen/bogen.md` | – | A ja, B dagegen (186.3 ruht) |
| `DESIGN-KAMPF-SPIELANLEITUNG-72-10A` | Probe der Kotlin-Fassung, 72.10a erledigt | Ideen „nach Test“ (72.10a.7, .8) prüfen, ob umgesetzt | A ja, B schwach dagegen |
| `DESIGN-MARS-AUFSTELLUNG` | Bild der alten Fassung, Regel vorn/hinten steht in `LISTE-MARS` | – | A ja, B dagegen (Design-Regel) |
| `LISTE-GRAFIKWEG` | entschieden 25.10. | Lizenzzeile Blender/Godot (Zeile 52) nach `LISTE-QUELLEN.md` | A ja, B schwach dagegen |

**Mein Urteil zu den Einwänden „ruht, nicht erledigt“ (Ford 2, 264, 186.3):** `docs/alt/` ist genau dein „in petto“: nichts geht verloren, beim Wiedereinschalten holt man die Datei zurück. Für DESIGN-MARS-AUFSTELLUNG folge ich Prüfer A: die gültige Regel steht in `LISTE-MARS`.

## Erst nach Umzug (2)

| Datei | was gilt noch | wohin |
|---|---|---|
| `LISTE-ENGLISCH-338-1B` | Regeln 1–7 für englische Spieltexte (US-Schreibung, „…“, Präsens), gelten für Godot | `STORY-REGELN.md` (Homer) |
| `LISTE-CC0-MODELLE` | 91 Lizenzangaben genutzter Modelle; `LISTE-BESTAND.md` verweist dafür hierher | `LISTE-QUELLEN.md` mit 623.1 (bei mir) |

## Bleibt (3)

| Datei | warum | Prüfer |
|---|---|---|
| `LISTE-UMZUG-348` | Modellregel, Messlatte, „Abgleich“ gelten, Wochenziel misst damit, Werkzeug zitiert sie | A und B |
| `LISTE-AUSWERTUNG-PRUEFBOGEN` | Vorschrift für die geplanten 12 Tester, Bedienung der Auswertewerkzeuge steht nur hier | A und B |
| `PRUEFBERICHT-ARCHIV` | wird laufend fortgeschrieben; Werkzeuge nehmen genau diesen Pfad aus | A und B |

## Dazu nötig
- `tools/notiz.sh` und `tools/regeltreue/notiz-neu.sh` nehmen `docs/alt` von der Warnung „alte Dateinamen“ aus, sonst warnen sie bei jedem Start (Prüfer A).
- Weitere Kandidaten (Prüfer A), nicht in dieser Liste: `STORY-K2-LANDKARTE` doppelt zu `STORY-K2-KARTE.svg`? (Homer); `DESIGN-SPIELSYSTEM-2-0.md` gegen `-ENTWURF.md`: welche gilt? (prüfe ich, vielfach verlinkt). `LISTE-SIMULATION-444` bleibt: Jerry rechnet darin noch (481).

## Folgerungen
„650.1 ja“: Perikles verschiebt die 10 (Links und Werkzeuge im selben Schritt), Homer zieht die Englisch-Regeln um, ich übertrage die Lizenzen (623.1); danach die zwei übrigen.
