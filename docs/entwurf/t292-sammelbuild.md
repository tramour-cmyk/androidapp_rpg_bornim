# Jerry und Spike · Build 292 · · Sammelbuild: Grafikstufen, Höhle ohne Hakeln, Joystick, Strahlprobe, Lesen · PR folgt
E Technik · Jerry (1285; ohne dich 643, 1305, 1333, 1366), Spike (698, 1286, 1145) · 16.11., 09:50 · APK folgt

Sammelbuild 1393 auf Build 291 aufgesetzt (enthält alles aus 291, 290 und `main`); die Punkte der Listen 290 und 291 kommen hier nicht noch einmal, beide bleiben offen, bis du sie fertig getestet hast.

Ein Weg: über Build 291 installieren, starten und auf die erste Blende achten (292.1), Menü → System → „Grafik“ (292.2), im Reiter „Test“ „Strahlen“ (292.3), dann Zeile 292.4 mit „Lage herstellen“ (Höhle bei Krogg) für 292.4 und 292.5.

Im Bau geprüft: Automatisch senkt die Grafikstufe nur am Ladepunkt, nie mitten in der Szene (698, `grafik_698`), Langbogen und Köcher als Waffenmodell gebaut (643, `waffen_522`; am Garrick sichtbar erst mit 531, Tom), im Probekampf Wölfe steht jedes Ziel, das der Nahkampf treffen darf, auch im Bild vorn (1305, `reihe_1305` mit Kaufwolf, Seed 7 und 9; behoben durch 1321 in Build 291), Wuchtschlag, Zweihänder und stumpfe Waffe melden „schwer“ an das Sterben mit Physik (1333, `handlungen_870`), Lesen spürbar: Größe der Ansage erst ab Lesestufe 1, Gegenschlag gegen großen Schlag offen, Wehr gegen kleinen 60 % (1366, `kerbe_930`; das Kerbensystem ist im Spiel noch aus, nur in den Proben an).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 292.1 | Spike | 698 | Handy | nach der Installation das Spiel starten, „Weiter“, auf die Blende vor dem ersten Ort achten | einmal „Die Feder wird angesetzt.“, darunter kleiner der Satz zum Einmessen, dritte Zeile „… im Systemmenü unter ‚Grafik‘“; danach geht es ohne Hänger in den Ort; beim nächsten Ortswechsel kommt sie nicht wieder | keine Blende; Blende bei jedem Ortswechsel; Spiel hängt |
| 292.2 | Spike | 698 | Handy | Menü → System → Zeichen „Grafik“ antippen, gedrückt halten für den Erklärsatz | Antippen wechselt Automatisch, Hoch, Mittel, Niedrig; Niedrig sieht man (weniger Schatten, weicher), Hoch wieder scharf | kein Zeichen „Grafik“; Wechsel ohne sichtbaren Unterschied; Absturz |
| 292.3 | Spike | 1286 | Handy | Reiter „Test“ → „Strahlen“, einen Strahl abwarten, dann „Zurück“ | das Spiel kommt zurück, keine Fehlermeldung | Fehlermeldung oder Absturz nach „Zurück“ |
| 292.4 | Spike | 1145 | Handy | Zeile 292.4 → „Lage herstellen“ (Höhle bei Krogg), herumgehen und die Kamera drehen | die Höhle läuft gleichmäßig, kein Hakeln beim Gehen und Drehen | es hakelt weiter wie in Build 286 |
| 292.5 | Jerry | 1285 | Handy | in der Höhle (Lage 292.4) den Joystick nur wenig ausschlagen, einmal mit Testmenü „Schnell“ an, einmal aus | im Ring geht der Held, erst über den Ring rennt er | er rennt schon bei kleinem Ausschlag |
| 292.6 | Jerry | 643 | ohne dich (Diogenes bestätigt am Lauf) | `waffen_522`: Langbogen und Köcher gebaut, Griff am Ursprung | Test grün | Test rot |
| 292.7 | Jerry | 1305 | ohne dich (Diogenes bestätigt am Lauf) | `reihe_1305`: jedes erlaubte Nahkampfziel steht im Bild vorn (Probekampf drei Wölfe, Kämpfer) | Test grün | Test rot |
| 292.8 | Jerry | 1333 | ohne dich (Diogenes bestätigt am Lauf) | `handlungen_870`: Wuchtschlag, Zweihänder, stumpfe Waffe melden „schwer“ | Test grün | Test rot |
| 292.9 | Jerry | 1366 | ohne dich (Diogenes bestätigt am Lauf) | `kerbe_930`: Ansage nach Lesestufe, Gegenschlag offen, Wehr gegen kleine 60 % | Test grün | Test rot |

## Lagen

- 292.4: station=Krogg
