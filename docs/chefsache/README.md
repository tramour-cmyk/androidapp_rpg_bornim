# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Überblick

Vom Werkzeug gerechnet (`tools/ueberblick.py`, 1313), Vorgangsliste vom 15.11., 23:28, neu bei jeder Änderung. Reihenfolge der Blöcke und ihren Zuschnitt legst du fest; vorziehen: sag es, wir setzen den Rang beim Besitzer.

**Themenblöcke**

| Block | offen | Muss | in Arbeit | zum Testen | ruht | nächster |
|---|---|---|---|---|---|---|
| **Kapitel 1 fertig (Godot, BRS)** | | | | | | |
| ↳ Umzug BRS, SRD ablösen | 4 | 3 | 0 | 0 | 1 | 870 (Sokrates) Umstellung ganz auf BRS, SRD-Parallelbetrieb been… |
| ↳ Kampf passt | 71 | 27 | 3 | 3 | 17 | 415 (Jerry) Handyprobe Beams-Free-Sample |
| ↳ Kleiderschrank und Modelle (Held, Leute, Monster) | 20 | 7 | 0 | 1 | 14 | 431 (Tom) Völker als Modelle: erst Bibliothek sichten, Kand… |
| ↳ Welt, Karten, Bild, Ton, Bedienung (auch was gegenüber Kotlin fehlt) | 64 | 12 | 2 | 8 | 33 | 1300 (Spike) atem_4531 zufällig rot, „nach 8 s wieder fast Ruh… |
| ↳ Godot besser nutzen (Technik, Build, Leistung) | 17 | 6 | 0 | 1 | 8 | 698 (Spike) Grafikstufen im Systemmenü mit Effekten |
| Werkzeuge und Abläufe der Firma | 59 | 34 | 0 | 0 | 9 | 1128.3 (Diogenes) ab Build 283 Funde und Rückschritte je Prüfart zä… |
| Marktstart | 10 | 0 | 0 | 0 | 8 | 780 (Sokrates) Unity-Asset-Store-EULA 2.2.1: gilt sie für unsere… |

**Die nächsten 20**

| # | Nr. | Wer | Worum | Kl. | Block | Stand |
|---|---|---|---|---|---|---|
| 1 | 415 | Jerry | Handyprobe Beams-Free-Sample | M | Kampf passt | startbar |
| 2 | 1072 | Jerry | Laufwege und Plätze im Kampf für alle Figuren: Zweiertausch im Heldenteam, Mons… | M | Kampf passt | startbar |
| 3 | 1288 | Sokrates | Kerben: Verstreichen lassen oder eine Kerbe in den nächsten Zug mitnehmen; Lück… | M | Kampf passt | startbar |
| 4 | 601.1 | Jerry | Pfeil trifft die Fußspitze, der Getroffene zuckt oben zurück; Einschlagstelle u… | M | Kampf passt | startbar |
| 5 | 1275 | Jerry | Kerbensystem auf dem Zweig weicht von DESIGN-GLUT.md ab: Taumeln nach Gegenschl… | M | Kampf passt | startbar |
| 6 | 1291 | Jerry | Waffe in der Nebenhand wirkt im BRS-Kampf nicht; Nebenhand nur Schild, Fackel,… | M | Kampf passt | startbar |
| 7 | 1292 | Jerry | Klosterschüler gewinnt immer, Ursache rechnen, Vorlage an den Chef | M | Kampf passt | startbar |
| 8 | 1305 | Jerry | Kämpfer mit Schwert und Schild läuft in die hintere Reihe und schlägt dort eine… | M | Kampf passt | in Arbeit |
| 9 | 1323 | Jerry | Kampfmeldungen ohne TP/HP, „+{1} Leben“ / “+{1} Life”; Reste siehe Zu-Absatz | M | Kampf passt | startbar |
| 10 | 1333 | Jerry | Aus 930.6: Regelkern meldet Schildstoß und schweren Treffer an ragdoll.gd | M | Kampf passt | startbar |
| 11 | 1340 | Jerry | Aus 1215: Sterben mit Physik fehlt noch für Skelett und Wiedergänger | M | Kampf passt | startbar |
| 12 | 1284a | Jerry | Rückfrage zu 1284: wie wird der Rattenbiss hinter dem Helden sichtbar? | M | Kampf passt | startbar |
| 13 | 431 | Tom | Völker als Modelle: erst Bibliothek sichten, Kandidaten drehend im Film vorlege… | M | Kleiderschrank und Modelle | startbar |
| 14 | 1285 | Jerry | Held rennt schon bei kleinen Joystick-Bewegungen, große Laufschritte statt Gehe… | M | Kleiderschrank und Modelle | startbar |
| 15 | 1300 | Spike | atem_4531 zufällig rot, „nach 8 s wieder fast Ruhe“ | M | Welt, Karten, Bild, Ton, Bedienung | in Arbeit |
| 16 | 1341 | Tom | Bild t290.6 neu, zeigt keine Gegenstandsnamen; Prüfpunkt klar formulieren, sieh… | M | Welt, Karten, Bild, Ton, Bedienung | startbar |
| 17 | 1303 | Spike | Stufen im Dunkel im Renderer mobile, Höhle: dunkle Flächen in Flecken statt Ver… | M | Welt, Karten, Bild, Ton, Bedienung | startbar |
| 18 | 698 | Spike | Grafikstufen im Systemmenü mit Effekten | M | Godot besser nutzen | startbar |
| 19 | 1128.3 | Diogenes | ab Build 283 Funde und Rückschritte je Prüfart zählen, Bautests „ohne dich“ am… | M | Werkzeuge und Abläufe der Firma | startbar |
| 20 | 1286 | Spike | Strahlprobe wirft nach dem Verlassen Fehler am A56, Build 286: busy/figures auf… | K | Kampf passt | startbar |

Danach 84 weitere offen. Bei dir zum Testen (vorgelegt): 13. Gebaut, fährt mit dem nächsten Build: 10. Werkzeug gebaut, Prüfung Diogenes: 28. Ruhend oder nach dem Meilenstein: 90.
## Zu entscheiden

Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136).

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [1284a](entscheiden/1284a-rattenbiss-sicht.md) | **Muss** | E Kampf | 15.11., 23:03 | Die Ratte beißt von hinter dem Helden und ist verdeckt; Platz zur Seite reicht nur, wo er frei ist. | Jerry |

## Zu billigen

Nichts offen.

## Anzusehen

**Builds** (installieren und testen; Folge = Version aufsteigend, Android installiert nur höhere Nummern über niedrigere):

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.348.506](ansehen/t290-sammelbuild.md) | [Build 290](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43764236337/artifacts/14182745059) | Sammelbuild: Menü wie alt, Karte, Ausrüstung, Wechsel | Tom und Jerry | 15.11., 22:59 |

## Zu tun

Nichts offen.

## Offen je Rolle

Vom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand 15.11.; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.

**Homer** – offen 4, Muss 0, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 302 | K | Bildsignatur: ist unsere Grafik wiedererkennbar, wie wird sie es? (Chef 22.10., 12:12); ja | wartet auf 302.1 (ruht) |
| 1235 | K | Texte Kapitel 2 bauen (Rest aus 41; Entwurf kapitel2/STORY-K2-ENTWURF.md, Storyplan K2 fer | nach dem Meilenstein |
| 1344 | K | Von Tom (870.20): Testerseite tester.de/en.html nennt Klassen und SRD 5.1; neuer Satz nach | startbar |
| Pflege | K | von Werkzeug (340.3, 15.11.): Übergabe über 700 Zeichen (nur Getanes und Nachfolger, Stand | startbar |

**Tom** – offen 71, Muss 18, startbar 3

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1044 | M | Von Sokrates (Chef 12.11., 16:08; 13.11., 09:35 zurück bis auf Lyra): Leute stehen außerha | wartet auf Sokrates |
| 1345 | M | Von Jerry (Build 290, Lauf 504 rot): lage_785_8 „Lage herstellen endet“ und lage_1156 „Lag | wartet auf Test t290 (Chef) |
| 1341 | M | Von Sokrates (1309, Chef 15.11., 21:42): Bild t290.6 neu, zeigt keine Gegenstandsnamen; Pr | startbar |
| 1325 | M | Rot: ziege_4162 auf dem Bauserver in Lauf 499 und 500 (Build 288 nach Reverts, Ziegencode | wartet auf Test (Build 290) |
| 431 | M | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, da | startbar |
| 568 | K | Ernten als Handlung statt Einsaugen; Angeln mit Pose und Ring (Chef 04.11., 19:42: ja, A) | ruht bis 23.11. |
| 531 | M | Build 249: Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertreibt Tiere | wartet auf 643 (ruht) |
| 515 | K | Truhen: 3–4 je Karte halb versteckt, verschlossene nach BRS (Dietrich, Aufbrechen) (Chef 0 | wartet auf 870 (wartet) |
| 376.1 | K | Probeblatt Quaternius-Figuren mit Bewegungsraster als Film (Chef kaufte 27.10., 12:20) | ruht bis 23.11. |
| 455.1 | K | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 1 | ruht bis 23.11. |
| 513 | M | Ein Figurenstand für alle Zweige; Schild, Robe Magier, Umhang jetzt (Chef 03.11., 15:56, „ | ruht bis 23.11. |
| 476 | K | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | wartet auf 458.3 (ruht) |
| 458.3 | K | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | ruht bis 23.11. |
| 423.1 | K | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | ruht bis 23.11. |
| 455.2 | K | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völker (Chef 01.11., 11: | ruht bis 23.11. |
| 385 | M | Protofactor-Animsets (Zauberer u. a.) auf die Listen, Probe ob nutzbar (Chef 27.10., 20:59 | ruht bis 23.11. |
| 372 | K | Feinschliff Held am Ende des Umzugs: Kettenhemd, Helm, Kragen (aus 338a B, Chef 27.10., 09 | ruht bis 23.11. |
| 348.13b | K | Tusche auch nach Fackeln, Feuer, Fenster; zuerst Dorf (Chef 28.10., 08:09 ja) | ruht bis 23.11. |
| 302.3 | K | Intro und Outro mit Tusche im Zeichner, etwas kräftiger als Intro 4 (Chef 23.10., 10:45) | ruht bis 23.11. |
| 302.2 | K | Tusche auf der Gebietskarte (Chef 22.10., 23:50); zurückgestellt (Chef 23.10., 10:45) | ruht bis 23.11. |
| 302.1 | K | Tuschelinie für Menschengestalten (Chef 22.10., 20:25, über Sokrates); jetzt nicht (Chef 2 | ruht bis 23.11. |
| 292.4 | K | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., | ruht bis 23.11. |
| 145 | K | Karten je Kapitel zum Drucken | ruht bis 23.11. |
| 417.1 | K | Restmängel Tragart nach „417 passt“ (Schildabstand, Rumpfdrehen, Fußrutschen, Kornfeld, St | ruht bis 23.11. |
| 558.1 | K | Prüferrest Robe Probe 5 nachhalten, nicht bauen; Chef sieht es nach dem Durchspielen an (C | ruht bis 23.11. |
| 447.4.1 | K | Bau Lehrmeister, Meisterschaften, Ruf Kapitel 1 (447.4) | wartet auf 508 (startbar) |
| 622 | K | Godot-Build als AAB für Play: dieselbe App de.bornim.game, mit dem Upload-Schlüssel des al | ruht bis 16.11. |
| 41.2 | K | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | wartet auf 1235 (nach Meilenstein) |
| 134 | K | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | aufgeteilt |
| 348.1 | M | Vergleichsbild Gebietskarte alt/neu, 64 (heute) und 128 je Kachel (Chef 24.10., 16:51, „je | ruht bis 23.11. |
| 531a | K | Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast kaufen? (Chef 04.11., 19:27) | ruht bis 23.11. |
| 649.3 | K | Figurenkatalog: Bewohner, Händler, Lehrmeister, Söldner füllen (Tagesablauf, Laden, Stimme | wartet auf 649.2 (ruht) |
| 644.4 | K | Gegenstandskatalog: Ladenbestand und Rezepte aus texte.json und Kotlin in den Katalog umst | wartet auf 644.1 (ruht) |
| 691 | K | Platzwechsel mit Leuten und Tieren: beide gleiten ineinander (Chef 03.11., 07:44, Test 204 | ruht bis 23.11. |
| 688 | K | Frage des Chefs je Karte: wie viel Sammelbares offen und versteckt liegt (alt gegen neu: T | ruht bis 23.11. |
| 689 | K | Dorf, Urteil Chef 25.10., 12:11 (aus 348.6, offen geblieben): Büsche über Dachfirsten, Lat | ruht bis 23.11. |
| 816 | K | Effekte Szene 1 Dorf am Abend nach LISTE-EFFEKTE (Reihenfolge 623.8): gedämpft, Bilder/s n | wartet auf 698 (startbar) |
| 839 | K | Von Homer (817): Erklärtexte der Grundwerte im Reiter Held nach BRS einbauen, Texte STORY- | ruht bis 23.11. |
| 852 | K | Von Homer (432a A, Chef 10.11., 12:05): Aschgeborene bauen: Modell Mensch mit aschgrauer S | ruht bis 23.11. |
| 861 | K | Von Sokrates (Chef 10.11., 13:12, Bild t274.14): Umhang des Kämpfers im Kampf rechts am Rü | wartet auf 431 (startbar) |
| 966.2 | K | Von Sokrates (966 A neu, Chef 11.11., 15:58): Kochen und Alchemie mit Ring wie Knacken (DE | wartet auf 870 (wartet) |
| 954a.5 | K | Von Perikles (954a.2): Schleichen auf der Gebietskarte: Schleichtaste, geduckt und langsam | wartet auf 870 (wartet) |
| 954a.7 | K | Von Perikles (954a.2, 954a.3 A): Spähen durch Verweilen: Ring zeigt Heilkräuter abseits de | wartet auf 870 (wartet) |
| 954a.12 | K | Von Perikles (954a.2): Erschaffung: nicht wählbare Fertigkeiten (Bergbau, Angeln, Lederarb | wartet auf 870 (wartet) |
| 954a.9 | K | Von Perikles (954a.2, 954a.3 B): Schmiedelehrling flickt selbst an Borins Amboss mit dem R | wartet auf 870 (wartet) |
| 976 | K | Von Sokrates (Chef 11.11., 16:31): Rezeptbuch für alle Handwerke (Rezeptliste DESIGN-BRS H | wartet auf 966.2 (wartet) |
| 785.8 | K | Von Spike (785): Karte im Menü: Lagerfeuer-Marken und Zielmarke eines Auftrags wie alt (Me | wartet auf Test (Build 290) |
| 785.20 | K | Von Spike (785): Klick-Klang auch auf Knöpfen im Stil 549a (PanelContainer: Spielstände, E | wartet auf Test (Build 290) |
| 785.21 | K | Von Spike (785): Android-Zurück wie alt: in der Welt öffnet sie das Menü (WorldScreen.kt 1 | wartet auf Test (Build 290) |
| 785.22 | K | Von Spike (785): Leiste zeigt den Zustand „Satt“ wie alt (WorldScreen.kt 2856–2872; zustan | wartet auf Test (Build 290) |
| 785.23 | K | Von Spike (785): Renntaste geht von selbst aus, wenn der Held steht oder außer Atem ist (W | wartet auf Test (Build 290) |
| 785.24 | K | Von Spike (785): Laden: Vorräte mit Wirkungszeile in der Liste wie alt (ShopScreen.kt 226– | startbar |
| 1155 | K | Von Sokrates (623.8 A, Chef 09.11., 22:23; Lücke, Chef 13.11., 15:12 „wann kommt … Teich u | ruht |
| 1157 | K | Von Sokrates (Archivprüfung, 1038 A R1, Chef 12.11., 16:24): Verband herstellen mit dem Re | wartet auf 976 (startbar) |
| 1158 | K | Von Sokrates (Archivprüfung, 558 Probe 4, Chef 04.11., 19:48): Oberflächen für Leder und M | ruht |
| 1167 | K | Von Sokrates (Archivprüfung, 453.1 Chef 01.11.; 453a B 02.11.): Atmen für die Dorftiere (g | ruht |
| 1174 | M? | Von Sokrates (Archivprüfung, 348.10 Chef 25.10., 16:36 „brauchen wir auf jeden Fall“; Zwec | wartet auf 431 (startbar) |
| 1185 | M | Von Perikles (1183, 1020 D): pruefliste.py warnt im Prüfschritt bei jeder Zeile ohne Eintr | wartet auf Diogenes |
| 1195 | M | Von Spike (Lauf 442): hoehle_492 rot ohne Höhlenänderung, Kampf endet mit NONE (Sperre 102 | wartet auf Test/Build (gebaut) |
| 1205 | K | Von Sokrates (Chef 13.11., 18:48): Wiesen und Blumenfelder mit mehr Pflanzen aus dem Grass | ruht |
| 1211 | M? | Von Sokrates (Prüfauftrag Chef 13.11., 19:10): Leuchtfunke mit R7 rocket_trail als Schweif | ruht |
| 1210 | K | Von Sokrates: Regen wie alt (D3.10) fehlt in Godot; Bild ohne Vorgang (R8 Weather FX statt | ruht |
| 1247 | K | Von Tom (1242): Haken 621 A erkennt Freigabe „<Nr>, Lauf frei“ (Einzahl) und Freigaben unt | Termin 16.11. |
| 1280 | K | Funde und Abgleich alt, Team Tom (1271a A, Chef 15.11., 11:23): 569, 570, 589, 590, 665, 6 | nach dem Meilenstein |
| 1295 | M | Von Sokrates (Chef 15.11., 13:41, Bild Handy, Build 286, Karte Blutzahnhöhle): Kartenblatt | wartet auf Test (Build 290) |
| 1297 | M | Von Sokrates (431, Chef 15.11., 14:32): Schildgröße je Körper, beim Halbling ist der Schil | wartet auf 431 (startbar) |
| 1304 | M | Von Sokrates (Chef 15.11., 17:13, Bild Ausrüstungsseite, wohl Build 288): Kampfstab in der | wartet auf Test (Build 290) |
| 1309 | M | Von Sokrates (Chef 15.11., 18:20, Bild Ausrüstungsseite Build 288, 17:12): Feld „Kopf“ rut | wartet auf Test (Build 290) |
| 1322 | M | Von Homer (1320, Chef 15.11., 20:15): Spielertexte der Oberfläche ohne TP/HP, Wert heißt L | wartet auf Test/Build (gebaut) |
| 870.20 | M | Von Sokrates (870, Schritt 9, auf build-289): SRD-Reste aus den Daten (held.json grundform | wartet auf Test/Build (gebaut) |
| 1326 | M | Von Sokrates (Chef 15.11., 20:33): Build-Name (Nummer des Builds) im Hauptmenü und in „Übe | wartet auf Test/Build (gebaut) |

**Jerry** – offen 76, Muss 28, startbar 29

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1331 | M | Sammelbuild: alle fertigen Zweige beider Teams, Nummern siehe „Zu 1331“; Prüfliste ansehen | startbar |
| 1321 | M | Von Jerry (1305, 481.2): Held ohne Wurzelweg weicht am Ort aus, die Bewegung schwingt den | wartet auf Test/Build (gebaut) |
| 1314 | M | Von Jerry (t289, Lauf 497 rot): Typen-Sperrklinke 1268.3 nach dem Mischen, tod_ragdoll_121 | wartet auf Test (Build 290) |
| 760 | M | Kampf: Wolf springt beim „Anspringen“ nicht, er beißt nur; Text und Bewegung passen nicht | Halt (Vorrat oben) |
| 1289 | M | Von Spike (Chef 15.11., 12:34): Höhle im Renderer mobile ganz anders als bisher: zu hell, | wartet auf Test/Build (gebaut) |
| 1284 | M | Von Chef (15.11., 12:07, Test Build 286, Wald): Riesenratte sagt „Biss“ an, Bericht „Riese | startbar |
| 1068 | M | Von Perikles (1048 A, H, D, Chef 12.11., 20:05): Ring bei jedem großen Schlag der Gegner ( | wartet auf 1072 (startbar) |
| 1043 | M | Von Sokrates (Chef 12.11., 15:52, Fund t278.33 Build 280, zu 988): MARS-Probekampf Wölfe, | wartet auf 760 (startbar) |
| 1032 | M | Von Sokrates (Chef 12.11., 14:08, Build 280, MARS-Probekampf Wölfe, Held und Söldner Wachs | wartet auf 760 (startbar) |
| 1072 | M | Laufwege und Plätze im Kampf für alle Figuren: Zweiertausch im Heldenteam, Monster zu eins | startbar |
| 709.1 | M | Wolf und Grimmzahn beißen den Helden mit Schild sichtbar (aus 709 abgetrennt, Chef 10.11., | wartet auf Sokrates |
| 506.2 | M | Grabhund-Biss reicht sichtbar bis zum Helden, nicht nur knapp an den Schild (von Sokrates, | wartet auf 709.1 (ruht) |
| 709 | M | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angre | wartet auf Sokrates |
| 642 | M | Wölfe ineinander beim Anlauf und Biss neben einem ruhenden Wolf, bis 0,15 m (wolf_mess_438 | ruht bis 23.11. |
| 438a | K | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv | ruht bis 23.11. |
| 416.6 | K | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef 31.10., 20:4x; 03.1 | ruht bis 23.11. |
| 415 | M | Handyprobe Beams-Free-Sample (aus 414, Chef 31.10., 20:3x; „jetzt“ 01.11.) | startbar |
| 406.1 | K | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann | wartet auf 469 (ruht) |
| 510 | K | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt ( | ruht bis 23.11. |
| 509 | K | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot (Chef 03.11., 09:21; Po | ruht bis 23.11. |
| 494 | K | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Woche | ruht bis 23.11. |
| 517 | K | Waldklang wie alt: Vögel am Tag, Eule und Grillen nachts, fernes Wolfsheulen im Tiefen Wal | ruht bis 16.11. |
| 507 | K | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager (Orte O10; aus 492) | ruht bis 16.11. |
| 496 | K | Durchspiel-Build: Kapitel 1 von Anfang bis Ende am Handy (Wochenziel 03.11., 488) | ruht bis 16.11. |
| 385.2 | K | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | wartet auf 623.2 (startbar) |
| 344.2 | K | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | ruht bis 23.11. |
| 168.1 | K | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | startbar |
| 39 | K | Schwierigkeitsgrad im Menü | ruht bis 23.11. |
| 59e | K | Händler: Vorrat je Laden | ruht bis 23.11. |
| 469 | K | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | ruht bis 16.11. |
| 623.2 | K | Effekte Szene 2 Wolfskampf und Szene 3 Höhle einbauen (623.8 A, Chef 09.11., 22:23; vorher | startbar |
| 598 | K | Umweltklang je Ort, Tageszeit, Wind und Wetter, lebendige Welt (Chef 05.11., 19:2x; Abnahm | ruht bis 16.11. |
| 643 | M | Langbogen mit Köcher als Waffenmodell (daten/waffen/longbow.bin, Griff = Ursprung, Schaft | ruht bis 16.11. |
| 649.2 | K | Figurenkatalog Schritt 2: Werkzeug figuren.py und tools/figuren/figuren.json (Art und Auft | ruht bis 16.11. |
| 649.4 | K | Zwei bis drei Handlungen je gewöhnlicher Monsterart vorschlagen und in 444 messen, nur wo | ruht bis 16.11. |
| 644.1 | K | Gegenstandskatalog: Werkzeug mit Spalten, Teil Rezepte und Prüfungen (644 A), zusammen mit | ruht bis 16.11. |
| 644.2 | K | Gegenstandskatalog: C1 Fertigkeit +1/+2 ab episch ohne Pflicht-Nachteil (Chef 14:32), C2 S | ruht bis 16.11. |
| 681 | K | Trinkgeräusch in drei Varianten beim Met und anderen Getränken (Chef 08.11., 16:16) | ruht bis 16.11. |
| 931 | M | Von 784 A (Chef 11.11., 12:15): Wolf vorn – „Anspringen!“ steht, während er sich duckt (ke | wartet auf 760 (startbar) |
| 930.3 | K | Von Sokrates (930): Rechnung (fertig, handgemenge_930.md) und Film zur Regelseite Handgeme | wartet auf 931 (startbar) |
| 954a.6 | K | Von Perikles (954a.2): Hinterhalt aus dem Schleichen: unbemerkt bis zum Angriff, Kampf beg | wartet auf 870 (wartet) |
| 954a.8 | K | Von Perikles (954a.2): Wurfwaffen: Grundform Wurfmesser (auch für die Elstern, Truhe cave_ | wartet auf 870 (wartet) |
| 954a.10 | K | Von Perikles (954a.2, 954a.3 A): Tiere beruhigen vor dem Kampf: Wolf, Wildschwein, Riesenf | wartet auf 870 (wartet) |
| 954a.11 | K | Von Perikles (954a.2): Jagd: Tiere geben öfter Fell, Fleisch, Hauer (tabellen.json), Auftr | wartet auf 870 (wartet) |
| 954a.13 | K | Von Perikles (954a.2, D): Volksmerkmal Glückskind (Hügelvolk) wirkt nur im alten Kampf kla | wartet auf 870 (wartet) |
| 785.9 | K | Von Spike (785): MARS-Probekampf im Systemmenü mit Regelseite (Reihen, Ansagen, Ring, Perf | startbar |
| 785.10 | K | Von Spike (785): Rest aus 536, auf dessen Zweig und main nicht gebaut: Erklärung je Zauber | startbar |
| 785.11 | K | Von Spike (785): Zielwahl im Kampf: Reihe in der Zielliste, gleichnamige Gegner unterschei | startbar |
| 785.12 | K | Von Spike (785): Ring: Ersthinweis am ersten Ring und Erklärung des Zeichens im Bericht; U | startbar |
| 785.13 | K | Von Spike (785): Eingebung beim ersten Schlag von hinten (SK 571–573); Ersthinweis vordere | startbar |
| 785.14 | K | Von Spike (785): Langes Drücken auf eigene Figur oder Gruppenkasten zeigt Waffe, Mana, „ha | startbar |
| 785.15 | K | Von Spike (785): Erklärfenster im Kampf lässt sich wegtippen und verschwindet während des | startbar |
| 785.16 | K | Von Spike (785): Raster- und Würfelschalter im Kampf über Kämpfe gemerkt (GameViewModel.kt | startbar |
| 785.17 | K | Von Spike (785): Zurück-Taste im Kampf schließt das Untermenü (SK 364; zurueck.gd: im Kamp | startbar |
| 785.18 | K | Von Spike (785): Stufenaufstieg im Endfeld des Kampfes hervorgehoben (alt eigenes Feld „St | startbar |
| 999.2 | M? | Von 999: Armbrust als Waffenmodell im Kampf (Ersatzwaffe der Probehelden, light_crossbow); | ruht bis 23.11. |
| 1036.1 | K | Von Tuffy (1036, Chef 12.11., 20:52): neue Vorlage Zustände, jeder Zustand des Codes mit a | ruht bis 20.11. |
| 1165 | K | Von Sokrates (Archivprüfung, 490/493 Chef 03.11. „nach dem Durchspielen“): Prüferbefunde K | wartet auf 496 (ruht) |
| 1224 | K | Von Tom (aus 1041, Rest Commit d1cfba877): Berührungsprüfung beim Platztausch (Netze beide | wartet auf 1072 (startbar) |
| 1250 | K | Von Jerry (1000): grak_348 (godot-kampf.yml) rot schon auf main aeb8e0eb0, 11 FEHLER: Plat | wartet auf Test/Build (gebaut) |
| 481.2 | M | Von Sokrates (481a A, Chef 15.11., 10:51): Rechnung glut2.py mit Deckel des Abzugs von Rüs | wartet auf Test (Build 290) |
| 601.1 | M | Von Sokrates (601, Chef 15.11., 11:02): Pfeil trifft die Fußspitze, der Getroffene zuckt o | startbar |
| 1275 | M | Von Homer (1267): Kerbensystem auf dem Zweig weicht von DESIGN-GLUT.md ab: Taumeln nach Ge | startbar |
| 1281 | K | Funde und Abgleich alt, Team Jerry (1271a A, Chef 15.11., 11:23): 551, 289, 628, 634, 936, | nach dem Meilenstein |
| 1285 | M | Von Chef (15.11., 12:09, Test Build 286, Höhle): Held rennt schon bei kleinen Joystick-Bew | startbar |
| 1291 | M | Von Tom (785.5): Waffe in der Nebenhand wirkt im BRS-Kampf nicht (aufruf.gd blatt „off“ li | startbar |
| 1292 | M | Von Sokrates (481.2 A, Chef 15.11., 12:44): Klosterschüler gewinnt immer, Ursache rechnen, | startbar |
| 1296 | M | Von Sokrates (Chef 15.11., 14:48, Build 287, Probekampf Wolfsrudel): goldene Eingebung bei | wartet auf Test (Build 290) |
| 1305 | M | Von Sokrates (Chef 15.11., 17:18, Probekampf 3 Wölfe, wohl Build 288): Kämpfer mit Schwert | startbar |
| 1319 | K | Von Homer (1318): Kampfmeldung MSG532_CURED (mars.gd 430) „von allen Leiden befreit“ / “cu | startbar |
| 1323 | M | Von Homer (1320, Chef 15.11., 20:15): Kampfmeldungen ohne TP/HP, „+{1} Leben“ / “+{1} Life | startbar |
| 508.1 | K | Von Sokrates (508): Simulation 444 mit Übung außerhalb des Kampfes in Kapitel 1; ab welche | startbar |
| 1327 | K | Von Sokrates (aus 1215, t289.2 ✓): Regeln melden Schildstoß und schweren Treffer an ragdol | startbar |
| 1333 | M | Aus 930.6 (Rest 1215, Sokrates t289.2): Regelkern meldet Schildstoß und schweren Treffer a | startbar |
| 1336 | K | Aus 1141 (Jerry 13.11., 18:55): Robe des Goblin-Schamanen fällt steif, Schattenseite zu du | startbar |
| 1340 | M | Aus 1215 (Jerry 15.11., 13:08): Sterben mit Physik fehlt noch für Skelett und Wiedergänger | startbar |

**Spike** – offen 19, Muss 9, startbar 7

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1300 | M | Von Tom (Build 288): atem_4531 zufällig rot, „nach 8 s wieder fast Ruhe“ (Lauf 492 rot: 1, | startbar |
| 1270.4 | K | Von Sokrates (1270 A, Chef 15.11., 10:51; 22:43 Film statt Bild), Bau Spike: Vergleichsfil | startbar |
| 1303 | M | Von Jerry (zu 1289): Stufen (Banding) im Dunkel im Renderer mobile, Höhle: dunkle Flächen | startbar |
| 698 | M | Grafikstufen im Systemmenü mit Effekten (Niedrig/Mittel/Hoch, Automatisch per Leistungstes | startbar |
| 1145 | K | Von Sokrates (Chef 13.11., 14:35/14:45, Build 282): Höhle fühlt sich hakelig an, Bilder/s | startbar |
| 1286 | K | Von Spike (zu 415): Strahlprobe wirft nach dem Verlassen Fehler am A56, Build 286: busy/fi | startbar |
| 1307 | K | Von Spike (1268.3): Sperrklinke Typen, nach dem Mischen von claude/spike-1268-3-typen: in | startbar |
| 1270.3 | M | Von Sokrates (1270 A, Chef 15.11., 10:51), Bau Spike: Shader-Vorbau beim Export (export_pr | wartet auf Test/Build (gebaut) |
| 1268.1 | M | Von Sokrates (1268 A, Chef 15.11., 10:51), Bau Spike, nach 1270: je Fehlerart eine Stelle | wartet auf Test/Build (gebaut) |
| 1268.2 | M | Von Sokrates (1268 A, Chef 15.11., 10:51), Bau Spike, nach 1270: schnelle Tests in einem G | wartet auf Diogenes (greift?) |
| 1268.3 | M | Von Sokrates (1268 A, Chef 15.11., 10:51), Bau Spike, nach 1270: Warnungen fehlender Typen | wartet auf Test/Build (gebaut) |
| 1268.5 | M | Von Sokrates (1268 A, Chef 15.11., 10:51), Bau Spike, nach 1270: Bildrate und Ladezeit je | wartet auf Diogenes (greift?) |
| 1335 | M | Von Sokrates (Chef 15.11., 21:09), für Spike nach 1328.1: wolf_mess_438 ohne Messrauschen | wartet auf Diogenes (greift?) |
| 918 | K | Von Sokrates (Chef 11.11., 09:53 „1 ja, 2 ja“): godot.yml lässt alle Tests durchlaufen, AP | ruht |
| 474 | K | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, M | ruht bis 23.11. |
| 30 | K | Abstürze beim Testen | ruht bis 23.11. |
| 673 | K | Emulator: Kamera drehen und zoomen mit Maus und Tasten (rechte Maustaste ziehen, Mausrad), | ruht bis 16.11. |
| 348.13 | K | Tusche nach Licht wie entschieden (Chef 26.10.) | ruht bis 23.11. |
| 348.2 | K | Tusche nach Licht auch am Helden, Innenlinien an Bäumen: zweites Vergleichsbild jetzt (Che | ruht bis 23.11. |

**Perikles** – offen 30, Muss 24, startbar 1

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1328.1 | M | Von Sokrates (1328, Chef 15.11., 21:05): Spike eigene Rolle Technik (Grafiktechnik, Leistu | wartet auf Diogenes (greift?) |
| 1334 | M | Von Sokrates (Chef 15.11., 21:09): Wiederholrot-Wächter: derselbe Test zum zweiten Mal rot | wartet auf Diogenes (greift?) |
| 1148 | M | Von Ford (13.11., 14:58): lauf.py startet/archiviert Spike 882.1 wiederholt, obwohl dessen | Termin 16.11. |
| 1332 | M | Von Sokrates (Chef 15.11., 21:07): „zu testen, ohne Rückmeldung“ nie liegen lassen: sofort | wartet auf Diogenes (greift?) |
| 1313 | M | Von Sokrates (Chef 15.11., 19:37): Überblick in der Chefsache: die nächsten 20 Vorgänge in | wartet auf Diogenes (greift?) |
| 1312 | M | Von Sokrates (Chef 15.11., 19:28): Fertiges nie liegen lassen: Werkzeug mischen (1311), Sp | Termin 17.11. |
| 1254 | M | Von Chef (14.11., 21:08 „Runs … mit den vorgerenderten Modellen schneller“): Läufe auf Zwe | Termin 17.11. |
| 1246 | M | Von Chef (14.11., 10:28, Fehler): nachts warten alle aufeinander; Pause ohne Datum sperrte | Termin 17.11. |
| 1217 | M | Von Sokrates (Chef „jetzt“ 13.11., 19:58/20:01): Testbitte unterwegs: Reiter „Test“ der AP | wartet auf Diogenes (greift?) |
| 1192 | M | Von Sokrates (1189 A, Chef 13.11., 17:09): Leichenprüfung alle 48 h durch Diogenes in ROLL | Termin 17.11. 08:00 |
| 1098 | M | D189.1 von Diogenes (zu 1019): Haken greift (4 Ford-Selbstneustarts seit 12.11. bei 416–88 | wartet auf 1098.1 (startbar) |
| 870.12 | K | Von Sokrates (870, Umzug BRS): Projektplan 2.3 (212 weg, Pechsträhne als Prozent) und 2.17 | wartet auf 870.20 (gebaut) |
| 464 | M | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählu | Termin 16.11. |
| 341 | K | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug u | Termin 16.11. |
| D75 | M | Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1); meldung.sh --film legte Film 572 nich | Dauerzeile |
| 919 | K | Von Sokrates (Chef 11.11., 09:53 „1 ja, 2 ja“): Regeln nachziehen: Testbitte auch bei rot | wartet auf 918 (ruht) |
| 1100 | K | Von Perikles (zu 1098): Ford-Lauf verbraucht 80–130 Tsd. Token je Stunde; Ausgabe von lauf | wartet auf 1125 (gebaut) |
| 1125 | M | D195.1 von Diogenes (1100.1): Ford-Lauf nach 1100 nicht billiger: Uhrläufe 9 Schritte wie | Termin 16.11. |
| 1170 | M | Von Sokrates (Chef 13.11., 15:37, zu 1128 A): Klang nicht in die APK: Auswahl eines Klangs | Termin 16.11. |
| 1173 | M | Von Sokrates (Chef 13.11., 15:40 „Kleinkram bitte selbst erledigen“, A): Regel Kleinkram o | wartet auf Diogenes (greift?) |
| 1188 | K | Von Sokrates (1186, Chef 13.11., 16:28): Wächter gegen still veraltete Zeilen: ruhende ode | Termin 16.11. |
| 1200 | M | Von Tuffy (Chef 13.11., 18:36: „ich brauche einen Vorgang“): LISTE-BAUEN-TESTEN „kaputter | Termin 16.11. |
| 1244 | M | D236.1 von Diogenes (1133, 1129.1 P2a): Pflegehinweis-Commits sinken nicht (13.11. nach 27 | Termin 16.11. |
| 1279 | M | Von Perikles (870.10, 870a 7 B): core/, app/, Kotlin-Vorschauordner unter tools/, Gradle-W | ruht bis 17.11. |
| 1301 | M | Von Sokrates (Chef 15.11., 16:54 zu 760: „vielleicht kommt ja jemand auch auf die Idee noc | Termin 17.11. |
| 1316 | M | Von Sokrates (1137 Stichtag 15.11., 20:00): reaktionen.py erkennt „Nachricht 4201, 4200“ ( | wartet auf Diogenes (greift?) |
| 1317 | M | Von Jerry (1314): probelauf.py hält MESS= für ausholen_1000 an (Test enthält save_png nur | wartet auf Diogenes (greift?) |
| 1324 | M | Von Tom (PR #207): pruefliste_1020 macht jeden Lauf auf claude/build-<n> rot, sobald die P | wartet auf Diogenes (greift?) |
| 1328.2 | K | Von Perikles (1328.1): Spike in Sperre 620.1 B und gemeinsamen Build einbeziehen (startbar | wartet auf Diogenes (greift?) |
| 1347 | M | Spikes Vorrat füllen: 698 (Grafikstufen, M) und 1145 (Höhle 45 statt 90 Bilder/s, K) von T | startbar |

**Diogenes** – offen 23, Muss 17, startbar 0, PAUSE bis 16.11., 08:00

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 461b | K | Nur Gültiges steht: neu ersetzt alt im selben Commit, Commit-Prüfung, Kennzahl Widersprüch | Termin 16.11. |
| 186.3 | K | Ausgefüllte Prüfbögen auswerten | ruht bis 23.11. |
| 644.5 | K | Abnahme Gegenstands- und Figurenkatalog: Prüfungen des Werkzeugs grün, Godot liest nur noc | wartet auf 644.1 (ruht) |
| 790 | M | 383 A messen: eine Woche Kosten je Aufruf und je Sitzung vorher gegen nachher (Neustart ab | Termin 16.11. 18:07 |
| 905 | K | Von Perikles (903 B Zusatz 3, Chef 11.11., 07:46): über etwa zehn Vorlagen an den Chef zäh | Termin 16.11. |
| 1098.1 | M | Von Sokrates (Chef 13.11., 09:18, 1098 A, vorher D): nach Fords erstem Neustart über Probe | Termin 16.11. |
| 1128.3 | M | Von Sokrates (1128 A, Chef 13.11., 13:36): ab Build 283 Funde und Rückschritte je Prüfart | Pause |
| 1185 | M | Von Perikles (1183, 1020 D): pruefliste.py warnt im Prüfschritt bei jeder Zeile ohne Eintr | Pause |
| 1328.1 | M | Von Sokrates (1328, Chef 15.11., 21:05): Spike eigene Rolle Technik (Grafiktechnik, Leistu | Pause |
| 1334 | M | Von Sokrates (Chef 15.11., 21:09): Wiederholrot-Wächter: derselbe Test zum zweiten Mal rot | Pause |
| 1332 | M | Von Sokrates (Chef 15.11., 21:07): „zu testen, ohne Rückmeldung“ nie liegen lassen: sofort | Pause |
| 1313 | M | Von Sokrates (Chef 15.11., 19:37): Überblick in der Chefsache: die nächsten 20 Vorgänge in | Pause |
| 1217 | M | Von Sokrates (Chef „jetzt“ 13.11., 19:58/20:01): Testbitte unterwegs: Reiter „Test“ der AP | Pause |
| 1173 | M | Von Sokrates (Chef 13.11., 15:40 „Kleinkram bitte selbst erledigen“, A): Regel Kleinkram o | Pause |
| 1317 | M | Von Jerry (1314): probelauf.py hält MESS= für ausholen_1000 an (Test enthält save_png nur | Pause |
| 1324 | M | Von Tom (PR #207): pruefliste_1020 macht jeden Lauf auf claude/build-<n> rot, sobald die P | Pause |
| 1268.2 | M | Von Sokrates (1268 A, Chef 15.11., 10:51), Bau Spike, nach 1270: schnelle Tests in einem G | Pause |
| 1268.5 | M | Von Sokrates (1268 A, Chef 15.11., 10:51), Bau Spike, nach 1270: Bildrate und Ladezeit je | Pause |
| 1335 | M | Von Sokrates (Chef 15.11., 21:09), für Spike nach 1328.1: wolf_mess_438 ohne Messrauschen | Pause |
| 1316 | K | Von Sokrates (1137 Stichtag 15.11., 20:00): reaktionen.py erkennt „Nachricht 4201, 4200“ ( | Pause |
| 1328.2 | K | Von Perikles (1328.1): Spike in Sperre 620.1 B und gemeinsamen Build einbeziehen (startbar | Pause |
| 1129.4 | M | Von Sokrates (1129 alle ja, Chef 13.11., 13:59): 1129.2/.3 am laufenden Werkzeug prüfen; M | Termin 16.11. |
| 1172 | M | Von Sokrates (Kleinkram A, Chef 13.11., 15:40): montags zählen: Kleinkram-Punkte ohne Chef | Termin 16.11. |

**Sokrates** – offen 37, Muss 11, startbar 3

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1186 | M | Altbestand: offene Vorgänge unter 700 auf überholt prüfen, Funde an die Besitzer zum Schli | Termin 16.11. |
| 1129 | M | Systemprüfung blinde Flecken mit Perikles: Regeln, Abläufe, Werkzeuge, die schneller, einf | wartet auf 1129.4 (startbar) |
| 887 | M | Archivieren und Kaufrepo ohne Nachfrage: Probe Sitzungsmodus statt Auto-Modus (dontAsk von | ruht bis 23.11. |
| 1044 | M | Von Sokrates (Chef 12.11., 16:08; 13.11., 09:35 zurück bis auf Lyra): Leute stehen außerha | startbar |
| 870 | M | Umstellung ganz auf BRS, SRD-Parallelbetrieb beenden: Liste, offene Regelfragen, Bau Tom u | wartet auf 870.20 (gebaut) |
| 780 | K | Unity-Asset-Store-EULA 2.2.1 (keine Assets als Eingabe für KI-Programme): gilt sie für uns | Termin 23.11. |
| 620 | K | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build | startbar |
| 508 | K | Lehrmeister in Kapitel 1 erreichbar (Geselle), Magie-Pflicht Paladin/Kriegsmagier, Wachsol | wartet auf 508.1 (startbar) |
| 481 | K | Herkünfte ausgleichen: Kräutersammler mit Kampftränken, Wachsoldat, Klosterschüler, Bewähr | wartet auf 481.2 (zu testen) |
| 383.2 | K | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | ruht bis 23.11. |
| 26.1 | K | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef | ruht bis 23.11. |
| 327 | K | Zweites Spiel: Marktsichtung Denkspiele, Modell ohne Werbung (Chef 23.10., 00:08; vertraul | nach dem Meilenstein |
| 246.1 | K | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | nach dem Meilenstein |
| 296 | K | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MA | ruht bis 23.11. |
| 366 | K | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | nach dem Meilenstein |
| 262 | K | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | ruht bis 23.11. |
| 253 | K | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf | ruht bis 23.11. |
| 72c | K | Brainstorming Wunden bis zur Rast (Zeichen, Heilung mit Verband oder Tempel, schwere Wunde | nach dem Meilenstein |
| 142.3 | K | Tester öffentlich suchen (Chef 27.10., 19:32) | ruht bis 23.11. |
| 142.4 | K | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 07.11.) | Termin 08.12. |
| 142 | K | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | nach dem Meilenstein |
| 45 | K | Geschäftsmodell und Umsetzung (Play Store) | nach dem Meilenstein |
| 109 | K | Repo öffentlich | nach dem Meilenstein |
| 340 | K | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Che | ruht bis 23.11. |
| 344 | K | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23 | ruht bis 23.11. |
| 644 | K | Alle Gegenstände an einer Stelle: Katalog 458 mit BRS-Werten, Voraussetzungen, Seltenheit, | wartet auf 644.1 (ruht) |
| 649 | M | Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten), Bestiarium ge | wartet auf 870 (wartet) |
| 654 | K | Mitdenken vor dem Bauen: Systemfrage je Fund („kommt das wieder?“), Wiederholungswächter, | Termin 16.11. |
| 862 | K | Systemlösung? Umhang: 6 frühere Vorgänge (58, 488, 463, 463.1, 656 …), neu 861; einmal gru | ruht bis 23.11. |
| 930 | K | Handgemenge und Abstand im Kampf, Prüfauftrag: Regelseite nach BRS, Rechnung und Film Jerr | wartet auf 930.3 (wartet) |
| 1137 | M | Vollzugsmeldung je Entscheid (Chef 13.11., 14:00/14:03): Folgeaufträge melden Vollzug auf | wartet auf 1129.4 (startbar) |
| 1189 | M | Leichenprüfung der Vorgangsliste alle 48 h (Diogenes?): Erledigtes, Überholtes, Hängendes | Termin 27.11. |
| 1268 | K | Code robuster, schneller, weniger fehleranfällig: Votum Sokrates, dann Gespräch (Chef 15.1 | wartet auf 1268.1 (gebaut) |
| 1270 | K | Grafik-Engine Godot ausschöpfen: Laden, Sichtweite, Shader vorab, Glühen, Abziehbilder; Vo | wartet auf 1270.3 (gebaut) |
| 1288 | M | Kerben: Verstreichen lassen oder eine Kerbe in den nächsten Zug mitnehmen; Lücke 930.5 (fa | startbar |
| 709.1 | M | Wolf und Grimmzahn beißen den Helden mit Schild sichtbar (aus 709 abgetrennt, Chef 10.11., | ruht |
| 709 | M | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angre | ruht |
## So geht's

- Je Punkt eine Datei: `entscheiden/<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`) oder `ansehen/t<build>-<stichwort>.md`. Erledigt heißt Datei löschen.
- Anzusehen als Bildvorschau (228, kein Build): `ansehen/<nr>-<stichwort>.md`, Zeile 1 `# <Nr.> · <Thema> · <Team> · <TT.MM.>, <HH:MM>`, dann Bild aus `bilder/` und der Satz, was der Chef sagen soll.
- Anzusehen (nur mit Build, Datei `ansehen/t<build>-<stichwort>.md`): Aufbau und Regeln nur in `LISTE-CHECK-BUILD-TEST.md` (657 D).
- Zeile 1 `# <Nr.> · <Frage>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich> · …` (Bereich wie „B Abläufe“, 136); Vorrang = Klasse der Nummer in `LISTE-VORGAENGE.md`; eine Zeile `Kurz: …` ersetzt in der Übersicht die Frage. Dann in dieser Folge (364): **Frage**, **Votum** (was der Chef tun oder sagen soll), **Berührt** (Vorgänge); darunter kurz **Begründung**, **Sachverhalt** (belegt, mit Quelle), **Auswertung** (mit dem stärksten Gegenargument), **Folgerungen** (was danach geschieht, wer); zuletzt `Antwort: …`. Lange Teile in `<details>`. Vorlage zum Kopieren: [MUSTER.md](MUSTER.md) (799); `probelauf.py` hält einen Commit oder Push an, der eine unvollständige Datei in `entscheiden/` oder `billigen/` nach `main` bringt.
- Zu billigen (Vorentscheid, 194.1): `billigen/<nr>-<stichwort>.md`, Aufbau wie bei „entscheiden“, Votum = Entschieden, plus: Umgesetzt (Commit), Rückbau, Kosten; in der Auswertung bei Balance und Spielgefühl die verworfene Möglichkeit. Hält keine Arbeit an; Antwort „gebilligt“ oder „zurück“, Sokrates löscht die Datei und setzt „gebilligt TT.MM.“ oder „zurück TT.MM.“ in die Archivzeile.
- Bilder in `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“. Ablage im Zweig `bilder` als `bilder:<pfad>` (z. B. `[Film](bilder:pruefung/x.mp4)`); die Übersicht macht daraus Links, Filme spielen im Browser (381.1).
- **Überarbeiten** (275, Chef 27.10., 15:23: „sonst schaue ich es mir am Schluss zweimal an“): wer eine Vorlage überarbeitet, löscht die Datei sofort und legt sie neu an, wenn die neue Fassung fertig ist; nie „folgt“, „kommt nach“ in einer Vorlage (die Übersicht meldet es unter „Lücken“).
- **Beantwortet oder zurück beim Team** (383.3, Chef 27.10., 19:55: „Sachen, die nicht mehr zur Vorlage sind, dann weg … Das ist kein Arbeiten so.“): wer eine Antwort des Chefs zu einer Vorlage einträgt (Vorgangsarchiv oder Vorrat), löscht die Datei im selben Commit, auch die eines anderen, und trägt jeden Auftrag, der aus der Antwort folgt, im selben Commit dem Betroffenen ein (783 W8, Chef 09.11., 20:07: „das darf nicht untergehen“); anlegen darf jeder nur seine, Sokrates auch für andere; bleibt ein Teil offen, legt der Besitzer sie neu an, sobald sie vorlegbar ist. Gilt die Antwort einer anderen Frage derselben Nummer, setzt er die Zeit in Zeile 1 oder 2 neu. Die Commit-Prüfung hält einen Archiveintrag an, dessen Vorlage stehen bleibt; Übersehenes meldet die Übersicht unter „Lücken“.
- Zu tun (275): `tun/<nr>-<stichwort>.md`, Zeile 1 `# <Nr.> · <was der Chef tun soll>`, Zeile 2 `<Absender> · <TT.MM.>, <HH:MM> · <Bereich>`, dann der Satz zum Kopieren als Codeblock oder der Weg in Schritten; erledigt heißt Datei löschen (wer sie angelegt hat). Ein „wartet auf Chef“ ohne Datei hier meldet `startbar.py` als Leiche.
- Telegram-Sprungmarke `[72s.1](cs:72s1)` führt auf die Datei (`tools/meldung.sh`).
