# Jerry · Testreihe 16.10.: vier Sammelbuilds

Jerry · 16.10., 14:3x · ersetzt die 14 Einzel-Builds (108a: Chef „sinnvolles Bündeln, damit ich nicht alles extra installieren muss“). Vorher-/Nachher-Bilder und Hörproben kamen per Telegram.

Kurz: 4 Sammelbuilds statt 14 Einzel-APKs, je Build eine Prüfliste; Reihenfolge 1 → 4

**Zu tun:** Build 1 installieren, seine Punkte prüfen, Ergebnis je Punkt („1.2 passt“, „1.3 nicht, weil …“) schreiben; dann Build 2, 3, 4. Jeder Build enthält `main` (auch Toms #71) und lässt sich über 0.1.757 und 0.1.773 installieren; die Nummern steigen von 1 nach 4 (0.1.777–0.1.780).

APK: im PR unten unter „Checks“ → „build“ → „Artifacts“. Testmenü: Reiter „Test“ (Uhrzeit +3 h, Teleport, „Held trifft immer kritisch“, „Bosse zurücksetzen“, „Alle Vorräte auf mindestens 10“).

Build 1–7, 9, 10 passen, auf `main` (PR #88, #89, #90, #91, #85, #87; 7, 9, 10 über PR #97). Offen: Build 8 (neu gebaut als 0.1.812, mit `main`, Zuruf Chef zu 72.10) und Build 11 (0.1.813, Rennen laut). Beide lassen sich über 0.1.806 installieren; Reihenfolge 8 → 11.

## Build 8 · 0.1.812 · Probe 72.10: Held und Söldner gegen Grak · [PR #68](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/68)

**APK direkt:** [0.1.812](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38957534926/artifacts/12071372011) (neu gebaut 16.10., 21:47 von Tom, enthält `main` bis PR #97). Ältere Builds im PR (0.1.796, 0.1.799) nicht mehr nehmen.

Erst die neue Kampfart zum Ausprobieren, noch nicht im Spiel: Reiter „Test“ → „Probe 72.10: Held und Söldner gegen Grak“ → Klasse des Söldners. Zahlen und Texte sind vorläufig (Texte bei Kreativ). Stil-Abgleich: gemalte Höhlenhalle mit Fackeln, Figuren im Fackellicht mit Schatten; Übergänge Ruhe ↔ Ausholen (Grak, solange der Ring läuft) ↔ Schlag mit kurzem Ausfall ↔ Ruhe, Treffer lässt zittern; selbst gefilmt durch die echte Oberfläche (Ring, Zielwahl, Wechsel der Züge). Bild des Rings per Telegram (18:5x).

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 8.1 | 72.10 | Probe starten (zuerst Kämpfer als Söldner) | nach 1–2 s stehen Held, Söldner und Grak; über Grak ein Schild mit seiner Absicht (»Rudel rufen«, »Schwerer Hieb«, »Kraft sammeln«) | Höhle bleibt länger als 3 s leer; Absturz |
| 8.2 | 72.11 | warten, bis Grak zuschlägt (nur Grak, Goblins ohne Ring); ein goldener Ring zieht sich um den Angegriffenen; irgendwo in die Szene tippen, wenn er sich schließt (mehrmals, auch zu früh und zu spät) | Grak holt sichtbar aus; oben „Perfekt!“, „Gut“ oder „Verpasst“; bei „Gut“ weniger Schaden, bei „Perfekt!“ keiner | Ring ruckelt; Tippen ohne Wirkung; Moment kaum zu treffen |
| 8.3 | 72.10, 72.13 | Angriff (bei mehreren Gegnern Ziel wählen), Platz, Abwarten; dann „Söldner: selbst“ auf „Automatik“ | Szene und Knöpfe bleiben ruhig an ihrem Platz; auf Automatik handelt der Söldner allein | Szene springt; Söldner wartet trotz Automatik |
| 8.4 | 72.11 | Grak hart treffen, solange er »Schwerer Hieb« oder »Kraft sammeln« angesagt hat | ab einem Fünftel seiner Lebenspunkte taumelt er, die Absicht ist vereitelt | Absicht läuft trotzdem |
| 8.5 | Gefühl | zwei, drei Durchgänge mit anderen Klassen (auch Magier) | spannend, echte Wahl zwischen Angreifen, Platz und Abwarten | langweilig; Takt nervt (dann sagen, was) |


## Build 11 · 0.1.813 · 86: Rennen laut · [PR #98](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/98)

**APK direkt:** [0.1.813](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38957756429/artifacts/12072105768). Von Tom aus Jerrys Zweig gebaut (16.10., 21:49). Außer Atem würfelt der Held die Initiative mit Nachteil; das prüfen Kerntests, nicht du.

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 11.1 | 86 | Tiefer Wald, tagsüber; einem Wolf erst gehend, dann (neu laden oder anderer Wolf) rennend entgegen | rennend erscheint das „!“ über dem Wolf deutlich früher (etwa 2 Felder weiter weg) | kein Unterschied; „!“ schon über den halben Bildschirm |
| 11.2 | 86 | ausdauernd rennen, bis der Held keucht, dann gehend an einen Wolf heran | nicht mehr früher bemerkt als beim Gehen | bemerkt wie beim Rennen |
