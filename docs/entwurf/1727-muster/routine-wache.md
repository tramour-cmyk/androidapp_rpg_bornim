# 1727, Routine Wache mit Herzschlag (Entwurf Perikles 21.11., 20:15, ungeprüft)

Auftrag: 1767 (Sokrates, Chef 21.11., 20:09). Raster `ein-ausgang.md`, schließt L-O9 und mit dem Herzschlag L-T1. **Nur Anschauung, nicht in Betrieb;** bis zur Umstellung trägt Ford (`ROLLE-BETRIEB.md` Telegram, „Wache-Uhr :33“).

Quellen: Gesamtbild 4.4 Zeile Ford „Telegram: du bist dran, Sitzung hängt, ab 3 roten Läufen je Stunde → Routine Wache (Werkzeug), Disponent bei Handlungsbedarf“ und „Uhr und Wache startet ein Werkzeug, nicht das Büro“ (G:474–475); `signale.md` S12, S18 (Herzschlag: Zeitmarke von `lauf.py` älter als 2 h → Telegram); `ablauf.md` A18 (GitHub-Lauf, kostet keine Token); `ROLLE-BETRIEB.md` Z. 35 (rote Läufe, 464; Tagesbericht fehlt um 10 Uhr, 448); 1572, 1610 (Hängeralarm 15 statt 15–75 Minuten).

## Vorschlag: Wache ohne Sitzung

Die Wache urteilt nicht, sie misst. Darum **kein Text für eine Sitzung**, sondern Regeln für ein Werkzeug (GitHub-Zeitplan, alle 15 Minuten, kostet keine Token). Es meldet per `meldung.sh`; handeln tut der Disponent.

| Fall | misst | meldet | an |
|---|---|---|---|
| **Herzschlag** | Zeitmarke des letzten `lauf.py` älter als 2 h | „Büro steht seit <Zeit>“ | Chef, laut (nachts lautlos) |
| **Sitzung hängt** | Sitzung `working` ohne neues Ereignis seit 15 Minuten (1610), oder `idle` mit offener angenommener Zeile nach Ablauf der Frist (3.3 F2 Nr. 3) | „<Rufname> <Nr> hängt seit <Zeit>“ | Disponent (Wecker); ab der zweiten Meldung derselben Sitzung Chef, lautlos |
| **Rote Läufe** | ab 3 fehlgeschlagenen GitHub-Läufen in der Stunde (464) | Zahl, Zweige, Link | Chef, laut (nachts lautlos); Disponent (Wecker) |
| **Du bist dran** | Testbitte oder Chefsache neu, seit 30 Minuten ohne Telegram | „wartet auf dich: <Nr>“ | Chef, laut (nachts lautlos) |
| **Tagesbericht fehlt** | 10 Uhr (Sa/So 12 Uhr) kein Bericht von heute | „Tagesbericht fehlt“ | Disponent (Wecker) |

Doppelt nie: dieselbe Meldung zum selben Fall höchstens einmal je Stunde (Stand in einer Datei des Werkzeugs).

## Raster

| 1 Einheit | 2 Auslöser | 3 Arbeit, Eingang | 4 Ende, Ausgang | 5 Meldung | 6 Nächster Empfänger | 7 Lücke |
|---|---|---|---|---|---|---|
| **Routine Wache** (Werkzeug) | GitHub-Zeitplan alle 15 Minuten | Zeitmarke `lauf.py`, `list_sessions`, GitHub-Läufe, Chefsache, Tagesbericht | Lauf endet nach den fünf Prüfungen | Telegram (`meldung.sh`), Wecker an den Disponenten | Disponent (handelt); Chef (Herzschlag, rot, du bist dran) | offen: Zugriff eines GitHub-Laufs auf `list_sessions` und `send_message` (Sitzungsschnittstelle) ungeklärt |

## Offen, Fragen

1. **Kann ein GitHub-Lauf Sitzungen sehen und wecken?** Herzschlag und rote Läufe gehen mit Git und GitHub allein (Zeitmarke als Commit, Läufe als API). „Sitzung hängt“ braucht den Sitzungsstand, den heute nur eine Claude-Sitzung über `list_sessions` liest. Vorschlag: `lauf.py` schreibt bei jedem Lauf den Sitzungsstand in eine Datei; die Wache liest sie. Läuft `lauf.py` nicht, greift der Herzschlag. Frage an Spike (Werkzeug).
2. **Wer wacht über die Wache?** Ein GitHub-Zeitplan fällt selten aus; schlägt er fehl, zeigt GitHub es. Kein zweiter Wächter (Gegenargument unten).
3. **Telegram-Zugang im GitHub-Lauf:** `meldung.sh` braucht das Telegram-Token als GitHub-Secret; setzt der Chef (Zugangsdaten nur als Secret, `CLAUDE.md`).

## Stärkstes Gegenargument

Eine Wache, die nur misst, sieht nicht, warum etwas hängt, und weckt den Disponenten auch für harmlose lange Züge (Build, 40 Minuten). **Dagegen:** urteilen soll der Disponent, nicht die Wache; 3.3 F2 Nr. 3 wartet bei `working`, darum misst die Wache bei `working` nur „kein neues Ereignis“, nicht die Dauer. Bleibt: ohne Antwort auf Frage 1 geht nur Herzschlag, rot, du bist dran und Tagesbericht; „Sitzung hängt“ bliebe beim Disponenten.
