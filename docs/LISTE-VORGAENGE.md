# Vorgänge

Eine Zeile je Vorgang (113), für den Überblick und die Kosten. **Wird beim Start nicht gelesen**; eine Nummer gezielt suchen mit `python3 tools/vorgang.py <Nr>` (alle Orte, 275). Wer einen Vorgang anlegt, trägt hier Bereich und Klasse ein (der Zähler „Nächste freie Vorgangsnummer“ steht in [Betrieb](ARBEIT-BETRIEB.md)); wer ihn abschließt, setzt den Stand. Stand nur aus der Wortliste (275; prüft `regelcheck.py`): offen, startbar, in Arbeit, wartet, Chef, ruht, gebaut, zu testen, Dauer, nach Meilenstein, aufgeteilt, Idee, erledigt; Einzelheiten im Vorrat. Unterpunkte (z. B. 13q.4) gehören zum Vorgang ihrer Nummer.

- **Bereich** (124): Hauptthema **E** Entwicklung (Welt, Figuren, Kampf, Klang, Oberfläche), **G** Gestaltung (Story, Stil, Balance), **Q** Qualität (QS, QM), **B** Betrieb (Steuerung, Abläufe, Werkzeuge), **M** Markt (Beratung, Veröffentlichung); Tabelle in `FIRMA.md`.
- **Kl.** (126): **M** Muss (im Wochenziel oder „jetzt“ des Chefs), **K** Kür, „–“ abgeschlossen. Stand der Zuordnung: 16.10., erstes Wochenziel 18.–24.10. (`LISTE-ABNAHME-KAPITEL1.md`).
- **Kosten** in $ (`usage.cost_usd`, Summe ab 17.10.): trägt Ford bzw. Ford 2 beim Neustart ein (`LISTE-BETRIEB.md`); „fehlt“, wenn die Zahl nicht zu bekommen war.

| Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |
|---|---|---|---|---|---|---|
| Betrieb | Läufe von Ford und Ford 2 | B Steuerung | – | Ford 37,38 $, Perikles Vorratsdurchsicht 1,90 $; Sokrates 18.10. 5,60 $; Ford 2 16,79 $; Probe Pro Mittel 17.10. 0,00 $; +688,64 $ | Ford | laufend |
| 19 | Zeitablauf der Kampfbewegungen (19e Beispiel) | E Kampf | K |  | Jerry | ruht |
| 24 | Animationen fehlen nach Start/Kartenwechsel; Zwischenbildschirm für Orte und Kämpfe | E Oberfläche | K |  | Jerry (Inhalt; Technik Tom erledigt) | ruht |
| 26.1 | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef 24.10., 16:56) | Q QS | M | – | Sokrates | wartet |
| 30 | Abstürze beim Testen | Q QS | K |  | Tom (Jerry: Klang-Fäden) | ruht |
| 38 | Balance-Langzeitplan (`DESIGN-BALANCE.md`) | G Balance | M | 11,51 $ | Jerry | offen |
| 39 | Schwierigkeitsgrad im Menü | E Kampf | M | 3,80 $ | Jerry (Menü mit Tom) | wartet |
| 41 | Storyplan je Kapitel, Plot Kapitel 2 | G Story | K | 4,27 $ | Homer mit Chef | nach Meilenstein |
| 41.2 | Ansel fährt nach N3 auch nachts (Prüfpunkt 6.4) | G Story | K |  | Homer | Chef |
| 45 | Geschäftsmodell und Umsetzung (Play Store) | M Veröffentlichung | M | 4,68 $ | Sokrates mit Nutzer | ruht |
| 48 | Zufallsgenerierte Dungeons, auch Questhöhlen | G Balance | K |  | Ideenspeicher | später |
| 49 | Lehrer für Waffen-, Rüstungs- und Rettungswurf-Übung | G Balance | K |  | Ideenspeicher | später |
| 50 | Weitere Klassen, ggf. zum Kauf | G Balance | K |  | Ideenspeicher | später |
| 52 | Feinarbeit an den Kampfanimationen | E Kampf | K |  | Ideen | Idee |
| 70 | Zwischensequenzen einheitlich, Bildsprache | G Stil | K | 2,30 $ | Ideen | ruht |
| 72 | Profil und Marktvergleich | E Kampf | K | 0,72; +0,61 $ | Homer, Jerry | Chef |
| 79 | Kampfhintergründe wie Diagonalwelt | E Kampf | K |  | Ideen | Idee |
| 84.4 | Lauschen beim Stehen: Welle zur Quelle | G Balance | K |  | Ideenspeicher | später |
| 86 | Bewegung und Übersicht: Ausdauer, Rennen, Rast, Kartenzeichen | E Kampf | K | 0,72; 1,21 $; +1,81 $ | Jerry | wartet |
| 99 | Zwei Niederlassungen | B Steuerung | K | 7,25 $ | Perikles | ruht |
| 102 | Dokumente BornWire TCS nachziehen | B Abläufe | K |  | Ideen | Idee |
| 109 | Repo öffentlich | M Veröffentlichung | M |  | Sokrates | Chef |
| 111 | `DESIGN-BLENDE.md` kürzen (nach 24.6) | B Abläufe | K |  | Ideen | Idee |
| 133 | Wahlen im Spiel: vier Charisma-Wahlen in Kapitel 2 (Chef 19.10. ja) | G Story | K | 1,12 $ | Tom, Jerry | nach Meilenstein |
| 134 | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | E Figuren | K | 1,06 $ | Tom | aufgeteilt |
| 142 | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | M Veröffentlichung | M | 12,30 $ | Sokrates | wartet |
| 142.2 | Pflichttest erst mit Bekannten, Webseite später (Chefsache) | M Veröffentlichung | M |  | Sokrates | wartet |
| 142.3 | Tester öffentlich suchen (Chef 27.10., 19:32) | M Veröffentlichung | M | – | Sokrates | in Arbeit |
| D23.3 | Magier und Kleriker sterben oft (Lauf 23) | G Balance | M |  | Jerry | ruht |
| Woche | Wochenzählung der Kennzahlen | Q QM | K |  | Diogenes | offen |
| 145 | Karten je Kapitel zum Drucken | E Welt | K | 6,22 $ | Tom | ruht |
| 167.6 | Morgenbericht mit Kennzahlen und Kostenbilanz (Chef 18.10.) | B Steuerung | M | 2,29 $ | Sokrates | Termin |
| 168.1 | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | G Story | K |  | Jerry | nach Meilenstein |
| 72u.1 | Umsetzung 72u: Kampfort aus der Karte (Standbild 2, Bau) | E Kampf | K | 2,38 $ | Jerry | ruht |
| 186.3 | Ausgefüllte Prüfbögen auswerten | Q Qualität | K |  | Diogenes | wartet |
| 212 | Kampfsystem wählbar: MARS oder klassisch, Schalter in den Einstellungen (Chef 19.10. A) | G Balance | M | 0,61 $ | Jerry | wartet |
| 217 | Wölfe (Grimmzahn, Rudelwolf) beißen im Kampf teils in die Luft, nach Süden am Helden vorbei (Chef 19.10.) | E Kampf | M | 3,24 $ | Jerry | ruht |
| 211.14 | Rest 211.13: Leistung A56, Puppen-Gegner im Kamerawinkel, Winkel je Platz, Wechsel als Gang | E Kampf | M? | – | Jerry | ruht |
| 246 | Dokumente grundsätzlich ins Repo statt als Artefakt; Wochenplan aktualisiert (Chef 20.10.) | Q Ablauf | K | –; +7,03 $ | Sokrates | entschieden |
| 246.1 | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | Q Ablauf | K | – | Sokrates | offen |
| 249 | MARS wie der klassische Kampf: Gleiten, Hiebe, Zoom, Blut, Effekte, Zustände (Chef 20.10.) | E Kampf | M | –; +33,41 $ | Jerry | offen |
| 253 | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf (Chef 20.10.) | M Markt | K | – | Sokrates | Dauer |
| 257 | Build 46: Meldung „App reagiert nicht“, warten oder schließen, läuft dann weiter (Chef 20.10.) | E Technik | M | – | Jerry | offen |
| 262 | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | B Betrieb | K | – | Sokrates | ruht |
| 263 | Rolle für Finanzen und Geschäftszimmer? (Chef 20.10.) | B Betrieb | K | – | Sokrates | Dauer |
| 365 | Aufwand „Hoch“ statt „Mittel“ für einzelne Rollen? (Chef 25.10., 12:36) | B Betrieb | M | –; +4,65 $ | Sokrates | Probe |
| 264 | Arbeitsorte neben GitHub: NAS, Proxmox, ALL-INKL? (Chef 20.10.) | B Betrieb | K | – | Sokrates | Chef |
| 267 | Spiel ruckelt auf dem Tablet (Chef 20.10., Build 48) | E Technik | M | –; +13,77 $ | Tom | ruht |
| 270 | Perikles und Diogenes auf das große Modell (Chef 21.10.) | B Betrieb | M | –; +4,16 $ | Perikles | wartet |
| 275 | Zentrale Vorgangsliste als einzige Quelle (Chef 21.10.; Stufe 1 jetzt, 27.10.) | B Werkzeuge | M | 17,83 $ | Perikles | wartet |
| 276 | Fords Anleitung auf eine Seite (Empfehlung Sokrates zu 274) | B Abläufe | K | – | Perikles | offen |
| 283.1 | Hohes Gras sichtbar höher als ein Feldweg, stimmige Welt (Chef 21.10.) | G Stil | K | – | Ideenspeicher | offen |
| 284 | Bis zum Durchspielen (26) am Kampf nur Fehlerbehebung, kein Feinschliff (Vorschlag Sokrates) | B Vorrang | M | – | Sokrates | entschieden |
| 289 | MARS: Wechsel „halber Zug“ missverständlich; Bewegung und Aktion im Kästchen zeigen? (Chef 21.10., 20:11) | E Kampf | K | – | Jerry | ruht |
| 292.2 | Hauptmenü: vier Figuren größer, schärfer, mit gelegentlicher Bewegung je Klasse (Chef 21.10., 22:28); Stufe 1 mit 292, Bewegung nach 284 | E Oberfläche | M | – | Team Tom | ruht |
| 292.4 | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., 15:10) | G Stil | K | – | Team Tom | ruht |
| 296 | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MARS fehlt (Chef 22.10., 07:50) | B Abläufe | M | –; +2,98 $ | Sokrates | Vorlage |
| 296.1 | Erste Fassung Checkliste MARS (`LISTE-MARS.md`) gegen den Code prüfen und pflegen | E Kampf | K | – | Team Jerry | neu |
| 296.2 | MARS spielnötig: Beute/Erfahrung, Fliehen, Eröffnung, Zustände, eigene Ausrüstung, Schalter (Chef 23.10., 18:25) | E Kampf | M | –; +12,97 $ | Team Jerry | gebaut |
| 296.3 | MARS-Schmuck: Todesschrei, Flucht/Zerfall, Zustände gezeichnet, Siegerpose (Chef 23.10., 18:25) | E Kampf | K | – | Team Jerry | ruht |
| 302 | Bildsignatur: ist unsere Grafik wiedererkennbar, wie wird sie es? (Chef 22.10., 12:12); ja 14:15, Probe in 292.3; Bestand 20:25: Figuren zuerst, Umriss schätzt Tom (302.1) | G Stil | K | –; +3,98 $ | Homer | wartet |
| 302.1 | Tuschelinie für Menschengestalten (Chef 22.10., 20:25, über Sokrates); jetzt nicht (Chef 23:37); M seit 338 (b), Charaktererstellung | G Stil | M | – | Team Tom | ruht |
| 302.2 | Tusche auf der Gebietskarte (Chef 22.10., 23:50); zurückgestellt (Chef 23.10., 10:45) | G Stil | K | – | Team Tom | ruht |
| 302.3 | Intro und Outro mit Tusche im Zeichner, etwas kräftiger als Intro 4 (Chef 23.10., 10:45) | G Stil | M | –; +6,40 $ | Team Tom | ruht |
| 327 | Zweites Spiel: Marktsichtung Denkspiele, Modell ohne Werbung (Chef 23.10., 00:08; vertraulich, Dokument außerhalb des Repos) | F Firma | K | –; +1,26 $ | Sokrates | wartet |
| 318 | Knappheit per Einstellung: Antwortstil „Knapp“ und Startanhang (Chef 22.10., 21:34) | B Abläufe | M | –; +45,66 $ | Sokrates | beobachten |
| 339 | Dashboard „Stand zum Marktstart“, immer aktuell (Plan, Ausgaben, Risiken) (Chef 23.10., 09:08) | B Abläufe | M | – | Perikles | offen |
| 340 | Rollenspiegel: zehn Fragen Ist-Soll an alle Rollen, Antwort am Sitzungsende mit Beleg (Chef 23.10., 09:34) | B Abläufe | M | –; +3,54 $ | Sokrates | entschieden |
| 340.2 | Rollenspiegel C: `tools/rollenspiegel.sh`, eigene Antwort ohne fremde | B Abläufe | M | –; +6,35 $ | Sokrates | gebaut |
| 338.1 | Stand zum Marktstart: jeden Montag eine Seite für den Chef, Ampel je Block (Chef 23.10., 09:01: Stand wird ihm nie vorgelegt) | B Abläufe | M | –; +5,07 $ | Perikles | Dauer |
| 376 | Quaternius-Bausätze (Dorf, Natur, Dungeon, Outfits) und gedrehte Häuser prüfen (Chef 27.10., 12:00) | E Welt | M | 38,96 $ | Sokrates | wartet |
| 376.1 | Probeblatt Quaternius-Figuren mit Bewegungsraster als Film (Chef kaufte 27.10., 12:20) | E Figuren | M | 64,19 $ | Team Tom | startbar |
| 376.2 | RenderHub-Marktpaket: Brunnen, Stände als Form (Chef 27.10., 12:37) | E Welt | M | – | Team Tom | wartet |
| 374 | Wer prüft regelmäßig, dass alle 373 einhalten? (Chef 27.10., 11:54) | B Abläufe | M | 4,45 $ | Perikles, Diogenes, Sokrates | offen |
| 372 | Feinschliff Held am Ende des Umzugs: Kettenhemd, Helm, Kragen (aus 338a B, Chef 27.10., 09:36) | E Figuren | M | – | Team Tom | ruht |
| 341 | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug und Diogenes (Chef 23.10., 09:39) | B Abläufe | M | – | Perikles | Dauer |
| 304 | Klassischer Kampf: Konter nach Abwehr, obwohl getroffen, regeltechnisch richtig? (Chef 22.10., 13:22) | E Kampf | M | – | Team Jerry | Chef |
| 344 | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23.10., 16:05) | E Welt | M | – | Sokrates | entschieden |
| 347 | Paket „Regeltreue erhöhen, Kosten senken“ (Zähler, Kernregeln, kleiner Start) prüfen und umsetzen (Chef 24.10., 16:20) | B Abläufe | M | –; +15,42 $ | Sokrates | entschieden |
| 347.2 | Umsetzung Plan 347 nach Gegenprüfung (Chef 24.10., 16:30) | B Abläufe | M | – | Perikles | gebaut |
| 348 | Fertige Spiel-Engine statt Selbstbau: Umzug nach Godot (Chef 24.10., 16:43) | E Technik | M | –; +115,14 $ | Sokrates | in Arbeit |
| 348.1 | Vergleichsbild Gebietskarte alt/neu, 64 (heute) und 128 je Kachel (Chef 24.10., 16:51, „jetzt“ 16:54) | E Technik | M | – | Team Tom | raus |
| 348.2 | Tusche nach Licht auch am Helden, Innenlinien an Bäumen: zweites Vergleichsbild jetzt (Chef 24.10., 17:30, 17:36) | E Technik | M | – | Team Tom | ruht |
| 348.6 | Umzug Godot: Fundament, Dorf als erste Gebietskarte | E Technik | M | 552,44 $ | Team Tom | Chef |
| 348.7 | Umzug Godot: Modellregel, Kampfort Wolfsrudel MARS | E Technik | M | –; +441,15 $ | Team Jerry | Chef |
| 348.7a | Rückfrage: Geschosse flach oder in 3D | E Technik | M | 58,17 $ | Jerry | in Arbeit |
| 348.7b | Rückfrage: Zauberbahn hoch über die Köpfe oder flach quer über Wolf 3 | E Kampf | M | – | Jerry | startbar |
| 348.9 | Umzug Godot: Arbeitsteilung, Meilenstein, Modelle jetzt (Chef 25.10., 12:24) | B Abläufe | M | 119,56 $ | Perikles, Diogenes | wartet |
| 348.12 | Fertige CC0-Grundmodelle prüfen, Probe Mensch (Chef 25.10., 21:21, 21:36) | E Technik | M | 39,24 $ | Sokrates, Jerry | startbar |
| 348.12c | Modellpaket auch gegen Geld (Quaternius QAL, Dungeon Monsters Kit, andere), Vorschlag mit Preisen (Chef 26.10., 11:59) | G Geld | M | –; +9,24 $ | Sokrates | ruht |
| 348.12f | Probe gekaufte Riesenratte in unserem Look | E Technik | M | 126,85 $ | Jerry | startbar |
| 348.12g | Gekaufte Monster (Ghul, Untote) zur Geschichte passend? | G Story | M | 4,29 $ | Homer | entschieden |
| 348.12h | Fertige Dinge, Möbel, Waffen suchen (CC0 zuerst, sonst gekauft; Chef 26.10., 16:16) | G Geld | M | – | Sokrates | in Arbeit |
| 348.12i | Kaufmodelle mit `AESContext` verschlüsseln, Bedingung für Kauf Protofactor (Chef 26.10., 19:41, B) | E Technik | M | – | Tom | gebaut |
| 348.13 | Tusche nach Licht wie entschieden (Chef 26.10.) | E Technik | M | –; +53,33 $ | Tom | Chef |
| 348.13a | Rückfrage: Kampfort Tusche alt oder nach Licht | G Aussehen | M | 30,71 $ | Tom | startbar |
| 353a | Rückfrage: Loch in den Kronen vor dem Helden in den nächsten Build? | G Stil | M | – | Team Tom | Chef |
| 355 | Kisten: zwei bis vier je Gebietskarte, gern versteckt (Chef 24.10., 17:17) | E Welt | K | – | Team Tom | ruht |
| 356.2 | Sammelaufträge: Felle 3, Pelzumhang, Hauerdolch (356 b, Chef 24.10., 21:33) | G Balance | K | – | Team Tom | offen |
| 357 | Puppe beim Drehen nicht fein (Chef 24.10.) | E Figuren | K | – | Team Tom | ruht |
| 344.2 | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | E Kampf | K | – | Team Jerry | offen |
| 366 | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | M Markt | M | –; +25,65 $ | Sokrates | offen |
| 384 | Kosten: alle Sitzungen gebucht? Lücken und Buchungen ohne Kennung (Chef 27.10., 20:06) | B Werkzeuge | M | – | Perikles | gebaut |
| 383.3 | Zurückgestellte Vorlagen sofort aus der Chefsache (Chef 27.10., 19:55) | B Werkzeuge | M | – | Perikles | gebaut |
| 385 | Protofactor-Animsets (Zauberer u. a.) auf die Listen, Probe ob nutzbar (Chef 27.10., 20:59) | E Figuren | M? | – | Sokrates | Chef |
| 383.2 | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | B Werkzeuge | M | – | Sokrates | wartet |
| 383.1 | Kein Neustart nur wegen Warten auf den Chef (Chef 27.10., 19:19) | B Werkzeuge | M | 2,01 $ | Perikles | erledigt |
| 383 | Wartewächter und Haken 63 verschärfen (Chef 27.10., 17:53 ja); Sitzungsgröße messen (Sokrates) | B Werkzeuge | M | 12,91 $ | Perikles | wartet |
