# Kosten je Bereich, Tag und Woche (651)

Erzeugt 08.11., 14:04 mit `python3 tools/kostenbericht.py` (nicht von Hand ändern; neu erzeugen). **Schätzung**, keine Rechnung: API-Preis je Sitzung (`KOSTEN-GEBUCHT.tsv`) zu gleichen Teilen auf ihre Commits verteilt; Bereich aus dem Vorgang (feste Liste `tools/bereiche.py`), Tag aus dem Commit. Weg und Grenzen im Kopf des Werkzeugs.

**Gebucht:** 8.168 $ in 841 Sitzungen · **über Commits zugeordnet:** 7.777 $ (95 %), davon 607 $ an Commits ohne Vorgangsnummer (Bereich nach Rolle) · **ohne Commit:** 61 Sitzungen, 391 $ (keinem Bereich zuzuordnen) · **Spalte „Kosten“ der Liste:** 8.589 $ in 443 von 981 Zeilen. Laufende Sitzungen zählen erst, wenn Ford sie beim Neustart bucht: der laufende Tag und die laufende Woche sind zu niedrig.

## Je Bereich und Teilbereich

| Bereich | geschätzt | Anteil | laut Liste |
|---|---|---|---|
| **E Entwicklung** | **5.716 $** | **74 %** | 5.681 $ |
| E Welt (Orte, Dorf, Wald, Höhle, Innenräume, Karten) | 148 $ | 2 % | 213 $ |
| E Figuren (Leute, Held, Monster, Tiere, Bewegungen) | 945 $ | 12 % | 1.011 $ |
| E Kampf (MARS, Regeln, Kampfort) | 1.424 $ | 18 % | 1.467 $ |
| E Klang (Musik, Geräusche) | 70,93 $ | 1 % | 66,88 $ |
| E Oberfläche (Menüs, Fenster, Bedienung, Schrift) | 395 $ | 5 % | 227 $ |
| E Technik (Godot, Umzug, Build, Speichern, Werkzeuge der Teams) | 2.734 $ | 35 % | 2.697 $ |
| **G Gestaltung** | **449 $** | **6 %** | 425 $ |
| G Story (Handlung, Spieltexte, Englisch) | 132 $ | 2 % | 119 $ |
| G Stil (Aussehen, Licht, Farbe, Design) | 222 $ | 3 % | 186 $ |
| G Balance (Werte, Geld, Handel, Spielgefühl) | 94,43 $ | 1 % | 121 $ |
| **Q Qualität** | **106 $** | **1 %** | 98,04 $ |
| Q QS (Builds, Prüflisten, Rückläufer, Tests) | 47,15 $ | 1 % | 45,39 $ |
| Q QM (Prüfläufe, Kennzahlen, Diogenes) | 58,92 $ | 1 % | 52,65 $ |
| **B Betrieb** | **1.208 $** | **16 %** | 2.280 $ |
| B Steuerung (Ford, Starts, Guthaben, Kosten) | 257 $ | 3 % | 1.020 $ |
| B Abläufe (Regeln, Notizen, Vorrang, Chefsache) | 749 $ | 10 % | 1.001 $ |
| B Werkzeuge (Haken und Skripte unter tools/) | 202 $ | 3 % | 259 $ |
| **M Markt** | **245 $** | **3 %** | 105 $ |
| M Markt (Strategie, Geschäftsmodell) | 175 $ | 2 % | 59,62 $ |
| M Veröffentlichung (Release, Store) | 69,40 $ | 1 % | 45,29 $ |
| ? unbekannt | 52,74 $ | 1 % | 0,00 $ |

## Je Woche (Montag bis Sonntag)

| Woche | E Entwicklung | G Gestaltung | Q Qualität | B Betrieb | M Markt | zusammen | Anteil Spiel (E+G) |
|---|---|---|---|---|---|---|---|
| 02.11.–08.11. | 1.993 $ | 59,83 $ | 16,68 $ | 399 $ | 53,33 $ | **2.531 $** | 81 % |
| 26.10.–01.11. | 2.456 $ | 189 $ | 15,72 $ | 426 $ | 50,55 $ | **3.141 $** | 84 % |
| 19.10.–25.10. | 1.267 $ | 199 $ | 73,10 $ | 382 $ | 140 $ | **2.101 $** | 70 % |
| 12.10.–18.10. | 0,00 $ | 1,14 $ | 0,57 $ | 1,71 $ | 0,57 $ | **4,00 $** | 29 % |

## Je Tag

| Tag | E Entwicklung | G Gestaltung | Q Qualität | B Betrieb | M Markt | zusammen | Anteil Spiel (E+G) |
|---|---|---|---|---|---|---|---|
| So 08.11. | 204 $ | 3,88 $ | 0,42 $ | 34,12 $ | 1,42 $ | **244 $** | 85 % |
| Sa 07.11. | 99,00 $ | 5,66 $ | 6,15 $ | 93,98 $ | 16,24 $ | **221 $** | 47 % |
| Fr 06.11. | 77,97 $ | 0,00 $ | 0,00 $ | 24,94 $ | 0,00 $ | **103 $** | 76 % |
| Do 05.11. | 114 $ | 0,00 $ | 0,00 $ | 33,98 $ | 0,84 $ | **149 $** | 77 % |
| Mi 04.11. | 475 $ | 4,25 $ | 1,31 $ | 54,46 $ | 16,98 $ | **559 $** | 86 % |
| Di 03.11. | 523 $ | 22,16 $ | 0,00 $ | 54,61 $ | 9,65 $ | **612 $** | 89 % |
| Mo 02.11. | 499 $ | 23,88 $ | 8,80 $ | 103 $ | 8,20 $ | **643 $** | 81 % |
| So 01.11. | 510 $ | 72,63 $ | 5,22 $ | 108 $ | 5,32 $ | **704 $** | 83 % |
| Sa 31.10. | 73,80 $ | 36,46 $ | 0,00 $ | 35,17 $ | 0,46 $ | **147 $** | 75 % |
| Do 29.10. | 156 $ | 4,33 $ | 0,00 $ | 19,46 $ | 2,58 $ | **183 $** | 88 % |
| Mi 28.10. | 624 $ | 17,74 $ | 0,00 $ | 52,57 $ | 11,46 $ | **706 $** | 91 % |
| Di 27.10. | 607 $ | 29,93 $ | 2,65 $ | 153 $ | 16,32 $ | **809 $** | 79 % |
| Mo 26.10. | 485 $ | 27,98 $ | 7,85 $ | 57,27 $ | 14,42 $ | **592 $** | 87 % |
| So 25.10. | 496 $ | 11,81 $ | 3,56 $ | 129 $ | 63,58 $ | **705 $** | 72 % |
| Sa 24.10. | 113 $ | 29,88 $ | 8,66 $ | 30,38 $ | 10,12 $ | **195 $** | 73 % |
| Fr 23.10. | 131 $ | 26,91 $ | 16,51 $ | 53,03 $ | 14,53 $ | **273 $** | 58 % |
| Do 22.10. | 134 $ | 49,42 $ | 2,13 $ | 47,02 $ | 5,22 $ | **240 $** | 76 % |
| Mi 21.10. | 155 $ | 10,79 $ | 3,61 $ | 83,39 $ | 24,84 $ | **278 $** | 60 % |
| Di 20.10. | 129 $ | 19,44 $ | 16,39 $ | 17,63 $ | 15,19 $ | **198 $** | 75 % |
| Mo 19.10. | 109 $ | 50,36 $ | 22,25 $ | 20,89 $ | 6,79 $ | **212 $** | 75 % |
| So 18.10. | 0,00 $ | 1,14 $ | 0,57 $ | 1,71 $ | 0,57 $ | **4,00 $** | 29 % |

## Vorgänge ohne Betrag in der Liste, geschätzt (362 Vorgänge, 1.195 $)

| Vorgang | Bereich | geschätzt | Titel |
|---|---|---|---|
| 557a | E Oberfläche | 25,74 $ | Rückfrage: senkrechte Lage auf Fenstern und Schirmen, mittig, oben ode |
| 2 | E Figuren | 20,99 $ | Waffe verstaut (auf der Karte geschultert bzw. am Rücken) |
| 416.6 | E Technik | 20,60 $ | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef |
| 630 | E Oberfläche | 20,31 $ | Restliche Schirme im Stil „ohne Kasten“ (549a): Laden-Fenster und Rück |
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
| 569 | E Oberfläche | 9,57 $ | Baumkronen ohne erkennbare Tuschelinie, „ein einziger Brei“ (Chef 04.1 |
| 461b | B Abläufe | 9,53 $ | Nur Gültiges steht: neu ersetzt alt im selben Commit, Commit-Prüfung,  |
| 406.1 | E Kampf | 9,07 $ | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff;  |
| 560 | E Figuren | 8,52 $ | Monster auf der Karte drehen sich zum Helden, wenn sie ihn wahrnehmen, |
| 142.4 | M Veröffentlichung | 8,50 $ | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 0 |
| 276 | B Abläufe | 8,47 $ | Fords Anleitung auf eine Seite (Empfehlung Sokrates zu 274) |
| 522 | E Oberfläche | 8,01 $ | Build 249: Ausrüstung im Testmenü geändert (Schild gegeben), Held im S |

Weitere 337 unter 25 Plätzen; ganz ohne Commit und ohne Betrag: 176 Zeilen.

## Abgleich Liste gegen Schätzung (größte Abweichungen)

Liste 8.589 $, gebucht 8.168 $: die Liste bucht eine Sitzung auf die Vorgänge ihres Titels (mehrere zu gleichen Teilen), die Schätzung nach Commits; Beträge aus der Zeit vor `KOSTEN-GEBUCHT.tsv` oder doppelt gebuchte erscheinen nur in der Liste.

| Vorgang | Liste | geschätzt | Liste minus Schätzung |
|---|---|---|---|
| Betrieb | 961 $ | 225 $ | +737 $ |
| 383 | 99,45 $ | 9,67 $ | +89,78 $ |
| D29.3 | 85,12 $ | 0,57 $ | +84,55 $ |
| 452 | 73,54 $ | 2,66 $ | +70,88 $ |
| 438 | 125 $ | 56,30 $ | +68,22 $ |
| 625 | 76,53 $ | 11,02 $ | +65,51 $ |
| 348 | 115 $ | 55,72 $ | +59,42 $ |
| 417 | 214 $ | 157 $ | +57,47 $ |
| 512 | 65,42 $ | 8,62 $ | +56,80 $ |
| 558 | 96,33 $ | 43,57 $ | +52,76 $ |
| 512b | 72,73 $ | 20,09 $ | +52,64 $ |
| 438a | 24,62 $ | 76,57 $ | −51,95 $ |
| 348.6 | 640 $ | 595 $ | +45,83 $ |
| 496a | 51,18 $ | 6,54 $ | +44,64 $ |
| 348.7 | 441 $ | 399 $ | +42,10 $ |

