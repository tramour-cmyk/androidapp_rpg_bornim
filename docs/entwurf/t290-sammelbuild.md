# Tom und Jerry · Build 290 · Sammelbuild: Menü wie alt, Karte, Ausrüstung, Wechsel · PR folgt
E Technik · Tom (785.8, 785.20, 785.21, 785.22, 785.23, 1295, 1304, 1309), Jerry (1296; ohne dich 1314, 481.2, 1250) · 15.11., 21:20 · APK folgt
Rot, bekannt, nicht melden: `wolf_mess_438` – Stab des Klerikers im Ausweichen am Ort 0,04 m durch Wolf 3 (1321, Jerry, in Arbeit).

Sammelbuild 1331 auf Build 289 aufgesetzt (enthält alles aus 289 und `main`); die Punkte der Liste 289 kommen hier nicht noch einmal. Toms Zweige sind einzeln übernommen, ohne die Rücknahmen aus dem alten Stand 288 (1000, 785.8 bleiben drin).

Ein Weg: über Build 289 installieren, Hauptmenü, „Weiter“ mit deinem Spielstand; erst im Dorf 290.1 bis 290.4, dann Menü 290.5 bis 290.7, dann Reiter „Test“, Zeilen 290.8 und 290.9 mit „Lage herstellen“. Die Bilder und Filme kommen vorher je als eigene Nachricht auf Telegram (👍 passt, 👎 falsch).

Im Bau geprüft: Knöpfe klicken (`klick_78520`), Zurück-Taste (`zurueck_78521`), Plakette „Satt“ (`satt_78522`), Renntaste (`renntaste_78523`), Stab im Drehteller (`stab_teller_1304`), Fächer und Namen (`faecher_1309`), Kartenhöhe (`kartenhoehe_1295`), Lage Aushang (`lage_785_8`), Eingebung nur vor dem eigenen Zug (`eingebung_1296`, 60 Kämpfe); ohne dich: Deckel 50 % für Rüstung und Schild (481.2, `brs_kampf_478`, `brs_473`), Graks Axt in der Faust beim Gehen und Schamane nicht im Boden (1314, `ausholen_1000`, `tod_ragdoll_1215`, `typen.py`), Graks Platzwechsel (1250, `grak_348` im Kampflauf).

Gegengelesen: Sokrates 15.11., 21:24 (vier Befunde „Zu 1331, von Sokrates“ bei Jerry, vor dem Push einarbeiten)

**Offen für Tom (Gegenlesen):** Wege 290.1 bis 290.7 aus den Commits abgeleitet, nicht am Gerät gegangen; Bilder 290.3, 290.6 und Film 290.5 vom Stand `claude/build-290` fehlen noch.

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 290.1 | Tom | 785.20 | Handy | Hauptmenü → „Spielstände“, einmal über die Liste wischen, dann unten „‹ Zurück“ antippen | „Zurück“ klickt leise beim Antippen, beim Wischen kein Klick | kein Klick; Klick beim Wischen |
| 290.2 | Tom | 785.21 | Handy | in der Welt die Android-Zurück-Geste; im Hauptmenü noch einmal | in der Welt öffnet sie das Menü; im Hauptmenü schließt sich das Spiel | nichts geschieht; Spiel schließt sich in der Welt |
| 290.3 | Tom | 785.22 | Bild | Menü → Tasche, etwas essen (Brot, Braten), zurück in die Welt: Leiste oben | goldene Plakette „Satt“ hinter den Zuständen | keine Plakette; falsche Farbe oder Schrift |
| 290.4 | Tom | 785.23 | Handy | im Dorf Renntaste antippen, rennen, dann stehen bleiben; noch einmal rennen, bis der Held außer Atem ist | die Renntaste geht beim Stehenbleiben und bei „außer Atem“ von selbst aus und wird matt | Held rennt nach dem Stehen weiter; Taste bleibt hell |
| 290.5 | Tom | 1304 | Film | Menü → Held → Reiter „Ausrüstung“, Held mit Kampfstab und Fackel im Drehteller | der Stab steht ruhig in der Hand und dreht mit | Stab zuckt 10–15 cm auf und ab |
| 290.6 | Tom | 1309 | Bild | Menü → Held → Reiter „Ausrüstung“, alle neun Fächer belegt, lange Namen | Fächer wie alt: Bild, darunter der Platz; „Kopf“ ganz sichtbar, Seite rollt nicht | „Kopf“ halb unter der Reiterleiste; Namen abgeschnitten |
| 290.7 | Tom | 1295 | Handy | in der Blutzahnhöhle oben in der Leiste das Kartenzeichen antippen (das Menü öffnet gleich auf „Karte“), zoomen und schieben | das Kartenblatt füllt den Platz bis „Zurück“, die ganze gesehene Höhle ist erreichbar | Blatt nur im oberen Drittel, darunter schwarz |
| 290.8 | Tom | 785.8 | Handy | Zeile 290.8 → „Lage herstellen“ (Aushang „Feuer am Steinkreis“ angenommen, Wald unerkundet), in den Wald zu Lagerfeuer und Steinkreis, dann Menü → Karte | Flamme am Lagerfeuer und goldene Raute am Steinkreis, erst nachdem du dort warst | fehlen; stehen vor dem Hinsehen da |
| 290.9 | Jerry | 1296 | Handy | Zeile 290.9 → „Lage herstellen“ (Probekampf Wölfe, jede Ansage ein Anspringen), auf die goldene Eingebung achten | der Satz „Er will springen …“ kommt nur, wenn du danach dran bist und „Wechsel“ aktiv ist | der Satz kommt, und ein Wolf springt, bevor du ziehen kannst |

## Lagen

- 290.8: station=Grak auftrag=stones unerkundet=forest
- 290.9: probe=WOLVES zug=pounce
