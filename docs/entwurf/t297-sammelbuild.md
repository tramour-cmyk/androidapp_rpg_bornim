# Tom und Jerry · Build 297 · Sammelbuild: Zielwahl, Ring erklärt, Erklärfenster, Zurück im Kampf, Höhlenwände, Kampfschirm, Stab, Achsel · PR folgt
E Kampf · Jerry (Handy 785.11, 785.12, 785.15, 785.17), Tom (Handy 1423, 785.10; ohne dich 1460, 531, 1448, 1516, 1522; Bild 1515/1417/1535) · 17.11., 10:39 · APK folgt

Verglichen (alt gegen neu): Zielliste, Ringerklärung, Erklärfenster und Zurück im Kampf gegen `SkirmishScreen.kt` (582–588, 705–725, 1257–1262, 1321–1328, 340, 364, 494) und `MarsTips.kt` 84–89; Funde behoben. Umbau überall: Zielliste und Dämpfen gelten für Angriff, Fähigkeit, Trank und Wurf (ein Weg in `kampf_ui.gd`); die Ringerklärung gibt es nur im Kampf. Höhle, Garrick, Leiste wie Liste 296.

Sammelbuild auf `main` mit `claude/build-296` (Chef 17.11., 10:03: „296 warten“; 296 wurde nicht installiert, seine Punkte stehen hier noch einmal als 297.1–297.4). 1512 (Spike, Probekampf auf Englisch) fährt im Zweig mit; den Test dazu baut Spike, er steht nicht in dieser Liste.

Ein Weg: über Build 295 installieren; 297.1 mit „Lage herstellen“ (Höhle); dann 297.6 (Grak), 297.7–297.9 im selben Probekampf Wölfe; 297.10 zuletzt.

Im Bau geprüft: Höhlenwände mindestens 2,2 m, Loch um den Helden hinter einer Wand (1423, `hoehle_492`); Schneidern statt Lederarbeit (1460, `schneidern_1460`); Zielliste mit Reihe ab drei Stehenden, Wählbare hell, übrige gedämpft bei Angriff, Fähigkeit, Trank, Wurf (785.11, `zielwahl_78511`); Ringerklärung einmal je Spielstand vor der Eingebung, nicht gegen einen Helden auf Automatik, Wort über dem ersten Ring (785.12, `ring_785`); Erklärfenster schließt mit einem Tipp und ist während des Rings weg (785.15, `tipp_78515`); Android-Zurück schließt Ziel, Können, Tasche, Wechsel (785.17, `zurueck_kampf_78517`); Kasten des Helden nur Leben und Mana, Schnell im leichten Kampf (785.10, `heldkasten_78510`, `schnell_78510`); Stab in der linken Faust (1516, `stab_menue_1516`); Kleidung an der Achsel nicht am Unterarm (1515, 1535, `achsel_1515`, `schild_menue_1417`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 297.1 | Tom | 1423 | Handy | Zeile 297.1 → „Lage herstellen“ (Höhle, Westflügel unten am Leuchtpilz, die hohe Wand zum Teich steht zwischen dir und dem Helden); drei Schritte nach rechts und wieder zurück | der Held bleibt ganz zu sehen: in der Wand vor ihm ist ein rundes Loch, das mit ihm geht; links und rechts davon steht der Fels hoch | der Held verschwindet hinter der Wand, das Loch bleibt stehen oder flackert, oder die ganze Wand ist weg |
| 297.2 | Tom | 1460 | ohne dich (Diogenes bestätigt am Lauf) | `schneidern_1460`: Fertigkeit Schneidern statt Lederarbeit, alte Spielstände übernommen | Test grün | Test rot |
| 297.3 | Tom | 531 | ohne dich (am Film gebilligt, 👍 17.11., 06:06) | Garrick vertreibt den Wolf mit der Fackel; seine Fackel leuchtet im Nebel | – | – |
| 297.4 | Tom | 1448 | ohne dich (am Bild gebilligt, 👍 17.11., 06:02) | Weltleiste und Heldenmenü ohne Wörter Leben/Mana/EP, Balken bündig, dahinter die Zahl, bei Erfahrung die Stufe | – | – |
| 297.5 | Tom | 1516 | ohne dich (am Bild gebilligt, 👍 17.11., 08:20) | Zauberlehrling hält den Stab in der linken Faust (Hauptmenü, Welt, Kampf) | – | – |
| 297.6 | Jerry | 785.12 | Handy | Zeile 297.6 → „Lage herstellen“ (Probekampf gegen Grak, er holt einmal sicher zum Schweren Hieb gegen dich aus); auf die Ansage warten, beim Ring tippen | im Bericht steht vor der Eingebung in deren Farbe „Das Zeichen ◯ heißt: dieser Schlag kommt mit Ring …“; über dem Ring steht „Tippen, wenn die Ringe aufeinanderliegen!“, nach dem Tipp weg; das Urteil steht farbig („Perfekt: ausgewichen“ hell, „Gut: halber Schaden“ in Textfarbe, „Verpasst“ in Warnfarbe), die Antwort der Klasse in Gold darunter | keine Erklärung oder sie steht erst nach der Eingebung, kein Wort über dem Ring oder es bleibt nach dem Tipp stehen, Urteil immer in derselben Farbe |
| 297.7 | Jerry | 785.11 | Handy | Zeile 297.7 → „Lage herstellen“ (Probekampf drei Wölfe); „Angriff“ tippen, dann „Zurück“, „Tasche“ → einen Trank wählen | bei „Angriff“: Liste mit Reihe und Leben je Wolf (etwa „Wolf 1 · vorn  25/25“), wählbare Wölfe mit Ring und Name, ein nicht erreichbarer Wolf und deine eigenen Leute blass; beim Trank sind die Wölfe blass, deine Leute hell | gleichnamige Wölfe nicht zu unterscheiden, keine Reihe, alles gleich hell |
| 297.8 | Jerry | 785.15 | Handy | im selben Kampf lange auf einen Knopf drücken (etwa „Angriff“), dann ins Erklärfenster tippen | das Fenster geht mit einem Tipp weg; kommt ein Ring, ist es währenddessen nicht zu sehen | das Fenster bleibt stehen oder liegt über dem Ring |
| 297.9 | Jerry | 785.17 | Handy | im selben Kampf „Angriff“ tippen, dann die Android-Zurück-Taste (oder Wischgeste) | wieder die Befehle (Angriff, Können, Tasche …), der Kampf läuft weiter | der Kampf endet, das Spiel geht ins Menü, oder nichts passiert |
| 297.10 | Tom | 785.10 | Handy | (Tom ergänzt: Weg zum leichten Kampf mit Starttafel Kämpfen/Schnell) | Kasten des Helden zeigt nur Leben und Mana, keinen Erfahrungsbalken und keine Stufe; (Tom ergänzt) | ein Erfahrungsbalken oder „Lv.“ im Kasten des Helden |
| 297.11 | Tom | 1515, 1417, 1535 | Bild | (Tom ergänzt: Wachsoldatin und Leute im Kaufkleid in Ruhebewegung, alt gegen neu) | – | – |
| 297.12 | Tom | 1522 | ohne dich | README ohne SRD-Hinweis und Satz zu Wizards of the Coast (kein Spielinhalt) | – | – |

## Lagen

- 297.1: station=Krogg ort=cave:2:11:RIGHT ruhig
- 297.6: probe=GRAK zug=heavy
- 297.7: probe=WOLVES
- 297.8: probe=WOLVES
- 297.9: probe=WOLVES
