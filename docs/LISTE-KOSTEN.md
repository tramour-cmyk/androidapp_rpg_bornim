# Kosten je Bereich, Tag und Woche (651)

Erzeugt 08.11., 16:44 mit `python3 tools/kostenbericht.py` (nicht von Hand ändern; neu erzeugen). **Schätzung**, keine Rechnung: API-Preis je Sitzung (`KOSTEN-GEBUCHT.tsv`) zu gleichen Teilen auf ihre Commits verteilt; Bereich aus dem Vorgang (feste Liste `tools/bereiche.py`), Tag aus dem Commit. Weg und Grenzen im Kopf des Werkzeugs.

**Gebucht:** 8.329 $ in 853 Sitzungen · **über Commits zugeordnet:** 8.047 $ (97 %), davon 623 $ an Commits ohne Vorgangsnummer (Bereich nach Rolle) · davon 14 Ford-Sitzungen ohne Commit mit Sitzungszeile, 103 $, nach Startdatum auf „Betrieb“ (685) · **ohne Commit:** 46 Sitzungen, 282 $ (keinem Bereich zuzuordnen) · **Spalte „Kosten“ der Liste:** 8.750 $ in 460 von 1029 Zeilen. Laufende Sitzungen zählen erst, wenn Ford sie beim Neustart bucht: der laufende Tag und die laufende Woche sind zu niedrig.

## Je Bereich und Teilbereich

| Bereich | geschätzt | Anteil | laut Liste |
|---|---|---|---|
| **E Entwicklung** | **5.828 $** | **72 %** | 5.774 $ |
| E Welt (Orte, Dorf, Wald, Höhle, Innenräume, Karten) | 179 $ | 2 % | 233 $ |
| E Figuren (Leute, Held, Monster, Tiere, Bewegungen) | 963 $ | 12 % | 1.027 $ |
| E Kampf (MARS, Regeln, Kampfort) | 1.458 $ | 18 % | 1.498 $ |
| E Klang (Musik, Geräusche) | 70,93 $ | 1 % | 66,88 $ |
| E Oberfläche (Menüs, Fenster, Bedienung, Schrift) | 426 $ | 5 % | 251 $ |
| E Technik (Godot, Umzug, Build, Speichern, Werkzeuge der Teams) | 2.732 $ | 34 % | 2.697 $ |
| **G Gestaltung** | **457 $** | **6 %** | 435 $ |
| G Story (Handlung, Spieltexte, Englisch) | 133 $ | 2 % | 120 $ |
| G Stil (Aussehen, Licht, Farbe, Design) | 228 $ | 3 % | 187 $ |
| G Balance (Werte, Geld, Handel, Spielgefühl) | 95,14 $ | 1 % | 129 $ |
| **Q Qualität** | **109 $** | **1 %** | 101 $ |
| Q QS (Builds, Prüflisten, Rückläufer, Tests) | 47,15 $ | 1 % | 45,39 $ |
| Q QM (Prüfläufe, Kennzahlen, Diogenes) | 61,85 $ | 1 % | 55,89 $ |
| **B Betrieb** | **1.341 $** | **17 %** | 2.334 $ |
| B Steuerung (Ford, Starts, Guthaben, Kosten) | 364 $ | 5 % | 1.031 $ |
| B Abläufe (Regeln, Notizen, Vorrang, Chefsache) | 771 $ | 10 % | 1.044 $ |
| B Werkzeuge (Haken und Skripte unter tools/) | 205 $ | 3 % | 259 $ |
| **M Markt** | **258 $** | **3 %** | 105 $ |
| M Markt (Strategie, Geschäftsmodell) | 187 $ | 2 % | 59,62 $ |
| M Veröffentlichung (Release, Store) | 70,77 $ | 1 % | 45,29 $ |
| ? unbekannt | 54,93 $ | 1 % | 0,00 $ |

## Je Woche (Montag bis Sonntag)

| Woche | E Entwicklung | G Gestaltung | Q Qualität | B Betrieb | M Markt | zusammen | Anteil Spiel (E+G) |
|---|---|---|---|---|---|---|---|
| 02.11.–08.11. | 2.105 $ | 63,24 $ | 19,61 $ | 428 $ | 66,14 $ | **2.692 $** | 81 % |
| 26.10.–01.11. | 2.457 $ | 188 $ | 15,72 $ | 462 $ | 50,55 $ | **3.177 $** | 83 % |
| 19.10.–25.10. | 1.266 $ | 204 $ | 73,10 $ | 449 $ | 140 $ | **2.174 $** | 68 % |
| 12.10.–18.10. | 0,00 $ | 1,14 $ | 0,57 $ | 1,71 $ | 0,57 $ | **4,00 $** | 29 % |

## Je Tag

| Tag | E Entwicklung | G Gestaltung | Q Qualität | B Betrieb | M Markt | zusammen | Anteil Spiel (E+G) |
|---|---|---|---|---|---|---|---|
| So 08.11. | 316 $ | 7,28 $ | 3,35 $ | 62,61 $ | 14,23 $ | **405 $** | 80 % |
| Sa 07.11. | 99,00 $ | 5,66 $ | 6,15 $ | 93,98 $ | 16,24 $ | **221 $** | 47 % |
| Fr 06.11. | 77,97 $ | 0,00 $ | 0,00 $ | 24,94 $ | 0,00 $ | **103 $** | 76 % |
| Do 05.11. | 114 $ | 0,00 $ | 0,00 $ | 33,98 $ | 0,84 $ | **149 $** | 77 % |
| Mi 04.11. | 475 $ | 4,25 $ | 1,31 $ | 54,46 $ | 16,98 $ | **559 $** | 86 % |
| Di 03.11. | 523 $ | 22,16 $ | 0,00 $ | 54,61 $ | 9,65 $ | **612 $** | 89 % |
| Mo 02.11. | 499 $ | 23,88 $ | 8,80 $ | 103 $ | 8,20 $ | **643 $** | 81 % |
| So 01.11. | 510 $ | 72,63 $ | 5,22 $ | 119 $ | 5,32 $ | **715 $** | 81 % |
| Sa 31.10. | 73,80 $ | 36,46 $ | 0,00 $ | 35,17 $ | 0,46 $ | **147 $** | 75 % |
| Do 29.10. | 156 $ | 4,33 $ | 0,00 $ | 19,46 $ | 2,58 $ | **183 $** | 88 % |
| Mi 28.10. | 627 $ | 16,73 $ | 0,00 $ | 52,90 $ | 11,46 $ | **708 $** | 91 % |
| Di 27.10. | 605 $ | 29,86 $ | 2,65 $ | 170 $ | 16,32 $ | **823 $** | 77 % |
| Mo 26.10. | 485 $ | 27,98 $ | 7,85 $ | 65,48 $ | 14,42 $ | **601 $** | 85 % |
| So 25.10. | 495 $ | 11,81 $ | 3,56 $ | 142 $ | 63,58 $ | **716 $** | 71 % |
| Sa 24.10. | 113 $ | 29,88 $ | 8,66 $ | 30,38 $ | 10,12 $ | **195 $** | 73 % |
| Fr 23.10. | 131 $ | 26,91 $ | 16,51 $ | 79,00 $ | 14,53 $ | **299 $** | 53 % |
| Do 22.10. | 134 $ | 55,17 $ | 2,13 $ | 49,98 $ | 5,22 $ | **250 $** | 76 % |
| Mi 21.10. | 155 $ | 10,79 $ | 3,61 $ | 83,39 $ | 24,84 $ | **278 $** | 60 % |
| Di 20.10. | 129 $ | 19,44 $ | 16,39 $ | 22,57 $ | 15,19 $ | **203 $** | 73 % |
| Mo 19.10. | 109 $ | 50,36 $ | 22,25 $ | 42,10 $ | 6,79 $ | **233 $** | 68 % |
| So 18.10. | 0,00 $ | 1,14 $ | 0,57 $ | 1,71 $ | 0,57 $ | **4,00 $** | 29 % |

## Vorgänge ohne Betrag in der Liste, geschätzt (377 Vorgänge, 1.214 $)

| Vorgang | Bereich | geschätzt | Titel |
|---|---|---|---|
| 557a | E Oberfläche | 25,74 $ | Rückfrage: senkrechte Lage auf Fenstern und Schirmen, mittig, oben ode |
| 2 | E Figuren | 20,99 $ | Waffe verstaut (auf der Karte geschultert bzw. am Rücken) |
| 416.6 | E Technik | 20,60 $ | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef |
| 453a | E Kampf | 18,09 $ | Rückfrage: Wolfsatem aus der Kampfkamera sichtbar machen, A/B/C |
| 1 | E Welt | 17,54 $ | Regen, Wetterleuchten mit Donner |
| 493 | E Kampf | 17,43 $ | Kampforte Wald: Waldrand, Teich, Baum, Felsen, Steinkreis (Orte O9; Wo |
| 19 | E Kampf | 15,89 $ | Zeitablauf der Kampfbewegungen (19e Beispiel) |
| 574 | E Technik | 14,76 $ | Laufprotokoll Build 257 (Handy): „Lambda capture … was freed“ dreimal, |
| 455.2 | E Figuren | 13,89 $ | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völk |
| 571 | E Oberfläche | 12,87 $ | Wischen auf Schaltflächen rollt Listen nicht (Testmenü, Erschaffung; C |
| 348.12i | E Technik | 12,10 $ | Kaufmodelle mit `AESContext` verschlüsseln, Bedingung für Kauf Protofa |
| 24 | E Oberfläche | 11,03 $ | Animationen fehlen nach Start/Kartenwechsel; Zwischenbildschirm für Or |
| 549 | E Oberfläche | 10,65 $ | Rastfenster am Feuer wirkt klein, zu viele Kästen; besser als alt gest |
| 268 | E Kampf | 10,27 $ | MARS: Held behält die Fackel in der Hand, obwohl er auf die zweihändig |
| 431c | E Figuren | 10,23 $ | Rückfrage: Völker Runde 4 am Tor angehalten, neue Läufe frei? |
| 503 | E Oberfläche | 10,05 $ | Laden, Verkaufen: Knopf „Gewöhnliche verkaufen“ leer, ohne Text (Chef  |
| 406a | E Kampf | 9,99 $ | Rückfrage: Schlussfilm Schilde am Tor angehalten, neue Läufe frei? |
| 142.4 | M Veröffentlichung | 9,87 $ | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 0 |
| 569 | E Oberfläche | 9,57 $ | Baumkronen ohne erkennbare Tuschelinie, „ein einziger Brei“ (Chef 04.1 |
| 461b | B Abläufe | 9,53 $ | Nur Gültiges steht: neu ersetzt alt im selben Commit, Commit-Prüfung,  |
| 406.1 | E Kampf | 9,07 $ | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff;  |
| 14 | B Werkzeuge | 8,53 $ | Neustart-Haken (Gesprächsgröße, dazu Größenwarnung für die Vorräte) |
| 560 | E Figuren | 8,52 $ | Monster auf der Karte drehen sich zum Helden, wenn sie ihn wahrnehmen, |
| 276 | B Abläufe | 8,47 $ | Fords Anleitung auf eine Seite (Empfehlung Sokrates zu 274) |
| 605 | E Technik | 8,15 $ | Ausrüstung: leeres Kopffeld, Auswahl zeigt falsch „Obergrenze“, kein Z |

Weitere 352 unter 25 Plätzen; ganz ohne Commit und ohne Betrag: 192 Zeilen.

## Abgleich Liste gegen Schätzung (größte Abweichungen)

Liste 8.750 $, gebucht 8.329 $: die Liste bucht eine Sitzung auf die Vorgänge ihres Titels (mehrere zu gleichen Teilen), die Schätzung nach Commits; Beträge aus der Zeit vor `KOSTEN-GEBUCHT.tsv` oder doppelt gebuchte erscheinen nur in der Liste.

| Vorgang | Liste | geschätzt | Liste minus Schätzung |
|---|---|---|---|
| Betrieb | 961 $ | 327 $ | +634 $ |
| 383 | 99,45 $ | 9,67 $ | +89,78 $ |
| D29.3 | 85,12 $ | 0,57 $ | +84,55 $ |
| 452 | 73,54 $ | 2,66 $ | +70,88 $ |
| 438 | 125 $ | 57,79 $ | +66,73 $ |
| 625 | 76,53 $ | 11,02 $ | +65,51 $ |
| 348 | 115 $ | 55,72 $ | +59,42 $ |
| 417 | 214 $ | 157 $ | +57,47 $ |
| 512 | 65,42 $ | 8,62 $ | +56,80 $ |
| 558 | 96,33 $ | 43,57 $ | +52,76 $ |
| 512b | 72,73 $ | 20,09 $ | +52,64 $ |
| 438a | 24,62 $ | 76,57 $ | −51,95 $ |
| 348.6 | 640 $ | 594 $ | +46,25 $ |
| 496a | 51,18 $ | 6,54 $ | +44,64 $ |
| 348.7 | 441 $ | 399 $ | +42,33 $ |

