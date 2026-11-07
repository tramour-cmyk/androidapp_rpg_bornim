# Vorgänge

Eine Zeile je Vorgang (113), für den Überblick und die Kosten. **Wird beim Start nicht gelesen**; eine Nummer gezielt suchen mit `python3 tools/vorgang.py <Nr>` (alle Orte, 275). Wer einen Vorgang anlegt, nimmt `python3 tools/vorgang.py neu "Titel" "Bereich" KLASSE "Besitzer"` (zieht die nächste freie Nummer aus [Betrieb](ARBEIT-BETRIEB.md) und zählt hoch; Unternummer mit `--nr 72s.1`); wer ihn abschließt, setzt den Stand mit `vorgang.py stand|fertig`. Von Hand geändert warnt die Commit-Prüfung (275 Stufe 2). Stand nur aus der Wortliste (275; prüft `regelcheck.py`): offen, startbar, in Arbeit, wartet, Chef, ruht, gebaut, zu testen, Dauer, nach Meilenstein, aufgeteilt, Idee, erledigt; Einzelheiten im Vorrat. Unterpunkte (z. B. 13q.4) gehören zum Vorgang ihrer Nummer.

- **Bereich** (124): Hauptthema **E** Entwicklung (Welt, Figuren, Kampf, Klang, Oberfläche), **G** Gestaltung (Story, Stil, Balance), **Q** Qualität (QS, QM), **B** Betrieb (Steuerung, Abläufe, Werkzeuge), **M** Markt (Beratung, Veröffentlichung); Tabelle in `FIRMA.md`.
- **Kl.** (126): **M** Muss (im Wochenziel oder „jetzt“ des Chefs), **K** Kür, „–“ abgeschlossen. Stand der Zuordnung: 16.10., erstes Wochenziel 18.–24.10. (`PROJEKTPLAN.md`).
- **Kosten** in $ (`usage.cost_usd`, Summe ab 17.10.): trägt Ford bzw. Ford 2 beim Neustart ein (`LISTE-BETRIEB.md`); „fehlt“, wenn die Zahl nicht zu bekommen war.

| Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |
|---|---|---|---|---|---|---|
| Betrieb | Läufe von Ford und Ford 2 | B Steuerung | – | Ford 37,38 $, Perikles Vorratsdurchsicht 1,90 $; Sokrates 18.10. 5,60 $; Ford 2 16,79 $; Probe Pro Mittel 17.10. 0,00 $; +829,12 $ | Ford | laufend |
| 19 | Zeitablauf der Kampfbewegungen (19e Beispiel) | E Kampf | K |  | Jerry | erledigt |
| 24 | Animationen fehlen nach Start/Kartenwechsel; Zwischenbildschirm für Orte und Kämpfe | E Oberfläche | K |  | Jerry (Inhalt; Technik Tom erledigt) | ruht |
| 26.1 | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef 24.10., 16:56) | Q QS | M | – | Sokrates | ruht |
| 30 | Abstürze beim Testen | Q QS | K |  | Tom (Jerry: Klang-Fäden) | ruht |
| 38 | Balance-Langzeitplan (`DESIGN-BALANCE.md`) | G Balance | M | 11,51 $ | Jerry | wartet |
| 39 | Schwierigkeitsgrad im Menü | E Kampf | M | 3,80 $ | Jerry (Menü mit Tom) | ruht |
| 41 | Storyplan je Kapitel, Plot Kapitel 2 | G Story | K | 4,27 $ | Homer mit Chef | nach Meilenstein |
| 41.2 | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | G Story | K |  | Homer | Chef |
| 45 | Geschäftsmodell und Umsetzung (Play Store) | M Veröffentlichung | M | 4,68 $ | Sokrates mit Nutzer | startbar |
| 48 | Zufallsgenerierte Dungeons, auch Questhöhlen | G Balance | K |  | Ideenspeicher | später |
| 49 | Lehrer für Waffen-, Rüstungs- und Rettungswurf-Übung | G Balance | K |  | Ideenspeicher | später |
| 50 | Weitere Klassen, ggf. zum Kauf | G Balance | K |  | Ideenspeicher | später |
| 52 | Feinarbeit an den Kampfanimationen | E Kampf | K |  | Ideen | Idee |
| 70 | Zwischensequenzen einheitlich, Bildsprache | G Stil | K | 2,30 $ | Ideen | ruht |
| 72 | Profil und Marktvergleich | E Kampf | K | 0,72; +0,61 $ | Homer, Jerry | Chef |
| 79 | Kampfhintergründe wie Diagonalwelt | E Kampf | K |  | Ideen | Idee |
| 84.4 | Lauschen beim Stehen: Welle zur Quelle | G Balance | K |  | Ideenspeicher | später |
| 99 | Zwei Niederlassungen | B Steuerung | K | 7,25 $ | Perikles | ruht |
| 102 | Dokumente BornWire TCS nachziehen | B Abläufe | K |  | Ideen | Idee |
| 109 | Repo öffentlich | M Veröffentlichung | M |  | Sokrates | startbar |
| 111 | `DESIGN-BLENDE.md` kürzen (nach 24.6) | B Abläufe | K |  | Ideen | Idee |
| 133 | Wahlen im Spiel: vier Charisma-Wahlen in Kapitel 2 (Chef 19.10. ja) | G Story | K | 1,12 $ | Tom, Jerry | erledigt |
| 134 | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | E Figuren | K | 1,06 $ | Tom | aufgeteilt |
| 142 | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | M Veröffentlichung | M | 13,47 $ | Sokrates | startbar |
| 142.3 | Tester öffentlich suchen (Chef 27.10., 19:32) | M Veröffentlichung | M | – | Sokrates | ruht |
| 142.4 | Rückfrage: D-U-N-S jetzt, Organisationskonto statt Pflichttest (Chef 07.11.) | M Veröffentlichung | M | – | Sokrates | Chef |
| Woche | Wochenzählung der Kennzahlen | Q QM | K |  | Diogenes | offen |
| 145 | Karten je Kapitel zum Drucken | E Welt | K | 6,22 $ | Tom | ruht |
| 167.6 | Morgenbericht mit Kennzahlen und Kostenbilanz (Chef 18.10.) | B Steuerung | M | 2,29 $ | Sokrates | startbar |
| 168.1 | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | G Story | K |  | Jerry | nach Meilenstein |
| 72u.1 | Umsetzung 72u: Kampfort aus der Karte (Standbild 2, Bau) | E Kampf | K | 2,38 $ | Jerry | ruht |
| 186.3 | Ausgefüllte Prüfbögen auswerten | Q Qualität | K |  | Diogenes | wartet |
| 212 | Kampfsystem wählbar: MARS oder klassisch, Schalter in den Einstellungen (Chef 19.10. A) | G Balance | M | 0,61 $ | Jerry | erledigt |
| 211.14 | Rest 211.13: Leistung A56, Puppen-Gegner im Kamerawinkel, Winkel je Platz, Wechsel als Gang | E Kampf | M? | – | Jerry | startbar |
| 246 | Dokumente grundsätzlich ins Repo statt als Artefakt; Wochenplan aktualisiert (Chef 20.10.) | Q Ablauf | K | –; +7,03 $ | Sokrates | entschieden |
| 246.1 | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | Q Ablauf | K | – | Sokrates | offen |
| 249 | MARS wie der klassische Kampf: Gleiten, Hiebe, Zoom, Blut, Effekte, Zustände (Chef 20.10.) | E Kampf | M | –; +33,41 $ | Jerry | erledigt |
| 253 | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf (Chef 20.10.) | M Markt | K | – | Sokrates | ruht |
| 257 | Build 46: Meldung „App reagiert nicht“, warten oder schließen, läuft dann weiter (Chef 20.10.) | E Technik | M | – | Jerry | offen |
| 262 | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | B Betrieb | K | – | Sokrates | ruht |
| 263 | Rolle für Finanzen und Geschäftszimmer? (Chef 20.10.) | B Betrieb | K | – | Sokrates | Dauer |
| 365 | Aufwand „Hoch“ statt „Mittel“ für einzelne Rollen? (Chef 25.10., 12:36) | B Betrieb | M | –; +4,65 $ | Sokrates | startbar |
| 264 | Arbeitsorte neben GitHub: NAS, Proxmox, ALL-INKL? (Chef 20.10.) | B Betrieb | K | – | Sokrates | Chef |
| 267 | Spiel ruckelt auf dem Tablet (Chef 20.10., Build 48) | E Technik | M | –; +13,77 $ | Tom | ruht |
| 270 | Perikles und Diogenes auf das große Modell (Chef 21.10.) | B Betrieb | M | –; +4,16 $ | Perikles | ruht |
| 275 | Zentrale Vorgangsliste als einzige Quelle (Chef 21.10.; Stufe 1 jetzt, 27.10.) | B Werkzeuge | M | 31,69 $ | Perikles | gebaut |
| 276 | Fords Anleitung auf eine Seite (Empfehlung Sokrates zu 274) | B Abläufe | K | – | Perikles | offen |
| 283.1 | Hohes Gras sichtbar höher als ein Feldweg, stimmige Welt (Chef 21.10.) | G Stil | K | – | Ideenspeicher | offen |
| 284 | Bis zum Durchspielen (26) am Kampf nur Fehlerbehebung, kein Feinschliff (Vorschlag Sokrates) | B Vorrang | M | – | Sokrates | entschieden |
| 289 | MARS: Wechsel „halber Zug“ missverständlich; Bewegung und Aktion im Kästchen zeigen? (Chef 21.10., 20:11) | E Kampf | K | – | Jerry | ruht |
| 292.2 | Hauptmenü: vier Figuren größer, schärfer, mit gelegentlicher Bewegung je Klasse (Chef 21.10., 22:28); Stufe 1 mit 292, Bewegung nach 284 | E Oberfläche | M | – | Team Tom | erledigt |
| 292.4 | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., 15:10) | G Stil | K | – | Team Tom | ruht |
| 296 | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MARS fehlt (Chef 22.10., 07:50) | B Abläufe | M | –; +2,98 $ | Sokrates | Vorlage |
| 296.1 | Erste Fassung Checkliste MARS (`LISTE-MARS.md`) gegen den Code prüfen und pflegen | E Kampf | K | – | Team Jerry | startbar |
| 296.2 | MARS spielnötig: Beute/Erfahrung, Fliehen, Eröffnung, Zustände, eigene Ausrüstung, Schalter (Chef 23.10., 18:25) | E Kampf | M | 14,29 $ | Team Jerry | wartet |
| 296.3 | MARS-Schmuck: Todesschrei, Flucht/Zerfall, Zustände gezeichnet, Siegerpose (Chef 23.10., 18:25) | E Kampf | K | – | Team Jerry | startbar |
| 302 | Bildsignatur: ist unsere Grafik wiedererkennbar, wie wird sie es? (Chef 22.10., 12:12); ja 14:15, Probe in 292.3; Bestand 20:25: Figuren zuerst, Umriss schätzt Tom (302.1) | G Stil | K | –; +3,98 $ | Homer | wartet |
| 302.1 | Tuschelinie für Menschengestalten (Chef 22.10., 20:25, über Sokrates); jetzt nicht (Chef 23:37); M seit 338 (b), Charaktererstellung | G Stil | M | – | Team Tom | ruht |
| 302.2 | Tusche auf der Gebietskarte (Chef 22.10., 23:50); zurückgestellt (Chef 23.10., 10:45) | G Stil | K | – | Team Tom | ruht |
| 302.3 | Intro und Outro mit Tusche im Zeichner, etwas kräftiger als Intro 4 (Chef 23.10., 10:45) | G Stil | M | –; +6,40 $ | Team Tom | ruht |
| 327 | Zweites Spiel: Marktsichtung Denkspiele, Modell ohne Werbung (Chef 23.10., 00:08; vertraulich, Dokument außerhalb des Repos) | F Firma | K | –; +1,26 $ | Sokrates | wartet |
| 318 | Knappheit per Einstellung: Antwortstil „Knapp“ und Startanhang (Chef 22.10., 21:34) | B Abläufe | M | –; +45,66 $ | Sokrates | startbar |
| 340 | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Chef 23.10., 09:34) | B Abläufe | M | –; +3,54 $ | Sokrates | entschieden |
| 340.2 | Rollenspiegel C: `tools/rollenspiegel.sh`, eigene Antwort ohne fremde | B Abläufe | M | –; +6,35 $ | Sokrates | wartet |
| 376.1 | Probeblatt Quaternius-Figuren mit Bewegungsraster als Film (Chef kaufte 27.10., 12:20) | E Figuren | M | 221,15 $ | Team Tom | ruht |
| 374 | Wer prüft regelmäßig, dass alle 373 einhalten? (Chef 27.10., 11:54) | B Abläufe | M | 17,69 $ | Perikles, Diogenes, Sokrates | startbar |
| 372 | Feinschliff Held am Ende des Umzugs: Kettenhemd, Helm, Kragen (aus 338a B, Chef 27.10., 09:36) | E Figuren | M | – | Team Tom | ruht |
| 341 | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug und Diogenes (Chef 23.10., 09:39) | B Abläufe | M | – | Perikles | ruht |
| 304 | Klassischer Kampf: Konter nach Abwehr, obwohl getroffen, regeltechnisch richtig? (Chef 22.10., 13:22) | E Kampf | M | – | Team Jerry | wartet |
| 344 | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23.10., 16:05) | E Welt | M | – | Sokrates | entschieden |
| 347 | Paket „Regeltreue erhöhen, Kosten senken“ (Zähler, Kernregeln, kleiner Start) prüfen und umsetzen (Chef 24.10., 16:20) | B Abläufe | M | –; +15,42 $ | Sokrates | startbar |
| 347.2 | Umsetzung Plan 347 nach Gegenprüfung (Chef 24.10., 16:30) | B Abläufe | M | – | Perikles | wartet |
| 348 | Fertige Spiel-Engine statt Selbstbau: Umzug nach Godot (Chef 24.10., 16:43) | E Technik | M | –; +115,14 $ | Sokrates | in Arbeit |
| 348.1 | Vergleichsbild Gebietskarte alt/neu, 64 (heute) und 128 je Kachel (Chef 24.10., 16:51, „jetzt“ 16:54) | E Technik | M | – | Team Tom | raus |
| 348.2 | Tusche nach Licht auch am Helden, Innenlinien an Bäumen: zweites Vergleichsbild jetzt (Chef 24.10., 17:30, 17:36) | E Technik | M | – | Team Tom | ruht |
| 348.7a | Rückfrage: Geschosse flach oder in 3D | E Technik | M | 58,17 $ | Jerry | in Arbeit |
| 348.9 | Umzug Godot: Arbeitsteilung, Meilenstein, Modelle jetzt (Chef 25.10., 12:24) | B Abläufe | M | 119,56 $ | Perikles, Diogenes | ruht |
| 348.12c | Modellpaket auch gegen Geld (Quaternius QAL, Dungeon Monsters Kit, andere), Vorschlag mit Preisen (Chef 26.10., 11:59) | G Geld | M | 52,94 $ | Sokrates | wartet |
| 348.12g | Gekaufte Monster (Ghul, Untote) zur Geschichte passend? | G Story | M | 4,29 $ | Homer | entschieden |
| 348.13 | Tusche nach Licht wie entschieden (Chef 26.10.) | E Technik | M | 89,13 $ | Tom | ruht |
| 348.13b | Tusche auch nach Fackeln, Feuer, Fenster; zuerst Dorf (Chef 28.10., 08:09 ja) | G Aussehen | M | – | Tom | ruht |
| 356.2 | Sammelaufträge: Felle 3, Pelzumhang, Hauerdolch (356 b, Chef 24.10., 21:33) | G Balance | K | – | Team Tom | startbar |
| 344.2 | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | E Kampf | K | – | Team Jerry | ruht |
| 366 | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | M Markt | M | –; +25,65 $ | Sokrates | offen |
| 391 | Zweit-Repo dauerhaft in den Sitzungen, ohne Ablehnung (Chef 28.10., 09:21) | B Werkzeuge | M | – | Sokrates | ruht |
| 397 | Ruhebewegungen wie im alten Spiel, mindestens drei je Figur, für alle (Chef 28.10., 11:15) | E Figuren | M | 19,54 $ | Team Tom, Team Jerry | ruht |
| 398 | Gegenprobe: Grundsätze aus DESIGN-Dateien, die im Umzug nach Godot fehlen (Chef 28.10., 11:22) | B Umzug | M | 12,07 $ | Sokrates | wartet |
| 399 | Spielbare Godot-Fassung zuerst: Dorf begehbar, Kampf spielbar; Feintuning ruht (Chef 28.10., 12:34) | B Umzug | M | 12,45 $ | Perikles, Team Tom, Team Jerry | wartet |
| 399.2d | Godot am Rechner freigeben (Auto-Modus lehnte Download ab), Tests ohne CI-Lauf (aus 399.2) | E Kampf | M | – | Team Jerry | wartet |
| 399.3.1 | Klang: Haken in spiel.gd übernehmen, Klangregler im Menü System (aus 399.3) | B Umzug | M | – | Team Tom | wartet |
| 385 | Protofactor-Animsets (Zauberer u. a.) auf die Listen, Probe ob nutzbar (Chef 27.10., 20:59) | E Figuren | M | 40,87 $ | Team Tom | ruht |
| 385.2 | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | E Kampf | M | 9,99 $ | Team Jerry | wartet |
| 387 | Gekaufte Tiere schnell auf Bewegungen und unsere Haut prüfen, vor Eigenbau (Chef 27.10., 21:27) | E Monster | M | 98,99 $ | Team Jerry | ruht |
| 469 | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | E Kampf | M | – | Team Jerry | wartet |
| 467 | Ausdauer nach BRS statt SRD (ausdauer.gd: Konstitution, Stärke 13), Formel aus 427 (Chef 01.11., 21:52) | E Kampf | M | – | Team Jerry | wartet |
| 470 | Bau BRS 1.1 Erschaffung (Wochenziel 02.11., Stufe 1) | E Regeln | M | 43,23 $ | Team Tom | ruht |
| 470.1 | Erschaffung: Held auf Antippen bildschirmgroß (Idee Chef 02.11., 18:37) | E Oberfläche | K | – | Team Tom | ruht |
| 478 | Rechenkern des Kampfs in Stufe 1 auf BRS (470a C, Chef 02.11., 17:59) | E Kampf | M | – | Team Jerry | startbar |
| 481 | Herkünfte ausgleichen: Kräutersammler mit Kampftränken, Wachsoldat, Klosterschüler, Bewährungsprobe (Chef 02.11., 18:54, aus 427) | E Kampf | M | – | Sokrates | startbar |
| 483 | Film-Links: jsDelivr liefert aus Zweig „bilder“ nichts mehr (über 50 MB), je Film eine Marke (Chef 02.11., 19:08) | B Werkzeuge | M | – | Sokrates | startbar |
| 485 | Diogenes bessert sich aus dem Rollenspiegel 02.11.: Wochentermine zählen, Vergleichsblätter selbst holen, Meldungen ohne Abkürzungen (Chef 02.11., 19:37 „1, 2, 3 ja“) | Q QS | M | – | Diogenes | ruht |
| 492 | Blutzahnhöhle begehbar mit Krogg, Grak, Lyra (Orte O8; Wochenziel 03.11., 488; von Jerry an Tom, Chef 07:54) | B Umzug | M | 29,10 $ | Team Tom | startbar |
| 494 | Gegner von Kapitel 1 im Kampf außer den Untoten (506), je Gegner höchstens ein Lauf (Wochenziel 03.11., 488) | E Kampf | M | 128,77 $ | Team Jerry | wartet |
| 495 | Zufallsspieler spielt Kapitel 1 in Godot durch (Abnahme 2.2; Wochenziel 03.11., 488) | E Technik | M | 27,75 $ | Team Tom | wartet |
| 496 | Durchspiel-Build: Kapitel 1 von Anfang bis Ende am Handy (Wochenziel 03.11., 488) | E Technik | M | – | Team Jerry | wartet |
| 499 | Erschaffung: Held im Drehteller mit schwebendem Schild und Schwert statt Tragart nach 417 (Chef 03.11., 07:14, Build 204) | E Figuren | M | 9,32 $ | Team Tom | wartet |
| 509 | Frösche und Libellen an den Teichen im Flüsterwald fehlen in Godot (Chef 03.11., 09:21; `PondLife.kt`, Projektplan O6, W22) | E Welt | M | – | Team Jerry | ruht |
| 511 | Kein Filmlauf ohne geprüftes Probebild vorher (Chef 03.11., 13:47: „Warum werden so viele sinnlose und kaputte Filme gemacht?“) | B Werkzeuge | M | 19,83 $ | Perikles | startbar |
| 512.1 | Wächter: Testbitte ohne Zeile „Verglichen:“ warnt (zu 512) | B Werkzeuge | M? | – | Perikles | gebaut |
| 524.1 | Gegenstandsfenster besser als alt und spielerfreundlicher: Vorschlag (Chef 04.11., 00:52) | A Spiel | M | – | Team Tom | startbar |
| 512 | Vor jeder Testbitte berührte Schirme alt gegen neu vergleichen (Sokrates 03.11., 07:45, nach Build 204: 9 Erstfunde des Chefs; Chef 23:28 an Sokrates) | B Abläufe | M | 58,93 $ | Sokrates | erledigt |
| 512b | Testbitte nur mit Nachweis eines fremden Helfers (Chef 04.11., 19:21: ja) | B Abläufe | M | 72,73 $ | Perikles, Jerry, Tom, Diogenes | gebaut |
| 531 | Build 249: Garrick wie alt und besser: Gesicht, Langbogen auf dem Rücken, vertreibt Tiere sichtbar mit der Fackel, Ruhebewegungen (Chef 03.11., 23:42) | A Spiel | M | 12,96 $ | Team Tom | startbar |
| 531a | Rückfrage: Bewegungspaket „Campfire“ für Garrick und Rast kaufen? (Chef 04.11., 19:27) | A Spiel | M | – | Team Tom | wartet |
| 551 | MARS: Rahmen des unteren Kastens links und rechts unterbrochen (Chef 04.11., 00:21) | E Kampf | M | – | Team Jerry | ruht |
| 547 | MARS: Text sagt „geht in die Knie“, Sturz ist aus (438a eingefroren): Text und Bild in Einklang bringen (Chef 04.11., 00:01) | E Kampf | M | 5,43 $ | Team Jerry | wartet |
| 532 | Kampf: Held geht ohne Zauberpunkte, Verbrauchtes, Zustände, Metrausch und ohne die ganze Tasche (nur einfacher Heiltrank) in den Kampf, danach wird nur TP zurückgeschrieben; Zauber kosten nichts (Abgleich 512, Sokrates 03.11., 23:4x) | E Kampf | M | 2,28 $ | Team Jerry | wartet |
| 534 | Kampf: Zauber und Fähigkeiten fehlen in „Können“ (Magierrüstung, Untote vertreiben, Spirituelle Waffe, Geisterwächter) oder wirken nicht (Unglaubliches Ausweichen, Unerbittlichkeit, Lebensraub, Schadensminderung der Ausrüstung); Talente zu Kampfbeginn (Einschüchtern, Schwächen kennen) (Abgleich 512, Sokrates 03.11., 23:4x) | E Kampf | M | 2,32 $ | Team Jerry | wartet |
| 536 | Kampf: Erklärungen bei langem Drücken (MarsTips), Grund bei gesperrtem Zauber, „Kein Ziel in Sicht“, Knopf „Schnell“, Stufe und EP im Gruppenkasten, Seltenheitsfarbe der Beute (Abgleich 512, Sokrates 03.11., 23:4x) | E Kampf | M | 2,28 $ | Team Jerry | startbar |
| 540 | Texte hängen am Spielbeginn: Südrand (immer Text vor dem Auftrag, „Kapitel 2 folgt“ fehlt, nichts gemerkt), Schlagbaum nach dem Auftrag, Klopfen an 12/5 nach Kapitel 1, Tipp beim Erwachen auch bei klassischer Steuerung (Abgleich 512, Sokrates 03.11., 23:4x) | A Spiel | M | – | Team Tom | wartet |
| 542 | Aufträge: Jorins „Feuer am Steinkreis“ nicht abschließbar (Fetzen fehlt), Gwennas Ring am Brett ohne Höhle nicht findbar, Aldrics Ring als Ding statt Einzelstück (Abgleich 512, Sokrates 03.11., 23:4x) | A Spiel | M | – | Team Tom | startbar |
| 543 | Startwerte gegen alt und BRS prüfen: Startgold 15–25 und Start-Heiltränke fehlen, Wiederkehrort Schenke statt Tempel, Beute im Tiefen Wald Stufe 1 statt 2 (Abgleich 512, Sokrates 03.11., 23:4x) | A Spiel | M | – | Team Tom | startbar |
| 549a.1 | ROLLE-ENTWICKLUNG: vor jedem Menüschirm „Fenster und Schirme“ lesen (zu 549a) | B Abläufe | M? | – | Perikles | erledigt |
| 558 | Robe des Magiers zu glatt, wie eine blaue Fläche: Stoff lebendiger (Falten, Schatten, Schmutz, Abnutzung) (Chef 04.11., 11:31, Bild) | E Figuren | M | 96,33 $ | Team Tom | startbar |
| 558.1 | Prüferrest Robe Probe 5 nachhalten, nicht bauen; Chef sieht es nach dem Durchspielen an (Chef 04.11., 22:23) | E Figuren | K | – | Team Tom | ruht |
| 560 | Monster auf der Karte drehen sich zum Helden, wenn sie ihn wahrnehmen, mit Schritten statt auf der Stelle (Chef 04.11., 16:22) | E Monster | M | – | Team Jerry | startbar |
| 562 | MARS: Helden laufen zum Angriff viel zu langsam, zurück gleiten sie flott (Chef 04.11., 17:02, t257 C) | E Kampf | M | 2,28 $ | Team Jerry | in Arbeit |
| 563 | MARS: Zustandsschilder über Gegnern („Blut 3“) überlagern Ansage und Leisten, wirken grob (Chef 04.11., 17:02, t257 C) | E Kampf | M | – | Team Jerry | startbar |
| 565 | MARS: unten im Gruppenkasten sieht man nicht, welcher Held am Zug ist (Chef 04.11., 17:10, t257 C) | E Kampf | M | – | Team Jerry | startbar |
| 568 | Ernten als Handlung statt Einsaugen; Angeln mit Pose und Ring (Chef 04.11., 19:42: ja, A) | A Spiel | M? | – | Team Tom | ruht |
| 569 | Baumkronen ohne erkennbare Tuschelinie, „ein einziger Brei“ (Chef 04.11., 19:44, Bild 558 Probe 4) | A Spiel | M | – | Team Tom | startbar |
| 570 | Theke: Wahl „Fleisch verkaufen · 12 Gold“ liest sich wie ein Preis (Prüfer 557 Runde 4) | A Spiel | M? | – | Homer | startbar |
| 581 | Ausrüstung: Seite breiter als der Schirm, Reiter springen (Abgleich 512b) | A Spiel | M | 2,31 $ | Team Tom | startbar |
| 583 | Textkasten: ▼ liegt im Text, erzählter Text ohne i-Punkte und nicht schräg (Abgleich 512b) | A Spiel | M | 5,99 $ | Team Tom | wartet |
| 584 | Kein halbfetter Schnitt: Köpfe und Titel in Erschaffung, Held, Chronik, Karte, System, Brett, Test nicht hervorgehoben wie alt (Abgleich 512b) | A Spiel | K | – | Team Tom | ruht |
| 585 | Menüs Kleinigkeiten: Titelumbruch Hauptmenü, Knopf Lizenzen, Bild in Rückfrage Wegwerfen, Test „Variante“ (Abgleich 512b) | A Spiel | K | – | Team Tom | ruht |
| 586 | Schirme 557 einheitlich: Zeichen neben der Überschrift bei Rast, Größe der Überschriften (Chef 05.11., 09:35, Kür) | A Spiel | K | – | Team Tom | wartet |
| 587 | Gegnergröße im Kampfort: 1,3-fach wie alt und die Wölfe, echte Größe oder je Kapitel (Chef 05.11., zu Bild 494) | E Kampf | M | 2,93 $ | Team Jerry | startbar |
| 589 | Dorf: Marktplatz wirkt geklont (gleiche Stände, gleiche Säcke), Durchgang links am Stand hakelig (Chef 05.11., 19:2x, t266) | E Welt | M | – | Team Tom | startbar |
| 590 | Innenräume: Türseite bei gedrehter Kamera dunkel und tot, mehr Licht (Kerzen) und Einrichtung (Chef 05.11., 19:2x) | E Innenräume | M | – | Team Tom | startbar |
| 591 | Dorftiere (Hühner, Kaninchen) fliehen vor dem Helden wie alt, mit Alarmklang (Chef 05.11., 19:2x) | E Welt | M | 3,68 $ | Team Tom | startbar |
| 593 | MARS: Ausweichen auch rückwärts als Abwechslung zu links und rechts (Chef 05.11., 19:2x) | E Kampf | M? | – | Team Jerry | wartet |
| 595 | Kampfbewegungen der Kaufgegner: Spinne mehr Angriffe, Egel und Schnecke schneller, Treffhöhe, Ruckeln, Ruhe (Chef 05.11., 19:2x, t266.1) | E Kampf | M | – | Team Jerry | wartet |
| 597 | MARS: Ring ohne Ankündigung (Fledermaus); alle Angreifer prüfen (Chef 05.11., 19:2x) | E Kampf | M | 2,88 $ | Team Jerry | startbar |
| 598 | Umweltklang je Ort, Tageszeit, Wind und Wetter, lebendige Welt (Chef 05.11., 19:2x; Abnahme 6) | E Klang | M | – | Team Jerry | startbar |
| 600 | Kampfort: Knopf zum Beschleunigen wie Würfel und Raster (Chef 05.11., 19:2x) | E Kampf | M | 2,88 $ | Team Jerry | startbar |
| 601 | Goblin-Späher: Schuss ohne Bewegung, falscher Pfeil, kein Pfeil beim Fehlschuss; Treffer trotz Schatten (Chef 05.11., 19:2x, t266.5) | C Kampf | M | 2,88 $ | Team Jerry | startbar |
| 604 | Schenke Erdgeschoss: Bett raus, mehr Tische und Bänke; Schlafen oben nur im Text (Chef 06.11., 09:38) | E Entwicklung | K | – | Team Tom, Homer | startbar |
| 605 | Ausrüstung: leeres Kopffeld, Auswahl zeigt falsch „Obergrenze“, kein Zurück (Chef 06.11., 21:22, t268) | E Entwicklung | M | – | Team Tom | gebaut |
| 606 | Schenke: Met kostet laut Liste 2 Gold, abgezogen werden 4 (Chef 07.11., t268) | A Spiel | M | – | Team Tom | gebaut |
| 607 | Leute nachts: Pim läuft um 3 Uhr herum, sein Klopftext sagt, er schläft (Chef 07.11., t268) | A Spiel | M | – | Team Tom | startbar |
| 608 | Haus wird durchsichtig, wenn der Held dahinter steht, dann geht innen das Licht an (Pims Hütte, Tempel) (Chef 07.11., t268) | E Welt | M | – | Team Tom | startbar |
| 609 | Dorf: Baum hinter der Schenke sperrt den Weg zum Schlagbaum; alle Häuser auf der Waldseite umrundbar (Chef 07.11., t268) | E Welt | M | – | Team Tom | startbar |
| 610 | Held im Dorf: Finger am Stab zucken ohne Unterlass (Schild auf dem Rücken) (Chef 07.11., t268) | E Figuren | M | – | Team Tom | startbar |
| 611 | Klopfen an Türen: deutlicher, mit Name des Hauses oder Sprechers; Zeichen an Pfeiler oder Laterne beim Zwerg wie alt (Chef 07.11., t268) | A Spiel | M | – | Team Tom | startbar |
| 612 | Dorf Süd: Heuhaufen geklont und wie aufgespießt, Wackelgras im Weizenfeld, Gemüsebeet mit Leerstreifen; drei Varianten je Ding (Chef 07.11., t268) | E Welt | M | – | Team Tom | startbar |
| 613 | Intro und Outro wie alt: Tempelgänger, kleine Bewegungen (Chef 07.11., t268.31) | A Spiel | M | – | Team Tom | startbar |
| 614 | Leute lebendig wie alt: Jorin mit Speer, Jorin öffnet den Schlagbaum sichtbar; Abgleich der Requisiten und Gesten (Chef 07.11., t268) | E Figuren | M? | – | Team Tom | startbar |
| 615 | Kamera dreht und zoomt um den Helden als Fixpunkt, läuft nicht aus dem Bild (Chef 07.11., t268) | E Welt | M | – | Team Tom | startbar |
| 616 | Kampf: Gegner weichen nach dem Angriff rückwärts zurück statt vorwärts zu laufen (Chef 07.11., t268) | E Kampf | M | – | Team Jerry | wartet |
| 617 | Hauptmenü „Laden“: Wischen löst Laden aus; laden nur mit dem Knopf rechts (Chef 07.11., t268.1) | A Spiel | M | – | Team Tom | gebaut |
| 618 | Knöpfe einheitlich: „Zurück“, „Abbrechen“, „Schließen“ nach einer Regel auf allen Schirmen, Liste der Abweichungen (Chef 07.11., t268) | A Spiel | M | – | Team Tom | startbar |
| 619 | Blende: derselbe Druck auf den Aktionsknopf drückt die Blende sofort weg (Chef 07.11., t268.18) | A Spiel | M | – | Team Tom | in Arbeit |
| 620 | Stärken ausbauen, Schwächen verkleinern: nachhalten, Lagebild und Wiederholquote je Build (Chef 07.11.) | F Firma | M | – | Sokrates | Dauer |
| 620.1 | Wiederholte Funde des Chefs vor Neuem; wenige Muss je Team zugleich (aus 620) | B Abläufe | M | – | Perikles | Chef |
| 620.2 | Abgleich alt einmal je Ort und Figur als Liste (Leute, Tiere, Requisiten, Gesten, Klänge) für alle Prüflisten (aus 620, 512) | B Abläufe | M | – | Perikles | erledigt |
| 620.2a | Abgleich alt nach `LISTE-ABGLEICH-ALT.md`: Dorf, Innenräume, Leute, Wald (aus 620.2) | B Abläufe | M | – | Team Tom | startbar |
| 620.2b | Abgleich alt nach `LISTE-ABGLEICH-ALT.md`: Höhle, Klang, Gegner, Bosse (aus 620.2) | B Abläufe | M | – | Team Jerry | startbar |
| 621.1 | Probenregel A: höchstens eine Aussehen-Probe je Thema, sonst Rückfrage mit Wegen und Kosten; ersetzt Rundenzahl 389 (Chef 07.11., 621) | B Abläufe | M | – | Perikles | erledigt |
| 626 | Rückfrage: 14 alte Zeilen aus SRD-Zeit und Umzug streichen oder in 478 übernehmen (Inventur 07.11.) | B Abläufe | M | – | Sokrates | erledigt |
| 625 | Sammelbuild 269: alle fertigen Zweige beider Teams (35 warten), Prüfliste als Weg durchs Spiel (Chef 07.11., 20:5x) | E Entwicklung | M | – | Team Tom | startbar |
| 317.1 | `startbar.py`, `lauf.py`: Obergrenze 6 je Build streichen (Chef 07.11., 20:5x) | B Werkzeuge | M | – | Perikles | gebaut |
| 624 | Testanzeigen größer: FPS und Standort über der Welt, Messwerte im Reiter „Test“ (Speicher u. a.) gut lesbar (Chef 07.11., 17:5x) | B Werkzeuge | M | – | Team Tom | startbar |
| 622 | Godot-Build als AAB für Play: dieselbe App `de.bornim.game`, mit dem Upload-Schlüssel des alten AAB, höhere Versionsnummer (Sokrates 07.11., aus 142.4) | M Veröffentlichung | M | – | Team Tom | startbar |
| 621.2 | Toms Vorrat auf etwa 15 KB: Erledigtes und alte „Zu“-Absätze ins Git (Chef 07.11., 621 B) | B Abläufe | M | – | Team Tom | startbar |
| 620.4 | Referenzszene Dorf bis Wolfskampf im Flüsterwald ganz fertig als Maß für alles (aus 620) | B Abläufe | M | – | Perikles | Chef |
| 555 | Testmenü wie alt und schneller: fehlende Einträge der alten Fassung, dazu Sprünge an jede Station von Kapitel 1 (Chef 04.11., 00:30) | B Werkzeuge | M | 15,00 $ | Team Tom | startbar |
| 523 | Tasche wie alt und besser: „Funke löschen“, Seltenheit und Kurzangabe der Vorräte, Ausrüstungszeile mit Art, Platz, Wert, „nicht tragbar“, ▲/▼ farbig, Sortierung nach Platz, Klang beim Benutzen (Abgleich 512, Sokrates 03.11., 23:3x) | A Spiel | M | – | Team Tom | startbar |
| 524 | Gegenstandsfenster, Inhalt wie alt und besser: Grundwerte (Seltenheit, Tragort, Gewicht, Schaden je Griffart, Angriff, RK + GES), Warnungen „Ungeübt“, „Zauberkraft nützt nur Zauberwirkern“, Vergleich mit „im Schnitt“ und Kapiteldeckel (Abgleich 512, Sokrates 03.11., 23:3x) | A Spiel | M | – | Team Tom | startbar |
| 528 | Held, Karte, Chronik wie alt: Satz zur Höchststufe des Kapitels am EP-Balken, Kartenzeichen in der oberen Leiste, „Auf der Karte“ bei Nebenaufträgen (Abgleich 512, Sokrates 03.11., 23:3x) | A Spiel | M | – | Team Tom | wartet |
| 522 | Build 249: Ausrüstung im Testmenü geändert (Schild gegeben), Held im Spiel ohne Schild (Chef 03.11., 23:33) | A Spiel | M | – | Team Tom | startbar |
| 521 | Build 249, Ausrüstung: Wechselschirm eines Platzes wie alt (Bild, Art und Wert, ▲/▼, „nicht tragbar“ matt) (Chef 03.11., 23:23, Bild) | A Spiel | M | – | Team Tom | startbar |
| 519 | Build 249, Ausrüstung: Gegenstandsfenster („Göttlicher Ring des Eisernen Richters“) passt nicht auf den Bildschirm, rechts abgeschnitten (Chef 03.11., 23:13, Bild) | A Spiel | M | 21,91 $ | Team Tom | startbar |
| 517 | Waldklang wie alt: Vögel am Tag, Eule und Grillen nachts, fernes Wolfsheulen im Tiefen Wald (`WildSound.kt`; Abgleich 512, von Team Tom) | A Spiel | M | 2,32 $ | Jerry | wartet |
| 513 | Ein Figurenstand für alle Zweige; Schild, Robe Magier, Umhang jetzt (Chef 03.11., 15:56, „513 B“) | E Figuren | M | 14,01 $ | Team Tom | ruht |
| 515 | Truhen: 3–4 je Karte halb versteckt, verschlossene nach BRS (Dietrich, Aufbrechen) (Chef 03.11., 16:07) | O Orte | K | – | Team Tom | ruht |
| 510 | Fledermaus: freies Modell (OGA „Vampire Bat“, CC0) neben der eigenen im Film, Chef wählt (Chef 03.11., 10:28–10:57, aus 494) | E Kampf | M | 17,92 $ | Team Jerry | ruht |
| 508 | Lehrmeister in Kapitel 1 erreichbar (Geselle), Magie-Pflicht Paladin/Kriegsmagier, Wachsoldat zu Wächter (aus 447.4) | D Design | M? | – | Sokrates | startbar |
| 505 | Bau Nebel des Krieges und Sichtfeld des Helden (Archiv 502; Welt W24, W25) | B Umzug | M | 69,46 $ | Team Tom | startbar |
| 506 | Untote im Kampf: Skelett, Zombie, Ghul (aus 494, Spike; Wochenziel 03.11., 488) | E Kampf | M | 26,61 $ | Team Tom | startbar |
| 507 | Kampforte Höhle: Eingang, Gang, Halle, Teich, Lager (Orte O10; aus 492) | E Kampf | M | 34,94 $ | Team Jerry | startbar |
| 471 | Bau BRS 1.2 Fertigkeiten durch Tun (Wochenziel 02.11., Stufe 1) | E Regeln | M | – | Team Tom | wartet |
| 474 | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, Meldung Tuffy): nächster Build einmal deinstallieren; dauerhaft ohne Cache | E Technik | M? | 8,66 $ | Team Tom | ruht |
| 475 | Leute des Dorfs (Rowena, Borin …) auf Kaufkörper ihres Volks mit Gesicht, statt der alten Figuren (Chef 02.11., 10:52, Build 146: „Kommt da noch was?“) | E Figuren | M | 64,38 $ | Team Tom | startbar |
| 476 | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | E Oberfläche | M? | – | Team Tom | wartet |
| 477 | Godot-APKs laufen nicht im MuMu Player am Rechner (Chef 02.11., 14:59) | E Technik | M? | – | Team Tom | startbar |
| 465 | Chefsache „Zu entscheiden“ mit Uhrzeit in „Seit“ wie bei Anzusehen und Zu tun (Chef 01.11., 20:50) | B Abläufe | M | 2,43 $ | Perikles | erledigt |
| 464 | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählung im Tagesbericht (Chef 01.11., 20:4x) | B Abläufe | M | – | Perikles | startbar |
| 461 | Grundstand Figuren und Kampf: Checkliste des Entschiedenen, Prüfer prüft jede Vorlage dagegen („jetzt“ 01.11., 20:3x) | B Abläufe | M | 22,37 $ | Perikles | erledigt |
| 417.1 | Restmängel Tragart nach „417 passt“ (Schildabstand, Rumpfdrehen, Fußrutschen, Kornfeld, Stabgang) | E Figuren | K | – | Team Tom | ruht |
| 461.1 | Grundstand zusammenführen: ein Zweig für Tom und Jerry, jede Probe baut darauf (01.11.) | B Umzug | M | 30,19 $ | Team Tom, Team Jerry | ruht |
| 461a | Rückfrage: hält ein Verstoß gegen den Grundstand den Film an? (D58.5) | B Abläufe | M | – | Perikles | erledigt |
| 461b | Nur Gültiges steht: neu ersetzt alt im selben Commit, Commit-Prüfung, Kennzahl Widersprüche (Chef 01.11., 22:26) | B Abläufe | M | – | Perikles, Diogenes, Sokrates | ruht |
| 461b.4 | Widersprüche aus Liste 461b: Köpfe Regelwerk, Bestiarium, DESIGN-KAMPF gegen Entscheidung 84 | D Design | M | 33,44 $ | Sokrates | startbar |
| 461d | Gültige Entscheidungen an einem Ort: Grundstand in die DESIGN-Dateien einsortieren (Vorentscheid Sokrates 01.11., 22:5x) | B Abläufe | M | 8,53 $ | Perikles, Homer | erledigt |
| 460 | Kamerafahrten im Kampfort: Eröffnung wie Drohnenflug je Blende, Wechsel der Perspektive ohne Eingabe; erst Probefilm (Chef 01.11., 20:2x) | E Kampf | M | – | Team Jerry | ruht |
| 406.1 | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann Bau (Chef 01.11., 20:2x) | E Kampf | M | – | Team Jerry | wartet |
| 406.2 | Angriff gehen statt rennen, Parade mit Schild je Richtung (Chef 03.11., 06:59, Schildfilm) | C Kampf | M | 41,37 $ | Team Jerry | startbar |
| 410 | Waffen am Körper wegstecken, alle Waffenarten (aus 376.1, Chef 29.10., 10:52, 11:40) | E Figuren | M | – | Team Tom | erledigt |
| 415 | Handyprobe Beams-Free-Sample (aus 414, Chef 31.10., 20:3x; „jetzt“ 01.11.) | C Kampf | M | 49,16 $ | Team Jerry | wartet |
| 623 | Effektpakete REEBOO Labs: Kauf, Ressourcenseite `LISTE-QUELLEN.md`, Zuordnung `LISTE-EFFEKTE.md`, Dank im Spiel (Chef 07.11.) | C Kampf | M | – | Sokrates | Chef |
| 623.2 | Effekte aus 623 A einbauen mit 478, in `LISTE-BESTAND.md` und `LISTE-EFFEKTE.md` mit Datenfeld `fx` (Chef 07.11., 623) | E Kampf | M | – | Team Jerry | wartet |
| 623.3 | Commit-Prüfung warnt bei neuem Shader oder Teilchenknoten ohne Zeile in `LISTE-EFFEKTE.md` (Chef 07.11., 623 E) | B Werkzeuge | M | – | Perikles | erledigt |
| 623.4 | Dank „Mit Dank an“ für alle fremden Quellen in „Über das Spiel“ (497), Wortlaut (Chef 07.11., 623 F) | C Texte | M | – | Homer | erledigt |
| 623.5 | Probe Kampf mit den Gratisproben (Combat Mega, Projectiles, Trails, Pack 3, Character Shaders) im Kampfort, Compatibility, FPS, ein Film (Chef 07.11., 623) | E Kampf | M | – | Team Jerry | startbar |
| 623.6 | Probe Welt mit den Gratisproben (Gras und Wind, Wasser, Wetter, Oberflächen) gegen unsere Fassung, Dorfbach und Flüsterwald, FPS, ein Film (Chef 07.11., 623 B1, D) | E Welt | M | – | Team Tom | startbar |
| 623.7 | „Mit Dank an“ (623.4) in „Über das Spiel“ (497) einbauen, de/en (Chef 07.11., 623 F) | C Texte | M | – | Team Tom | startbar |
| 623.1 | Prüfschema auf bisher geprüfte Quellen anwenden (Chef 07.11., aus 623) | B Abläufe | M | – | Sokrates | startbar |
| 416.4 | Rennen des Helden wirkt wie Hochsprung (Chef 31.10., 20:4x) | B Umzug | M | 41,57 $ | Team Tom | startbar |
| 416.6 | Spuren des Helden, auch bei Regen; Blutspuren in der Welt zuerst (Chef 31.10., 20:4x; 03.11., 07:31) | B Umzug | M | – | Team Jerry | ruht |
| 423.1 | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | A Technik | M? | – | Team Tom | wartet |
| 431 | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, dann Körperbau je Volk (Chef 31.10., 22:0x) | E Figuren | M | 50,10 $ | Team Tom | ruht |
| 431c | Rückfrage: Völker Runde 4 am Tor angehalten, neue Läufe frei? | E Figuren | M | – | Team Tom | Chef |
| 431d | Rückfrage: Völker Lauf 3 am Tor angehalten (B1 Elf, C3, G3, A1/A3 Grak, A2), neue Läufe frei, Weg A2? | E Figuren | M | – | Team Tom | Chef |
| 431e | Rückfrage: Gesicht des Helden im Dorflicht fast weiß, Hauteichung nach Messung? | E Figuren | M | – | Team Tom | Chef |
| 432 | Eigenes Volk aus Bornim (etwa mit dem Grauen Propheten, „Tag der Asche“) prüfen, mit der Geschichte ab Kapitel 2 (Chef 31.10., 22:0x) | C Texte | K | 0,79 $ | Homer | ruht |
| 438 | Wölfe im Kampf wirken gleitend: Angriff, Tempo, Vorbeigehen (Film 403, Chef 31.10., 23:31) | E Kampf | M | 124,52 $ | Team Jerry | wartet |
| 438a | Hinfallen und Aufstehen des Kaufhelden aus dem Waffenpaket, Waffe und Schild frei (Archiv 438a) | E Kampf | M | 24,62 $ | Team Jerry | ruht |
| 453 | Wölfe im Kampfort: Ruhebewegungen (atmen, scharren, umblicken, knurren) (Chef 01.11., 11:05) | E Kampf | M | 47,52 $ | Team Jerry | ruht |
| 455.1 | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 11:24) | E Figuren | M | 30,05 $ | Team Tom | ruht |
| 455.2 | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völker (Chef 01.11., 11:27, 455 ja) | E Figuren | M | – | Team Tom | ruht |
| 458.3 | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | E Figuren | M | 12,15 $ | Team Tom | ruht |
| 447.4.1 | Bau Lehrmeister, Meisterschaften, Ruf Kapitel 1 (447.4) | C Texte | M | – | Team Tom | wartet |
| 416.8 | NPC dreht sich zum Helden, nach etwa 10 s Leerlauf (Chef 31.10., 20:5x) | B Umzug | M | 19,24 $ | Team Tom | startbar |
| 390 | Umzug: Punkte ohne Bilderrunde weiterbauen, solange Blätter beim Chef liegen (Perikles 28.10., Wochenziel 348) | E Technik | M | 39,54 $ | Team Tom, Team Jerry | erledigt |
| 383.2 | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | B Werkzeuge | M | – | Sokrates | wartet |
| 383 | Wartewächter und Haken 63 verschärfen (Chef 27.10., 17:53 ja); Sitzungsgröße messen (Sokrates) | B Werkzeuge | M | 99,45 $ | Perikles | startbar |
| 627 | probelauf.py: Push mit `git commit -F -` im selben Befehl als Probelauf gezählt (562, ohne Lauf) | B Werkzeuge | M? | – | Perikles | gebaut |
| 341.1 | Zielvereinbarung für alle Rollen: je Rolle höchstens drei Ziele, Z3 und Z4 für alle, eins eigen (aus 341) | B Abläufe | M | – | Sokrates | startbar |
