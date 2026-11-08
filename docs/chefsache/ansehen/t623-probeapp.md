# Tom und Jerry · Probe 623 (Lauf 306) · 0.348.306 · Welt und Effekte vor dem Kauf · Zweig claude/tom-6236-probeapk
E Welt · Tom und Jerry · 08.11., 19:22 · [APK: Artefakt „bornim-godot-apk“ im Lauf 306](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42503105716/artifacts/13628378603)

623.6 und 623.5 (Chef 17:05: „Ja, Probe-APK für Welt und Effekte zusammen.“): eigene App „Bornim Probe 623“ neben dem Spiel, kein Build und kein PR, darum sieben Zeilen je Ort und Effekt statt der Buildregel; Build 270 und dein Spielstand bleiben unberührt. Archiv laden, entpacken, `bornim-godot.apk` installieren, öffnen, neues Spiel. Gekauft wird ein Paket nur, wenn beide Fragen mit Ja beantwortet sind: sieht es am Handy deutlich besser aus als unsere Fassung, und bleibt die Bildrate flüssig? Die Lizenz aller elf REEBOO-Pakete ist geprüft (`LISTE-QUELLEN.md`, 07.11.).

Verglichen (alt gegen neu): Reiter „Test“ mit der neuen Reihe „Proben 623.6“ (Zeichen und Meldung wie die anderen Schalter); sonst keine Schirme neu.

Ein Weg: Reiter „Test“ → „Bildrate“ an; Teleport Dorf, zum Bach im Süden (A); Teleport Wald, Wiese im Norden und Teich nordwestlich (B); dann im Reiter „Test“ unter „Kampfhilfen“ den Knopf „Effekte“ (C). Die Schalter für die Welt stehen im Reiter „Test“ unter „Welt“, Reihe „Proben 623.6“; das Menü bleibt offen, die Welt dahinter wechselt sofort, und die Wahl bleibt beim Ortswechsel erhalten.

## A · Dorfbach (Water Kit, Weather FX)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| A1 | Tom | 623.6 | am Bach „Wasser“ tippen: zwischen unserem Wasser und „Paket klar“ wechseln | Paket: klares Wasser mit sichtbarem Grund und Spiegelung; deutlich besser als unseres? Bildrate ablesen | Wasser schwarz oder rosa; Bildrate bricht ein |
| A2 | Tom | 623.6 | „Regen“ an (Weather FX), eine Minute stehen | nur Regen mit Spritzern und Ringen, kein grauer Nebel; Regen hörbar; der erste Blitz nach 4 bis 9 s, dann alle 9 bis 22 s, danach Donner; deutlich besser als ohne? Bildrate ablesen | graue Suppe; stumm; Bildrate bricht ein |

## B · Flüsterwald (Grass & Wind, Water Kit, Surface Shaders)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| B1 | Tom | 623.6 | auf der Wiese im Norden „Gras“ tippen: unser → „Paket Frühling“ → „Paket Sommer“, durchs Gras gehen | Gras des Pakets wiegt im Wind, der Held schiebt es beiseite; deutlich besser als unseres? Bildrate je Fassung | Gras fehlt oder schwebt; Bildrate bricht ein |
| B2 | Tom | 623.6 | am Teich (nordwestlich) „Wasser“ auf „Paket klar“ stellen | wie A1, am Teich | wie A1 |
| B3 | Tom | 623.6 | irgendwo „Oberflächen“ an | fünf Felsen vor dem Helden: Runen glühend, Runen grün, Schnee, Eis, Lava; deutlich besser als unsere Felsen? | Felsen weiß oder schwebend |

## C · Effekte im Kampfort (Jerry, 623.5)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| C1 | Jerry | 623.5 | Reiter „Test“ → „Effekte“; alle Effekte laufen nacheinander, die Bilder je Sekunde stehen oben | jeder Effekt aus einem Guss, lesbar; Bildrate flüssig | Effekt fehlt, Absturz |
| C2 | Jerry | 623.5 | Knopf „Fassung“: zwischen Paket und unserer Fassung wechseln | derselbe Effekt in unserer Fassung; Paket deutlich besser? | kein Unterschied zu sehen |

Bekannt: Blumenwiese gibt es in der Gratisprobe Grass & Wind nicht (nur die Fassungen Frühling und Sommer). Unsere Felsen sind mit dem Boden zu einem Netz verschmolzen, darum stellt „Oberflächen“ eigene Felsen des Pakets vor den Helden. In unserer Fassung der Effekte stehen in dieser Probe noch Kampfleisten und Ansagen (behoben f32cac483, nicht in Lauf 306).
