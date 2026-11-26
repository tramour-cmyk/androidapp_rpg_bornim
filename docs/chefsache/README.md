# Chefsache

Was auf den Chef wartet (63, 108). Diese Übersicht schreibt ein Werkzeug (`tools/zug-index.py`) bei jedem Push; nicht von Hand ändern.

**Letzter Testbuild:** [Build 301 · 0.348.600 (APK)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/45887352754/artifacts/15151448895) · 26.11., 18:00 · zum Testen · Release dagegen nur auf Zuruf

## Wer wofür

- **Sokrates:** Leitung mit dir, bringt deine Worte als Aufträge
- **Büro:** Disponent (Takt, Eingang, Guthaben) und Arbeitsplaner (aus dem Vorgang ein Auftrag)
- **Abnahme:** Prüfer (prüft einen Auftrag) und Tester (testet ein Ganzes)
- **Regeln:** Regelwerk BRS, Werte, Proben, Erschaffung, Zahlen der Balance; mit Umzug BRS
- **Kampf:** Ablauf, Bewegung, Kampforte, Gegnerverhalten, Kampfgefühl
- **Figur:** Held, Leute, Monster
- **Kataloge:** Figuren, Helden, Gegenstände
- **Welt:** Gelände, Licht, Wetter, Stil der Welt
- **Klang:** Klang und Musik
- **Oberfläche:** Bedienung und Oberfläche
- **Story:** Geschichte und Texte
- **Technik:** Technik, Leistung, Build
- **Werkzeug:** Firma: Werkzeuge und Abläufe
- **Build-Macher:** Fachkraft Technik mit Build im Auftrag: Sammelbuild, Prüfliste, Testbitte
## Überblick

Vom Werkzeug gerechnet (`tools/ueberblick.py`, 1313), Vorgangsliste vom 26.11., 22:03, neu bei jeder Änderung. Reihenfolge der Blöcke und ihren Zuschnitt legst du fest; vorziehen: sag es, wir setzen den Rang beim Besitzer. Die Blocknummer bleibt fest („Block 3“), auch wenn die Reihenfolge sich ändert. „In Arbeit“: eine Sitzung hat den Vorgang laut Besetzung (`ARBEIT-BESETZUNG.md`, stündlich).

**Themenblöcke**

| Block | offen | Muss | in Arbeit | zum Testen | ruht | nächster |
|---|---|---|---|---|---|---|
| **Kapitel 1 fertig (Godot, BRS)** | | | | | | |
| ↳ **10** Regeln (Regelwerk BRS, Werte, Proben, Erschaffung, Zahlen der Balance; mit Umzug BRS) | 6 (6) | 0 | 0 | 0 | 4 | 59e (Regeln) Händler: Vorrat je Laden |
| ↳ **2** Kampf (Ablauf, Bewegung, Kampforte, Gegnerverhalten, Kampfgefühl) | 65 (62) | 19 | 0 | 3 | 27 | 2056 (Kampf) Systemlösung? Klinge: 2 frühere Vorgänge, neu 158… |
| ↳ **3** Figuren und Kleidung (Held, Leute, Monster) | 40 (40) | 24 | 1 | 8 | 9 | 2031 (Figur) Kutte/Robe und Haut aus MakeHuman-Paketen als Pro… |
| ↳ **4** Kataloge: alles an einer Stelle (Figuren, Helden, Gegenstände) | 10 (10) | 3 | 0 | 1 | 4 | 644.2 (Kataloge) Gegenstandskatalog: C1 Fertigkeit +1/+2 ab episch… |
| ↳ **5** Welt und Karten (Gelände, Licht, Wetter, Stil der Welt) | 31 (31) | 2 | 0 | 2 | 5 | 1630 (Welt) alle Lichtquellen der Höhle nach Dunkelheit am Or… |
| ↳ **11** Klang und Musik | 6 (6) | 1 | 0 | 0 | 0 | 1753 (Klang) Streicherspur nach 120 bauen, nur bei Jägern |
| ↳ **12** Bedienung und Oberfläche | 6 (6) | 0 | 0 | 0 | 3 | 531a (Oberfläche) Rückfrage: Bewegungspaket „Campfire“ für Garrick… |
| ↳ **13** Geschichte und Texte | 10 (10) | 1 | 0 | 0 | 2 | 2040 (Story) Wörter für Frisur und Bart aus 2029, Vorschlag de… |
| ↳ **6** Technik, Leistung, Build | 24 (24) | 12 | 0 | 2 | 1 | 1270.7 (Technik) nach Messung 1270.6: Texturen komprimiert und Lau… |
| **7** Firma: Werkzeuge und Abläufe | 122 (124) | 85 | 0 | 1 | 23 | 1520 (Werkzeug) An den Läufen sparen |
| **8** Marktstart | 10 (10) | 0 | 0 | 0 | 5 | 142.3 (Arbeitsplaner) Tester öffentlich suchen |

**Erledigt und neu** (Kalendertage bis 24 Uhr; Woche ab Montag, Monat ab dem 1.; in Klammern bei „offen“: Stand 0:00 heute; netto plus = weniger offen)

| | heute | gestern | Woche | Monat (seit 07.11.) |
|---|---|---|---|---|
| erledigt | 14 | 7 | 64 | 1479 |
| neu | 15 | 19 | 82 | 1588 |
| **netto** (erledigt − neu) | **−1** | **−12** | **−18** | **−109** |

Monat erst ab 07.11.: vorher hatte die Vorgangsliste kein Feld Stand, offene Vorgänge sind dort nicht zählbar.

**Je Profil das Nächste** (wie der Disponent startet, 1893)

| Profil | als Nächstes |
|---|---|
| **Chef** | [t301](ansehen/t301-sammelbuild.md) testen, hält 14 Zeilen; dann 1 weitere |
| Arbeitsplaner | 142.3 Tester öffentlich suchen (Kür) |
| Regeln | 59e Händler: Vorrat je Laden (Kür) |
| Kampf | 2056 Systemlösung? Klinge: 2 frühere Vorgänge, neu 1589.4; einma… (Kür) |
| Figur | 2031 Kutte/Robe und Haut aus MakeHuman-Paketen als Probe in der… (Muss); dann 2 weitere |
| Kataloge | 644.2 Gegenstandskatalog: C1 Fertigkeit +1/+2 ab episch ohne Pfli… (Kür) |
| Welt | 1630 alle Lichtquellen der Höhle nach Dunkelheit am Ort statt Uh… (Kür) |
| Klang | 1753 Streicherspur nach 120 bauen, nur bei Jägern (Muss) |
| Oberfläche | 531a Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast k… (Kür) |
| Story | 2040 Wörter für Frisur und Bart aus 2029, Vorschlag de/en an den… (Muss) |
| Technik | 1270.7 nach Messung 1270.6: Texturen komprimiert und Laub ohne Dur… (Muss); dann 3 weitere |
| Werkzeug | 1520 An den Läufen sparen (Muss); dann 19 weitere |
| Prüfer | leer, weil keine offene Zeile |
| Tester | leer, weil keine offene Zeile |

**Die nächsten 20**

| # | Nr. | Wer | Worum | Kl. | Block | Stand |
|---|---|---|---|---|---|---|
| 1 | 2031 | Figur | Kutte/Robe und Haut aus MakeHuman-Paketen als Probe in der Spielkamera, alt geg… | M | 3 Figuren und Kleidung | startbar |
| 2 | 2034 | Figur | Rest der MakeHuman-Pakete: alle Kopfteile, Ausrüstung, Aussehen von Held und NP… | M | 3 Figuren und Kleidung | in Arbeit |
| 3 | 2045 | Figur | Kutte für Klosterschüler einbauen, nach Chef-👍 26.11., 00:06 auf Frage 2031 | M | 3 Figuren und Kleidung | startbar |
| 4 | 1753 | Klang | Streicherspur nach 120 bauen, nur bei Jägern | M | 11 Klang und Musik | startbar |
| 5 | 2040 | Story | Wörter für Frisur und Bart aus 2029, Vorschlag de/en an den Chef | M | 13 Geschichte und Texte | startbar |
| 6 | 1270.7 | Technik | nach Messung 1270.6: Texturen komprimiert und Laub ohne Durchsicht fern, je Ver… | M | 6 Technik, Leistung, Build | startbar |
| 7 | 1484 | Technik | Welt und Kampf 9–10 Bilder/s, Dorf laden 10,6 s kalt | M | 6 Technik, Leistung, Build | startbar |
| 8 | 1955 | Technik | LISTE-CHECK-BUILD-TEST Punkt 3 und 8 nennen noch Spike und „Tom liest Jerrys Li… | M | 6 Technik, Leistung, Build | startbar |
| 9 | 2033 | Technik | Thessa: fast schwarzes Loch in der rechten Faust, Tusche zieht die Faustöffnung… | M | 6 Technik, Leistung, Build | startbar |
| 10 | 1520 | Werkzeug | An den Läufen sparen | M | 7 Firma | startbar |
| 11 | 1933 | Werkzeug | Abgleich aller Rollendateien gegen Kerne, Profile, Sockel: geht jede Rolle halb… | M | 7 Firma | startbar |
| 12 | 1128.3 | Werkzeug | ab Build 283 Funde und Rückschritte je Prüfart zählen, Bautests „ohne dich“ am… | M | 7 Firma | startbar |
| 13 | 1387 | Werkzeug | Übersicht-Commits 15.11. 193, Ursache 1313 | M | 7 Firma | startbar |
| 14 | 1388 | Werkzeug | D257.1 von Diogenes: rote Godot-Läufe 09.–15.11. 93 von 159 gegen 52 von 185 de… | M | 7 Firma | startbar |
| 15 | 1507 | Werkzeug | Satz „Fertiges lautlos … mit 👍/👎-Zeile“ nur in Starts von Tom, Jerry, Spike, Tu… | M | 7 Firma | startbar |
| 16 | 1642 | Werkzeug | Änderung 1 Rollenspiegel: jede Startwarnung mit festem Besitzer im Werkzeug, na… | M | 7 Firma | startbar |
| 17 | 1728 | Werkzeug | Teilprojekte im Projektplan durch Verweis auf chefsache/themenbloecke.md ersetz… | M | 7 Firma | startbar |
| 18 | 1773 | Werkzeug | Nachträge zu 1767 F3: Disponent „Fertig“ ohne Ausnahme 1311, Werkzeugfehler-Sat… | M | 7 Firma | startbar |
| 19 | 1774 | Werkzeug | Werte für Höchstdauer je Auftrag und Laufbremse festlegen | M | 7 Firma | startbar |
| 20 | 1794 | Werkzeug | Profil Disponent :20 und Kern Büro „fertig ohne Commit nimmst du nicht an“: Aus… | M | 7 Firma | startbar |

Danach 178 weitere offen. Bei dir zum Testen (vorgelegt): 17. Gebaut, fährt mit dem nächsten Build: 7. Werkzeug gebaut, Prüfung Diogenes: 25. Ruhend oder nach dem Meilenstein: 83.
## Zu entscheiden

Nichts offen.

## Zu billigen

Nichts offen.

## Anzusehen

**Bilder** (ansehen und im Gespräch „ja“ oder was anders sein soll):

| Nr. | Was | Wer | Seit |
|---|---|---|---|
| [1973](ansehen/1973-zweihaender-waffe-in-der-hand.md) | Zweihänder: trägt der Held die Waffe jetzt in beiden Fäusten? | – | 26.11., 11:28 |

**Builds** (installieren und testen; Folge = Version aufsteigend, Android installiert nur höhere Nummern über niedrigere):

| Folge | Version | Build | Was | Wer | Seit |
|---|---|---|---|---|---|
| 1 | [0.348.600](ansehen/t301-sammelbuild.md) | [Build 301](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/45887352754/artifacts/15151448895) | Sammelbuild: Einmessen, Gang mit Waffe, Leute an der Bank, Wiese in Niedrig, Ansagen je Art, Zielwahl und Flucht, Figuren in der Arena, Kleider, Waffenstaffel | Tom, Jerry und Technik | 26.11., 18:00 |

## Zu tun

Nichts offen.

## Offen je Rolle

Vom Werkzeug gerechnet (`tools/startbar.py --md`, 167.10), Stand 26.11.; „startbar“ heißt: nichts hält die Zeile auf, eine laufende Sitzung kennt das Werkzeug nicht.

**Arbeitsplaner** – offen 10, Muss 0, startbar 5

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 142.3 | K | Tester öffentlich suchen (Chef 27.10., 19:32) | startbar |
| 142.4 | K | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 07.11.) | startbar |
| 253 | K | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf | startbar |
| 366 | K | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | startbar |
| 780 | K | Unity-Asset-Store-EULA 2.2.1 (keine Assets als Eingabe für KI-Programme): gilt sie für uns | startbar |
| 45 | K | Geschäftsmodell und Umsetzung (Play Store) | nach dem Meilenstein |
| 109 | K | Repo öffentlich | nach dem Meilenstein |
| 142 | K | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | nach dem Meilenstein |
| 327 | K | Zweites Spiel: Marktsichtung Denkspiele, Modell ohne Werbung … | nach dem Meilenstein |
| 622 | K | Godot-Build als AAB für Play: dieselbe App de.bornim.game, mit dem Upload-Schlüssel des al | nach dem Meilenstein |

**Regeln** – offen 6, Muss 0, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 48 | K | Zufallsgenerierte Dungeons, auch Questhöhlen | Idee |
| 59e | K | Händler: Vorrat je Laden | startbar |
| 84.4 | K | Lauschen beim Stehen: Welle zur Quelle | Idee |
| 954a.11 | K | Jagd: Tiere geben öfter Fell, Fleisch, Hauer (tabellen.json), Aufträge Thessa und Borin ne | ruht |
| 1486 | K | bei gleicher Stufe gewinnen Wachsoldat und Klosterschüler 100 % in allen 12 Begegnungen bi | wartet auf Sokrates |
| 1487 | K | Heiler wächst in Kapitel 1 nie im Willen (Heilmagie 12/13 am Kapitelende, übt Stumpfe Waff | startbar |

**Kampf** – offen 65, Muss 19, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1589 | M | Motor des Kampfs: Gegnerverhalten nach Regeln … | wartet auf 1589.4 (zu testen) |
| 1627 | M | Trefferbild je Angriff: Kontaktpunkt, Zucken, Treffer/Abwehr/Fehlschlag unterscheidbar, Ke | wartet auf 1589.4 (zu testen) |
| 506.2 | M | Grabhund-Biss reicht sichtbar bis zum Helden, nicht nur knapp an den Schild (von Sokrates, | wartet auf 709.1 (ruht) |
| 709 | M | Kampf: Angriffe treffen den Gegner sichtbar (Waffe am Körper, kein Luftschlag), alle Angre | wartet auf 1589.4 (zu testen) |
| 709.1 | M | Wolf und Grimmzahn beißen den Helden mit Schild sichtbar … | wartet auf 1589.4 (zu testen) |
| 760 | M | Kampf: Wolf springt beim „Anspringen“ nicht, er beißt nur | wartet auf 1589.4 (zu testen) |
| 931 | M | Wolf vorn – „Anspringen!“ steht, während er sich duckt (keine eigene Pause), Sprung bis Bi | wartet auf 760 (ruht) |
| 1032 | M | nach dem eigenen Angriff taumelt ein Wachsoldat getroffen, im Bericht steht ein Angriff, a | wartet auf 760 (ruht) |
| 1043 | M | MARS-Probekampf Wölfe, Klosterschüler, „Ausweichen“ erzwungen: „davon hab ich nix gesehen. | wartet auf 760 (ruht) |
| 1068 | M | Ring bei jedem großen Schlag der Gegner … | wartet auf Test/Build (gebaut) |
| 1415 | M | Kampftakt Wolfsrudel, Runde 31,8–34,1 s statt 14,6 (784 A) | wartet auf 709 (ruht) |
| 1588 | M | Wolf am eigenen Platz dreht nicht zum Ziel, wenn die Drehung tief in den Nachbarn führt … | wartet auf 1589.4 (zu testen) |
| 1589.2 | M | Stufe 1 Gegnerverhalten, Arena unsichtbar: arena.gd, Zielwahl je Denkweise mit Trägheit un | wartet auf 1589.4 (zu testen) |
| 1589.4 | M | Stufe 3 Gegnerverhalten, Figuren in die Arena: figur.gd nur Wege der Arena, Beinarbeit nac | wartet auf Test (Build 301) |
| 1589.5 | M | Stufe 4 Gegnerverhalten, Reihenfolge der Bosse Grimmzahn, Krogg, Grak (Plan) mit Homer, Za | wartet auf 1589.4 (zu testen) |
| 1589.6 | M | Rechnung 444 in die Arena: sim444 rechnet mit arena.gd (Punkt, Umriss, Reichweite) statt n | wartet auf 1589.4 (zu testen) |
| 1603 | M | Besonderheiten fehlen im MARS ohne Kerben: Krogg Prankenhieb, Grimmzahn Umreißen nur in ke | wartet auf Test (Build 301) |
| 1708 | M | Blut beim Biss fliegt bis etwa 1,5 Körperhöhen weg statt an den Zähnen zu bleiben (kampf_u | wartet auf 1589.4 (zu testen) |
| 2046 | M | 1589.4 grün: alte Reihen-Tests (reihe_1305, tausch_1041, stehen_973, biss_1284) und wolf_m | wartet auf 1589.4 (zu testen) |
| 1402 | K | Kamera im Kampf: Spieler dreht frei oder das Spiel wechselt den Blickwinkel | wartet auf 1589.4 (zu testen) |
| 1404 | K | Machbarkeitsstudie Kampf mit zwei Waffen, ohne Spielcode: Bestand Bewegungen UAL2/Protofac | wartet auf 1589.4 (zu testen) |
| 1526 | K | vorderer Wolf weicht nach Angriff eines hinteren ganz nach hinten und läuft als Nächster w | wartet auf 1589.4 (zu testen) |
| 1532 | K | Hinterhalt mit dem Rücken: Held steht abgewandt, dreht sich nach dem ersten Gegnerzug um | wartet auf 1589.4 (zu testen) |
| 1533 | K | Gegner ohne Zahlen: Zustand und Stärke in Worten nach Lesestufe, keine Stufe des Gegners | ruht |
| 1634 | K | Höhle weiß, wie du kommst: entkommt ein Späher oder Kampf laut am Eingang, ist die Höhle g | wartet auf 1589.4 (zu testen) |
| 1639 | K | Festklammern: ab drei Goblins klammert einer den Helden, die anderen treffen leichter, Lös | wartet auf 1589.4 (zu testen) |
| 39 | K | Schwierigkeitsgrad im Menü | wartet auf 1589.4 (zu testen) |
| 52 | K | Feinarbeit an den Kampfanimationen | Idee |
| 344.2 | K | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | wartet auf 1589.4 (zu testen) |
| 385.2 | K | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | wartet auf 1589.4 (zu testen) |
| 406.1 | K | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff | wartet auf 469 (wartet) |
| 438a | K | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv | wartet auf 1589.4 (zu testen) |
| 460 | K | Kamerafahrten im Kampfort: Eröffnung wie Drohnenflug je Blende, Wechsel der Perspektive oh | Idee |
| 469 | K | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | wartet auf 1589.4 (zu testen) |
| 494 | K | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Woche | wartet auf 1589.4 (zu testen) |
| 507 | K | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager (Orte O10; aus 492) | wartet auf 1589.4 (zu testen) |
| 510 | K | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt … | wartet auf 1589.4 (zu testen) |
| 623.9 | K | Aus 623.2 (Jerry): Effekte Szene 3 Höhle einbauen (623.8 A, Chef 09.11., 22:23): Nebel R8, | wartet auf 1589.4 (zu testen) |
| 785.9 | K | MARS-Probekampf im Systemmenü mit Regelseite … | wartet auf 1589.4 (zu testen) |
| 785.13 | K | Eingebung beim ersten Schlag von hinten (SK 571–573) | wartet auf 1589.4 (zu testen) |
| 785.14 | K | Langes Drücken auf eigene Figur oder Gruppenkasten zeigt Waffe, Mana, „halber Zug“ wie alt | wartet auf 1589.4 (zu testen) |
| 785.16 | K | Raster- und Würfelschalter im Kampf über Kämpfe gemerkt (GameViewModel.kt 335–346; kampf_u | wartet auf 1589.4 (zu testen) |
| 785.18 | K | Stufenaufstieg im Endfeld des Kampfes hervorgehoben … | wartet auf 1589.4 (zu testen) |
| 803 | K | Rest 211.14 (Kür, Tuffy): Gegner durch Antippen der Figur als Ziel wählen | Idee |
| 930 | K | Handgemenge und Abstand im Kampf, Prüfauftrag: Regelseite nach BRS, Rechnung und Film Jerr | wartet auf 930.3 (ruht) |
| 930.3 | K | Rechnung (fertig, handgemenge_930.md) und Film zur Regelseite Handgemenge: eine Runde Rude | wartet auf 931 (ruht) |
| 954a.6 | K | Hinterhalt aus dem Schleichen: unbemerkt bis zum Angriff, Kampf beginnt HERO_FIRST mit Rin | wartet auf 954a.5 (startbar) |
| 954a.8 | K | Wurfwaffen: Grundform Wurfmesser (auch für die Elstern, Truhe cave_3, aus 935), als Bündel | ruht |
| 954a.10 | K | Tiere beruhigen vor dem Kampf: Wolf, Wildschwein, Riesenfledermaus | ruht |
| 954a.13 | K | Volksmerkmal Glückskind (Hügelvolk) wirkt nur im alten Kampf klassisch.gd, der entfällt (8 | ruht |
| 999.2 | K | Armbrust als Waffenmodell im Kampf (Ersatzwaffe der Probehelden, light_crossbow) | wartet auf 1589.4 (zu testen) |
| 1165 | K | Prüferbefunde Kampforte in Godot nachprüfen: Baum fast schwarz ohne Moos, Felsen ohne Scha | wartet auf 496 (startbar) |
| 1224 | K | Berührungsprüfung beim Platztausch (Netze beider Figuren von oben) sperrend machen, sobald | wartet auf 1589.4 (zu testen) |
| 1319 | K | Kampfmeldung MSG532_CURED „von allen Leiden befreit“ stimmt nicht (Rausch bleibt) | wartet auf Test (Build 301) |
| 1336 | K | Aus 1141 (Jerry 13.11., 18:55): Robe des Goblin-Schamanen fällt steif, Schattenseite zu du | wartet auf 1589.4 (zu testen) |
| 1509 | K | Systemlösung? Nebel: 6 frühere Vorgänge (502, 505, 1091, 785.7, 1145 …), neu 623.9 | wartet auf 1589.4 (zu testen) |
| 1510 | K | Systemlösung? Teich: 5 frühere Vorgänge (1155, 509, 507, 509a, 493), neu 623.9 | wartet auf 1589.4 (zu testen) |
| 1521 | K | Figurenkatalog Build 3 (Rest aus 649, 649b A; Perikles 17.11.: Muss 649 schließt nach Buil | wartet auf 649.3 (ruht) |
| 1529.1 | K | Ausdauer im Kampf bauen nach DESIGN-GLUT.md 12.5 … | ruht |
| 1536 | K | drei Merkmalsnamen je Tiermerkmal einbauen, im Kampf ein Name je Merkmal, von Kampf zu Kam | wartet auf 1589.4 (zu testen) |
| 1607 | K | Rest von 1266, noch 92 Stellen „glut“ in 34 Dateien unter godot/, dazu DESIGN-GLUT.md, glu | wartet auf 1589.4 (zu testen) |
| 1635 | K | Systemlösung? Bogen: 2 frühere Vorgänge (26.1, 1041), neu 1634 | wartet auf 1589.4 (zu testen) |
| 72c | K | Brainstorming Wunden bis zur Rast (Zeichen, Heilung mit Verband oder Tempel, schwere Wunde | nach dem Meilenstein |
| 2056 | K | Systemlösung? Klinge: 2 frühere Vorgänge (900, 1515), neu 1589.4; einmal grundsätzlich lös | startbar |
| 2057 | K | Systemlösung? Drehung: 4 frühere Vorgänge (1588, 1979, 1998, 245), neu 1589.4; einmal grun | startbar |

**Figur** – offen 40, Muss 24, startbar 14

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 513 | M | Ein Figurenstand für alle Zweige | ruht |
| 1535 | M | Kleidung hängt bei NPCs in der Ruhebewegung an einer Hand | wartet auf Test (Build 301) |
| 1570 | M | Umhang einmal grundsätzlich lösen statt Einzelflicken: 12 frühere Vorgänge (1006, 1052, 10 | ruht bis 28.11. |
| 1619 | M | Held stakst im Film 458.3, sieht nicht nach Gehen aus („vielleicht Tempo“) | wartet auf Test (Build 301) |
| 1621 | M | Zweihandwaffen kürzer: Großaxt 131→110 cm, Kriegshammer 115→100, Zweihänder 128→115 (waffe | wartet auf 1694 (ruht) |
| 1665 | M | Streitkolben in der Haupthand angelegt, am Helden in der Ausrüstung nicht zu sehen (Fackel | wartet auf 458.3 (zu testen) |
| 1674 | M | Bewohner (Kittel, Dorfplatz am Brunnen) hängt rund 2 Minuten an der Bank fest, kommt nicht | wartet auf Test (Build 301) |
| 1676 | M | angelegter Umhang des Helden deckt den rechten Unterarm teils zu, links frei | ruht bis 28.11. |
| 1694 | M | Griff einmal für alle gehaltenen Dinge: fester Griffpunkt in der Faustmitte je Hand, Finge | ruht |
| 1709 | M | Blender-Probe gemeinsam am PC des Chefs, Sonntag 22.11.: ein Modell (Garricks Flanke, 1535 | ruht bis 28.11. |
| 431 | M | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, da | wartet auf Test (Build) |
| 1297 | M | Schildgröße je Körper, beim Halbling ist der Schild so groß wie er | wartet auf 431 (zu testen) |
| 1649 | M | Zweihandwaffe im Stand: keine Haltung (Stehen_axt fehlt), linke Faust reicht nicht an den | wartet auf 1694 (ruht) |
| 1650 | M | Durchstechprüfung: Hosen stechen durch den Stiefelschaft (0,4 m, 90–144 Ecken) bei Borin, | wartet auf 1535 (zu testen) |
| 1655 | M | Durchstechprüfung: Morwen Kapuze schneidet in den Kopf (1,7 m, bis 135 Ecken) | wartet auf Test (Build 301) |
| 1657 | M | Durchstechprüfung: Held Robe M/W Hände durch die Robe (0,9–1,0 m) und 230–285 gezogene Dre | wartet auf 1694 (ruht) |
| 1973 | M | Von Figur (Dana 22.11., 18:49, zu 1570): kein Zweihändermodell in daten/waffen – Gang mit | wartet auf 1694 (ruht) |
| 2024 | M | Krogg schlägt beim Prankenhieb mit der freien Pranke, Morgenstern bleibt in der Hand (schw | Termin 27.11. 17:30 |
| 2028 | M | Rowena: fast schwarze Flecken an beiden Handgelenken, alt wie neu (Fund Prüfer 1654-Ü11, 2 | wartet auf Test (Build 301) |
| 2029 | M | Kopfteile aus MakeHuman-Paketen: Haare, Bärte, Helme je ein Stück als Probe in der Spielka | ruht |
| 2031 | M | Kutte/Robe und Haut aus MakeHuman-Paketen als Probe in der Spielkamera, alt gegen neu (Che | startbar |
| 2032 | M | Rowena: rechte Finger auf dem Gürtel dunkel, gelbe Kleid-Innenseite sichtbar (Rest aus 202 | ruht |
| 2034 | M | Rest der MakeHuman-Pakete: alle Kopfteile, Ausrüstung, Aussehen von Held und NPCs, als zus | startbar |
| 2045 | M | Kutte (MakeHuman donitz_monk_robe_hood) für Klosterschüler einbauen, nach Chef-👍 26.11., 0 | startbar |
| 1632 | K | Gangprüfung im Bautest: Fußgleiten je Bodenkontakt und Schrittzahl gegen Gehtempo, je Waff | wartet auf Test (Build 301) |
| 134 | K | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | aufgeteilt |
| 417.1 | K | Restmängel Tragart nach „417 passt“ (Schildabstand, Rumpfdrehen, Fußrutschen, Kornfeld, St | startbar |
| 455.1 | K | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 1 | startbar |
| 558.1 | K | Prüferrest Robe Probe 5 nachhalten, nicht bauen | startbar |
| 691 | K | Platzwechsel mit Leuten und Tieren: beide gleiten ineinander … | startbar |
| 861 | K | Umhang des Kämpfers im Kampf rechts am Rücken stark gewölbt (Handaxt und Schild, Rückenans | wartet auf 431 (zu testen) |
| 1174 | K | Körperregler in der Erschaffung je Volk in Grenzen: Brust, Bauch, Ober-/Unterarm, Obersche | wartet auf 431 (zu testen) |
| 1613 | K | Waffen episch und höher mit Effekt statt Färbung (Chef 02.11.), Schwarzstahl liest sich fa | startbar |
| 1656 | K | Systemlösung? Kapuze: 2 frühere Vorgänge (475a, 1546), neu 1655 | startbar |
| 1735 | K | Federknochen für losen Stoff (Umhang, Rocksaum, Kapuzenzipfel) mit SpringBoneSimulator3D ( | startbar |
| 1736 | K | Systemlösung? Umhang: 19 frühere Vorgänge (1648, 1569, 1571, 1569.1, 1651 …), neu 1735 | wartet auf 1735 (startbar) |
| 1752 | K | Feld jaeger in werte.json kennungen setzen bei Bugbear, Schreckenswolf, Hobgoblin-Hauptman | startbar |
| 2022 | K | Systemlösung? Griff: 5 frühere Vorgänge (954a.9, 524, 653, 872, 643), neu 1694; einmal gru | startbar |
| 2025 | K | Systemlösung? Axt: 3 frühere Vorgänge (280.2, 348.12j, 1314), neu 1694; einmal grundsätzli | startbar |
| 2037 | K | Systemlösung? Haar: 2 frühere Vorgänge (1423b, 2026), neu 2029; einmal grundsätzlich lösen | startbar |

**Kataloge** – offen 10, Muss 3, startbar 2

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 458.3 | M | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | wartet auf Test (Build 301) |
| 649 | M | Figurenkatalog: alle Figuren an einer Stelle (Monster, Bewohner, Gefährten), Bestiarium ge | wartet auf 649.2 (ruht) |
| 649.2 | M | Figurenkatalog Schritt 2: Werkzeug figuren.py und tools/figuren/figuren.json … | wartet auf 1331 (zu testen) |
| 644 | K | Alle Gegenstände an einer Stelle: Katalog 458 mit BRS-Werten, Voraussetzungen, Seltenheit, | wartet auf 644.1 (wartet) |
| 644.1 | K | Gegenstandskatalog: Werkzeug mit Spalten, Teil Rezepte und Prüfungen (644 A), zusammen mit | wartet auf 649.2 (ruht) |
| 644.2 | K | Gegenstandskatalog: C1 Fertigkeit +1/+2 ab episch ohne Pflicht-Nachteil (Chef 14:32), C2 S | startbar |
| 644.4 | K | Gegenstandskatalog: Ladenbestand und Rezepte aus texte.json und Kotlin in den Katalog umst | wartet auf 644.1 (wartet) |
| 644.5 | K | Abnahme Gegenstands- und Figurenkatalog: Prüfungen des Werkzeugs grün, Godot liest nur noc | wartet auf 644.1 (wartet) |
| 649.3 | K | Figurenkatalog: Bewohner, Händler, Lehrmeister, Söldner füllen … | wartet auf 649.2 (ruht) |
| 649.4 | K | Zwei bis drei Handlungen je gewöhnlicher Monsterart vorschlagen und in 444 messen, nur wo | startbar |

**Welt** – offen 31, Muss 2, startbar 19

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1205b | M | in Grafik Niedrig nur die Blumen des Kits, Kleckse überall weg, Gras in Niedrig unser alte | wartet auf 1535 (zu testen) |
| 1205 | M | Wiesen und Blumenfelder mit mehr Pflanzen aus dem Grass & Wind Kit … | wartet auf 1535 (zu testen) |
| 1519 | K | vier Helden im Hauptmenü mit Ruhebewegung (Atmen, Umsehen), Hände bleiben, wo sie sind | wartet auf 431 (zu testen) |
| 1563 | K | Teich in der Höhle am Ufer noch eckig und kantig | wartet auf 1564 (startbar) |
| 1630 | K | alle Lichtquellen der Höhle (Fackeln, Glut, Funken) nach Dunkelheit am Ort statt Uhrzeit, | startbar |
| 145 | K | Karten je Kapitel zum Drucken | startbar |
| 292.4 | K | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., | startbar |
| 344 | K | Fackel: brennt überall außer in hellen Grundrissen | startbar |
| 508 | K | Lehrmeister in Kapitel 1 erreichbar (Geselle), Magie-Pflicht Paladin/Kriegsmagier, Wachsol | startbar |
| 509 | K | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot … | startbar |
| 515 | K | Truhen: 3–4 je Karte halb versteckt, verschlossene nach BRS (Dietrich, Aufbrechen) (Chef 0 | startbar |
| 688 | K | Frage des Chefs je Karte: wie viel Sammelbares offen und versteckt liegt (alt gegen neu: T | startbar |
| 689 | K | Dorf, Urteil Chef 25.10., 12:11 (aus 348.6, offen geblieben): Büsche über Dachfirsten, Lat | startbar |
| 816 | K | Effekte Szene 1 Dorf am Abend nach LISTE-EFFEKTE (Reihenfolge 623.8): gedämpft, Bilder/s n | startbar |
| 852 | K | Aschgeborene bauen: Modell Mensch mit aschgrauer Strähne und goldenem Iris-Ring (nie leuch | startbar |
| 954a.5 | K | Schleichen auf der Gebietskarte: Schleichtaste, geduckt und langsamer, Jäger bemerken spät | startbar |
| 954a.7 | K | Spähen durch Verweilen: Ring zeigt Heilkräuter abseits der Wiesen, Fallen an Truhen und ha | startbar |
| 954a.9 | K | Schmiedelehrling flickt selbst an Borins Amboss mit dem Ring wie beim Knacken (515), dazu | wartet auf 515 (startbar) |
| 966.2 | K | Kochen und Alchemie mit Ring wie Knacken (DESIGN-BRS 8): Held brät selbst am Lagerfeuer, b | startbar |
| 976 | K | Rezeptbuch für alle Handwerke (Rezeptliste DESIGN-BRS Herstellen, drei Zustände) und Rezep | wartet auf 966.2 (startbar) |
| 1036.1 | K | neue Vorlage Zustände, jeder Zustand des Codes mit allen passenden Effekten aller Kaufpake | startbar |
| 1157 | K | Verband herstellen mit dem Rezeptbuch (Heilkräuter und Leinen, Spinnseide stärker; DESIGN- | wartet auf 976 (startbar) |
| 1158 | K | Oberflächen für Leder und Metall nach 488 (Stoffschicht gilt für Stoff, Leder, Metall nach | ruht |
| 1210 | K | Regen wie alt (D3.10) fehlt in Godot | ruht |
| 1564 | K | Systemlösung? Wasser: 4 frühere Vorgänge (1155, 221, 623.6, 1218), neu 1563 | startbar |
| 1705 | K | Leveldesign Kapitel 1, Bestandsaufnahme: alle Gebietskarten, Anordnung, Übergänge, Grundri | startbar |
| 1745 | K | Ausrichtung von Orten bei drehbarer Sicht (kamera.gd) | startbar |
| 1979 | K | Randlinie am Höhlenwasser außer Sicht (türkis, je Drehung, 270° hellster 58), Rest aus 156 | startbar |
| 1629 | K | epische Beute (höchste Stufe) zeigt beim Fund einmal Glanz und Funken am Fundort, kurz, oh | nach dem Meilenstein |
| 1280 | K | Funde und Abgleich alt, Team Tom (1271a A, Chef 15.11., 11:23): 569, 570, 589, 590, 665, 6 | nach dem Meilenstein |
| 1281 | K | Funde und Abgleich alt, Team Jerry (1271a A, Chef 15.11., 11:23): 551, 289, 628, 634, 936, | nach dem Meilenstein |

**Klang** – offen 6, Muss 1, startbar 5

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1753 | M | Streicherspur nach 120 bauen, nur bei Jägern (1752) | startbar |
| 598 | K | Umweltklang je Ort, Tageszeit, Wind und Wetter, lebendige Welt (Chef 05.11., 19:2x; Abnahm | startbar |
| 681 | K | Trinkgeräusch in drei Varianten beim Met und anderen Getränken (Chef 08.11., 16:16) | startbar |
| 1748 | K | LISTE-KLANG-ALT-NEU nachziehen, Stand 11.11. | startbar |
| 1754 | K | Stufe 1: tools/klang/QUELLEN.md zur Quelle erweitern (Kennung, Art, Grundpegel, Schleife, | startbar |
| 1755 | K | Klangkatalog Stufe 2: Spiel liest nur den Katalog (Figur, Ort nach Tag, Nacht, Wetter, Han | wartet auf 649.3 (ruht) |

**Oberfläche** – offen 6, Muss 0, startbar 3

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1534 | K | Gegnerkunde: Reiter „Gegner“ in der Chronik, füllt sich mit eigener Erfahrung (Angriffe, S | ruht |
| 470.1 | K | Erschaffung: Held auf Antippen bildschirmgroß (Idee Chef 02.11., 18:37) | Idee |
| 476 | K | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | wartet auf 458.3 (zu testen) |
| 531a | K | Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast kaufen? (Chef 04.11., 19:27) | startbar |
| 568 | K | Ernten als Handlung statt Einsaugen | startbar |
| 954a.12 | K | Erschaffung: nicht wählbare Fertigkeiten … | startbar |

**Story** – offen 10, Muss 1, startbar 6

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 2040 | M | Wörter für Frisur und Bart aus 2029 (Elf Mann Haar_MH01, Zwerg Mann Bart_Breit und Bart_Wi | startbar |
| 1628 | K | Kräutersammler-Handlung vor der Blutzahnhöhle, braut aus Kräutern einen Trank für den Boss | startbar |
| 1636 | K | Gnade: schwer verwundeter Goblin allein, verschonen oder töten | startbar |
| 1637 | K | Lyras Fährte zwischen Wald und Höhle (Saum, Gebetsperlen, Schleifspur), wer sie liest, fin | startbar |
| 1638 | K | Leuchtfunke vorschicken: außerhalb des Kampfs werfen als Köder und Sicht voraus, im Kampf | startbar |
| 41.2 | K | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | wartet auf 1235 (ruht) |
| 447.4.1 | K | Bau Lehrmeister, Meisterschaften, Ruf Kapitel 1 (447.4) | wartet auf 508 (startbar) |
| 839 | K | Erklärtexte der Grundwerte im Reiter Held nach BRS einbauen, Texte STORY-MENUE.md [817.…] | startbar |
| 1235 | K | Texte Kapitel 2 bauen (Rest aus 41; Entwurf kapitel2/STORY-K2-ENTWURF.md, Storyplan K2 fer | Chef Gespräch (großes Vorhaben, Sokrates bündelt in der Chefrunde, 1236) |
| 168.1 | K | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | nach dem Meilenstein |

**Technik** – offen 24, Muss 12, startbar 15

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1270.6 | M | Messbuild Technik: Schalter 3D-Auflösung 50 % im Testmenü, Überzeichnungs-Ansicht vorher a | wartet auf Test (Build 301) |
| 1270.7 | M | nach Messung 1270.6: Texturen komprimiert (Nr. 2) und Laub ohne Durchsicht fern (Nr. 3, au | startbar |
| 1331 | M | Sammelbuild: alle fertigen Zweige beider Teams, Nummern siehe „Zu 1331“ | wartet auf Test (Build) |
| 1484 | M | Welt und Kampf 9–10 Bilder/s (A56 gleicher Build 24–25, Kampf 12–18), Dorf laden 10,6 s ka | startbar |
| 1583 | M | rotbuch.py --anlegen legt einen Wiederholer neu an, sobald sein Vorgang erledigt ist, aus | wartet auf Test/Build (gebaut) |
| 1700 | M | Wiederholrot durchstich_1631: 6× rot in 48 h (Läufe 570, 568, 567, 566, 564, 561) | wartet auf Test/Build (gebaut) |
| 1701 | M | alte Notizkopie trat wieder auf (Sokrates 20:29: 60 eigene, 341 fehlende Commits, Stand 03 | wartet auf Test/Build (gebaut) |
| 1702 | M | vier Läufe zu 1655 an einem Tag, zuletzt alte Fassung des Bildskripts am Rechner | wartet auf Test/Build (gebaut) |
| 1719 | M | Buildzweige 24 h 3 grün, 4 rot, 3 abgebrochen (70 min Bauzeit verloren), rot über grün | wartet auf Test/Build (gebaut) |
| 1720 | M | Vordergrund deckt bis zur halben Bildfläche schwarz ab (Baumkronen, Felswand) | wartet auf 1871 (gebaut) |
| 1955 | M | Von Spike (1871): LISTE-CHECK-BUILD-TEST Punkt 3 und 8 nennen noch Spike und „Tom liest Je | startbar |
| 2033 | M | Thessa: fast schwarzes Loch in der rechten Faust, Tusche zieht die Faustöffnung nach (Rest | startbar |
| 26.1 | K | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef | startbar |
| 30 | K | Abstürze beim Testen | startbar |
| 186.3 | K | Ausgefüllte Prüfbögen auswerten | startbar |
| 348.13 | K | Tusche nach Licht wie entschieden (Chef 26.10.) | startbar |
| 416.6 | K | Spuren des Helden, auch bei Regen | startbar |
| 474 | K | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, M | startbar |
| 496 | K | Durchspiel-Build: Kapitel 1 von Anfang bis Ende am Handy (Wochenziel 03.11., 488) | startbar |
| 1270 | K | Grafik-Engine Godot ausschöpfen: Laden, Sichtweite, Shader vorab, Glühen, Abziehbilder | startbar |
| 1270.8 | K | nur wenn die Messung es verlangt: Tusche halbe Auflösung (Nr. 4, Vorlage), halbe Rechengen | startbar |
| 1396 | K | lauf.py startet Tuffy auf Zeile 1393, die Jerry schon in seiner Sitzung baut (Stand „warte | wartet auf Test/Build (gebaut) |
| 1711 | K | Systemlösung? Messung meldet passt, Bild zeigt Fehler: 1694 (Faust, anderer Knoten/Pose), | startbar |
| 1738 | K | Wie spielt eine Sitzung ohne Handy Kapitel 1 durch (Tester der Abnahme)? Godot ohne Bildsc | startbar |

**Werkzeug** – offen 120, Muss 84, startbar 46

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1148 | M | lauf.py startet/archiviert Spike 882.1 wiederholt, obwohl dessen Render-Lauf in der idle S | wartet auf Diogenes (greift?) |
| 1961 | M | Ford heißt Disponent: Werkzeug (lauf.py, kosten.py) auf Titel „Disponent“ umstellen, dann | wartet auf Sokrates |
| 1716 | M | Buildzweig gehört Spike: nur Spike pusht auf claude/build-<n>, Nachträge in den nächsten B | wartet auf Prüfer |
| 1129 | M | Systemprüfung blinde Flecken mit Perikles: Regeln, Abläufe, Werkzeuge, die schneller, einf | wartet auf 1387 (startbar) |
| 1965 | M | WEITER nur für Nachbesserung des eigenen Auftrags, nie an Planer, Prüfer, Tester (Chef 22. | wartet auf Sokrates |
| 2005 | M | lauf.py startet Planer für ruhende Vorgänge (513 am 23.11. 18-mal) | wartet auf Sokrates |
| 2019 | M | Wochenzählung in Betrieb bis Mo 30.11.: Profil anlegen, Wochentermin ohne --sperre anlegen | ruht |
| 1414 | M | Warnung bei Vorgangsnummer ohne Wort dazu in Vorlagen der Chefsache und in meldung.sh … | wartet auf Diogenes (greift?) |
| 1520 | M | An den Läufen sparen | startbar |
| 1572 | M | Ford hing ab 16:04 zwei Stunden (Rebase-Abbruch abgelehnt), keiner startete, kein Telegram | wartet auf 1610 (gebaut) |
| 1715 | M | Laufzahl täglich im Tagesbericht Perikles: Läufe der Build-Zweige grün, rot, abgebrochen m | wartet auf Diogenes (greift?) |
| 1725 | M | Ablauf als Flussdiagramm: wer am Spiel arbeitet, wer Verfahren und Regeln hält … | ruht |
| 1933 | M | Abgleich aller Rollendateien gegen Kerne, Profile, Sockel: geht jede Rolle halbwegs auf, f | startbar |
| 1954 | M | Chefsache-README als kurzes Dashboard: laufende Sitzungen, wer woran, als Nächstes, Quoten | wartet auf Sokrates |
| D75 | M | Filmsperre 511 zählte Film-Pushes 572 nicht (D75.1) | Dauerzeile |
| 464 | M | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählu | wartet auf 1388 (startbar) |
| 1125 | M | D195.1 von Diogenes (1100.1): Ford-Lauf nach 1100 nicht billiger: Uhrläufe 9 Schritte wie | wartet auf Diogenes (greift?) |
| 1128.3 | M | ab Build 283 Funde und Rückschritte je Prüfart zählen, Bautests „ohne dich“ am Lauf bestät | startbar |
| 1172 | M | montags zählen: Kleinkram-Punkte ohne Chef auf main, davon vom Chef zurückgeholt, Rückschr | ruht |
| 1173 | M | Regel Kleinkram ohne Chef auf main … | wartet auf Diogenes (greift?) |
| 1189 | M | Leichenprüfung der Vorgangsliste alle 48 h (Diogenes?): Erledigtes, Überholtes, Hängendes | Termin 27.11. |
| 1387 | M | Übersicht-Commits 15.11. 193 (14.11.: 37), Ursache 1313 | startbar |
| 1388 | M | D257.1 von Diogenes (464): rote Godot-Läufe 09.–15.11. 93 von 159 (58 %) gegen 52 von 185 | startbar |
| 1400 | M | D261.1 von Diogenes: „Geprüft an“ nennt Commits, die es nicht gibt: 1392 c28c2e3d9 (echt 2 | wartet auf Diogenes (greift?) |
| 1462 | M | Liegengebliebenes in derselben Sitzung als Vorgang beim Besitzer, eigenes Hindernis sofort | Termin 30.11. |
| 1506 | M | startbar.py zeigt Kür am Aussehen als startbar, obwohl 488 sie einfriert … | wartet auf Diogenes (greift?) |
| 1507 | M | Satz „Fertiges lautlos … mit 👍/👎-Zeile“ nur in Starts von Tom, Jerry, Spike, Tuffy, nicht | startbar |
| 1537 | M | Neustart-Haken zusätzlich an jeden Werkzeugaufruf (PreToolUse/PostToolUse): ab 200 Tsd. Er | wartet auf Diogenes (greift?) |
| 1610 | M | D305.1 von Diogenes (1572): Hängeralarm kam 15 bis 75 statt 15 Minuten nach dem Hängen … | wartet auf Diogenes (greift?) |
| 1642 | M | Änderung 1 Rollenspiegel: jede Startwarnung mit festem Besitzer im Werkzeug, nach 6 h legt | startbar |
| 1662 | M | lauf.py startete Jerry für Nachfolger 1595 (Schlussbuild 299), obwohl die Zeile seit 1633 | wartet auf Diogenes (greift?) |
| 1728 | M | Teilprojekte im Projektplan durch Verweis auf chefsache/themenbloecke.md ersetzen (eine Qu | startbar |
| 1739 | M | Werkzeuge der Bauliste ab 21.11., 20:00 bauen … | wartet auf Sokrates |
| 1762 | M | Haken D trägt Chefwort aus fremder Sitzung in die Vorgangsdatei (Freigabe, Antwort auf Fra | wartet auf Diogenes (greift?) |
| 1763 | M | lauf.py startet Sokrates bei „steckt fest“, „Frage“, „wirkt nein“ (C) | wartet auf Diogenes (greift?) |
| 1764 | M | Herzschlag und Wache des Disponenten (Ausfall, Nachfolger ohne Vorräte) | wartet auf 1894 (gebaut) |
| 1765 | M | Build-Werkzeug … | wartet auf 1739 (startbar) |
| 1766 | M | Laufbremse und Höchstdauer je Auftrag in lauf.py, auch bei working (prozesspruefung-21-11. | wartet auf 1774 (startbar) |
| 1767 | M | Profile Büro 3.2 (Disponent, Release, Kosten), Routinen Tagesbericht, Wache, Wochenzählung | wartet auf Sokrates |
| 1773 | M | Nachträge zu 1767 F3: Disponent „Fertig“ ohne Ausnahme 1311, Werkzeugfehler-Satz nur Kern | startbar |
| 1774 | M | Werte für Höchstdauer je Auftrag (auch bei working) und Laufbremse (Läufe je Auftrag) fest | startbar |
| 1781 | M | nach der Umstellung trägt jeder Start (Fachkraft, Build-Macher, Tester, auch aus auftrag.p | wartet auf Sokrates |
| 1790 | M | rueckmeldung.py:89 gibt „ja“ des Prüfers bei einem Werkzeug als Testbitte an den Chef weit | wartet auf Diogenes (greift?) |
| 1793 | M | startbar.py:196–198 Feld „nach“ legt den Rundblick nur an, wenn die Wochenzählung am selbe | wartet auf Diogenes (greift?) |
| 1794 | M | Profil Disponent :20 und Kern Büro „fertig ohne Commit nimmst du nicht an“: Ausnahmen fehl | startbar |
| 1858 | M | Testbitte-Schreiber: Testbitte aus dem Build-Auftrag als chefsache/ansehen/t<n>.md und Tel | wartet auf Sokrates |
| 1859 | M | .claude/settings.json: Haken weiter-haken, zug-haken, autoMode-Sätze (ARBEIT-*, Ford archi | wartet auf 1871 (gebaut) |
| 1871 | M | Umschalt-Commit (werkzeuge.md Schritt 8) samt Umzug „Zu <Nr>“ in Vorgangsdateien (aus 1865 | wartet auf Diogenes (greift?) |
| 1894 | M | herzschlag.yml prüft nur bei Push auf docs/ (nachts fast nur von Ford) und per Zeitplan (s | wartet auf 1871 (gebaut) |
| 1937 | M | Probelauf-Haken bleibt | wartet auf 1871 (gebaut) |
| 1851 | M | neustart-haken.py umbauen: Bremse nur Sperre ohne Erinnerungstext, auch Folgeaufträge, Fac | wartet auf Sokrates |
| 1852 | M | Quelle Protokoll ARBEIT-BETRIEB.md ersetzen in startsperre-haken.py, startwarnung.py (auch | wartet auf Sokrates |
| 1853 | M | tagesbericht.py nach routine-tagesbericht.md F3 (:22–28): „Wo stehen wir“ statt „Rest gesc | wartet auf Sokrates |
| 1856 | M | Ende-Haken statt weiter-haken.py: meldet am Ende jeder Fachkraft-, Prüfer-, Arbeitsplaner- | wartet auf Sokrates |
| 1857 | M | zug-index.yml Auslöser docs/ARBEIT-*.md (:18) und „Offen je Rolle“ auf Vorgangsdateien ums | wartet auf Sokrates |
| 1863 | M | werkzeuge.yml Rest: alle tools/*_test.py statt Auswahl, Auslöser auch Unterordner tools/ | wartet auf Sokrates |
| 1864 | M | Build-Auftrag B<n> aus der Warteschlange: Auftrag mit Commit je Vorgang (Einfrieren), Ausl | wartet auf Sokrates |
| 1868 | M | Kennzahlen Wochenzählung: Liegezeit (Median je Übergabe, Fälle über 6 h) aus den Übergabez | wartet auf Sokrates |
| 1956 | M | lauf.py pusht die Startsperre schon ohne --sperre; zweiter Lauf setzt zweite Sperre (Ford | wartet auf Sokrates |
| 1958 | M | Von Chef (20.11., 15:52; Rest aus 1727): Leistungsstufe je Auftrag, nach Ergebnis 1742 Fas | wartet auf 1742 (ruht) |
| 1966 | M | Vorlage KISS im neuen Ablauf: kleiner Werkzeugfehler mit klarem Befund ohne Planer direkt | startbar |
| 1969 | M | Von Tagesbericht (22.11., 17:43): Tabelle je Rolle im Tagesbericht zeigt nach der Umstellu | wartet auf Sokrates |
| 1970 | M | Von Welt (Emil 22.11., 17:43, zu 1566; Sokrates 18:07): tools/godot/bau_am_rechner.py holt | wartet auf Sokrates |
| 1972 | M | Von Chef (22.11., 18:39): Kennzahlen Kosten, Sitzungen, Vorgänge, Aufträge je Stunde, Tag, | wartet auf Sokrates |
| 1974 | M | Von Sokrates (22.11., 18:56): Archiv-Schutz – keine Sitzung archivieren, die auf eine Frei | wartet auf Sokrates |
| 1975 | M | Von Sokrates (22.11., 18:57): Verweis bl → ~/bl aus bau_am_rechner.py (Zeile 5) im Repo; r | wartet auf Sokrates |
| 1982 | M | Telegram-Nachrichten des Chefs ohne Bezug liest keiner (Chef 23.11., 06:47; „1566 B“ 06:40 | wartet auf Sokrates |
| 1983 | M | Prüfer nimmt bis drei Aufträge (Chef 23.11., 07:27 A): Profil Prüfer und Disponent (Muster | startbar |
| 1990 | M | vorgang.py uebergabe nennt als WECKER eine archivierte Sitzung (Besetzung veraltet), Weckr | wartet auf Sokrates |
| 1991 | M | Rufnamen doppelt vergeben: lauf.py --start und Takt geben denselben Rufnamen an Sitzungen | wartet auf Sokrates |
| 1994 | M | tagesbericht.py zählt erledigte Vorgänge nicht: Stand seit 22.11., 16:26 kursiv (*erledigt | wartet auf Sokrates |
| 1995 | M | Kür nach Abhängigen ordnen: nach Eilt, Halt, Muss Kür mit vielen offenen wartenden Vorgäng | wartet auf Sokrates |
| 1996 | M | Weckruf-Sperre: Haken am Zugende prüft, dass jeder WECKER aus vorgang.py als Nachricht ver | wartet auf Sokrates |
| 2003 | M | PermissionDenied-Block in settings.json raus, falls nach der ersten echten Auto-Ablehnung | wartet auf Sokrates |
| 2004 | M | meldung.sh schreibt die Lehrenbuch-Zeile der lauten Wache vor dem Senden und je Text statt | wartet auf Sokrates |
| 2010 | M | Alter Ego (Supervisor): Kosten der Sitzungen; Werkzeug kennt die Rolle nicht (zählt als Fa | startbar |
| 2020 | M | Gebilligtes geht über GitHub nach main: Ablauf führt Zweig nach main bei 👍 des Chefs, Ja d | ruht |
| 2021 | M | Rundblick und Ideenlauf starten nie: rundblick_zeilen verlangt Besitzer Sokrates, neue Lis | ruht |
| 2036 | M | Rufnamen: Fachkräfte weiblich, alle anderen Rollen männlich; Sokrates und Alter Ego bleibe | startbar |
| 2039 | M | Chefsache: nichts zum Angucken; Filme auf Telegram ohne Abstimmschaltfläche (Chef 25.11., | startbar |
| 2043 | M | titel_thema_test rot auf main (Fall Doris → Welt); liegt.py nennt noch Diogenes und Ford | startbar |
| 2054 | M | Werkzeugtests (1775) auf main 7× rot seit 10:18 (12:28, 12:47, 13:07; Lauf 45816794073); U | startbar |
| 1625 | K | feste Startprompts je Rolle statt Startlektüre | startbar |
| 1734 | K | Forschung und Entwicklung bei Sokrates, wöchentlich oder auf Bedarf: wie arbeiten andere … | startbar |
| 102 | K | Dokumente BornWire TCS nachziehen | Idee |
| 111 | K | DESIGN-BLENDE.md kürzen (nach 24.6) | Idee |
| 262 | K | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | startbar |
| 296 | K | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MA | startbar |
| 340 | K | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Che | startbar |
| 341 | K | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug u | startbar |
| 383.2 | K | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | startbar |
| 423.1 | K | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | startbar |
| 620 | K | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build | startbar |
| 654 | K | Mitdenken vor dem Bauen: Systemfrage je Fund („kommt das wieder?“), Wiederholungswächter, | startbar |
| 1100 | K | Ford-Lauf verbraucht 80–130 Tsd. Token je Stunde | wartet auf 1125 (gebaut) |
| 1188 | K | Wächter gegen still veraltete Zeilen: ruhende oder alte Kür ohne Bewegung einmal dem Besit | wartet auf Diogenes (greift?) |
| 1469 | K | chefsache/bilder/415-strahlen-gl.webp und 415-strahlen-mobile.webp über 60 KB seit 04.11. | startbar |
| 1666 | K | bau_am_rechner.py --cache bricht ohne Blender ab, sobald nur Block klassen fehlt (Leute br | startbar |
| 1690 | K | ARBEIT-TEAM-TOM.md: 5 „Zu“ zu Erledigtem (1569, 1569, 1515, 1515, 1515), beim Übergeben st | startbar |
| 1729 | K | docs/LISTE-REGELWERTE.md veraltet | startbar |
| 1741 | K | Block 4 Kataloge Zeilen nachziehen: 649.2 Titel nennt tools/figuren/figuren.json (gilt nic | startbar |
| 1742 | K | notiz.sh gibt beim Start Modell und Aufwand aus | wartet auf Sokrates |
| 1749 | K | Präfix je Katalog für die Wortschlüssel ja oder nein | wartet auf Sokrates |
| 1770 | K | Profil Release als Auftrag schreiben, sobald 622 (Godot-AAB) steht | wartet auf 622 (nach Meilenstein) |
| 1802 | K | ARBEIT-TEAM-JERRY.md: Übergabe über 700 Zeichen (nur Getanes und Nachfolger, Stand gehört | startbar |
| 1870 | K | PreToolUse-Sperre Keystore, Zugangsdaten, Force-Push, Spielcode auf main | wartet auf Sokrates |
| 1939 | K | ARBEIT-TEAM-JERRY.md: 1 „Zu“ zu Erledigtem (1776), beim Übergeben streichen | startbar |
| 1940 | K | ARBEIT-PROJEKT.md: 2 „Zu“ zu Erledigtem (1624, 1605), beim Übergeben streichen | startbar |
| 1977 | K | Von Werkzeug (Startwarnung 650.2, 1642, seit 22.11., 18:32): Inhaltsverzeichnis docs/READM | startbar |
| 1998 | K | Von Werkzeug (Startwarnung 108, 1642, seit 23.11., 06:39): Datei über 60 KB: docs/chefsach | startbar |
| 2014 | K | Sitzungstitel: 8 Themen bleiben ein Wort wegen Zahlenschnitt (aus 1960) | ruht |
| 2016 | K | Von Tagesbericht (24.11., 07:55): tagesbericht.py Zeile 2 zählt erledigt 24 h 0 und abgeno | startbar |
| 2027 | K | Von Werkzeug (Startwarnung Pflege, 1642, seit 24.11., 18:41): startbar.py: UNLESBAR 2018: | startbar |
| 2047 | K | Von Tagesbericht (26.11., 08:58): Spalte Frist der Vorgangsliste zählt in keinem Werkzeug | startbar |
| 2050 | K | commit-pruefung.py findet Kennungen nur hinter „Nachricht“: Eintrag mit „Telegram 4605“ (Z | startbar |
| 2051 | K | Haken-Texte (startsperre-haken.py nacht(), neustart-haken.py Z. 8) richten sich noch an „F | startbar |
| 2053 | K | Zeno-Hinweis 2052: startbar.kuer_ruht prüft weder Laufbremse, Nachtdeckel noch --ohne; Zah | startbar |
| 246.1 | K | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | nach dem Meilenstein |
| 2058 | M | Arbeitsplaner, der noch läuft, nimmt weitere Aufträge, bis zu drei, dann archivieren; 2 Pl | startbar |
| 2059 | M | Erledigte Übergaben ganz ins Archiv, in der Datei nur offene; nächste Kennung aus Datei un | startbar |

**Disponent** – offen 0, Muss 0, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|

**Prüfer** – offen 1, Muss 1, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
| 1716 | M | Buildzweig gehört Spike: nur Spike pusht auf claude/build-<n>, Nachträge in den nächsten B | ruht |

**Tester** – offen 0, Muss 0, startbar 0

| Nr. | Kl. | Was | Stand |
|---|---|---|---|
## Lücken

Vom Werkzeug gefunden (D21.3): steht in der Vorgangsliste, hat hier keine Datei.

Beantwortet, Datei noch da (383.3: der Absender löscht sofort): ansehen/1973-zweihaender-waffe-in-der-hand.md (Antwort 1973, 26.11., 11:29), ansehen/t301-sammelbuild.md (Antwort t301, 26.11., 21:58)

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
