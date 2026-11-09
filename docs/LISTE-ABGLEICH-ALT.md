# Abgleich alt: Kapitel 1 der alten Fassung je Ort und je Figur (620.2)

Vorgang 620.2 (Chef 07.11., 14:3x zu 620; 621 D ja, 16:4x: „Abgleich alt einmal je Ort und Figur statt je Build“). Gelesen aus dem alten Code von einem Helfer am 07.11., 21:1x, gesammelt von Perikles. **So wird sie benutzt:** jeder Ort und jede Figur wird **einmal** gegen diese Liste in Godot geprüft; je Zeile in der Spalte „Godot“ ein Wort: **da**, **fehlt** (wird ein Vorgang im eigenen Vorrat), **anders** (mit Grund) oder **entfällt** (nur mit Chefwort, z. B. BRS statt SRD). Bis eine Zeile geprüft ist, gilt für ihren Ort weiter der Abgleich je Build (512, 512b). Die Liste ist Grundlage jeder Prüfliste: was hier „da“ ist, steht in keiner Testbitte mehr als neu. Keine 1:1-Kopie (`LISTE-UMZUG-348.md` „Grundsätze“): verglichen wird, was da ist, nicht jede Drehung einer Fichte.

**Wer prüft** (nach `CLAUDE.md` „Rollen“): **Tom** 1.1–1.6 (Dorf, Innenräume) und alle Leute in 2; **Spike** (Team Tom) 1.7 und 1.8 (Wald); **Jerry** 1.9 (Höhle: Gegner, Licht, Klang; Grundriss mit Tom, 492), 1.10, jede Zeile „Klang“ und „Gegner“ in allen Orten, Krogg, Grak, Grimmzahn. Wer eine Zeile prüft, trägt die Spalte nach und pusht; Diogenes zählt den Stand.

Nur belegte Punkte; Spieltexte nicht abgeschrieben, nur genannt (Schlüssel `[…]` oder Thema). Koordinaten (x/y) sind Kacheln der alten Karte (Ursprung oben links), aus den Kartenzeilen in `Story.kt`.

Quellenkürzel (Pfade ab `core/src/main/kotlin/de/bornim/core/`):
- **S** = `Story.kt` · **G** = `Game.kt` · **W** = `World.kt` · **VD** = `VillageDay.kt` · **MP** = `MapPeople.kt` · **MM** = `MapMarks.kt` · **J** = `Jobs.kt` · **R** = `Resting.kt` · **H** = `Hail.kt` · **IL** = `Interlude.kt`
- **A/** = `art/` · **AU/** = `audio/` (z. B. `A/MapFolk.kt` = `art/MapFolk.kt`)
- **UI** = `app/src/main/java/de/bornim/game/ui/WorldScreen.kt` (Zeilen dort ungefähr, Blockanfang)

Lesehilfe: Tag 7–19 Uhr, Dämmerung 19–21, Nacht 21–5, Morgen 5–7 (`G:118-127`); „Nacht“ = Licht unter 0,35. Die `draft`-Schalter von Katze, Hund, Hühnern, Ruhebewegungen, Teichleben stehen auf `true`, sind also im Spiel (`A/MapCat.kt:9`, `MapDog.kt:9`, `MapHen.kt:18`, `MapRest.kt:24`, `PondLife.kt:18`). Blendensprüche der Figuren (lange Blende, 16 Sprüche, Aldric zuerst): `IL:324-354`; Blendensätze je Ort `IL:27-90`.

---

## 1. Orte

### 1.1 Dorf Bornim, Gesamtkarte (`village`, 36 × 32, Art Stadt)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Name, Art | „Bornim“, Kartenart TOWN, Startort des Helden ist das Gasthaus (8/2), Wiederbelebung im Tempel (4/4) | S:133-136, S:88-89 | |
| Ausgänge | Nord: zwei Pfadkacheln (17/0), (18/0) in den Flüsterwald (9/30 bzw. 10/30), erst nach `QUEST_STARTED`, sonst spricht Jorin („Halt“, Haus des Ältesten unten links) | S:172-173, S:270-273 | |
| Ausgänge | Süd: sechs Kacheln (15-20/31), Kapitel 1 gesperrt, der Held kehrt um (`turnBack`) mit Gedanke je Stand (4 Stände, erstes Mal lang, danach kurz); Schild (19/29) „Rabenschanze / Schilfrode“ | S:174-175, S:281-296, S:196-197 | |
| Ausgänge | Türen: Gasthaus (6/5), Kramladen (28/5), Ältesten-Haus (5/20), Tempel (28/20); Tür wird per Aktionsknopf von vorn betreten (nicht begangen) | S:176-179, G:1019-1025, G:613 | |
| Wege | Hauptstraße N–S (x 17-18) vom Schlagbaum bis zur Brücke, Querwege (Zeilen 8 und 23), gepflasterter Dorfplatz (Kopfstein), Pfade zu den Haustüren | S:138-169 | |
| Schlagbaum | Balken über der Nordstraße (17/2), (18/2); geschlossen unpassierbar, Hinweis „Schlagbaum unten“ (ohne/mit Auftrag verschieden); nach `BARRIER_OPEN` passierbar; Öffnen spielt Türgeräusch; gezeichneter Balken mit Drehpfosten, offen/zu | W:57-58, G:31-32, G:1116, G:1162, A/MapTownIso.kt:1182 | |
| Zaun am Schlagbaum | Zaunstücke (16/1), (19/1), (16/2), (19/2); Laternen beidseits (15/2), (20/2); Schild (21/2) „Norden: Flüsterwald, Goblins“ | S:139-141, S:194 | |
| Laternen, Fässer, Bänke, Wäsche | Laternen (15/2), (20/2), (12/11), (23/11), (12/17), (23/17), nachts mit Lichtkegel; Fässer (9/5), (9/6), (31/5); Bänke (14/16), (21/16); Wäscheleine (8-10/11); je eigener Antworttext | S:140, 143, 149, G:1061-1068, A/MapTownIso.kt:823, 958 | |
| Kaels Laterne | alte Handlaterne auf Steinsockel neben Kaels Tür bei (24/6), Familienzeichen (Raute mit Balken), nachts schwaches Bernsteinlicht; Verweis auf Aschfurt (Kap. 2) | A/MapTownIso.kt:849-915 | |
| Brückenlaterne | Laterne an der Südecke der Brücke, nachts leuchtend | A/MapTownIso.kt:934-943, 1472 | |
| Brunnen | (16/16) auf dem Dorfplatz (Verschiebung wegen Sicht, 348.6), Steinring, Text „alter Brunnen, klares kaltes Wasser“; Gwenna morgens hier | S:131-132, G:1054, A/MapTownIso.kt:734, VD:23 | |
| Marktstände | vier Kacheln (14/12), (15/12), (20/12), (21/12) = zwei Stände mit Tuchdach; drei Warenvarianten (Äpfel/Gemüse, Stoffe/Wolle, Kräuter/Pilze) je nach Kachel | G:1056-1060, A/MapTownIso.kt:772-810 | |
| Anschlagbrett | (4/7) vor dem Gasthaus; Aktionsknopf öffnet die Auftragstafel; Brett zeigt einen frischen blassen Zettel, solange ein ungelesener Auftrag hängt | W:17-18, G:1047, J:1-10, 123, A/MapTownIso.kt:646 | |
| Aufträge am Brett | vier: Wolfsfelle (Thessa), Gwennas Ring (Gwenna), Keilerhauer (Borin), danach nach Krogg: Giftdrüsen (Morwen), Feuer am Steinkreis (Jorin); Annehmen, Abgeben, Zurücklegen; Abgabe beim Auftraggeber | J:43-101, G:1137, J:140 | |
| Schilder | Gasthaus (7/6) „Zum Schlafenden Greif“, Kramladen (25/6) „Waffen · Rüstungen · Tränke“, Wegweiser (21/2), (19/29); gezeichneter Wegweiser | S:193-199, A/MapTownIso.kt:611 | |
| Hofdinge | (2/5), (13/9), (11/11), (28/13), (7/24), (22/27): Holzstapel mit Hackklotz und Axt, Handkarren (leer/Säcke/Heu), Eimer/Waschzuber, Fischernetz, je drei Varianten | W:63-64, A/MapTownIso.kt:975-1180 | |
| Felder | Gemüsebeete mit Zaun (4-8/29-30), Kornfeld (21-31/29-30), Heuballen (33/28), (33/29), (11/30); Texte „Korn steht hoch“, „Kohl und Möhren“, „Heuballen, Hühner scharren drumherum“ | S:166-168, G:1063-1065, A/MapWoodIso.kt:1321 | |
| Fluss und Brücke | Wasserband Zeilen 25-27, Holzbrücke (17-18/26-27) mit Geländer (Pfosten an den Ecken); Fluss rauscht, am lautesten auf der Brücke; Wasserglitzern, nachts Lichtspiegelung der Laternen; Gwenna wäscht hier, Pim spielt hier | S:163-165, A/MapTownIso.kt:945, AU/RiverSound.kt:1-10, A/WaterLife.kt, UI:867 | |
| Häuser (Dächer) | neun Hausstile (Gasthaus mit Wirtshausschild, Kramladen mit Markise, Tempel mit Glockenturm, sechs Wohnhäuser); Rauch aus Schornsteinen; nachts helle Fenster, bei verschlossenen Häusern geschlossene Läden | S:200-210, A/MapTownIso.kt:72-290, 1430, UI:2105 | |
| Türklopfen | fünf verschlossene Wohnhäuser, Aktionsknopf = Klopfgeräusch + Stimme von innen, je nach Tag/Nacht/Kapitelstand: Bäcker (12/5, Edrik), Kael (23/5), Gwenna (5/14), Schmied Dorran (30/13), Pim (13/22); danach trägt die Karte den Hausnamen | S:180-191, 264-268, G:1020-1024, MP:157-168 | |

Leben und Tiere im Dorf

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Hühner | je Heuballen bis zu zwei, drei Gefieder (weiß/braun/dunkel); picken, scharren, schauen, laufen um; rennen flatternd weg, wenn der Held naht, bei Regen und Dämmerung (Licht ≤ 0,3) ziehen sie sich unter die Bäume zurück; Gackern, Scharrgeräusch, Alarm, Flügel | A/MapHen.kt:12-15, 473-500, UI:1313, AU/HenSound.kt:1-30, S:242 | |
| Hund | zotteliger brauner Dorfhund, schläft nacheinander an drei Plätzen im Osten (24/10), (30/7), (19/9), setzt sich, wedelt, streckt sich, trabt auf festen Wegen zum nächsten Platz | A/MapDog.kt:1-7, 143-146, UI:1299 | |
| Vögel | kleine Vögel auf Gras und Pfad (etwa jede 23. Kachel), hüpfen, fliegen bei Nähe auf (Flügelgeräusch, Scharren im Gras); nur am Tag, nicht bei Regen, nicht im Tiefen Wald | A/MapBirds.kt:1-30, AU/WildSound.kt:76-122 | |
| Schmetterlinge, Glühwürmchen | Schmetterlinge über Blumenkacheln am Tag (nicht im Regen); Glühwürmchen nur manche Nächte, Schwärme über Feldern, Wiesen, Ufer | UI:1662, 1889 | |

Tag/Nacht, Klang, Funktionen im Dorf

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Tagesablauf der Leute | s. Abschnitt 2 (Pim, Bram, Gwenna, Liska gehen ihren Tag; Jorin patrouilliert) | VD:16-26 | |
| Tag/Nacht | Licht nach Tageszeit (Dämmerung warm/violett, nachts kalt mit Mond, Laternen, Fensterlicht); Sonnenschatten in drei Ständen; Vögel nur tags, Grillen nachts; Hühner ziehen sich bei Dämmerung zurück | A/MapLight.kt:1-20, A/MapSun.kt:1-15, A/MapGrade.kt:1-10 | |
| Klang | Wind als Dauerton; Vögel am Tag, Grillen nachts; Hühner; Fluss; Regen; Schritte nach Boden (Gras, Erde, Pflaster, Holz, Stein); Musik: drei Dorfstücke („dorf_minstrel_dance“, „dorf_lament“, „dorf_small_fire“), ein Stück, dann 10-30 s Stille | AU/PlaceSound.kt:12-30, AU/WildSound.kt:21-37, AU/Music.kt (MusicLib.village), AU/Footsteps.kt:1 | |
| Kartenmenü | Gezeichnete Ortskarte (Tinte/Aquarell auf Pergament); Marken: Aufträge, Leute, Dienste (Gasthaus, Kramladen, Tempel, Lagerfeuer, Anschlagbrett), Hausnamen in Handschrift nach Besuch/Klopfen; Marken erinnern, führen nicht | MM:1-60, MP:1-30, A/MapInk.kt:1-10 | |

### 1.2 Gasthaus „Zum Schlafenden Greif“ (`inn`, 10 × 8, Innenraum)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Ausgang | Tür (4/7) unten, in das Dorf bei (6/6) | S:304-314 | |
| Einrichtung | Kamin (3-4/0), vier Fenster; Regale (1-2/1); Fass (6/1), (1/5); Bett (7/1)–(7/2) (nur hier ein „Zimmer für Gold“); Tresen (1-3/3); Tische (3/4), (6/4), (7/4); Bänke (6-7/5); Teppich (3-5/5-6); Kisten (8/1), (8/6); Kram (5/1), (8/3), (4/4), (8/5) (Bett: Chef 06.11., 604 „Bett raus“) | S:304-313, G:1067-1071, A/MapRoomIso.kt:619-1290 | |
| Hocker Borin | Hocker unter Borin (8/4), sein Hammer angelehnt am Tischende | A/MapRoomIso.kt:2134-2138 | |
| Katze | rote Katze, schläft nacheinander am Kamin (5/2), am Fass (1/4), in der Raummitte (6/3); wacht auf, streckt sich, geht auf festen Wegen um Tresen und Tische (Teppich, nie durch den Tisch) und legt sich neu | A/MapCat.kt:3-6, 139-150, UI:1289 | |
| Dienste | Rowena am Tresen: Met trinken (Preis 2 Gold, ab dem 5. betrunken), Zimmer (5 Gold) = lange Rast, rohes Fleisch verkaufen; Bett im Raum öffnet die Zimmer-Rast; nach Kapitel 1 Met gratis (außer nach Lyras Wort vom Lager) | S:317-344, R:12-60, G:1071 | |
| Klang | keine Menge, aber: Rowena wischt (Wisch-Ton), schenkt ein (Gieß-Ton), Borin stellt Flasche ab, Stuhl rückt, Husten, Holzknarren selten; Kaminknistern lauter beim Herangehen; gedämpfter Raumklang | AU/PlaceSound.kt:12-95, AU/Ambience.kt:1-5, AU/Room.kt:1-6 | |

### 1.3 Thessas Kramladen (`shop`, 9 × 7)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Ausgang | Tür (4/6), Dorf (28/6); Dorftür (28/5) | S:177, 368-382 | |
| Einrichtung | Kamin (2-3/0), vier Fenster; Warenregale (4-6/1), Werkzeugregal (7/1) mit Axt, Schaufel, Heugabel, Sense (3. Variante Speer, Bogen, Schild); Tresen quer (2-5/3) mit Waage und Münzen, Kassenbuch und Laterne, Stoffballen und Schere; Fässer (1/2), (1/3); Kisten (7/4), (1/5); Kram (7/3), (7/5) | S:372-381, A/MapRoomIso.kt:1742-1945 | |
| Dienst | Thessa verkauft Tränke etc. (8 Vorratsposten) und Ausrüstung (zufällig, passend zur Klasse, erneuert alle 8 Siege und je Stufe, immer eine Fackel) | S:109, 384-390, Loot.kt:177-195 | |
| Aufträge | Wolfsfelle (60 Gold) von Thessa am Brett | J:45-54 | |
| Blendentext | fünf Zeilen („Türglocke schlägt an“, „riecht nach Leder, Öl, Staub“ …) | IL:64-70 | |

### 1.4 Haus des Ältesten (`elder`, 9 × 6)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Ausgang | Tür (4/5), Dorf (5/21); Dorftür (5/20) | S:394-409 | |
| Einrichtung | Kamin (4-5/0), fünf Fenster; zwei Betten nebeneinander (1-2/1-2), Lehnstuhl (3/1), Wandbehang (6/1) (Sonne von Bornim / Wald-Teppich / Karte mit Zetteln), Schreibpult (7/1) mit Tinte und Kerze, Truhen (7/2), (1/3), Teppich (3-5/3-4); Aldrics Stock angelehnt (allein / mit Umhang / im Eimer), Bücherbord | S:398-406, A/MapRoomIso.kt:1320-1745 | |
| Handlung | Aldric gibt den Hauptauftrag (Blutzahn-Stamm, Lyra, Sonnenamulett), 2 Heiltränke, 50 Gold; später Übergabe des Amuletts, Brief des Grauen Propheten, Ring des Schutzes, 200 Gold; Nacht, Tempelszene, Morgen im Tempel | S:437-480, 411-422 | |
| Blendentext | fünf Zeilen („Aldric blickt vom Pult auf“, „Kerzenwachs und alte Bücher“ …) | IL:57-63 | |

### 1.5 Tempel des Morgenlichts (`temple`, 9 × 7)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Ausgang | Tür (4/6), Dorf (28/21); Dorftür (28/20) | S:482-498 | |
| Einrichtung | fünf Fenster; Kerzenständer (2/1), (6/1); Altar breit (3-5/1) (Tuch weiß/rot/kahl, Sonne auf Ständer, leere Halterung bis zur Rückkehr des Amuletts); Lesepult (5/2); Bankblöcke (2-3/3-4), (5-6/3-4); Weihwasserbecken (3/5) | S:486-495, G:1072-1075, A/MapRoomIso.kt:1946-2086 | |
| Dienste | Osric heilt (TP und ZP voll) gratis; Respawn-Ort des Helden | S:499-512, S:89 | |
| Klang | Hallton als Dauerton (stille Halle) | AU/PlaceSound.kt:25-33 | |
| Blendentext | sechs Zeilen, eine nur nach `QUEST_STARTED` ohne `LYRA_RESCUED` („Altar wirkt leer“) | IL:79-90 | |
| Szene Amulett | Nach Kapitel 1: Tempelszene mit fünf gemalten Bildern (Kerzenflackern, Staub im Lichtstrahl), Musik „Ancient Legend“; danach Morgen im Tempel, Lyra spricht vom Lager im Süden (setzt `CAMP_TOLD`) | S:417-435, TempleLife.kt:1-25, AU/Music.kt (amuletReturn), Intro.kt | |

### 1.6 Hütten

Wohnhäuser im Dorf: kein Innenraum, nur verschlossene Tür mit Stimme (1.1 „Türklopfen“, `S:180-191`). Morwens Hütte: siehe 1.8.

### 1.7 Flüsterwald (`forest`, 20 × 32, Art Wald, Stufe 1)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Wege/Ausgänge | Süd (9/31), (10/31) zurück nach Bornim; Nord Höhleneingang (10/0) in die Blutzahnhöhle (10/18); Ost-Ast von (13/10) bis zum Kartenrand (19/10) in den Tiefen Flüsterwald (1/18); Hauptpfad nord-süd | S:528-571 | |
| Schilder | (11/28) „Flüsterwald, bleib auf dem Weg“; (12/1) „BLUTZAHN-HÖHLE …“ | S:572-575 | |
| Lagerfeuer | (11/9) in Steinring, Garricks Lager; Rast hier („Rasten?“: kurz 1 Std. = ¼ TP und volle Ausdauer, lang 8 Std. = alles, einmal je Spieltag); Rauchsäule, Funken, Feuerknistern lauter beim Näherkommen, warmer Rand auf Figuren | S:542, R:1-14, G:1050, UI:2141-2200, AU/Ambience.kt | |
| Truhen | (16/4) Ausrüstung mind. ungewöhnlich, (16/15) 2 Heiltränke, (2/24) 40 Gold | S:576-580 | |
| Steinkreis | vier stehende Steine (15/24), (13/25), (17/25), (14/27) = Fundort von Jorins grauem Stofffetzen (Auftrag „Feuer am Steinkreis“) | S:557-560, J:154-162 | |
| Anderes | umgestürzte Stämme (15-16/2), (3-4/19); Felsen (3/7), (14/8), (15/22); Teich (2-5/13-16) mit Libellen am Tag, Fröschen am Ufer (springen ins Wasser, klettern zurück), Froschrufe, Chor in der Dämmerung | S:534-564, A/PondLife.kt:1-15, AU/PondSound.kt:1-10 | |
| Kräuter | Blumenwiesen mit Heilkräutern (hellgrün), etwa die Hälfte der Blumenkacheln trägt Kraut, Einsammeln durch Darüberlaufen (1-3 Stück, Perk-Zusatz), wächst nach Sonnenaufgang nach | G:46-47, 737-759 | |
| Tiere/Leben | Schmetterlinge, Vögel am Tag, fallende Blätter, Glühwürmchen nachts, Eulen und Grillen nachts | UI:1662-1760, AU/WildSound.kt:21-37 | |
| Gegner | sichtbare Streuner (7) und Hinterhalt im hohen Gras (Chance 0,004 je Schritt); Tabelle Tag (Ratte, Wolf, Goblin, Bogenschütze, Wildschwein, Kobold, Hundertfüßer, Stirge) und Nacht (u. a. Skelett, Zombie, Fledermaus); Verhalten Jäger/Wanderer/Lauerer | S:599-611, Roamers.kt:1-55 | |
| Sicherheitszonen | um Garricks Feuer (Radius 4, mit Fackelwarnung), um Süd-Eingang, Höhleneingang, Ostweg; Monster geben dort auf | S:613-618, G:869 | |
| Nebel | Wald wird erst durch Sehen aufgedeckt (Sichtkegel, Dunkelheit verkürzt), Karte merkt Erkundetes | G:575-585, Fog.kt, MM:259 | |

### 1.8 Tiefer Flüsterwald (`deep_forest`, 44 × 38, Stufe 2) mit Morwens Hütte

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Wege/Ausgänge | West (0/18) zurück in den Flüsterwald (18/10); Hauptpfade; Südast zu Morwens Lichtung | S:623-672 | |
| Schild | (3/19) „Tiefer Flüsterwald, hier endet der Weg der Jäger“ | S:674-677 | |
| Morwens Hütte | Strohdach, Plankenwände, Hütte (23/27); Tür (23/28) verschlossen (`LOCKED`, Ausgang führt vor die Tür); Tür liegt nach Süden zum Feuer hin; kein Innenraum | S:667-673, A/MapTownIso.kt:1398-1404, 1536 | |
| Morwens Feuer | (23/30), Rauch blasser und leicht grün; Sicherheitszone Radius 4 mit Hinweis „beißender Kräuterrauch vertreibt die Biester“; Bäume darüber bis zur höchsten Krone | S:727-730, UI:2141-2150, A/MapFlora.kt:78 | |
| Truhen | (37/7) selten, (9/32) 2 Heiltränke, (39/31) 120 Gold, (27/4) sehr selten | S:678-683 | |
| Steinkreis | vier Steine (6/14), (10/14), (5/16), (11/16) | S:642-644 | |
| Gegner | Streuner 13; Tabelle Tag (Wolf, Wildschwein, Kobold, Spinne, Goblins, Schamane …), Nacht plus Untote, Ghul | S:714-725 | |
| Boss | Grimmzahn (Leitwolf, nur einmal), Kampf auslösen durch Ansprechen; danach ruhiger, Wölfe heulen weiter ferne | S:706-712, AU/WildSound.kt:1-6 | |
| Klang | keine Vögel, nur Wind, nachts Grillen, fern Wolfsgeheul (nachts alle 1-2½ Min., tags seltener) | AU/WildSound.kt:42-66 | |
| Blendentext | fünf Zeilen („Kein Vogel singt mehr“, „Kronen schließen sich“ …) | IL:43-49 | |

### 1.9 Blutzahnhöhle (`cave`, 22 × 20, Art Höhle, Stufe 3)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Ausgang | Höhlenausgang (10-11/19) zurück in den Wald (10/1) | S:761-764 | |
| Aufbau | Südhalle, Seitenflügel West/Ost, Gitter (10-11/5) in der Mitte (`GATE`), dahinter Graks Halle (10/2); Holzstützen (10-11/6, 12, 17) | S:739-760 | |
| Gitter | Aktionsknopf: mit „rostigem Schlüssel“ (Kroggs Beute) öffnet es sich (Schlüssel verbraucht, Ton), sonst „verschlossen“; Ziel-Hinweise im Menü je Stand | G:1118-1127, Monsters.kt:127-130, S:833-843 | |
| Licht | Fackeln (6/1), (15/1) (lebendige Flamme, Funken); Leuchtpilze (2/7), (7/8), (2/9), (3/11), (3/15) mit Sporen; Kristalle (3/6), (6/6) violett; Tageslichtschacht (16/7) mit Staub; Lagerfeuer der Goblins (16/15) (Rauch gerade nach oben, kein Rasten: „viel zu gefährlich“) | S:739-760, G:1050, UI:2307-2440 | |
| Dinge | Knochen, Schutt, Stalagmiten, Pfütze/Teich (2-3/13-15), Schlaflager (14/13-14), Kisten (19/13-14), Tropfen mit Ringen am Boden | S:739-760, UI:2229-2268 | |
| Truhen | (3/8) 2 große Heiltränke, (18/8) Ausrüstung selten, (4/14) klassenpassende Waffe; in `cave_3` liegt Gwennas Ring, sobald der Auftrag angenommen ist (auch bei schon geleerter Truhe) | S:765-769, G:1090-1096, J:35-37, 150 | |
| Gegner | Krogg (16/9, einzigartig) mit Hinterhalt-Fähigkeit, Beute: rostiger Schlüssel; Grak (10/2) hinter dem Gitter; Streuner 6 (Goblins, Untote, Fledermaus, Ratte, Spinne, Ocker-Glibber); Auslöser (10/4), (11/4) lassen Grak zum Kampf antreten | S:770-810, 800-802, Monsters.kt:126-145 | |
| Gefangene | Lyra in Ketten bei (8/1) bis Graks Tod; Schlüssel öffnet, Segen (voll heilen), 2 Weihwasser, geht aus der Halle zum Tunnel und ist weg | S:780-798, A/MapFolk.kt:421 | |
| Blendentext | fünf Zeilen | IL:50-56 | |

### 1.10 Ortsübergreifend

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Übergänge, Musik, Wetter | schwarze Blende mit Ortssatz (5-6 Varianten, Nacht-Satz fürs Dorf); Musik je Szene (Dorf/Wald/Höhle je 3-7 Stücke, Kampf 6, Boss 3, Sieg, Kapitelende „ende_new_sunrise“, Tempelszene „boss_ancient_legend“); Höhle mit 10 Dauertönen, Hall, Tropfen, Grollen; Wald mit Wind, Eulen/Grillen; Regen, Böen, Blitzschein, Spuren | IL:25-90, AU/Music.kt:40-70, AU/Ambience.kt, AU/WildSound.kt, AU/Room.kt, UI:2720, Tracks.kt:1 | |
| Einleitung/Ende | Intro (5 Bilder, Ankunft bei Nacht, Fackelzug), Kapitelende-Text | Intro.kt:1-25, IntroLife.kt, S:845-848 | |

---

## 2. Figuren

Für alle sprechenden Figuren: Aktionsknopf = ansprechen; sie drehen sich zum Helden und schauen ihn bis 3 Kacheln an (nach 10 s Stillstand verloren); goldenes Zeichen + kurzer Ruf (Mann/Frau/Kind) + Geste, wenn sie Neues haben (Text geändert oder Auftrag abgebbar); Ruhebewegungen (Atmen, Gewicht, Blick, Hand zum Gürtel); Ansprechen setzt `met_<id>` (Karte merkt Namen und Gewohnheiten). Quellen: `G:495-560`, `H:1-68`, `A/MapRest.kt:1-10`, `A/MapFolk.kt:855-875`.

Gesten bei Neuem (`A/MapFolk.kt:216-229`): Hand (Normalfall; Bram), Segen (Osric), schüchtern (Gwenna), Winken (Pim), Heranwinken (Thessa), kurz (Jorin), langsam (Morwen), Nicken (Lyra, Garrick, Liska), Stab heben (Aldric), Krug heben (Rowena), Becher heben (Borin). Karten-Gewohnheiten der Leute: `MP:115-134`.

### Aldric (Ältester, `elder`, Haus des Ältesten (7/3))

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen/Requisit | alt, hager, weißer Bart, weißgraues Haar, Robe Pflaume, dunkler Umhang, Stab quer auf der Schulter (trägt ihn auch im Gehen) | A/MapFolk.kt:46-48 | |
| Gesten | Neues: Stab von der Schulter heben | A/MapFolk.kt:218 | |
| Gespräch/Quest | Hauptauftrag (Blutzahn-Stamm, Grak, Lyra, Sonnenamulett; 2 Heiltränke + 50 Gold; Jorin öffnet den Schlagbaum); Zwischenstände (Höhle im Norden; Grak tot ohne Lyra); Übergabe mit Amulett und Brief des Grauen Propheten, Ring des Schutzes, 200 Gold; Einladung zur Tempelzeremonie; danach Lager im Süden | S:437-480 | |

### Rowena (Wirtin, `inn`, Tresen (1/2))

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | kräftig, Ärmel hochgekrempelt, braune Wolle, helle Schürze | A/MapFolk.kt:44-45 | |
| Gesten/Bewegungen | wischt den Tresen (Tuch kreist), schenkt aus Krug ein; steht dicht am Tresen (Abstand-Anpassung); Geste bei Neuem: Krug heben | A/MapFolk.kt:431-466, 82-93, 218 | |
| Klang | Wisch- und Gießgeräusch passend zur Bewegung | A/MapFolk.kt:964-979, AU/PlaceSound.kt:48-60 | |
| Gespräch | Stand 1: Aldric wartet; Stand 2: Osric im Tempel heilt; Stand 3: Lager im Süden; sonst Bier aufs Haus; vor dem Tresen bietet sie Fleisch zum Verkauf | S:324-343 | |
| Dienst | Met, Zimmer, Fleisch kaufen | R:12-60 | |
| Einführung | Eröffnungsrede im Gasthaus (Lyra entführt) | S:352-357 | |

### Borin (Zwerg, `inn`, am Tisch (8/4))

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | Zwerg, kräftig, Schmiedeleder, Handschuhe, Hammer auf der Schulter (am Tisch abgelegt) | A/MapFolk.kt:73-75, A/MapRoomIso.kt:1146 | |
| Bewegungen | sitzt am Tisch auf Hocker: Hände auf Tisch, trinkt aus Flasche, isst, schaut sich um; zufällig, nie im Takt | A/MapFolk.kt:95-205 | |
| Klang | Becher abgestellt, Stuhl rückt | A/MapFolk.kt:980-986 | |
| Gespräch | Wuchtwaffen gegen Skelette, heiliges Licht gegen Untote (ein Tipp) | S:345-350 | |
| Quest | Auftrag Keilerhauer (3, 50 Gold) vom Brett | J:66-76 | |
| Geste | Becher heben | A/MapFolk.kt:220 | |

### Thessa (Händlerin, `shop`, hinter dem Tresen (4/2))

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | mittelgroß, wohlhabend, Tunika Rost/Ocker, gute Stiefel, Reiseumhang | A/MapFolk.kt:49-51 | |
| Laden | Begrüßung, Warenliste (8 Verbrauchsgüter plus generierte Ausrüstung), Abschiedswort | S:384-390, Loot.kt:177 | |
| Quest | Wolfsfelle (5, 60 Gold) | J:45-54 | |
| Geste | Heranwinken | A/MapFolk.kt:224 | |
| Plan | Liska besucht sie gegen 10 Uhr | VD:25 | |

### Osric (Bruder, `temple`, vor dem Altar (4/2))

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | kahl, Robe ungefärbte Wolle, Sonne auf der Brust | A/MapFolk.kt:52-54 | |
| Dienst | Heilung gratis (TP und ZP voll); vor Lyras Rettung bittet er um ihre Rettung | S:499-512 | |
| Geste | Segenshand | A/MapFolk.kt:221 | |

### Lyra (Schwester, Höhle (8/1) in Ketten; später Tempel (6/2))

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | schlank, weiße Robe, Stirnreif | A/MapFolk.kt:55-57 | |
| Höhle | Ketten an der Säule bis Grak fällt; ruft „Hier drüben“; Schlüssel öffnet Ketten, Segen heilt voll, 2 Weihwasser; geht dann zum Hallenausgang und ist weg (`LYRA_GONE`) | S:780-798, 829 | |
| Tempel | sichtbar erst nach `LYRA_RESCUED`; Dank, Auftrag: Amulett zu Aldric; nach Zeremonie: Lager im Süden (`CAMP_TOLD`); später Traum vom Grauen Propheten | S:513-522 | |
| Geste | Nicken | A/MapFolk.kt:226 | |

### Jorin (Wache, Schlagbaum)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | kräftig, Kettenhemd, Helm, blauer Wappenrock, Speer auf der Schulter | A/MapFolk.kt:58-60 | |
| Bewegung | Patrouille (15/3)→(17/3)→(20/3)→(18/3), bleibt an Wegpunkten stehen; mit Speer: stützt ihn bei längeren Halten auf; Geste kurzes Heranwinken | S:213, A/MapRest.kt:132, 159 (Speer aufstützen), UI:1100-1115 | |
| Besonderer Ablauf | Ohne Auftrag: lässt niemanden hinaus; nach Auftrag: öffnet den Schlagbaum (Seil löst, Balken schwingt, Türgeräusch), Tipp zu Gras; nach Kapitel: dankt | S:214-227 | |
| Quest | Steinkreis-Auftrag (Fetzen mit Auge; Lohn Kopfschutz) | J:90-101 | |

### Pim (Kind, Dorf)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | klein (Größe 0,62), Kittel zu groß, Graublau | A/MapFolk.kt:61-63 | |
| Tagesablauf | 7 Uhr Platz (15/14) streunen; 12 Uhr heim (13/23); 13 Uhr Fluss (17/24); 17 Uhr Platz; 20/21 Uhr heim, ab 21 Uhr im Haus (nicht gezeichnet) | VD:17-19 | |
| Gespräch | Feuer gegen Goblins; Alchemistenfeuer bei Thessa; nach Kapitel: will auch Held werden | S:229-236 | |
| Geste | schnelles Winken; Ruf Kind | A/MapFolk.kt:223, H:53 | |
| Haustür | (13/22) „Pim schläft“ nachts | S:190 | |

### Bram (Bauer, Südfeld (20/29))

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | breit, sonnenverbrannt, Bart, grobes Leinenhemd, Erdbraun | A/MapFolk.kt:64-66 | |
| Tagesablauf | 5 Uhr Feld (20/29); 12 Uhr Platz (14/15); 13 Uhr Feld Ost (32/29); 19 Uhr Gasthaus-Vorplatz (7/8); 22 Uhr Zaun (10/29) | VD:20-21 | |
| Gespräch | Korn, Wölfe holen Hühner; Fleisch am Feuer braten macht stark; nach Kapitel: Hühner schlafen ruhig | S:237-244 | |

### Liska (Magd, Dorf)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | schlank, Kleid verblichenes Rot, helles Kopftuch | A/MapFolk.kt:67-69 | |
| Tagesablauf | 6 Uhr fegt vor dem Gasthaus (8/7); 10 Uhr bei Thessa (25/8); 11 Uhr hängt Wäsche (10/12); 15 Uhr (8/10); 22 Uhr vor Gasthaus; 23 Uhr drinnen | VD:25 | |
| Gespräch | Wäsche, Thessas Ware, Markt am Brunnen, Kräuterstände; nach Kapitel Gerücht | S:245-252 | |
| Geste | Nicken | A/MapFolk.kt:226 | |

### Gwenna (Fischerin, Dorf)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | mittel, Kleid Schlammgrün, Schal/Umhang | A/MapFolk.kt:70-72 | |
| Tagesablauf | 6 Uhr Brunnen (16/15); 9 Uhr Fluss waschen (8/24); 16 Uhr Markt (14/13); 20 Uhr Haustür (5/15); 22 Uhr im Haus | VD:23 | |
| Gespräch | nachts am Fluss fischen, Wölfe; nach Kapitel: „Held von Bornim“ | S:253-259 | |
| Haustür | (5/14) Mann kam nicht zurück; nachts eigener Satz | S:185-187 | |
| Quest | Ring-Auftrag (Truhe in der Höhle, 40 Gold + Heiltrank), Zettel am Brett | J:56-65 | |
| Geste | schüchtern, zögernd | A/MapFolk.kt:222 | |

### Garrick (Jäger, Wald (10/9) am Feuer)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | breit, kurzer Vollbart, Kapuze, dunkler Olivumhang, dunkles Leder, Langbogen quer über dem Rücken | A/MapFolk.kt:25-36 | |
| Bewegungen | wärmt die Hände (reibt), späht in den Wald (Hand über den Augen), hockt sich ans Feuer (schürt Glut; nachts länger und nickt ein), steht beim Herannahen auf; wehrt Biester an der Sicherheitszone mit einer Fackel ab | A/MapFolk.kt:495-560, 568-720, 889-952, S:614 | |
| Gespräch | Erstes Gespräch: Feuer, Riesenratten/Wölfe/Goblin-Späher, rasten am Feuer, 2 Heiltränke; sofort der Krogg-Hinweis (Schlüssel, Ostflügel, Morwen als Hilfe, Warnung unter Stufe 3); später dasselbe bis Krogg tot; danach „Rast gebrauchen“ | S:53-64, 583-597 | |
| Geste | Nicken | A/MapFolk.kt:226 | |

### Morwen (Kräuterfrau, Tiefer Wald (25/30) vor ihrer Hütte)

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Aussehen | alt, schlank, graues Haar unter Kapuze, Robe Moosgrün | A/MapFolk.kt:76-78 | |
| Gespräch | Erstkontakt: Kräuter sammeln, Rauch, Grimmzahn im Norden, Heilmittel geschenkt; Rauchbündel gegen Kroggs ersten Hieb (einmalig, nur nach Garrick und vor Krogg-Tod); Kräuterhinweise; nach Grimmzahn ruhiger | S:66-74, 685-705 | |
| Laden | Tränke (5 Posten) und Brauen aus Kräutern (Heiltrank 2 Kräuter 5 G, Kräutertrank 2 Kräuter 2 G, großer Trank 3 Kräuter + Fledermausflügel 15 G, Alchemistenfeuer 1 Drüse 5 G) | S:44, Recipes.kt:13-19 | |
| Quest | Giftdrüsen (3, 50 G + 2 Kräutertränke) nach Krogg; Zettel am Brett | J:78-89 | |
| Geste | langsames Heranwinken | A/MapFolk.kt:225 | |

### Weitere Figuren und Namen

| Punkt | was alt da ist | Quelle | Godot |
|---|---|---|---|
| Krogg | Grottenschrat „Krogg der Grobian“ (16/9), Boss; Hinterhalt-Fähigkeit (schlägt zuerst, Rauchbündel verhindert den ersten Hieb), Sprüche vor dem Kampf; lässt rostigen Schlüssel + Ogerhandschuhe fallen | S:771-778, Monsters.kt:126-131, art/HeroBattle.kt:418 | |
| Grak | Hobgoblin-Hauptmann (10/2), Boss hinter dem Gitter; Kampf wird auch durch Betreten von (10/4), (11/4) ausgelöst; lässt Sonnenamulett, Brief, Graks Schlüssel, Streitaxt fallen | S:779, 800-802, 822-830, Monsters.kt:139-144 | |
| Grimmzahn | Leitwolf (22/4), Boss im Tiefen Wald, nur sichtbar vor dem Tod; Amulett, Wolfsfell, Fleisch als Beute | S:706-712, Monsters.kt:132-138 | |
| Kael | alter Mann, nur als Hausname (23/5), Laterne neben Tür; Spruch auf Blende | A/MapTownIso.kt:849, IL:348 | |
| Edrik | Bäcker, nur als Hausstimme (12/5) und Blendenspruch | S:182-183, IL:350 | |
| Dorran | Schmied (30/13), nur Hausstimme und Name (Schmiede kalt nachts) | S:188-189 | |

---

## 3. Lücken der Liste (nachprüfen beim Abgleich)

- Jorins „Wachfeuer“ nachts steht nur als Text in `MP:123`; kein Feuer im Code gefunden. Karte: `MP:122` „Wache am Schlagbaum“.
- Fallen: keine im Kartencode gefunden. Ziegen- und Kaninchentöne (`AU/Sfx.kt:26-27`) sind aufgenommen, eine Verwendung wurde nicht gefunden.
- Tag/Nacht je Figur: nur Pim, Bram, Gwenna, Liska haben einen Tagesplan (`VD:16-26`); alle anderen stehen fest (Jorin patrouilliert immer, auch nachts).
- Nur überflogen: `A/MapRest.kt`, `A/MapFoe.kt`, `A/MapFollow.kt`, Kampfdateien. Soll-Stand (beschlossen, aber alt nicht gebaut): `LISTE-FIGUREN.md` „neu“, `STORY-K1-WELT.md`.
- Zeilenangaben `UI:…` sind Blockanfänge, auf etwa 10 Zeilen genau.

## 4. Stand Jerry (620.2b, 08.11., 00:5x; Helfer am Code von `main` mit 478, nur gelesen)

Statt der Spalte „Godot“ je Zeile hier gesammelt:
- **1.9 Höhle:** auf `main` fehlt die Gebietskarte (kein `cave.bin`, „Grundriss folgt“), Kapitel 1 nicht zu Ende spielbar; gebaut in `claude/tom-492-hoehle` (492), Kampforte in `claude/jerry-507-hoehle` (507). Logik da: Gitter, Ziel-Hinweise, Rastverbot am Goblinfeuer, Blendentext, Kisten, Gwennas Ring, Krogg- und Grak-Auslöser. **Anders:** Truhe cave_3 gibt „@class_weapon“ als Ding (632, Tom); Lyras Abgang fehlt auf `main` (in 492); Untote fehlen als Gruppe (506); Kampf im Waldkampfort (507); Schlüsselton nicht gefunden.
- **1.10:** da: Ortsblende, Musik je Szene, Hall, Tropfen, Grollen, Wind, Eulen, Grillen, Intro, Kapitelende. **Fehlt:** Regen, Böen, Blitz (598); Spuren nur als Regelcode (416.6).
- **Klang 1.1–1.8:** da: Wind, Vögel, Grillen, Hühner, Fluss, Schritte, Dorfmusik mit Stille, Tempelhall, Tiefer Wald mit fernem Wolf. **Fehlt:** Regen (598); Rowena und Borin: Wischen, Gießen, Becher, Stuhl (634); Frösche und Libellen am Teich (509).
- **Gegner 1.7, 1.8:** Streuner, Tabellen, Schutzzonen da; Skelett, Zombie, Ghul nachts fehlen (506).
- **Krogg, Grak, Grimmzahn:** Bosse, Auslöser, Sprüche, Rauchbündel, Schlüssel, Amulett, Brief, Leibwache da. **Fehlt:** Ogerhandschuhe, Graks Streitaxt, Grimmzahn-Amulett als Beute, Boss-Ausrüstung (`boss=false`, 633).

## 5. Stand Tom (620.2a, 08.11., 06:2x; zwei Helfer am Code von `claude/tom-625-nacht` = Build 269, nur gelesen; Klang und Gegner siehe 4)

Statt der Spalte „Godot“ je Zeile hier gesammelt:
- **1.1 Dorf da:** Start Gasthaus, Wiederkehr Tempel, Nordausgang mit Jorins Abweisung, Südrand mit 4 Ständen, Türen per Knopf, Wege, Schlagbaum zu/offen mit Text, Zaun, alle Laternen mit Licht (auch Kaels und die Brückenlaterne), Fässer, Bänke, Wäsche mit Texten, Brunnen, Marktstände (3 Waren), Brett mit Tafel und Aufträgen aus `Jobs`, Schilder, Hofdinge (3 Ansichten), Felder mit Texten, Fluss und Brücke mit Glitzern und Spiegelung, Hausstile, Rauch, Fensterlicht, Türklopfen mit Stimme und Hausname, Hühner fliehen, Schmetterlinge, Glühwürmchen, Tagesablauf, Licht nach Tageszeit, Kartenmenü mit Marken. **Anders/fehlt:** kein Türgeräusch am Schlagbaum (636, gebaut); Brett ohne frischen Zettel (637; „Zurücklegen“ war alt nicht erreichbar, `JobList` ohne Aufruf); Schlagbaum schwang auch alt nicht (nur zu/offen); keine geschlossenen Läden (640); Hund, sichtbare Vögel, Rückzug der Hühner fehlen (638); Regen gibt es nicht (598, Jerry).
- **1.2–1.5 Innenräume da:** Einrichtung, Dienste (Met 2 Gold, Zimmer, Fleisch), Thessas Laden, Aldrics Handlung bis zum Kapitelende, Osric heilt, Tempelszene, Blendentexte. **Anders/fehlt:** Bett in der Schenke steht noch (604); Katze fehlt (638); Werkzeugregal nur als Waffenständer, ein Wandbehang statt drei, Stock in einer Fassung, Altartuch immer weiß, leere Amulett-Halterung nur im Text (640).
- **1.6 Hütten:** da (verschlossen mit Stimme).
- **1.7, 1.8 Wald da:** Gebietskarten, Ausgänge, Schilder, Lagerfeuer, Rast, Truhen, Steinkreis, Teich, Kräuter, Schutzzonen, Morwens Hütte, Grimmzahn. **Anders/fehlt:** Höhle nicht gebaut (492); Nebel und erkundete Waldkarte (505); Libellen und Frösche (509, Jerry); fallende Blätter (638); Morwens Rauch nicht grünlich (640).
- **Leute da:** Aussehen, Gespräche und Stände aller Figuren, Tagesabläufe (Pim, Bram, Liska, Gwenna), Jorins Runde, Rowenas und Morwens Dienste, Garricks Gespräch mit Rast, Hausstimmen. **Fehlt/anders:** Lyra wird nie gebaut, steht nicht im Tempel (635); Gesten zu „!“ und Ruf, Rowenas Wischen und Einschenken, Borin sitzt, trinkt, isst nicht, Garricks Ruhebewegungen (475, 531); Jorins Speer, Aldrics Stab quer (639), Garricks Langbogen und Fackel (531); Gwennas Ring, Krogg, Grak nur mit der Höhle (492); Blende ohne Figurensprüche (267.1, so gebaut).
