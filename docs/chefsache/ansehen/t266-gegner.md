# Tom und Jerry · Build 266 · Godot 0.348.266 · Gegner von Kapitel 1 und Kampf · [PR #185](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/185)
E Kampf · Jerry (494, 577, 575, 573, 564), Tom (566, 567, Übernahme) · 05.11., 12:35 · [Lauf 266, bornim-godot-apk](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42009917474/artifacts/13410931658) (Tests grün 12:3x) · Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42009917474

Ein Weg: über Build 257 installieren; erst im Reiter „Test“ die MARS-Probekämpfe (A), dann mit dem eigenen Helden in den Flüsterwald und den Tiefen Wald (B).

Verglichen (512b, fremder Helfer 05.11., 09:46, ohne Bild): Kampfschirm alt (Battle.kt gegen acht Gegner nachgespielt) gegen neu (alle Probekämpfe dieser Liste mit Autopilot, Klang und Texte mitgeschrieben, Karte nach karten.json); Bilder je Gegner aus Lauf 265 (ansehen/494-gegnerbild.md, Prüfer 05.11., 11:2x). Seine Funde sind behoben (Fell auf Karte und im Kampf gleich, tote Bosse springen nicht, Namen im Reiter „Test“) oder stehen unten unter „Bekannt“.

## A · MARS-Probekampf (Reiter „Test“, Gegner wechseln)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 266.1 | Jerry | 494 | Gegner nacheinander „Wildschwein“, „Hundertfüßer“, „Riesenegel“, „Säureschnecke“, „Ratte“, „Fledermaus“, „Spinne allein“, „Krogg“; je kurz kämpfen | jedes Tier steht allein in seinem eigenen Modell: Keiler, Hundertfüßer, Egel, Schnecke, Ratte, Fledermaus, Spinne; Krogg als Grobian mit Bärenkopf und Morgenstern; sein Name steht über ihm, es greift an und fällt | ein Wolf, eine graue Kapsel oder ein Goblin statt des Tiers; Name „Wolf“; der Kampf hängt |
| 266.2 | Jerry | 577, 575 | Gegner „Ratten“ (drei), zuhören und die Texte lesen | die Ratten fauchen und quieken wie Ratten; Texte sagen „Riesenratte“, der Lohn nach dem Sieg 25 EP wie alt | Wolfsknurren; Sätze von Wölfen („Jungwolf“, „Rudel“); Name „Wolf“ |
| 266.3 | Jerry | 573 | Gegner „Wolf mit Jungwölfen“, einmal mit dem Haken „ich gewinne“, einmal normal bis zum Sieg | jeder Gefallene bleibt liegen, wo er fiel, auch der letzte | der zuletzt Gefallene wird in die Mitte gezogen |
| 266.4 | Tom | 567 | Gegner „Wolfsrudel“, dann „Goblin-Späher“ | die Gegner stehen getrennt nebeneinander, jede Ansage hängt mit Strich an ihrem Tier (bei dreien zwei seitlich neben dem Kopf) | zwei Tiere fast übereinander; eine Ansage hängt seitlich ohne Figur |
| 266.5 | Tom | 566 | „Goblin-Späher“, warten, bis einer „In den Schatten“ ansagt und seinen Zug macht | nach seinem Zug ist er blass, mit Schatten am Boden, bis zu seinem nächsten Zug; dann wieder voll da | er sieht im Schatten aus wie immer |
| 266.6 | Jerry | 564 | nach den Probekämpfen ein paar Knöpfe lange drücken, dann Reiter „Test“, „Absturzbericht zeigen …“, „Seit Start, Fehler“ | kein „Lambda capture at index 0 was freed“ | die Zeile steht da, wie in Build 257 viermal |

## B · Flüsterwald und Tiefer Wald (eigener Held)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 266.7 | Jerry | 494 | Flüsterwald am Tag durchs hohe Gras gehen, Monster auf der Karte ansehen und in eines hineinlaufen; „Teleport“ Tiefer Wald; dann Reiter „Test“, „Tag / Nacht“ und noch einmal | auf der Karte stehen jetzt auch Wildschwein, Hundertfüßer, Riesenegel; die Ratte allein (wie alt, in Build 257 kamen drei); nachts die Fledermaus allein; im Tiefen Wald die Riesenspinne allein; jedes in seinem Modell, im Kampf dasselbe Tier mit demselben Fell; Hundertfüßer und Egel sind selten wie alt (sonst Reiter „Test“, „Neben den Helden holen“) | ein Tier fehlt auf der Karte oder ist ein Platzhalter; drei Ratten aus einer; ein anderes Tier im Kampf als auf der Karte |
| 266.8 | Jerry | 494 | Reiter „Test“, „Teleport“ Höhle; umhergehen, dann zu Krogg (Testreiter „Stationen“, falls die Geschichte noch nicht so weit ist) | in der Höhle laufen auch Säureschnecke und Riesenspinne; Krogg steht da und kämpft als Grobian mit Morgenstern; mit Morwens Rauchbündel steht zu Beginn „… wirft Rauchbündel!“ und sein erster Schlag geht fehl; danach Grak; beide bleiben nach dem Fall liegen, auch wenn am Ende das Ergebnis kommt | Krogg fehlt (wie in Build 257), der Kampf beginnt nicht oder gegen ein anderes Tier |

**Bekannt:** Kämpfe in der Höhle stehen noch auf der Waldlichtung (507); der Rauchwurf ist nur eine Textzeile, ohne Bewegung, Rauch und Klang; Ansturm des Keilers, Blutsaugen des Egels, Säure der Schnecke und Kroggs schwerer erster Schlag aus der alten Fassung fehlen noch, die Ansage heißt bei ihnen „Stich“ (kommt mit den Regeln des BRS, 478); der Egel klingt wie die Stirge mit Flügelsurren; Goblins, Späher, Schamanen, Kobolde kommen noch in Dreiergruppen statt wie alt; Grimmzahns Blende spricht noch mit Wolfssätzen (533); die Höhle selbst sieht noch aus wie in Build 257 (neu mit 492, Tom); Einzelstücke als Beute von Krogg, Grak, Grimmzahn und Spinne fehlen noch (mit Toms 505); Skelett, Zombie, Ghul kommen mit 506; die Fledermaus ist die eigene, bis du in 510 wählst.
