# 598 · Umweltklang: was fehlt gegen alt, Regen zurück? · Jerry · 06.11., 07:40

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/38baab14d/godot/klang/klang.gd (gegen alt `core/.../audio/`: PlaceSound, Ambience, WildSound, RiverSound, PondSound, RainSound, `Weather.kt`)

**Frage:** Soll der Regen aus dem alten Spiel zurückkommen (Bild und Klang), und in welcher Reihenfolge baue ich die fehlenden Ortsklänge?

**Votum Jerry:** ja zum Regen, nach dem Durchspiel-Build (488); vorher die zwei fehlenden Klänge, die es alt gab und die ohne neue Bilder gehen: Leute in der Schenke, dann der Teich (509).

**Berührt:** 598, 509 (Teich), 517 (Waldklang), 555 (Nacht), Team Tom (Regen im Bild).

## Sachverhalt: je Ort alt gegen neu

| Ort | alt | neu (Godot) |
|---|---|---|
| Dorf, Wald, Tiefer Wald | Wind; Vögel bei Tag, Grillen und Eule nachts; im Tiefen Wald keine Vögel, fernes Wolfsheulen | gleich (517); nachts erst hörbar, wenn es im Spiel Nacht wird (555) |
| Fluss, Brücke | Rauschen, lauter zur Brücke | gleich |
| Teich | Frösche, Libellen, Froschchor in der Dämmerung | **fehlt** (509) |
| Lagerfeuer, Herd | Knistern, lauter zum Feuer | gleich |
| Höhle | Tropfen, Grollen im Berg | gleich |
| Tempel | stille Halle | gleich |
| Schenke, Häuser | Holz knarrt, Husten; Wirt wischt und schenkt ein, Gast stellt die Flasche ab, rückt den Stuhl, je mit der Bewegung | Knarren, Husten gleich; **Leute fehlen** |
| Draußen bei Regen | Regen setzt in 9 s ein und hört ebenso auf, unter Dach und in der Höhle still; selten Wetterleuchten, Donner 2–4 s später | **fehlt ganz**, auch im Bild |

Wetter gab es alt also: Regen nach Zufall (Testmenü: immer, nie, zufällig). Wind je Wetter oder Böen gab es alt nicht (im Code kein Fund).

## Stärkstes Gegenargument

Regen ist ein Umbau über beide Teams (Bild bei Tom, Klang bei mir) und kein Fehler; die oberste Direktive verlangt „immersiv durch Klang“, aber Kapitel 1 ist ohne Regen spielbar. **Darum:** erst nach dem Durchspiel-Build, die Klänge ohne neue Bilder vorher.
