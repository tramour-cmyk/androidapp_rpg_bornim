# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

**Letzter Testbuild:** [Build 299 · 0.348.563 (APK)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/44301568081/artifacts/14429688295) · 18.11., 14:20 · getestet · Release dagegen nur auf Zuruf

## Wer wofür

- **Sokrates:** Stab des Chefs: Strategie, Markt, Geschäftsmodell, Chefrunde
- **Homer:** Kreativdirektor: Story, Texte, Stil, Spielgefühl, Leveldesign, Ideen
- **Perikles:** Projektmanager: Wochenziel, Vorrang, Kosten, Abläufe
- **Diogenes:** Prüfer: prüft `main`, zählt Kennzahlen, ändert nichts; nur Chef oder Ford starten ihn
- **Ford:** Betriebsleiter: startet Sitzungen, verteilt Arbeit, schreibt die Besetzung
- **Tom:** Entwickler: Leute, Dorf, Innenräume, Blende
- **Jerry:** Entwickler: Monster, Höhle, Kampf, Klang
- **Tuffy:** Aushilfe bei Jerry, nimmt dessen Muss-Zeilen auf anderem Zweig
- **Spike:** Technik, jede APK
## Überblick

Vom Werkzeug gerechnet (`tools/ueberblick.py`, 1313), Vorgangsliste vom 18.11., 22:17, neu bei jeder Änderung. Reihenfolge der Blöcke und ihren Zuschnitt legst du fest; vorziehen: sag es, wir setzen den Rang beim Besitzer. Die Blocknummer bleibt fest („Block 3“), auch wenn die Reihenfolge sich ändert. „In Arbeit“: eine Sitzung hat den Vorgang laut Besetzung (`ARBEIT-BESETZUNG.md`, stündlich).

**Themenblöcke**

| Block | offen | Muss | in Arbeit | zum Testen | ruht | nächster |
|---|---|---|---|---|---|---|
| **Kapitel 1 fertig (Godot, BRS)** | | | | | | |
| ↳ **1** Umzug BRS, SRD ablösen | 2 (2) | 1 | 0 | 0 | 0 | 870 (Sokrates) Umstellung ganz auf BRS, SRD-Parallelbetrieb been… |
| ↳ **2** Kampf passt | 64 (61) | 18 | 0 | 1 | 51 | 1635 (Sokrates) Systemlösung? Bogen: 2 frühere Vorgänge, neu 1634… |
| ↳ **3** Kleiderschrank und Modelle (Held, Leute, Monster) | 34 (20) | 22 | 0 | 6 | 7 | 1694 (Spike) Griff einmal für alle gehaltenen Dinge: fester Gr… |
| ↳ **4** Alles an einer Stelle: Figuren, Helden, Gegenstände | 10 (10) | 3 | 0 | 0 | 6 | 644.5 (Diogenes) Abnahme Gegenstands- und Figurenkatalog: Prüfunge… |
| ↳ **5** Welt, Karten, Bild, Ton, Bedienung (auch was gegenüber Kotlin fehlt) | 51 (48) | 5 | 0 | 3 | 27 | 1628 (Homer) Kräutersammler-Handlung vor der Blutzahnhöhle, br… |
| ↳ **6** Godot besser nutzen (Technik, Build, Leistung) | 20 (11) | 11 | 0 | 5 | 4 | 1701 (Spike) alte Notizkopie trat wieder auf; Ursache finden,… |
| **7** Werkzeuge und Abläufe der Firma | 51 (48) | 28 | 0 | 2 | 12 | 1507 (Ford) Satz „Fertiges lautlos … mit 👍/👎-Zeile“ nur in St… |
| **8** Marktstart | 10 (10) | 0 | 0 | 0 | 9 | 780 (Sokrates) Unity-Asset-Store-EULA 2.2.1: gilt sie für unsere… |

**Erledigt und neu** (Kalendertage bis 24 Uhr; Woche ab Montag, Monat ab dem 1.; in Klammern bei „offen“: Stand 0:00 heute; netto plus = weniger offen)

| | heute | gestern | Woche | Monat (seit 07.11.) |
|---|---|---|---|---|
| erledigt | 82 | 114 | 398 | 1258 |
| neu | 114 | 116 | 394 | 1284 |
| **netto** (erledigt − neu) | **−32** | **−2** | **+4** | **−26** |

Monat erst ab 07.11.: vorher hatte die Vorgangsliste kein Feld Stand, offene Vorgänge sind dort nicht zählbar.

**Je Rolle das Nächste** (wie Ford startet, mit Übernahme, 1364)

| Rolle | als Nächstes |
|---|---|
| **Chef** | [1655](ansehen/1655-morwen-kapuze.md) ansehen |
| Tom | 1535 Kleidung hängt bei NPCs in der Ruhebewegung an einer Hand;… (Muss); dann 2 weitere |
| Jerry | 1653 Durchstechprüfung: Thessa Kleid sticht durch den Kragen; Si… (Muss); dann 1 weitere |
| Tuffy | 1654 Durchstechprüfung: Rowena Kleid sticht auf Hüfthöhe durch;… (Muss von Jerry, neben dessen Arbeit) |
| Spike | läuft: 1595 (Besetzung); 1694 Griff einmal für alle gehaltenen Dinge: fester Griffpunkt i… (Muss); dann 2 weitere |
| Homer | 1628 Kräutersammler-Handlung vor der Blutzahnhöhle, braut aus Kr… (Kür) |
| Diogenes | 1707 ARBEIT-PRUEFUNG.md: 1 „Zu“ zu Erledigtem, beim Übergeben st… (Kür) |
| Sokrates | läuft: 1608 (Besetzung); 870 Umstellung ganz auf BRS, SRD-Parallelbetrieb beenden: Liste… (Muss) |
| Perikles | M? M? entscheiden: 1710, 1711, 1713, 1712, 1714 (Muss); dann 1 weitere |

**Die nächsten 20**

| # | Nr. | Wer | Worum | Kl. | Block | Stand |
|---|---|---|---|---|---|---|
| 1 | 870 | Sokrates | Umstellung ganz auf BRS, SRD-Parallelbetrieb beenden: Liste, offene Regelfragen… | M | 1 Umzug BRS, SRD ablösen | startbar |
| 2 | 1694 | Spike | Griff einmal für alle gehaltenen Dinge: fester Griffpunkt in der Faustmitte je… | M | 3 Kleiderschrank und Modelle | startbar |
| 3 | 1535 | Tom | Kleidung hängt bei NPCs in der Ruhebewegung an einer Hand; alle Figuren mit Kau… | M | 3 Kleiderschrank und Modelle | startbar |
| 4 | 1676 | Tom | angelegter Umhang des Helden deckt den rechten Unterarm teils zu, links frei | M | 3 Kleiderschrank und Modelle | startbar |
| 5 | 1570 | Tom | Umhang einmal grundsätzlich lösen statt Einzelflicken: 12 frühere Vorgänge, off… | M | 3 Kleiderschrank und Modelle | startbar |
| 6 | 1653 | Jerry | Durchstechprüfung: Thessa Kleid sticht durch den Kragen; Sichtbarkeit prüfen, d… | M | 3 Kleiderschrank und Modelle | startbar |
| 7 | 1654 | Jerry | Durchstechprüfung: Rowena Kleid sticht auf Hüfthöhe durch; Sichtbarkeit prüfen,… | M | 3 Kleiderschrank und Modelle | startbar |
| 8 | 1701 | Spike | alte Notizkopie trat wieder auf; Ursache finden, warum neue Container eine alte… | M | 6 Godot besser nutzen | startbar |
| 9 | 1702 | Spike | vier Läufe zu 1655 an einem Tag, zuletzt alte Fassung des Bildskripts am Rechne… | M | 6 Godot besser nutzen | startbar |
| 10 | 1507 | Ford | Satz „Fertiges lautlos … mit 👍/👎-Zeile“ nur in Starts von Tom, Jerry, Spike, Tu… | M | 7 Werkzeuge und Abläufe der Firma | startbar |
| 11 | 1706 | Perikles | Prüfbilder bekannter Fehler gingen als Frage an den Chef, Figur am Rand, ohne M… | M | 7 Werkzeuge und Abläufe der Firma | startbar |
| 12 | 1635 | Sokrates | Systemlösung? Bogen: 2 frühere Vorgänge, neu 1634; einmal grundsätzlich lösen? | K | 2 Kampf passt | startbar |
| 13 | 1656 | Sokrates | Systemlösung? Kapuze: 2 frühere Vorgänge, neu 1655; einmal grundsätzlich lösen? | K | 3 Kleiderschrank und Modelle | startbar |
| 14 | 1628 | Homer | Kräutersammler-Handlung vor der Blutzahnhöhle, braut aus Kräutern einen Trank f… | K | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |
| 15 | 1636 | Homer | Gnade: schwer verwundeter Goblin allein, verschonen oder töten; verschont Hinwe… | K | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |
| 16 | 1637 | Homer | Lyras Fährte zwischen Wald und Höhle, wer sie liest, findet einen verborgenen z… | K | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |
| 17 | 1638 | Homer | Leuchtfunke vorschicken: außerhalb des Kampfs werfen als Köder und Sicht voraus… | K | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |
| 18 | 1705 | Homer | Leveldesign Kapitel 1, Bestandsaufnahme: alle Gebietskarten, Anordnung, Übergän… | K | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |
| 19 | 508 | Sokrates | Lehrmeister in Kapitel 1 erreichbar, Magie-Pflicht Paladin/Kriegsmagier, Wachso… | K | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |
| 20 | 1564 | Sokrates | Systemlösung? Wasser: 4 frühere Vorgänge, neu 1563; einmal grundsätzlich lösen? | K | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |

Danach 60 weitere offen. Bei dir zum Testen (vorgelegt): 17. Gebaut, fährt mit dem nächsten Build: 11. Werkzeug gebaut, Prüfung Diogenes: 18. Ruhend oder nach dem Meilenstein: 116.
## Zu entscheiden

Nichts offen.

## Zu billigen

Nichts offen.

## Anzusehen

**Bilder** (ansehen und im Gespräch „ja“ oder was anders sein soll):

| Nr. | Was | Wer | Seit |
|---|---|---|---|
| [1655](ansehen/1655-morwen-kapuze.md) | Morwen: sticht der Kopf durch die Kapuze? | – | 18.11., 20:58 |

## Zu tun

Nichts offen.

## Offen je Rolle

Vom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand 18.11.; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.

**Homer** – offen 7, Muss 0, startbar 6

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1628 | K | Von Chef (18.11., 09:00, Rollenspiegel Perikles): Kräutersammler-Handlung vor der Blutzahn | startbar |
| 1235 | K | Texte Kapitel 2 bauen (Rest aus 41; Entwurf kapitel2/STORY-K2-ENTWURF.md, Storyplan K2 fer | Chef Gespräch (großes Vorhaben, Sokrates bündelt in der Chefrunde, 1236) |
| 1636 | K | Von Chef (18.11., 09:11, Idee Sokrates 4): Gnade: schwer verwundeter Goblin allein, versch | startbar |
| 1637 | K | Von Chef (18.11., 09:11, Idee Sokrates 5): Lyras Fährte zwischen Wald und Höhle (Saum, Geb | startbar |
| 1638 | K | Von Chef (18.11., 09:10, Idee): Leuchtfunke vorschicken: außerhalb des Kampfs werfen als K | startbar |
| 1686 | K | Von Werkzeug (Startwarnung 650.2, 1642, seit 18.11., 10:55): Inhaltsverzeichnis docs/READM | startbar |
| 1687 | K | Von Werkzeug (Startwarnung 650.2, 1642, seit 18.11., 10:55): Inhaltsverzeichnis docs/READM | startbar |

**Tom** – offen 53, Muss 16, startbar 4

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1700 | M | Von Werkzeug (1334): Wiederholrot durchstich_1631: 6× rot in 48 h (Läufe 570, 568, 567, 56 | wartet auf Test/Build (gebaut) |
| 431 | M | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, da | wartet auf 870 (startbar) |
| 513 | M | Ein Figurenstand für alle Zweige; Schild, Robe Magier, Umhang jetzt (Chef 03.11., 15:56, „ | ruht bis 23.11. |
| 1297 | M | Von Sokrates (431, Chef 15.11., 14:32): Schildgröße je Körper, beim Halbling ist der Schil | wartet auf 431 (startbar) |
| 1535 | M | Von Chef (17.11., 09:18, zu 1515): Kleidung hängt bei NPCs in der Ruhebewegung an einer Ha | startbar |
| 1589.3 | M | Von Perikles (1600, 1589.1 A): Stufe 2 Gegnerverhalten, Bewegung Menschengestalten: Rückwä | Termin 21.11. 20:00 |
| 1650 | M | Von Tom (1631, Lauf 560): Durchstechprüfung: Hosen stechen durch den Stiefelschaft (0,4 m, | wartet auf Test/Build (gebaut) |
| 1655 | M | Von Tom (1631, Lauf 560): Durchstechprüfung: Morwen Kapuze schneidet in den Kopf (1,7 m, b | wartet auf Test/Build (gebaut) |
| 1657 | M | Von Tom (1631, Lauf 560): Durchstechprüfung: Held Robe M/W Hände durch die Robe (0,9–1,0 m | wartet auf 1694 (startbar) |
| 1205 | M | Von Sokrates (Chef 13.11., 18:48): Wiesen und Blumenfelder mit mehr Pflanzen aus dem Grass | wartet auf Test/Build (gebaut) |
| 1663 | M | Von Chef (18.11., 14:17, Bild, Fund): Beutel und Detailansicht eines Gegenstands ohne Wirk | wartet auf Test (Build 300) |
| 1205b | M | Von Chef (18.11., 15:37, 1205b A): in Grafik Niedrig nur die Blumen des Kits, Kleckse über | wartet auf Test/Build (gebaut) |
| 1674 | M | Von Chef (18.11., 15:59, t299, Bild): Bewohner (Kittel, Dorfplatz am Brunnen) hängt rund 2 | wartet auf Test/Build (gebaut) |
| 1675 | M | Von Chef (18.11., 15:57, t299): Wachsoldatin im Hauptmenü, Schild schwebt neben ihr; zurüc | Termin 21.11. 20:00 |
| 1676 | M | Von Chef (18.11., 15:56, t299): angelegter Umhang des Helden deckt den rechten Unterarm te | startbar |
| 1570 | M | Von Chef (18.11., 17:07, „ich bin auch für die Systemlösung“, Votum Sokrates): Umhang einm | startbar |
| 568 | K | Ernten als Handlung statt Einsaugen; Angeln mit Pose und Ring (Chef 04.11., 19:42: ja, A) | ruht bis 23.11. |
| 515 | K | Truhen: 3–4 je Karte halb versteckt, verschlossene nach BRS (Dietrich, Aufbrechen) (Chef 0 | wartet auf 870 (startbar) |
| 455.1 | K | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 1 | ruht bis 23.11. |
| 476 | K | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | wartet auf 458.3 main (gebaut) |
| 423.1 | K | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | ruht bis 23.11. |
| 292.4 | K | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., | ruht bis 23.11. |
| 145 | K | Karten je Kapitel zum Drucken | ruht bis 23.11. |
| 417.1 | K | Restmängel Tragart nach „417 passt“ (Schildabstand, Rumpfdrehen, Fußrutschen, Kornfeld, St | ruht bis 23.11. |
| 558.1 | K | Prüferrest Robe Probe 5 nachhalten, nicht bauen; Chef sieht es nach dem Durchspielen an (C | ruht bis 23.11. |
| 447.4.1 | K | Bau Lehrmeister, Meisterschaften, Ruf Kapitel 1 (447.4) | wartet auf 508 (startbar) |
| 41.2 | K | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | wartet auf 1235 (ruht) |
| 134 | K | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | aufgeteilt |
| 531a | K | Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast kaufen? (Chef 04.11., 19:27) | ruht bis 23.11. |
| 649.3 | K | Figurenkatalog: Bewohner, Händler, Lehrmeister, Söldner füllen (Tagesablauf, Laden, Stimme | wartet auf 649.2 (ruht) |
| 644.4 | K | Gegenstandskatalog: Ladenbestand und Rezepte aus texte.json und Kotlin in den Katalog umst | wartet auf 644.1 (wartet) |
| 691 | K | Platzwechsel mit Leuten und Tieren: beide gleiten ineinander (Chef 03.11., 07:44, Test 204 | ruht bis 23.11. |
| 688 | K | Frage des Chefs je Karte: wie viel Sammelbares offen und versteckt liegt (alt gegen neu: T | ruht bis 23.11. |
| 689 | K | Dorf, Urteil Chef 25.10., 12:11 (aus 348.6, offen geblieben): Büsche über Dachfirsten, Lat | ruht bis 23.11. |
| 816 | K | Effekte Szene 1 Dorf am Abend nach LISTE-EFFEKTE (Reihenfolge 623.8): gedämpft, Bilder/s n | ruht bis 23.11. |
| 839 | K | Von Homer (817): Erklärtexte der Grundwerte im Reiter Held nach BRS einbauen, Texte STORY- | ruht bis 23.11. |
| 852 | K | Von Homer (432a A, Chef 10.11., 12:05): Aschgeborene bauen: Modell Mensch mit aschgrauer S | ruht bis 23.11. |
| 861 | K | Von Sokrates (Chef 10.11., 13:12, Bild t274.14): Umhang des Kämpfers im Kampf rechts am Rü | wartet auf 431 (startbar) |
| 966.2 | K | Von Sokrates (966 A neu, Chef 11.11., 15:58): Kochen und Alchemie mit Ring wie Knacken (DE | wartet auf 870 (startbar) |
| 954a.5 | K | Von Perikles (954a.2): Schleichen auf der Gebietskarte: Schleichtaste, geduckt und langsam | wartet auf 870 (startbar) |
| 954a.7 | K | Von Perikles (954a.2, 954a.3 A): Spähen durch Verweilen: Ring zeigt Heilkräuter abseits de | wartet auf 870 (startbar) |
| 954a.12 | K | Von Perikles (954a.2): Erschaffung: nicht wählbare Fertigkeiten (Bergbau, Angeln, Lederarb | wartet auf 870 (startbar) |
| 954a.9 | K | Von Perikles (954a.2, 954a.3 B): Schmiedelehrling flickt selbst an Borins Amboss mit dem R | wartet auf 870 (startbar) |
| 976 | K | Von Sokrates (Chef 11.11., 16:31): Rezeptbuch für alle Handwerke (Rezeptliste DESIGN-BRS H | wartet auf 966.2 (startbar) |
| 1157 | K | Von Sokrates (Archivprüfung, 1038 A R1, Chef 12.11., 16:24): Verband herstellen mit dem Re | wartet auf 976 (startbar) |
| 1158 | K | Von Sokrates (Archivprüfung, 558 Probe 4, Chef 04.11., 19:48): Oberflächen für Leder und M | ruht |
| 1174 | K | Von Sokrates (Archivprüfung, 348.10 Chef 25.10., 16:36 „brauchen wir auf jeden Fall“; Zwec | wartet auf 431 (startbar) |
| 1210 | K | Von Sokrates: Regen wie alt (D3.10) fehlt in Godot; Bild ohne Vorgang (R8 Weather FX statt | ruht |
| 1406 | K | Von Spike (1386, Chef 16.11. „Drehen auf der Stelle … ganz Entscheidendes“): Wenden ab 135 | wartet auf Test (Build 300) |
| 1519 | K | Von Chef (17.11., 07:39, „Hauptmenü lebendig ja … kein Muss, ganz hinten“): vier Helden im | wartet auf 431 (startbar) |
| 1690 | K | Von Werkzeug (Startwarnung 1425, 1642, seit 18.11., 10:55): ARBEIT-TEAM-TOM.md: 5 „Zu“ zu | startbar |
| 622 | K | Godot-Build als AAB für Play: dieselbe App de.bornim.game, mit dem Upload-Schlüssel des al | nach dem Meilenstein |
| 1280 | K | Funde und Abgleich alt, Team Tom (1271a A, Chef 15.11., 11:23): 569, 570, 589, 590, 665, 6 | nach dem Meilenstein |

**Jerry** – offen 77, Muss 26, startbar 8

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1331 | M | Sammelbuild: alle fertigen Zweige beider Teams, Nummern siehe „Zu 1331“; Prüfliste ansehen | wartet auf Test (Build) |
| 760 | M | Kampf: Wolf springt beim „Anspringen“ nicht, er beißt nur; Text und Bewegung passen nicht | wartet auf Sokrates |
| 1068 | M | Von Perikles (1048 A, H, D, Chef 12.11., 20:05): Ring bei jedem großen Schlag der Gegner ( | ruht bis 21.11. 20:00 |
| 1043 | M | Von Sokrates (Chef 12.11., 15:52, Fund t278.33 Build 280, zu 988): MARS-Probekampf Wölfe, | ruht bis 21.11. 20:00 |
| 1032 | M | Von Sokrates (Chef 12.11., 14:08, Build 280, MARS-Probekampf Wölfe, Held und Söldner Wachs | ruht bis 21.11. 20:00 |
| 709.1 | M | Wolf und Grimmzahn beißen den Helden mit Schild sichtbar (aus 709 abgetrennt, Chef 10.11., | ruht bis 21.11. 20:00 |
| 506.2 | M | Grabhund-Biss reicht sichtbar bis zum Helden, nicht nur knapp an den Schild (von Sokrates, | wartet auf 709.1 (ruht) |
| 709 | M | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angre | ruht bis 21.11. 20:00 |
| 1415 | M | Von Jerry (1072 gemessen): Kampftakt Wolfsrudel, Runde 31,8–34,1 s statt 14,6 (784 A); Weg | wartet auf 709 (ruht) |
| 931 | M | Von 784 A (Chef 11.11., 12:15): Wolf vorn – „Anspringen!“ steht, während er sich duckt (ke | ruht bis 21.11. 20:00 |
| 1566 | M | Von Chef (17.11., 14:50, an Sokrates, Build 296, Bild): Höhlenwasser leuchtet hinter Wände | wartet auf Test (Build 300) |
| 1588 | M | Von Spike (1556): Wolf am eigenen Platz dreht nicht zum Ziel, wenn die Drehung tief in den | ruht bis 21.11. 20:00 |
| 1589 | M | Von Chef (17.11., 17:45–17:58, an Sokrates): Motor des Kampfs: Gegnerverhalten nach Regeln | wartet auf 1589.5 (startbar) |
| 1589.2 | M | Von Perikles (1600, 1589.1 A, Chef 17.11., 22:33): Stufe 1 Gegnerverhalten, Arena unsichtb | Termin 21.11. 20:00 |
| 1589.4 | M | Von Perikles (1600, 1589.1 A): Stufe 3 Gegnerverhalten, Figuren in die Arena: figur.gd nur | wartet auf 1589.2 (startbar) |
| 1589.5 | M | Von Perikles (1600, 1589.1 A): Stufe 4 Gegnerverhalten, Reihenfolge der Bosse Grimmzahn, K | wartet auf 1589.4 (startbar) |
| 1603 | M | Von Perikles (1600, Abgleich Tabelle 9 DESIGN-GEGNER.md): Besonderheiten fehlen im MARS oh | Termin 21.11. 20:00 |
| 455.2 | M | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völker (Chef 01.11., 11: | wartet auf Test (Build 300) |
| 1627 | M | Von Chef (18.11., 09:00, Rollenspiegel Jerry, LISTE-IDEEN): Trefferbild je Angriff: Kontak | Termin 21.11. 20:00 |
| 1652 | M | Von Tom (1631, Lauf 560): Durchstechprüfung: Osric innere Stücke stechen durch die Robe (1 | wartet auf Test (Build 300) |
| 1653 | M | Von Tom (1631, Lauf 560): Durchstechprüfung: Thessa Kleid sticht durch den Kragen (1,4–1,5 | startbar |
| 1654 | M | Von Tom (1631, Lauf 560): Durchstechprüfung: Rowena Kleid sticht auf Hüfthöhe durch (0,9 m | startbar |
| 1664 | M | Von Chef (18.11., 14:19/14:20, Fund): im Kampf (Wald, drei Goblins, Held Zauberlehrling, B | wartet auf Test (Build 300) |
| 1697 | M | Von Jerry (Film t300.9, Lauf 567): dunkle Rechtecke unter Held und Goblin im Kampfort Wald | Chef (Datei in der Chefsache) |
| 1698 | M | Von Ford (Befund Spike 18.11., 18:14): frischer Bau des Blocks klassen (held_klassen.py au | wartet auf Test/Build (gebaut) |
| 1563 | K | Von Chef (17.11., 12:22, an Sokrates, Build 296, nannte 1155): Teich in der Höhle am Ufer | wartet auf 1564 (startbar) |
| 438a | K | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv | ruht bis 23.11. |
| 416.6 | K | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef 31.10., 20:4x; 03.1 | ruht bis 23.11. |
| 406.1 | K | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann | wartet auf 469 (ruht) |
| 510 | K | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt ( | ruht bis 23.11. |
| 509 | K | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot (Chef 03.11., 09:21; Po | ruht bis 23.11. |
| 494 | K | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Woche | ruht bis 23.11. |
| 507 | K | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager (Orte O10; aus 492) | ruht bis 23.11. |
| 496 | K | Durchspiel-Build: Kapitel 1 von Anfang bis Ende am Handy (Wochenziel 03.11., 488) | ruht bis 23.11. |
| 385.2 | K | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | ruht bis 21.11. 20:00 |
| 344.2 | K | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | ruht bis 23.11. |
| 39 | K | Schwierigkeitsgrad im Menü | ruht bis 23.11. |
| 59e | K | Händler: Vorrat je Laden | ruht bis 23.11. |
| 469 | K | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | ruht bis 23.11. |
| 598 | K | Umweltklang je Ort, Tageszeit, Wind und Wetter, lebendige Welt (Chef 05.11., 19:2x; Abnahm | ruht bis 23.11. |
| 649.4 | K | Zwei bis drei Handlungen je gewöhnlicher Monsterart vorschlagen und in 444 messen, nur wo | ruht bis 23.11. |
| 644.1 | M | Gegenstandskatalog: Werkzeug mit Spalten, Teil Rezepte und Prüfungen (644 A), zusammen mit | wartet auf 649.2 (ruht) |
| 644.2 | K | Gegenstandskatalog: C1 Fertigkeit +1/+2 ab episch ohne Pflicht-Nachteil (Chef 14:32), C2 S | ruht bis 23.11. |
| 681 | K | Trinkgeräusch in drei Varianten beim Met und anderen Getränken (Chef 08.11., 16:16) | ruht bis 23.11. |
| 930.3 | K | Von Sokrates (930): Rechnung (fertig, handgemenge_930.md) und Film zur Regelseite Handgeme | wartet auf 931 (ruht) |
| 954a.6 | K | Von Perikles (954a.2): Hinterhalt aus dem Schleichen: unbemerkt bis zum Angriff, Kampf beg | wartet auf 870 (startbar) |
| 954a.8 | K | Von Perikles (954a.2): Wurfwaffen: Grundform Wurfmesser (auch für die Elstern, Truhe cave_ | wartet auf 870 (startbar) |
| 954a.10 | K | Von Perikles (954a.2, 954a.3 A): Tiere beruhigen vor dem Kampf: Wolf, Wildschwein, Riesenf | wartet auf 870 (startbar) |
| 954a.11 | K | Von Perikles (954a.2): Jagd: Tiere geben öfter Fell, Fleisch, Hauer (tabellen.json), Auftr | wartet auf 870 (startbar) |
| 954a.13 | K | Von Perikles (954a.2, D): Volksmerkmal Glückskind (Hügelvolk) wirkt nur im alten Kampf kla | wartet auf 870 (startbar) |
| 785.9 | K | Von Spike (785): MARS-Probekampf im Systemmenü mit Regelseite (Reihen, Ansagen, Ring, Perf | ruht bis 21.11. 20:00 |
| 785.13 | K | Von Spike (785): Eingebung beim ersten Schlag von hinten (SK 571–573); Ersthinweis vordere | ruht bis 21.11. 20:00 |
| 785.14 | K | Von Spike (785): Langes Drücken auf eigene Figur oder Gruppenkasten zeigt Waffe, Mana, „ha | ruht bis 21.11. 20:00 |
| 785.16 | K | Von Spike (785): Raster- und Würfelschalter im Kampf über Kämpfe gemerkt (GameViewModel.kt | ruht bis 21.11. 20:00 |
| 785.18 | K | Von Spike (785): Stufenaufstieg im Endfeld des Kampfes hervorgehoben (alt eigenes Feld „St | ruht bis 21.11. 20:00 |
| 999.2 | K | Von 999: Armbrust als Waffenmodell im Kampf (Ersatzwaffe der Probehelden, light_crossbow); | ruht bis 23.11. |
| 1036.1 | K | Von Tuffy (1036, Chef 12.11., 20:52): neue Vorlage Zustände, jeder Zustand des Codes mit a | ruht bis 20.11. |
| 1165 | K | Von Sokrates (Archivprüfung, 490/493 Chef 03.11. „nach dem Durchspielen“): Prüferbefunde K | wartet auf 496 (ruht) |
| 1224 | K | Von Tom (aus 1041, Rest Commit d1cfba877): Berührungsprüfung beim Platztausch (Netze beide | ruht bis 21.11. 20:00 |
| 1319 | K | Von Homer (1318): Kampfmeldung MSG532_CURED „von allen Leiden befreit“ stimmt nicht (Rausc | startbar |
| 1336 | K | Aus 1141 (Jerry 13.11., 18:55): Robe des Goblin-Schamanen fällt steif, Schattenseite zu du | ruht bis 21.11. 20:00 |
| 1402 | K | Von Chef (16.11., 10:11, Idee zu 1284a; „als großes Thema … fürs Feintuning und für den Ka | ruht bis 21.11. 20:00 |
| 1404 | K | Von Chef (1291a D, 16.11., 10:37): Machbarkeitsstudie Kampf mit zwei Waffen, ohne Spielcod | ruht bis 21.11. 20:00 |
| 1486 | K | Von Sokrates (1411.1 Tuffy 16.11., 20:32; 1403): bei gleicher Stufe gewinnen Wachsoldat un | wartet auf Sokrates |
| 1487 | K | Von Sokrates (1411.1 Tuffy 16.11., 20:32; Fund 644a.1): Heiler wächst in Kapitel 1 nie im | ruht bis 21.11. 20:00 |
| 623.9 | K | Aus 623.2 (Jerry): Effekte Szene 3 Höhle einbauen (623.8 A, Chef 09.11., 22:23): Nebel R8, | ruht bis 21.11. 20:00 |
| 1526 | K | Von Chef (17.11., 08:12, Probekampf Wölfe, Build 295; Rest aus 1072): vorderer Wolf weicht | wartet auf 1589.4 (startbar) |
| 1536 | K | Von Homer (1525 C, Chef 17.11., 09:43): drei Merkmalsnamen je Tiermerkmal einbauen, im Kam | ruht bis 21.11. 20:00 |
| 1529.1 | K | Von Sokrates (1529 nach Votum, Chef 17.11., 10:51): Ausdauer im Kampf bauen nach DESIGN-GL | ruht |
| 1607 | K | Von Sokrates (Chef 17.11., 23:46 „irgendwann … das Glut-System mal umbenennen in Kerbensys | Termin 21.11. 20:00 |
| 1634 | K | Von Chef (18.11., 09:11, Idee Sokrates 1): Höhle weiß, wie du kommst: entkommt ein Späher | startbar |
| 1639 | K | Von Chef (18.11., 09:10, Idee): Festklammern: ab drei Goblins klammert einer den Helden, d | startbar |
| 1684 | K | Von Werkzeug (Startwarnung 108, 1642, seit 18.11., 10:55): Datei über 60 KB: docs/chefsach | startbar |
| 1685 | K | Von Werkzeug (Startwarnung 108, 1642, seit 18.11., 10:55): Datei über 60 KB: docs/chefsach | startbar |
| 1691 | K | Von Werkzeug (Startwarnung 1425, 1642, seit 18.11., 10:55): ARBEIT-TEAM-JERRY.md: 8 „Zu“ z | startbar |
| 168.1 | K | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | nach dem Meilenstein |
| 1281 | K | Funde und Abgleich alt, Team Jerry (1271a A, Chef 15.11., 11:23): 551, 289, 628, 634, 936, | nach dem Meilenstein |

**Spike** – offen 29, Muss 20, startbar 4

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1694 | M | Von Chef (18.11., 17:01, „Als Systemlösung, genau“, Votum Sokrates): Griff einmal für alle | startbar |
| 1484 | M | Von Sokrates (Chef 16.11., 20:20, Tablet SM-X210, Adreno 619, Build 286): Welt und Kampf 9 | Termin 21.11. 20:00 |
| 1537 | M | Von Sokrates (1520 so, Chef 17.11., 10:00): Neustart-Haken zusätzlich an jeden Werkzeugauf | Termin 23.11. |
| 1484a | M | Von Spike (1484, Auswertung Tablet 17.11.): Rückfrage Welt in Zellen teilen, Durchsicht nu | Termin 21.11. 20:00 |
| 1589.6 | M | Von Perikles (Chef 17.11., 23:13 „wir haben auch Tuffy und Spike“; 1589.2): Rechnung 444 i | wartet auf 1589.2 (startbar) |
| 458.3 | M | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | Termin 21.11. 20:00 |
| 1621 | M | Von Chef (18.11., 07:37, A, Votum Sokrates): Zweihandwaffen kürzer: Großaxt 131→110 cm, Kr | wartet auf 1694 (startbar) |
| 1619 | M | Von Chef (18.11., 07:29, über Sokrates): Held stakst im Film 458.3, sieht nicht nach Gehen | wartet auf Test t301 (Chef) |
| 649.2 | M | Figurenkatalog Schritt 2: Werkzeug figuren.py und tools/figuren/figuren.json (Art und Auft | ruht bis 21.11. 20:00 |
| 1642 | M | Von Sokrates (340.12 A, Chef 18.11., 09:45): Änderung 1 Rollenspiegel: jede Startwarnung m | Termin 25.11. |
| 1643 | M | Von Sokrates (340.12 A, Chef 18.11., 09:45): Änderung 3 Rollenspiegel, Rest neben 1624: de | Termin 25.11. |
| 1645 | M | Von Spike (1270.5 Rang 6): Kampfort setzt die Sonnenschattenkarte beim Verlassen fest auf | wartet auf Test (Build 300) |
| 1649 | M | Von Sokrates (1621, Chef 18.11., 11:55): Zweihandwaffe im Stand: keine Haltung (Stehen_axt | wartet auf 1694 (startbar) |
| 1270.6 | M | Von Sokrates (1270.5 A, Chef 18.11., 13:06): Messbuild Technik: Schalter 3D-Auflösung 50 % | wartet auf Test (Build 300) |
| 1270.7 | M | Von Sokrates (1270.5 A, Chef 18.11., 13:06): nach Messung 1270.6: Texturen komprimiert (Nr | Termin 21.11. 20:00 |
| 1665 | M | Von Chef (18.11., 14:34, Fund, Build 298/299): Streitkolben in der Haupthand angelegt, am | startbar |
| 1669 | M | Von Perikles (1668, Chef 18.11., 14:44): nächster Sammelbuild ein Handypunkt Grafikstufe: | wartet auf Test (Build 300) |
| 1670 | M | Von Chef (18.11., 15:30, Fund, Build 299): Grafik Hoch im Systemmenü 1. Mal zurück auf Aut | wartet auf Test (Build 300) |
| 1632 | K | Von Chef (18.11., 09:00, Rollenspiegel Diogenes): Gangprüfung im Bautest: Fußgleiten je Bo | wartet auf Test t301 (Chef) |
| 1630 | K | Von Chef (18.11., 09:00, Rollenspiegel Ford): alle Lichtquellen der Höhle (Fackeln, Glut, | wartet auf Test (Build 300) |
| 474 | K | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, M | ruht bis 23.11. |
| 30 | K | Abstürze beim Testen | ruht bis 23.11. |
| 348.13 | K | Tusche nach Licht wie entschieden (Chef 26.10.) | ruht bis 23.11. |
| 1613 | K | Von Sokrates (458.3, Vorentscheid 18.11.): Waffen episch und höher mit Effekt statt Färbun | Termin 21.11. 20:00 |
| 1270.8 | K | Von Sokrates (1270.5 A, Chef 18.11., 13:06): nur wenn die Messung es verlangt: Tusche halb | Termin 21.11. 20:00 |
| 1666 | K | Von Jerry (1652): bau_am_rechner.py --cache bricht ohne Blender ab, sobald nur Block klass | wartet auf Test t301 (Chef) |
| 1629 | K | Von Chef (18.11., 09:00, Rollenspiegel Sokrates): epische Beute (höchste Stufe) zeigt beim | nach dem Meilenstein |
| 1701 | M | Von Sokrates (Archiv 18.11., 20:27): alte Notizkopie trat wieder auf (Sokrates 20:29: 60 e | startbar |
| 1702 | M | Von Sokrates (1655, 18.11., 20:59): vier Läufe zu 1655 an einem Tag, zuletzt alte Fassung | startbar |

**Perikles** – offen 24, Muss 17, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1148 | M | Von Ford (13.11., 14:58): lauf.py startet/archiviert Spike 882.1 wiederholt, obwohl dessen | Termin 23.11. |
| 1572 | M | Von Chef (17.11., 17:02, an Sokrates): Ford hing ab 16:04 zwei Stunden (Rebase-Abbruch abg | wartet auf 1610 (gebaut) |
| 1462 | M | Von Sokrates (Chef 16.11., 16:31 „Haltung 4 schärfen mit Zahl, so machen“): Liegengebliebe | Termin 30.11. |
| 1398 | M | Von Chef (16.11., 10:01, über Sokrates): Prüfliste mischt wieder Bild/Film mit APK-Wegen; | wartet auf Test/Build (gebaut) |
| 464 | M | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählu | wartet auf 1388 (wartet) |
| D75 | M | Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1); meldung.sh --film legte Film 572 nich | Dauerzeile |
| 1125 | M | D195.1 von Diogenes (1100.1): Ford-Lauf nach 1100 nicht billiger: Uhrläufe 9 Schritte wie | Termin 23.11. |
| 1173 | M | Von Sokrates (Chef 13.11., 15:40 „Kleinkram bitte selbst erledigen“, A): Regel Kleinkram o | Termin 23.11. |
| 1301 | M | Von Sokrates (Chef 15.11., 16:54 zu 760: „vielleicht kommt ja jemand auch auf die Idee noc | Termin 23.11. |
| 1387 | M | Von Sokrates (1129.4, Punkt 6 gerissen): Übersicht-Commits 15.11. 193 (14.11.: 37), Ursach | wartet auf Diogenes |
| 1388 | M | D257.1 von Diogenes (464): rote Godot-Läufe 09.–15.11. 93 von 159 (58 %) gegen 52 von 185 | Termin 23.11. |
| 1400 | M | D261.1 von Diogenes: „Geprüft an“ nennt Commits, die es nicht gibt: 1392 c28c2e3d9 (echt 2 | Termin 23.11. |
| 1414 | M | Von Chef (16.11., 12:09, über Sokrates): Warnung bei Vorgangsnummer ohne Wort dazu in Vorl | Termin 23.11. |
| 1506 | M | Von Sokrates: startbar.py zeigt Kür am Aussehen als startbar, obwohl 488 sie einfriert (To | Termin 23.11. |
| 1583 | M | Von Jerry (1578): rotbuch.py --anlegen legt einen Wiederholer neu an, sobald sein Vorgang | wartet auf Test/Build (gebaut) |
| 1610 | M | D305.1 von Diogenes (1572): Hängeralarm kam 15 bis 75 statt 15 Minuten nach dem Hängen (la | Termin 23.11. |
| 1662 | M | Von Ford (18.11., 13:06): lauf.py startete Jerry für Nachfolger 1595 (Schlussbuild 299), o | Termin 23.11. |
| 870.12 | K | Von Sokrates (870, Umzug BRS): Projektplan 2.3 (212 weg, Pechsträhne als Prozent) und 2.17 | wartet auf 870 (startbar) |
| 341 | K | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug u | Termin 23.11. |
| 1100 | K | Von Perikles (zu 1098): Ford-Lauf verbraucht 80–130 Tsd. Token je Stunde; Ausgabe von lauf | wartet auf 1125 (gebaut) |
| 1188 | K | Von Sokrates (1186, Chef 13.11., 16:28): Wächter gegen still veraltete Zeilen: ruhende ode | Termin 23.11. |
| 1396 | K | Von Ford (Tuffy 16.11., 10:00): lauf.py startet Tuffy auf Zeile 1393, die Jerry schon in s | wartet auf Test/Build (gebaut) |
| 1689 | K | Von Werkzeug (Startwarnung Pflege, 1642, seit 18.11., 10:55): ARBEIT-TAGESBERICHT.md: Tabe | startbar |
| 1703 | K | Von Werkzeug (Startwarnung 650.2, 1642, seit 18.11., 14:44): Inhaltsverzeichnis docs/READM | startbar |

**Diogenes** – offen 8, Muss 7, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1301 | M | Von Sokrates (Chef 15.11., 16:54 zu 760: „vielleicht kommt ja jemand auch auf die Idee noc | Termin 23.11. |
| 1387 | M | Von Sokrates (1129.4, Punkt 6 gerissen): Übersicht-Commits 15.11. 193 (14.11.: 37), Ursach | Termin 23.11. |
| 1642 | M | Von Sokrates (340.12 A, Chef 18.11., 09:45): Änderung 1 Rollenspiegel: jede Startwarnung m | Termin 25.11. |
| 1643 | M | Von Sokrates (340.12 A, Chef 18.11., 09:45): Änderung 3 Rollenspiegel, Rest neben 1624: de | Termin 25.11. |
| 1128.3 | M | Von Sokrates (1128 A, Chef 13.11., 13:36): ab Build 283 Funde und Rückschritte je Prüfart | Termin 23.11. |
| 1172 | M | Von Sokrates (Kleinkram A, Chef 13.11., 15:40): montags zählen: Kleinkram-Punkte ohne Chef | Termin 23.11. |
| 186.3 | K | Ausgefüllte Prüfbögen auswerten | ruht bis 23.11. |
| 644.5 | M | Abnahme Gegenstands- und Figurenkatalog: Prüfungen des Werkzeugs grün, Godot liest nur noc | wartet auf 644.1 (wartet) |

**Sokrates** – offen 44, Muss 9, startbar 9

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1520 | M | Von Chef (17.11., 06:18): An den Läufen sparen; A Neustart-Haken auch in langen Zügen, Spe | ruht bis 24.11. |
| 1129 | M | Systemprüfung blinde Flecken mit Perikles: Regeln, Abläufe, Werkzeuge, die schneller, einf | wartet auf 1387 (gebaut) |
| 887 | M | Archivieren und Kaufrepo ohne Nachfrage: Probe Sitzungsmodus statt Auto-Modus (dontAsk von | ruht bis 23.11. |
| 870 | M | Umstellung ganz auf BRS, SRD-Parallelbetrieb beenden: Liste, offene Regelfragen, Bau Tom u | startbar |
| 649 | M | Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten), Bestiarium ge | wartet auf 649.2 (ruht) |
| 1137 | M | Vollzugsmeldung je Entscheid (Chef 13.11., 14:00/14:03): Folgeaufträge melden Vollzug auf | ruht bis 23.11. |
| 1189 | M | Leichenprüfung der Vorgangsliste alle 48 h (Diogenes?): Erledigtes, Überholtes, Hängendes | Termin 27.11. |
| 1679 | M | Von Chef (18.11., 16:32, Frage): wer ist zuständig für Kartendesign, Design grundsätzlich, | startbar |
| 760 | M | Kampf: Wolf springt beim „Anspringen“ nicht, er beißt nur; Text und Bewegung passen nicht | startbar |
| 1625 | K | Von Chef (18.11., 08:17/08:22, Idee): feste Startprompts je Rolle statt Startlektüre; wir | ruht bis 25.11. |
| 780 | K | Unity-Asset-Store-EULA 2.2.1 (keine Assets als Eingabe für KI-Programme): gilt sie für uns | Termin 23.11. |
| 620 | K | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build | Termin 23.11. |
| 508 | K | Lehrmeister in Kapitel 1 erreichbar (Geselle), Magie-Pflicht Paladin/Kriegsmagier, Wachsol | startbar |
| 383.2 | K | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | ruht bis 23.11. |
| 26.1 | K | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef | ruht bis 23.11. |
| 296 | K | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MA | ruht bis 23.11. |
| 262 | K | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | ruht bis 23.11. |
| 253 | K | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf | ruht bis 23.11. |
| 142.3 | K | Tester öffentlich suchen (Chef 27.10., 19:32) | ruht bis 23.11. |
| 142.4 | K | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 07.11.) | ruht bis 24.11. |
| 340 | K | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Che | ruht bis 26.11. |
| 344 | K | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23 | ruht bis 23.11. |
| 644 | K | Alle Gegenstände an einer Stelle: Katalog 458 mit BRS-Werten, Voraussetzungen, Seltenheit, | wartet auf 644.1 (wartet) |
| 654 | K | Mitdenken vor dem Bauen: Systemfrage je Fund („kommt das wieder?“), Wiederholungswächter, | Termin 23.11. |
| 930 | K | Handgemenge und Abstand im Kampf, Prüfauftrag: Regelseite nach BRS, Rechnung und Film Jerr | wartet auf 930.3 (ruht) |
| 1270 | K | Grafik-Engine Godot ausschöpfen: Laden, Sichtweite, Shader vorab, Glühen, Abziehbilder; Vo | startbar |
| 1509 | K | Systemlösung? Nebel: 6 frühere Vorgänge (502, 505, 1091, 785.7, 1145 …), neu 623.9; einmal | ruht bis 21.11. 20:00 |
| 1510 | K | Systemlösung? Teich: 5 frühere Vorgänge (1155, 509, 507, 509a, 493), neu 623.9; einmal gru | ruht bis 21.11. 20:00 |
| 1521 | K | Figurenkatalog Build 3 (Rest aus 649, 649b A; Perikles 17.11.: Muss 649 schließt nach Buil | wartet auf 649.3 (ruht) |
| 1532 | K | Von Chef (17.11., 08:41, Idee, ja zur Vorlage 08:46): Hinterhalt mit dem Rücken: Held steh | ruht bis 21.11. 20:00 |
| 1533 | K | Von Chef (17.11., 08:44/08:52, Idee): Gegner ohne Zahlen: Zustand und Stärke in Worten nac | ruht |
| 1534 | K | Von Chef (17.11., 08:53, Idee): Gegnerkunde: Reiter „Gegner“ in der Chronik, füllt sich mi | ruht |
| 366 | K | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | ruht bis 24.11. |
| 1564 | K | Systemlösung? Wasser: 4 frühere Vorgänge (1155, 221, 623.6, 1218), neu 1563; einmal grunds | startbar |
| 1635 | K | Systemlösung? Bogen: 2 frühere Vorgänge (26.1, 1041), neu 1634; einmal grundsätzlich lösen | startbar |
| 1656 | K | Systemlösung? Kapuze: 2 frühere Vorgänge (475a, 1546), neu 1655; einmal grundsätzlich löse | startbar |
| 1693 | K | Von Werkzeug (Startwarnung 1425, 1642, seit 18.11., 10:55): ARBEIT-BERATUNG.md: 1 „Zu“ zu | startbar |
| 1486 | K | Von Sokrates (1411.1 Tuffy 16.11., 20:32; 1403): bei gleicher Stufe gewinnen Wachsoldat un | ruht bis 21.11. 20:00 |
| 327 | K | Zweites Spiel: Marktsichtung Denkspiele, Modell ohne Werbung (Chef 23.10., 00:08; vertraul | nach dem Meilenstein |
| 246.1 | K | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | nach dem Meilenstein |
| 72c | K | Brainstorming Wunden bis zur Rast (Zeichen, Heilung mit Verband oder Tempel, schwere Wunde | nach dem Meilenstein |
| 142 | K | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | nach dem Meilenstein |
| 45 | K | Geschäftsmodell und Umsetzung (Play Store) | nach dem Meilenstein |
| 109 | K | Repo öffentlich | nach dem Meilenstein |
## Lücken

Vom Werkzeug gefunden (D21.3): steht in der Vorgangsliste, hat hier keine Datei.

Format (Muster: „So geht's“ unten): ansehen/1655-morwen-kapuze.md: kein Absender (Zeile 1 „· <Rolle> ·“ oder Zeile 2)

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
