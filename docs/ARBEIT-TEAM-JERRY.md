# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`).

Nie „Heldin“, immer „der Held“ (Chef 29.10.: „Jerry immer noch gendert“).

**Übergabe (01.11., 12:1x):** 406 Kaufschilde gebaut (1bd54b7c7 auf `claude/jerry-406-kaufschild`, von 438), Film an den Chef (ansehen/406-kaufschilde), Probelauf 406 2/2; 454 gemessen (dd7f09215 auf `claude/jerry-454-bissachse`, Zu 454). Lokal nachbauen: Skript-Schritte wie godot.yml (held3, rig, held_klassen, held_kampf, wolf, kampfort_wald, waffen, kaufwolf, kaufschild); Haartexturen der UBC Source liegen eine Ebene über „Rigged to Head Bone/Male“ (verlinken). Nachfolger: „Jerry – 454: Biss trifft das Ziel“

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 438 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Wölfe gleiten (Angriff, Tempo, aneinander vorbei); echte Schritte, Zahlen (Zu 438) | gebaut: passt (Archiv 438, 01.11., 11:45), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 453 | M | **von Sokrates (Chef 01.11., 11:05):** Wölfe brauchen Ruhebewegungen: atmen, scharren, umblicken, knurren (Zu 453) | in Arbeit bei Tuffy | – |
| 454 | M | **von Sokrates (Chef 01.11., 11:05):** beim Biss zielt die Achse des Wolfs wohl rechts neben den Helden; erst messen, dann bauen (Zu 453) | startbar: gemessen dd7f09215 (Zu 454), bauen: Wolf beim Biss so drehen, dass die Schnauze das Ziel trifft | `claude/jerry-454-bissachse` |
| 438a | M | **von Sokrates (Chef 01.11., 11:47, „nicht beurteilen, wenn ich es nicht gesehen habe … Vielleicht kann er auch so taumeln“):** Sichtungsfilm Hinfallen/Aufstehen auf Kaufheld: UAL Crawl, GroundSit, Death01/02 vorwärts und rückwärts; Wizard-Set (385, Übertragung geht): GetHit Heavy, Death Back, GetBackUp; dazu Knie der alten Fassung, eigene 3 | startbar: Archiv 438a | – |
| 439 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Reihenfolge Angriff, Treffer, Tod, Neuformation (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 440 | M | **von Sokrates (Chef 31.10., 23:34, Film 403):** Wolf-Tod zu schnell weg (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 416.5 | M | **von Sokrates (Chef 31.10., 20:4x, Build 143):** im Kampf Details des Kampflogs aufrufen, dann nicht mehr schließbar (Taste reagiert nicht); beheben | wartet auf Test: Build 146 (t146) | – |
| 416.6 | K | **von Sokrates (Chef 31.10., 20:4x):** Spuren des Helden fehlen (Fußspuren; bei Regen eigene Spuren); `core/Tracks.kt` laut `LISTE-UMZUG-348.md` Zeile „Spuren“ bei Jerry. Perikles: M oder K? | frei | – |
| 415 | K | **von Sokrates (Chef 31.10., 20:3x „Ja, Probe mit dem Beams-Sample an Jerry geben“):** Handyprobe Godot-Beams (gratis, itch.io reeboolabs): läuft es, FPS, Renderer Mobile und Compatibility; nur Zahlen, kein Urteil über Aussehen (373), nichts kaufen, Lizenz je Datei | frei, nach den Mussen | – |
| 399.2 | M | **von Perikles („jetzt“ 28.10., 12:34, Archiv):** Kampfort aufrufbar | wartet auf Test: Build 146 (t146; 143 getestet 31.10., 20:4x, Befunde als 416.x) | `claude/jerry-348-kampf` |
| 399.2b | M | **von Team Tom (15:05):** Rudel allein zu stark | wartet auf Test: Build 146 (t146) | – |
| 402 | M | **von Sokrates (Chef 22:2x, Archiv):** Blende vor dem Kampf wie alt; Herzschlag beim Hinterhalt stärker | wartet auf Test: Build 146 (t146) | – |
| 403 | M | **von Team Tom (23:1x, zu 376.1; M Perikles: Held gleitet im Kampf, Fehler):** Kampfort: Held je Klasse wie im Dorf (`HeldFigur.baue`) statt `kampf/daten/held.bin`; Hieb, Stich, Treffer, Tod, Ausweichen aus der UAL Pro | gebaut: Chef 01.11., 11:13 „403 passt, super Richtung“ (Archiv), fährt im nächsten Build mit | – |
| 406 | M | **von Team Tom (Chef 28.10., 23:0x, Archiv 376.1 Klassenentwürfe):** Ausrüstung der Helden je Stück aufwerten („steril“), zuerst Rundschild des Klerikers hell mit goldener Sonne (`Dress.kt`); Wappenrock-Sonne macht Tom | wartet auf Chef: Prüferbefund in ansehen/406-kaufschilde (nur Innenseite im Film); neuer Film nach seinem Wort | `claude/jerry-406-kaufschild` |
| 401 | M | **von Chef über Sokrates (Archiv):** Tierlaute, mind. 3 je Tier | wartet auf Test: Build 146 (t146) | – |
| 387 | M | **von Sokrates (Chef 21:27):** gekaufte Tiere prüfen, vor Eigenbau | ruht: im Dorf über Toms godot.yml (kauftier.py); Feintuning nach 399: Hühner hoppeln (Chef), Rind 78 s Fleck, 150°-Sprung |
| 348.12f | M | **von Sokrates (Archiv 348.12c b):** gekaufte Riesenratte, unsere Haut | gebaut f77f2740e: Kaufratte und -wolf verschlüsselt im APK | `claude/jerry-348-kampf` |
| 348.12 | M | **von Sokrates (Archiv):** Goblin aufs CC0-Gerüst mit UAL | startbar: Grak gut, Gang schreiten (Chef 10:55, Zu 402) | `claude/jerry-348-kampf` |
| 385.2 | M | **von Chef (Archiv 385.1):** Feuer aus dem Stab | wartet auf 403 (Magier mit Stab im Kampfort) | – |
| 348.13a | M | **von Team Tom (Chef 08:09, Archiv: r9 ja):** Tusche nach Licht im Kampf, Linie 1,3 (Zu 348.13a) | gebaut 421662dbd: Tusche nach Licht Vorgabe, Linie 1,3; offen Säbel (Tom) | `claude/jerry-348-kampf` |
| 397 | M | **von Chef (28.10., 11:15):** Tiere, Monster: mind. drei Ruhebewegungen wie alt (`LISTE-UMZUG-348.md`) | ruht (399) | – |
| 348.12c | M | **von Sokrates (Chef 20:32 „Zuordnung ja“, Archiv):** Wiedergänger, Grabhund, Riesenegel, Säureschnecke übernehmen Fähigkeiten der Vorgänger; Werte je Modell vorschlagen (Balance an Chef) | ruht: altes SRD-System (Chef 31.10.) | – |
| 348.7 | M | **von Sokrates (Chef 25.10., 01:19):** Umzug Godot: Modellregel, Kampfort Wolfsrudel in MARS (`LISTE-UMZUG-348.md`) | ruht: altes SRD-System (Chef 31.10.) | `claude/jerry-348-kampf` |
| 390 | M | **von Perikles:** Funktionen ohne Bild (`LISTE-UMZUG-348.md`) | ruht: altes SRD-System (Chef 31.10.) | `claude/jerry-348-kampf` |
| 304 | M | **von Chef (22.10., 13:22):** Klassisch: Abwehr, getroffen, trotzdem Konter, regeltechnisch richtig? (Zu 304) | ruht: altes SRD-System (Chef 31.10.) | – |
| 257 | M | **von Chef (20.10., 17:17, Test B46):** App „hängt“, ging dann weiter (Zu 257) | ruht: Hänger-Wächter (Tom) seit Build 49; bis zum nächsten Hänger mit Absturzbericht | – |
| 211.14 | M | **von Sokrates (20.10.):** Rest 211.13: Leistung am A56 messen (M), Rest Kür | ruht bis 348.7: Messung am A56; Kür-Teil mit 348.7 | – |
| 217 | M | **von Chef (19.10., 13:50):** Wölfe beißen teilweise in die Luft (Vorgangsarchiv 217) | ruht bis 348.7 (Kampf in Godot; Urteil 348 gefallen 25.10.) | – |
| 249 | M | **von Chef (20.10., 14:41):** MARS sieht und fühlt sich an wie der klassische Kampf (Zu 249) | ruht: altes SRD-System (Chef 31.10.) | – |
| 289 | K | **von Chef (21.10., 20:11):** MARS: verfügbare Züge im Kästchen zeigen (Zu 289) | ruht: Chef 21.10., 20:59 „stellen wir mal zurück“ | – |
| 296.1 | K | **von Sokrates (22.10.):** `LISTE-MARS.md` gegen den Code prüfen, je Build pflegen | ruht bis zum nächsten zusammengeführten Build; gepflegt bis B81 | – |
| 296.2 | M | **von Sokrates (Chef 23.10., 18:25, Vorgangsarchiv 341.1a):** MARS spielnötig (Vorgangsarchiv 341.1a, Zu 296.2) | ruht: altes SRD-System (Chef 31.10.) | `claude/build-89` |
| 296.3 | K | **von Sokrates (Chef 23.10., 18:25):** MARS-Schmuck: Todesschrei, Flucht vor heiligem Licht/Zerfallen, Zustände am Gegner gezeichnet, Siegerpose | ruht bis 348.7 (Kampf in Godot; Urteil 348 gefallen 25.10.) | – |
| 344.2 | K | **von Sokrates (Chef 23.10., Archiv 344):** Kampf mit der Fackel in beiden Systemen (Zu 344.2) | ruht: altes SRD-System (Chef 31.10.) | `claude/jerry-344-2-fackel` |
| 168.1 | K | Umsetzung 168: Kapitel 2 Garrick fest an der Seite, Söldner ab Kapitel 3 (Zu 168.1) | wartet auf 38, dann Bau Kapitel 2; Texte Homer (41) | – |
| D23.3 | M | Diogenes Lauf 23: Magier und Kleriker sterben oft; Kleriker Stufe 1 vor dem Meilenstein (Archiv 38) | ruht bis Ende Umzug 348.7 (Archiv 38: danach in MARS messen) | `claude/diogenes-d41-messung` |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte (Grak im Wald) (Zu 72u.1) | ruht bis 348.7 (Kampfort in Godot); Kür hinter dem Meilenstein (Chef 19.10.) | `claude/jerry-72u-standbild-2` |
| 133 | K | Umsetzung 133: Charisma-Proben und Erfahrung für gelöste Konflikte | ruht: altes SRD-System (Chef 31.10.) | – |
| 212 | M | Umsetzung 212: Schalter „Kampf: MARS oder klassisch“, jederzeit wechselbar; neue Regeln nur in MARS; 338 (e) | ruht: altes SRD-System (Chef 31.10.) | – |
| 86 | K | Bewegung und Übersicht: Keuchen, Initiative, Rennen (Zu 86) | ruht: altes SRD-System (Chef 31.10.) | – |
| 38 | M | Balance: Kapitel 1 gemessen (Zu 38) | ruht: altes SRD-System (Chef 31.10.) | – |
| 39 | M | Schwierigkeitsgrad im Menü (Zu 39) | ruht: altes SRD-System (Chef 31.10.) | `claude/jerry-39-schwierigkeit` |
| 59e | K | Händler: Vorrat je Laden (59e.2 Mengen) | ruht: altes SRD-System (Chef 31.10.) | `claude/jerry-59e-haendlervorrat` |
| 19 | K | Zeitablauf der Kampfbewegungen (Vorgangsarchiv 19e) | ruht: altes SRD-System (Chef 31.10.) | – |
| D29.1 | K | **von Diogenes (Lauf 30):** Ortsklang ohne Richtung; Dorf stumm | ruht: Klang zieht nach Godot; Rest `LISTE-IDEEN.md` „Klang“ | `claude/build-89` |

## Einzelheiten

- **Hinweis von Team Tom (Spike, 01.11., 11:52, zu 425):** MARS: Waffentreffer ab `hero.crit` kritisch (Champion 19), Würfelkasten, Wucht, Klang zeigen „kritisch“ nur bei der 20; bei der 19 „Treffer“ trotz doppeltem Schaden. 425 setzt „krit“ in der Meldung, nur erzwungen im Testmodus (`claude/spike-425-testmenue`, kleine Haken in `mars.gd`, `kampfort.gd`, `aufruf.gd`, `kampf_ui.gd`, `klang.gd`).

- **Zu 453, 454, 438, 439, 438b, von Sokrates (Chef 01.11., 11:05, zum Film „2 Helden gegen 3 Wölfe“):** „438b Empfehlung 1“ (eine Zeile, Archiv). „dass sich die Wölfe Plätze tauschen, so während noch irgendwas läuft, finde ich super. Das sieht richtig gut aus. Und dann wenn der Wolf stirbt, dann werden die Plätze erst dann angenommen, ist auch top. Aus meiner Sicht müssen die Wölfe auch nicht immer hintereinander stehen. Können sie, müssen sie [nicht], aber ich könnte auch theoretisch nebeneinander stehen.“ (Prüferbefund Platztausch also kein Fehler.) 453: „Was mir aber völlig fehlt, sind diese Ruheanimationen. Also ich weiß nicht, ob die Wölfe atmen, ob die mal ab und zu scharren oder sich umblicken oder knurren. Sozusagen, da muss mehr Leben rein.“ (Bestand zuerst: Kaufwolf hat Ruhe, Heulen, Fressen; 408.) 454: „wenn die Wölfe zubeißen, dass eigentlich die Ausrichtung des Wolfes, wenn ich seine Achse betrachte, dass die gar nicht auf dem Helden geht, dass die immer irgendwie perspektivisch rechts daneben ein bisschen beißen. Weiß nicht, ob ich mich da irre oder nicht.“ (erst messen: Winkel Wolfsachse gegen Richtung zum Ziel je Biss, `wolf_mess_438.gd`). 11:45 noch einmal 453: „die Wölfe … machen die nur was, wenn sie dran sind … atmen, oder eine Ruheanimation … Scharren, knurren … Kopf mal drehen … Sonst wirkt es sehr steril.“
- **Zu 438a, von Sokrates (Chef 01.11., 11:49):** „nicht immer die gleiche Animation … unsere viel zitierten 3 Varianten … oder zumindest 2 … bevor wir wieder Geld ausgeben und selbst entwickeln“; „unsere Signatur muss sich wiederfinden“: im Sichtungsfilm je Hinfallen und Aufstehen mindestens zwei, besser drei Varianten aus dem Bestand vorschlagen; Film mit Toon-Licht, Tusche nach Licht, Schatten wie im Kampfort (457).
- **Zu 438, 439, 440** (passt 11:45; Wortlaut Chef 31.10. und Rest in Git, `git show 7171c04f5:docs/ARBEIT-TEAM-JERRY.md`): Messung `tests/wolf_mess_438.gd` (`MESS_LOG`, `SCHAU_MESS`, `KLASSEN`); Film `SEED=7 DAUER_MS=48000 KLASSEN=CLERIC film_403.gd`; Rest Wolf in Wolf 0,12 m (Schurke), Stab beim Ausweichen 0,16 m. Kaufpakete lokal per `gh api … releases/assets/<id>`, entpacken wie `kauf_laden.sh`.

- **Hinweis von Diogenes (374/434, 01.11.):** Prüfer erst nach dem Versand (396), Zeile „Bestand geprüft“ (377). Bestätigt (Jerry 01.11.: 406 so).
- **Zu 454 (Jerry 01.11., 12:1x, `tests/biss_achse_454.gd`, ohne Bild):** Chef hat recht: Schnauze am weitesten Punkt des Bisses im Bild bei 16 von 16 Bissen rechts der Zielmitte (Mittel 182 px bei 1080 Breite). Ursache: der Biss des Kaufwolfs schwenkt den Kopf dort 0,16 m nach links (aus Wolfssicht; in Hocke und Gehen 0), die Achse selbst zielt nur 1–8° daneben. Dazu: Schnauze dann 0,6–1,6 m von der Zielmitte (Fehlschläge nicht getrennt, prüfen). Bauen: im Biss zum Ziel nachdrehen (etwa atan(0,16 / Reichweite)), danach mit demselben Test 0 px Mittel.
- **Zu 406 (Chef 31.10., 23:22: „Schild 2 für ehemaligen Kleriker (neues System!!!) und 15 für Krieger (neues System)“; Jerry 01.11.):** Kaufschilde unverändert bis auf Lage und Größe (`kaufschild.py`), Krieger 15 als `round_shield`, Kleriker 2 als `shield`, Startausrüstung in `Rules.kt` getauscht; Messung `tests/schild_406.gd`. Tom (11:09, Nachricht): 406 bleibt bei Jerry; sein Stand `claude/tom-348-406-schild` e7cf1df0f hat `probe.gd` `DREH_HELD=1` (dreht Held und Söldner), nützlich für den neuen Film von vorn.

- **Zu 348.12 (Chef 27.10., 17:19):** „ob das Modell trifft … muss man halt nachjustieren, das kann kein Kriterium sein“.
- **Zu 348.12 Grak (29.10., f5f269856):** Bau `OUT=~/grakg CC0=~/cc0 WAFFEN=~/basis UAL=<Pro>/UAL1.glb TOD_QUELLE=Death02 ~/bl/bin/python -I tools/blender348/grak_gestalt.py`. Prüfen ohne Bild `tests/grak_348.gd`, Axt `grak_axtmess.py <blend>`; Film nur mit `res://kampf/probe.tscn`. Dodge mit Großaxt geht nicht, darum Seitenlauf. Prüferbefund nachprüfen: Axt 5,95 s ein Bild weg, Axt fliegt im Tod 150 px, Umhang steif, Platzwechsel am Rand.
- **Zu 402, von Sokrates (Chef 31.10., 21:07, Archiv):** „Fassung 2b“ der Hörprobe, aber der Herzschlag besteht aus zwei kurzen Schlägen (Systole, Diastole), dann Pause, wieder zwei, wieder zwei: „Bubum. Bubum. Bubum. Bubum.“; die Hörprobe mit fünf einzelnen Schlägen „haut nicht hin“. Anzahl Paare nach der Blende (1,2 s) wählt Jerry; dann Hörprobe nicht nötig, außer Chef verlangt sie.
- **Zu 348.12 Grak (Chef 29.10., 10:55):** gut, aber Gang schreitend statt kurzer Sprint.
- **Zu 348.13a (Tom 08:27):** offen r9: Säbel liest sich als Bogen; Schwert, Schild, Scheide bei Tom (372).

- **Zu 296.2, 344.2, 249, 211.13/211.14, 168.1, 72u.1, 38, 39** (alle ruhend, altes SRD-System): Einzelheiten in Git, `git show 2124a6aaf:docs/ARBEIT-TEAM-JERRY.md` (Abschnitt „Einzelheiten“). **Zu 348.7 (stehen, Treffer, Goblin, Runde 16, Lohn), 348.12f (Kaufwolf, Ort), 390** (Technik, ruhend): `git show 5b0ac7a23:docs/ARBEIT-TEAM-JERRY.md`; **Zu 348.7 (Hintergrund, Abnahmeliste, Zustandszeichen „erst nach Ja“, „nie heller als alt“)**: `git show 92df2b0f3:docs/ARBEIT-TEAM-JERRY.md`.
- **Zu 399.2, von Tom (28.10., 13:23):** `goblin.py` patcht `v3/rig.py` als Text, erkennt Toms Fassung nicht; `godot.yml` baut Goblins mit `v3_kampf/` (Stand 12:12); vor der Höhle auf Toms `v3` umstellen (dort fehlen Anker `a3`, `a2`/`b2`).
