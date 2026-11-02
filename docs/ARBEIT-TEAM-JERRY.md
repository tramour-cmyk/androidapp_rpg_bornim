# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`).

Nie „Heldin“, immer „der Held“ (Chef 29.10.: „Jerry immer noch gendert“).

**Übergabe (02.11., 11:4x):** Leichen 453, 348.12j berichtigt; 473 und 472 (Regelteil) gebaut auf `claude/jerry-473-monsterwerte`. Aus der Übergabe 07:27 weiter offen: 406 Schlussfilm Lauf 170 (`claude/jerry-406c-gehen`), 438a Lauf 164. Nachfolger: „Jerry – 406, 438a: Schlussfilm Lauf 170 prüfen und vorlegen, Lauf 164 auswerten“

## Zeilen

Volle Titel der ruhenden Zeilen in Git: `git show dc386b2e8:docs/ARBEIT-TEAM-JERRY.md`.

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 473 | M | **von Perikles (Wochenziel 02.11., Stufe 1):** Bau BRS 1.4 Monsterwerte Kapitel 1 nach Rechenmodell D ins Spiel (Abnahmeliste 1.4, Schätzung 447.3: 1 Sitzung, 1 Runde) | gebaut 7d2eec7cc: Werte aller 18 Arten und Modell D im Spiel (regeln/brs.gd, daten/werte.json wie sim444), Kampf rechnet bis 2.3 nach SRD (Frage an Perikles); fährt im nächsten Build | – |
| 472 | M | **von Perikles (Wochenziel 02.11., Stufe 1):** Bau BRS 1.3 Heldenstufe aus Erfahrung, Anteil Fertigkeiten höchstens 40 %, Erfahrungstopf je Gebiet (Abnahmeliste 1.3); Schnittstelle mit Tom (471) | gebaut a6a83b13e: Regel (Brs.gib_erfahrung, Deckel, weiche Grenze, Topf); Verdrahtung mit Held nach 470 etwa 1 S, 1 R (Zu 472) | – |
| 467 | M | **von Sokrates (Chef 01.11., 21:52, Frage „Wie steigert sich die Ausdauer?“):** `godot/regeln/ausdauer.gd` rechnet noch nach SRD (Konstitution 10, Modifikator, Stärke 13); BRS: Ausdauer aus Zähigkeit, Wille, Stufe (Abschnitt 2); Formel kommt mit 427 zum Chef, dann umstellen | wartet auf 427 (Formel von Sokrates zum Chef) | – |
| 438 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Wölfe gleiten (Angriff, Tempo, aneinander vorbei); echte Schritte, Zahlen (Zu 438) | gebaut: wolf_mess_438 grün (Zu 438) | `claude/jerry-438-wolf-kampf` |
| 458.2 | M | **von Sokrates (Chef 01.11., 13:1x, Archiv 458):** Gegenstandskatalog: Werte, Preise, Beute je Monster in die Datendatei (aus 444); das Spiel liest nur sie | gebaut 67eb82d09: Katalog voll, Spiel liest ihn (katalog.gd); fährt im nächsten Build | `claude/tuffy-458-2-katalog` |
| 457.2 | M | **von Perikles (Chef 01.11., 11:49, „unsere Signatur muss sich wiederfinden“):** eigene Probeskripte zeichnen standardmäßig mit Toon-Licht, Tusche, Schatten; ohne nur mit Schalter (Zu 457.2) | gebaut e87815dc8, fährt mit den nächsten Filmen | `claude/jerry-457-2-signatur` |
| 453.1 | M | **von Sokrates (Chef 01.11., 13:0x):** Helden im Kampf atmen gleich und zu heftig („hechelt“): Atmen ruhiger, je Figur eigener Takt, nach Angriff oder Abwehr schneller, dann abklingend (Zu 453.1) | in Arbeit bei Tuffy: Feld 2 gebaut fd2116303 (Ruhe 3,6 s, Steigerung 2,6-mal tief, 2 s halten), Film Lauf 173 (kampf=4531) | `claude/tuffy-453-1-held-atem` |
| 453 | M | **von Sokrates (Chef 01.11., 11:05):** Wölfe brauchen Ruhebewegungen: atmen, scharren, umblicken, knurren (Zu 453) | gebaut: r3b passt (Chef 02.11., 11:02, Archiv 453), fährt im nächsten Build (claude/grundstand-461); Sichtbarkeit in 453a | – |
| 453a | M | Wolfsatem B (Archiv) | gebaut ec57fe08a: Lauf 174 mit Messung und Vergleichsfilm (B, r3b, ohne) läuft | – |
| 454 | M | **von Sokrates (Chef 01.11., 11:05):** beim Biss zielt die Achse des Wolfs wohl rechts neben den Helden; erst messen, dann bauen (Zu 453) | gebaut: passt (Archiv 454), fährt im nächsten Build; Schildreaktion in 406 | `claude/jerry-454-bissachse` |
| 438a | M | **von Sokrates (Chef 01.11., 11:47, „nicht beurteilen, wenn ich es nicht gesehen habe … Vielleicht kann er auch so taumeln“):** Sichtungsfilm Hinfallen/Aufstehen auf Kaufheld aus dem Bestand, dann Wahl am Bild (Archiv 438a) | wartet auf Chef: Urteil Runde 2 (ansehen/438a-sturz-runde2; Wächter 468 (3)); Lauf 164 ausgewertet (Zu 438a) | `claude/jerry-438a-sturz-2` |
| 439 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Reihenfolge Angriff, Treffer, Tod, Neuformation (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 440 | M | **von Sokrates (Chef 31.10., 23:34, Film 403):** Wolf-Tod zu schnell weg (Zu 438) | gebaut: passt (Archiv 438), fährt im nächsten Build | `claude/jerry-438-wolf-kampf` |
| 416.6 | K | **von Sokrates (Chef 31.10., 20:4x):** Spuren des Helden fehlen (`core/Tracks.kt`, `LISTE-UMZUG-348.md` „Spuren“). Perikles: M oder K? | frei | – |
| 415 | M | **von Sokrates („jetzt“ 01.11., 20:0x; Archiv 415):** Handyprobe Beams Free Sample: läuft es auf dem Handy, FPS je Renderer, Wirkung mit Toon-Licht und Tusche im Kampfort (Film); nichts kaufen | wartet auf 415b (Film Lauf 172 am Tor angehalten, APK fürs Handy da) | – |
| 415b | M | Rückfrage: dritter Lauf oder Handy? | wartet auf Chef: entscheiden/415b | – |
| 399.2 | M | **von Perikles („jetzt“ 28.10., 12:34, Archiv):** Kampfort aufrufbar | wartet auf Test: Build 146 (ansehen/t146-befunde.md; 143 getestet 31.10., 20:4x, Befunde als 416.x) | `claude/jerry-348-kampf` |
| 399.2b | M | **von Team Tom (15:05):** Rudel allein zu stark | wartet auf Test: Build 146 (t146) | – |
| 403 | M | **von Team Tom (23:1x, zu 376.1; M Perikles: Held gleitet im Kampf, Fehler):** Kampfort: Held je Klasse wie im Dorf (`HeldFigur.baue`), Bewegungen aus der UAL Pro | gebaut: passt (Archiv 403), fährt im nächsten Build | – |
| 461.1 | M | **von Sokrates („jetzt“ 01.11., 20:3x, Archiv 461):** Grundstand mit Tom: Kampfort, Wölfe, Helden im Kampf (`LISTE-GRUNDSTAND-461.md`) in `claude/grundstand-461`; vor 460 und 406.1 | wartet auf 406, 438a, 453.1, 376.1 (Zu 461.1) | `claude/grundstand-461` |
| 460 | M | **von Sokrates (Chef 01.11., 20:2x: „Wechsel der Kameraperspektive … wie eine Drohne rumfliegen … verschiedene Eröffnungen“; Wortlaut Archiv 460):** Probefilm Kamerafahrten: Eröffnung je Blende (402), kurze Wechsel nur ohne Eingabe; Vorschlag Sokrates im Chat 20:3x, Zu 460 | wartet auf 461.1 (Grundstand vor 460) | – |
| 406.1 | M | **von Sokrates (Chef 01.11., 20:2x, Archiv 406):** Schildstoß ins MARS/BRS (Reaktion, Konter am Ring, vielleicht Angriff): Regelvorschlag als Chefsache, dann Bau mit `ShieldAttack1–3S&S` | wartet auf 444: A mit Bedingungen (Chef 02.11., 11:21, Archiv) | – |
| 406 | M | **von Team Tom (Chef 28.10., 23:0x, Archiv 376.1 Klassenentwürfe):** Ausrüstung der Helden je Stück aufwerten („steril“), zuerst Rundschild des Klerikers hell mit goldener Sonne (`Dress.kt`); Wappenrock-Sonne macht Tom | wartet auf 406a (Schlussfilm Lauf 170 am Tor angehalten) | `claude/jerry-406-kaufschild` |
| 406a | M | Rückfrage: neue Läufe für den Schlussfilm? | wartet auf Chef: entscheiden/406a | – |
| 401 | M | **von Chef über Sokrates (Archiv):** Tierlaute, mind. 3 je Tier | wartet auf Test: Build 146 (t146) | – |
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
| D63.6 | K | **von Diogenes (374/434, Vortag 01.11.):** ohne „Bestand geprüft“ (434): 438 08:11, 09:45; 454; 348.12 21:49; 453.1 Atem (Tuffy); ohne Homer-Vorgabe (373 c): 438, 454, 348.12, 453, 453.1; nach Tor 461a ohne belegte Prüfung: 453 r3, 453.1 (Tuffy 23:03) (Zu 374 in `ARBEIT-PRUEFUNG.md`) | offen | – |

## Einzelheiten

- **Zu 472, 473 (Jerry 02.11., 11:4x):** `godot/regeln/brs.gd` liest `daten/werte.json` (= `tools/sim444/werte.json`); Tests `brs_472.gd`, `brs_473.gd`. Offen: Kampf rechnet bis 2.3 nach SRD (Frage an Perikles); Stufe am Helden (Heldenblatt, Anzeige Deckel, `lohn.gd`) nach 470; Annahmen Topf 10 %, weich 0,25 an Sokrates (427).

- **Zu 438, von Tuffy 00:57, Prüfer 453 r3b):** Wolf springt 7,9 s in 2 Bildern in Vorderansicht; nah 12,7 s 180° in 0,3 s.

- **von Team Tom (Spike, 01.11., 21:2x, zu 461.1):** `claude/grundstand-461` = Build 146, Tom, `jerry-406-kaufschild`, `jerry-348-12-grak-schreitet`; Konflikte (`heldfigur.gd`, `figur.gd`, `film_403.gd`) mit beiden Seiten gelöst. Nicht neu mischen, weiter auf dem Zweig; Kampfort-Film gegen die Checkliste bleibt euer.
- **Wortlaut in Git** (`git show <Commit>:docs/ARBEIT-TEAM-JERRY.md`): von Homer zu 444 und Spike zu 425 ee343195b; Zu 453, 402 („Bubum“) 7cacfa97d; Zu 453 r2 („Helden wieder doof“) 00d2ab8d5; Zu 406 a–e, 460, 438a Waffenpakete 907f307f2; Zu 453.1 da33d472c; ruhende SRD-Zeilen (296.2, 344.2, 249, 211.13/14, 168.1, 72u.1, 38, 39) de0998e2a; Zu 348.12 Lauf 177 5dc32fd63.
- **Zu 453 r3, r3b (Tuffy):** Stand und Prüferbefunde im Blatt `ansehen/453-wolf-ruhe.md`, Ursache im Commit d41f0c692; Rückfrage 453a.
- **Zu 461.1, 406, Tuffy (02.11., 03:4x):** Prüfer Lauf 159 (Kampfort-Film, Tor 461a) Verstöße: B5 Kleriker-Schild ohne Sonne (406, 461c); E5, F1 beim schweren Biss kein Hinfallen, Schild erst danach (438a); C1 Kämpfer von hinten ohne sichtbaren Atem (453.1); B4, E3 Umhang (Tom); A4 Verdacht: Held nur runder Bodenfleck.
- **Zu 438a (Urteil Sichtung 01.11., 20:1x; Runde 2 und 3, 02.11.) und Zu 438 (wolf_mess_438 behoben, 9 → 0):** Waffe und Schild nach Prefab anstecken, Durchdringung höchstens 2 cm; Runde 3 gebaut 713fdb5fd, 3a6b29459, 602b0fd41; Wortlaut, Werkzeuge, Commits in Git, `git show 98a37d865:docs/ARBEIT-TEAM-JERRY.md`. **Lauf 164:** Faust gut; 9 falsch: Stab in Beinrüstung 4,8/8,5 cm (KAPSEL_FREI wirkt nicht), Schildfinger 1,7 cm, Drehung 34,5° je Bild; Klinge im Umhang bis 13 cm (Tom 463), Zucken 16°, 40° je Bild. Wolf 1 läuft 6–7 cm in den stehenden Kleriker (Bahn 438, nicht Liegen); Kleriker ab 10,6 s angeschnitten (G1). Weiter: Stab am Netz nachstellen, dann bauen.
- **Zu 348.12 (Chef 27.10., 17:19):** „ob das Modell trifft … muss man halt nachjustieren, das kann kein Kriterium sein“. Grak (Chef 29.10., 10:55): „gut, aber Gang schreitend statt kurzer Sprint“; Bau und Prüfwege `git show c30c827d0:docs/ARBEIT-TEAM-JERRY.md`.

- **Zu 399.2, von Tom (28.10., 13:23):** `goblin.py` kennt `v3/rig.py` nicht; Goblins mit `v3_kampf/`, vor der Höhle auf `v3` umstellen.
- **von Sokrates (Chef 01.11., 22:35, „461c wie Sokrates“, Archiv 461c; Grundstand B5, F4):** zu 406: Kleriker-Schild Form Schild 2 mit goldener Sonne in unseren Farben; zu Kampf: Tod für alle zusammenbrechen, kurz liegen, dann ausblenden (auch Wölfe); zu 444: Schmiedelehrling startet zusätzlich mit Stumpfe Waffen (`werte.json`), neu rechnen.
- **Zu 348.12, Urteil Film Grak schreitet, von Sokrates (Chef 01.11., 22:45, Archiv 348.12; Grundstand D5, F5):** Schreiten nur beim Ortswechsel; Ausweichen rasch, nur gegen einen sichtbaren Angriff, danach zurück; Wortlaut `git show 515dfd03e:docs/ARBEIT-TEAM-JERRY.md`. In 348.12k mitnehmen.
- **Zu 348.12, aus 348.12j (Chef 02.11., 11:22, Archiv 348.12j):** Axtkopf im Kampf oben; im Kampf (Held wie Grak) Kampfhaltung des Zweihand-Pakets, beide Fäuste am Stiel, Stiel nicht durch die Schulter (E3); E6 hängend nur unterwegs. Beim nächsten Grak-Lauf bauen.