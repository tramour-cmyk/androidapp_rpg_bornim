# Tom und Jerry · Probe 623 (Lauf 306) · 0.348.306 · Welt und Effekte vor dem Kauf · Zweig claude/tom-6236-probeapk
E Welt · Tom und Jerry · 08.11., 19:06 · [APK: Artefakt „bornim-godot-apk“ im Lauf 306](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42503105716)

623.6 und 623.5 (Chef 17:05: „Ja, Probe-APK für Welt und Effekte zusammen.“): eigene App „Bornim Probe 623“ neben dem Spiel; Build 270 und dein Spielstand bleiben unberührt. ZIP laden, `bornim-godot.apk` installieren, öffnen, neues Spiel. Gekauft wird ein Paket nur, wenn beide Fragen mit Ja beantwortet sind: sieht es am Handy deutlich besser aus als unsere Fassung, und bleibt die Bildrate flüssig? Die Lizenz aller elf REEBOO-Pakete ist geprüft (`LISTE-QUELLEN.md`, 07.11.).

Verglichen (alt gegen neu): Reiter „Test“ mit der neuen Reihe „Proben 623.6“ (Zeichen und Meldung wie die anderen Schalter); sonst keine Schirme neu.

Ein Weg: Reiter „Test“ → „Bildrate“ an; Teleport Dorf, zum Bach im Süden (A); Teleport Wald, Wiese und Teich (B); dann im Reiter „Test“ unter „Kampfhilfen“ den Knopf „Effekte“ (C). Die Schalter für die Welt stehen im Reiter „Test“ unter „Welt“, Reihe „Proben 623.6“; das Menü bleibt offen, die Welt dahinter wechselt sofort, und die Wahl bleibt beim Ortswechsel erhalten.

## A · Dorfbach (Water Kit, Weather FX)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 623.1 | Tom | 623.6 | am Bach „Wasser“ tippen: zwischen unserem Wasser und „Paket klar“ wechseln | Paket: klares Wasser mit sichtbarem Grund und Spiegelung; deutlich besser als unseres? Bildrate ablesen | Wasser schwarz oder rosa; Bildrate bricht ein |
| 623.2 | Tom | 623.6 | „Regen“ an (Weather FX), eine Minute stehen | nur Regen mit Spritzern und Ringen, kein grauer Nebel; Regen hörbar; alle 10 bis 20 s ein Blitz, danach Donner; deutlich besser als ohne? Bildrate ablesen | graue Suppe; stumm; Bildrate bricht ein |

## B · Flüsterwald (Grass & Wind, Water Kit, Surface Shaders)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 623.3 | Tom | 623.6 | auf der Wiese „Gras“ tippen: unser → „Paket Frühling“ → „Paket Sommer“, durchs Gras gehen | Gras des Pakets wiegt im Wind, der Held schiebt es beiseite; deutlich besser als unseres? Bildrate je Fassung | Gras fehlt oder schwebt; Bildrate bricht ein |
| 623.4 | Tom | 623.6 | am Teich „Wasser“ auf „Paket klar“ stellen | wie 623.1, am Teich | wie 623.1 |
| 623.5 | Tom | 623.6 | am Weg „Oberflächen“ an | fünf Felsen vor dem Helden: Runen glühend, Runen grün, Schnee, Eis, Lava; deutlich besser als unsere Felsen? | Felsen weiß oder schwebend |

## C · Effekte im Kampfort (Jerry, 623.5)

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 623.6 | Jerry | 623.5 | Reiter „Test“ → „Effekte“; alle Effekte laufen nacheinander, die Bilder je Sekunde stehen oben | jeder Effekt aus einem Guss, lesbar; Bildrate flüssig | Effekt fehlt, Absturz |
| 623.7 | Jerry | 623.5 | Knopf „Fassung“: zwischen Paket und unserer Fassung wechseln | derselbe Effekt in unserer Fassung; Paket deutlich besser? | kein Unterschied zu sehen |

Bekannt: Blumenwiese gibt es in der Gratisprobe Grass & Wind nicht (nur die Fassungen Frühling und Sommer). Unsere Felsen sind mit dem Boden zu einem Netz verschmolzen, darum stehen die Felsen des Pakets am Weg. In unserer Fassung der Effekte stehen in dieser Probe noch Kampfleisten und Ansagen (behoben f32cac483, nicht in Lauf 306).
