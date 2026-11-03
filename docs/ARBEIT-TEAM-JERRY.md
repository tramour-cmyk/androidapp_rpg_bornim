# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-ENTWICKLUNG.md`).

Nie „Heldin“, immer „der Held“ (Chef 29.10.).

**Übergabe (04.11., 00:1x):** 415 Build 250 (Strahlenprobe mit „Ohne Strahl“, `claude/jerry-415-ohne-strahl`); gebaut für den nächsten Build: 527, 532, 544 (je eigener Zweig von `claude/build-490`); 532a beim Chef; 545 Test ohne Befund. Nachfolger: Jerry – 545/548: Testknöpfe und Rattenkampf in der Welt nachstellen.

## Zeilen

| Nr. | Kl. | Titel | Stand | Zweig |
|---|---|---|---|---|
| 527 | M | **von Sokrates (512, Abgleich Build 249 im Code; Zu 527):** System: Schalter „Tempo“ und „Kampftext“ wirken im Kampf nicht; anschließen oder ausblenden, bis sie wirken | gebaut: Tempo über Engine.time_scale, Kampftext ausgeblendet (wirkte alt nur klassisch), fährt im nächsten Build (claude/jerry-527-tempo-kampftext); Geprüft an: 6a1e5eab8 (tempo_527, menue_test) | – |
| 548 | M | **von Sokrates (Chef 04.11., 00:03, Build 249, Bild; Zu 548):** „Gegen Ratten gespielt. Die starben ohne mein Zutun alle drei?!? Habe nicht einen Knopf gedrückt …“ | startbar: braucht die Welt mit Daten (Kartenratten), am Rechner ohne Welt nicht nachstellbar; mit 545 zusammen (Zu 548) | – |
| 551 | M | **von Sokrates (Chef 04.11., 00:21, Build 249):** „MARS Kasten links und rechts unten wird unterbrochen angezeigt …“ Goldrahmen des Bedienkastens; nachstellen am Handyformat (Bilder des Chefs 23:49–00:03 im Probekampf und im Wald) | startbar | – |
| 552 | M | **von Sokrates (Chef 04.11., 00:22, Build 249):** „MARS Zugreihenfolge oben fehlt“. Laut Abgleich gibt es eine Zugleiste im Code; in den Bildern des Chefs ist oben nur ein leerer schwarzer Streifen: liegt sie unter der Kamera des Handys (vgl. `Rand.oben`, 399.4)? Nachstellen | startbar | – |
| 553 | M | **von Sokrates (Chef 04.11., 00:26, Build 249, Bild):** „Was ist das für ein graues Tier??????“ Flüsterwald bei Garricks Feuer, Tag 2 13:47: graues, hochbeiniges Tier mit langem Hals, buschigem Schwanz, flach wirkend; dazu ein Wildschwein. Welche Art (Riesenratte mit Fell „grau“ und `ART_GROESSE` 2×, `figur.gd` 33, 47? Wolf?) feststellen; erkennbar machen oder ersetzen | startbar | – |
| 545 | M | **von Sokrates (Chef 04.11., 00:01, Build 249; Zu 545):** MARS-Probekampf: Testknöpfe „Gegner besiegen“ (✓) und „Held fällt“ (✗) ohne Funktion | startbar: am Rechner ohne Welt nicht nachgestellt (beide Wege wirken, testende_545); in der Welt mit Daten nachstellen (Zu 545); claude/jerry-545-testknoepfe | – |
| 546 | M | **von Sokrates (Chef 04.11., 00:01, Build 249; Zu 545):** MARS: Wölfe weichen viel zu träge aus („wie Schlaftabletten“) | startbar | – |
| 547 | M | **von Sokrates (Chef 04.11., 00:01, Build 249; Zu 545):** MARS: Text sagt „geht in die Knie“, Sturz ist aus (438a eingefroren): Text und Bild in Einklang bringen | startbar | – |
| 544 | M | **von Sokrates (Chef 03.11., 23:49, Build 249, Bild MARS-Probekampf: „Stimmt die Schrift?“):** Kampfschirm in Ersatzschrift ohne Serifen statt Alegreya wie Menü (Zu 544) | gebaut: load() statt roh (Ursache nachgestellt), nächster Build; Geprüft an: 510d5940b (schrift_544) | `claude/jerry-544-kampfschrift` |
| 532 | M | **von Sokrates (512, Abgleich Build 249 im Code; Zu 532):** Kampf: Held geht ohne Zauberpunkte, Verbrauchtes, Zustände, Metrausch und ohne die ganze Tasche (nur einfacher Heiltrank) in den Kampf, danach wird nur TP zurückgeschrieben; Zauber kosten nichts | gebaut: ZP, Verbrauchtes, Zustände, nächster Build (Zu 532); Rest 532a; Geprüft an: cfc2c499b | `claude/jerry-532-kampfzustand` |
| 532a | M | Rückfrage: Tasche und Metrausch jetzt wie alt in MARS oder erst mit 478? | wartet auf Chef: entscheiden/532a | – |
| 533 | M | **von Sokrates (512, Abgleich Build 249 im Code; Zu 533):** Kampf: Grimmzahn ist ein Wolf, kein Boss: Werte, „Grimmzahns Fang“, keine Flucht, Leibwache flieht nach seinem Fall | startbar | – |
| 534 | M | **von Sokrates (512, Abgleich Build 249 im Code; Zu 534):** Kampf: Zauber und Fähigkeiten fehlen in „Können“ (Magierrüstung, Untote vertreiben, Spirituelle Waffe, Geisterwächter) oder wirken nicht (Unglaubliches Ausweichen, Unerbittlichkeit, Lebensraub, Schadensminderung der Ausrüstung); Talente zu Kampfbeginn (Einschüchtern, Schwächen kennen) | startbar | – |
| 535 | M | **von Sokrates (512, Abgleich Build 249 im Code; Zu 535):** Kampf: Gegnerstufe, Elite, schimmernde Gegner, Gruppen (Ratten und Fledermäuse als Wölfe, Schamane ohne Heilen), EP und Gold je Gegner, Nachlass in Stufe 1; gegen BRS klären, Balance entscheidet der Chef | startbar | – |
| 536 | M | **von Sokrates (512, Abgleich Build 249 im Code; Zu 536):** Kampf: Erklärungen bei langem Drücken (MarsTips), Grund bei gesperrtem Zauber, „Kein Ziel in Sicht“, Knopf „Schnell“, Stufe und EP im Gruppenkasten, Seltenheitsfarbe der Beute | startbar: Chef 23:56 bestätigt am Gerät (Zu 536) | – |
| 478 | M | **von Sokrates (Chef 02.11., 17:59 „470a C“):** Rechenkern des Kampfs in Stufe 1 auf BRS (Modell D) | ruht: 470a B (3–4 Sitzungen, Wortlaut in Git) | – |
| 481.1 | M | **von Sokrates (427):** Tränke in sim444, Herkünfte neu messen, Zahlen an Sokrates | gebaut: sim444 Abschnitt 6 (claude/jerry-481-1-traenke); Geprüft an: 4bb60ba5e | – |
| 467 | M | **von Sokrates (Chef 01.11., 21:52):** `regeln/ausdauer.gd` rechnet nach SRD; BRS: Ausdauer aus Zähigkeit, Wille, Stufe; nach der Formel aus 427 umstellen | wartet auf Sokrates: Formel Ausdauer fehlt in 427 (Hinweis Beratung) | – |
| 438 | M | **von Sokrates (Chef 31.10., 23:31, Film 403):** Wölfe gleiten (Angriff, Tempo, aneinander vorbei); echte Schritte, Zahlen (Zu 438) | gebaut: wolf_mess_438 grün (Zu 438) | `claude/jerry-438-wolf-kampf` |
| 457.2 | M | **von Perikles (Chef 01.11., 11:49):** Probeskripte zeichnen standardmäßig mit Toon-Licht, Tusche, Schatten | gebaut e87815dc8, fährt mit den nächsten Filmen | `claude/jerry-457-2-signatur` |
| 453.1 | M | **von Sokrates:** Helden im Kampf atmen ruhiger, je Figur eigener Takt | wartet auf Test: t249 | – |
| 453 | M | **von Sokrates:** Ruhebewegungen der Wölfe | wartet auf Test: t249 | – |
| 453a | M | Wolfsatem B | wartet auf Test: t249 | – |
| 454 | M | **von Sokrates:** Bissachse des Wolfs | wartet auf Test: t249 | – |
| 438a | M | **von Sokrates (438a):** Hinfallen und Aufstehen des Kaufhelden, Waffe und Schild frei | ruht: eingefroren (488); Klinge quer im Kleid, Hand ruckt; im Spiel aus | `claude/jerry-438a-sturz-2` |
| 439 | M | **von Sokrates:** Reihenfolge Angriff, Treffer, Tod, Neuformation | wartet auf Test: t249 | – |
| 440 | M | **von Sokrates:** Wolf-Tod zu schnell weg | wartet auf Test: t249 | – |
| 416.6 | M | **von Sokrates:** Spuren (`core/Tracks.kt`): Blut, Staub, Fußspuren | wartet auf Perikles: Probebild nur auf dem Bauserver (511); mit 416.4 b31b7a85d lokal gut | `claude/jerry-416-6-blut` |
| 415 | M | **von Sokrates:** Probe Beams Free Sample im Kampfort; nichts kaufen | wartet auf Test: t250 (Ohne Strahl je Renderer), dann Renderer vorschlagen; claude/jerry-415-ohne-strahl | – |
| 399.2 | M | **von Perikles („jetzt“ 28.10., 12:34):** Kampfort aufrufbar | wartet auf Test: Build 146 (ansehen/t146-befunde.md; Befunde als 416.x) | `claude/jerry-348-kampf` |
| 403 | M | **von Team Tom:** Kampfort: Held je Klasse wie im Dorf | wartet auf Test: t249 | – |
| 461.1 | M | **von Sokrates („jetzt“ 01.11., 20:3x, Archiv 461):** Grundstand mit Tom: Kampfort, Wölfe, Helden (`LISTE-GRUNDSTAND-461.md`); vor 460 und 406.1 | ruht: nach dem Durchspielen (488) | `claude/grundstand-461` |
| 460 | M | **von Sokrates (Chef 01.11., 20:2x, Archiv 460):** Probefilm Kamerafahrten: Eröffnung je Blende (402), kurze Wechsel nur ohne Eingabe | ruht: nach dem Durchspielen (488, Wochenziel 03.11.) | – |
| 406.1 | M | **von Sokrates (406.1):** Schildstoß ins MARS/BRS, Bau mit `ShieldAttack1–3S&S` | wartet auf 481 (Herkünfte): Bedingung Chef 11:21 mit Werten 427 nicht erfüllt (Zu 427.1) | – |
| 489 | M | **von Sokrates:** Hauptmenü: Schalter Musik und Effekte wie alt | wartet auf Test: t249 | – |
| 406.2a | M | **von Sokrates:** Angriffsweg im Kampf mit UAL-Rennen wie im Dorf, alle Waffen (Zu 406.2a) | wartet auf Perikles: Probebild nur auf dem Bauserver (511); Messlauf 246 (Zu 406.2a) | `claude/jerry-406-2a-rennen` |
| 406.2 | M | **von Sokrates (Chef 03.11., 06:59, „jetzt“; Zu 406.2):** im Kampf zum Angriff gehen statt rennen, Parade mit Schild je Richtung; ein Lauf, dann eingefroren (488) | gebaut: Parade nach Trefferhöhe, nächster Build; Geprüft an: 9bb94fd69 | – |
| 406 | M | **von Team Tom:** Ausrüstung der Helden aufwerten, Kaufschilde mit goldener Sonne | wartet auf Test: t249 | – |
| 510 | M | **von Sokrates:** Fledermaus: freies OGA-Modell „Vampire Bat“ (CC0) mit unseren Fellen neben der eigenen, Film, Chef wählt (Zu 510) | wartet auf Perikles: Probebild nur auf dem Bauserver (511); Lauf 243: Runner abgeschaltet (Zu 510) | `claude/jerry-494-gegner` |
| 509 | M | **von Sokrates (Chef 03.11., 09:21):** Frösche und Libellen an den Teichen wie alt (`PondLife.kt`, `PondSound.kt`; O6, W22) | wartet auf Perikles: Probebild nur auf dem Bauserver (511); Film kaputt, aus der Chefsache (Chef 13:49) | `claude/jerry-509-teich` |
| 494 | M | **von Perikles (Wochenziel 03.11. Reihe 3, 488):** Gegner von Kapitel 1 im Kampf (Liste und Stand Zu 494), je Gegner höchstens ein Lauf; 348.12 Goblin geht hierin auf | wartet auf 511: alle Gegner außer Fledermaus (510) gebaut, Bilder ungeprüft; zuletzt Netzwurf 6a155992b, Ratte, Fledermaus, Spinne allein f0f9ea09d (Zu 494) | `claude/jerry-494-gegner` |
| 517 | M | **von Team Tom (03.11., 16:3x, Abgleich 512):** Waldklang wie alt: Vögel am Tag, Eule und Grillen nachts, fernes Wolfsheulen im Tiefen Wald (`WildSound.kt`; `klang.gd` hat nur Wind, Feuer, Fluss, Dorftiere), steht in t248 als bekannt | gebaut: fährt im nächsten Build; Geprüft an: c12991504 (klang_test) | `claude/jerry-517-waldklang` |
| 507 | M | **von Perikles (Wochenziel 03.11. Reihe 3, 488; aus 492):** Kampforte Höhle wie alt: Eingang, Gang, Halle, Teich, Lager (Orte O10); die Höhle als Ort baut Tom (492) | startbar: ein Lauf frei (Sokrates 20:2x, Archiv), Probebild nach 511a | `claude/jerry-507-hoehle` |
| 496a | M | Rückfrage: abgenommene Kampfbilder schon in den Durchspiel-Build? | wartet auf Test: t249 | – |
| 496 | M | **von Perikles (Wochenziel 03.11. Reihe 5, 488):** Durchspiel-Build aus 490–495: der Chef spielt Kapitel 1 von Anfang bis Ende am Handy | wartet auf 490, 491, 492, 493, 494, 495, 506, 507 | – |
| 387 | M | **von Sokrates (Chef 21:27):** gekaufte Tiere prüfen, vor Eigenbau | ruht: Feintuning nach 399 (Hühner hoppeln, Rind 78 s Fleck, 150°-Sprung) |
| 348.12f | M | **von Sokrates (348.12c b):** gekaufte Riesenratte, unsere Haut | gebaut f77f2740e: Kaufratte und -wolf verschlüsselt im APK | `claude/jerry-348-kampf` |
| 385.2 | M | **von Chef:** Feuer aus dem Stab | ruht (Stopp 07:26): Befund f482b46c1, Zweig claude/tuffy-385-2-stabfeuer | – |
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
| 296.3 | K | von Sokrates: MARS-Schmuck | ruht bis 348.7 (Kampf in Godot; Urteil 348 gefallen 25.10.) | – |
| 344.2 | K | von Sokrates: Kampf mit der Fackel | ruht: SRD (Chef 31.10.) | `claude/jerry-344-2-fackel` |
| 168.1 | K | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab 3 | wartet auf 38, dann Bau Kapitel 2; Texte Homer (41) | – |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte | ruht bis 348.7 (Kampfort in Godot); Kür hinter dem Meilenstein (Chef 19.10.) | `claude/jerry-72u-standbild-2` |
| 133 | K | Umsetzung 133: Charisma-Proben, Erfahrung für Konflikte | ruht: SRD (Chef 31.10.) | – |
| 212 | M | Umsetzung 212: Schalter MARS oder klassisch | ruht: SRD (Chef 31.10.) | – |
| 86 | K | Keuchen, Initiative, Rennen | ruht: SRD (Chef 31.10.) | – |
| 38 | M | Balance Kapitel 1 gemessen | ruht: teils ersetzt durch 427 (Balance je Herkunft, sim444, 481) | – |
| 39 | M | Schwierigkeitsgrad im Menü | ruht: SRD (Chef 31.10.) | `claude/jerry-39-schwierigkeit` |
| 59e | K | Händler: Vorrat je Laden | ruht: SRD (Chef 31.10.) | `claude/jerry-59e-haendlervorrat` |
| 19 | K | Zeitablauf der Kampfbewegungen | ruht: SRD (Chef 31.10.) | – |
| 469 | M | **von Sokrates:** Kampf auf BRS: Ring ohne Klassen regeln | wartet auf 406.1 | – |
| D29.1 | K | von Diogenes: Ortsklang ohne Richtung | ruht: Klang zieht nach Godot; Rest `LISTE-IDEEN.md` „Klang“ | `claude/build-89` |
| Pflege | K | **von Werkzeug (340.3, 04.11.):** 22680 Bytes (Grenze 15000), Erledigtes streichen | startbar |

## Einzelheiten

- **Zu 548, von Sokrates:** Bild: Magier Alrik mit Langschwert und Schild allein im Wald, keine Ratte zu sehen; Bericht „Riesenratte 1 sackt winselnd zusammen. Riesenratte 2 fällt. Riesenratte 3 sackt winselnd zusammen.“; Sieg, 80 EP, 6 Gold, Rohes Fleisch; TP 6/19. Möglich, nicht geprüft: „Held selbst“ (Automatik) blieb aus dem Probekampf an; verspätete Wirkung des Testknopfs ✓ (545); Ratten als Wölfe mit Wolfstexten (535). Erst nachstellen. Ratten auch unsichtbar? **Chef 00:05:** „Ich konnte nicht einstellen, da die Ratten angriffen und dann eine nach der anderen tot umfiel …“ Also kein Zug des Spielers, keine Knöpfe; Kampf läuft von selbst bis zum Sieg. **Jerry:** diese Zeilen schreibt auch `test_end(true)` (545).
- **Zu 545–547, von Sokrates:** Chef 04.11., 00:01: „MARS: Animation niedersinken oder umfallen oder in die Knie gehen kommt trotz Text nicht. Wölfe weichen aus wie Schlaftabletten. Helden wehren immer gleich ab.... Button Gegner killen oder Suicide ohne Funktion“ „Helden wehren immer gleich ab“ gehört zu 406.2 (Parade je Richtung, laut t249 später). Zu 547: entweder Sturz zeigen oder bis dahin Text ohne „in die Knie“; Text über Homer.
- **Zu 545 (Jerry 00:0x):** `tests/testende_545.gd` (Hochformat, Finger und Maus, über `probe.gd` und `aufruf.gd` mit Blende): Haken und Kreuz wirken am Rechner. Nächster Schritt: in `spiel.tscn` mit allen Daten über „Test“ → „MARS-Probekampf“, `gui_get_hovered_control()` an `win_rect`.
- **Zu 544 (Jerry 23:57):** `kampf_ui.gd` las die rohe .ttf (`load_dynamic_font`), im APK steht nur die importierte .fontdata (`include_filter`); nachgestellt ohne rohe Datei: leere Schrift ohne Namen. Jetzt `load()`.
- **Zu 527–536, von Sokrates (Helfer, Code gelesen):** Alt lief der Weltkampf klassisch (`Battle.kt`), MARS nur als Probekampf; neu jeder Kampf MARS, `regeln/klassisch.gd` ungenutzt. Besser neu: Reihen, Platztausch, Waffenwechsel, Decken, Absichten, Automatik je Figur, Kampfbericht, Zugleiste.
- **Zu 532, von Sokrates:** `aufruf.gd` 178, 203–209, `spiel.gd` 489, 529, `mars.gd` 333–335 (je Rast voll zu jedem Kampf); alt `Battle.kt` 160–176, 576–605, `Game.kt` 764–773, 1496. Test: Kampf, dann Rast, ZP und Tasche prüfen.
- **Zu 533, von Sokrates:** `aufruf.gd` 34, `tabellen.json` „wolf“, `mars.gd` 939, 1525; alt `Monsters.kt` 133–137, `Packs.kt` 64. **Chef 04.11., 00:33, Bild Tiefer Flüsterwald:** „Ist Grimmzahn groß???“ Auf der Karte reicht sein Rücken bis an den Kopf des Helden, der Kopf darüber; Story: „groß wie ein Pony“ (`STORY-PLAN-K1.md` 194, `STORY-K1-WELT.md` 55, 160), Pony Widerrist etwa 1,2–1,4 m: wirkt größer als ein Pony. Maß auf Karte und im Kampfort (`figur.gd` 47 `dire_wolf` 1,75) danach festlegen, Größe am Helden messen. Neben ihm ein Kobold mit Speer (Leibwache?).
- **Zu 534, von Sokrates:** `mars.gd` 83–86, 1494 `_hurt`; alt `Battle.kt` 221–227, 407–410, 478–560, 1036–1042. Gegen BRS (451) prüfen, was bleiben soll.
- **Zu 535, von Sokrates:** `aufruf.gd` 29–36, 178 (kein „over“), `lohn.gd` 31–43; alt `Game.kt` 1267–1276, `Battle.kt` 101–116, 658–683, 1069–1071, `Packs.kt` 51, 68. Grinden lohnt neu nicht (Leitbild). Was absichtlich anders ist (MARS, BRS), als Chefsache vorlegen, nicht still angleichen.
- **Zu 536, von Sokrates:** `kampf_ui.gd` 589–702, `mars.gd` 669 `quick()`; alt `SkirmishScreen.kt` 1340–1475, `BattleScreen.kt` 1650–1730. **Chef 23:56, Bild Zielwahl im Probekampf:** „Tip durch Drücken funktioniert nicht. Aber ein Wolf hat Namen eingeblendet. Hier ebenfalls kein Vergleich mit Vorgängerversion erfolgt …“ Dazu im Bild: drei Wölfe, Zielwahl bietet nur Wolf 1 und Wolf 2 (Reichweite? prüfen und, wenn gewollt, erklären).
- **von Team Tom (03.11., 21:4x, zu 518):** `godot/kampf/toon.gdshader` und `godot/shader/toon.gdshader` setzten seit 463 `POSITION` nur bei `rueck`/`vorrang`/`nach` > 0, alle anderen Netze unsichtbar (Dorf ohne Häuser, Build 248); behoben 4f9ca1dce (`claude/tom-518-position`), Test `tests/position_518.gd`. Jeder deiner Zweige mit dem Figurenstand 463 braucht den Commit vor dem nächsten Bildlauf.

- **von Team Tom (03.11., 16:3x):** Krogg und Rauch eingebunden (`claude/tom-492-hoehle` 2fa4f6f0d, `"bugbear": "KROGG"`, `lage["rauch"]`, Abzug nach `mars.smoke`; ohne deinen Zweig wirkungslos). Build 248 (PR #180, auf 245) mit 490, 491, 493, 501, 503, 500, 497 läuft. Waldklang als 517.
- **Hinweis von Perikles (03.11., 16:1x, 513.1):** `probelauf.py` hält jeden Probelauf an, dessen Stand die Figurencommits aus `tools/figurenstand.tsv` nicht enthält; `claude/jerry-494-gegner` enthält beide (geprüft 17:0x), die übrigen Zweige nach dem Mischen von `main` prüfen.

- **Zu 507 (Jerry 15:5x):** `kampfort_hoehle.py`, `kampfort.gd _build_cave`, Tests `hoehle_bau_507`, `hoehle_507`, `ansage_507`; Felsen mit Tom 492. Lauf 247: Höhle a94fd2b32, Ansage 7c0b2b78e, Miras Schild nur davor. Lauf 3 nach „507, Läufe frei“.
- **Zu 416.6 (Chef 09:21, nach „416.6 passt“ für Blut):** Fußspuren bei Regen, Staub beim Laufen wie in Kotlin; Wortlaut a091e0433. Staub gebaut; Läufe 226, 231: Held ging (416.4).
- **Zu 494 (Perikles, Chef 07:54):** Gegner: Wildschwein, Riesenspinne, Hundertfüßer, Stirge, Ockergallerte, Krogg (Untote 506); Ratten, Fledermäuse eigene Figur. **Fertig** alle außer Fledermaus (Einzelheiten in den Commits auf `claude/jerry-494-gegner`, zuletzt 458867c5f; Säureschnecke: `figur.gd` spielt Umsehen, Drohen noch nicht; Ratte, Fledermaus, Spinne auf der Karte erst mit Toms `Streuner.GRUPPE`); **offen:** Wahl der Fledermaus (510); alle Bilder ungeprüft (511).
- **Zu 494 (Chef 10:26):** Kartenratte = Kaufratte; geprüft (Jerry 19:0x, Code): `aufruf.gegner()` setzt `Figur.ersatz_art` bei jedem Kampfbeginn neu, je Kampf nur eine Art; Wolf und Ratte behalten je ihr Modell.
- **Zu 494, von Sokrates (15:4x):** Kauf 348.12c: nur Fehlendes selbst bauen. `bornim-kaufmodelle/LIZENZ.md` nachgetragen (Jerry 18:01, 3353173; Bär steht unter Janpec). Chef 03.11., 18:00: „Hiermit erteile ich dir alle Rechte, die du brauchst, damit du vernünftig arbeiten kannst. Auch mögliche Schreibrechte in der Kaufmodellrepo.“ Push dorthin geht (`add_repo` mit Schreibzugang).
- **Zu 494, von Sokrates (Chef 16:08, zu 491):** Grimmzahn „sieht … nicht aus wie unsere Wölfe aus dem Kampf“: auf den Kaufwolf (eigenes Fell, 1,75, glühende Augen). Gebaut 11e6c4167 (`kaufwolf.py ART=dire_wolf`; ohne Narbe, Ohr; ungeprüft, 511).
- **Zu 510 (aus 494, „ein Lauf“; Wortlaut a091e0433):** OGA-Fledermaus in unseren Fellen neben der eigenen, Chef wählt; nur vorhandene Bewegungen, kurzer Film (`gegner=FLEDERMAUS`). Lauf 243 ohne Film: Runner abgeschaltet.
- **Zu 406.2a (Chef 09:03):** alle Waffen, ohne Durchdringung, nie `SS_RunForward`; Film `film_4062a.gd` (`rennen=ja`). Messlauf 246: Waffen 4–5-mal kleiner als im Spiel, Wolf auf der Schattenseite; nächster Schritt Spielkamera, Probebild (511).
- **Zu 415 (Chef 02.11., 22:04 „415d ja“):** läuft die Probe im Build flüssig, `chefsache/tun/415d-…` anlegen (Kauf beider Pakete), Lizenz vor dem Einbau lesen; vor jeder Testbitte Probe im APK.
- **Zu 415, von Sokrates (Chef 03.11., 22:57, Bild t249 245.4):** „Zu Build 249 Werte der Effekte“: Renderer gl_compatibility, jetzt 37 Bilder/s; Mittel Blauer Laser 33, Feuerstrom 34, Blitzbogen 33. Chef 23:00, zweites Bild: Renderer mobile, jetzt 25; Mittel Laser 24, Feuerstrom 25, Blitzbogen 25, also unter 30 (Falsch-Spalte); `project.godot` stellt auf main „mobile“ ein. Kein Urteil zum Aussehen. Chef 23:05 „Ja, Jerry soll ohne Strahlen messen“: dieselbe Stelle ohne Strahlen auf beiden Renderern messen, dann einen Renderer vorschlagen; 415d nicht vorher.
- **Zu 496a (Chef 07:59 „Rein damit in den Build. Also auf Main.“):** `claude/build-496a` = `main` + 461, 406.2, 415, 489, 453.1, 463, 417, Build 245; Kotlin rot (BattleAheadTest, fremd). Nach Test auf `main`.
- **Wortlaut in Git:** gekürzte Zeilen und Zu 453, 402, 406 a–e, 438, 461.1, 427.1, 438a, 478, 415, 348.12b, 489, 406.2, 348.12/348.12j: `git show a97f67e7e:docs/ARBEIT-TEAM-JERRY.md`, `a18dd9473:…`, `a091e0433:…`, Stand 16:2x `8e133b464:…`.
- **von Sokrates (461c):** zu 444: Schmiedelehrling startet auch mit Stumpfe Waffen (`werte.json`), neu rechnen.
