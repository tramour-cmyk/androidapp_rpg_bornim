# Tom und Jerry · Build 292 · 0.348.517 · Sammelbuild: Grafikstufen, Höhle ohne Hakeln, Joystick, Strahlprobe, Lesen · [PR #211](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/211)
E Technik · Jerry (1285; ohne dich 643, 1305, 1333, 1366), Spike (698, 1286, 1145), Tom (ohne dich 1383) · 16.11., 11:20 · [APK (Lauf 517)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43835954328/artifacts/14214731981)
Rot, bekannt, nicht melden: `typen.py` (Zeile 19) – `regeln/mars.gd` hat 4 Stellen ohne Typ über der Sperrklinke, aus 1275/1366/1333 (Jerry), am Rechner nachgestellt, Behebung im nächsten Build (1408); `kauf_cache_probe.sh` (Zeile 45) – Gegenprobe des Kauf-Caches auf dem Bauserver, am Rechner grün, berührt das Spiel nicht (1409).

Sammelbuild 1393 auf Build 291 aufgesetzt (enthält alles aus 291, 290 und `main`); die Punkte der Listen 290 und 291 kommen hier nicht noch einmal, beide bleiben offen, bis du sie fertig getestet hast.

Ein Weg: über Build 291 installieren, starten und auf die erste Blende achten (292.1), Systemmenü → „Grafik“ (292.2), im Reiter „Test“ „Strahlen“ (292.3), dann Zeile 292.4 mit „Lage herstellen“ (Höhle bei Krogg) für 292.4 und 292.5.

Im Bau geprüft: Automatisch senkt die Grafikstufe nur am Ladepunkt, nie mitten in der Szene (698, `grafik_698`), Langbogen und Köcher als Waffenmodell gebaut (643, `waffen_522`; am Garrick sichtbar erst mit 531, Tom), im Probekampf Wölfe steht jedes Ziel, das der Nahkampf treffen darf, auch im Bild vorn (1305, `reihe_1305` mit Kaufwolf, Seed 7 und 9; behoben durch 1321 in Build 291), Wuchtschlag, Zweihänder und stumpfe Waffe melden „schwer“ an das Sterben mit Physik (1333, `handlungen_870`), Lesen spürbar: Größe der Ansage erst ab Lesestufe 1, Gegenschlag gegen großen Schlag offen, Wehr gegen kleinen 60 % (1366, `kerbe_930`; das Kerbensystem ist im Spiel noch aus, nur in den Proben an), ein Tier, das von der Kachel des Helden flieht, sperrt den Platztausch nicht mehr (1383, `ziege_4162`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 292.1 | Spike | 698 | Handy | über Build 291 installieren, Hauptmenü, „Weiter“: vor dem Ort einmal die schwarze Blende „Die Feder wird angesetzt.“ mit zwei Zeilen darunter abwarten; danach App ganz schließen und noch einmal „Weiter“ | Blende kommt genau einmal, die drei Zeilen sind lesbar, nach wenigen Sekunden geht es von selbst in den Ort; beim zweiten Start keine Blende | keine Blende, sie bleibt hängen, Text abgeschnitten, oder sie kommt bei jedem Start |
| 292.2 | Spike | 698 | Handy | Systemmenü, Gruppe „Spiel“: Zeichen „Grafik“ viermal antippen, einmal gedrückt halten; unten „Gerät zeigen …“ antippen | Antippen wechselt Automatisch → Hoch → Mittel → Niedrig → Automatisch; gedrückt halten erklärt das Zeichen; bei „Niedrig“ werden Schatten und Schärfe sofort sparsamer, Schrift und Tuschelinie bleiben; dort steht die Zeile „Grafikstufe“ passend zur Wahl | Wert wechselt nicht oder falsche Reihenfolge; keine Erklärung; Bild ändert sich nicht oder Schrift/Tuschelinie leidet; Zeile „Grafikstufe“ fehlt oder stimmt nicht |
| 292.3 | Spike | 1286 | Handy | Reiter „Test“ → „Strahlen“, einen Strahl abwarten, dann „Zurück“ | das Spiel kommt zurück, keine Fehlermeldung | Fehlermeldung oder Absturz nach „Zurück“ |
| 292.4 | Spike | 1145 | Handy | Zeile 292.4 → „Lage herstellen“ (Höhle bei Krogg), Grafik auf „Automatisch“; eine Minute durch die Gänge gehen und dabei die Kamera drehen | Gehen und Drehen laufen gleichmäßig, kein kurzes Hakeln beim Schritt auf eine neue Kachel | es hakelt weiter wie in Build 291 |
| 292.5 | Jerry | 1285 | Handy | in der Höhle (Lage 292.4) den Joystick nur wenig ausschlagen, einmal mit Testmenü „Schnell“ an, einmal aus | in beiden Fällen geht der Held im Ring, erst über den Ring rennt er | er rennt schon bei kleinem Ausschlag (mit oder ohne „Schnell“) |
| 292.6 | Jerry | 643 | ohne dich (Diogenes bestätigt am Lauf) | `waffen_522`: Langbogen und Köcher gebaut, Griff am Ursprung | Test grün | Test rot |
| 292.7 | Jerry | 1305 | ohne dich (Diogenes bestätigt am Lauf) | `reihe_1305`: jedes erlaubte Nahkampfziel steht im Bild vorn (Probekampf drei Wölfe, Kämpfer) | Test grün | Test rot |
| 292.8 | Jerry | 1333 | ohne dich (Diogenes bestätigt am Lauf) | `handlungen_870`: Wuchtschlag, Zweihänder, stumpfe Waffe melden „schwer“ | Test grün | Test rot |
| 292.9 | Jerry | 1366 | ohne dich (Diogenes bestätigt am Lauf) | `kerbe_930`: Ansage nach Lesestufe, Gegenschlag offen, Wehr gegen kleine 60 % | Test grün | Test rot |
| 292.10 | Tom | 1383 | ohne dich (Diogenes bestätigt am Lauf) | `ziege_4162`: fliehendes Tier sperrt den Platztausch nicht | Test grün | Test rot |

Gegengelesen: Tom 16.11., 09:54 (alle Wege im Code von 698, 1286, 1145 und Build 291 nachgesehen: Einmess-Blende nur ohne gespeicherte Stufe, Zeichen „Grafik“ mit Gedrückthalten, Folge Automatisch–Hoch–Mittel–Niedrig, Testmenü „Strahlen“, Lage Krogg, Schalter „Schnell“; 292.2 „Niedrig“ nach Tabelle 698a berichtigt, dort sind die Schatten hart, nicht weicher)

Nachtrag (Jerry 09:58): 292.10 (1383, von Tom zu Build 292 gegeben) und die Zeilen 292.1, 292.2, 292.4 im Wortlaut von Spike nach dem Gegenlesen; 292.7 (1305) „ohne dich“ mit `reihe_1305`, neu im Lauf.

Gegengelesen: Sokrates 16.11., 11:24 (beide Teams; Wegsatz nur durch Handy-Zeilen, Nummern aufsteigend, Lage 292.4 vorhanden; alle sechs Tests aus „Im Bau geprüft“ und den Zeilen „ohne dich“ stehen in `godot.yml` von `claude/build-292`; 292.5 „Passt“ auf beide Fälle mit und ohne „Schnell“ geschärft, `held.gd` 20)

## Lagen

- 292.4: station=Krogg
