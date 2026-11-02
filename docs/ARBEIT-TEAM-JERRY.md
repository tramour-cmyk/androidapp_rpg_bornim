# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`).

Nie „Heldin“, immer „der Held“ (Chef 29.10.: „Jerry immer noch gendert“).

**Übergabe (02.11., 18:3x):** 415 r3 gebaut, Messung ohne Befund, Film Lauf 181 fertig (noch nicht geprüft, nicht gesendet); 438a Hautkapseln 4c (5b89022e4, Messlauf läuft); 406 G1 behoben, Messung Faust beugen läuft (Lauf 182); 478 geschätzt, gemeldet (470a → B); 453.1 passt. Nachfolger: „Jerry – 415, 438a, 406: Strahlenfilm ans Tor und zum Chef, Hautkapseln auswerten, Faust der Schildhand“

## Zeilen

Volle Titel der ruhenden Zeilen in Git: `git show dc386b2e8:docs/ARBEIT-TEAM-JERRY.md`.

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 478 | M | **von Sokrates (Chef 02.11., 17:59: „470a C“, Archiv):** Rechenkern des Kampfs schon in Stufe 1 auf BRS (Modell D: Treffer, Schaden, Abzug; Held mit Leben, Angriff, Abwehr nach BRS), Darstellung bleibt bis 2.3; erst genau schätzen: über 2 Sitzungen → Chef (dann B) | ruht: 470a B (Chefregel über 2 Sitzungen; geschätzt 3–4, Zu 478; gemeldet 18:1x); Erschaffung mit 2.3 | – |
| 473 | M | **von Perikles (Wochenziel 02.11., Stufe 1):** Bau BRS 1.4 Monsterwerte Kapitel 1 nach Rechenmodell D ins Spiel (Abnahmeliste 1.4, Schätzung 447.3: 1 Sitzung, 1 Runde) | gebaut 7d2eec7cc: Werte aller 18 Arten und Modell D im Spiel (regeln/brs.gd, daten/werte.json wie sim444), Kampf rechnet bis 2.3 nach SRD (Frage an Perikles); fährt im nächsten Build | – |
| 472 | M | **von Perikles (Wochenziel 02.11., Stufe 1):** Bau BRS 1.3 Heldenstufe aus Erfahrung, Anteil Fertigkeiten höchstens 40 %, Erfahrungstopf je Gebiet (Abnahmeliste 1.3); Schnittstelle mit Tom (471) | gebaut a6a83b13e: Regel (Brs.gib_erfahrung, Deckel, weiche Grenze, Topf); Verdrahtung mit Held nach 470 etwa 1 S, 1 R (Zu 472) | – |
| 467 | M | **von Sokrates (Chef 01.11., 21:52, Frage „Wie steigert sich die Ausdauer?“):** `godot/regeln/ausdauer.gd` rechnet noch nach SRD (Konstitution 10, Modifikator, Stärke 13); BRS: Ausdauer aus Zähigkeit, Wille, Stufe (Abschnitt 2); Formel kommt mit 427 zum Chef, dann umstellen | wartet auf 427 (Formel von Sokrates zum Chef) | – |
| 438 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Wölfe gleiten (Angriff, Tempo, aneinander vorbei); echte Schritte, Zahlen (Zu 438) | gebaut: wolf_mess_438 grün (Zu 438) | `claude/jerry-438-wolf-kampf` |
| 458.2 | M | **von Sokrates (Chef 01.11., 13:1x, Archiv 458):** Gegenstandskatalog: Werte, Preise, Beute je Monster in die Datendatei (aus 444); das Spiel liest nur sie | gebaut 67eb82d09: Katalog voll, Spiel liest ihn (katalog.gd); fährt im nächsten Build | `claude/tuffy-458-2-katalog` |
| 457.2 | M | **von Perikles (Chef 01.11., 11:49, „unsere Signatur muss sich wiederfinden“):** eigene Probeskripte zeichnen standardmäßig mit Toon-Licht, Tusche, Schatten; ohne nur mit Schalter (Zu 457.2) | gebaut e87815dc8, fährt mit den nächsten Filmen | `claude/jerry-457-2-signatur` |
| 453.1 | M | **von Sokrates (Chef 01.11., 13:0x):** Helden im Kampf atmen gleich und zu heftig („hechelt“): Atmen ruhiger, je Figur eigener Takt, nach Angriff oder Abwehr schneller, dann abklingend (Zu 453.1) | gebaut: passt (Archiv 453.1a, Lauf 173 = fd2116303), fährt im nächsten Build; 0f28eda79, d88f06ab3 ungesehen, nicht mitnehmen | `claude/tuffy-453-1-held-atem` |
| 453 | M | **von Sokrates (Chef 01.11., 11:05):** Wölfe brauchen Ruhebewegungen: atmen, scharren, umblicken, knurren (Zu 453) | gebaut: r3b passt (Chef 02.11., 11:02, Archiv 453), fährt im nächsten Build (claude/grundstand-461); Sichtbarkeit in 453a | – |
| 453a | M | Wolfsatem B (Archiv) | wartet auf 453b | – |
| 453b | M | Rückfrage: neue Läufe? | wartet auf Chef | – |
| 454 | M | **von Sokrates (Chef 01.11., 11:05):** beim Biss zielt die Achse des Wolfs wohl rechts neben den Helden; erst messen, dann bauen (Zu 453) | gebaut: passt (Archiv 454), fährt im nächsten Build; Schildreaktion in 406 | `claude/jerry-454-bissachse` |
| 438a | M | **von Sokrates (Archiv 438a):** Hinfallen/Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei | wartet auf Test: Messlauf 5b89022e4 (Hautkapseln 4c, Ursache Wertetyp behoben) | `claude/jerry-438a-sturz-2` |
| 439 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Reihenfolge Angriff, Treffer, Tod, Neuformation (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 440 | M | **von Sokrates (Chef 31.10., 23:34, Film 403):** Wolf-Tod zu schnell weg (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 416.6 | K | **von Sokrates (Chef 31.10., 20:4x):** Spuren des Helden fehlen (`core/Tracks.kt`, `LISTE-UMZUG-348.md` „Spuren“). Perikles: M oder K? | frei | – |
| 415 | M | **von Sokrates („jetzt“ 01.11., 20:0x; Archiv 415):** Probe Beams Free Sample im Kampfort (Film, Bilder je Sekunde); nichts kaufen | startbar: Film fertig (Lauf 181, Artefakt bornim-godot-bilder 13164021766), Tor 461a durch Helfer, dann an den Chef | – |
| 399.2 | M | **von Perikles („jetzt“ 28.10., 12:34, Archiv):** Kampfort aufrufbar | wartet auf Test: Build 146 (ansehen/t146-befunde.md; 143 getestet 31.10., 20:4x, Befunde als 416.x) | `claude/jerry-348-kampf` |
| 403 | M | **von Team Tom (23:1x, zu 376.1; M Perikles: Held gleitet im Kampf, Fehler):** Kampfort: Held je Klasse wie im Dorf (`HeldFigur.baue`), Bewegungen aus der UAL Pro | gebaut: passt (Archiv 403), fährt im nächsten Build | – |
| 461.1 | M | **von Sokrates („jetzt“ 01.11., 20:3x, Archiv 461):** Grundstand mit Tom: Kampfort, Wölfe, Helden im Kampf (`LISTE-GRUNDSTAND-461.md`) in `claude/grundstand-461`; vor 460 und 406.1 | wartet auf 406, 438a, 453.1, 376.1 (Zu 461.1) | `claude/grundstand-461` |
| 460 | M | **von Sokrates (Chef 01.11., 20:2x, Archiv 460):** Probefilm Kamerafahrten: Eröffnung je Blende (402), kurze Wechsel nur ohne Eingabe | wartet auf 461.1 (Grundstand vor 460) | – |
| 406.1 | M | **von Sokrates (Archiv 406.1):** Schildstoß ins MARS/BRS, Bau mit `ShieldAttack1–3S&S` | wartet auf 427 (sim444 Schildträger gleicher Stufe 92–100 % Leben, Hinweis an Sokrates) | – |
| 406 | M | **von Team Tom (Archiv 376.1):** Ausrüstung der Helden aufwerten, Kaufschilde mit goldener Sonne | wartet auf Test: Messlauf Faust schließen −50/−75/−90°, je Finger (82804c504; Lauf 182: −50° lässt Kämpfer 1,8–2,4, Kleriker 3,3–4,1 cm); E8 wartet auf Tom 417; F2 offen | `claude/jerry-406-kaufschild` |
| 387 | M | **von Sokrates (Chef 21:27):** gekaufte Tiere prüfen, vor Eigenbau | ruht: im Dorf über Toms godot.yml (kauftier.py); Feintuning nach 399: Hühner hoppeln (Chef), Rind 78 s Fleck, 150°-Sprung |
| 348.12f | M | **von Sokrates (Archiv 348.12c b):** gekaufte Riesenratte, unsere Haut | gebaut f77f2740e: Kaufratte und -wolf verschlüsselt im APK | `claude/jerry-348-kampf` |
| 348.12 | M | **von Sokrates (Archiv):** Goblin aufs CC0-Gerüst mit UAL | wartet auf 463 (Tom, B4 Umhang); F1, F5 behoben, E2-Messung drin (6f8eecf62); dann Lauf kampf=grak | `claude/tuffy-348-12k-grak` |
| 385.2 | M | **von Chef (Archiv 385.1):** Feuer aus dem Stab | ruht (Stopp 07:26): Befund f482b46c1, Zweig claude/tuffy-385-2-stabfeuer | – |
| 348.13a | M | **von Team Tom (Chef 08:09, Archiv: r9 ja):** Tusche nach Licht im Kampf, Linie 1,3 (Zu 348.13a) | gebaut 421662dbd: Tusche nach Licht Vorgabe, Linie 1,3; offen Säbel (Tom) | `claude/jerry-348-kampf` |
| 397 | M | von Chef: Tiere, Monster mind. drei Ruhebewegungen | ruht (399) | – |
| 348.12c | M | von Sokrates: Untote und Gewürm übernehmen Fähigkeiten der Vorgänger | ruht: SRD (Chef 31.10.) | – |
| 348.7 | M | von Sokrates: Umzug Godot, Kampfort Wolfsrudel in MARS | ruht: SRD (Chef 31.10.) | `claude/jerry-348-kampf` |
| 390 | M | von Perikles: Funktionen ohne Bild | ruht: SRD (Chef 31.10.) | `claude/jerry-348-kampf` |
| 304 | M | von Chef: Klassisch, Konter nach Abwehr regelrecht? | ruht: SRD (Chef 31.10.) | – |
| 257 | M | von Chef: App „hängt“, ging dann weiter | ruht: Hänger-Wächter (Tom) seit Build 49; bis zum nächsten Hänger mit Absturzbericht | – |
| 211.14 | M | von Sokrates: Leistung am A56 messen | ruht bis 348.7: Messung am A56; Kür-Teil mit 348.7 | – |
| 217 | M | von Chef: Wölfe beißen in die Luft | ruht bis 348.7 (Kampf in Godot; Urteil 348 gefallen 25.10.) | – |
| 249 | M | von Chef: MARS wie der klassische Kampf | ruht: SRD (Chef 31.10.) | – |
| 289 | K | von Chef: MARS, verfügbare Züge zeigen | ruht: Chef 21.10., 20:59 „stellen wir mal zurück“ | – |
| 296.1 | K | von Sokrates: `LISTE-MARS.md` gegen den Code | ruht bis zum nächsten zusammengeführten Build; gepflegt bis B81 | – |
| 296.2 | M | von Sokrates: MARS spielnötig | ruht: SRD (Chef 31.10.) | `claude/build-89` |
| 296.3 | K | von Sokrates: MARS-Schmuck (Todesschrei, Siegerpose …) | ruht bis 348.7 (Kampf in Godot; Urteil 348 gefallen 25.10.) | – |
| 344.2 | K | von Sokrates: Kampf mit der Fackel | ruht: SRD (Chef 31.10.) | `claude/jerry-344-2-fackel` |
| 168.1 | K | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab 3 | wartet auf 38, dann Bau Kapitel 2; Texte Homer (41) | – |
| D23.3 | M | Diogenes Lauf 23: Magier und Kleriker sterben oft | ruht bis Ende Umzug 348.7 (Archiv 38: danach in MARS messen) | `claude/diogenes-d41-messung` |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte | ruht bis 348.7 (Kampfort in Godot); Kür hinter dem Meilenstein (Chef 19.10.) | `claude/jerry-72u-standbild-2` |
| 133 | K | Umsetzung 133: Charisma-Proben, Erfahrung für Konflikte | ruht: SRD (Chef 31.10.) | – |
| 212 | M | Umsetzung 212: Schalter MARS oder klassisch | ruht: SRD (Chef 31.10.) | – |
| 86 | K | Keuchen, Initiative, Rennen | ruht: SRD (Chef 31.10.) | – |
| 38 | M | Balance Kapitel 1 gemessen | ruht: SRD (Chef 31.10.) | – |
| 39 | M | Schwierigkeitsgrad im Menü | ruht: SRD (Chef 31.10.) | `claude/jerry-39-schwierigkeit` |
| 59e | K | Händler: Vorrat je Laden | ruht: SRD (Chef 31.10.) | `claude/jerry-59e-haendlervorrat` |
| 19 | K | Zeitablauf der Kampfbewegungen | ruht: SRD (Chef 31.10.) | – |
| 469 | M | **von Sokrates (02.11., 11:0x, zu 406.1):** Kampf auf BRS: Ring (MARS) ohne Klassen regeln (Antwort nach Klasse heute) | wartet auf 406.1 | – |
| D29.1 | K | von Diogenes: Ortsklang ohne Richtung | ruht: Klang zieht nach Godot; Rest `LISTE-IDEEN.md` „Klang“ | `claude/build-89` |
| D63.6 | K | **von Diogenes (374/434, 01.11.):** fehlende Zeilen „Bestand geprüft“, Homer-Vorgabe, Tor-Prüfung bei 438, 454, 348.12, 453, 453.1 (Zu 374 in `ARBEIT-PRUEFUNG.md`) | offen | – |

## Einzelheiten

- **Zu 478 (Jerry 02.11., 18:2x):** 3–4 Sitzungen: BRS-Heldenwerte fehlen im Spiel (470, 471) 1; mars.gd Treffer, Schaden, Leben 1; Zauber, Schleichangriff, Zustände, Ring, Würfelzeile 1; Gegenprobe sim444, Tests 0,5–1. Gegenargument: nur Waffe und Biss in 2, dann Magier und Kleriker auf SRD.
- **Zu 406 (Jerry 02.11., `claude/jerry-406c-gehen`):** G1 behoben (Lauf 179: 0 angeschnitten). E3: Finger 3–8,6 cm vor dem Schild; Schild weiter vor drückt den Schwertarm hinein; Messung Faust beugen läuft. E8 wartet auf Tom 417; F2 offen.

- **von Sokrates (Chef 02.11., 14:49, zu 438a Runde 2, Wortlaut Archiv):** passt nicht: beide stechen sich beim Aufstehen mit der Waffe durchs rechte Bein (Schwert, Stab), „als ob das rechte Bein nicht existent wäre“, beim Abstützen mit der rechten Hand (Waffenhand); wie Prüferbefund 02:0x, der vor dem Versand hätte behoben sein müssen. Umhang vorn und hinten scheint durch (463, Tom).
- **von Sokrates (Chef 02.11., 14:55, zu 348.12):** „348.12b alter Körper ja“: Grak-Film darf vorab auf Graks heutigem Körper raus (Grundstand B2 hält ihn dafür nicht an); beurteilt wird die Bewegung.

- **Zu 472, 473 (Jerry 02.11., 11:4x):** `godot/regeln/brs.gd` liest `daten/werte.json` (= `tools/sim444/werte.json`); Tests `brs_472.gd`, `brs_473.gd`. Offen: Kampf rechnet bis 2.3 nach SRD (Frage an Perikles); Stufe am Helden (Heldenblatt, Anzeige Deckel, `lohn.gd`) nach 470; Annahmen Topf 10 %, weich 0,25 an Sokrates (427).

- **Zu 438, von Tuffy 00:57, Prüfer 453 r3b):** Wolf springt 7,9 s in 2 Bildern in Vorderansicht; nah 12,7 s 180° in 0,3 s.

- **von Team Tom (Spike, 01.11., 21:2x, zu 461.1):** `claude/grundstand-461` = Build 146, Tom, `jerry-406-kaufschild`, `jerry-348-12-grak-schreitet`; Konflikte (`heldfigur.gd`, `figur.gd`, `film_403.gd`) mit beiden Seiten gelöst. Nicht neu mischen, weiter auf dem Zweig; Kampfort-Film gegen die Checkliste bleibt euer.
- **Wortlaut in Git** (`git show <Commit>:docs/ARBEIT-TEAM-JERRY.md`): von Homer zu 444 und Spike zu 425 ee343195b; Zu 453, 402 („Bubum“) 7cacfa97d; Zu 453 r2 („Helden wieder doof“) 00d2ab8d5; Zu 406 a–e, 460, 438a Waffenpakete 907f307f2; Zu 453.1 da33d472c; ruhende SRD-Zeilen (296.2, 344.2, 249, 211.13/14, 168.1, 72u.1, 38, 39) de0998e2a; Zu 348.12 Lauf 177 5dc32fd63.
- **Zu 453 r3, r3b (Tuffy):** Stand und Prüferbefunde im Blatt `ansehen/453-wolf-ruhe.md`, Ursache im Commit d41f0c692; Rückfrage 453a.
- **Zu 461.1, Tuffy (02.11., 03:4x):** Prüfer Lauf 159: E5, F1 beim schweren Biss kein Hinfallen, Schild erst danach (438a); A4 Verdacht: Held nur runder Bodenfleck (Prüfer 453a Lauf 176 ebenso).
- **Zu 438a, 438:** Runde 1–3, Lauf 164 in Git (`git show 4b77bbc77:docs/ARBEIT-TEAM-JERRY.md`). Runde 4: Rüstung bis 9,5 cm über den Beinkapseln, Hautkapseln (faf633e16) in Messung. Offen: Klinge im Kleid schon in Kampfhaltung (463), Schildfinger 1,7 cm, Drehung über dem Satz, Wolf 1 im Kleriker (438).
- **Zu 348.12 (Chef 27.10., 17:19):** „ob das Modell trifft … muss man halt nachjustieren, das kann kein Kriterium sein“. Grak (Chef 29.10., 10:55): „gut, aber Gang schreitend statt kurzer Sprint“; Bau und Prüfwege `git show c30c827d0:docs/ARBEIT-TEAM-JERRY.md`.

- **Zu 399.2, von Tom (28.10., 13:23):** `goblin.py` kennt `v3/rig.py` nicht; Goblins mit `v3_kampf/`, vor der Höhle auf `v3` umstellen.
- **von Sokrates (Chef 01.11., 22:35, „461c wie Sokrates“, Archiv 461c; Grundstand B5, F4):** zu 406: Kleriker-Schild Form Schild 2 mit goldener Sonne in unseren Farben; zu Kampf: Tod für alle zusammenbrechen, kurz liegen, dann ausblenden (auch Wölfe); zu 444: Schmiedelehrling startet zusätzlich mit Stumpfe Waffen (`werte.json`), neu rechnen.
- **Zu 348.12, Urteil Film Grak schreitet, von Sokrates (Chef 01.11., 22:45, Archiv 348.12; Grundstand D5, F5):** Schreiten nur beim Ortswechsel; Ausweichen rasch, nur gegen einen sichtbaren Angriff, danach zurück; Wortlaut `git show 515dfd03e:docs/ARBEIT-TEAM-JERRY.md`. In 348.12k mitnehmen.
- **Zu 348.12, aus 348.12j (Chef 02.11., 11:22, Archiv 348.12j):** Axtkopf im Kampf oben; im Kampf (Held wie Grak) Kampfhaltung des Zweihand-Pakets, beide Fäuste am Stiel, Stiel nicht durch die Schulter (E3); E6 hängend nur unterwegs. Beim nächsten Grak-Lauf bauen.