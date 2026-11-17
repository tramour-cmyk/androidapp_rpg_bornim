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

Vom Werkzeug gerechnet (`tools/ueberblick.py`, 1313), Vorgangsliste vom 17.11., 01:28, neu bei jeder Änderung. Reihenfolge der Blöcke und ihren Zuschnitt legst du fest; vorziehen: sag es, wir setzen den Rang beim Besitzer. Die Blocknummer bleibt fest („Block 3“), auch wenn die Reihenfolge sich ändert.

**Themenblöcke**

| Block | offen | Muss | in Arbeit | zum Testen | ruht | nächster |
|---|---|---|---|---|---|---|
| **Kapitel 1 fertig (Godot, BRS)** | | | | | | |
| ↳ **1** Umzug BRS, SRD ablösen | 2 (3) | 1 | 0 | 0 | 0 | 870 (Sokrates) Umstellung ganz auf BRS, SRD-Parallelbetrieb been… |
| ↳ **2** Kampf passt | 61 (61) | 20 | 1 | 9 | 8 | 1340 (Jerry) Aus 1215: Sterben mit Physik fehlt noch für Skele… |
| ↳ **3** Kleiderschrank und Modelle (Held, Leute, Monster) | 16 (16) | 7 | 1 | 2 | 8 | 431 (Tom) Völker als Modelle: erst Bibliothek sichten, Kand… |
| ↳ **4** Alles an einer Stelle: Figuren, Helden, Gegenstände | 10 (10) | 1 | 0 | 0 | 3 | 649.4 (Jerry) Zwei bis drei Handlungen je gewöhnlicher Monstera… |
| ↳ **5** Welt, Karten, Bild, Ton, Bedienung (auch was gegenüber Kotlin fehlt) | 51 (52) | 8 | 1 | 4 | 20 | 531 (Tom) Build 249: Garrick wie alt und besser: Gesicht, L… |
| ↳ **6** Godot besser nutzen (Technik, Build, Leistung) | 13 (13) | 5 | 0 | 6 | 3 | 496 (Jerry) Durchspiel-Build: Kapitel 1 von Anfang bis Ende a… |
| **7** Werkzeuge und Abläufe der Firma | 41 (43) | 26 | 0 | 0 | 9 | 1501 (Jerry) D283.1 von Diogenes: claude/build-294 ohne main a… |
| **8** Marktstart | 10 (10) | 0 | 0 | 0 | 8 | 780 (Sokrates) Unity-Asset-Store-EULA 2.2.1: gilt sie für unsere… |

**Erledigt und neu** (Kalendertage bis 24 Uhr; Woche ab Montag, Monat ab dem 1.; in Klammern bei „offen“: Stand 0:00 heute; netto plus = weniger offen)

| | heute | gestern | Woche | Monat (seit 07.11.) |
|---|---|---|---|---|
| erledigt | 6 | 202 | 208 | 1068 |
| neu | 2 | 164 | 166 | 1056 |
| **netto** (erledigt − neu) | **+4** | **+38** | **+42** | **+12** |

Monat erst ab 07.11.: vorher hatte die Vorgangsliste kein Feld Stand, offene Vorgänge sind dort nicht zählbar.

**Je Rolle das Nächste** (wie Ford startet, mit Übernahme, 1364)

| Rolle | als Nächstes |
|---|---|
| **Chef** | [t294](ansehen/t294-sammelbuild.md) testen, hält 16 Zeilen; dann 6 weitere |
| Tom | 431 Völker als Modelle: erst Bibliothek sichten, Kandidaten dre… (Muss); dann 1 weitere |
| Jerry | 1340 Aus 1215: Sterben mit Physik fehlt noch für Skelett und Wie… (Muss); dann 3 weitere |
| Tuffy | 1284b Rückfrage zu 1284: Rattenbiss verdeckt der Held selbst, nic… (Muss von Jerry, neben dessen Arbeit); dann 2 weitere |
| Spike | leer, weil 3 ruht, 2 wartet auf Test, 2 wartet auf Test/Build |
| Homer | 1235 Texte Kapitel 2 bauen, nach dem Meilenstein (nach dem Meilenstein) |
| Diogenes | Pflege von Werkzeug: 3 „Zu“ zu Erledigtem, beim Übergeben streichen (Kür) |
| Sokrates | Pflege von Werkzeug: Übergabe über 700 Zeichen; 8 „Zu“ zu Erledigt… (Kür) |
| Perikles | Pflege von Werkzeug: 1 „Zu“ zu Erledigtem, beim Übergeben streichen (Kür) |

**Die nächsten 20**

| # | Nr. | Wer | Worum | Kl. | Block | Stand |
|---|---|---|---|---|---|---|
| 1 | 1340 | Jerry | Aus 1215: Sterben mit Physik fehlt noch für Skelett und Wiedergänger | M | 2 Kampf passt | in Arbeit |
| 2 | 1284b | Jerry | Rückfrage zu 1284: Rattenbiss verdeckt der Held selbst, nicht der Nachbar; Kame… | M | 2 Kampf passt | startbar |
| 3 | 431 | Tom | Völker als Modelle: erst Bibliothek sichten, Kandidaten drehend im Film vorlege… | M | 3 Kleiderschrank und Modelle | in Arbeit |
| 4 | 531 | Tom | Build 249: Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertr… | M | 5 Welt, Karten, Bild, Ton, Bedienung | in Arbeit |
| 5 | 1423 | Jerry | Felswände der Höhle nur nabelhoch, auch mit 1289 auf claude/spike-1303-stufen;… | M | 5 Welt, Karten, Bild, Ton, Bedienung | startbar |
| 6 | 1501 | Jerry | D283.1 von Diogenes: claude/build-294 ohne main ab 21:47 gebaut, 1485 fehlt; AP… | M | 7 Werkzeuge und Abläufe der Firma | startbar |
| 7 | 507 | Jerry | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager | K | 2 Kampf passt | startbar |
| 8 | 469 | Jerry | Kampf auf BRS: Ring ohne Klassen regeln | K | 2 Kampf passt | startbar |
| 9 | 623.2 | Jerry | Effekte Szene 2 Wolfskampf und Szene 3 Höhle einbauen, Datenfeld fx in LISTE-EF… | K | 2 Kampf passt | startbar |
| 10 | 785.9 | Jerry | MARS-Probekampf im Systemmenü mit Regelseite wie alt | K | 2 Kampf passt | startbar |
| 11 | 785.10 | Jerry | Rest aus 536, auf dessen Zweig und main nicht gebaut: Erklärung je Zauber, Fähi… | K | 2 Kampf passt | startbar |
| 12 | 785.11 | Jerry | Zielwahl im Kampf: Reihe in der Zielliste, gleichnamige Gegner unterscheidbar;… | K | 2 Kampf passt | startbar |
| 13 | 785.12 | Jerry | Ring: Ersthinweis am ersten Ring und Erklärung des Zeichens im Bericht; Urteil… | K | 2 Kampf passt | startbar |
| 14 | 785.13 | Jerry | Eingebung beim ersten Schlag von hinten; Ersthinweis vordere Reihe erledigt mit… | K | 2 Kampf passt | startbar |
| 15 | 785.14 | Jerry | Langes Drücken auf eigene Figur oder Gruppenkasten zeigt Waffe, Mana, „halber Z… | K | 2 Kampf passt | startbar |
| 16 | 785.15 | Jerry | Erklärfenster im Kampf lässt sich wegtippen und verschwindet während des Rings | K | 2 Kampf passt | startbar |
| 17 | 785.16 | Jerry | Raster- und Würfelschalter im Kampf über Kämpfe gemerkt | K | 2 Kampf passt | startbar |
| 18 | 785.17 | Jerry | Zurück-Taste im Kampf schließt das Untermenü; ganzer Bericht erledigt mit 833 A | K | 2 Kampf passt | startbar |
| 19 | 785.18 | Jerry | Stufenaufstieg im Endfeld des Kampfes hervorgehoben | K | 2 Kampf passt | startbar |
| 20 | 1319 | Jerry | Kampfmeldung MSG532_CURED „von allen Leiden befreit“ / “cured of all ailments”… | K | 2 Kampf passt | startbar |

Danach 77 weitere offen. Bei dir zum Testen (vorgelegt): 21. Gebaut, fährt mit dem nächsten Build: 9. Werkzeug gebaut, Prüfung Diogenes: 18. Ruhend oder nach dem Meilenstein: 59.
## Zu entscheiden

Muss zuerst, dann neueste oben. Vorrang und Bereich aus `LISTE-VORGAENGE.md` (Klasse, 126; Bereich, 124), Bereich in Zeile 2 der Datei geht vor (136).

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [431h](entscheiden/431h-stufe2-ruestung.md) | **Muss** | E Figuren | 17.11., 00:51 | 431h (Rüstung sichtbar), Stufe 2 zeigt jede angelegte Rüstung mit ihrem eigenen Teil, auch Stücke anderer Herkünfte und die Ritterteile; Aufwand und Risiko hier. | Tom |

## Zu billigen

Nichts offen.

## Anzusehen

**Bilder** (ansehen und im Gespräch „ja“ oder was anders sein soll):

| Nr. | Was | Wer | Seit |
|---|---|---|---|
| [1439](ansehen/1439-mana-balken.md) | Mana als eigener blauer Balken im Kampfschirm | – | 16.11., 23:51 |
| [1448](ansehen/1448-leiste-ohne-woerter.md) | Weltleiste und Heldenmenü ohne Wörter vor den Balken | – | 17.11., 01:14 |
| [1499](ansehen/1499-laufnachweis-skripte.md) | Laufnachweis: Prüfskripte mit Endung werden jetzt erkannt | – | 16.11., 23:11 |
| [601.1](ansehen/6011-pfeiltreffer.md) | Pfeiltreffer: Pfeil an der Brust, der Getroffene zuckt dort | – | 17.11., 00:36 |

**Builds** (installieren und testen; Folge = Version aufsteigend, Android installiert nur höhere Nummern über niedrigere):

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.348.542](ansehen/t294-sammelbuild.md) | [Build 294](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43980603017/artifacts/14284795775) | Sammelbuild: Wolf bleibt dran und dreht zum Helden, Zurück im Hauptmenü fragt, Leben in Kampfmeldungen, Testreparaturen | Tom und Jerry | 17.11., 01:25 |

## Zu tun

Was nur du tun kannst (Satz in einer Sitzung, Freigabe, Kauf; 275). Erledigt: Datei löschen.

| Nr. | Vorrang | Bereich | Seit | Was | Wer |
|---|---|---|---|---|---|
| [1484](tun/1484-tablet-messen.md) | **Muss** | E Technik | 16.11., 21:09 | Auf dem Tablet mit Build 293 einmal Wald und einmal Kampf messen (etwa 5 Minuten) | Spike |

## Offen je Rolle

Vom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand 17.11.; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.

**Homer** – offen 1, Muss 0, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1235 | K | Texte Kapitel 2 bauen (Rest aus 41; Entwurf kapitel2/STORY-K2-ENTWURF.md, Storyplan K2 fer | nach dem Meilenstein |

**Tom** – offen 57, Muss 15, startbar 12

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1044 | M | Von Sokrates (Chef 12.11., 16:08; 13.11., 09:35 zurück bis auf Lyra): Leute stehen außerha | wartet auf Test (Build 294) |
| 1383 | M | Von Werkzeug (1334): Wiederholrot ziege_4162: 6× rot in 48 h (Läufe 513, 500, 499, 484, 47 | wartet auf Test (Build 294) |
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
| 649.3 | M | Figurenkatalog: Bewohner, Händler, Lehrmeister, Söldner füllen (Tagesablauf, Laden, Stimme | wartet auf 649.2 (wartet) |
| 644.4 | M | Gegenstandskatalog: Ladenbestand und Rezepte aus texte.json und Kotlin in den Katalog umst | wartet auf 644.1 (wartet) |
| 691 | K | Platzwechsel mit Leuten und Tieren: beide gleiten ineinander (Chef 03.11., 07:44, Test 204 | ruht bis 23.11. |
| 688 | K | Frage des Chefs je Karte: wie viel Sammelbares offen und versteckt liegt (alt gegen neu: T | ruht bis 23.11. |
| 689 | K | Dorf, Urteil Chef 25.10., 12:11 (aus 348.6, offen geblieben): Büsche über Dachfirsten, Lat | ruht bis 23.11. |
| 816 | K | Effekte Szene 1 Dorf am Abend nach LISTE-EFFEKTE (Reihenfolge 623.8): gedämpft, Bilder/s n | startbar |
| 839 | K | Von Homer (817): Erklärtexte der Grundwerte im Reiter Held nach BRS einbauen, Texte STORY- | ruht bis 23.11. |
| 852 | K | Von Homer (432a A, Chef 10.11., 12:05): Aschgeborene bauen: Modell Mensch mit aschgrauer S | ruht bis 23.11. |
| 861 | K | Von Sokrates (Chef 10.11., 13:12, Bild t274.14): Umhang des Kämpfers im Kampf rechts am Rü | wartet auf 431 (in Arbeit) |
| 966.2 | K | Von Sokrates (966 A neu, Chef 11.11., 15:58): Kochen und Alchemie mit Ring wie Knacken (DE | startbar |
| 954a.5 | K | Von Perikles (954a.2): Schleichen auf der Gebietskarte: Schleichtaste, geduckt und langsam | wartet auf 870 (wartet) |
| 954a.7 | K | Von Perikles (954a.2, 954a.3 A): Spähen durch Verweilen: Ring zeigt Heilkräuter abseits de | wartet auf 870 (wartet) |
| 954a.12 | K | Von Perikles (954a.2): Erschaffung: nicht wählbare Fertigkeiten (Bergbau, Angeln, Lederarb | wartet auf 870 (wartet) |
| 954a.9 | K | Von Perikles (954a.2, 954a.3 B): Schmiedelehrling flickt selbst an Borins Amboss mit dem R | wartet auf 870 (wartet) |
| 976 | K | Von Sokrates (Chef 11.11., 16:31): Rezeptbuch für alle Handwerke (Rezeptliste DESIGN-BRS H | wartet auf 966.2 (startbar) |
| 1155 | K | Von Sokrates (623.8 A, Chef 09.11., 22:23; Lücke, Chef 13.11., 15:12 „wann kommt … Teich u | startbar |
| 1157 | K | Von Sokrates (Archivprüfung, 1038 A R1, Chef 12.11., 16:24): Verband herstellen mit dem Re | wartet auf 976 (startbar) |
| 1158 | K | Von Sokrates (Archivprüfung, 558 Probe 4, Chef 04.11., 19:48): Oberflächen für Leder und M | ruht |
| 1167 | K | Von Sokrates (Archivprüfung, 453.1 Chef 01.11.; 453a B 02.11.): Atmen für die Dorftiere (g | startbar |
| 1174 | K | Von Sokrates (Archivprüfung, 348.10 Chef 25.10., 16:36 „brauchen wir auf jeden Fall“; Zwec | wartet auf 431 (in Arbeit) |
| 1205 | K | Von Sokrates (Chef 13.11., 18:48): Wiesen und Blumenfelder mit mehr Pflanzen aus dem Grass | startbar |
| 1211 | K | Von Sokrates (Prüfauftrag Chef 13.11., 19:10): Leuchtfunke mit R7 rocket_trail als Schweif | startbar |
| 1210 | K | Von Sokrates: Regen wie alt (D3.10) fehlt in Godot; Bild ohne Vorgang (R8 Weather FX statt | ruht |
| 1280 | K | Funde und Abgleich alt, Team Tom (1271a A, Chef 15.11., 11:23): 569, 570, 589, 590, 665, 6 | nach dem Meilenstein |
| 1297 | M | Von Sokrates (431, Chef 15.11., 14:32): Schildgröße je Körper, beim Halbling ist der Schil | wartet auf 431 (in Arbeit) |
| 1322 | M | Von Homer (1320, Chef 15.11., 20:15): Spielertexte der Oberfläche ohne TP/HP, Wert heißt L | wartet auf Test (Build 294) |
| 431h | M | Rückfrage zu 431: angelegte Rüstung am Helden sichtbar, Zuordnung Grundform → Kaufteil, et | Chef (Datei in der Chefsache) |
| 1406 | K | Von Spike (1386, Chef 16.11. „Drehen auf der Stelle … ganz Entscheidendes“): Wenden ab 135 | startbar |
| 1417 | M | Von Chef (16.11., 12:37/12:38, Bild Hauptmenü v0.348.506, über Sokrates): Schild des Helde | wartet auf Test (Build 294) |
| 1418 | M | Von Chef (16.11., 12:40, zu t292, über Sokrates): Android-Zurück im Hauptmenü beendet das | wartet auf Test (Build 294) |
| 1420 | M | Von Chef (16.11., 12:44, Test t290, über Sokrates): Fußstaub (814) jetzt zu stark, „sieht | wartet auf Test (Build 294) |
| 1447 | K | Von Sokrates (Chef 16.11., 14:41, Idee, erst denken): Weltleiste links oben unruhig, Wörte | startbar |
| 1448 | K | Von Sokrates (1448 A, Chef 16.11., 14:47): Weltleiste und Heldenmenü ohne Wörter Leben/Man | startbar |
| 1460 | M | Von Sokrates (975a A, Chef 11.11., 17:04, nie gebaut; Fund Jerry 644a.1): Fertigkeit „Lede | wartet auf Test/Build (gebaut) |
| 1480 | M | Von Perikles (1470, Chef 16.11., 17:53: t293.7 mit Testschalter „Schnell“ getestet, falsch | wartet auf Test (Build 294) |
| Pflege | K | von Werkzeug (340.3, 17.11.): 2 „Zu“ zu Erledigtem (1355, 1395), beim Übergeben streichen | startbar |

**Jerry** – offen 79, Muss 26, startbar 34

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1455 | M | Von Werkzeug (1334): Wiederholrot biss_1284: 2× rot in 48 h (Läufe 524, 518); Ursache nach | wartet auf Test (Build 294) |
| 1453 | M | Von Jerry (Build 293 rot, Lauf 524): stehen_973 (Wölfe und Goblins rücken ohne neuen Platz | wartet auf Test (Build 294) |
| 642 | M | Wölfe ineinander beim Anlauf und Biss neben einem ruhenden Wolf, bis 0,15 m (wolf_mess_438 | wartet auf Test (Build 294) |
| 1331 | M | Sammelbuild: alle fertigen Zweige beider Teams, Nummern siehe „Zu 1331“; Prüfliste ansehen | wartet auf Test (Build) |
| 760 | M | Kampf: Wolf springt beim „Anspringen“ nicht, er beißt nur; Text und Bewegung passen nicht | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1453 (wolf) |
| 1068 | M | Von Perikles (1048 A, H, D, Chef 12.11., 20:05): Ring bei jedem großen Schlag der Gegner ( | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1072 |
| 1043 | M | Von Sokrates (Chef 12.11., 15:52, Fund t278.33 Build 280, zu 988): MARS-Probekampf Wölfe, | wartet auf 760 (startbar) |
| 1032 | M | Von Sokrates (Chef 12.11., 14:08, Build 280, MARS-Probekampf Wölfe, Held und Söldner Wachs | wartet auf 760 (startbar) |
| 1072 | M | Laufwege und Plätze im Kampf für alle Figuren: Zweiertausch im Heldenteam, Monster zu eins | wartet auf Test (Build 294) |
| 709.1 | M | Wolf und Grimmzahn beißen den Helden mit Schild sichtbar (aus 709 abgetrennt, Chef 10.11., | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1453 (wolf) |
| 506.2 | M | Grabhund-Biss reicht sichtbar bis zum Helden, nicht nur knapp an den Schild (von Sokrates, | wartet auf 709.1 (wartet) |
| 709 | M | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angre | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1072 |
| 438a | K | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv | ruht bis 23.11. |
| 416.6 | K | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef 31.10., 20:4x; 03.1 | ruht bis 23.11. |
| 406.1 | K | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann | wartet auf 469 (startbar) |
| 510 | K | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt ( | ruht bis 23.11. |
| 509 | K | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot (Chef 03.11., 09:21; Po | ruht bis 23.11. |
| 494 | K | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Woche | ruht bis 23.11. |
| 517 | K | Waldklang wie alt: Vögel am Tag, Eule und Grillen nachts, fernes Wolfsheulen im Tiefen Wal | wartet auf Test/Build (gebaut) |
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
| 1415 | M | Von Jerry (1072 gemessen): Kampftakt Wolfsrudel, Runde 31,8–34,1 s statt 14,6 (784 A); Weg | wartet auf Test t294 (Chef) |
| 1439 | M | Von Sokrates (Chef 16.11., 14:15): Kampfschirm zeigt Mana nur als Text „Mana 40/40“; alt e | wartet auf Test (Build 294) |
| 601.1 | M | Von Sokrates (601, Chef 15.11., 11:02): Pfeil trifft die Fußspitze, der Getroffene zuckt o | wartet auf Test/Build (gebaut) |
| 1488 | M | Von Sokrates (1411b A, Chef 16.11., 20:59): Merkmale je Exemplar bauen (Werte wie Rechnung | wartet auf Test (Build 295) |
| 649.2 | M | Figurenkatalog Schritt 2: Werkzeug figuren.py und tools/figuren/figuren.json (Art und Auft | Sperre 620.1 B: 8 ungetestete Muss, erst gemeinsamer Build und Test; überschneidet sich mit 1453 |
| 649.4 | K | Zwei bis drei Handlungen je gewöhnlicher Monsterart vorschlagen und in 444 messen, nur wo | startbar |
| 644.1 | M | Gegenstandskatalog: Werkzeug mit Spalten, Teil Rezepte und Prüfungen (644 A), zusammen mit | wartet auf 649.2 (wartet) |
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
| 1275 | M | Von Homer (1267): Kerbensystem auf dem Zweig weicht von DESIGN-GLUT.md ab: Taumeln nach Ge | wartet auf Test (Build 295) |
| 1281 | K | Funde und Abgleich alt, Team Jerry (1271a A, Chef 15.11., 11:23): 551, 289, 628, 634, 936, | nach dem Meilenstein |
| 1296 | M | Von Sokrates (Chef 15.11., 14:48, Build 287, Probekampf Wolfsrudel): goldene Eingebung bei | wartet auf Test (Build 294) |
| 1305 | M | Von Sokrates (Chef 15.11., 17:18, Probekampf 3 Wölfe, wohl Build 288): Kämpfer mit Schwert | wartet auf Test (Build 294) |
| 1319 | K | Von Homer (1318): Kampfmeldung MSG532_CURED (mars.gd 430) „von allen Leiden befreit“ / “cu | startbar |
| 508.1 | K | Von Sokrates (508): Simulation 444 mit Übung außerhalb des Kampfes in Kapitel 1; ab welche | startbar |
| 1336 | K | Aus 1141 (Jerry 13.11., 18:55): Robe des Goblin-Schamanen fällt steif, Schattenseite zu du | startbar |
| 1340 | M | Aus 1215 (Jerry 15.11., 13:08): Sterben mit Physik fehlt noch für Skelett und Wiedergänger | startbar |
| 1402 | K | Von Chef (16.11., 10:11, Idee zu 1284a; „als großes Thema … fürs Feintuning und für den Ka | startbar |
| 1404 | K | Von Chef (1291a D, 16.11., 10:37): Machbarkeitsstudie Kampf mit zwei Waffen, ohne Spielcod | startbar |
| 1284b | M | Rückfrage zu 1284 (Jerry): Rattenbiss verdeckt der Held selbst, nicht der Nachbar; Kamera | startbar |
| 1423 | M | Von Sokrates (Chef 16.11., 13:08, zu 1303; schon 15.11., 20:34 zu 1289): Felswände der Höh | startbar |
| 1465 | K | Von Diogenes (1463, Startwarnung 969): LISTE-REGELWERTE.md veraltet seit 15.11., 20:22 (we | startbar |
| 1466 | K | Von Diogenes (1463, Startwarnung 650.2): toter Link in ARBEIT-TEAM-JERRY.md auf chefsache/ | startbar |
| 1478 | K | Von Sokrates (1411 A, Chef 16.11., 19:32): nach jedem Sieg Mana + halber Wille; Wundsegen | startbar |
| 1486 | K | Von Sokrates (1411.1 Tuffy 16.11., 20:32; 1403): bei gleicher Stufe gewinnen Wachsoldat un | startbar |
| 1487 | K | Von Sokrates (1411.1 Tuffy 16.11., 20:32; Fund 644a.1): Heiler wächst in Kapitel 1 nie im | startbar |
| 1501 | M | D283.1 von Diogenes (1485): claude/build-294 (Lauf 537, 22:33) ohne main ab 21:47 gebaut, | startbar |
| Pflege | K | von Werkzeug (340.3, 17.11.): 34495 Bytes (Grenze 30000), Erledigtes streichen; Übergabe ü | startbar |

**Spike** – offen 9, Muss 5, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1270.4 | K | Von Sokrates (1270 A, Chef 15.11., 10:51; 22:43 Film statt Bild), Bau Spike: Vergleichsfil | wartet auf Test t295 (Chef) |
| 474 | K | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, M | ruht bis 23.11. |
| 30 | K | Abstürze beim Testen | ruht bis 23.11. |
| 348.13 | K | Tusche nach Licht wie entschieden (Chef 26.10.) | ruht bis 23.11. |
| 1426 | M | Von Sokrates (Chef 16.11., 13:31 zu t291.3; 14:17 „trägt es Früchte?“): Ladezeit je Ort mi | wartet auf Test (Build 294) |
| 1458 | M | Von Sokrates (870, Plan Schritt 5 „gelöscht“): tote SRD-Reste nur für Tests (regeln/ausdau | wartet auf Test (Build 294) |
| 1482 | M | D280.1 von Diogenes (aus 1385): Namen nach [1473.namen] (claude/spike-1385-pruefung ac454c | wartet auf Test/Build (gebaut) |
| 1483 | M | D280.2 von Diogenes (aus 1445): Spielcode der Anmerkung bei Passt (claude/spike-1445-anmer | wartet auf Test/Build (gebaut) |
| 1484 | M | Von Sokrates (Chef 16.11., 20:20, Tablet SM-X210, Adreno 619, Build 286): Welt und Kampf 9 | Chef (Datei in der Chefsache) |

**Perikles** – offen 27, Muss 21, startbar 4

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1148 | M | Von Ford (13.11., 14:58): lauf.py startet/archiviert Spike 882.1 wiederholt, obwohl dessen | Termin 23.11. |
| 1462 | M | Von Sokrates (Chef 16.11., 16:31 „Haltung 4 schärfen mit Zahl, so machen“): Liegengebliebe | Termin 30.11. |
| 1461 | M | Von Sokrates (340 A, Chef 16.11., 16:27): Rollenspiegel mittwochs nach dem Tagesbericht st | Termin 18.11. |
| 1425 | M | Von Chef (16.11., 13:44): täglich vor dem Tagesbericht den ganzen Vorrat auf links drehen: | Termin 17.11. 10:00 |
| 1398 | M | Von Chef (16.11., 10:01, über Sokrates): Prüfliste mischt wieder Bild/Film mit APK-Wegen; | wartet auf Test/Build (gebaut) |
| 1312 | M | Von Sokrates (Chef 15.11., 19:28): Fertiges nie liegen lassen: Werkzeug mischen (1311), Sp | wartet auf 1504 (startbar) |
| 1246 | M | Von Chef (14.11., 10:28, Fehler): nachts warten alle aufeinander; Pause ohne Datum sperrte | Termin 17.11. 08:00 |
| 870.12 | K | Von Sokrates (870, Umzug BRS): Projektplan 2.3 (212 weg, Pechsträhne als Prozent) und 2.17 | wartet auf 870 (wartet) |
| 464 | M | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählu | wartet auf 1388 (wartet) |
| 341 | K | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug u | Termin 23.11. |
| D75 | M | Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1); meldung.sh --film legte Film 572 nich | Dauerzeile |
| 1100 | K | Von Perikles (zu 1098): Ford-Lauf verbraucht 80–130 Tsd. Token je Stunde; Ausgabe von lauf | wartet auf 1125 (gebaut) |
| 1125 | M | D195.1 von Diogenes (1100.1): Ford-Lauf nach 1100 nicht billiger: Uhrläufe 9 Schritte wie | Termin 23.11. |
| 1173 | M | Von Sokrates (Chef 13.11., 15:40 „Kleinkram bitte selbst erledigen“, A): Regel Kleinkram o | Termin 23.11. |
| 1188 | K | Von Sokrates (1186, Chef 13.11., 16:28): Wächter gegen still veraltete Zeilen: ruhende ode | Termin 23.11. |
| 1244 | M | D236.1 von Diogenes (1133, 1129.1 P2a): Pflegehinweis-Commits sinken nicht (13.11. nach 27 | wartet auf 1389 (gebaut) |
| 1279 | M | Von Perikles (870.10, 870a 7 B): core/, app/, Kotlin-Vorschauordner unter tools/, Gradle-W | startbar |
| 1301 | M | Von Sokrates (Chef 15.11., 16:54 zu 760: „vielleicht kommt ja jemand auch auf die Idee noc | wartet auf Diogenes (greift?) |
| 1387 | M | Von Sokrates (1129.4, Punkt 6 gerissen): Übersicht-Commits 15.11. 193 (14.11.: 37), Ursach | wartet auf Diogenes |
| 1388 | M | D257.1 von Diogenes (464): rote Godot-Läufe 09.–15.11. 93 von 159 (58 %) gegen 52 von 185 | Termin 23.11. |
| 1389 | M | D257.2 von Diogenes (1244): Pflegehinweis-Commits 15.11. 38 (13.11.: 79), Anteil 2,6 % geg | wartet auf Diogenes |
| 1396 | K | Von Ford (Tuffy 16.11., 10:00): lauf.py startet Tuffy auf Zeile 1393, die Jerry schon in s | wartet auf Test/Build (gebaut) |
| 1400 | M | D261.1 von Diogenes: „Geprüft an“ nennt Commits, die es nicht gibt: 1392 c28c2e3d9 (echt 2 | Termin 23.11. |
| 1414 | M | Von Chef (16.11., 12:09, über Sokrates): Warnung bei Vorgangsnummer ohne Wort dazu in Vorl | Termin 23.11. |
| 1441 | M | Von Sokrates (Chef 16.11., 14:24): ständige Freigaben (Repos, Archivieren, Fords Stundenuh | startbar |
| Pflege | K | von Werkzeug (340.3, 17.11.): 1 „Zu“ zu Erledigtem (1427), beim Übergeben streichen (1425) | startbar |
| 1504 | M | D286.1 von Diogenes (1312): Spielcode „gebaut“ ohne Build liegt trotz Auftrag über 12 h: J | startbar |

**Diogenes** – offen 10, Muss 8, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1425 | M | Von Chef (16.11., 13:44): täglich vor dem Tagesbericht den ganzen Vorrat auf links drehen: | Termin 17.11. 10:00 |
| 1246 | M | Von Chef (14.11., 10:28, Fehler): nachts warten alle aufeinander; Pause ohne Datum sperrte | Termin 17.11. 08:00 |
| 1301 | M | Von Sokrates (Chef 15.11., 16:54 zu 760: „vielleicht kommt ja jemand auch auf die Idee noc | startbar |
| 1387 | M | Von Sokrates (1129.4, Punkt 6 gerissen): Übersicht-Commits 15.11. 193 (14.11.: 37), Ursach | Termin 23.11. |
| 1389 | M | D257.2 von Diogenes (1244): Pflegehinweis-Commits 15.11. 38 (13.11.: 79), Anteil 2,6 % geg | Termin 18.11. |
| 186.3 | K | Ausgefüllte Prüfbögen auswerten | ruht bis 23.11. |
| 644.5 | M | Abnahme Gegenstands- und Figurenkatalog: Prüfungen des Werkzeugs grün, Godot liest nur noc | wartet auf 644.1 (wartet) |
| 1128.3 | M | Von Sokrates (1128 A, Chef 13.11., 13:36): ab Build 283 Funde und Rückschritte je Prüfart | Termin 23.11. |
| 1172 | M | Von Sokrates (Kleinkram A, Chef 13.11., 15:40): montags zählen: Kleinkram-Punkte ohne Chef | Termin 23.11. |
| Pflege | K | von Werkzeug (340.3, 17.11.): 3 „Zu“ zu Erledigtem (1472, 1186, 853), beim Übergeben strei | startbar |

**Sokrates** – offen 31, Muss 7, startbar 1

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1503 | M | Zusammenführen: getestet, nicht auf main: Build 293 (6 h); grün machen und PR zusammenführ | wartet auf Test t294 (Chef) |
| 1129 | M | Systemprüfung blinde Flecken mit Perikles: Regeln, Abläufe, Werkzeuge, die schneller, einf | wartet auf 1387 (gebaut) |
| 887 | M | Archivieren und Kaufrepo ohne Nachfrage: Probe Sitzungsmodus statt Auto-Modus (dontAsk von | ruht bis 23.11. |
| 870 | M | Umstellung ganz auf BRS, SRD-Parallelbetrieb beenden: Liste, offene Regelfragen, Bau Tom u | wartet auf 1279 (startbar) |
| 780 | K | Unity-Asset-Store-EULA 2.2.1 (keine Assets als Eingabe für KI-Programme): gilt sie für uns | Termin 23.11. |
| 620 | K | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build | Termin 23.11. |
| 508 | K | Lehrmeister in Kapitel 1 erreichbar (Geselle), Magie-Pflicht Paladin/Kriegsmagier, Wachsol | wartet auf 508.1 (startbar) |
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
| 340 | K | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Che | ruht bis 26.11. |
| 344 | K | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23 | ruht bis 23.11. |
| 644 | K | Alle Gegenstände an einer Stelle: Katalog 458 mit BRS-Werten, Voraussetzungen, Seltenheit, | wartet auf 644.1 (wartet) |
| 649 | M | Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten), Bestiarium ge | wartet auf 649.2 (wartet) |
| 654 | K | Mitdenken vor dem Bauen: Systemfrage je Fund („kommt das wieder?“), Wiederholungswächter, | Termin 23.11. |
| 930 | K | Handgemenge und Abstand im Kampf, Prüfauftrag: Regelseite nach BRS, Rechnung und Film Jerr | wartet auf 930.3 (wartet) |
| 1137 | M | Vollzugsmeldung je Entscheid (Chef 13.11., 14:00/14:03): Folgeaufträge melden Vollzug auf | Termin 17.11. 08:00 |
| 1189 | M | Leichenprüfung der Vorgangsliste alle 48 h (Diogenes?): Erledigtes, Überholtes, Hängendes | Termin 27.11. |
| 1270 | K | Grafik-Engine Godot ausschöpfen: Laden, Sichtweite, Shader vorab, Glühen, Abziehbilder; Vo | wartet auf 1270.4 (zu testen) |
| Pflege | K | von Werkzeug (340.3, 17.11.): Übergabe über 700 Zeichen (nur Getanes und Nachfolger, Stand | startbar |
## Lücken

Vom Werkzeug gefunden (D21.3): steht in der Vorgangsliste, hat hier keine Datei.

Format (Muster: „So geht's“ unten): ansehen/1439-mana-balken.md: kein Absender (Zeile 1 „· <Rolle> ·“ oder Zeile 2); ansehen/1448-leiste-ohne-woerter.md: kein Absender (Zeile 1 „· <Rolle> ·“ oder Zeile 2); ansehen/6011-pfeiltreffer.md: kein Absender (Zeile 1 „· <Rolle> ·“ oder Zeile 2)

Ohne Bild oder Film (450: `meldung.sh --bild/--film` trägt den Link selbst ein; sonst `[Film](bilder:<pfad>)` von Hand): ansehen/6011-pfeiltreffer.md

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
