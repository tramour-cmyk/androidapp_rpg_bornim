# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`).

Nie „Heldin“, immer „der Held“ (Chef 29.10.: „Jerry immer noch gendert“).

**Übergabe (02.11., 21:4x):** 487 auf `claude/build-487` zusammengestellt (Zu 487). Nachfolger: „Jerry – 487, 438a, 406: Build starten, Messläufe auswerten“

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 487 | M | **von Perikles (Wochenziel 02.11. Reihe 6):** gemeinsamer Build, höchstens 6 Punkte, Figuren über 461.1 | wartet auf Lauf 193 (claude/build-487, 6e7751d28), PR #178, Prüfliste t193-build-487; dann Testbitte | – |
| 478 | M | **von Sokrates (Chef 02.11., 17:59: „470a C“, Archiv):** Rechenkern des Kampfs schon in Stufe 1 auf BRS (Modell D), Darstellung bleibt bis 2.3 | ruht: 470a B (geschätzt 3–4 Sitzungen, Zu 478) | – |
| 481.1 | M | **von Sokrates (Archiv 427):** Tränke in sim444 (Zu 481 in `ARBEIT-BERATUNG.md`), Herkünfte neu messen, Zahlen an Sokrates | gebaut: sim444 Abschnitt 6 auf claude/jerry-481-1-traenke, Befund LISTE-SIMULATION-444, Zahlen an Sokrates (Zu 481); Geprüft an: 4bb60ba5e (--pruefen 0, Abschnitte 1–5 gleich main) | – |
| 473 | M | **von Perikles (Wochenziel 02.11., Stufe 1):** Bau BRS 1.4 Monsterwerte Kapitel 1 nach Rechenmodell D ins Spiel (Abnahmeliste 1.4, Schätzung 447.3: 1 Sitzung, 1 Runde) | gebaut 7d2eec7cc: Werte aller 18 Arten und Modell D im Spiel (regeln/brs.gd, daten/werte.json wie sim444), Kampf rechnet bis 2.3 nach SRD (Frage an Perikles); fährt im nächsten Build | – |
| 472 | M | **von Perikles (Wochenziel 02.11., Stufe 1):** Bau BRS 1.3 Heldenstufe aus Erfahrung, Anteil Fertigkeiten höchstens 40 %, Erfahrungstopf je Gebiet (Abnahmeliste 1.3); Schnittstelle mit Tom (471) | gebaut a6a83b13e: Regel (Brs.gib_erfahrung, Deckel, weiche Grenze, Topf); Verdrahtung mit Held nach 470 etwa 1 S, 1 R (Zu 472) | – |
| 467 | M | **von Sokrates (Chef 01.11., 21:52, Frage „Wie steigert sich die Ausdauer?“):** `godot/regeln/ausdauer.gd` rechnet noch nach SRD (Konstitution 10, Modifikator, Stärke 13); BRS: Ausdauer aus Zähigkeit, Wille, Stufe (Abschnitt 2); Formel kommt mit 427 zum Chef, dann umstellen | wartet auf Sokrates: Formel Ausdauer fehlt in 427 (Hinweis Beratung) | – |
| 438 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Wölfe gleiten (Angriff, Tempo, aneinander vorbei); echte Schritte, Zahlen (Zu 438) | gebaut: wolf_mess_438 grün (Zu 438) | `claude/jerry-438-wolf-kampf` |
| 458.2 | M | **von Sokrates (Chef 01.11., 13:1x, Archiv 458):** Gegenstandskatalog: Werte, Preise, Beute je Monster in die Datendatei (aus 444); das Spiel liest nur sie | gebaut 67eb82d09: Katalog voll, Spiel liest ihn (katalog.gd); fährt im nächsten Build | `claude/tuffy-458-2-katalog` |
| 457.2 | M | **von Perikles (Chef 01.11., 11:49, „unsere Signatur muss sich wiederfinden“):** eigene Probeskripte zeichnen standardmäßig mit Toon-Licht, Tusche, Schatten; ohne nur mit Schalter (Zu 457.2) | gebaut e87815dc8, fährt mit den nächsten Filmen | `claude/jerry-457-2-signatur` |
| 453.1 | M | **von Sokrates (Chef 01.11., 13:0x):** Helden im Kampf atmen gleich und zu heftig („hechelt“): Atmen ruhiger, je Figur eigener Takt, nach Angriff oder Abwehr schneller, dann abklingend (Zu 453.1) | gebaut: passt (Archiv 453.1a, Lauf 173 = fd2116303), fährt im nächsten Build; 0f28eda79, d88f06ab3 nicht mitnehmen | `claude/tuffy-453-1-held-atem` |
| 453 | M | **von Sokrates (Chef 01.11., 11:05):** Wölfe brauchen Ruhebewegungen: atmen, scharren, umblicken, knurren (Zu 453) | gebaut: r3b passt (Chef 02.11., 11:02, Archiv 453), fährt im nächsten Build (claude/grundstand-461); Sichtbarkeit in 453a | – |
| 453a | M | Wolfsatem B (Archiv) | gebaut: passt 19:58; Geprüft an: Lauf 176; Bildrand Nahansicht danach | – |
| 454 | M | **von Sokrates (Chef 01.11., 11:05):** beim Biss zielt die Achse des Wolfs wohl rechts neben den Helden; erst messen, dann bauen (Zu 453) | gebaut: passt (Archiv 454), fährt im nächsten Build; Schildreaktion in 406 | `claude/jerry-454-bissachse` |
| 438a | M | **von Sokrates (Archiv 438a):** Hinfallen/Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei | wartet auf Test: Messlauf 3fd827bf7 (Ursache im schlimmsten Bild, Vergleich V1); Lauf 189 Zu 438a | `claude/jerry-438a-sturz-2` |
| 439 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Reihenfolge Angriff, Treffer, Tod, Neuformation (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 440 | M | **von Sokrates (Chef 31.10., 23:34, Film 403):** Wolf-Tod zu schnell weg (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 416.6 | K | **von Sokrates (Chef 31.10., 20:4x):** Spuren des Helden fehlen (`core/Tracks.kt`, `LISTE-UMZUG-348.md` „Spuren“). Perikles: M oder K? | wartet auf Tom: Regen und Zeichnen in Godot (LISTE-UMZUG-348 „Wetter“, Toms karte.gd); spuren.gd mit Test regeln_390 fertig | – |
| 415 | M | **von Sokrates („jetzt“ 01.11., 20:0x; Archiv 415):** Probe Beams Free Sample im Kampfort (Film, Bilder je Sekunde); nichts kaufen | gebaut: passt (Chef 20:05), Testmenü da, fährt im nächsten Build; Geprüft an: Lauf 185 | `claude/jerry-415-beams` |
| 399.2 | M | **von Perikles („jetzt“ 28.10., 12:34, Archiv):** Kampfort aufrufbar | wartet auf Test: Build 146 (ansehen/t146-befunde.md; 143 getestet 31.10., 20:4x, Befunde als 416.x) | `claude/jerry-348-kampf` |
| 403 | M | **von Team Tom (23:1x, zu 376.1; M Perikles: Held gleitet im Kampf, Fehler):** Kampfort: Held je Klasse wie im Dorf (`HeldFigur.baue`), Bewegungen aus der UAL Pro | gebaut: passt (Archiv 403), fährt im nächsten Build | – |
| 461.1 | M | **von Sokrates („jetzt“ 01.11., 20:3x, Archiv 461):** Grundstand mit Tom: Kampfort, Wölfe, Helden im Kampf (`LISTE-GRUNDSTAND-461.md`) in `claude/grundstand-461`; vor 460 und 406.1 | wartet auf 406, 438a, 453.1, 376.1 (Zu 461.1) | `claude/grundstand-461` |
| 460 | M | **von Sokrates (Chef 01.11., 20:2x, Archiv 460):** Probefilm Kamerafahrten: Eröffnung je Blende (402), kurze Wechsel nur ohne Eingabe | wartet auf 461.1 (Grundstand vor 460) | – |
| 406.1 | M | **von Sokrates (Archiv 406.1):** Schildstoß ins MARS/BRS, Bau mit `ShieldAttack1–3S&S` | wartet auf 481 (Herkünfte): Bedingung Chef 11:21 mit Werten 427 nicht erfüllt (Zu 427.1) | – |
| 406 | M | **von Team Tom (Archiv 376.1):** Ausrüstung der Helden aufwerten, Kaufschilde mit goldener Sonne | wartet auf Messlauf 194 (eb03f25ee: Hand im Handgelenk geknickt, Kämpfer 20°, Kleriker 30°, Schild bleibt; KNICK ±10°); Lauf 190 Faust allein 2,1–4,0 cm (Zu 406) | `claude/jerry-406-kaufschild` |
| 387 | M | **von Sokrates (Chef 21:27):** gekaufte Tiere prüfen, vor Eigenbau | ruht: Feintuning nach 399 (Hühner hoppeln, Rind 78 s Fleck, 150°-Sprung) |
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
| D23.3 | M | Diogenes Lauf 23: Magier und Kleriker sterben oft | ruht: ersetzt durch 427 (Klassen entfallen; Zauberlehrling und Klosterschüler je Herkunft in sim444, 481) | `claude/diogenes-d41-messung` |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte | ruht bis 348.7 (Kampfort in Godot); Kür hinter dem Meilenstein (Chef 19.10.) | `claude/jerry-72u-standbild-2` |
| 133 | K | Umsetzung 133: Charisma-Proben, Erfahrung für Konflikte | ruht: SRD (Chef 31.10.) | – |
| 212 | M | Umsetzung 212: Schalter MARS oder klassisch | ruht: SRD (Chef 31.10.) | – |
| 86 | K | Keuchen, Initiative, Rennen | ruht: SRD (Chef 31.10.) | – |
| 38 | M | Balance Kapitel 1 gemessen | ruht: teils ersetzt durch 427 (Balance je Herkunft, sim444, 481) | – |
| 39 | M | Schwierigkeitsgrad im Menü | ruht: SRD (Chef 31.10.) | `claude/jerry-39-schwierigkeit` |
| 59e | K | Händler: Vorrat je Laden | ruht: SRD (Chef 31.10.) | `claude/jerry-59e-haendlervorrat` |
| 19 | K | Zeitablauf der Kampfbewegungen | ruht: SRD (Chef 31.10.) | – |
| 469 | M | **von Sokrates (02.11., 11:0x, zu 406.1):** Kampf auf BRS: Ring (MARS) ohne Klassen regeln (Antwort nach Klasse heute) | wartet auf 406.1 | – |
| D29.1 | K | von Diogenes: Ortsklang ohne Richtung | ruht: Klang zieht nach Godot; Rest `LISTE-IDEEN.md` „Klang“ | `claude/build-89` |

## Einzelheiten

- **Zu 487 (Jerry 02.11., 21:4x):** `claude/build-487` (4c96e8fba): Tom 416.9, 416.8, 416.2 (Merge); Jerry 458.2 (Merge, Einzelstücke jetzt in `ladenschirm.gd` ausgeblendet), 473, 472 (Cherry-Pick); `brs_473` auf Werte 2.0 (427.1, sim.py nachgerechnet). Lokal grün außer tresen, platzwechsel, klang (brauchen Modelle, Klänge). Nicht drin: 415 (sitzt auf Grundstand), 416.4, 453.2 (über 461.1). Offen: `godot.yml` von Hand auf dem Zweig, Prüfliste, PR; 472/473 ohne sichtbare Wirkung bis 2.3.

- **von Sokrates (Chef 02.11., 20:05, zu 415):** „Ob es auf dem Handy läuft, weiß ich nicht. Müsste getestet werden mit einem flotten Testeintrag im Testmenü.“ Eintrag zeigt die drei Strahlen nacheinander mit Bildern je Sekunde; dazu Schalter Leuchten (Glow) an/aus, weil Status Effects VFX ihn braucht (Kauf 415d beim Chef). Mit dem nächsten Build, Testbitte selbst stellen.

- **von Sokrates (Chef 02.11., 14:55, zu 348.12):** „348.12b alter Körper ja“: Grak-Film darf vorab auf Graks heutigem Körper raus (Grundstand B2 hält ihn dafür nicht an); beurteilt wird die Bewegung.

- **Zu 472, 473 (Jerry 02.11., 11:4x):** `godot/regeln/brs.gd` liest `daten/werte.json` (= `tools/sim444/werte.json`); Tests `brs_472.gd`, `brs_473.gd`. Offen: Kampf rechnet bis 2.3 nach SRD (Frage an Perikles); Stufe am Helden (Heldenblatt, Anzeige Deckel, `lohn.gd`) nach 470; Annahmen Topf 10 %, weich 0,25 an Sokrates (427).

- **von Team Tom (Spike, 01.11., 21:2x, zu 461.1):** `claude/grundstand-461` = Build 146, Tom, `jerry-406-kaufschild`, `jerry-348-12-grak-schreitet`; Konflikte (`heldfigur.gd`, `figur.gd`, `film_403.gd`) mit beiden Seiten gelöst. Nicht neu mischen, weiter auf dem Zweig; Kampfort-Film gegen die Checkliste bleibt euer.
- **Wortlaut in Git** (`git show <Commit>:docs/ARBEIT-TEAM-JERRY.md`): volle Titel der ruhenden Zeilen dc386b2e8; von Homer zu 444 und Spike zu 425 ee343195b; Zu 453, 402 („Bubum“) 7cacfa97d; Zu 453 r2 („Helden wieder doof“) 00d2ab8d5; Zu 406 a–e, 460, 438a Waffenpakete 907f307f2; Zu 453.1 da33d472c; ruhende SRD-Zeilen (296.2, 344.2, 249, 211.13/14, 168.1, 72u.1, 38, 39) de0998e2a; Zu 348.12 Lauf 177 5dc32fd63; Zu 438 (Tuffy 00:57), Zu 461.1 (Tuffy 03:4x), Zu 399.2 (Tom, Goblins v3) 110805b49; Zu 453 r3, Zu 406 G1, von Sokrates zu 427.1 (19:0x) 0bcceff99; von Perikles (bild=nein), von Sokrates zu 438a Runde 2 (14:49), Zu 438a Läufe 186–187 ccc23661c; Zu 478 (Schätzung) 22ae14a88.
- **Zu 438a, 438 (Jerry 02.11., 20:5x):** Chef 14:49 passt nicht (Waffe durchs rechte Bein beim Aufstehen). Runde 5 (5837c37a2, Hautschutz der Beine) kaum besser. Lauf 189: Griff frei (−0,5 cm), Klinge 0,52 m vom Griff 13,0 cm im Kleid (thigh_l, 2,90 s); Kampfhaltung 8,1 cm im ersten Bild (0,03 s, Schutz dort aus); Kleriker 5,8 cm, Griff frei. Messlauf 87b0297d5 (bild=nein): Zeile „Schutz:“ (was _boden_schutz tat) und Vergleich V1 (Hautpunkte nach dem Drehen neu, tief drin ohne Grenze je Bild). Offen: Kampfhaltung Kleid (463), Wolf 1 im Kleriker (438).
- **Zu 406 (Jerry 02.11., 22:0x):** Lauf 190 (SchildFaust −50°, in `skeleton_updated`): Finger noch 2,1–2,7 cm (Kämpfer), 3,7–4,0 cm (Kleriker) vor der Vorderseite, vor allem Ring- und kleiner Finger. Schild weiter vor schiebt den Schwertarm hinein (Lauf 179), darum Hand im Handgelenk nach hinten geknickt, Schild bleibt (eb03f25ee, Kämpfer 20°, Kleriker 30°); Messlauf 194 misst dazu je −10/+10/+20° (Zeile KNICK).
- **von Sokrates (Chef 01.11., 22:35, „461c wie Sokrates“, Archiv 461c; Grundstand B5, F4):** zu 406: Kleriker-Schild Form Schild 2 mit goldener Sonne in unseren Farben; zu Kampf: Tod für alle zusammenbrechen, kurz liegen, dann ausblenden (auch Wölfe); zu 444: Schmiedelehrling startet zusätzlich mit Stumpfe Waffen (`werte.json`), neu rechnen.
- **Zu 348.12 (Chef 27.10., 29.10., 01.11., 22:45):** Wortlaut in Git (1820858d2): Nachjustieren kein Kriterium; Schreiten nur beim Ortswechsel, Ausweichen rasch nur gegen sichtbaren Angriff; in 348.12k mitnehmen.
- **Zu 348.12, aus 348.12j (Chef 02.11., 11:22, Archiv 348.12j):** Axtkopf im Kampf oben; im Kampf (Held wie Grak) Kampfhaltung des Zweihand-Pakets, beide Fäuste am Stiel, Stiel nicht durch die Schulter (E3); E6 hängend nur unterwegs. Beim nächsten Grak-Lauf bauen.