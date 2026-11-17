# Tom und Jerry · Build 297 · Sammelbuild: Zielwahl, Ring erklärt, Erklärfenster, Zurück im Kampf, Höhlenwände, Kampfschirm, Stab, Achsel · PR folgt
E Kampf · Jerry (Handy 785.11, 785.12, 785.15, 785.17; ohne dich 1505, 1514, 1340), Tom (Handy 1423b, 785.10, 1530, 431h, Prüfzeile 1423a; ohne dich 1516, 1522; Bild 1515/1417/1535), Spike (Handy 1483) · 17.11., 12:40 · APK folgt

Verglichen (alt gegen neu): Zielliste, Ringerklärung, Erklärfenster und Zurück im Kampf gegen `SkirmishScreen.kt` (582–588, 705–725, 1257–1262, 1321–1328, 340, 364, 494) und `MarsTips.kt` 84–89; Funde behoben. Umbau überall: Zielliste und Dämpfen gelten für Angriff, Fähigkeit, Trank und Wurf (ein Weg in `kampf_ui.gd`); die Ringerklärung gibt es nur im Kampf. Höhle, Garrick, Leiste wie Liste 296.

Sammelbuild mit allem Offenen (1547, Chef 17.11., 11:07): `main`, `claude/build-296`, Toms 1423b, 431h, 1530. Nach t296 (11:03) erledigt und darum hier nicht mehr: 1460, 531, 1448, 1512 (frühere Zeilen 297.2–297.4, 297.16). 1483 (Anmerkung bei Passt) aus t295 nicht prüfbar, darum noch einmal. 1305 wartet auf den Bautest von Diogenes, nicht in dieser Liste.

Ein Weg: über Build 295 installieren; 297.1 mit „Lage herstellen“ (Höhle), gleich danach 297.19 (dieselbe Stelle mit Leuchtfunken); dann 297.6 (Grak), 297.7–297.9 im selben Probekampf Wölfe; 297.10; 297.18 (Probekampf, dann Welt); 297.17 zuletzt (Menü).

Gegengelesen: Tom 17.11., 10:52 (297.6–297.9: Lage-Schlüssel probe, zug gültig in `testmodus.gd` LAGE_SCHLUESSEL; Wege und Passt/Falsch eindeutig; 297.1–297.5 aus t296 übernommen)

Gegengelesen: Jerry 17.11., 12:40 (297.17, 297.18: Wege aus frischem Spielstand erreichbar; `ruestung=plate` greift ohne `held=`, der Testheld bekommt den Plattenpanzer über `probe_ausstatten`; 297.18 in der Welt auf die eigene Brustrüstung geschärft)
Gegengelesen: Tom 17.11., 12:54 (297.19: Lage `vorraete` legt je Ding 10 Stück in die Tasche, auch den Leuchtfunken (`testmodus.gd` vorraete); Knopf heißt „Benutzen“ (vorher „trinken“, geändert); Passt/Falsch eindeutig. 297.20: ohne dich, am Film gebilligt, keine Handlung nötig)

Im Bau geprüft: Höhlenwände mindestens 2,2 m, Loch um den Helden hinter einer Wand (1423, `hoehle_492`); Schneidern statt Lederarbeit (1460, `schneidern_1460`); Zielliste mit Reihe ab drei Stehenden, Wählbare hell, übrige gedämpft bei Angriff, Fähigkeit, Trank, Wurf (785.11, `zielwahl_78511`); Ringerklärung einmal je Spielstand vor der Eingebung, nicht gegen einen Helden auf Automatik, Wort über dem ersten Ring (785.12, `ring_785`); Erklärfenster schließt mit einem Tipp und ist während des Rings weg (785.15, `tipp_78515`); Android-Zurück schließt Ziel, Können, Tasche, Wechsel (785.17, `zurueck_kampf_78517`); Kasten des Helden nur Leben und Mana, Schnell im leichten Kampf (785.10, `heldkasten_78510`, `schnell_78510`); Stab in der linken Faust (1516, `stab_menue_1516`); Kleidung an der Achsel nicht am Unterarm (1515, 1535, `achsel_1515`, `schild_menue_1417`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 297.1 | Tom | 1423, 1423b | Handy | Zeile 297.1 → „Lage herstellen“ (Höhle, Westflügel unten am Leuchtpilz, die hohe Wand zum Teich steht zwischen dir und dem Helden); drei Schritte nach rechts und wieder zurück | der Held bleibt ganz zu sehen: in der Wand vor ihm ist ein rundes Loch, das mit ihm geht; links und rechts davon steht der Fels hoch | der Held verschwindet hinter der Wand, das Loch bleibt stehen oder flackert, oder die ganze Wand ist weg |
| 297.5 | Tom | 1516 | ohne dich (am Bild gebilligt, 👍 17.11., 08:20) | Zauberlehrling hält den Stab in der linken Faust (Hauptmenü, Welt, Kampf) | – | – |
| 297.6 | Jerry | 785.12 | Handy | Zeile 297.6 → „Lage herstellen“ (Probekampf gegen Grak, er holt einmal sicher zum Schweren Hieb gegen dich aus); auf die Ansage warten, beim Ring tippen | im Bericht steht vor der Eingebung in deren Farbe „Das Zeichen ◯ heißt: dieser Schlag kommt mit Ring …“; über dem Ring steht „Tippen, wenn die Ringe aufeinanderliegen!“, nach dem Tipp weg; das Urteil steht farbig („Perfekt: ausgewichen“ hell, „Gut: halber Schaden“ in Textfarbe, „Verpasst“ in Warnfarbe), die Antwort der Klasse in Gold darunter | keine Erklärung oder sie steht erst nach der Eingebung, kein Wort über dem Ring oder es bleibt nach dem Tipp stehen, Urteil immer in derselben Farbe |
| 297.7 | Jerry | 785.11 | Handy | Zeile 297.7 → „Lage herstellen“ (Probekampf drei Wölfe); „Angriff“ tippen, dann „Zurück“, „Tasche“ → einen Trank wählen | bei „Angriff“: Liste mit Reihe und Leben je Wolf (etwa „Wolf 1 · vorn  25/25“), wählbare Wölfe mit Ring und Name, ein nicht erreichbarer Wolf und deine eigenen Leute blass; beim Trank sind die Wölfe blass, deine Leute hell | gleichnamige Wölfe nicht zu unterscheiden, keine Reihe, alles gleich hell |
| 297.8 | Jerry | 785.15 | Handy | im selben Kampf lange auf einen Knopf drücken (etwa „Angriff“), dann ins Erklärfenster tippen | das Fenster geht mit einem Tipp weg; kommt ein Ring, ist es währenddessen nicht zu sehen | das Fenster bleibt stehen oder liegt über dem Ring |
| 297.9 | Jerry | 785.17 | Handy | im selben Kampf „Angriff“ tippen, dann die Android-Zurück-Taste (oder Wischgeste) | wieder die Befehle (Angriff, Können, Tasche …), der Kampf läuft weiter | der Kampf endet, das Spiel geht ins Menü, oder nichts passiert |
| 297.10 | Tom | 785.10 | Handy | Zeile 297.10 → „Lage herstellen“ (Probekampf Ratten, dein Held Stufe 5: ein leichter Kampf); vor dem ersten Zug die Starttafel ansehen, „Kämpfen“ tippen und den Kasten deines Helden unten ansehen | vor dem Kampf zwei Knöpfe „Kämpfen“ und „Schnell“; im Kampf zeigt der Kasten des Helden nur Leben und Mana, keinen Erfahrungsbalken und keine Stufe | keine Starttafel, ein Erfahrungsbalken oder „Lv.“ im Kasten des Helden |
| 297.11 | Tom | 1515, 1417, 1535 | Bild (Tom sendet nach dem grünen Lauf) | Wachsoldatin mit Schild und eine Bewohnerin im Kaufkleid in der Ruhebewegung, alt gegen neu: kein Stoffstreifen mehr zwischen Unterarm und Rumpf | – | – |
| 297.12 | Tom | 1522 | ohne dich | README ohne SRD-Hinweis und Satz zu Wizards of the Coast (kein Spielinhalt) | – | – |
| 297.13 | Jerry | 1505 | ohne dich (Diogenes bestätigt am Lauf) | `wolf_mess_438`: Wölfe rücken nach einem Tod auf einen neuen Platz; `tod_ragdoll_1215`: Sterben im Physiktakt, bei jeder Bildrate gleich | Test grün | Test rot |
| 297.14 | Jerry | 1514 | ohne dich (Diogenes bestätigt am Lauf) | `typen.py`: `kampf/treffer_fx.gd` mit Typen | Test grün | Test rot |
| 297.15 | Spike | 1483 | Handy | Reiter „Test“, diese Zeile 297.15 aufklappen, ins Feld „Anmerkung, freiwillig …“ ein Wort tippen, dann „Passt“; danach „Ergebnis kopieren“ und irgendwo einfügen | im eingefügten Text steht „- 297.15 ✓ <dein Wort>“ | Feld fehlt, das Wort ist nach „Passt“ weg, oder der Text zeigt nur „✓“ |
| 297.17 | Tom | 1530 | Handy | Menü → Chronik → unter „Bisher geschehen“ „Die Ankunft ansehen“; beim dritten Bild (Platz mit Brunnen und Tempel, „Der Platz schläft …“) hinsehen | fünf Träger mit Fackeln gehen rechts die Straße entlang zum Tempel, ihr Licht liegt warm auf dem Pflaster und spiegelt sich in der Pfütze; einer nach dem anderen verschwindet hinter dem Tempel | der Platz bleibt leer, die Fackeln stehen still, oder das Licht fehlt |
| 297.18 | Tom | 431h | Handy | Zeile 297.18 → „Lage herstellen“ (Probekampf Wölfe, dein Held im Plattenpanzer); im Kampf deinen Helden ansehen; danach in der Welt (dort trägt dein eigener Held seine eigene Brustrüstung, nicht den Plattenpanzer) Menü → Ausrüstung: die Brustrüstung antippen, „Ablegen“; dann Tasche → dieselbe Rüstung → „Anlegen“, jedes Mal die Figur ansehen | im Kampf trägt dein Held sichtbar einen Plattenpanzer, nichts sticht durch; in der Welt verschwindet beim Ablegen die Rüstung an der Figur, beim Anlegen kommt sie wieder | der Held trägt im Kampf seine Herkunftskleidung statt des Panzers, Haut oder Kleid sticht durch, oder die Figur ändert sich beim Ablegen nicht |
| 297.19 | Tom | 1423 | Handy | Zeile 297.19 → „Lage herstellen“ (Höhle bei Krogg wie 297.1, mit vollen Vorräten); Tasche → Leuchtfunke → „Benutzen“, dann drei Schritte nach rechts hinter die hohe Wand und zurück | über dem Helden leuchtet ein Funke, der Held ist auch hinter der Wand bei Krogg gut zu sehen (ohne Funken steht er dort im Dunkeln, so gewollt: Licht nur aus Quellen) | mit Funken bleibt der Held im Dunkeln oder ist nicht zu erkennen |
| 297.20 | Jerry | 1340 | ohne dich (am Film gebilligt, 👍 17.11., 06:08) | Skelett und Wiedergänger sterben mit Physik wie die Goblins | – | – |
| 297.21 | Tom | 1549 | ohne dich (nur Prüfbild, kein Spielcode) | `kleid_film2_431` (Nahtbilder 431h): wer sitzt, hat die Waffe abgelegt; im Spiel sitzt der Held nie, die einzige sitzende Figur (Borin) trägt nichts. Sichtbar im nächsten Rüstungsbild | – | – |
| 297.22 | Tom | 1155 | ohne dich (am Bild freigegeben, Chef 17.11., 12:24 über Sokrates) | Wasser im Wald aus dem Kaufpaket: Teich klar, Bach | – | – |

## Lagen

- 297.1: station=Krogg ort=cave:2:11:RIGHT ruhig
- 297.6: probe=GRAK zug=heavy
- 297.7: probe=WOLVES
- 297.8: probe=WOLVES
- 297.9: probe=WOLVES
- 297.10: probe=RATS pstufe=5
- 297.18: probe=WOLVES ruestung=plate
- 297.19: station=Krogg ort=cave:2:11:RIGHT ruhig vorraete
