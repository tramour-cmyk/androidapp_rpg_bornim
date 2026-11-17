# 1211 · Leuchtfunke: heute gegen R7 rocket_trail (Film nachts im Dorf)

Spike · 17.11., 21:46 · Prüfauftrag Chef 13.11., 19:10 („Prüfe auch mal, ob wir Rocket Trail nicht als Lichtquelle verwenden können für den Trank“)
Kurz: rocket_trail macht den Funken größer und heller, bringt aber kein besseres Licht. Kühl eingefärbt wird er ein weißer Klecks, in der Urfassung ist er orangefarbenes Feuer mit Rauch. Den Lichtkreis am Boden macht in „heute“ und „kühl“ dasselbe Licht.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/3f4f21c7f (Film am Rechner, Renderer des Handys, Lavapipe), Skript `godot/tests/film_funke_1211.gd`, ein Lauf (Freigabe Sokrates 21:23); Film auf Telegram

**Film:** Der Held geht nachts um 23 Uhr durchs Dorf. Links der Funke von heute: ein kleiner Kern mit Hof, sein kühles Licht am Boden. In der Mitte rocket_trail in kühlem Weiß (`FUNKE_FARBE`), ohne Rauch und ohne eigenes Licht; das Licht kommt weiter vom Funken von heute. Rechts rocket_trail unverändert: warmes Feuer mit Rauch und eigenem orangefarbenem Licht.

**Befund:**
- rocket_trail hat ein eigenes Licht, aber nur warmes und flackerndes (rechts). Kühl bleibt das Licht von heute; rocket_trail ändert dann nur den Leuchtkörper, nicht das Licht am Boden.
- Kühl wird es eine überstrahlte weiße Wolke, nicht gedämpft (623.8). Der Schweif ist beim Gehtempo kaum zu sehen.
- Unverändert ist es Feuer mit Rauch über dem Kopf. In der Inventur vom 09.11. steht rocket_trail unter „Unbrauchbar (Science-Fiction, bunt)“.
- Bildrate am Rechner gleich (heute 2,8, kühl 2,8, unverändert 2,7 Bilder/s; Zeichenaufrufe 125/127/128).

**Offen:** Der Held ist im Film unbekleidet; Ursache nicht geprüft (vermutlich der Modellstand aus dem Kaufcache in der Sitzung). Einmal verdeckt ein Hausdach das Bild. Mit nur einem Lauf war das nicht zu wiederholen.

Empfehlung: den Funken von heute behalten; was dem Chef am Licht fehlt (Hof, Lichtkreis, Tusche), als eigenen Vorgang am Licht angehen, nicht über rocket_trail.

👍 Funke bleibt wie heute · 👎 rocket_trail kühl weiter (dann gedämpft, kleiner)
