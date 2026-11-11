# Abgleich Oberfläche alt gegen neu (785)

Vorgang 785 (654 A, Chef 09.11., 17:46): jeder Schirm und jede Bedienung der alten Fassung (Kotlin, `app/src/main/java/de/bornim/game/ui/`) gegen Godot (`godot/skripte/`, `godot/kampf/`). Maßstab des Chefs (17:47): „wir brauchen keine 1:1 Kopie. Es soll so gut sein wie das alte, aber gerne auch besser.“ Die alte Fassung ist die Untergrenze. **Urteil** je Zeile: **da**, **besser**, **anders gleich gut** (bleibt), **schlechter** oder **fehlt** (je ein Vorgang 785.n), **unklar** (am Gerät oder im Lauf klären). Was mit dem BRS absichtlich wegfällt (Würfel, Klassen, Talente, Punkte verteilen, Zauberpunkte), ist kein Befund; Anzeige, Erklärung und Bedienweg bleiben Maßstab.

**Vorgänge daraus (11.11., 18:37):** Tom 785.1–785.8, 785.19–785.24; Jerry 785.9–785.18. Wo Umzugsdateien berührt sind (`LISTE-UMZUG-BRS.md` 4, Grundsatz 5), wartet der Vorgang auf 870.13, 785.7 auf 870.9; startbar sind 785.8, 785.19, 785.20, 785.23. Systemfrage Nebel: 985 (Sokrates, vom Werkzeug angelegt).

**Stand:** Code von `main` am 11.11., 18:25 (gleich dem Zweig `claude/tom-870-9-ohne-kotlin` für diese Dateien), drei Helfer haben nur gelesen, Spike hat Stichproben nachgesehen (Kartenblatt nur Dorf und Räume, `seen_rows` nie gesetzt, Flucht ohne Tipp, Decken nur für `FIGHTER`). Bekannte Vorgänge stehen in der Spalte „Vorgang“; 666, 669, 671, 711, 752 (Systemfragen Fenster, Kasten, Menü, Schrift, Knopf) gehen in dieser Liste auf. Wer einen Befund baut, trägt in „Vorgang“ den Stand nach; Abkürzungen: alt ohne Pfad = `ui/…kt`, neu ohne Pfad = `godot/skripte/…gd`, KU = `godot/kampf/kampf_ui.gd`, SK = `SkirmishScreen.kt`, BS = `BattleScreen.kt`, MT = `MarsTips.kt`.

## 1. Spielmenü mit allen Reitern (Team Tom)

| Schirm | Bedienung/Inhalt | alt | neu | Urteil | Vorgang |
|---|---|---|---|---|---|
| Menü | Name des Reiters groß in Goldversalien | MenuScreen:114 | menue:77, 105 | da | – |
| Menü | Reiter als gezeichnete Zeichen, gewählt hell; langes Drücken nennt den Reiter | MenuTabs:32–46 | reiterzeichen:84–92 | da | – |
| Menü | Reiter Fertigkeiten | – | menue:109, 307 | besser | 762 |
| Menü | Stern an der Chronik bei Neuem | MenuScreen:119 | menue:112 | da | – |
| Menü | Stern am Helden bei offenen Punkten | MenuScreen:119 | – | anders gleich gut (Punkte entfallen, BRS) | – |
| Menü | Antippen wechselt den Reiter, Erklärfenster geht zu; vom Kartenzeichen geöffnet: Karte noch einmal führt ins Spiel | MenuScreen:121–126 | menue:136–141; spiel:1066–1068 | da | – |
| Menü | Wischen zwischen Reitern | – | – | anders gleich gut (alt auch nicht) | – |
| Menü | Rollen über Knöpfen, Tippen erst unter 12 dp Weg | Theme:377–381 | wischen:9–31; menue:532–544 | da | – |
| Menü | Unten Schließen, Zurück-Taste: erst Fenster, dann Erklärung, dann Menü | MenuScreen:93–95, 153 | menue:59, 96, 1683; rueckfrage:81 | da | – |
| Menü | Kurze Meldung nach Benutzen, Anlegen; Klick-Klang | MenuScreen:744, 806; Theme:293 | menue:150–158; klang:986 | da | – |
| Fenster | Tippen daneben schließt, hinein nicht | Dialogs:52–62 | rueckfrage:74–98 | da | – |
| Held | Drehende Figur, Name, Volk, Herkunft, Stufe, Gold, Leben, Mana, EP mit Satz bei Höchststufe, Kampfwert und Waffe | HeroDollUi:41–53; MenuScreen:584–606 | menue:195–222 | da | – |
| Held | Grundwerte mit Zahl, Tippen öffnet Erklärung | MenuScreen:614–632 | menue:224–239, 413–418 | da | 839 |
| Held | Erklärung Verstand | MenuScreen:625 | menue:393 (leer) | schlechter: nur „Wert n“, kein Satz | bekannt (menue:381, an Homer) |
| Held | Anteil der Ausrüstung je Grundwert (blau, *), Satz zur Obergrenze | MenuScreen:635–637, 650–657 | menue:231 (nur Summe) | fehlt | 785.1 |
| Held | Punkte verteilen | MenuScreen:611–683 | – | anders gleich gut (BRS) | – |
| Held | Fertigkeiten, Volksmerkmal | MenuScreen:686–693 | menue:242, 297–305 | anders gleich gut | 762 |
| Held | Zustände mit Erklärung | – | – | fehlt | 764 |
| Fertigkeiten | Gruppen auf/zu, Rang, Wert, Balken | – | menue:270–380 | besser | 762 |
| Fertigkeiten | Was eine Fertigkeit tut (alt: Satz je Fähigkeit) | MenuScreen:692 | menue:270–295 (nicht tippbar) | fehlt | 785.2 |
| Tasche | Gold als erste Zeile, Leuchtfunke „Löschen“, „nichts“ | MenuScreen:732–748 | menue:423–440 | da | – |
| Tasche | Vorrat: Bild, Name in Seltenheitsfarbe, ×Anzahl, Zeile darunter | MenuScreen:707–723 | menue:441–449, 515–530 | da (Beschreibung statt Würfel) | – |
| Tasche | Vorrat antippen: Essen, Benutzen, OK; Klang, Antwortsatz | MenuScreen:751–762 | menue:733–760 | besser | – |
| Tasche | Vorratsfenster nennt die Seltenheit als Wort | Dialogs:116 | menue:742–760 (nur Farbe) | schlechter | 785.3 |
| Tasche | Ausrüstung (n), Sortierung, Zeile mit Bild, Art, Wert, „nicht tragbar“, „zweihändig“, Rahmen in Seltenheitsfarbe, ▲/▼ | MenuScreen:766–768; GearUi:65–153 | menue:452–509, 1433–1456 | besser | – |
| Tasche | Stück antippen: Anlegen, Nebenhand, Wegwerfen mit Rückfrage und Händlerpreis; Fackel | MenuScreen:769–809 | menue:903–961, 1163–1213 | da | – |
| Gegenstand | Bild, Name, Seltenheit, Art, Tragort, Stufe, Rüstungsart, „Ersetzt:“, Urteil, Schutz, Boni, Warnungen, Vergleich, rollt | GearUi:161–244; Dialogs:67–88 | menue:1221–1376 | da, Boni und Händlerpreis besser | 756, 926 |
| Gegenstand | Schaden als Zahl statt Würfel | GearUi:180–191 | menue:1340–1342 | anders gleich gut | 926 |
| Gegenstand | Waffenzug Fernkampf genannt | GearUi:192–196 | menue:1343–1346 | schlechter: „Fernkampf“ fehlt | 785.4 |
| Gegenstand | Seltenheit, Abnutzung, Güte | – | – | fehlt | 756, 926 |
| Ausrüstung | Puppe 5 + 4 Plätze, Bild, Rahmen, Name; Zweihänder füllt Nebenhand; Ablegen, Wechseln | GearUi:249–276; MenuScreen:830–865 | menue:979–1159, 1380–1508 | da | 521, 581 |
| Ausrüstung | Kampfwerte Schutz, Schaden, Kritisch, Magiefund | MenuScreen:868–887 | menue:1399–1410 | da (dazu Leben, Mana, Ausdauer) | – |
| Ausrüstung | Kampfwert der Nebenhandwaffe | MenuScreen:879 | – | fehlt | 785.5 |
| Ausrüstung | Lebensraub, Widerstand, Goldfund, EP-Bonus als Summe | MenuScreen:882–887 | menue:1410 (nur Magiefund); beute:108–119 würfelt sie weiter | fehlt | 785.6 |
| Karte | Titel, Stufe höher, Filter, öffnet auf dem Helden, zoomen, schieben, Held als Ring mit Keil | MenuScreen:177–197, 367–380, 440–455 | kartenreiter:91–116, 302–367, 393 | da | 860 |
| Karte | Hausschilder, Dach oder Wand tippen öffnet Grundriss; Marken, Erledigtes blass, Name, „In der Chronik“, Gewohnheit | MenuScreen:341–347, 383–469 | kartenreiter:126–199, 418–456 | da | – |
| Karte | Landkarte: Nebel, Handschrift, roter Ort, bekannten Ort tippen | MenuScreen:249–297 | kartenreiter:464–523 | da | – |
| Karte | Wald, Tiefer Wald, Höhle als Kartenblatt mit Nebel | MenuScreen:325–336 | `kartenblatt.json` nur village, inn, shop, elder, temple; kartenreiter:66 | fehlt: dort öffnet die Landkarte, Tippen auf den Wald tut nichts | 785.7 |
| Karte | Höhlenmund tippen öffnet Höhlenplan | MenuScreen:388–390 | – | fehlt | 785.7 |
| Karte | Lagerfeuer-Marke | MenuScreen:558–566 | kartenreiter:233–257 (keine) | fehlt | 785.8 |
| Karte | Zielmarke eines Auftrags | MenuScreen:430–438 | kartenreiter:161–199 (nie angelegt) | fehlt | 785.8 |
| Chronik | Aufträge / Bisher geschehen, Hauptauftrag gold, Nebenaufträge mit Stand und Lohn, Erledigt aufklappbar, Andacht und Ankunft ansehen, gelesen, „Auf der Karte“ | ChronicleTab:44–112 | menue:1868–1937 | da | 860 |
| System | Version, Ersthinweis „halte gedrückt“, Erklärfenster, „Aus“ gedimmt | MenuSigns:78–177 | menue:1522–1690; zeichenknopf:12–258 | da | 713 |
| System | Speichern, Sprache, Hauptmenü, Anleitung, Über, Blut, Tempo, Rückfragen, Joystick, Rennen, Aktion, Karte nah, Rütteln, Schritte, Lautstärken, Helligkeit, Schritte und Siege, Gerät | MenuSigns:183–250; SoundSettings:43–74 | menue:1537–1711 | da | – |
| System | Kampftext, Steuerung Wischen/Klassisch | MenuSigns:206–219 | – | anders gleich gut (527, 663) | – |
| System | Zeichen „M“: MARS-Probekampf mit Regelseite | MenuSigns:192; MarsRules:29–143 | nur Testreiter (testmodus:331) | fehlt | 785.9 |
| Anleitung | Seite mit Titel, Absatzköpfe, Zurück | GuideScreen:40–67 | menue:1730–1767 | da | – |
| Anleitung | Teil zu den Fähigkeiten des Helden | GuideScreen:46 | menue:1736 (fällt ohne Klasse weg) | fehlt | 870.15 (Handbuch BRS, Homer) |
| Test | Testreiter | TestTab | menue:109, 125 | unklar | 668 |

## 2. Übrige Schirme und Bedienung in der Welt (Team Tom)

Weder alt noch neu gibt es Zufallsheld oder Zufallsnamen (Vorgabe „Alrik“), Gold stand alt nicht in der Leiste: kein Befund.

| Schirm | Bedienung/Inhalt | alt | neu | Urteil | Vorgang |
|---|---|---|---|---|---|
| Vorspann | Firmenzeichen, „präsentiert“, Klanglogo, Name wächst ins Menü, Tippen überspringt | App:164–186 | hauptmenue:86–155 | da | – |
| Hauptmenü | Titel, Zier, Untertitel, Titelmusik; „Weiter“ mit Name · Stufe · Ort; Neues Spiel, Spielstände; Sprache, Musik, Klang; Logo, Version, 7× Tippen Testmodus | App:78–273 | hauptmenue:81–336 | da (Spielstände auch bei nur alten besser) | – |
| Hauptmenü | Bild der Helden | App:225–228 | hauptmenue:15, 281 | schlechter: alte Kotlin-Figuren | 867 |
| Hauptmenü | Kurzhinweis | App:131–137 | hauptmenue:339–355 | anders gleich gut | – |
| Hauptmenü | Android-Zurück verlässt das Spiel | App (ohne BackHandler) | project.godot:8; zurueck.gd | schlechter: tut nichts | 785.21 |
| Über das Spiel | Titel, Text, Schriften, Logo, Version, Zurück | App:341–372 | hauptmenue:458–536 | besser (Lizenzen aufklappbar) | – |
| alle Schirme | Klick-Klang auf jedem Knopf | Theme:293, 300 | klang:985–987 (nur BaseButton) | fehlt bei Knöpfen im Stil 549a (Spielstände, Erschaffung, Laden, Brett, Rast, Kapitelende, Rückfragen) | 785.20 |
| Spielstände | vier Plätze, leer → Neues Spiel dorthin, belegt mit Bild und Angaben, Laden, Löschen mit Rückfrage, Zurück schließt erst die Rückfrage | SlotsScreen:45–116 | spielstaende:47, 186–362 | da (Kapitel und Hauptauftrag besser) | – |
| Erschaffung | Held dreht sich, Zusammenfassung, Name (12, „Alrik“), Aussehen, Zurück und Beginnen, Platz ersetzen | CreateScreen:74–300; HeroDollUi:28–55 | erschaffung_brs:104–498 | da (Grund für gesperrtes „Beginnen“, Gesicht, Frisur, Bart besser) | 470.1 |
| Erschaffung | Volk mit Beschreibung und Wirkung des Merkmals | CreateScreen:123–133 | erschaffung_brs:175–187 | schlechter: ohne Beschreibung, Merkmal nur als Name | 954 (Erklärung durch Gedrückthalten; prüfen, ob das reicht) |
| Erschaffung | Herkunft mit Satz je Startfertigkeit; Grundwerte mit sichtbarem Nutzen | CreateScreen:142–216 | erschaffung_brs:193–202, 356–396 | schlechter: Fertigkeiten und Grundwerte ohne sichtbare Erklärung | 954 (ebenso) |
| Erschaffung | Vorschlag verteilt die Punkte; Fertigkeiten selbst wählen | CreateScreen:188 | erschaffung_brs:223–230, 399–422 | anders gleich gut | 954a.12 |
| Erschaffung | Zurück führt zu den Spielständen, wenn man von dort kam | CreateScreen:74 | hauptmenue:363, 372 (immer Hauptmenü) | schlechter | 785.21 |
| Zwischensequenz | Intro beim neuen Spiel, Bilder überblenden, Satz, Wind, Fluss, Grillen, Glocke | App:122; IntroScreen:127–150; IntroSoundUi:20–49 | spiel:136–139; zwischenbild:60–207, 357–460 | da | – |
| Zwischensequenz | Fackelzug über Bild 3 | IntroScreen:180, 211–273 | zwischenbild:218–315 | unklar: Code da, der Chef sah nichts | 613.2 |
| Zwischensequenz | Tempel: Kerzen flackern, Staub im Lichtstrahl | IntroScreen:83, 95–111 | zwischenbild:65 (nur Intro) | fehlt | 613.2 |
| Zwischensequenz | Tippen fragt „Überspringen?“ | IntroScreen:130, 153–161 | zwischenbild:427–447 | schlechter: alter Kasten | 856 |
| Ortsblende | Name, Zierstrich, Satz beim ersten Besuch, Tippen beendet früher | InterludeUi:61–106, 231, 325 | ortsblende:41–45, 106–170 | da | – |
| Ortsblende | Ladebalken, Vignette | InterludeUi:67–133 | ortsblende:6, 83–85 | anders gleich gut (Chef 556) | – |
| Gespräch | Kasten, Sprecher gold, Erzähltes schräg, ▼, Tippen schaltet weiter, Knöpfe verborgen | DialogDraft:39–68; WorldScreen:421–485 | steuerung:120–235, 409–462 | da | – |
| Gespräch | Text Zeichen für Zeichen, Tippen zeigt ihn ganz | WorldScreen:127, 382–388 | steuerung:425 (sofort) | fehlt | 785.19 |
| Rast | Titel, Gold, Rowenas Satz, Wahlen mit Nutzen und Sperrgrund, Met, Notiz, Verlassen, Zurück, Schwarzblende | RestScreen:43–144 | spiel:1335–1436; rastfeld:26–198 | da, Wahlen besser | – |
| Rast | „Fleisch verkaufen · 12 Gold“ | RestScreen:117–122 | spiel:1350 | schlechter | 570 |
| Laden | Titel, Gold, Kaufen, Verkaufen, Brauen, Zurückkaufen, tragbar zuerst, ▲/▼, Ware nach 8 Siegen, Gewöhnliche verkaufen, Mengenkasten, Rückfragen, Rezepte, Meldung, Schließen | ShopScreen:75–412 | ladenschirm:30–666 | da, mehrfach besser | – |
| Laden | Vorräte mit Wirkungszeile in der Liste | ShopScreen:226–250 | ladenschirm:121–130 | schlechter: Wirkung erst nach Antippen | 785.24 |
| Brett | Aushänge, Annehmen, leer „verblichene Nägel“, Zurück | BoardScreen:45–85 | brettschirm:26–105 | da | 542 |
| Kapitelende | Titel, Text, Heldenzeile, Weiter | ShopScreen:416–455 | kapitelschirm:72–141 | besser | – |
| Welt | Leiste LP, Mana, EP, Sonne/Mond, Uhrzeit; Karte und Menü öffnen | WorldScreen:2839–2884 | leiste:98–208; spiel:62, 1056 | da | – |
| Welt | Leiste: Zustand „Satt“ | WorldScreen:2856–2872 | zustand:22, nicht in leiste | fehlt | 785.22 |
| Welt | Android-Zurück öffnet das Menü | WorldScreen:139 | zurueck:5–6 (Welt: nichts) | fehlt | 785.21 |
| Welt | Joystick, Rennen über den Ring, Tippen geht hin oder spricht an, Aktionsknopf, Ausgangsziel, Linkshänder, Renntaste, Ausdauerbalken, Kurzhinweise, Helligkeit | WorldScreen:200–751, 2955–2978; StaminaBar:25–42 | steuerung:85–505; aktionsknopf; ausdauer:31–61; spiel:86, 279–304 | da; zwei Finger drehen und zoomen besser | – |
| Welt | Steuerkreuz mit NEXT, ACT, MENU | ActionSigns:117–135 | – | anders gleich gut (663) | – |
| Welt | Renntaste geht aus, wenn der Held steht oder außer Atem ist | WorldScreen:201 | steuerung:116 | fehlt | 785.23 |

## 3. Kampf, nur Bedienung und Anzeige (Team Jerry)

Alt lief MARS nur als Probekampf im Systemmenü (`App.kt:124`), die Story-Kämpfe klassisch; Ende und Beute stehen darum in BS. Der Atembalken (`StaminaBar.kt`) stand nur auf der Karte (`WorldScreen.kt:411`). **536 ist „zu testen“ (Build 277), sein Zweig `claude/tuffy-536-tips` ändert aber nur die Lage der Ansagen; der übrige Titel (Erklärungen, „Kein Ziel“, „Schnell“, Stufe und EP, Seltenheitsfarbe) ist weder dort noch auf `main` gebaut: 785.10.**

| Schirm | Bedienung/Inhalt | alt | neu | Urteil | Vorgang |
|---|---|---|---|---|---|
| Befehle | Angriff · Können · Tasche · Wechsel, gesperrt grau; Abwehr · Decken · Söldner und Held Auto/selbst; Sperrgrund von Held Auto als Tipp | SK:1428–1510 | KU:682–714 | da | – |
| Befehle | Langes Drücken auf die Hauptknöpfe | SK:1430–1499; MT:11–36 | KU:554–566; marstips:5–20 | da | – |
| Befehle | Flucht mit Erklärung (Aussicht, nie vor Bossen) | BS:1757 | KU:696–697 (ohne Tipp) | schlechter | 785.10 |
| Befehle | „…“, während die Gegner ziehen | SK:1423 | KU:671–676 | da | 751, 833 |
| Befehle | Decken für den Helden | SK:1488–1490 (Kämpfer) | KU:698 (nur `cls == FIGHTER`, BRS-Held hat keine Klasse) | unklar: erscheint nie; hängt an der Regel | 469 |
| Zielwahl | Liste mit Name, Reihe (ab 3 Gegnern), Leben | SK:1438, 1556–1561 | KU:722–728 | schlechter: Reihe fehlt, Gleichnamige nicht zu unterscheiden | 785.11 |
| Zielwahl | Ein Ziel: Angriff greift sofort | SK:1431 | KU:684–688 | da | – |
| Zielwahl | Wählbare leuchten, übrige gedämpft, auch beim Zauberziel | SK:886–891, 1051–1061, 1223 | KU:983–984, 1031 (nur Angriffsziel) | schlechter | 785.11 |
| Können | Liste mit Kosten, gesperrte grau; Ziel einer Reihe | SK:1457–1473 | KU:756–786 | da | – |
| Können | Langes Drücken erklärt Zauber oder Fähigkeit | SK:1463; MT:92–98 | KU:769 (ohne Tipp) | fehlt | 785.10 |
| Tasche | Tränke × Anzahl, dann Ziel mit Leben | SK:1474–1479 | KU:787–803 | da | – |
| Tasche | Langes Drücken erklärt den Trank; Bild je Gegenstand (klassisch) | SK:1475; MT:101; BS:1815–1819 | KU:791 | fehlt | 785.10 |
| Wechsel | Reihe, Tausch, „(frei)“, Waffe | SK:1440–1456 | KU:729–755 | da | – |
| Hinweis | „Kein Ziel in Sicht: … Abwehr.“ bei gesperrtem Angriff | SK:1346–1351 | – | fehlt | 785.10 |
| Schnell | Leichter Kampf: Starttafel, Kämpfen/Schnell, Eckknopf „Schnell ›“, Tipp | SK:750–767, 1340–1405; MT:37–39 | – | fehlt | 785.10 |
| Ring | Großer Ring zieht sich zusammen, Zeile „Tippen, wenn …“ | SK:1255, 1352, 1731–1748 | KU:1104–1113 | da | – |
| Ring | Erster Ring: Hinweis „Tippen, wenn die Ringe aufeinanderliegen!“; erste Ansage mit Ring: Erklärung des Zeichens im Bericht | SK:583–585, 710–718, 1257–1262; MT:85–87 | – | fehlt | 785.12 |
| Ring | Urteil in Farbe je Ergebnis, Gegenschlag darunter, „Gut“ allein bei Fehlschlag | SK:586–588, 721–725, 1321–1328 | KU:838–846 | schlechter: eine Farbe, kein Gegenschlag, „halber Schaden“ auch bei Fehlschlag | 785.12 |
| Ersthinweise | Eingebung beim ersten Auftreten einer Absicht | SK:581; MT:70–83 | – | fehlt | 840 |
| Ersthinweise | Eingebung beim ersten Schlag von hinten | SK:571–573; MT:14–16 | – | fehlt | 785.13 |
| Ersthinweise | „Nahkampf erreicht nur die vordere Reihe.“ nur im ersten Kampf | SK:543–546 | KU:216 (`seen_rows` nie gesetzt) | schlechter: kommt in jedem Kampf | 785.13 |
| Ansagen | Zeichen, Ring-Symbol, starke Absicht rot, Farbe des Ziels, ohne Überlappen; Dreieck vor dem Angezielten | SK:1249–1253, 1667–1717 | KU:994–1015, 1701–1880 | da | 536, 597, 563 |
| Ansagen | Langes Drücken: Erklärung, Gegenmittel, wer gegen wen | SK:1700; MT:45–68 | KU:867–889 | anders gleich gut | – |
| Figuren | Langes Drücken auf einen Gegner: Name, Absicht, Ziel; danach alle Namen | SK:1225–1229, 1544–1548 | KU:278–285, 876–889, 1025–1034 | da | – |
| Figuren | Langes Drücken auf eigene Figur oder Gruppenkasten: Waffe, Mana, „halber Zug“ | SK:1384–1388, 1544–1553 | – (KU:879 nur Gegner, `_party_box` ohne Eingabe) | fehlt | 785.14 |
| Figuren | Blass im Schatten, Lebensleiste über Gegnern | SK:1087, 1221, 1641–1651 | figur:4194; KU:1043–1093 | da | – |
| Am Zug | Zugleiste, Goldring, Name in Gold; Gruppenkasten des Zugs hervorgehoben | SK:1051–1061, 1312, 1916–1975 | KU:458–485, 981, 1689–1698, 1923–1967 | besser | 565 |
| Gruppenkasten | Farbmarke, Name, Leiste, Leben, Mana | SK:1585–1604 | KU:472–527 | da | – |
| Gruppenkasten | Stufe und EP-Balken (klassisch) | BS:1708, 1725–1729 | – | fehlt | 785.10 |
| Zustände | Schilder mit Restrunden, Antippen erklärt | BS:1686–1697 | KU:245, 859–864, 1584–1675 | besser | 563 |
| Bericht | 5 Zeilen, ganzer Bericht zum Blättern | SK:1360–1380, 1570–1581 | KU:298–425 | da | – |
| Erklärfenster | 6 s, Antippen schließt, weg während des Rings | SK:340, 494–495, 1354–1358 | KU:812–823 | schlechter: lässt sich nicht wegtippen, bleibt beim Ring | 785.15 |
| Schalter | Raster und Würfel unten rechts | SK:1330–1335 | KU:233–238, 1970–1996 | da | – |
| Schalter | Raster und Würfel über Kämpfe gemerkt | GameViewModel:335–346 | KU:3, 14 (jeder Kampf neu) | schlechter | 785.16 |
| Tempo | Tempo im Kampf, gemerkt | BS:497, 609–622 | kampfort:208–224; KU:1992–2008 | besser | 600 |
| Bedienung | Zurück-Taste schließt Untermenü bzw. ganzen Bericht | BS:631; SK:364 | zurueck:3–6 („Kampf tut sie nichts“) | schlechter | 785.17 |
| Ende | Ergebnis, „Du bist entkommen.“, Lohn EP, Gold, Beute, Stufe; Söldner bewusstlos; Nochmal/Zurück | BS:389–403, 1560–1571; SK:1411–1421 | KU:638–669; lohn:81–103 | da | 833 |
| Ende | Beute in Seltenheitsfarbe | BS:1569 | KU:651–656 | schlechter | 785.10 |
| Ende | Aufstieg als eigenes Feld „Stärker geworden“ | BS:402–403, 520–523 | KU:651 (eine Zeile) | schlechter | 785.18 |
| Blende | Schwarz, Eröffnung, Gegnername, Satz; Tippen nach Lesezeit; Boss alt größer | InterludeUi:376–475 | kampfblende:72–131 | da | – |
| Blende | Ladebalken während des Zeichnens | InterludeUi:474 | – | unklar: ob Godot hier wartet, nur im Lauf zu sehen | – |
| Regelhilfe | Seite „MARS – Probekampf“: Reihen, Ansagen, Ring, Perfekt, Dein Zug, Automatik, Wer fällt; Gegner und Söldner wählen | MarsRules:29–143 | – (menue:18 „MARS-Probe (Jerry)“ offen) | fehlt | 785.9 |

