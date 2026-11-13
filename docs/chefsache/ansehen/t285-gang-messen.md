# Tom und Jerry · Build 285 · 0.348.464 · Aufträge, Brücke, Metall sperrt Zauber, Messen · PR #204
E Welt · Tom (542, 964, 1145, 1168, 1180, 1190, 1212, 1218, 1030), Jerry (644b.1, 904, 987, 1013, 1014, 1025, 1049, 1054, 1136, 1141, 1162, 1166, 1194, 1206; Messungen 932, 1141.1) · 13.11., 23:30 · [APK (Lauf 464)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43505629901/artifacts/14079389845)

Entwurf Tom; Teil Jerry von Tom aus Jerrys Vorrat eingetragen, Jerry prüft und ergänzt; gegenlesen: Sokrates (Punkte beider Teams).

Gegengelesen: Sokrates 13.11., 21:32 (mit drei Hinweisen an Tom, vor dem Bau beheben: 285.9 Wert des Rings, 285.10 Zauber anderer Schulen, 1190 als Bild zur Kenntnis). Tom 21:34: 285.9 bleibt „Schutzwert +1, Leben +5“ (das Spiel nimmt `werte.json` einzelstuecke, `zusatz` AC 1, HP 5; die `rolls` in `texte.json` liest es nicht, nur den Namen); 285.10 auf Bannschild gegen Funkenpfeil umgeschrieben (gesperrte Zauber fehlen in der Liste, `mars.gd` 637); 1190 als Handy mit „Vier Güten“, weil der Bildlauf für 1190 nach 621 A verbraucht ist

Ein Weg: über Build 284 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand ins Dorf (285.1); das Bild 285.2 kam als eigene Nachricht auf Telegram (👍 passt, 👎 falsch); dann Reiter „Test“, je Zeile 285.7 bis 285.10 „Lage herstellen“, zuletzt 285.11 „Vier Güten“.

Zurück an Tom, nicht in diesem Test (die Aufnahmen aus Lauf 464 zeigen den Gegenstand nicht, Tom 23:28): 285.3 Fußstaub (1119; Film aus der Ferne, Held am Schlagbaum, Staub nicht zu erkennen), 285.5 Lyra wendet (1040.1; Film 3,5 s, fast schwarz, Lyra nicht zu sehen), 285.6 Höhlenausgang (1091; beide Bilder zeigen das Hauptmenü). Neue Aufnahmen, dann der nächste Build.

Schon gebilligt, fährt unverändert mit (kein neuer Prüfpunkt): 1162 Steinkreis im Kampfort (Bild, 👍 20:28), 1166 Atmen aller Tiere (Film, 👍 20:34), 1141 Goblins sterben verschieden (Film r4, Chef 19:41 „passt es jetzt erstmal“).

Nicht in diesem Build: 1149 Dolch an der Hüfte (die Lederscheide fehlt noch, Chef 19:45; Bild vorher, dann nächster Build).

Messungen im Lauf, nicht für dich: 697 (Drehteller halbtransparent, Schritt „Alpha 697“), 932 (Angriffstakt des Helden), 1141.1 (fallen die Körper um die Füße).

Im Bau geprüft: Tageslicht des Höhlenausgangs reicht drei Kacheln in den Gang, nachts höchstens halb so hell (`tageslicht_1091`), Messschalter im Testmenü an und aus (`messen_1145`), innen keine Waffe an der Figur, Schild bleibt (`waffe_innen_1168`), Lage nur mit Gegnern, die ein Modell haben, und Lage mit Brustrüstung (`lage_modell_1180`, `lage_1156`), Kurzzeile ohne Gütewort, Fenster mit Güte, kein Deckel, Schutzwert halb so oft wie Leben (`gegenstaende_870`, `brs_held_870`, `obergrenze_701`), Ziege tauscht von beiden Seiten den Platz (`ziege_4162`), aufgeklappte Zeile im Reiter „Test“ steht im Bild (`rollstand_1030`), Eingebung ohne Nebenmeldung (`eingebung_840`), Randwege (`rand_1022`), Tod der Goblins (`tod_1141`), Atmen der Tiere (`atem_tiere_1166`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 285.1 | Tom | 1168 | Handy | „Weiter“ mit deinem Spielstand, mit der Waffe in der Hand in die Schenke gehen, dann wieder hinaus | drinnen keine Waffe am Helden (Schild bleibt), draußen wieder in der Hand | Waffe auch drinnen; draußen fehlt sie |
| 285.2 | Tom | 1218 | Bild | Dorf Süd, der Steg über den Bach, Blick quer zum Wasser; links Build 284, rechts 285 [Bild von 13.11., 23:28](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/13-2328-t285.2-Tom.png) | der Steg liegt an beiden Enden auf dem Weg auf | der Steg endet über dem Wasser und schwebt |
| 285.4a | Tom | 1022.1 | Bild | Flüsterwald Süd, Blick vom Helden den Weg entlang über den Kartenrand; links Build 284 (dein Bild vom 13.11., 19:20), rechts 285 (Spike) [Bild von 14.11., 00:24](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/14-0024-t285.4a-Spike.png) | kein grüner Querstrich über dem Weg; der Weg schwingt hinter dem Rand und franst am Rand aus | Querstrich; Weg läuft wie mit dem Lineal |
| 285.4b | Tom | 1022.1 | Bild | Tiefer Flüsterwald West, Blick den Weg entlang über den Rand; links 284, rechts 285 (Spike) [Bild von 14.11., 00:24](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/14-0024-t285.4b-Spike.png) | der Weg schwingt hinter dem Rand, Rand ausgefranst | Weg gerade wie mit dem Lineal, Rand glatt |
| 285.7 | Tom | 1145 | Handy | Reiter „Test“ → „Bildrate“ an; Zeile 285.7 → „Lage herstellen“ (Höhle vor Krogg); unter „Anzeigen“ je einen der Schalter Tusche, Tusche nach Lampen, Nebel, Schatten aus und wieder an, jedes Mal Bilder/s, Grafikzeit, Rechenzeit ablesen (Bildschirmfoto genügt) | über der Welt stehen Bilder/s, Grafikzeit, Rechenzeit, Bildschirm in Hz und „aus: …“; der abgeschaltete Teil fehlt im Bild | Schalter ändert nichts; die Zeile fehlt |
| 285.8 | Tom | 542 | Handy | Zeile 285.8 → „Lage herstellen“ (Krogg besiegt, du stehst vor dem Anschlagbrett, Monster beachten dich nicht); am Brett „Feuer am Steinkreis“ und „Gwennas Ring“ annehmen. Reiter „Test“ → Teleport „Wald“, ein paar Schritte nach Süden zum Steinkreis, an einen Stein treten, „Ansehen“ tippen. Teleport „Höhle“, die Truhe links oberhalb des Eingangs öffnen. Teleport „Dorf“: Jorin am Schlagbaum im Norden ansprechen, dann Gwenna im Süden des Dorfs | am Stein: Asche, Stiefelspuren, ein grauer Fetzen mit gesticktem Auge kommt in die Tasche; in der Truhe ein Ring aus angelaufenem Silber; Jorin und Gwenna nehmen Fetzen und Ring, danken, beide Aufträge stehen in der Chronik als erledigt | am Stein nichts; Truhe ohne Ring; ein Auftrag bleibt offen, obwohl Fetzen oder Ring abgegeben sind |
| 285.9 | Tom | 542 | Handy | Zeile 285.9 → „Lage herstellen“ (Kapitelende: vor Aldric in seinem Haus); Aldric ansprechen bis „Nimm diesen Ring“, Kapitelende und Morgen durchtippen; Menü → Tasche | in der Tasche „Ring des Ältesten“, selten, mit eigenem Namen und Werten (Schutzwert +1, Leben +5) | nur „Ring“ ohne Namen; Ring fehlt |
| 285.10 | Tom | 964 | Handy | Zeile 285.10 → „Lage herstellen“ (Probekampf gegen Wölfe, Zauberlehrling im Kettenhemd); im Kampf die Zauberliste öffnen und „Bannschild“ wirken (der Zauberlehrling kennt sonst „Bannschild“ und „Funkenpfeil“) | im Kettenhemd steht nur „Bannschild“ (Schutzmagie) in der Liste und wirkt; „Funkenpfeil“ (Evokation) fehlt | im Kettenhemd steht „Funkenpfeil“ in der Liste; „Bannschild“ fehlt oder wirkt nicht |
| 285.11 | Tom | 1190 | Handy | Reiter „Test“ → „Vier Güten“ (dieselbe Waffe Schlecht, Normal, Gut, Meisterhaft), Menü → Tasche, dann das meisterhafte Stück antippen | in den vier Zeilen unter dem Namen kein Wort zur Güte, nur das Zeichen am Bild; im Fenster „Güte: Meisterhaft“ | „Gut“ oder „Meisterhaft“ steht in der Zeile; das Fenster nennt die Güte nicht |
| 285.12 | Tom | 1180, 1212, 1030 | ohne dich (Diogenes bestätigt am Lauf) | `lage_modell_1180`, `ziege_4162`, `rollstand_1030` im Lauf der APK | grün | rot |
| 285.13 | Jerry | 644b.1, 1194, 1206 | ohne dich (Diogenes bestätigt am Lauf) | `gegenstaende_870`, `brs_held_870`, `obergrenze_701` (kein Deckel, Schutzwert halb so oft), `eingebung_840`; Kauf-Cache baut nicht doppelt (Protokoll des Laufs) | grün | rot |
| 285.14 | Jerry | 904, 987, 1013, 1014, 1025, 1049, 1054, 1136 | ohne dich (Diogenes bestätigt am Lauf) | aus 280, 281, 284 ohne Rückmeldung, Code schon in 284: `sim444_870` (904), `krogg_494` (987, jeder Wurf 20 hält), `schild_406` (1013, 1014), `zweikampf_1025` (1025), `absicht_1049` (1049), `mars_regeln` (1054), alle im Lauf der APK ohne „oder true“ (1136) | grün | rot |

## Lagen

- 285.7: station=Krogg
- 285.8: station=Grak ort=village:4:8:UP uhr=10:00 ruhig
- 285.9: station=Kapitelende
- 285.10: probe=WOLVES held=test herkunft=Zauberlehrling ruestung=chain_shirt
