# Tom und Jerry · Build 291 · 0.348.514 · Sammelbuild: Leben statt TP, Laden, Höhle schwarz, Kerben, Einschlag · [PR #210](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/210)
E Technik · Tom (1326, 785.24, 870.20; ohne dich 1322, 1355, 1357), Jerry (1289, 415, 1321, 1275, 601.1, 1363), Spike (1270.3; ohne dich 673) · 16.11., 07:30 · [APK (Lauf 514)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43789694188/artifacts/14192207855)

Sammelbuild 1361 auf Build 290 aufgesetzt (enthält alles aus 290 und `main`); die Punkte der Liste 290 kommen hier nicht noch einmal, 290 bleibt offen, bis du ihn fertig getestet hast.

Ein Weg: über Build 290 installieren, „Weiter“ mit deinem Spielstand, im Reiter „Test“ Zeile 291.3 mit „Lage herstellen“ (Höhle bei Krogg) für 291.3 und 291.4, dann „Strahlen“ (291.5), zuletzt Zeile 291.7. Bilder und Filme (291.1, 291.2, 291.6, 291.8, 291.9, 291.10) nur auf Telegram (👍 passt, 👎 falsch), nicht in der APK.

Im Bau geprüft: Kurzzeile der Vorräte im Laden (785.24, `laden_582`), Leben/Life statt TP/HP an Zahlen, Verband und Heilen (1322, `pim_verband_842`, `typen.py`), Wende ohne Nachlauf, nicht mehr zufällig rot (1355, `wende_4168`), Treffer ohne Schaden meldet sich (1321, `meldung_1305`), Einschlag am Rumpf (601.1, `einschlag_6011`), Kerbensystem (1275, `kerbe_930`), Lage Aushang nach Uhr statt 900 Bildern (1357, `lage_785_8`); ohne dich: Maus am Rechner dreht und zoomt die Kamera, Handy unverändert (673, `maus_673`; nur am Rechner), Leben/Life in allen Spielertexten (1322).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 291.1 | Tom | 1326 | Bild | Hauptmenü unten, unter dem Firmenzeichen die Zeile mit Fassung und Build (Stand `claude/build-291` am Rechner, Fassung und Build wie im Lauf 514 eingesetzt; am Ende von „Über das Spiel“ steht dieselbe Zeile) | „v0.348.514 · Build 291“ | nur „v0.1“ oder keine Build-Nummer |
| 291.2 | Tom | 785.24 | Bild | Morwens Laden, „Kaufen“: die Tränke mit Zeile darunter (Stand `claude/build-291` am Rechner) | unter jedem Trank klein und matt, was er tut, etwa „heilt 14 Leben“, wie im alten Spiel | keine Zeile unter dem Namen; Würfel wie „2W4+2“; „TP“ |
| 291.3 | Spike | 1270.3 | Handy | Reiter „Test“, oben die Zeile „Grafik“ lesen; dann Zeile 291.3 → „Lage herstellen“ (Höhle bei Krogg), auf das Laden achten | „Grafik: mobile“; die Höhle ist nicht langsamer da als in Build 290 | „gl_compatibility“; Laden deutlich länger als in 290 |
| 291.4 | Jerry | 1289 | Handy | in der Höhle (Lage 291.3) bis zu Krogg und zurück gehen, auf Wände und Gänge hinter Wänden achten | was du gerade nicht siehst (hinter Wänden, außerhalb von Fackel und Licht), ist schwarz; Wände auf deiner Seite stehen hell in voller Höhe; Bilder/s oben im Reiter „Test“ nicht unter Build 290 | Wände als kniehohe Stummel; Gänge hinter Wänden hell; Bilder/s unter Build 290 |
| 291.5 | Jerry | 415 | Handy | Reiter „Test“ → „Strahlen“, drei Strahlen ansehen, oben die Zeile „Bilder/s · Renderer“; „Renderer wechseln“ nicht antippen | Renderer mobile, Bilder/s wie im Kampf, kein Ruckeln | Ruckeln oder Bilder/s deutlich unter dem Kampf |
| 291.6 | Jerry | 1321 | Film | Probekampf Wölfe, Held mit Kampfstab weicht einem Biss aus, Stand `claude/build-291` [Film von 16.11., 07:25](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261116-072537-t291.6/2026-11/16-0725-t291.6-Jerry.mp4) | der Held weicht nach hinten oder schräg aus, der Stab bleibt vor dem Wolf | der Stab fährt in einen Wolf; der Held weicht am Ort aus |
| 291.7 | Jerry | 1275 | Handy | Zeile 291.7 → „Lage herstellen“ (Probekampf Wölfe), Knopf „Tausch“, dann angreifen | nach dem Tausch bist du weiter dran | der Zug endet mit dem Tausch |
| 291.8 | Jerry | 601.1 | Film | Probekampf Goblin-Späher, der Späher schießt auf den Helden, Stand `claude/build-291` [Film von 16.11., 06:58](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261116-065827-t291.8/2026-11/16-0658-t291.8-Jerry.mp4) | der Pfeil steckt in der Brust, dort zuckt der Held | Pfeil an Bein oder Fuß; Zucken oben, Pfeil unten |
| 291.9 | Tom | 870.20 | Bild | „Über das Spiel“ (Stand `claude/build-291` am Rechner); das Handbuch prüft `menue_test` auf SRD, Würfel, TP/HP und Rüstungsklasse, am Rechner auf diesem Stand ohne Fund (der Test steht nicht im Lauf der APK) | Text ohne SRD-Hinweis, die Regeln heißen „Bornimer Rollenspielsystem“ | SRD-Hinweis steht noch |
| 291.10 | Jerry | 1363 | Film | Probekampf Wölfe, der Söldner mit Schild wird gebissen, Stand `claude/build-291` [Film von 16.11., 07:01](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261116-070133-t291.10/2026-11/16-0701-t291.10-Jerry.mp4) | er zuckt, der Schild bleibt vor ihm | der Schild fährt in den Wolf oder der Arm wirkt steif |

## Lagen

- 291.2: station=Morwen
- 291.3: station=Krogg
- 291.7: probe=WOLVES

Nachtrag 291.10 (Jerry, 1363, Text von Jerry 03:03): Gegengelesen: Tom 16.11., 03:04 (Bewegung, darum Film; erreichbar im Probekampf Wölfe mit Söldner).

Gegengelesen: Sokrates 16.11., 01:22 (drei Befunde, eingearbeitet Tom 01:23, dann frei): (1) 291.6 (1321, Stab beim Ausweichen) und 291.8 (601.1, Pfeil in der Brust, Zucken) sind Bewegung: nach Regel 9 als Film vom Stand `claude/build-291`, nicht als Handy, je Film nur der Gegenstand, „Wo und wie“ = was im Film zu sehen ist; ihre Lagen fallen weg. (2) 291.4 (1289): zusätzlich „Bilder/s oben im Reiter Test nicht unter Build 290“ in „Passt“, weil Schwarz hinter Wänden die Grafikzeit ändert und die Höhle schon hakelt (1145). (3) 291.9 (870.20): nicht „spielen bis in die Höhle“; Texte sichert der Bau (1322 ohne dich), am Handy nur Hauptmenü, „Über das Spiel“ und Handbuch.
