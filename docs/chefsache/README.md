# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

## Wer wofür

- **Sokrates:** Stab des Chefs: Strategie, Markt, Geschäftsmodell, Chefrunde
- **Homer:** Kreativdirektor: Story, Texte, Stil, Spielgefühl, Ideen
- **Perikles:** Projektmanager: Wochenziel, Vorrang, Kosten, Abläufe
- **Diogenes:** Prüfer: prüft `main`, zählt Kennzahlen, ändert nichts; nur Chef oder Ford starten ihn
- **Ford:** Betriebsleiter: startet Sitzungen, verteilt Arbeit, schreibt die Besetzung
- **Tom:** Entwickler: Leute, Dorf, Innenräume, Blende
- **Jerry:** Entwickler: Monster, Höhle, Kampf, Klang
- **Tuffy:** Aushilfe bei Jerry, nimmt dessen Muss-Zeilen auf anderem Zweig
- **Spike:** Entwickler: Technik
## Überblick

Vom Werkzeug gerechnet (`tools/ueberblick.py`, 1313), Vorgangsliste vom 16.11., 13:24, neu bei jeder Änderung. Reihenfolge der Blöcke und ihren Zuschnitt legst du fest; vorziehen: sag es, wir setzen den Rang beim Besitzer.

**Themenblöcke**

| Block | offen | Muss | in Arbeit | zum Testen | ruht | nächster |
|---|---|---|---|---|---|---|
| **Kapitel 1 fertig (Godot, BRS)** | | | | | | |
| ↳ Umzug BRS, SRD ablösen | 4 (4) | 3 | 0 | 1 | 1 | 870 (Sokrates) Umstellung ganz auf BRS, SRD-Parallelbetrieb been… |
| ↳ Kampf passt | 71 (68) | 29 | 1 | 9 | 9 | 1411 (Sokrates) Mana grundsätzlich: woher, wie viel, wie es wächs… |
| ↳ Kleiderschrank und Modelle (Held, Leute, Monster) | 17 (14) | 8 | 0 | 1 | 8 | 1044 (Tom) Leute stehen außerhalb des Kampfs wie zur Rolle p… |
| ↳ Alles an einer Stelle: Figuren, Helden, Gegenstände | 11 (10) | 2 | 1 | 0 | 3 | 649.2 (Jerry) Figurenkatalog Schritt 2: Werkzeug figuren.py und… |
| ↳ Welt, Karten, Bild, Ton, Bedienung (auch was gegenüber Kotlin fehlt) | 55 (57) | 13 | 0 | 9 | 20 | 1341 (Tom) Bild t290.6 neu, zeigt keine Gegenstandsnamen; Pr… |
| ↳ Godot besser nutzen (Technik, Build, Leistung) | 21 (18) | 9 | 0 | 10 | 4 | 1270.4 (Spike) Vergleichsfilm alt gegen neu Glühen und vorberech… |
| Werkzeuge und Abläufe der Firma | 44 (56) | 27 | 0 | 1 | 9 | 1424 (Perikles) 12 von 20 Läufen rot, meist bekannte Rote auf Zwe… |
| Marktstart | 10 (10) | 0 | 0 | 0 | 8 | 780 (Sokrates) Unity-Asset-Store-EULA 2.2.1: gilt sie für unsere… |

Heute (seit 6:00): 68 erledigt, 64 neu. In Klammern bei „offen“: Stand 6:00.

**Je Rolle das Nächste** (wie Ford startet, mit Übernahme, 1364)

| Rolle | als Nächstes |
|---|---|
| **Chef** | [t291](ansehen/t291-sammelbuild.md) testen, hält 15 Zeilen; dann 2 weitere |
| Tom | 1044 Leute stehen außerhalb des Kampfs wie zur Rolle passend, ke… (Muss); dann 7 weitere |
| Jerry | 1292 Klosterschüler, 1292 A: Wundsegen höchstens zweimal je Kamp… (Muss); dann 4 weitere |
| Tuffy | 1296 goldene Eingebung beim Anspringen rät „Wechsel“, unter den… (Muss von Jerry, neben dessen Arbeit); dann 3 weitere |
| Spike | 1416 Winken oder ähnliche Geste war im Video des Pakets UAL2; LI… (Muss) |
| Homer | 1235 Texte Kapitel 2 bauen, nach dem Meilenstein (nach dem Meilenstein) |
| Diogenes | Pflege von Werkzeug: Übergabe über 700 Zeichen (Kür) |
| Sokrates | 1411 Mana grundsätzlich: woher, wie viel, wie es wächst; Zauberk… (Muss); dann 1 weitere |
| Perikles | 1424 12 von 20 Läufen rot, meist bekannte Rote auf Zweigen ohne… (Muss) |

**Die nächsten 20**

| # | Nr. | Wer | Worum | Kl. | Block | Stand |
|---|---|---|---|---|---|---|
| 1 | 1411 | Sokrates | Mana grundsätzlich: woher, wie viel, wie es wächst; Zauberkosten; Streuung bei… | M | Kampf passt | startbar |
| 2 | 1292 | Jerry | Klosterschüler, 1292 A: Wundsegen höchstens zweimal je Kampf, sichtbar am Knopf… | M | Kampf passt | startbar |
| 3 | 1296 | Jerry | goldene Eingebung beim Anspringen rät „Wechsel“, unter den Knöpfen fehlt ein We… | M | Kampf passt | startbar |
| 4 | 1340 | Jerry | Aus 1215: Sterben mit Physik fehlt noch für Skelett und Wiedergänger | M | Kampf passt | in Arbeit |
| 5 | 1284b | Jerry | Rückfrage zu 1284: Rattenbiss verdeckt der Held selbst, nicht der Nachbar; Kame… | M | Kampf passt | startbar |
| 6 | 1415 | Jerry | Kampftakt Wolfsrudel, Runde 31,8–34,1 s statt 14,6; Wege sind es nicht mehr, Ze… | M | Kampf passt | startbar |
| 7 | 1044 | Tom | Leute stehen außerhalb des Kampfs wie zur Rolle passend, kein Kampfstand | M | Kleiderschrank und Modelle | startbar |
| 8 | 431 | Tom | Völker als Modelle: erst Bibliothek sichten, Kandidaten drehend im Film vorlege… | M | Kleiderschrank und Modelle | startbar |
| 9 | 1416 | Spike | Winken oder ähnliche Geste war im Video des Pakets UAL2; LISTE-BESTAND sagt „Fe… | M | Kleiderschrank und Modelle | startbar |
| 10 | 431h | Tom | Rückfrage zu 431: angelegte Rüstung am Helden sichtbar, Zuordnung Grundform → K… | M | Kleiderschrank und Modelle | startbar |
| 11 | 1417 | Tom | Schild des Helden links an mehreren Stellen wie abgeschnitten: Umhang/Stoff dah… | M | Kleiderschrank und Modelle | startbar |
| 12 | 1341 | Tom | Bild t290.6 neu, zeigt keine Gegenstandsnamen; Prüfpunkt klar formulieren, sieh… | M | Welt, Karten, Bild, Ton, Bedienung | startbar |
| 13 | 531 | Tom | Build 249: Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertr… | M | Welt, Karten, Bild, Ton, Bedienung | startbar |
| 14 | 1418 | Tom | Android-Zurück im Hauptmenü beendet das Spiel sofort; künftig Abfrage „Spiel be… | M | Welt, Karten, Bild, Ton, Bedienung | startbar |
| 15 | 1420 | Tom | Fußstaub jetzt zu stark, „sieht nach Comic aus“; sanfter machen, Film alt gegen… | M | Welt, Karten, Bild, Ton, Bedienung | startbar |
| 16 | 1424 | Perikles | 12 von 20 Läufen rot, meist bekannte Rote auf Zweigen ohne die Behebung aus Bui… | M | Werkzeuge und Abläufe der Firma | startbar |
| 17 | 507 | Jerry | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager | K | Kampf passt | startbar |
| 18 | 469 | Jerry | Kampf auf BRS: Ring ohne Klassen regeln | K | Kampf passt | startbar |
| 19 | 623.2 | Jerry | Effekte Szene 2 Wolfskampf und Szene 3 Höhle einbauen, Datenfeld fx in LISTE-EF… | K | Kampf passt | startbar |
| 20 | 1405 | Sokrates | Systemlösung? Parade: 3 frühere Vorgänge, neu 1404; einmal grundsätzlich lösen? | K | Kampf passt | startbar |

Danach 93 weitere offen. Bei dir zum Testen (vorgelegt): 31. Gebaut, fährt mit dem nächsten Build: 10. Werkzeug gebaut, Prüfung Diogenes: 17. Ruhend oder nach dem Meilenstein: 62.
## Zu entscheiden

Nichts offen.

## Zu billigen

Nichts offen.

## Anzusehen

**Bilder** (ansehen und im Gespräch „ja“ oder was anders sein soll):

| Nr. | Was | Wer | Seit |
|---|---|---|---|
| [1375](ansehen/1375-haken.md) | Haken-Frage Abnahmeliste, Woche 16.11. | Perikles | 16.11., 09:11 |

**Builds** (installieren und testen; Folge = Version aufsteigend, Android installiert nur höhere Nummern über niedrigere):

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.348.514](ansehen/t291-sammelbuild.md) | [Build 291](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43789694188/artifacts/14192207855) | Sammelbuild: Leben statt TP, Laden, Höhle schwarz, Kerben, Einschlag | Tom und Jerry | 16.11., 07:30 |
| 2 | [0.348.517](ansehen/t292-sammelbuild.md) | [Build 292](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43835954328/artifacts/14214731981) | Sammelbuild: Grafikstufen, Höhle ohne Hakeln, Joystick, Strahlprobe, Lesen | Tom und Jerry | 16.11., 11:20 |

## Zu tun

Nichts offen.

## Offen je Rolle

Vom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand 16.11.; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.

**Homer** – offen 2, Muss 1, startbar 1

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1235 | K | Texte Kapitel 2 bauen (Rest aus 41; Entwurf kapitel2/STORY-K2-ENTWURF.md, Storyplan K2 fer | nach dem Meilenstein |
| 1419 | M | Von Sokrates (Chef 16.11., 12:40, für Tom): Text der Abfrage beim Beenden im Hauptmenü (Fr | startbar |

**Tom** – offen 66, Muss 18, startbar 14

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1044 | M | Von Sokrates (Chef 12.11., 16:08; 13.11., 09:35 zurück bis auf Lyra): Leute stehen außerha | startbar |
| 1357 | M | Von Werkzeug (1334): Wiederholrot lage_785_8: 2× rot in 48 h (Läufe 508, 504); Ursache nac | wartet auf Test (Build 291) |
| 1383 | M | Von Werkzeug (1334): Wiederholrot ziege_4162: 6× rot in 48 h (Läufe 513, 500, 499, 484, 47 | wartet auf Test (Build 292) |
| 1361 | M | Von Tom (1312): Sammelbuild 291: alle fertigen Zweige der drei Teams nach t290 (785.24, 13 | wartet auf Test (Build 291) |
| 1341 | M | Von Sokrates (1309, Chef 15.11., 21:42): Bild t290.6 neu, zeigt keine Gegenstandsnamen; Pr | startbar |
| 431 | M | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, da | startbar |
| 568 | K | Ernten als Handlung statt Einsaugen; Angeln mit Pose und Ring (Chef 04.11., 19:42: ja, A) | ruht bis 23.11. |
| 531 | M | Build 249: Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertreibt Tiere | startbar |
| 515 | K | Truhen: 3–4 je Karte halb versteckt, verschlossene nach BRS (Dietrich, Aufbrechen) (Chef 0 | wartet auf 870 (wartet) |
| 455.1 | K | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 1 | ruht bis 23.11. |
| 513 | M | Ein Figurenstand für alle Zweige; Schild, Robe Magier, Umhang jetzt (Chef 03.11., 15:56, „ | ruht bis 23.11. |
| 476 | K | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | wartet auf 458.3 (ruht) |
| 458.3 | K | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | ruht bis 23.11. |
| 423.1 | K | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | ruht bis 23.11. |
| 455.2 | K | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völker (Chef 01.11., 11: | ruht bis 23.11. |
| 292.4 | K | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., | ruht bis 23.11. |
| 145 | K | Karten je Kapitel zum Drucken | ruht bis 23.11. |
| 417.1 | K | Restmängel Tragart nach „417 passt“ (Schildabstand, Rumpfdrehen, Fußrutschen, Kornfeld, St | ruht bis 23.11. |
| 558.1 | K | Prüferrest Robe Probe 5 nachhalten, nicht bauen; Chef sieht es nach dem Durchspielen an (C | ruht bis 23.11. |
| 447.4.1 | K | Bau Lehrmeister, Meisterschaften, Ruf Kapitel 1 (447.4) | wartet auf 508 (startbar) |
| 622 | K | Godot-Build als AAB für Play: dieselbe App de.bornim.game, mit dem Upload-Schlüssel des al | nach dem Meilenstein |
| 41.2 | K | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | wartet auf 1235 (nach Meilenstein) |
| 134 | K | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | aufgeteilt |
| 531a | K | Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast kaufen? (Chef 04.11., 19:27) | ruht bis 23.11. |
| 649.3 | K | Figurenkatalog: Bewohner, Händler, Lehrmeister, Söldner füllen (Tagesablauf, Laden, Stimme | wartet auf 649.2 (startbar) |
| 644.4 | K | Gegenstandskatalog: Ladenbestand und Rezepte aus texte.json und Kotlin in den Katalog umst | wartet auf 644.1 (startbar) |
| 691 | K | Platzwechsel mit Leuten und Tieren: beide gleiten ineinander (Chef 03.11., 07:44, Test 204 | ruht bis 23.11. |
| 688 | K | Frage des Chefs je Karte: wie viel Sammelbares offen und versteckt liegt (alt gegen neu: T | ruht bis 23.11. |
| 689 | K | Dorf, Urteil Chef 25.10., 12:11 (aus 348.6, offen geblieben): Büsche über Dachfirsten, Lat | ruht bis 23.11. |
| 816 | K | Effekte Szene 1 Dorf am Abend nach LISTE-EFFEKTE (Reihenfolge 623.8): gedämpft, Bilder/s n | startbar |
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
| 785.23 | K | Von Spike (785): Renntaste geht von selbst aus, wenn der Held steht oder außer Atem ist (W | wartet auf Test (Build 290) |
| 785.24 | K | Von Spike (785): Laden: Vorräte mit Wirkungszeile in der Liste wie alt (ShopScreen.kt 226– | wartet auf Test (Build 291) |
| 1155 | K | Von Sokrates (623.8 A, Chef 09.11., 22:23; Lücke, Chef 13.11., 15:12 „wann kommt … Teich u | startbar |
| 1157 | K | Von Sokrates (Archivprüfung, 1038 A R1, Chef 12.11., 16:24): Verband herstellen mit dem Re | wartet auf 976 (startbar) |
| 1158 | K | Von Sokrates (Archivprüfung, 558 Probe 4, Chef 04.11., 19:48): Oberflächen für Leder und M | ruht |
| 1167 | K | Von Sokrates (Archivprüfung, 453.1 Chef 01.11.; 453a B 02.11.): Atmen für die Dorftiere (g | startbar |
| 1174 | K | Von Sokrates (Archivprüfung, 348.10 Chef 25.10., 16:36 „brauchen wir auf jeden Fall“; Zwec | wartet auf 431 (startbar) |
| 1205 | K | Von Sokrates (Chef 13.11., 18:48): Wiesen und Blumenfelder mit mehr Pflanzen aus dem Grass | startbar |
| 1211 | K | Von Sokrates (Prüfauftrag Chef 13.11., 19:10): Leuchtfunke mit R7 rocket_trail als Schweif | startbar |
| 1210 | K | Von Sokrates: Regen wie alt (D3.10) fehlt in Godot; Bild ohne Vorgang (R8 Weather FX statt | ruht |
| 1280 | K | Funde und Abgleich alt, Team Tom (1271a A, Chef 15.11., 11:23): 569, 570, 589, 590, 665, 6 | nach dem Meilenstein |
| 1295 | M | Von Sokrates (Chef 15.11., 13:41, Bild Handy, Build 286, Karte Blutzahnhöhle): Kartenblatt | wartet auf Test (Build 290) |
| 1297 | M | Von Sokrates (431, Chef 15.11., 14:32): Schildgröße je Körper, beim Halbling ist der Schil | wartet auf 431 (startbar) |
| 1309 | M | Von Sokrates (Chef 15.11., 18:20, Bild Ausrüstungsseite Build 288, 17:12): Feld „Kopf“ rut | wartet auf 1341 (startbar) |
| 1322 | M | Von Homer (1320, Chef 15.11., 20:15): Spielertexte der Oberfläche ohne TP/HP, Wert heißt L | wartet auf Test (Build 291) |
| 870.20 | M | Von Sokrates (870, Schritt 9, auf build-289): SRD-Reste aus den Daten (held.json grundform | wartet auf Test (Build 291) |
| 1326 | M | Von Sokrates (Chef 15.11., 20:33): Build-Name (Nummer des Builds) im Hauptmenü und in „Übe | wartet auf Test (Build 291) |
| 431h | M | Rückfrage zu 431: angelegte Rüstung am Helden sichtbar, Zuordnung Grundform → Kaufteil, et | startbar |
| 1355 | K | Von Spike (Lauf 509): wende_4168 zufällig rot, „Knoten folgt der Kurve (hoechstens 1.21 Gr | wartet auf Test (Build 291) |
| Pflege | K | von Werkzeug (340.3, 16.11.): 31051 Bytes (Grenze 30000), Erledigtes streichen | startbar |
| 1406 | K | Von Spike (1386, Chef 16.11. „Drehen auf der Stelle … ganz Entscheidendes“): Wenden ab 135 | startbar |
| 1417 | M | Von Chef (16.11., 12:37/12:38, Bild Hauptmenü v0.348.506, über Sokrates): Schild des Helde | startbar |
| 1418 | M | Von Chef (16.11., 12:40, zu t292, über Sokrates): Android-Zurück im Hauptmenü beendet das | wartet auf 1419 (startbar) |
| 1420 | M | Von Chef (16.11., 12:44, Test t290, über Sokrates): Fußstaub (814) jetzt zu stark, „sieht | startbar |

**Jerry** – offen 85, Muss 34, startbar 33

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1408 | M | Von Jerry (Build 292 rot): typen.py rot, regeln/mars.gd 288 Stellen ohne Typ statt 284 (au | wartet auf Test/Build (gebaut) |
| 1393 | M | Von Jerry (1312): Sammelbuild 292: alle fertigen Zweige nach t291 (698, 1145, 1286, 1285, | wartet auf Test (Build 292) |
| 1363 | M | Von Tom (1361): Rot in Build 291 (Lauf 512): arkan_993 Treffer endet 1,09 m hoch, 0,95 m n | wartet auf Test (Build 291) |
| 1331 | M | Sammelbuild: alle fertigen Zweige beider Teams, Nummern siehe „Zu 1331“; Prüfliste ansehen | wartet auf Test t290 (Chef) |
| 1321 | M | Von Jerry (1305, 481.2): Held ohne Wurzelweg weicht am Ort aus, die Bewegung schwingt den | wartet auf Test (Build 291) |
| 760 | M | Kampf: Wolf springt beim „Anspringen“ nicht, er beißt nur; Text und Bewegung passen nicht | Sperre 620.1 B: 10 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1321 (wolf) |
| 1289 | M | Von Spike (Chef 15.11., 12:34): Höhle im Renderer mobile ganz anders als bisher: zu hell, | wartet auf Test (Build 291) |
| 1284 | M | Von Chef (15.11., 12:07, Test Build 286, Wald): Riesenratte sagt „Biss“ an, Bericht „Riese | Sperre 620.1 B: 10 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1321 (figur.gd) |
| 1068 | M | Von Perikles (1048 A, H, D, Chef 12.11., 20:05): Ring bei jedem großen Schlag der Gegner ( | Halt (Vorrat oben) |
| 1043 | M | Von Sokrates (Chef 12.11., 15:52, Fund t278.33 Build 280, zu 988): MARS-Probekampf Wölfe, | wartet auf 760 (startbar) |
| 1032 | M | Von Sokrates (Chef 12.11., 14:08, Build 280, MARS-Probekampf Wölfe, Held und Söldner Wachs | wartet auf 760 (startbar) |
| 1072 | M | Laufwege und Plätze im Kampf für alle Figuren: Zweiertausch im Heldenteam, Monster zu eins | wartet auf Test/Build (gebaut) |
| 709.1 | M | Wolf und Grimmzahn beißen den Helden mit Schild sichtbar (aus 709 abgetrennt, Chef 10.11., | Sperre 620.1 B: 10 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1321 (wolf) |
| 506.2 | M | Grabhund-Biss reicht sichtbar bis zum Helden, nicht nur knapp an den Schild (von Sokrates, | wartet auf 709.1 (wartet) |
| 709 | M | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angre | Halt (Vorrat oben) |
| 642 | M | Wölfe ineinander beim Anlauf und Biss neben einem ruhenden Wolf, bis 0,15 m (wolf_mess_438 | ruht bis 23.11. |
| 438a | K | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv | ruht bis 23.11. |
| 416.6 | K | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef 31.10., 20:4x; 03.1 | ruht bis 23.11. |
| 415 | M | Handyprobe Beams-Free-Sample (aus 414, Chef 31.10., 20:3x; „jetzt“ 01.11.) | wartet auf Test (Build 291) |
| 406.1 | K | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann | wartet auf 469 (startbar) |
| 510 | K | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt ( | ruht bis 23.11. |
| 509 | K | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot (Chef 03.11., 09:21; Po | ruht bis 23.11. |
| 494 | K | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Woche | ruht bis 23.11. |
| 517 | K | Waldklang wie alt: Vögel am Tag, Eule und Grillen nachts, fernes Wolfsheulen im Tiefen Wal | Chef (Datei in der Chefsache) |
| 507 | K | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager (Orte O10; aus 492) | startbar |
| 496 | K | Durchspiel-Build: Kapitel 1 von Anfang bis Ende am Handy (Wochenziel 03.11., 488) | startbar |
| 385.2 | K | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | wartet auf 623.2 (startbar) |
| 344.2 | K | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | ruht bis 23.11. |
| 168.1 | K | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | startbar |
| 39 | K | Schwierigkeitsgrad im Menü | ruht bis 23.11. |
| 59e | K | Händler: Vorrat je Laden | ruht bis 23.11. |
| 469 | K | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | startbar |
| 623.2 | K | Effekte Szene 2 Wolfskampf und Szene 3 Höhle einbauen (623.8 A, Chef 09.11., 22:23; vorher | startbar |
| 598 | K | Umweltklang je Ort, Tageszeit, Wind und Wetter, lebendige Welt (Chef 05.11., 19:2x; Abnahm | startbar |
| 643 | M | Langbogen mit Köcher als Waffenmodell (daten/waffen/longbow.bin, Griff = Ursprung, Schaft | wartet auf Test (Build 292) |
| 649.2 | K | Figurenkatalog Schritt 2: Werkzeug figuren.py und tools/figuren/figuren.json (Art und Auft | startbar |
| 649.4 | K | Zwei bis drei Handlungen je gewöhnlicher Monsterart vorschlagen und in 444 messen, nur wo | startbar |
| 644.1 | K | Gegenstandskatalog: Werkzeug mit Spalten, Teil Rezepte und Prüfungen (644 A), zusammen mit | startbar |
| 644.2 | K | Gegenstandskatalog: C1 Fertigkeit +1/+2 ab episch ohne Pflicht-Nachteil (Chef 14:32), C2 S | startbar |
| 681 | K | Trinkgeräusch in drei Varianten beim Met und anderen Getränken (Chef 08.11., 16:16) | startbar |
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
| 999.2 | K | Von 999: Armbrust als Waffenmodell im Kampf (Ersatzwaffe der Probehelden, light_crossbow); | ruht bis 23.11. |
| 1036.1 | K | Von Tuffy (1036, Chef 12.11., 20:52): neue Vorlage Zustände, jeder Zustand des Codes mit a | ruht bis 20.11. |
| 1165 | K | Von Sokrates (Archivprüfung, 490/493 Chef 03.11. „nach dem Durchspielen“): Prüferbefunde K | wartet auf 496 (startbar) |
| 1224 | K | Von Tom (aus 1041, Rest Commit d1cfba877): Berührungsprüfung beim Platztausch (Netze beide | Halt (Vorrat oben) |
| 1250 | K | Von Jerry (1000): grak_348 (godot-kampf.yml) rot schon auf main aeb8e0eb0, 11 FEHLER: Plat | wartet auf Test/Build (gebaut) |
| 481.2 | M | Von Sokrates (481a A, Chef 15.11., 10:51): Rechnung glut2.py mit Deckel des Abzugs von Rüs | Sperre 620.1 B: 10 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1321 |
| 601.1 | M | Von Sokrates (601, Chef 15.11., 11:02): Pfeil trifft die Fußspitze, der Getroffene zuckt o | wartet auf Test (Build 291) |
| 1275 | M | Von Homer (1267): Kerbensystem auf dem Zweig weicht von DESIGN-GLUT.md ab: Taumeln nach Ge | wartet auf Test (Build 291) |
| 1281 | K | Funde und Abgleich alt, Team Jerry (1271a A, Chef 15.11., 11:23): 551, 289, 628, 634, 936, | nach dem Meilenstein |
| 1285 | M | Von Chef (15.11., 12:09, Test Build 286, Höhle): Held rennt schon bei kleinen Joystick-Bew | wartet auf Test (Build 292) |
| 1291 | M | Von Tom (785.5): Waffe in der Nebenhand wirkt im BRS-Kampf nicht (aufruf.gd blatt „off“ li | startbar |
| 1292 | M | Von Sokrates (481.2 A): Klosterschüler, 1292 A (Chef 16.11., 11:49): Wundsegen höchstens z | startbar |
| 1296 | M | Von Sokrates (Chef 15.11., 14:48, Build 287, Probekampf Wolfsrudel): goldene Eingebung bei | wartet auf Test (Build 290) |
| 1305 | M | Von Sokrates (Chef 15.11., 17:18, Probekampf 3 Wölfe, wohl Build 288): Kämpfer mit Schwert | wartet auf Test (Build 292) |
| 1319 | K | Von Homer (1318): Kampfmeldung MSG532_CURED (mars.gd 430) „von allen Leiden befreit“ / “cu | startbar |
| 1323 | M | Von Homer (1320, Chef 15.11., 20:15): Kampfmeldungen ohne TP/HP, „+{1} Leben“ / “+{1} Life | wartet auf Test/Build (gebaut) |
| 508.1 | K | Von Sokrates (508): Simulation 444 mit Übung außerhalb des Kampfes in Kapitel 1; ab welche | startbar |
| 1327 | K | Von Sokrates (aus 1215, t289.2 ✓): Regeln melden Schildstoß und schweren Treffer an ragdol | startbar |
| 1333 | M | Aus 930.6 (Rest 1215, Sokrates t289.2): Regelkern meldet Schildstoß und schweren Treffer a | wartet auf Test (Build 292) |
| 1336 | K | Aus 1141 (Jerry 13.11., 18:55): Robe des Goblin-Schamanen fällt steif, Schattenseite zu du | startbar |
| 1340 | M | Aus 1215 (Jerry 15.11., 13:08): Sterben mit Physik fehlt noch für Skelett und Wiedergänger | startbar |
| 1366 | M | Von Sokrates (1288b A, Chef 16.11., 06:56): Lesen spürbar – Größe der Ansage erst ab Leses | wartet auf Test (Build 292) |
| Pflege | K | von Werkzeug (340.3, 16.11.): Übergabe über 700 Zeichen (nur Getanes und Nachfolger, Stand | startbar |
| 1402 | K | Von Chef (16.11., 10:11, Idee zu 1284a; „als großes Thema … fürs Feintuning und für den Ka | startbar |
| 1404 | K | Von Chef (1291a D, 16.11., 10:37): Machbarkeitsstudie Kampf mit zwei Waffen, ohne Spielcod | startbar |
| 1409 | M | Von Jerry (Build 292 rot): kauf_cache_probe.sh Zeile 45 auf dem Bauserver FALSCH (geholt w | Sperre 620.1 B: 10 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1321 (Zweig liegt darauf) |
| 1284b | M | Rückfrage zu 1284 (Jerry): Rattenbiss verdeckt der Held selbst, nicht der Nachbar; Kamera | startbar |
| 1415 | M | Von Jerry (1072 gemessen): Kampftakt Wolfsrudel, Runde 31,8–34,1 s statt 14,6 (784 A); Weg | startbar |

**Spike** – offen 15, Muss 6, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1270.4 | K | Von Sokrates (1270 A, Chef 15.11., 10:51; 22:43 Film statt Bild), Bau Spike: Vergleichsfil | wartet auf 1303 (in Arbeit) |
| 1303 | M | Von Jerry (zu 1289): Stufen (Banding) im Dunkel im Renderer mobile, Höhle: dunkle Flächen | startbar |
| 698 | M | Grafikstufen im Systemmenü mit Effekten (Niedrig/Mittel/Hoch, Automatisch per Leistungstes | wartet auf Test (Build 292) |
| 1145 | K | Von Sokrates (Chef 13.11., 14:35/14:45, Build 282): Höhle fühlt sich hakelig an, Bilder/s | wartet auf Test (Build 292) |
| 1286 | K | Von Spike (zu 415): Strahlprobe wirft nach dem Verlassen Fehler am A56, Build 286: busy/fi | wartet auf Test (Build 292) |
| 1307 | K | Von Spike (1268.3): Sperrklinke Typen, nach dem Mischen von claude/spike-1268-3-typen: in | wartet auf Test t290 (Chef) |
| 1270.3 | M | Von Sokrates (1270 A, Chef 15.11., 10:51), Bau Spike: Shader-Vorbau beim Export (export_pr | wartet auf Test (Build 291) |
| 1268.3 | M | Von Sokrates (1268 A, Chef 15.11., 10:51), Bau Spike, nach 1270: Warnungen fehlender Typen | wartet auf Test/Build (gebaut) |
| 918 | K | Von Sokrates (Chef 11.11., 09:53 „1 ja, 2 ja“): godot.yml lässt alle Tests durchlaufen, AP | ruht |
| 474 | K | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, M | ruht bis 23.11. |
| 30 | K | Abstürze beim Testen | ruht bis 23.11. |
| 673 | K | Emulator: Kamera drehen und zoomen mit Maus und Tasten (rechte Maustaste ziehen, Mausrad), | wartet auf Test (Build 291) |
| 348.13 | K | Tusche nach Licht wie entschieden (Chef 26.10.) | ruht bis 23.11. |
| 1385 | M | Von Perikles (1382, Chef 16.11., 09:00 „Spike da mal als verantwortlich“): Unterbau „Alles | wartet auf Sokrates |
| 1416 | M | Von Chef (16.11., 12:27, zu 1386 über Sokrates): Winken oder ähnliche Geste war im Video d | startbar |

**Perikles** – offen 27, Muss 20, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1148 | M | Von Ford (13.11., 14:58): lauf.py startet/archiviert Spike 882.1 wiederholt, obwohl dessen | Termin 23.11. |
| 1398 | M | Von Chef (16.11., 10:01, über Sokrates): Prüfliste mischt wieder Bild/Film mit APK-Wegen; | wartet auf Test t293 (Chef) |
| 1312 | M | Von Sokrates (Chef 15.11., 19:28): Fertiges nie liegen lassen: Werkzeug mischen (1311), Sp | Termin 17.11. |
| 1254 | M | Von Chef (14.11., 21:08 „Runs … mit den vorgerenderten Modellen schneller“): Läufe auf Zwe | Termin 17.11. |
| 1246 | M | Von Chef (14.11., 10:28, Fehler): nachts warten alle aufeinander; Pause ohne Datum sperrte | Termin 17.11. |
| 1217 | M | Von Sokrates (Chef „jetzt“ 13.11., 19:58/20:01): Testbitte unterwegs: Reiter „Test“ der AP | wartet auf Test t291 (Chef) |
| 1192 | M | Von Sokrates (1189 A, Chef 13.11., 17:09): Leichenprüfung alle 48 h durch Diogenes in ROLL | Termin 17.11. 08:00 |
| 1098 | M | D189.1 von Diogenes (zu 1019): Haken greift (4 Ford-Selbstneustarts seit 12.11. bei 416–88 | wartet auf 1098.1 (startbar) |
| 870.12 | K | Von Sokrates (870, Umzug BRS): Projektplan 2.3 (212 weg, Pechsträhne als Prozent) und 2.17 | wartet auf 870.20 (zu testen) |
| 464 | M | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählu | wartet auf 1388 (wartet) |
| 341 | K | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug u | Termin 23.11. |
| D75 | M | Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1); meldung.sh --film legte Film 572 nich | Dauerzeile |
| 919 | K | Von Sokrates (Chef 11.11., 09:53 „1 ja, 2 ja“): Regeln nachziehen: Testbitte auch bei rot | wartet auf 918 (ruht) |
| 1100 | K | Von Perikles (zu 1098): Ford-Lauf verbraucht 80–130 Tsd. Token je Stunde; Ausgabe von lauf | wartet auf 1125 (gebaut) |
| 1125 | M | D195.1 von Diogenes (1100.1): Ford-Lauf nach 1100 nicht billiger: Uhrläufe 9 Schritte wie | Termin 23.11. |
| 1173 | M | Von Sokrates (Chef 13.11., 15:40 „Kleinkram bitte selbst erledigen“, A): Regel Kleinkram o | Termin 23.11. |
| 1188 | K | Von Sokrates (1186, Chef 13.11., 16:28): Wächter gegen still veraltete Zeilen: ruhende ode | Termin 23.11. |
| 1244 | M | D236.1 von Diogenes (1133, 1129.1 P2a): Pflegehinweis-Commits sinken nicht (13.11. nach 27 | wartet auf 1389 (gebaut) |
| 1279 | M | Von Perikles (870.10, 870a 7 B): core/, app/, Kotlin-Vorschauordner unter tools/, Gradle-W | ruht bis 17.11. |
| 1301 | M | Von Sokrates (Chef 15.11., 16:54 zu 760: „vielleicht kommt ja jemand auch auf die Idee noc | Termin 17.11. |
| 1387 | M | Von Sokrates (1129.4, Punkt 6 gerissen): Übersicht-Commits 15.11. 193 (14.11.: 37), Ursach | wartet auf Diogenes |
| 1388 | M | D257.1 von Diogenes (464): rote Godot-Läufe 09.–15.11. 93 von 159 (58 %) gegen 52 von 185 | Termin 23.11. |
| 1389 | M | D257.2 von Diogenes (1244): Pflegehinweis-Commits 15.11. 38 (13.11.: 79), Anteil 2,6 % geg | wartet auf Diogenes |
| 1396 | K | Von Ford (Tuffy 16.11., 10:00): lauf.py startet Tuffy auf Zeile 1393, die Jerry schon in s | wartet auf 1407 (gebaut) |
| 1400 | M | D261.1 von Diogenes: „Geprüft an“ nennt Commits, die es nicht gibt: 1392 c28c2e3d9 (echt 2 | Termin 23.11. |
| 1407 | K | D262.1 von Diogenes (1396): sitzungszweige() liest current_branches, das lauf.py nie bekom | wartet auf Diogenes |
| 1414 | M | Von Chef (16.11., 12:09, über Sokrates): Warnung bei Vorgangsnummer ohne Wort dazu in Vorl | Termin 23.11. |

**Diogenes** – offen 10, Muss 6, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1387 | M | Von Sokrates (1129.4, Punkt 6 gerissen): Übersicht-Commits 15.11. 193 (14.11.: 37), Ursach | Termin 23.11. |
| 1389 | M | D257.2 von Diogenes (1244): Pflegehinweis-Commits 15.11. 38 (13.11.: 79), Anteil 2,6 % geg | Termin 18.11. |
| 1407 | K | D262.1 von Diogenes (1396): sitzungszweige() liest current_branches, das lauf.py nie bekom | startbar |
| 186.3 | K | Ausgefüllte Prüfbögen auswerten | ruht bis 23.11. |
| 644.5 | K | Abnahme Gegenstands- und Figurenkatalog: Prüfungen des Werkzeugs grün, Godot liest nur noc | wartet auf 644.1 (startbar) |
| 790 | M | 383 A messen: eine Woche Kosten je Aufruf und je Sitzung vorher gegen nachher (Neustart ab | Termin 16.11. 18:07 |
| 1098.1 | M | Von Sokrates (Chef 13.11., 09:18, 1098 A, vorher D): nach Fords erstem Neustart über Probe | wartet auf Ford |
| 1128.3 | M | Von Sokrates (1128 A, Chef 13.11., 13:36): ab Build 283 Funde und Rückschritte je Prüfart | Termin 23.11. |
| 1172 | M | Von Sokrates (Kleinkram A, Chef 13.11., 15:40): montags zählen: Kleinkram-Punkte ohne Chef | Termin 23.11. |
| Pflege | K | von Werkzeug (340.3, 16.11.): Übergabe über 700 Zeichen (nur Getanes und Nachfolger, Stand | startbar |

**Sokrates** – offen 35, Muss 9, startbar 3

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1129 | M | Systemprüfung blinde Flecken mit Perikles: Regeln, Abläufe, Werkzeuge, die schneller, einf | wartet auf 1387 (gebaut) |
| 887 | M | Archivieren und Kaufrepo ohne Nachfrage: Probe Sitzungsmodus statt Auto-Modus (dontAsk von | ruht bis 23.11. |
| 870 | M | Umstellung ganz auf BRS, SRD-Parallelbetrieb beenden: Liste, offene Regelfragen, Bau Tom u | wartet auf 870.20 (zu testen) |
| 780 | K | Unity-Asset-Store-EULA 2.2.1 (keine Assets als Eingabe für KI-Programme): gilt sie für uns | Termin 23.11. |
| 620 | K | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build | Termin 23.11. |
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
| 644 | K | Alle Gegenstände an einer Stelle: Katalog 458 mit BRS-Werten, Voraussetzungen, Seltenheit, | wartet auf 644.1 (startbar) |
| 649 | M | Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten), Bestiarium ge | wartet auf 870 (wartet) |
| 654 | K | Mitdenken vor dem Bauen: Systemfrage je Fund („kommt das wieder?“), Wiederholungswächter, | Termin 23.11. |
| 930 | K | Handgemenge und Abstand im Kampf, Prüfauftrag: Regelseite nach BRS, Rechnung und Film Jerr | wartet auf 930.3 (wartet) |
| 1137 | M | Vollzugsmeldung je Entscheid (Chef 13.11., 14:00/14:03): Folgeaufträge melden Vollzug auf | Termin 17.11. 08:00 |
| 1189 | M | Leichenprüfung der Vorgangsliste alle 48 h (Diogenes?): Erledigtes, Überholtes, Hängendes | Termin 27.11. |
| 1268 | K | Code robuster, schneller, weniger fehleranfällig: Votum Sokrates, dann Gespräch (Chef 15.1 | wartet auf 1268.3 (gebaut) |
| 1270 | K | Grafik-Engine Godot ausschöpfen: Laden, Sichtweite, Shader vorab, Glühen, Abziehbilder; Vo | wartet auf 1270.3 (zu testen) |
| 1403 | M | Von Chef (1352a A, 16.11., 10:15): Nachmessung im Simulator glut2.py mit Taumeln (ein Fünf | wartet auf 1275 (zu testen) |
| 1405 | K | Systemlösung? Parade: 3 frühere Vorgänge (219, 662, 406.2), neu 1404; einmal grundsätzlich | startbar |
| 1411 | M | Von Chef (1292 A, 16.11., 11:49): Mana grundsätzlich: woher, wie viel, wie es wächst; Zaub | startbar |
| 1385 | M | Von Perikles (1382, Chef 16.11., 09:00 „Spike da mal als verantwortlich“): Unterbau „Alles | startbar |
## Lücken

Vom Werkzeug gefunden (D21.3): steht in der Vorgangsliste, hat hier keine Datei.

Ohne Bild oder Film (450: `meldung.sh --bild/--film` trägt den Link selbst ein; sonst `[Film](bilder:<pfad>)` von Hand): ansehen/1375-haken.md

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
