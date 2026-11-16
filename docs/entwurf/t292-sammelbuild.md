# Jerry · Build 292 · · Sammelbuild: Joystick, Strahlprobe, Lesen, Sterben, Langbogen · PR folgt
E Technik · Jerry (1285; ohne dich 643, 1333, 1366), Spike (1286) · 16.11., 09:40 · APK folgt

Sammelbuild 1393 auf Build 291 aufgesetzt (enthält alles aus 291, 290 und `main`); die Punkte der Listen 290 und 291 kommen hier nicht noch einmal, beide bleiben offen, bis du sie fertig getestet hast.

Ein Weg: über Build 291 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand, im Reiter „Test“ zuerst „Strahlen“ (292.1), dann Zeile 292.2 mit „Lage herstellen“ (Höhle bei Krogg).

Im Bau geprüft: Langbogen und Köcher als Waffenmodell gebaut (643, `waffen_522`; am Garrick sichtbar erst mit 531, Tom), Wuchtschlag, Zweihänder und stumpfe Waffe melden „schwer“ an das Sterben mit Physik (1333, `handlungen_870`), Lesen spürbar: Größe der Ansage erst ab Lesestufe 1, Gegenschlag gegen großen Schlag offen, Wehr gegen kleinen 60 % (1366, `kerbe_930`; das Kerbensystem ist im Spiel noch aus, nur in den Proben an).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 292.1 | Spike | 1286 | Handy | Reiter „Test“ → „Strahlen“, einen Strahl abwarten, dann „Zurück“ | das Spiel kommt zurück, keine Fehlermeldung | Fehlermeldung oder Absturz nach „Zurück“ |
| 292.2 | Jerry | 1285 | Handy | Zeile 292.2 → „Lage herstellen“ (Höhle bei Krogg), den Joystick nur wenig ausschlagen, einmal mit Testmenü „Schnell“ an, einmal aus | im Ring geht der Held, erst über den Ring rennt er | er rennt schon bei kleinem Ausschlag |
| 292.3 | Jerry | 643 | ohne dich (Diogenes bestätigt am Lauf) | `waffen_522`: Langbogen und Köcher gebaut, Griff am Ursprung | Test grün | Test rot |
| 292.4 | Jerry | 1333 | ohne dich (Diogenes bestätigt am Lauf) | `handlungen_870`: Wuchtschlag, Zweihänder, stumpfe Waffe melden „schwer“ | Test grün | Test rot |
| 292.5 | Jerry | 1366 | ohne dich (Diogenes bestätigt am Lauf) | `kerbe_930`: Ansage nach Lesestufe, Gegenschlag offen, Wehr gegen kleine 60 % | Test grün | Test rot |

## Lagen

- 292.2: station=Krogg
