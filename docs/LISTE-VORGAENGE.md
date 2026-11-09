# Vorgänge

**Die eine Vorgangsliste** (275.2, Chef 07.11., 21:5x): je Vorgang eine Zeile mit festen Feldern; Vorräte `ARBEIT-*.md` haben keine Tabelle mehr, nur Übergabe, Pause und „Zu <Nr>“. **Nicht ganz lesen:** die eigenen Zeilen zeigt `python3 tools/vorgang.py --rolle <Rolle>` (Bedingung des Chefs 27.10.: keine 1000 Tokens extra), eine Nummer `vorgang.py <Nr>`. **Schreiben nur mit `tools/vorgang.py`** (`neu`, `stand`, `warte`, `setze`, `rang`, `fertig`, `build`; Hilfe ohne Argument); von Hand geändert warnt die Commit-Prüfung.

- **Reihenfolge** der Zeilen eines Besitzers = Vorrang (`vorgang.py rang`). **Besitzer:** Homer, Tom, Jerry, Perikles, Diogenes, Sokrates, Ford, Ideen (wird nie gestartet). **Kl.** (126): M Muss, K Kür, M? (Perikles entscheidet), – abgeschlossen.
- **Stand** (275): ein Wort aus offen, startbar, in Arbeit, wartet, Chef, ruht, gebaut, zu testen, Dauer, nach Meilenstein, aufgeteilt, Idee, erledigt; dahinter nach Komma höchstens ein kurzer Zusatz (bei „gebaut“ Pflicht: „Geprüft an: <Link, Lauf oder Commit>“, 340.4).
- **wartet auf** (Automatik A): Nummer, Rolle, Datum `TT.MM.[ HH:MM]` oder `Chef[ <Dateinummer>]` (nur mit Datei in `docs/chefsache/`), mit Komma getrennt. Nummer erledigt, Datum vorbei oder Chefsache-Datei weg: `startbar.py` meldet „GELÖST“, `lauf.py --sperre` setzt die Zeile auf startbar und meldet es der laufenden Sitzung des Besitzers. Ist die Nummer erst gebaut oder zu testen, hält sie nicht auf (190.1), das Feld bleibt aber stehen, bis sie erledigt ist. Eine Rolle löst sich nicht von selbst: die Zeile steht bei ihr als Arbeit, bis sie das Feld mit `vorgang.py warte <Nr> –` leert.
- **Zweig** `claude/…`; **Build** die Nummer des Testbuilds, der den Vorgang trägt (`vorgang.py build <n> --mit <Nr,…>`); nach dem Test des Chefs schließt `vorgang.py build <n>` ab (Automatik B: bestanden → erledigt, ✗ → startbar mit dem Fund, ohne Rückmeldung → zu testen).
- **Bereich** (124): E Entwicklung, G Gestaltung, Q Qualität, B Betrieb, M Markt. **Kosten** in $ (`usage.cost_usd`, ab 17.10.): bucht Ford (`lauf.py --kosten`).
- Erledigte Zeilen schiebt `lauf.py --aufraeumen` ins [Archiv](LISTE-VORGAENGE-ARCHIV.md).

| Nr. | Titel | Besitzer | Kl. | Stand | wartet auf | Zweig | Build | Bereich | Kosten |
|---|---|---|---|---|---|---|---|---|---|
| 656 | Umhang Kämpfer mit Beulen, große Beule unter dem Schwertarm: woher, weg (Chef 08.11., 14:52, schon zu 623.5 gefragt, Antwort verloren; 16:44 wieder auf den Siegerposen 296.3) · wiederholt | Tom | M | Chef, Film 23:48 (Lauf 311) | Chef 656 | claude/tom-656-umhang | – | E Figuren | 12,65 $ |
| 670 | Build 269: Menü des Helden (Held, Tasche, Ausrüstung, Karte, Chronik, System) noch im alten Design statt 557/549a; Zweig tom-557-einschalten war im Build? (Chef 08.11., 15:32) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 664 | Halbes Haus: Haus des alten Kael und Hütte der Kräuterhexe im tiefen Flüsterwald nur halb da (Chef 08.11., 15:28, mehrfach gemeldet, nie eingetragen) · wiederholt | Tom | M | gebaut, fährt im nächsten Build. Geprüft an: 3bc19a09f (Bild passt, Chef 👍 16:42) | – | claude/tom-664-haeuser | – | E Welt | 8,06 $ |
| 635 | Lyra fehlt als Figur im Tempel und in der Höhle: Kennung lyra_temple/lyra_cave, gebaut wird nur „lyra“ (Abgleich 620.2a) | Tom | M | zu testen, ohne Rückmeldung t270 | – | claude/tom-635-lyra | – | E Welt | – |
| 581 | Ausrüstung: Seite breiter als der Schirm, Reiter springen (Abgleich 512b) | Tom | M | startbar, Fund t269.16 | – | claude/tom-581-ausruestung | – | E Oberfläche | 2,31 $ |
| 583 | Textkasten: ▼ liegt im Text, erzählter Text ohne i-Punkte und nicht schräg (Abgleich 512b) | Tom | M | startbar, Fund t269.3 | – | claude/tom-583-textkasten | – | E Oberfläche | 5,99 $ |
| 584 | Kein halbfetter Schnitt: Köpfe und Titel in Erschaffung, Held, Chronik, Karte, System, Brett, Test nicht hervorgehoben wie alt (Abgleich 512b) | Tom | K | in Arbeit, gebaut 0fcdd69d5, Bild nach Lauf | Sokrates | claude/tom-584-halbfett | – | E Oberfläche | 23,80 $ |
| 585 | Menüs Kleinigkeiten: Titelumbruch Hauptmenü, Knopf Lizenzen, Bild in Rückfrage Wegwerfen, Test „Variante“ (Abgleich 512b) | Tom | K | gebaut, fährt im nächsten Build. Geprüft an: c304c5842 (Bild ansehen/585, Chef 21:55) | – | claude/tom-585-kleinigkeiten | – | E Oberfläche | – |
| 569 | Baumkronen ohne erkennbare Tuschelinie, „ein einziger Brei“ (Chef 04.11., 19:44, Bild 558 Probe 4) | Tom | M | startbar, Lauf frei 16:28 | – | – | – | E Oberfläche | – |
| 568 | Ernten als Handlung statt Einsaugen; Angeln mit Pose und Ring (Chef 04.11., 19:42: ja, A) | Tom | K | ruht | – | – | – | E Oberfläche | – |
| 531 | Build 249: Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertreibt Tiere sichtbar mit der Fackel, Ruhebewegungen (Chef 03.11., 23:42) | Tom | M | in Arbeit, Ursachen nachgestellt (Zu 531) | 643 | claude/tom-531-film | – | E Oberfläche | 12,96 $ |
| 522 | Build 249: Ausrüstung im Testmenü geändert (Schild gegeben), Held im Spiel ohne Schild (Chef 03.11., 23:33) | Tom | M | startbar, Fund t269.12 | – | claude/tom-522-waffen | – | E Oberfläche | – |
| 521 | Build 249, Ausrüstung: Wechselschirm eines Platzes wie alt (Bild, Art und Wert, ▲/▼, „nicht tragbar“ matt) (Chef 03.11., 23:23, Bild) | Tom | M | startbar, Fund t269.16 | – | claude/tom-521-tasche | – | E Oberfläche | – |
| 540 | Texte hängen am Spielbeginn: Südrand (immer Text vor dem Auftrag, „Kapitel 2 folgt“ fehlt, nichts gemerkt), Schlagbaum nach dem Auftrag, Klopfen an 12/5 nach Kapitel 1, Tipp beim Erwachen auch bei klassischer Steuerung… | Tom | M | startbar, Fund t269.3 | – | claude/spike-540-starttexte | – | E Oberfläche | – |
| 542 | Aufträge: Jorins „Feuer am Steinkreis“ nicht abschließbar (Fetzen fehlt), Gwennas Ring am Brett ohne Höhle nicht findbar, Aldrics Ring als Ding statt Einzelstück (Abgleich 512, Sokrates 03.11., 23:4x) | Tom | M | gebaut, Geprüft an: f9111b5c2 (auf main; Jorin erst nach Krogg wie alt) | – | claude/tom-542-testwolf | – | E Oberfläche | – |
| 543 | Startwerte gegen alt und BRS prüfen: Startgold 15–25 und Start-Heiltränke fehlen, Wiederkehrort Schenke statt Tempel, Beute im Tiefen Wald Stufe 1 statt 2 (Abgleich 512, Sokrates 03.11., 23:4x) | Tom | M | zu testen, ohne Rückmeldung t269 | – | claude/spike-543-startwerte | – | E Oberfläche | – |
| 495 | Zufallsspieler spielt Kapitel 1 in Godot durch (Abnahme 2.2; Wochenziel 03.11., 488) | Tom | M | wartet | 492 | – | – | E Technik | 27,75 $ |
| 505 | Bau Nebel des Krieges und Sichtfeld des Helden (Archiv 502; Welt W24, W25) | Tom | M | startbar | 492 | – | – | E Technik | 69,46 $ |
| 515 | Truhen: 3–4 je Karte halb versteckt, verschlossene nach BRS (Dietrich, Aufbrechen) (Chef 03.11., 16:07) | Tom | K | ruht | – | – | – | E Welt | – |
| 506 | Untote im Kampf: Skelett, Zombie, Ghul (aus 494, Spike; Wochenziel 03.11., 488) | Tom | M | in Arbeit, Balken behoben, Rest aus dem Helferbefund offen (Zu 506) | Sokrates | claude/tom-506-skelett | – | E Kampf | 42,52 $ |
| 492 | Blutzahnhöhle begehbar mit Krogg, Grak, Lyra (Orte O8; Wochenziel 03.11., 488; von Jerry an Tom, Chef 07:54) | Tom | M | startbar, B (Chef 21:46), Lager offen | – | claude/tom-492-durchspiel | – | E Technik | 81,67 $ |
| 431 | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, dann Körperbau je Volk (Chef 31.10., 22:0x) | Tom | M | ruht | – | claude/tom-431-voelker | – | E Figuren | 50,10 $ |
| 416.8 | NPC dreht sich zum Helden mit kleinen Schritten, nicht auf der Stelle (Chef 31.10., 20:5x; t269.11 15:44 wieder Plastikfigur) · wiederholt | Tom | M | gebaut, fährt im nächsten Build. Geprüft an: 98af8d5cc (gier ±90 am Rechner, schauen_4168) | – | claude/tom-4168-wende | – | E Technik | 19,24 $ |
| 376.1 | Probeblatt Quaternius-Figuren mit Bewegungsraster als Film (Chef kaufte 27.10., 12:20) | Tom | M | ruht | – | claude/spike-376-1-tracht | – | E Figuren | 221,15 $ |
| 455.1 | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 11:24) | Tom | M | ruht | – | claude/spike-455-1-baukasten | – | E Figuren | 30,05 $ |
| 513 | Ein Figurenstand für alle Zweige; Schild, Robe Magier, Umhang jetzt (Chef 03.11., 15:56, „513 B“) · „jetzt“ 03.11., 15:56 | Tom | M | ruht | – | claude/figurenstand-513 | – | E Figuren | 14,01 $ |
| 470 | Bau BRS 1.1 Erschaffung (Wochenziel 02.11., Stufe 1) | Tom | M | ruht | – | claude/spike-470-erschaffung | – | E Kampf | 43,23 $ |
| 570 | Theke: Wahl „Fleisch verkaufen · 12 Gold“ liest sich wie ein Preis (Prüfer 557 Runde 4) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 470.1 | Erschaffung: Held auf Antippen bildschirmgroß (Idee Chef 02.11., 18:37) | Tom | K | ruht | – | – | – | E Oberfläche | – |
| 471 | Bau BRS 1.2 Fertigkeiten durch Tun (Wochenziel 02.11., Stufe 1) | Tom | M | startbar, gelöst 08.11.: 478 | – | – | – | E Kampf | – |
| 474 | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, Meldung Tuffy): nächster Build einmal deinstallieren; dauerhaft ohne Cache | Tom | M | ruht | – | – | – | E Technik | 8,66 $ |
| 475 | Leute des Dorfs (Rowena, Borin …) auf Kaufkörper ihres Volks mit Gesicht, statt der alten Figuren (Chef 02.11., 10:52, Build 146: „Kommt da noch was?“) · „jetzt“ 04.11., 00:53 | Tom | M | startbar | Sokrates | – | – | E Figuren | 64,38 $ |
| 476 | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | Tom | K | wartet | 458.3 | – | – | E Oberfläche | – |
| 477 | Godot-APKs laufen nicht im MuMu Player am Rechner (Chef 02.11., 14:59) | Tom | K | wartet, ein Lauf Emulator (tom-477-emulator.yml) | Sokrates | claude/tom-477-mumu | – | E Technik | – |
| 461.1 | Grundstand zusammenführen: ein Zweig für Tom und Jerry, jede Probe baut darauf (01.11.) | Tom | M | ruht | – | claude/grundstand-461 | – | E Technik | 30,19 $ |
| 458.3 | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | Tom | M | ruht | – | claude/spike-458-3-staffel | – | E Figuren | 12,15 $ |
| 423.1 | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | Tom | K | ruht | – | – | – | B Werkzeuge | – |
| 455.2 | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völker (Chef 01.11., 11:27, 455 ja) | Tom | M | ruht | – | claude/spike-455-2-groesse | – | E Figuren | – |
| 385 | Protofactor-Animsets (Zauberer u. a.) auf die Listen, Probe ob nutzbar (Chef 27.10., 20:59) · „jetzt“ 28.10., 10:00 | Tom | M | ruht | – | – | – | E Figuren | 40,87 $ |
| 372 | Feinschliff Held am Ende des Umzugs: Kettenhemd, Helm, Kragen (aus 338a B, Chef 27.10., 09:36) | Tom | M | ruht | – | claude/tom-348-fundament | – | E Figuren | – |
| 348.13 | Tusche nach Licht wie entschieden (Chef 26.10.) | Tom | M | ruht | – | – | – | E Technik | 89,13 $ |
| 348.13b | Tusche auch nach Fackeln, Feuer, Fenster; zuerst Dorf (Chef 28.10., 08:09 ja) | Tom | M | ruht | – | claude/tom-34813-kampfprobe | – | G Stil | – |
| 267 | Spiel ruckelt auf dem Tablet (Chef 20.10., Build 48) | Tom | M | ruht | – | – | – | E Technik | –; +13,77 $ |
| 302.3 | Intro und Outro mit Tusche im Zeichner, etwas kräftiger als Intro 4 (Chef 23.10., 10:45) | Tom | M | ruht | – | claude/tom-3023-kraeftiger | – | G Stil | –; +6,40 $ |
| 302.2 | Tusche auf der Gebietskarte (Chef 22.10., 23:50); zurückgestellt (Chef 23.10., 10:45) | Tom | K | ruht | – | claude/tom-3022-tuschebild | – | G Stil | – |
| 302.1 | Tuschelinie für Menschengestalten (Chef 22.10., 20:25, über Sokrates); jetzt nicht (Chef 23:37); M seit 338 (b), Charaktererstellung | Tom | M | ruht | – | claude/tom-3021-tusche | – | G Stil | – |
| 292.4 | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., 15:10) | Tom | K | ruht | – | claude/tom-2923-titelmodus | – | G Stil | – |
| 356.2 | Sammelaufträge: Felle 3, Pelzumhang, Hauerdolch (356 b, Chef 24.10., 21:33) | Tom | K | gebaut, fährt im nächsten Build. Geprüft an: a483cdeea (brett_test, katalog_test lokal) | – | claude/tom-3562-auftraege | – | G Balance | – |
| 30 | Abstürze beim Testen | Tom | K | ruht | – | – | – | Q QS | – |
| 145 | Karten je Kapitel zum Drucken | Tom | K | ruht | – | claude/tom-145-kartenmappe | – | E Welt | 6,22 $ |
| 417.1 | Restmängel Tragart nach „417 passt“ (Schildabstand, Rumpfdrehen, Fußrutschen, Kornfeld, Stabgang) | Tom | K | ruht | – | claude/tom-417-tragart | – | E Figuren | – |
| 558.1 | Prüferrest Robe Probe 5 nachhalten, nicht bauen; Chef sieht es nach dem Durchspielen an (Chef 04.11., 22:23) | Tom | K | ruht | – | claude/tom-558-robe | – | E Figuren | – |
| 447.4.1 | Bau Lehrmeister, Meisterschaften, Ruf Kapitel 1 (447.4) | Tom | M | wartet | 508 | – | – | G Story | – |
| 589 | Dorf: Marktplatz wirkt geklont (gleiche Stände, gleiche Säcke), Durchgang links am Stand hakelig (Chef 05.11., 19:2x, t266) | Tom | M | startbar | – | – | – | E Welt | – |
| 590 | Innenräume: Türseite bei gedrehter Kamera dunkel und tot, mehr Licht (Kerzen) und Einrichtung (Chef 05.11., 19:2x) | Tom | M | startbar | – | – | – | E Welt | – |
| 591 | Dorftiere (Hühner, Kaninchen) fliehen vor dem Helden wie alt, mit Alarmklang (Chef 05.11., 19:2x) · „jetzt“ 06.11., 08:07 | Tom | M | gebaut, C nur Klang (Chef 18:27). Geprüft an: f22334feb | – | claude/tom-591-laut2 | – | E Welt | 3,68 $ |
| 617 | Hauptmenü „Laden“: Wischen löst Laden aus; laden nur mit dem Knopf rechts (Chef 07.11., t268.1) | Tom | M | startbar, Fund t269.16 | – | claude/tom-605-doppeltipp | – | E Oberfläche | – |
| 610 | Held im Dorf: Finger am Stab zucken ohne Unterlass (Schild auf dem Rücken) (Chef 07.11., t268) | Tom | M | startbar, Fund t269.12 | – | claude/tom-610-finger | – | E Figuren | – |
| 630 | Restliche Schirme im Stil „ohne Kasten“ (549a): Laden-Fenster und Rückfragen, Menü, Brett, Anleitung, Über das Spiel, Erschaffung (Liste aus 618, Sokrates 07.11.) · „jetzt“ 07.11., 22:28 | Tom | M | gebaut, passt (Telegram 18:14), fährt im nächsten Build. Geprüft an: Lauf 302 | – | claude/tom-630-schirme | – | E Oberfläche | 8,06 $ |
| 612 | Dorf Süd: Heuhaufen geklont und wie aufgespießt, Wackelgras im Weizenfeld, Gemüsebeet mit Leerstreifen; drei Varianten je Ding (Chef 07.11., t268) | Tom | M | startbar | – | – | – | E Welt | – |
| 614 | Leute lebendig wie alt: Jorin mit Speer, Jorin öffnet den Schlagbaum sichtbar; Abgleich der Requisiten und Gesten (Chef 07.11., t268) | Tom | M | startbar | – | – | – | E Figuren | – |
| 622 | Godot-Build als AAB für Play: dieselbe App `de.bornim.game`, mit dem Upload-Schlüssel des alten AAB, höhere Versionsnummer (Sokrates 07.11., aus 142.4) | Tom | M | startbar | – | – | – | M Veröffentlichung | – |
| 41.2 | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | Tom | K | wartet | 41 | – | – | G Story | – |
| 586 | Schirme 557 einheitlich: Zeichen neben der Überschrift bei Rast, Größe der Überschriften (Chef 05.11., 09:35, Kür) | Tom | K | gebaut, fährt im nächsten Build. Geprüft an: 3d56c4077 (Bild ansehen/586, passt 21:55) | – | claude/tom-586-rast | – | E Oberfläche | – |
| 134 | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | Tom | K | aufgeteilt | – | – | – | E Figuren | 1,06 $ |
| 348.1 | Vergleichsbild Gebietskarte alt/neu, 64 (heute) und 128 je Kachel (Chef 24.10., 16:51, „jetzt“ 16:54) | Tom | M | ruht, ohne Vorratszeile, Liste „raus“ (275.2) | – | – | – | E Technik | – |
| 348.2 | Tusche nach Licht auch am Helden, Innenlinien an Bäumen: zweites Vergleichsbild jetzt (Chef 24.10., 17:30, 17:36) | Tom | M | ruht | – | – | – | E Technik | – |
| 531a | Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast kaufen? (Chef 04.11., 19:27) | Tom | M | ruht, ohne Vorratszeile, Liste „wartet“ (275.2) | – | – | – | E Oberfläche | – |
| 431c | Rückfrage: Völker Runde 4 am Tor angehalten, neue Läufe frei? | Tom | M | ruht, ohne Vorratszeile, Liste „Chef“ (275.2) | – | – | – | E Figuren | – |
| 431d | Rückfrage: Völker Lauf 3 am Tor angehalten (B1 Elf, C3, G3, A1/A3 Grak, A2), neue Läufe frei, Weg A2? | Tom | M | ruht, ohne Vorratszeile, Liste „Chef“ (275.2) | – | – | – | E Figuren | – |
| 431e | Rückfrage: Gesicht des Helden im Dorflicht fast weiß, Hauteichung nach Messung? | Tom | M | ruht, ohne Vorratszeile, Liste „Chef“ (275.2) | – | – | – | E Figuren | – |
| 632 | Truhe der Höhle (cave_3, 4/14) gibt „@class_weapon“ statt der Waffe der Klasse wie alt (Story.classWeapon, Game.kt 1108); von Jerry, Abgleich 620.2b | Tom | M | gebaut, Geprüft an: ca508b846 (truhe_632 lokal), fährt mit der Höhle (492) | – | claude/tom-632-truhe | – | E Welt | – |
| 636 | Schlagbaum öffnet ohne Türgeräusch (alt G:1162 Sound.DOOR; Abgleich 620.2a) | Tom | M | startbar, A (Chef 09.11., 06:55): Geräusch fehlt trotz Satz | – | claude/tom-636-schlagbaum | – | E Welt | – |
| 637 | Anschlagbrett: frischer blasser Zettel, solange ein ungelesener Auftrag hängt (A/MapTownIso.kt 646, J:123; „Aufgeben“ war alt nicht erreichbar: JobList ohne Aufruf; Abgleich 620.2a) | Tom | M | startbar | – | – | – | E Welt | – |
| 638 | Kleinleben wie alt: Dorfhund, Katze in der Schenke, sichtbare Vögel, fallende Blätter im Wald, Hühner ziehen sich in der Dämmerung zurück (Abgleich 620.2a) | Tom | M | startbar | – | – | – | E Welt | – |
| 639 | Leute tragen ihre Dinge wie alt: Jorins Speer, Aldrics Stab quer auf der Schulter (Garricks Langbogen: 531; Abgleich 620.2a) | Tom | M | startbar | – | – | – | E Welt | – |
| 640 | Innenräume und Häuser, Varianten wie alt: Werkzeugregal, Wandbehänge und Stock bei Aldric, Altartuch, leere Amulett-Halterung; geschlossene Läden, Morwens Rauch grünlich (Abgleich 620.2a) | Tom | M | startbar | – | – | – | E Welt | – |
| 649.3 | Figurenkatalog: Bewohner, Händler, Lehrmeister, Söldner füllen (Tagesablauf, Laden, Stimme, Gang, Klänge, Bewegungen, Text-Marken; aus 649) | Tom | M | startbar | 649.2 | – | – | E Figuren | – |
| 644.4 | Gegenstandskatalog: Ladenbestand und Rezepte aus texte.json und Kotlin in den Katalog umstellen (644 A, Ablösung) | Tom | M | startbar | 644.1 | – | – | E Welt | – |
| 653 | Halt für Waffen und Schilde einmal je Modell festlegen statt je Figur nachmessen: Griffpunkt je Gegenstand, Halterung je Körper, eine Anlegefunktion, Prüfbild aller Kombinationen (Chef 08.11., 14:35) | Tom | M | startbar, ja (Chef 14:40), Jerry stellt den Kampf um | – | – | – | E Figuren | – |
| 661 | Blende zwischen Orten an Schirme ohne Kasten angleichen: Schrift größer, Zierleiste wie dort (Chef 08.11., 15:11) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 663 | Klassische Steuerung ausbauen: Steuerkreuz und Funktionstasten ganz raus, nur Touch; Auswahl der Steuerung samt Rückfrage weg (Chef 08.11., 15:24, t269.3) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 665 | Nacht im Dorf: um 2:30 kaum dunkel; in allen Häusern Licht, keiner schläft: tiefe Nacht dunkel, Fenster nach Schlafenszeit aus (Chef 08.11., 15:31, Build 269 auf MuMu) | Tom | M | startbar | – | – | – | E Welt | – |
| 668 | Testmenü an Schirme ohne Kasten angleichen: Zurück, Trennlinien, Aufbau wie 549a/618 (Chef 08.11., 15:32, Build 269) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 673 | Emulator: Kamera drehen und zoomen mit Maus und Tasten (rechte Maustaste ziehen, Mausrad), nur am Rechner, Handy unverändert (Rückfrage Sokrates 08.11., 15:34) | Tom | M | startbar, ja (Chef 15:39) | – | – | – | E Technik | – |
| 678 | Testmenü: Heldenstufe +1 geht über die Kapitelgrenze (Stufe 9 in Kapitel 1), Grenze auch beim Hochstufen im Testmenü einhalten (Chef 08.11., 16:01, Build 269) | Tom | M | startbar | – | – | – | B Werkzeuge | – |
| 683 | Oberfläche noch mit SRD-Wörtern: Gegenstandsfenster und Vergleich zeigen Zauberpunkte, Attribute, Stärke, Konstitution, Weisheit, Charisma statt BRS (Mana, Kraft, Zähigkeit …; Regelwerk Abschnitt 12) (Sokrates nach Bild des Chefs 08.11., 15:57) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 691 | Platzwechsel mit Leuten und Tieren: beide gleiten ineinander (Chef 03.11., 07:44, Test 204.6: „Im Zweifelsfall lassen wir das so“; Zeile nach dem Durchspielen zugesagt, aus 416.2; zurückgeholt 675) | Tom | K | ruht, nach dem Durchspielen (488) | – | – | – | E Figuren | – |
| 687 | Tiefer Flüsterwald: Grimmzahn auf der Karte „steht ganz alleine rum und schaut eher aus wie damals noch aus Kotlin“: Leibwache und Modell prüfen (Chef 03.11., 16:04, aus 491 (5); zurückgeholt 675) | Tom | K | ruht, nach dem Durchspielen (488) | – | – | – | E Welt | – |
| 688 | Frage des Chefs je Karte: wie viel Sammelbares offen und versteckt liegt (alt gegen neu: Truhen, Kräuter, Verstecktes) und ob die Signatur A1–A3 da ist, „für unsere Karten ganz entscheidend“ (Chef 03.11., 16:04, aus 491 (6); unbeantwortet; zurückgeholt 675) | Tom | K | ruht, nach dem Durchspielen (688 A, Chef 18:30) | – | – | – | E Welt | – |
| 689 | Dorf, Urteil Chef 25.10., 12:11 (aus 348.6, offen geblieben): Büsche über Dachfirsten, Laternenpfahl am Steg, Lichtstreifen nachts, Korn wie Gestrüppwiese, Schatten ohne Werfer, Flimmern, Südrand ohne Abschluss; erst prüfen, was in Godot heute noch gilt (zurückgeholt 675) | Tom | K | ruht, nach dem Durchspielen (488) | – | – | – | E Welt | – |
| 697 | Erschaffung: Held im Drehteller halbtransparent (Chef 08.11., 15:23, Build 269; aus 499) | Tom | M | startbar | – | – | – | E Figuren | – |
| 698 | Grafikstufen im Systemmenü mit Effekten (Niedrig/Mittel/Hoch, Automatisch per Leistungstest; LISTE-IDEEN „Grafik-Einstellungen“, Chef 28.10., 08:31; 08.11., 19:46, zu 623) | Tom | K | startbar | 623 | – | – | E Technik | – |
| 699 | Laden: Rückfrage „Alle gewöhnlichen verkaufen“ sagt „1 GEGENSTÄNDE:“ statt Einzahl (Tom, gesehen bei 586, 20:22) | Tom | M | gebaut, fährt im nächsten Build. Geprüft an: 373073b70 (LADEN503) | – | claude/tom-699-einzahl | – | E Oberfläche | 0,26 $ |
| 700 | Erschaffung, Platzwahl „Alle Spielstand-Plätze sind belegt“: Rahmen um jeden Platz gegen 549a (Tom, gesehen bei 586, 20:22) | Tom | M | startbar, passt (Chef 21:50), in den nächsten Build | – | claude/tom-700-platzwahl | – | E Oberfläche | 0,26 $ |
| 701 | Gegenstandsfenster: Hinweis Obergrenze nur einmal statt je Grundwert (Chef t270.5, 08.11., 20:37: „wirkt überbordend“) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 613.2 | Zwischensequenzen: Bewegung sichtbar wie alt (Kerzenflackern, atmendes Licht, Staub im Strahl) und Fackelzug fehlt (Chef 08.11., 21:58 zu 613: „gesehen habe ich nichts“) | Tom | M | startbar | – | – | – | E Oberfläche | – |
| 708 | Zugriff auf bornim-kaufmodelle in Jerry-Sitzungen: add_repo vom Automodus abgelehnt (Jerry 08.11., 21:50; neue Sitzung 22:37 wieder), hält das Nachstellen von 682, 562, 593, 662, 536, 560 an (wie 660 bei Tom) · wiederholt | Jerry | M | Chef | Chef 708 | – | – | E Technik | – |
| 682 | Kampf flüssiger: Held geht zügig zum Angriff, Gegner laufen in weichen Bögen statt eckig gerade-diagonal, weniger Warten auf Hin- und Zurücklaufen bei Fehlschlägen; grundsätzlich für alle Gegner (Chef 08.11., 16:22, t269; „Schienenbahnen“ t270) · „jetzt“ 08.11., 21:36 | Jerry | M | startbar | 708 | – | – | E Kampf | 26,69 $ |
| 702 | Wölfe: Anspringen nimmt dem Helden jeden Zug, Rudel hält ihn dauerhaft fest (Chef t270, 08.11., 21:27: „1 Minute lang zugeguckt … sinnlos“, Balance) · „jetzt“ 08.11., 21:36 | Jerry | M | wartet | Chef | claude/tuffy-702-anspringen | – | E Kampf | 6,49 $ |
| 703 | Ausweichen: Gegner bleibt am Ausweichplatz statt zurückzutappeln, 703 A (Chef t270.12, 08.11., 21:33; ändert DESIGN-KAMPF F5) · „jetzt“ 08.11., 21:36 | Jerry | M | zu testen | – | claude/jerry-703-ausweichen | 271 | E Kampf | – |
| 562 | MARS: Helden laufen zum Angriff viel zu langsam, zurück gleiten sie flott (Chef 04.11., 17:02, t257 C) | Jerry | M | startbar, Fund t270.8 | – | claude/jerry-562-angriffsschritt | – | E Kampf | 17,49 $ |
| 709 | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angreifer prüfen (Chef 08.11., 21:36, über Sokrates) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 560 | Monster auf der Karte drehen sich zum Helden, wenn sie ihn wahrnehmen, mit Schritten statt auf der Stelle (Chef 04.11., 16:22) | Jerry | M | startbar, Fund t270.7 | – | claude/jerry-560-wenden | – | E Figuren | – |
| 662 | Kampf (vorher 653): Parade des Helden mit Schild dreht über _face_sanft ohne Pfotenhalt, Skriptfehler „halt“ Nil, gang bleibt „dreh“ (Jerry 08.11., effekt_mess_6235) | Jerry | M | startbar, Fund t270.9 | – | claude/jerry-653-parade | – | E Kampf | – |
| 536 | Kampf: Erklärungen bei langem Drücken (MarsTips), Grund bei gesperrtem Zauber, „Kein Ziel in Sicht“, Knopf „Schnell“, Stufe und EP im Gruppenkasten, Seltenheitsfarbe der Beute (Abgleich 512, Sokrates 03.11., 23:4x) | Jerry | M | startbar, Fund t270.10 | – | claude/jerry-536-namen | – | E Kampf | 37,47 $ |
| 593 | MARS: Ausweichen auch rückwärts als Abwechslung zu links und rechts (Chef 05.11., 19:2x) | Jerry | M | startbar, Fund t270.12 | – | claude/jerry-593-ausweichen | – | E Kampf | – |
| 406.2 | Angriff gehen statt rennen, Parade mit Schild je Richtung (Chef 03.11., 06:59, Schildfilm) | Jerry | M | startbar, Fund t269.21 | – | – | – | E Kampf | 41,37 $ |
| 704 | Wolf allein ist harmlos, wenn der Held jedem angekündigten Sprung ausweicht: 300 von 300 Siegen, er kann nur springen (Befund Tuffy zu 702, 08.11.) | Jerry | M | startbar | – | – | – | E Kampf | 0,26 $ |
| 705 | Zauberlehrling Stufe 1 gewinnt gegen Wolf und Rudel selten (BRS 2–30 %, Messung anspringen_702; Befund Tuffy zu 702, 08.11.) | Jerry | M | startbar | – | – | – | E Kampf | 0,26 $ |
| 680 | Absturz: Testmenü Sprung Wald → Dorf, in der Schenke schon hakelig, nach Met immer zäher, beim Öffnen des Testmenüs (Sprung in den Wald) Absturz, ohne Fehlerzeile (Chef 08.11., 16:16, 16:18, Build 269, Handy) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 679 | Kampf: im ersten Testkampf (Kleriker gegen Wölfe) fehlten Befehle und Knöpfe (Gewinnen, Verlieren, Raster, Würfelergebnisse), „null Einfluss“; im zweiten Kampf gegen das Wolfsrudel waren sie da: Ursache nachstellen (Chef 08.11., 16:06, 16:07, Build 269) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 565 | MARS: unten im Gruppenkasten sieht man nicht, welcher Held am Zug ist (Chef 04.11., 17:10, t257 C) | Jerry | M | zu testen | – | claude/jerry-565-a | 271 | E Kampf | 13,51 $ |
| 563 | MARS: Zustandsschilder über Gegnern („Blut 3“) überlagern Ansage und Leisten, wirken grob (Chef 04.11., 17:02, t257 C) | Jerry | M | zu testen | – | claude/jerry-563-a | 271 | E Kampf | 13,48 $ |
| 551 | MARS: Rahmen des unteren Kastens links und rechts unterbrochen (Chef 04.11., 00:21) | Jerry | M | ruht | – | – | – | E Kampf | – |
| 547 | MARS: Text sagt „geht in die Knie“, Sturz ist aus (438a eingefroren): Text und Bild in Einklang bringen (Chef 04.11., 00:01) | Jerry | M | zu testen, ohne Rückmeldung t269 | – | claude/jerry-547-sturztexte | – | E Kampf | 5,43 $ |
| 532 | Kampf: Held geht ohne Zauberpunkte, Verbrauchtes, Zustände, Metrausch und ohne die ganze Tasche (nur einfacher Heiltrank) in den Kampf, danach wird nur TP zurückgeschrieben; Zauber kosten nichts (Abgleich 512, Sokrates… | Jerry | M | startbar, Fund t269.25 | – | claude/jerry-532-metrausch | – | E Kampf | 2,28 $ |
| 534 | Kampf: Zauber und Fähigkeiten fehlen in „Können“ (Magierrüstung, Untote vertreiben, Spirituelle Waffe, Geisterwächter) oder wirken nicht (Unglaubliches Ausweichen, Unerbittlichkeit, Lebensraub, Schadensminderung der Aus… | Jerry | M | ruht, 424: altes SRD-System | – | claude/jerry-534-faehigkeiten | – | E Kampf | 2,32 $ |
| 467 | Ausdauer nach BRS statt SRD (ausdauer.gd: Konstitution, Stärke 13), Formel aus 427 (Chef 01.11., 21:52) | Jerry | M | startbar, gelöst 08.11.: 478 | – | – | – | E Kampf | – |
| 438 | Wölfe im Kampf wirken gleitend: Angriff, Tempo, Vorbeigehen (Film 403, Chef 31.10., 23:31) | Jerry | M | startbar, Fund t269.21 | – | claude/jerry-438-wolf-kampf | – | E Kampf | 124,52 $ |
| 453 | Wölfe im Kampfort: Ruhebewegungen (atmen, scharren, umblicken, knurren) (Chef 01.11., 11:05) | Jerry | M | ruht | – | – | – | E Kampf | 47,52 $ |
| 438a | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv 438a) | Jerry | M | ruht | – | claude/jerry-438a-sturz-2 | – | E Kampf | 24,62 $ |
| 416.6 | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef 31.10., 20:4x; 03.11., 07:31) | Jerry | M | ruht | – | claude/jerry-416-6-blut | – | E Technik | – |
| 415 | Handyprobe Beams-Free-Sample (aus 414, Chef 31.10., 20:3x; „jetzt“ 01.11.) | Jerry | M | wartet | 623 | – | – | E Kampf | 49,16 $ |
| 460 | Kamerafahrten im Kampfort: Eröffnung wie Drohnenflug je Blende, Wechsel der Perspektive ohne Eingabe; erst Probefilm (Chef 01.11., 20:2x) | Jerry | M | ruht | – | – | – | E Kampf | – |
| 406.1 | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann Bau (Chef 01.11., 20:2x) | Jerry | M | wartet, Abzug und Block nach BRS, dann Teil 7 neu | 469 | – | – | E Kampf | – |
| 510 | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt (Chef 03.11., 10:28–10:57, aus 494) | Jerry | M | ruht | – | claude/jerry-494-gegner | – | E Kampf | 17,92 $ |
| 509 | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot (Chef 03.11., 09:21; `PondLife.kt`, Projektplan O6, W22) | Jerry | M | ruht | – | claude/jerry-509-teich | – | E Welt | – |
| 494 | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Wochenziel 03.11., 488) | Jerry | M | wartet | 492 | claude/jerry-494-gegner | – | E Kampf | 135,26 $ |
| 517 | Waldklang wie alt: Vögel am Tag, Eule und Grillen nachts, fernes Wolfsheulen im Tiefen Wald (`WildSound.kt`; Abgleich 512, von Team Tom) | Jerry | M | startbar, Fund t269.26 | – | claude/jerry-517-waldklang | – | E Oberfläche | 2,32 $ |
| 507 | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager (Orte O10; aus 492) | Jerry | M | startbar, Bildlauf frei 16:28 | – | claude/jerry-507-hoehle | – | E Kampf | 61,39 $ |
| 496 | Durchspiel-Build: Kapitel 1 von Anfang bis Ende am Handy (Wochenziel 03.11., 488) | Jerry | M | startbar | – | – | – | E Technik | – |
| 387 | Gekaufte Tiere schnell auf Bewegungen und unsere Haut prüfen, vor Eigenbau (Chef 27.10., 21:27) | Jerry | M | ruht | – | – | – | E Figuren | 98,99 $ |
| 385.2 | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | Jerry | M | wartet | 623.2 | – | – | E Kampf | 9,99 $ |
| 397 | Ruhebewegungen wie im alten Spiel, mindestens drei je Figur, für alle (Chef 28.10., 11:15) | Jerry | M | ruht | – | – | – | E Figuren | 19,54 $ |
| 348.12c | Modellpaket auch gegen Geld (Quaternius QAL, Dungeon Monsters Kit, andere), Vorschlag mit Preisen (Chef 26.10., 11:59) | Jerry | M | startbar | – | – | – | G Balance | 52,94 $ |
| 304 | Klassischer Kampf: Konter nach Abwehr, obwohl getroffen, regeltechnisch richtig? (Chef 22.10., 13:22) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 257 | Build 46: Meldung „App reagiert nicht“, warten oder schließen, läuft dann weiter (Chef 20.10.) | Jerry | M | ruht | – | – | – | E Technik | – |
| 211.14 | Rest 211.13: Leistung A56, Puppen-Gegner im Kamerawinkel, Winkel je Platz, Wechsel als Gang | Jerry | M | startbar | – | – | – | E Kampf | – |
| 628 | Lohn: EP und Gold steigen nicht mit der Monsterstufe über der Gebietsstufe (over fehlt, alt Battle.finishWin) | Jerry | M | startbar, gelöst 08.11.: 478 | – | – | – | E Kampf | – |
| 289 | MARS: Wechsel „halber Zug“ missverständlich; Bewegung und Aktion im Kästchen zeigen? (Chef 21.10., 20:11) | Jerry | K | ruht | – | – | – | E Kampf | – |
| 296.2 | MARS spielnötig: Beute/Erfahrung, Fliehen, Eröffnung, Zustände, eigene Ausrüstung, Schalter (Chef 23.10., 18:25) | Jerry | M | startbar | – | claude/build-89 | – | E Kampf | 14,29 $ |
| 296.3 | MARS-Schmuck: Todesschrei, Flucht/Zerfall, Zustände gezeichnet, Siegerpose (Chef 23.10., 18:25) | Jerry | M | zu testen | 656 | claude/jerry-2963-jaulen | 271 | E Kampf | – |
| 344.2 | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | Jerry | K | ruht | – | claude/jerry-344-2-fackel | – | E Kampf | – |
| 168.1 | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | Jerry | K | wartet | 38 | – | – | G Story | – |
| 72u.1 | Umsetzung 72u: Kampfort aus der Karte (Standbild 2, Bau) | Jerry | K | ruht | – | claude/jerry-72u-standbild-2 | – | E Kampf | 2,38 $ |
| 38 | Balance-Langzeitplan (`DESIGN-BALANCE.md`) | Jerry | M | startbar | – | – | – | G Balance | 11,51 $ |
| 39 | Schwierigkeitsgrad im Menü | Jerry | M | ruht | – | claude/jerry-39-schwierigkeit | – | E Kampf | 3,80 $ |
| 59e | Händler: Vorrat je Laden | Jerry | K | ruht | – | claude/jerry-59e-haendlervorrat | – | G Balance | – |
| 469 | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 597 | MARS: Ring ohne Ankündigung (Fledermaus); alle Angreifer prüfen (Chef 05.11., 19:2x) | Jerry | M | zu testen, ohne Rückmeldung t269 | – | claude/jerry-597-ring | – | E Kampf | 2,88 $ |
| 601 | Goblin-Späher: Schuss ohne Bewegung, falscher Pfeil, kein Pfeil beim Fehlschuss; Treffer trotz Schatten (Chef 05.11., 19:2x, t266.5) | Jerry | M | wartet, Pfeil R3 Arrow Streak (LISTE-EFFEKTE), Schussbewegung mit Film | 623 | claude/jerry-601-spaeher | – | E Kampf | 2,88 $ |
| 595 | Kampfbewegungen der Kaufgegner: Spinne mehr Angriffe, Egel und Schnecke schneller, Treffhöhe, Ruckeln, Ruhe (Chef 05.11., 19:2x, t266.1) | Jerry | M | startbar, gelöst 08.11.: 478 | – | – | – | E Kampf | – |
| 623.2 | Effekte aus 623 A einbauen mit 478, in `LISTE-BESTAND.md` und `LISTE-EFFEKTE.md` mit Datenfeld `fx` (Chef 07.11., 623) | Jerry | M | wartet | 623 | – | – | E Kampf | – |
| 598 | Umweltklang je Ort, Tageszeit, Wind und Wetter, lebendige Welt (Chef 05.11., 19:2x; Abnahme 6) | Jerry | M | startbar | – | – | – | E Klang | – |
| 616 | Kampf: Gegner weichen nach dem Angriff rückwärts zurück statt vorwärts zu laufen (Chef 07.11., t268) | Jerry | M | startbar, gelöst 08.11.: 478 | – | – | – | E Kampf | – |
| 24 | Animationen fehlen nach Start/Kartenwechsel; Zwischenbildschirm für Orte und Kämpfe | Jerry | K | ruht | – | – | – | E Oberfläche | – |
| 348.7a | Rückfrage: Geschosse flach oder in 3D | Jerry | M | ruht, ohne Vorratszeile, Liste „in Arbeit“ (275.2) | – | – | – | E Technik | 58,17 $ |
| 399.2d | Godot am Rechner freigeben (Auto-Modus lehnte Download ab), Tests ohne CI-Lauf (aus 399.2) | Jerry | M | ruht, ohne Vorratszeile, Liste „wartet“ (275.2) | – | – | – | E Kampf | – |
| 633 | Boss-Beute wie alt: Ogerhandschuhe (Krogg), Graks Streitaxt, Grimmzahn-Amulett fehlen im Loot; Beute.beute im Kampf mit boss=false (spiel.gd 573); von Jerry, Abgleich 620.2b | Jerry | M | startbar | – | – | – | E Kampf | – |
| 634 | Schenkenklang wie alt: Rowena wischt, gießt, stellt Becher ab, Borin Flasche und Stuhl, im Takt ihrer Bewegung (PlaceSound.folk, MapFolk.sounds; Aufnahmen da); von Jerry, Abgleich 620.2b | Jerry | M | startbar | – | – | – | E Welt | – |
| 642 | Wölfe ineinander beim Anlauf und Biss neben einem ruhenden Wolf, bis 0,15 m (wolf_mess_438 Seeds 1, 3 am Rechner; im Bau misst nur Seed 7), auch mit altem Heldentempo; von Jerry zu 438 | Jerry | M | startbar | – | – | – | E Kampf | – |
| 643 | Langbogen mit Köcher als Waffenmodell (daten/waffen/longbow.bin, Griff = Ursprung, Schaft +Y) für Garrick auf dem Rücken, wie alt (MapFolk.kt: longbow over the quiver; von Tom zu 531) | Jerry | M | startbar | – | – | – | E Welt | – |
| 649.1 | Figurenkatalog Schritt 1: eine Kennung je Monsterart, werte.json und tabellen.json zu BRS zusammenführen (aus 649, Bauplan LISTE-FIGURENKATALOG-649.md) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 649.2 | Figurenkatalog Schritt 2: Werkzeug figuren.py und tools/figuren/figuren.json (Art und Auftritt, Klänge, Bewegungen, Gruppen erzeugt), Seite LISTE-FIGUREN.md; Monster füllen (aus 649) | Jerry | M | startbar | 649.1 | – | – | E Kampf | – |
| 649.4 | Zwei bis drei Handlungen je gewöhnlicher Monsterart vorschlagen und in 444 messen, nur wo eine Bewegung da ist (649 B, Chef 13:28) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 644.1 | Gegenstandskatalog: Werkzeug mit Spalten, Teil Rezepte und Prüfungen (644 A), zusammen mit 649.2; Ablösung held.json, tabellen.json items, beute.gd | Jerry | M | startbar | – | – | – | E Kampf | – |
| 644.2 | Gegenstandskatalog: Zahlen nach 469 in 444 (Tempo, Parieren, Durchschlag, Güte, Stufe), C1 Fertigkeit +1/+2 ab episch ohne Pflicht-Nachteil (Chef 14:32), C2 Seltenheitsdecke je Kapitel in die Regelwerte (644 C) | Jerry | M | startbar | – | – | – | E Kampf | – |
| 681 | Trinkgeräusch in drei Varianten beim Met und anderen Getränken (Chef 08.11., 16:16) | Jerry | M | startbar | – | – | – | E Klang | – |
| Pflege | von Werkzeug (340.3, 09.11.): 15191 Bytes (Grenze 15000), Erledigtes streichen | Jerry | K | startbar | – | – | – | B Abläufe | – |
| 432 | Eigenes Volk aus Bornim (etwa mit dem Grauen Propheten, „Tag der Asche“) prüfen, mit der Geschichte ab Kapitel 2 (Chef 31.10., 22:0x) | Homer | K | ruht | – | – | – | G Story | 0,79 $ |
| 302 | Bildsignatur: ist unsere Grafik wiedererkennbar, wie wird sie es? (Chef 22.10., 12:12); ja 14:15, Probe in 292.3; Bestand 20:25: Figuren zuerst, Umriss schätzt Tom (302.1) | Homer | K | wartet | 302.1 | – | – | G Stil | –; +3,98 $ |
| 41 | Storyplan je Kapitel, Plot Kapitel 2 | Homer | K | ruht | – | – | – | G Story | 4,27 $ |
| 72 | Profil und Marktvergleich | Homer | K | ruht | – | – | – | E Kampf | 0,72; +0,61 $ |
| 348.12g | Gekaufte Monster (Ghul, Untote) zur Geschichte passend? | Homer | M | ruht, ohne Vorratszeile, Liste „entschieden“ (275.2) | – | – | – | G Story | 4,29 $ |
| 586.1 | Von Team Tom: DESIGN-STIL Tabelle „Schrift“ nachtragen: Fenstertitel 22 statt 15 sp (586 passt, Chef 08.11., 21:55) | Homer | K | startbar | – | – | – | E Oberfläche | – |
| 317.1 | `startbar.py`, `lauf.py`: Obergrenze 6 je Build streichen (Chef 07.11., 20:5x) | Perikles | M | gebaut, Geprüft an: 12837c9c3 | – | – | – | B Werkzeuge | – |
| 620.1 | Wiederholte Funde des Chefs vor Neuem; wenige Muss je Team zugleich (aus 620) | Perikles | M | gebaut, Geprüft an: 5b65bf6bb (startbar --stand 11:05: Tom 33, Jerry 12 gesperrt) | – | – | – | B Abläufe | 4,11 $ |
| 511 | Kein Filmlauf ohne geprüftes Probebild vorher (Chef 03.11., 13:47: „Warum werden so viele sinnlose und kaputte Filme gemacht?“) · „jetzt“ 03.11., 13:50 | Perikles | M | gebaut, Geprüft an: d6d9eca8c | Diogenes, D75 | – | – | B Werkzeuge | 19,83 $ |
| 483 | Film-Links: jsDelivr liefert aus Zweig „bilder“ nichts mehr (über 50 MB), je Film eine Marke (Chef 02.11., 19:08) | Perikles | M | gebaut, Geprüft an: 62e922b30 | Diogenes, D75 | – | – | B Werkzeuge | – |
| 464 | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählung im Tagesbericht (Chef 01.11., 20:4x) | Perikles | M | gebaut, Geprüft an: fcf9ab215 | – | – | – | B Abläufe | – |
| 398 | Gegenprobe: Grundsätze aus DESIGN-Dateien, die im Umzug nach Godot fehlen (Chef 28.10., 11:22) | Perikles | M | startbar, gelöst 09.11.: 09.11. | – | – | – | E Technik | 12,07 $ |
| 383 | Wartewächter und Haken 63 verschärfen (Chef 27.10., 17:53 ja); Sitzungsgröße messen (Sokrates) | Perikles | M | gebaut, Geprüft an: 4e1f16df6 | Sokrates | – | – | B Werkzeuge | 99,45 $ |
| 275 | Zentrale Vorgangsliste als einzige Quelle (Chef 21.10.; Stufe 1 jetzt, 27.10.) | Perikles | M | gebaut, Geprüft an: e23a4ccb2 | Diogenes | – | – | B Werkzeuge | 31,69 $ |
| 347.2 | Umsetzung Plan 347 nach Gegenprüfung (Chef 24.10., 16:30) | Perikles | M | wartet | 347 | – | – | B Abläufe | – |
| 276 | Fords Anleitung auf eine Seite (Empfehlung Sokrates zu 274) | Perikles | K | ruht | – | – | – | B Abläufe | – |
| 341 | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug und Diogenes (Chef 23.10., 09:39) | Perikles | M | startbar, gelöst 09.11.: 09.11. | – | – | – | B Abläufe | – |
| 270 | Perikles und Diogenes auf das große Modell (Chef 21.10.) | Perikles | M | ruht | – | – | – | B Abläufe | 5,58 $ |
| D75 | Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1); meldung.sh --film legte Film 572 nicht ab (D75.2) | Perikles | M | Dauer, bis zum nächsten echten Film (D75.1 gebaut, D75.2 dann prüfen) | – | – | – | B Werkzeuge | – |
| 627 | probelauf.py: Push mit `git commit -F -` im selben Befehl als Probelauf gezählt (562, ohne Lauf) | Perikles | M | gebaut, Geprüft an: 4bcd30e87 | – | – | – | B Werkzeuge | – |
| 99 | Zwei Niederlassungen | Perikles | K | ruht | – | – | – | B Steuerung | 7,25 $ |
| 641 | lauf.py startet Nachfolger „auf Abruf“, obwohl nichts startbar ist (Diogenes 08.11., 09:07, Leerstart) | Perikles | M | gebaut, Geprüft an: af1a4da5a (Probe: Übergabe „Diogenes – Prüfer (auf Abruf)“, alt START, neu NICHTS) | – | – | – | B Werkzeuge | – |
| 646 | Zeigen statt messen: Messläufe zählen als Probe, nach einer Probe immer Bild an den Chef (Chef 08.11., 12:28) | Perikles | M | gebaut, Geprüft an: 18b80b3b4 | – | – | – | B Abläufe | 13,26 $ |
| 647 | Abgleich alt schon vor dem Bauen: Fundstelle alter Code lesen und nennen, nicht erst vor der Testbitte (Chef 08.11., 12:44; aus 512, 499) | Perikles | M | gebaut, Geprüft an: d1c316652 | – | – | – | B Abläufe | – |
| 648 | Glossar und Abkürzungsverzeichnis LISTE-GLOSSAR.md: Wort, Bedeutung, Zusammenhang, Fundstellen per Werkzeug, Link zur Festlegung (Chef 08.11., 13:01) | Perikles | K | gebaut, Geprüft an: 42e11acf4 | – | – | – | B Abläufe | – |
| 651 | Kostenauswertung: Bereiche als feste Liste, fehlende Kosten (533 von 980 Zeilen) über Commits je Sitzung schätzen, Auswertung je Bereich, Tag, Woche (Chef 08.11., 13:29) | Perikles | M | gebaut, Geprüft an: 50bf4011a | – | – | – | B Steuerung | 3,00 $ |
| 650.1 | Liste für docs/alt/ nach zwei Gegenprüfungen (aus 650) | Perikles | M | startbar, gelöst 09.11.: 09.11. | – | – | – | B Abläufe | 3,00 $ |
| 654.1 | Systemfrage vor jedem Bau in ROLLE-ENTWICKLUNG.md und Prüfliste, Wiederholungswächter in vorgang.py neu (Stichwort in zwei früheren → Zeile „Systemlösung?“ für Sokrates); Regelbilanz (654, Chef 14:42) | Perikles | M | gebaut, Geprüft an: 36cff7b9d (Probe in Kopie: Schild → Systemlösung?, zweite blockiert) | – | – | – | B Abläufe | – |
| 696 | meldung.sh: mehrere Bilder in derselben Minute überschreiben sich im Zweig bilder (Pfad TT-HHMM-Nr-Name ohne Zähler; 613 am 08.11. 19:10/19:11: zehn gesendet, zwei abgelegt), Links in ansehen/ zeigen nur das letzte (von Spike) | Perikles | K | gebaut, Geprüft an: d5e584b7a (Probe Wegwerf-Repo) | – | – | – | B Werkzeuge | 1,41 $ |
| 340.2 | Rollenspiegel C: `tools/rollenspiegel.sh`, eigene Antwort ohne fremde | Diogenes | M | startbar, gelöst 09.11.: 09.11. | – | – | – | B Abläufe | –; +6,35 $ |
| 485 | Diogenes bessert sich aus dem Rollenspiegel 02.11.: Wochentermine zählen, Vergleichsblätter selbst holen, Meldungen ohne Abkürzungen (Chef 02.11., 19:37 „1, 2, 3 ja“) · „jetzt“ 02.11., 19:37 | Diogenes | M | startbar, gelöst 09.11.: 09.11. | – | – | – | Q QS | – |
| 461b | Nur Gültiges steht: neu ersetzt alt im selben Commit, Commit-Prüfung, Kennzahl Widersprüche (Chef 01.11., 22:26) | Diogenes | M | startbar, gelöst 09.11.: 09.11. | – | – | – | B Abläufe | – |
| 348.9 | Umzug Godot: Arbeitsteilung, Meilenstein, Modelle jetzt (Chef 25.10., 12:24) | Diogenes | M | ruht | – | – | – | B Abläufe | 119,56 $ |
| Woche | Wochenzählung der Kennzahlen | Diogenes | K | startbar, gelöst 09.11.: 09.11. | – | – | – | Q QM | – |
| 186.3 | Ausgefüllte Prüfbögen auswerten | Diogenes | K | ruht | – | – | – | Q QS | – |
| 644.5 | Abnahme Gegenstands- und Figurenkatalog: Prüfungen des Werkzeugs grün, Godot liest nur noch aus den Katalogen (keine alten Datenwege), Seiten auffindbar für den Chef, Stichprobe im Spiel (Chef 08.11., 14:30) | Diogenes | M | startbar | 644.1, 644.2, 644.4, 649.2, 649.3 | – | – | Q QM | – |
| 657 | Regeln radikal kürzen: eine Seite für alle mit Stil, Team, Ablauf (Chef 08.11., 14:58, 15:05) | Sokrates | M | wartet, Votum nach 657.1 | Chef | – | – | B Abläufe | – |
| 620 | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build (Chef 07.11.) | Sokrates | M | startbar | – | – | – | B Abläufe | 6,49 $ |
| 341.1 | Zielvereinbarung für alle Rollen: je Rolle höchstens drei Ziele, Z3 und Z4 für alle, eins eigen (aus 341) | Sokrates | M | startbar, prüfen (alte Leiche: in LISTE-VORGAENGE.md „erledigt“, Zeile noch im Vorrat) | – | – | – | B Abläufe | – |
| 623 | Effektpakete REEBOO Labs: Kauf, Ressourcenseite `LISTE-QUELLEN.md`, Zuordnung `LISTE-EFFEKTE.md`, Dank im Spiel (Chef 07.11.) | Sokrates | M | wartet, Kauf beim Chef | Chef | – | – | E Kampf | 6,49 $ |
| 623.1 | Prüfschema auf bisher geprüfte Quellen anwenden (Chef 07.11., aus 623) | Sokrates | M | startbar | – | – | – | B Abläufe | – |
| 508 | Lehrmeister in Kapitel 1 erreichbar (Geselle), Magie-Pflicht Paladin/Kriegsmagier, Wachsoldat zu Wächter (aus 447.4) | Sokrates | M | startbar | – | – | – | G Stil | – |
| 461b.4 | Widersprüche aus Liste 461b: Köpfe Regelwerk, Bestiarium, DESIGN-KAMPF gegen Entscheidung 84 | Sokrates | M | startbar | – | – | – | G Stil | 33,44 $ |
| 481 | Herkünfte ausgleichen: Kräutersammler mit Kampftränken, Wachsoldat, Klosterschüler, Bewährungsprobe (Chef 02.11., 18:54, aus 427) | Sokrates | M | startbar | – | – | – | E Kampf | – |
| 391 | Zweit-Repo dauerhaft in den Sitzungen, ohne Ablehnung (Chef 28.10., 09:21) | Sokrates | M | ruht | – | – | – | B Werkzeuge | – |
| 383.2 | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | Sokrates | M | ruht | – | – | – | B Werkzeuge | – |
| 374 | Wer prüft regelmäßig, dass alle 373 einhalten? (Chef 27.10., 11:54) | Sokrates | M | startbar | – | – | – | B Abläufe | 17,69 $ |
| 348 | Fertige Spiel-Engine statt Selbstbau: Umzug nach Godot (Chef 24.10., 16:43) · „jetzt“ 24.10., 16:54 | Sokrates | M | ruht | – | – | – | E Technik | –; +115,14 $ |
| 26.1 | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef 24.10., 16:56) | Sokrates | M | ruht | – | – | – | Q QS | – |
| 327 | Zweites Spiel: Marktsichtung Denkspiele, Modell ohne Werbung (Chef 23.10., 00:08; vertraulich, Dokument außerhalb des Repos) | Sokrates | K | nach Meilenstein | – | – | – | M Markt | –; +1,26 $ |
| 347 | Paket „Regeltreue erhöhen, Kosten senken“ (Zähler, Kernregeln, kleiner Start) prüfen und umsetzen (Chef 24.10., 16:20) | Sokrates | M | startbar | – | – | – | B Abläufe | –; +15,42 $ |
| 318 | Knappheit per Einstellung: Antwortstil „Knapp“ und Startanhang (Chef 22.10., 21:34) | Sokrates | M | startbar | – | – | – | B Abläufe | –; +45,66 $ |
| 246.1 | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | Sokrates | K | nach Meilenstein | – | – | – | Q QM | – |
| 296 | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MARS fehlt (Chef 22.10., 07:50) | Sokrates | K | ruht | – | – | – | B Abläufe | –; +2,98 $ |
| 264 | Arbeitsorte neben GitHub: NAS, Proxmox, ALL-INKL? (Chef 20.10.) | Sokrates | K | ruht | – | – | – | B Abläufe | – |
| 263 | Rolle für Finanzen und Geschäftszimmer? (Chef 20.10.) | Sokrates | K | startbar | – | – | – | B Steuerung | – |
| 366 | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | Sokrates | M | startbar | – | – | – | M Markt | –; +25,65 $ |
| 365 | Aufwand „Hoch“ statt „Mittel“ für einzelne Rollen? (Chef 25.10., 12:36) | Sokrates | M | startbar | – | – | – | B Abläufe | –; +4,65 $ |
| 262 | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | Sokrates | K | ruht | – | – | – | B Abläufe | – |
| 253 | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf (Chef 20.10.) | Sokrates | K | ruht | – | – | – | M Markt | – |
| 72c | Brainstorming Wunden bis zur Rast (Zeichen, Heilung mit Verband oder Tempel, schwere Wunden); Wortlaut Vorgangsarchiv 72c | Sokrates | K | nach Meilenstein | – | – | – | E Kampf | – |
| 167.6 | Morgenbericht mit Kennzahlen und Kostenbilanz (Chef 18.10.) | Sokrates | M | startbar | – | – | – | B Steuerung | 2,29 $ |
| 142.3 | Tester öffentlich suchen (Chef 27.10., 19:32) | Sokrates | M | ruht | – | – | – | M Veröffentlichung | – |
| 142.4 | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 07.11.) | Sokrates | M | wartet, D-U-N-S beantragt über Apple (Chef 08.11., 14:33), Bearbeitung bis etwa 30 Tage; Chef sagt „D-U-N-S da“ | 08.12. | – | – | M Veröffentlichung | – |
| 142 | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | Sokrates | M | startbar | – | – | – | M Veröffentlichung | 19,96 $ |
| 45 | Geschäftsmodell und Umsetzung (Play Store) | Sokrates | M | startbar | – | – | – | M Veröffentlichung | 4,68 $ |
| 109 | Repo öffentlich | Sokrates | M | startbar | – | – | – | M Veröffentlichung | – |
| 246 | Dokumente grundsätzlich ins Repo statt als Artefakt; Wochenplan aktualisiert (Chef 20.10.) | Sokrates | K | ruht, ohne Vorratszeile, Liste „entschieden“ (275.2) | – | – | – | Q QM | –; +7,03 $ |
| 284 | Bis zum Durchspielen (26) am Kampf nur Fehlerbehebung, kein Feinschliff (Vorschlag Sokrates) | Sokrates | M | ruht, ohne Vorratszeile, Liste „entschieden“ (275.2) | – | – | – | B Abläufe | – |
| 340 | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Chef 23.10., 09:34) | Sokrates | M | ruht, ohne Vorratszeile, Liste „entschieden“ (275.2) | – | – | – | B Abläufe | –; +3,54 $ |
| 344 | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23.10., 16:05) | Sokrates | M | ruht, ohne Vorratszeile, Liste „entschieden“ (275.2) | – | – | – | E Welt | – |
| 644 | Alle Gegenstände an einer Stelle: Katalog 458 mit BRS-Werten, Voraussetzungen, Seltenheit, Bild je Stück, ohne Würfel (Chef 08.11., 11:05–12:39) | Sokrates | M | wartet, entschieden A B C (Chef 14:28) | 644.1, 644.2, 644.4 | – | – | E Kampf | 13,53 $ |
| 649 | Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten), Bestiarium geht darin auf; mehr als eine Handlung je Monsterart (Chef 08.11., 13:19, 13:24) | Sokrates | M | startbar, ja mit Gegenprüfung der Spalten (Chef 13:28) | 649.3, 649.4 | – | – | E Kampf | – |
| 650 | docs aufräumen: 88 Dateien, Erledigtes nach docs/alt/, Zusammenlegen, Inhaltsverzeichnis neu (Chef 08.11., 13:24) | Sokrates | M | startbar, ja mit Gegenprüfung (Chef 13:27) | – | – | – | B Abläufe | – |
| 654 | Mitdenken vor dem Bauen: Systemfrage je Fund („kommt das wieder?“), Wiederholungswächter, wöchentliche Runde über die teuersten Vorgänge (Chef 08.11., 14:39) | Sokrates | M | wartet, ja (Chef 14:42); Systemrunde ab 09.11. bei Sokrates | 654.1 | – | – | B Abläufe | 22,24 $ |
| 655 | Bilder: Ersteller sieht sein Bild selbst an, Regel 300 streichen statt neuer Vorprüfung (Chef 08.11., 14:51: „warum entsteht überhaupt das Falsche?“) | Sokrates | M | startbar, gelöst 08.11.: 655.1 | – | – | – | B Abläufe | 7,02 $ |
| 666 | Systemlösung? Fenster: 8 frühere Vorgänge (25, 557a, 526, 399.5, 549a.1 …), neu 665; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Welt | – |
| 667 | Systemlösung? Licht: 12 frühere Vorgänge (84.5, 221, 539, 348.13a, 399.5 …), neu 665; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Welt | – |
| 669 | Systemlösung? Kasten: 7 frühere Vorgänge (551, 659, 153, 549a, 557 …), neu 668; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Oberfläche | – |
| 671 | Systemlösung? Menü: 10 frühere Vorgänge (345, 426, 425, 549a.1, 399.3.1 …), neu 670; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Oberfläche | – |
| 672 | Systemlösung? Karte: 20 frühere Vorgänge (322, 500, 553, 529, 86 …), neu 670; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Oberfläche | – |
| 674 | Systemlösung? Kamera: 5 frühere Vorgänge (590, 615, 460, 211.14, 399.4), neu 673; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Technik | – |
| 676 | Systemlösung? Schild: 14 frühere Vorgänge (662, 58, 406a, 417, 645 …), neu 675; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | B Abläufe | – |
| 690 | Systemlösung? Schatten: 10 frühere Vorgänge (208, 242.2, 566, 399.5, 558 …), neu 689; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Welt | – |
| 706 | Systemlösung? Fackel: 17 frühere Vorgänge (322, 345, 344.1, 332.1, 539 …), neu 613.2; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Oberfläche | – |
| 707 | Systemlösung? Zwischensequenz: 4 frühere Vorgänge (613, 70, 314, 659), neu 613.2; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Oberfläche | – |
| 710 | Systemlösung? Waffe: 12 frühere Vorgänge (348.12h, 534a, 427, 417, 410 …), neu 709; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Kampf | – |
| 711 | Systemlösung? Schrift: 8 frühere Vorgänge (292.3, 312, 498, 497, 544 …), neu 586.1; einmal grundsätzlich lösen? (654) | Sokrates | K | startbar | – | – | – | E Oberfläche | – |
| Betrieb | Läufe von Ford und Ford 2 | Ford | – | Dauer | – | – | – | B Steuerung | Ford 37,38 $, Perikles Vorratsdurchsicht 1,90 $; Sokrates 18.10. 5,60 $; Ford 2 16,79 $; Probe Pro Mittel 17.10. 0,00 $; +857,14 $ |
| Pflege | von Werkzeug (340.3, 09.11.): 23764 Bytes (Grenze 15000), Erledigtes streichen | Ford | K | startbar | – | – | – | B Abläufe | – |
| 48 | Zufallsgenerierte Dungeons, auch Questhöhlen | Ideen | K | Idee | – | – | – | G Balance | – |
| 49 | Lehrer für Waffen-, Rüstungs- und Rettungswurf-Übung | Ideen | K | Idee | – | – | – | G Balance | – |
| 50 | Weitere Klassen, ggf. zum Kauf | Ideen | K | Idee | – | – | – | G Balance | – |
| 52 | Feinarbeit an den Kampfanimationen | Ideen | K | Idee | – | – | – | E Kampf | – |
| 70 | Zwischensequenzen einheitlich, Bildsprache | Ideen | K | Idee | – | – | – | G Stil | 2,30 $ |
| 79 | Kampfhintergründe wie Diagonalwelt | Ideen | K | Idee | – | – | – | E Kampf | – |
| 84.4 | Lauschen beim Stehen: Welle zur Quelle | Ideen | K | Idee | – | – | – | G Balance | – |
| 102 | Dokumente BornWire TCS nachziehen | Ideen | K | Idee | – | – | – | B Abläufe | – |
| 111 | `DESIGN-BLENDE.md` kürzen (nach 24.6) | Ideen | K | Idee | – | – | – | B Abläufe | – |
| 283.1 | Hohes Gras sichtbar höher als ein Feldweg, stimmige Welt (Chef 21.10.) | Ideen | K | Idee | – | – | – | G Stil | – |
