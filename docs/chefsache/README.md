# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Zu entscheiden

Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136).

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [783](entscheiden/783-widersprueche.md) | **Muss** | B Abläufe | 09.11., 20:15 | acht Widersprüche zwischen zwei Regeln, je einer gilt | Diogenes |
| [650.2](entscheiden/6502-docs-gliederung.md) | **Muss** | B Abläufe | 09.11., 20:04 | 11 Dateien nach alt/ oder kapitel2/, 6 Themen zusammenlegen, Gliederung flach lassen, Inhaltsverzeichnis neu | Sokrates |

## Zu billigen

Schon entschieden und umgesetzt (Vorentscheid, 194.1); hält keine Arbeit an. Antwort „gebilligt“ oder „zurück“ im Gespräch mit Sokrates; „zurück“ legt den Rückbau als Muss in den Vorrat des Besitzers.

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [341.1](billigen/3411-ziele-alle-rollen.md) | **Muss** | B Abläufe | 09.11., 18:22 | Ziele für alle Rollen; Teams messen sich an einem Haken der Abnahmeliste je Woche | Sokrates |

## Anzusehen

**Bilder** (ansehen und im Gespräch „ja“ oder was anders sein soll):

| Nr. | Was | Wer | Seit |
|---|---|---|---|
| [701](ansehen/701-obergrenze.md) | Gegenstandsfenster: Hinweis auf die Obergrenze einmal | Tom | 09.11., 18:35 |
| [753](ansehen/753-rastblende.md) | Blende nach der Rast im neuen Design | Spike | 09.11., 20:13 |

**Builds** (installieren und testen; Folge = Version aufsteigend, Android installiert nur höhere Nummern über niedrigere):

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.348.315](ansehen/t272-sammelbuild.md) | [Build 272](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42669446341/artifacts/13701543948) | Erschaffung, Tasche, Wald, Kampf | Tom und Jerry | 09.11., 18:50 |

## Zu tun

Was nur du tun kannst (Satz in einer Sitzung, Freigabe, Kauf; 275). Erledigt: Datei löschen.

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [506](tun/506-kaufmodelle.md) | **Muss** | E Kampf | 09.11., 18:35 | Tom das Repo der Kaufmodelle erlauben | Tom |
| [780](tun/780-zustimmung-haendler.md) | **Muss** | M Veröffentlichung | 09.11., 17:47 | Zustimmung von Protofactor und Janpec einholen | Sokrates |
| [623](tun/623-kauf.md) | **Muss** | E Kampf | 07.11., 20:13 | Effektpakete: Rest nach dem Kauf | Sokrates |

## Offen je Rolle

Vom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand 09.11.; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.

**Homer** – offen 7, Muss 2, startbar 1

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 432 | K | Eigenes Volk aus Bornim (etwa mit dem Grauen Propheten, „Tag der Asche“) prüfen, mit der G | ruht |
| 302 | K | Bildsignatur: ist unsere Grafik wiedererkennbar, wie wird sie es? (Chef 22.10., 12:12); ja | wartet auf 302.1 (ruht) |
| 41 | K | Storyplan je Kapitel, Plot Kapitel 2 | ruht |
| 72 | K | Profil und Marktvergleich | ruht |
| 348.12g | M | Gekaufte Monster (Ghul, Untote) zur Geschichte passend? | ruht |
| 766 | M | Wochentermin 13.11.: Rollenspiegel Homer (rollenspiegel.sh Homer) (719); deckt 02.–13.11., | Termin 13.11. 08:00 |
| 772 | K | D89.2 von Diogenes (über Perikles): Glossar ohne „Vorgang beim Chef“ (480); „steht in“ zei | startbar |

**Tom** – offen 103, Muss 84, startbar 5

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 656 | M | Umhang Kämpfer mit Beulen, große Beule unter dem Schwertarm: woher, weg (Chef 08.11., 14:5 | wartet auf Test (Build 272) |
| 773 | M | Sammelbuild 272: alle fertigen Zweige beider Teams (Tom 5, Jerry 6: u. a. 656, 717, 717.1, | wartet auf Test/Build (gebaut) |
| 610 | M | Held im Dorf: Finger am Stab zucken ohne Unterlass (Schild auf dem Rücken) (Chef 07.11., t | wartet auf Test t272 (Chef) |
| 522 | M | Build 249: Ausrüstung im Testmenü geändert (Schild gegeben), Held im Spiel ohne Schild (Ch | wartet auf Test t272 (Chef) |
| 697 | M | Erschaffung: Held im Drehteller halbtransparent (Chef 08.11., 15:23, Build 269; aus 499) | wartet auf 782 (startbar) |
| 653 | M | Halt für Waffen und Schilde einmal je Modell festlegen statt je Figur nachmessen: Griffpun | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 773 (aller) |
| 560 | M | Monster auf der Karte drehen sich zum Helden, wenn sie ihn wahrnehmen, mit Schritten statt | wartet auf Test (Build 272) |
| 680 | M | Absturz: Testmenü Sprung Wald → Dorf, in der Schenke schon hakelig, nach Met immer zäher, | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 543 (schenke) |
| 506 | M | Untote im Kampf: Skelett, Zombie, Ghul (aus 494, Spike; Wochenziel 03.11., 488) | Chef (Datei in der Chefsache) |
| 492 | M | Blutzahnhöhle begehbar mit Krogg, Grak, Lyra (Orte O8; Wochenziel 03.11., 488; von Jerry a | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 635 (lyra) |
| 670 | M | Build 269: Menü des Helden (Held, Tasche, Ausrüstung, Karte, Chronik, System) noch im alte | wartet auf Test t272 (Chef) |
| 581 | M | Ausrüstung: Seite breiter als der Schirm, Reiter springen (Abgleich 512b) | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 522 (ausrustung) |
| 583 | M | Textkasten: ▼ liegt im Text, erzählter Text ohne i-Punkte und nicht schräg (Abgleich 512b) | wartet auf Test t272 (Chef) |
| 521 | M | Build 249, Ausrüstung: Wechselschirm eines Platzes wie alt (Bild, Art und Wert, ▲/▼, „nich | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 522 (ausrustung) |
| 540 | M | Texte hängen am Spielbeginn: Südrand (immer Text vor dem Auftrag, „Kapitel 2 folgt“ fehlt, | wartet auf Test t272 (Chef) |
| 617 | M | Hauptmenü „Laden“: Wischen löst Laden aus; laden nur mit dem Knopf rechts (Chef 07.11., t2 | wartet auf Test t272 (Chef) |
| 701 | M | Gegenstandsfenster: Hinweis Obergrenze nur einmal statt je Grundwert (Chef t270.5, 08.11., | wartet auf Test (Build 272) |
| 636 | M | Schlagbaum öffnet ohne Türgeräusch (alt G:1162 Sound.DOOR; Abgleich 620.2a) | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 540 (schlagbaum) |
| 683 | M | Oberfläche noch mit SRD-Wörtern: Gegenstandsfenster und Vergleich zeigen Zauberpunkte, Att | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 701 (gegenstandsfenster) |
| 700 | M | Erschaffung, Platzwahl „Alle Spielstand-Plätze sind belegt“: Rahmen um jeden Platz gegen 5 | wartet auf Test (Build 272) |
| 635 | M | Lyra fehlt als Figur im Tempel und in der Höhle: Kennung lyra_temple/lyra_cave, gebaut wir | wartet auf Test (Build) |
| 584 | K | Kein halbfetter Schnitt: Köpfe und Titel in Erschaffung, Held, Chronik, Karte, System, Bre | startbar |
| 569 | M | Baumkronen ohne erkennbare Tuschelinie, „ein einziger Brei“ (Chef 04.11., 19:44, Bild 558 | ruht |
| 568 | M | Ernten als Handlung statt Einsaugen; Angeln mit Pose und Ring (Chef 04.11., 19:42: ja, A) | ruht |
| 531 | M | Build 249: Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertreibt Tiere | wartet auf 643 (ruht) |
| 542 | M | Aufträge: Jorins „Feuer am Steinkreis“ nicht abschließbar (Fetzen fehlt), Gwennas Ring am | wartet auf Test/Build (gebaut) |
| 543 | M | Startwerte gegen alt und BRS prüfen: Startgold 15–25 und Start-Heiltränke fehlen, Wiederke | wartet auf Test (Build) |
| 495 | M | Zufallsspieler spielt Kapitel 1 in Godot durch (Abnahme 2.2; Wochenziel 03.11., 488) | wartet auf 492 (startbar) |
| 505 | M | Bau Nebel des Krieges und Sichtfeld des Helden (Archiv 502; Welt W24, W25) | wartet auf 492 (startbar) |
| 515 | M | Truhen: 3–4 je Karte halb versteckt, verschlossene nach BRS (Dietrich, Aufbrechen) (Chef 0 | ruht |
| 431 | M | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, da | ruht |
| 376.1 | M | Probeblatt Quaternius-Figuren mit Bewegungsraster als Film (Chef kaufte 27.10., 12:20) | ruht |
| 455.1 | M | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 1 | ruht |
| 513 | M | Ein Figurenstand für alle Zweige; Schild, Robe Magier, Umhang jetzt (Chef 03.11., 15:56, „ | ruht |
| 470 | M | Bau BRS 1.1 Erschaffung (Wochenziel 02.11., Stufe 1) | ruht |
| 570 | M | Theke: Wahl „Fleisch verkaufen · 12 Gold“ liest sich wie ein Preis (Prüfer 557 Runde 4) | ruht |
| 470.1 | K | Erschaffung: Held auf Antippen bildschirmgroß (Idee Chef 02.11., 18:37) | ruht |
| 471 | M | Bau BRS 1.2 Fertigkeiten durch Tun (Wochenziel 02.11., Stufe 1) | ruht |
| 474 | M | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, M | ruht |
| 475 | M | Leute des Dorfs (Rowena, Borin …) auf Kaufkörper ihres Volks mit Gesicht, statt der alten | wartet auf Sokrates |
| 476 | K | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | wartet auf 458.3 (ruht) |
| 477 | K | Godot-APKs laufen nicht im MuMu Player am Rechner (Chef 02.11., 14:59) | ruht |
| 461.1 | M | Grundstand zusammenführen: ein Zweig für Tom und Jerry, jede Probe baut darauf (01.11.) | ruht |
| 458.3 | M | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | ruht |
| 423.1 | K | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | ruht |
| 455.2 | M | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völker (Chef 01.11., 11: | ruht |
| 385 | M | Protofactor-Animsets (Zauberer u. a.) auf die Listen, Probe ob nutzbar (Chef 27.10., 20:59 | ruht |
| 372 | M | Feinschliff Held am Ende des Umzugs: Kettenhemd, Helm, Kragen (aus 338a B, Chef 27.10., 09 | ruht |
| 348.13 | M | Tusche nach Licht wie entschieden (Chef 26.10.) | ruht |
| 348.13b | M | Tusche auch nach Fackeln, Feuer, Fenster; zuerst Dorf (Chef 28.10., 08:09 ja) | ruht |
| 267 | M | Spiel ruckelt auf dem Tablet (Chef 20.10., Build 48) | ruht |
| 302.3 | M | Intro und Outro mit Tusche im Zeichner, etwas kräftiger als Intro 4 (Chef 23.10., 10:45) | ruht |
| 302.2 | K | Tusche auf der Gebietskarte (Chef 22.10., 23:50); zurückgestellt (Chef 23.10., 10:45) | ruht |
| 302.1 | M | Tuschelinie für Menschengestalten (Chef 22.10., 20:25, über Sokrates); jetzt nicht (Chef 2 | ruht |
| 292.4 | K | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., | ruht |
| 30 | K | Abstürze beim Testen | ruht |
| 145 | K | Karten je Kapitel zum Drucken | ruht |
| 417.1 | K | Restmängel Tragart nach „417 passt“ (Schildabstand, Rumpfdrehen, Fußrutschen, Kornfeld, St | ruht |
| 558.1 | K | Prüferrest Robe Probe 5 nachhalten, nicht bauen; Chef sieht es nach dem Durchspielen an (C | ruht |
| 447.4.1 | M | Bau Lehrmeister, Meisterschaften, Ruf Kapitel 1 (447.4) | wartet auf 508 (startbar) |
| 589 | M | Dorf: Marktplatz wirkt geklont (gleiche Stände, gleiche Säcke), Durchgang links am Stand h | ruht |
| 590 | M | Innenräume: Türseite bei gedrehter Kamera dunkel und tot, mehr Licht (Kerzen) und Einricht | ruht |
| 612 | M | Dorf Süd: Heuhaufen geklont und wie aufgespießt, Wackelgras im Weizenfeld, Gemüsebeet mit | ruht |
| 614 | M | Leute lebendig wie alt: Jorin mit Speer, Jorin öffnet den Schlagbaum sichtbar; Abgleich de | ruht |
| 622 | M | Godot-Build als AAB für Play: dieselbe App de.bornim.game, mit dem Upload-Schlüssel des al | ruht |
| 41.2 | K | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | wartet auf 41 (ruht) |
| 134 | K | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | aufgeteilt |
| 348.1 | M | Vergleichsbild Gebietskarte alt/neu, 64 (heute) und 128 je Kachel (Chef 24.10., 16:51, „je | ruht |
| 348.2 | M | Tusche nach Licht auch am Helden, Innenlinien an Bäumen: zweites Vergleichsbild jetzt (Che | ruht |
| 531a | M | Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast kaufen? (Chef 04.11., 19:27) | ruht |
| 431c | M | Rückfrage: Völker Runde 4 am Tor angehalten, neue Läufe frei? | ruht |
| 431d | M | Rückfrage: Völker Lauf 3 am Tor angehalten (B1 Elf, C3, G3, A1/A3 Grak, A2), neue Läufe fr | ruht |
| 431e | M | Rückfrage: Gesicht des Helden im Dorflicht fast weiß, Hauteichung nach Messung? | ruht |
| 632 | M | Truhe der Höhle (cave_3, 4/14) gibt „@class_weapon“ statt der Waffe der Klasse wie alt (St | wartet auf Test/Build (gebaut) |
| 637 | M | Anschlagbrett: frischer blasser Zettel, solange ein ungelesener Auftrag hängt (A/MapTownIs | ruht |
| 638 | M | Kleinleben wie alt: Dorfhund, Katze in der Schenke, sichtbare Vögel, fallende Blätter im W | ruht |
| 639 | M | Leute tragen ihre Dinge wie alt: Jorins Speer, Aldrics Stab quer auf der Schulter (Garrick | ruht |
| 640 | M | Innenräume und Häuser, Varianten wie alt: Werkzeugregal, Wandbehänge und Stock bei Aldric, | ruht |
| 649.3 | M | Figurenkatalog: Bewohner, Händler, Lehrmeister, Söldner füllen (Tagesablauf, Laden, Stimme | wartet auf 649.2 (ruht) |
| 644.4 | M | Gegenstandskatalog: Ladenbestand und Rezepte aus texte.json und Kotlin in den Katalog umst | wartet auf 644.1 (ruht) |
| 661 | M | Blende zwischen Orten an Schirme ohne Kasten angleichen: Schrift größer, Zierleiste wie do | ruht |
| 663 | M | Klassische Steuerung ausbauen: Steuerkreuz und Funktionstasten ganz raus, nur Touch; Auswa | ruht |
| 665 | M | Nacht im Dorf: um 2:30 kaum dunkel; in allen Häusern Licht, keiner schläft: tiefe Nacht du | ruht |
| 668 | M | Testmenü an Schirme ohne Kasten angleichen: Zurück, Trennlinien, Aufbau wie 549a/618 (Chef | ruht |
| 673 | M | Emulator: Kamera drehen und zoomen mit Maus und Tasten (rechte Maustaste ziehen, Mausrad), | ruht |
| 678 | M | Testmenü: Heldenstufe +1 geht über die Kapitelgrenze (Stufe 9 in Kapitel 1), Grenze auch b | ruht |
| 691 | K | Platzwechsel mit Leuten und Tieren: beide gleiten ineinander (Chef 03.11., 07:44, Test 204 | ruht |
| 687 | K | Tiefer Flüsterwald: Grimmzahn auf der Karte „steht ganz alleine rum und schaut eher aus wi | ruht |
| 688 | K | Frage des Chefs je Karte: wie viel Sammelbares offen und versteckt liegt (alt gegen neu: T | ruht |
| 689 | K | Dorf, Urteil Chef 25.10., 12:11 (aus 348.6, offen geblieben): Büsche über Dachfirsten, Lat | ruht |
| 698 | K | Grafikstufen im Systemmenü mit Effekten (Niedrig/Mittel/Hoch, Automatisch per Leistungstes | wartet auf 623 (wartet) |
| 613.2 | M | Zwischensequenzen: Bewegung sichtbar wie alt (Kerzenflackern, atmendes Licht, Staub im Str | ruht |
| 713 | K | Von Homer (586.1): Erklärfenster beim Gedrückthalten (menue.gd:1561) noch mit Goldrand und | ruht |
| 753 | M | Blende nach der Rast: „8 Stunden vergehen“ klein und futzelig, nicht im neuen Design (Chef | wartet auf Test/Build (gebaut) |
| 757 | M | Schenke: neuer Tisch 7/2 (aus 604) wirkt als 1:1-Kopie des Tischs vor der Theke, gleiche S | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 543 (schenke) |
| 758 | M | Borin sitzt an seinem Tisch wie alt (MapFolk.sits, Sitzposen, Krug statt Hammer); in Godot | startbar |
| 762 | M | Heldenreiter zeigt die BRS-Fertigkeiten mit Wert, Rang und Fortschritt, damit man sieht, w | startbar |
| 764 | M | Heldenreiter zeigt aktive Zustände (betrunken usw.) mit Erklärung; Tippen auf die Leiste ö | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 670 (menu) |
| 769 | M | Wochentermin 13.11.: Rollenspiegel Tom (rollenspiegel.sh Tom) (719); deckt 02.–13.11., Woc | Termin 13.11. 08:00 |
| 781 | M | „Über das Spiel“ nennt den MIT-Teil der REEBOO-Pakete (David Hoskins, Hashfunktionen in Gr | startbar |
| 756 | M | Gegenstände: wie Seltenheit, Abnutzung und übrige Merkmale bei anlegbarer Ausrüstung angez | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 522 (ausrustung) |
| 785 | M | Oberfläche einmal ganz gegen alt: jeder Schirm und jede Bedienung als eine Liste, jeder Un | startbar |
| 795 | M | BRS-Erschaffung, Platzwahl „Alle Spielstand-Plätze sind belegt“: noch Rahmen und Auslösen | Sperre 620.1 B: 16 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 773 (alle) |

**Jerry** – offen 74, Muss 68, startbar 4

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 778 | M | Von Tom (773): Build 272 rot an wolf_mess_438 (Kleriker gegen Wölfe: Wolf in Wolf 68 Bilde | wartet auf Test (Build 272) |
| 717 | M | Kampf: Gegner zeigt dem Helden nie den Rücken, außer auf der Flucht; nach dem Angriff rück | wartet auf Test (Build 272) |
| 717.1 | M | Kampf: Zurechtrücken der Gegner läuft gleichzeitig mit dem Zug des Helden statt davor (Ide | wartet auf Test (Build 272) |
| 682 | M | Kampf flüssiger: Held geht zügig zum Angriff, Gegner laufen in weichen Bögen statt eckig g | wartet auf Test (Build 272) |
| 709 | M | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angre | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 717 (angriffe) |
| 562 | M | MARS: Helden laufen zum Angriff viel zu langsam, zurück gleiten sie flott (Chef 04.11., 17 | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 717 (angriff) |
| 662 | M | Kampf (vorher 653): Parade des Helden mit Schild dreht über _face_sanft ohne Pfotenhalt, S | startbar |
| 593 | M | MARS: Ausweichen auch rückwärts als Abwechslung zu links und rechts (Chef 05.11., 19:2x) | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 717 (ruckwarts) |
| 406.2 | M | Angriff gehen statt rennen, Parade mit Schild je Richtung (Chef 03.11., 06:59, Schildfilm) | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 717 (angriff) |
| 438 | M | Wölfe im Kampf wirken gleitend: Angriff, Tempo, Vorbeigehen (Film 403, Chef 31.10., 23:31) | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 778 (wolfe) |
| 642 | M | Wölfe ineinander beim Anlauf und Biss neben einem ruhenden Wolf, bis 0,15 m (wolf_mess_438 | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 778 (wolf) |
| 679 | M | Kampf: im ersten Testkampf (Kleriker gegen Wölfe) fehlten Befehle und Knöpfe (Gewinnen, Ve | wartet auf Test/Build (gebaut) |
| 704 | M | Wolf allein ist harmlos, wenn der Held jedem angekündigten Sprung ausweicht: 300 von 300 S | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 778 (wolf) |
| 705 | M | Zauberlehrling Stufe 1 gewinnt gegen Wolf und Rudel selten (BRS 2–30 %, Messung anspringen | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 778 (wolf) |
| 702 | M | Wölfe: Anspringen nimmt dem Helden jeden Zug, Rudel hält ihn dauerhaft fest (Chef t270, 08 | wartet auf Test (Build 272) |
| 595 | M | Kampfbewegungen der Kaufgegner: Spinne mehr Angriffe, Egel und Schnecke schneller, Treffhö | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 717 (angriffe) |
| 616 | M | Kampf: Gegner weichen nach dem Angriff rückwärts zurück statt vorwärts zu laufen (Chef 07. | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 717 (angriff) |
| 532 | M | Kampf: Held geht ohne Zauberpunkte, Verbrauchtes, Zustände, Metrausch und ohne die ganze T | in Arbeit bei Tuffy |
| 536 | M | Kampf: Erklärungen bei langem Drücken (MarsTips), Grund bei gesperrtem Zauber, „Kein Ziel | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 679 (knopf) |
| 296.2 | M | MARS spielnötig: Beute/Erfahrung, Fliehen, Eröffnung, Zustände, eigene Ausrüstung, Schalte | startbar |
| 211.14 | M | Rest 211.13: Leistung A56, Puppen-Gegner im Kamerawinkel, Winkel je Platz, Wechsel als Gan | startbar |
| 551 | M | MARS: Rahmen des unteren Kastens links und rechts unterbrochen (Chef 04.11., 00:21) | ruht |
| 547 | M | MARS: Text sagt „geht in die Knie“, Sturz ist aus (438a eingefroren): Text und Bild in Ein | wartet auf Test (Build) |
| 534 | M | Kampf: Zauber und Fähigkeiten fehlen in „Können“ (Magierrüstung, Untote vertreiben, Spirit | ruht (424: altes SRD-System) |
| 467 | M | Ausdauer nach BRS statt SRD (ausdauer.gd: Konstitution, Stärke 13), Formel aus 427 (Chef 0 | ruht |
| 453 | M | Wölfe im Kampfort: Ruhebewegungen (atmen, scharren, umblicken, knurren) (Chef 01.11., 11:0 | ruht |
| 438a | M | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv | ruht |
| 416.6 | M | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef 31.10., 20:4x; 03.1 | ruht |
| 415 | M | Handyprobe Beams-Free-Sample (aus 414, Chef 31.10., 20:3x; „jetzt“ 01.11.) | wartet auf 623 (wartet) |
| 460 | M | Kamerafahrten im Kampfort: Eröffnung wie Drohnenflug je Blende, Wechsel der Perspektive oh | ruht |
| 406.1 | M | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann | wartet auf 469 (ruht) |
| 510 | M | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt ( | ruht |
| 509 | M | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot (Chef 03.11., 09:21; Po | ruht |
| 494 | M | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Woche | wartet auf 492 (startbar) |
| 517 | M | Waldklang wie alt: Vögel am Tag, Eule und Grillen nachts, fernes Wolfsheulen im Tiefen Wal | ruht |
| 507 | M | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager (Orte O10; aus 492) | ruht |
| 496 | M | Durchspiel-Build: Kapitel 1 von Anfang bis Ende am Handy (Wochenziel 03.11., 488) | ruht |
| 387 | M | Gekaufte Tiere schnell auf Bewegungen und unsere Haut prüfen, vor Eigenbau (Chef 27.10., 2 | ruht |
| 385.2 | M | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | wartet auf 623.2 (wartet) |
| 397 | M | Ruhebewegungen wie im alten Spiel, mindestens drei je Figur, für alle (Chef 28.10., 11:15) | ruht |
| 348.12c | M | Modellpaket auch gegen Geld (Quaternius QAL, Dungeon Monsters Kit, andere), Vorschlag mit | ruht |
| 304 | M | Klassischer Kampf: Konter nach Abwehr, obwohl getroffen, regeltechnisch richtig? (Chef 22. | ruht |
| 257 | M | Build 46: Meldung „App reagiert nicht“, warten oder schließen, läuft dann weiter (Chef 20. | ruht |
| 628 | M | Lohn: EP und Gold steigen nicht mit der Monsterstufe über der Gebietsstufe (over fehlt, al | ruht |
| 289 | K | MARS: Wechsel „halber Zug“ missverständlich; Bewegung und Aktion im Kästchen zeigen? (Chef | ruht |
| 344.2 | K | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | ruht |
| 168.1 | K | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | wartet auf 38 (ruht) |
| 72u.1 | K | Umsetzung 72u: Kampfort aus der Karte (Standbild 2, Bau) | ruht |
| 38 | M | Balance-Langzeitplan (DESIGN-BALANCE.md) | ruht |
| 39 | M | Schwierigkeitsgrad im Menü | ruht |
| 59e | K | Händler: Vorrat je Laden | ruht |
| 469 | M | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | ruht |
| 597 | M | MARS: Ring ohne Ankündigung (Fledermaus); alle Angreifer prüfen (Chef 05.11., 19:2x) | wartet auf Test (Build) |
| 601 | M | Goblin-Späher: Schuss ohne Bewegung, falscher Pfeil, kein Pfeil beim Fehlschuss; Treffer t | wartet auf 623 (wartet) |
| 623.2 | M | Effekte aus 623 A einbauen mit 478, in LISTE-BESTAND.md und LISTE-EFFEKTE.md mit Datenfeld | wartet auf 623 (wartet) |
| 598 | M | Umweltklang je Ort, Tageszeit, Wind und Wetter, lebendige Welt (Chef 05.11., 19:2x; Abnahm | ruht |
| 348.7a | M | Rückfrage: Geschosse flach oder in 3D | ruht |
| 399.2d | M | Godot am Rechner freigeben (Auto-Modus lehnte Download ab), Tests ohne CI-Lauf (aus 399.2) | ruht |
| 633 | M | Boss-Beute wie alt: Ogerhandschuhe (Krogg), Graks Streitaxt, Grimmzahn-Amulett fehlen im L | ruht |
| 634 | M | Schenkenklang wie alt: Rowena wischt, gießt, stellt Becher ab, Borin Flasche und Stuhl, im | ruht |
| 643 | M | Langbogen mit Köcher als Waffenmodell (daten/waffen/longbow.bin, Griff = Ursprung, Schaft | ruht |
| 649.1 | M | Figurenkatalog Schritt 1: eine Kennung je Monsterart, werte.json und tabellen.json zu BRS | ruht |
| 649.2 | M | Figurenkatalog Schritt 2: Werkzeug figuren.py und tools/figuren/figuren.json (Art und Auft | wartet auf 649.1 (ruht) |
| 649.4 | M | Zwei bis drei Handlungen je gewöhnlicher Monsterart vorschlagen und in 444 messen, nur wo | ruht |
| 644.1 | M | Gegenstandskatalog: Werkzeug mit Spalten, Teil Rezepte und Prüfungen (644 A), zusammen mit | ruht |
| 644.2 | M | Gegenstandskatalog: Zahlen nach 469 in 444 (Tempo, Parieren, Durchschlag, Güte, Stufe), C1 | ruht |
| 681 | M | Trinkgeräusch in drei Varianten beim Met und anderen Getränken (Chef 08.11., 16:16) | ruht |
| 744 | M | Karte: Streuner und Leute bewegen sich natürlich, verweilen mit Ruhebewegung statt Roboter | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 717 |
| 751 | M | Kampf: Knopfleiste des Helden manchmal leer („…“), keine Menüfunktion, auch ohne „ganzer B | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 778 (figur.gd) |
| 760 | M | Kampf: Wolf springt beim „Anspringen“ nicht, er beißt nur; Text und Bewegung passen nicht | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 778 (wolf) |
| 770 | M | Wochentermin 13.11.: Rollenspiegel Jerry (rollenspiegel.sh Jerry) (719); deckt 02.–13.11., | Termin 13.11. 08:00 |
| 784 | M | Kampf-Sollbild „Wolfsrudel, eine Runde“: wer geht wohin, Höchstdauer je Handlung, Ausweich | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 679 (wolfsrudel) |
| 786 | M | Klangliste alt gegen neu: je Anlass alt, neu, fehlt (654 A, als Drittes) | wartet auf 784 (startbar) |
| Pflege | K | von Werkzeug (340.3, 09.11.): 17083 Bytes (Grenze 15000), Erledigtes streichen | startbar |

**Perikles** – offen 20, Muss 7, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 511 | M | Kein Filmlauf ohne geprüftes Probebild vorher (Chef 03.11., 13:47: „Warum werden so viele | wartet auf Diogenes |
| 483 | M | Film-Links: jsDelivr liefert aus Zweig „bilder“ nichts mehr (über 50 MB), je Film eine Mar | wartet auf Diogenes |
| 464 | M | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählu | Termin 16.11. |
| 347.2 | M | Umsetzung Plan 347 nach Gegenprüfung (Chef 24.10., 16:30) | wartet auf 347 (startbar) |
| 276 | K | Fords Anleitung auf eine Seite (Empfehlung Sokrates zu 274) | ruht |
| 341 | M | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug u | Termin 16.11. |
| D75 | M | Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1); meldung.sh --film legte Film 572 nich | Dauerzeile |
| 99 | K | Zwei Niederlassungen | ruht |
| 725 | K | D72 probelauf.py: arbeitskopie/push_lauf lösen cd $VAR und cd "$HOME/…" nicht auf, figur_s | ruht |
| 726 | K | D73 probelauf.py gleich_film (578) prüft nur den Archivkopf, nicht das Ergebnis „→ ja (Nut | ruht |
| 727 | K | D62.2 lauf.py: Uhrzeit im Nachfolger („ab 16.11., 8 Uhr“) wird am Tag selbst nicht gelesen | ruht |
| 728 | K | D78.1 Testbitte: Zeile „Verglichen“ deckte bei t268 nur die Menüs, nicht Dorf, Kampf, Kapi | ruht |
| 729 | K | D85.1 startbar.py 620.1 B gibt auch „Rückläufer aus einem Build“ frei, Chef nannte nur wie | ruht |
| 730 | K | D86.1 probelauf.py: Ausnahme Sammelbuild gilt für jeden Ablauf auf claude/build-<n> (godot | ruht |
| 731 | K | D87.1 Prüfung „Alt:“ (647) greift nicht bei Push über den GitHub-Server (push_files, creat | ruht |
| 732 | K | D89.1 glossar.py: Begriff mit Bindestrich vorn geht als Schalter an git grep; -e davor (vo | ruht |
| 734 | K | D92.1 Warnung „LISTE-VORGAENGE.md von Hand geändert“ wird nirgends festgehalten, Woche War | ruht |
| 735 | K | D92.4 Überholtes ohne „→ ersetzt durch“ (461b): DESIGN-ABNAHME.md 11 und Kopf DESIGN-KAMPF | ruht |
| 742 | K | D78.1 Testbitte t268: Zeile „Verglichen“ deckte nur die Schirme vom 05.11., nicht Dorf, Ka | ruht |
| 791 | M | D111 von Diogenes (783, 745 A2 Schritt 3): Überholtes und Doppeltes im Regelwerk umschreib | wartet auf 783 (wartet) |

**Diogenes** – offen 10, Muss 9, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 511 | M | Kein Filmlauf ohne geprüftes Probebild vorher (Chef 03.11., 13:47: „Warum werden so viele | wartet auf D75 (Dauer) |
| 483 | M | Film-Links: jsDelivr liefert aus Zweig „bilder“ nichts mehr (über 50 MB), je Film eine Mar | wartet auf D75 (Dauer) |
| 461b | M | Nur Gültiges steht: neu ersetzt alt im selben Commit, Commit-Prüfung, Kennzahl Widersprüch | Termin 16.11. |
| 348.9 | M | Umzug Godot: Arbeitsteilung, Meilenstein, Modelle jetzt (Chef 25.10., 12:24) | ruht |
| 186.3 | K | Ausgefüllte Prüfbögen auswerten | ruht |
| 644.5 | M | Abnahme Gegenstands- und Figurenkatalog: Prüfungen des Werkzeugs grün, Godot liest nur noc | wartet auf 644.1 (ruht) |
| 768 | M | Wochentermin 13.11.: Rollenspiegel Diogenes (rollenspiegel.sh Diogenes) (719); deckt 02.–1 | Termin 13.11. 08:00 |
| 771 | M | Probe 657 auswerten: Erstfunde des Chefs t272–t275 gegen 11, 11, 9, 7 (von Perikles, Werkz | wartet auf Test t275 (Chef) |
| 783 | M | 745.1 Widersprüche und Doppelungen in CLAUDE.md, Rollendateien, Listen gegen das Archiv li | Chef (Datei in der Chefsache) |
| 790 | M | 383 A messen: eine Woche Kosten je Aufruf und je Sitzung vorher gegen nachher (Neustart ab | Termin 16.11. 18:07 |

**Sokrates** – offen 45, Muss 34, startbar 22

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 650.2 | M | docs Schritt 2 und 3: Abgelöstes nach alt/, Doppeltes zusammen, Gliederung (aus 650, Chef | Chef (Datei in der Chefsache) |
| 780 | M | Unity-Asset-Store-EULA 2.2.1 (keine Assets als Eingabe für KI-Programme): gilt sie für uns | Chef (Datei in der Chefsache) |
| 620 | M | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build | startbar |
| 623 | M | Effektpakete REEBOO Labs: Kauf, Ressourcenseite LISTE-QUELLEN.md, Zuordnung LISTE-EFFEKTE. | Chef (Datei in der Chefsache) |
| 508 | M | Lehrmeister in Kapitel 1 erreichbar (Geselle), Magie-Pflicht Paladin/Kriegsmagier, Wachsol | startbar |
| 461b.4 | M | Widersprüche aus Liste 461b: Köpfe Regelwerk, Bestiarium, DESIGN-KAMPF gegen Entscheidung | startbar |
| 481 | M | Herkünfte ausgleichen: Kräutersammler mit Kampftränken, Wachsoldat, Klosterschüler, Bewähr | startbar |
| 391 | M | Zweit-Repo dauerhaft in den Sitzungen, ohne Ablehnung (Chef 28.10., 09:21) | ruht |
| 383.2 | M | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | ruht |
| 374 | M | Wer prüft regelmäßig, dass alle 373 einhalten? (Chef 27.10., 11:54) | startbar |
| 348 | M | Fertige Spiel-Engine statt Selbstbau: Umzug nach Godot (Chef 24.10., 16:43) · „jetzt“ 24.1 | ruht |
| 26.1 | M | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef | ruht |
| 327 | K | Zweites Spiel: Marktsichtung Denkspiele, Modell ohne Werbung (Chef 23.10., 00:08; vertraul | nach dem Meilenstein |
| 347 | M | Paket „Regeltreue erhöhen, Kosten senken“ (Zähler, Kernregeln, kleiner Start) prüfen und u | startbar |
| 318 | M | Knappheit per Einstellung: Antwortstil „Knapp“ und Startanhang (Chef 22.10., 21:34) | startbar |
| 246.1 | K | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | nach dem Meilenstein |
| 296 | K | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MA | ruht |
| 264 | K | Arbeitsorte neben GitHub: NAS, Proxmox, ALL-INKL? (Chef 20.10.) | ruht |
| 263 | K | Rolle für Finanzen und Geschäftszimmer? (Chef 20.10.) | startbar |
| 366 | M | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | startbar |
| 365 | M | Aufwand „Hoch“ statt „Mittel“ für einzelne Rollen? (Chef 25.10., 12:36) | startbar |
| 262 | K | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | ruht |
| 253 | K | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf | ruht |
| 72c | K | Brainstorming Wunden bis zur Rast (Zeichen, Heilung mit Verband oder Tempel, schwere Wunde | nach dem Meilenstein |
| 167.6 | M | Morgenbericht mit Kennzahlen und Kostenbilanz (Chef 18.10.) | startbar |
| 142.3 | M | Tester öffentlich suchen (Chef 27.10., 19:32) | ruht |
| 142.4 | M | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 07.11.) | Termin 08.12. |
| 142 | M | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | startbar |
| 45 | M | Geschäftsmodell und Umsetzung (Play Store) | startbar |
| 109 | M | Repo öffentlich | startbar |
| 246 | K | Dokumente grundsätzlich ins Repo statt als Artefakt; Wochenplan aktualisiert (Chef 20.10.) | ruht |
| 284 | M | Bis zum Durchspielen (26) am Kampf nur Fehlerbehebung, kein Feinschliff (Vorschlag Sokrate | ruht |
| 340 | M | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Che | ruht |
| 344 | M | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23 | ruht |
| 644 | M | Alle Gegenstände an einer Stelle: Katalog 458 mit BRS-Werten, Voraussetzungen, Seltenheit, | wartet auf 644.1 (ruht) |
| 649 | M | Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten), Bestiarium ge | wartet auf 649.3 (ruht) |
| 650 | M | docs aufräumen: 88 Dateien, Erledigtes nach docs/alt/, Zusammenlegen, Inhaltsverzeichnis n | startbar |
| 654 | M | Mitdenken vor dem Bauen: Systemfrage je Fund („kommt das wieder?“), Wiederholungswächter, | startbar |
| 655 | M | Bilder: Ersteller sieht sein Bild selbst an, Regel 300 streichen statt neuer Vorprüfung (C | startbar |
| 739 | K | D84.1 die sechs wiederholten Funde aus t268 mit „wiederholt“ im Titel nachziehen (620.1 A; | startbar |
| 740 | K | D63.7 Vorlage entscheiden/3761-kettenhemd-heldin.md (01.11., 20:55) ohne Zeile „Bestand ge | startbar |
| 745 | M | Regelwerk konsolidieren: Widersprüche listen (Diogenes), Chef entscheidet, jede Regel an e | startbar |
| 765 | M | Wochentermin 13.11.: Rollenspiegel Sokrates (rollenspiegel.sh Sokrates) (719); deckt 02.–1 | Termin 13.11. 08:00 |
| 782 | M | Von Tom (697): ein Lauf am Rechner frei? Der erste (17:38) brach vor dem Zeichnen ab (Proj | startbar |
| 475 | M | Leute des Dorfs (Rowena, Borin …) auf Kaufkörper ihres Volks mit Gesicht, statt der alten | startbar |
## Lücken

Vom Werkzeug gefunden (D21.3): steht in der Vorgangsliste, hat hier keine Datei.

Format (Muster: „So geht's“ unten): t272-sammelbuild.md: Zeile 2 ist keine Bereichszeile

## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen als Bildvorschau (228, kein Build): `ansehen/<nr>-<stichwort>.md`, Zeile 1 `# <Nr.> · <Thema> · <Team> · <TT.MM.>, <HH:MM>`, dann Bild aus `bilder/` und der Satz, was der Chef sagen soll.
- Anzusehen (nur mit Build, Datei `ansehen/t<build>-<stichwort>.md`): Aufbau und Regeln nur in `LISTE-CHECK-BUILD-TEST.md` (657 D).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich> · …` (Bereich wie „B Abläufe“, 136); Vorrang = Klasse der Nummer in `LISTE-VORGAENGE.md`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann in dieser Folge (364): **Frage**, **Votum** (was der Chef tun oder sagen soll), **Berührt** (Vorgänge); darunter kurz **Begründung**, **Sachverhalt** (belegt, mit Quelle), **Auswertung** (mit dem stärksten Gegenargument), **Folgerungen** (was danach geschieht, wer); zuletzt `Antwort: …`. Lange Teile in `<details>`.
- Zu billigen (Vorentscheid, 194.1): `billigen/<nr>-<stichwort>.md`, Aufbau wie bei „entscheiden“, Votum = Entschieden, plus: Umgesetzt (Commit), Rückbau, Kosten; in der Auswertung bei Balance und Spielgefühl die verworfene Möglichkeit. Hält keine Arbeit an; Antwort „gebilligt“ oder „zurück“, Sokrates löscht die Datei und setzt „gebilligt TT.MM.“ oder „zurück TT.MM.“ in die Archivzeile.
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“. Ablage im Zweig `bilder` als `bilder:<pfad>` (z. B. `[Film](bilder:pruefung/x.mp4)`); die Übersicht macht daraus Links, Filme spielen im Browser (381.1).
- **Überarbeiten** (275, Chef 27.10., 15:23: „sonst schaue ich es mir am Schluss zweimal an“): wer eine Vorlage überarbeitet, löscht die Datei sofort und legt sie neu an, wenn die neue Fassung fertig ist; nie „folgt“, „kommt nach“ in einer Vorlage (die Übersicht meldet es unter „Lücken“).
- **Beantwortet oder zurück beim Team** (383.3, Chef 27.10., 19:55: „Sachen, die nicht mehr zur Vorlage sind, dann weg … Das ist kein Arbeiten so.“): wer eine Antwort des Chefs zu einer Vorlage einträgt (Vorgangsarchiv oder Vorrat), löscht die Datei im selben Commit, auch die eines anderen; bleibt ein Teil offen, legt der Besitzer sie neu an, sobald sie vorlegbar ist. Gilt die Antwort einer anderen Frage derselben Nummer, setzt er die Zeit in Zeile 1 oder 2 neu. Die Commit-Prüfung hält einen Archiveintrag an, dessen Vorlage stehen bleibt; Übersehenes meldet die Übersicht unter „Lücken“.
- Zu tun (275): `tun/<nr>-<stichwort>.md`, Zeile 1 `# <Nr.> · <was der Chef tun soll>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich>`, dann der Satz zum Kopieren als Codeblock oder der Weg in Schritten; erledigt heißt Datei löschen (wer sie angelegt hat). Ein „wartet auf Chef“ ohne Datei hier meldet `startbar.py` als Leiche.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
