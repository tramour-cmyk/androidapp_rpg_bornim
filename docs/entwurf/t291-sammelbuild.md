# Tom und Jerry · Build 291 · Version folgt · Sammelbuild: Leben statt TP, Laden, Höhle schwarz, Kerben, Einschlag · PR folgt
E Technik · Tom (1326, 785.24, 870.20; ohne dich 1322, 1355, 1357), Jerry (1289, 415, 1321, 1275, 601.1), Spike (1270.3; ohne dich 673) · 16.11., 01:20 · APK folgt

Sammelbuild 1361 auf Build 290 aufgesetzt (enthält alles aus 290 und `main`); die Punkte der Liste 290 kommen hier nicht noch einmal, 290 bleibt offen, bis du ihn fertig getestet hast.

Ein Weg: über Build 290 installieren, Hauptmenü (291.1), dann „Weiter“ mit deinem Spielstand und im Reiter „Test“ die Zeilen 291.2 bis 291.7 mit „Lage herstellen“; zuletzt Hauptmenü und Handbuch (291.9). Die Filme 291.6 und 291.8 kommen vorher je als eigene Nachricht auf Telegram (👍 passt, 👎 falsch).

Im Bau geprüft: Kurzzeile der Vorräte im Laden (785.24, `laden_582`), Leben/Life statt TP/HP an Zahlen, Verband und Heilen (1322, `pim_verband_842`, `typen.py`), Wende ohne Nachlauf, nicht mehr zufällig rot (1355, `wende_4168`), Treffer ohne Schaden meldet sich (1321, `meldung_1305`), Einschlag am Rumpf (601.1, `einschlag_6011`), Kerbensystem (1275, `kerbe_930`), Lage Aushang nach Uhr statt 900 Bildern (1357, `lage_785_8`); ohne dich: Maus am Rechner dreht und zoomt die Kamera, Handy unverändert (673, `maus_673`; nur am Rechner), Leben/Life in allen Spielertexten (1322).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 291.1 | Tom | 1326 | Handy | Hauptmenü: unter dem Firmenzeichen lesen, dann „Über das Spiel“ öffnen | an beiden Stellen Fassung und Build, etwa „v0.348.5xx · Build 291“ | nur „v0.1“ oder keine Build-Nummer |
| 291.2 | Tom | 785.24 | Handy | Zeile 291.2 → „Lage herstellen“ (bei Morwen), mit Morwen reden, ihren Laden öffnen, „Kaufen“ | unter jedem Trank klein und matt, was er tut, etwa „heilt 12 Leben“, wie im alten Spiel | keine Zeile unter dem Namen; Würfel wie „2W4+2“; „TP“ |
| 291.3 | Spike | 1270.3 | Handy | Reiter „Test“, oben die Zeile „Grafik“ lesen; dann Zeile 291.3 → „Lage herstellen“ (Höhle bei Krogg), auf das Laden achten | „Grafik: mobile“; die Höhle ist nicht langsamer da als in Build 290 | „gl_compatibility“; Laden deutlich länger als in 290 |
| 291.4 | Jerry | 1289 | Handy | in der Höhle (Lage 291.3) bis zu Krogg und zurück gehen, auf Wände und Gänge hinter Wänden achten | was du gerade nicht siehst (hinter Wänden, außerhalb von Fackel und Licht), ist schwarz; Wände auf deiner Seite stehen hell in voller Höhe; Bilder/s oben im Reiter „Test“ nicht unter Build 290 | Wände als kniehohe Stummel; Gänge hinter Wänden hell; Bilder/s unter Build 290 |
| 291.5 | Jerry | 415 | Handy | Reiter „Test“ → „Strahlen“, drei Strahlen ansehen, oben die Zeile „Bilder/s · Renderer“; „Renderer wechseln“ nicht antippen | Renderer mobile, Bilder/s wie im Kampf, kein Ruckeln | Ruckeln oder Bilder/s deutlich unter dem Kampf |
| 291.6 | Jerry | 1321 | Film | Probekampf Wölfe, Held mit Kampfstab weicht einem Biss aus, Stand `claude/build-291` (Film folgt, Jerry) | der Held weicht nach hinten oder schräg aus, der Stab bleibt vor dem Wolf | der Stab fährt in einen Wolf; der Held weicht am Ort aus |
| 291.7 | Jerry | 1275 | Handy | Zeile 291.7 → „Lage herstellen“ (Probekampf Wölfe), Knopf „Tausch“, dann angreifen | nach dem Tausch bist du weiter dran | der Zug endet mit dem Tausch |
| 291.8 | Jerry | 601.1 | Film | Probekampf Goblin-Späher, der Späher schießt auf den Helden, Stand `claude/build-291` (Film folgt, Jerry) | der Pfeil steckt in der Brust, dort zuckt der Held | Pfeil an Bein oder Fuß; Zucken oben, Pfeil unten |
| 291.9 | Tom | 870.20 | Handy | Hauptmenü und „Über das Spiel“ ansehen, dann Menü → System → Handbuch durchblättern | kein „SRD 5.1 · CC BY 4.0“ mehr; im Handbuch keine Würfel, TP/HP oder Rüstungsklasse, der Wert heißt Leben | SRD-Hinweis steht noch; Würfel, TP oder RK im Handbuch |

## Lagen

- 291.2: station=Morwen
- 291.3: station=Krogg
- 291.7: probe=WOLVES

Gegengelesen: Sokrates 16.11., 01:22 (drei Befunde, eingearbeitet Tom 01:23, dann frei): (1) 291.6 (1321, Stab beim Ausweichen) und 291.8 (601.1, Pfeil in der Brust, Zucken) sind Bewegung: nach Regel 9 als Film vom Stand `claude/build-291`, nicht als Handy, je Film nur der Gegenstand, „Wo und wie“ = was im Film zu sehen ist; ihre Lagen fallen weg. (2) 291.4 (1289): zusätzlich „Bilder/s oben im Reiter Test nicht unter Build 290“ in „Passt“, weil Schwarz hinter Wänden die Grafikzeit ändert und die Höhle schon hakelt (1145). (3) 291.9 (870.20): nicht „spielen bis in die Höhle“; Texte sichert der Bau (1322 ohne dich), am Handy nur Hauptmenü, „Über das Spiel“ und Handbuch.
