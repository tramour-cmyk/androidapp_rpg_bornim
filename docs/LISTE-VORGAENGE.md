# Vorgänge

Eine Zeile je Vorgang (113), für den Überblick und die Kosten. **Wird beim Start nicht gelesen**; eine Nummer gezielt suchen mit `python3 tools/vorgang.py <Nr>` (alle Orte, 275). Wer einen Vorgang anlegt, trägt hier Bereich und Klasse ein (der Zähler „Nächste freie Vorgangsnummer“ steht in [Betrieb](ARBEIT-BETRIEB.md)); wer ihn abschließt, setzt den Stand. Stand nur aus der Wortliste (275; prüft `regelcheck.py`): offen, startbar, in Arbeit, wartet, Chef, ruht, gebaut, zu testen, Dauer, nach Meilenstein, aufgeteilt, Idee, erledigt; Einzelheiten im Vorrat. Unterpunkte (z. B. 13q.4) gehören zum Vorgang ihrer Nummer.

- **Bereich** (124): Hauptthema **E** Entwicklung (Welt, Figuren, Kampf, Klang, Oberfläche), **G** Gestaltung (Story, Stil, Balance), **Q** Qualität (QS, QM), **B** Betrieb (Steuerung, Abläufe, Werkzeuge), **M** Markt (Beratung, Veröffentlichung); Tabelle in `FIRMA.md`.
- **Kl.** (126): **M** Muss (im Wochenziel oder „jetzt“ des Chefs), **K** Kür, „–“ abgeschlossen. Stand der Zuordnung: 16.10., erstes Wochenziel 18.–24.10. (`LISTE-ABNAHME-KAPITEL1.md`).
- **Kosten** in $ (`usage.cost_usd`, Summe ab 17.10.): trägt Ford bzw. Ford 2 beim Neustart ein (`LISTE-BETRIEB.md`); „fehlt“, wenn die Zahl nicht zu bekommen war.

| Nr. | Vorgang | Bereich | Kl. | Kosten | Vorrat | Stand |
|---|---|---|---|---|---|---|
| Betrieb | Läufe von Ford und Ford 2 | B Steuerung | – | Ford 37,38 $, Perikles Vorratsdurchsicht 1,90 $; Sokrates 18.10. 5,60 $; Ford 2 16,79 $; Probe Pro Mittel 17.10. 0,00 $; +739,17 $ | Ford | laufend |
| 19 | Zeitablauf der Kampfbewegungen (19e Beispiel) | E Kampf | K |  | Jerry | ruht |
| 24 | Animationen fehlen nach Start/Kartenwechsel; Zwischenbildschirm für Orte und Kämpfe | E Oberfläche | K |  | Jerry (Inhalt; Technik Tom erledigt) | ruht |
| 26.1 | Durchspielbogen auswerten, Rest von 26: Gegenprobe je Klasse, neuer Bogen auf Godot (Chef 24.10., 16:56) | Q QS | M | – | Sokrates | wartet |
| 30 | Abstürze beim Testen | Q QS | K |  | Tom (Jerry: Klang-Fäden) | ruht |
| 38 | Balance-Langzeitplan (`DESIGN-BALANCE.md`) | G Balance | M | 11,51 $ | Jerry | ruht |
| 39 | Schwierigkeitsgrad im Menü | E Kampf | M | 3,80 $ | Jerry (Menü mit Tom) | ruht |
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
| 86 | Bewegung und Übersicht: Ausdauer, Rennen, Rast, Kartenzeichen | E Kampf | K | 0,72; 1,21 $; +1,81 $ | Jerry | ruht |
| 99 | Zwei Niederlassungen | B Steuerung | K | 7,25 $ | Perikles | ruht |
| 102 | Dokumente BornWire TCS nachziehen | B Abläufe | K |  | Ideen | Idee |
| 109 | Repo öffentlich | M Veröffentlichung | M |  | Sokrates | ruht |
| 111 | `DESIGN-BLENDE.md` kürzen (nach 24.6) | B Abläufe | K |  | Ideen | Idee |
| 133 | Wahlen im Spiel: vier Charisma-Wahlen in Kapitel 2 (Chef 19.10. ja) | G Story | K | 1,12 $ | Tom, Jerry | ruht |
| 134 | Leute mit Neuem: Ausrufezeichen und Mikrogesten (Idee Chef) | E Figuren | K | 1,06 $ | Tom | aufgeteilt |
| 142 | Vorbereitung Pflichttest Play Store (Konto, Datenschutz) | M Veröffentlichung | M | 13,47 $ | Sokrates | Chef |
| 142.2 | Pflichttest erst mit Bekannten, Webseite später (Chefsache) | M Veröffentlichung | M |  | Sokrates | wartet |
| 142.3 | Tester öffentlich suchen (Chef 27.10., 19:32) | M Veröffentlichung | M | – | Sokrates | in Arbeit |
| D23.3 | Magier und Kleriker sterben oft (Lauf 23) | G Balance | M |  | Jerry | ruht |
| Woche | Wochenzählung der Kennzahlen | Q QM | K |  | Diogenes | offen |
| 145 | Karten je Kapitel zum Drucken | E Welt | K | 6,22 $ | Tom | ruht |
| 167.6 | Morgenbericht mit Kennzahlen und Kostenbilanz (Chef 18.10.) | B Steuerung | M | 2,29 $ | Sokrates | Termin |
| 168.1 | Umsetzung 168: Garrick fest in Kapitel 2, Söldner ab Kapitel 3 (Texte Homer) | G Story | K |  | Jerry | nach Meilenstein |
| 72u.1 | Umsetzung 72u: Kampfort aus der Karte (Standbild 2, Bau) | E Kampf | K | 2,38 $ | Jerry | ruht |
| 186.3 | Ausgefüllte Prüfbögen auswerten | Q Qualität | K |  | Diogenes | wartet |
| 212 | Kampfsystem wählbar: MARS oder klassisch, Schalter in den Einstellungen (Chef 19.10. A) | G Balance | M | 0,61 $ | Jerry | ruht |
| 217 | Wölfe (Grimmzahn, Rudelwolf) beißen im Kampf teils in die Luft, nach Süden am Helden vorbei (Chef 19.10.) | E Kampf | M | 3,24 $ | Jerry | ruht |
| 211.14 | Rest 211.13: Leistung A56, Puppen-Gegner im Kamerawinkel, Winkel je Platz, Wechsel als Gang | E Kampf | M? | – | Jerry | ruht |
| 246 | Dokumente grundsätzlich ins Repo statt als Artefakt; Wochenplan aktualisiert (Chef 20.10.) | Q Ablauf | K | –; +7,03 $ | Sokrates | entschieden |
| 246.1 | Übrige Artefakte ins Repo (außer Geschäftsmodell, Markt, Preise), nach dem Meilenstein | Q Ablauf | K | – | Sokrates | offen |
| 249 | MARS wie der klassische Kampf: Gleiten, Hiebe, Zoom, Blut, Effekte, Zustände (Chef 20.10.) | E Kampf | M | –; +33,41 $ | Jerry | ruht |
| 253 | BornWire (vorher WireStorm): Firmensachen BornWire TCS in eigener Sitzung, Kosten hierauf (Chef 20.10.) | M Markt | K | – | Sokrates | ruht |
| 257 | Build 46: Meldung „App reagiert nicht“, warten oder schließen, läuft dann weiter (Chef 20.10.) | E Technik | M | – | Jerry | offen |
| 262 | API-Credits im Plan: wofür nutzen? (Chef 20.10.) | B Betrieb | K | – | Sokrates | ruht |
| 263 | Rolle für Finanzen und Geschäftszimmer? (Chef 20.10.) | B Betrieb | K | – | Sokrates | Dauer |
| 365 | Aufwand „Hoch“ statt „Mittel“ für einzelne Rollen? (Chef 25.10., 12:36) | B Betrieb | M | –; +4,65 $ | Sokrates | Probe |
| 264 | Arbeitsorte neben GitHub: NAS, Proxmox, ALL-INKL? (Chef 20.10.) | B Betrieb | K | – | Sokrates | Chef |
| 267 | Spiel ruckelt auf dem Tablet (Chef 20.10., Build 48) | E Technik | M | –; +13,77 $ | Tom | ruht |
| 270 | Perikles und Diogenes auf das große Modell (Chef 21.10.) | B Betrieb | M | –; +4,16 $ | Perikles | wartet |
| 275 | Zentrale Vorgangsliste als einzige Quelle (Chef 21.10.; Stufe 1 jetzt, 27.10.) | B Werkzeuge | M | 27,62 $ | Perikles | wartet |
| 276 | Fords Anleitung auf eine Seite (Empfehlung Sokrates zu 274) | B Abläufe | K | – | Perikles | offen |
| 283.1 | Hohes Gras sichtbar höher als ein Feldweg, stimmige Welt (Chef 21.10.) | G Stil | K | – | Ideenspeicher | offen |
| 284 | Bis zum Durchspielen (26) am Kampf nur Fehlerbehebung, kein Feinschliff (Vorschlag Sokrates) | B Vorrang | M | – | Sokrates | entschieden |
| 289 | MARS: Wechsel „halber Zug“ missverständlich; Bewegung und Aktion im Kästchen zeigen? (Chef 21.10., 20:11) | E Kampf | K | – | Jerry | ruht |
| 292.2 | Hauptmenü: vier Figuren größer, schärfer, mit gelegentlicher Bewegung je Klasse (Chef 21.10., 22:28); Stufe 1 mit 292, Bewegung nach 284 | E Oberfläche | M | – | Team Tom | ruht |
| 292.4 | Hauptmenü B am Feuer: Feuerlicht, Animation, Klang (aus 292.3 zurückgestellt, Chef 22.10., 15:10) | G Stil | K | – | Team Tom | ruht |
| 296 | Checkliste je großem System (MARS zuerst): umgesetzt, offen, was zwischen klassisch und MARS fehlt (Chef 22.10., 07:50) | B Abläufe | M | –; +2,98 $ | Sokrates | Vorlage |
| 296.1 | Erste Fassung Checkliste MARS (`LISTE-MARS.md`) gegen den Code prüfen und pflegen | E Kampf | K | – | Team Jerry | neu |
| 296.2 | MARS spielnötig: Beute/Erfahrung, Fliehen, Eröffnung, Zustände, eigene Ausrüstung, Schalter (Chef 23.10., 18:25) | E Kampf | M | –; +12,97 $ | Team Jerry | ruht |
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
| 338.1 | Stand zum Marktstart: jeden Montag eine Seite für den Chef, Ampel je Block (Chef 23.10., 09:01: Stand wird ihm nie vorgelegt) | B Abläufe | M | 26,69 $ | Perikles | gebaut |
| 376 | Quaternius-Bausätze (Dorf, Natur, Dungeon, Outfits) und gedrehte Häuser prüfen (Chef 27.10., 12:00) | E Welt | M | 38,96 $ | Sokrates | wartet |
| 376.1 | Probeblatt Quaternius-Figuren mit Bewegungsraster als Film (Chef kaufte 27.10., 12:20) | E Figuren | M | 221,15 $ | Team Tom | wartet |
| 376.2 | RenderHub-Marktpaket: Brunnen, Stände als Form (Chef 27.10., 12:37) | E Welt | M | – | Team Tom | wartet |
| 374 | Wer prüft regelmäßig, dass alle 373 einhalten? (Chef 27.10., 11:54) | B Abläufe | M | 17,69 $ | Perikles, Diogenes, Sokrates | wartet |
| 372 | Feinschliff Held am Ende des Umzugs: Kettenhemd, Helm, Kragen (aus 338a B, Chef 27.10., 09:36) | E Figuren | M | – | Team Tom | ruht |
| 341 | Zielvereinbarung Perikles bis zum Marktstart: sechs messbare Ziele, geprüft von Werkzeug und Diogenes (Chef 23.10., 09:39) | B Abläufe | M | – | Perikles | Dauer |
| 304 | Klassischer Kampf: Konter nach Abwehr, obwohl getroffen, regeltechnisch richtig? (Chef 22.10., 13:22) | E Kampf | M | – | Team Jerry | ruht |
| 344 | Fackel: brennt überall außer in hellen Grundrissen; Kampf mit der Fackel nach SRD (Chef 23.10., 16:05) | E Welt | M | – | Sokrates | entschieden |
| 347 | Paket „Regeltreue erhöhen, Kosten senken“ (Zähler, Kernregeln, kleiner Start) prüfen und umsetzen (Chef 24.10., 16:20) | B Abläufe | M | –; +15,42 $ | Sokrates | entschieden |
| 347.2 | Umsetzung Plan 347 nach Gegenprüfung (Chef 24.10., 16:30) | B Abläufe | M | – | Perikles | wartet |
| 348 | Fertige Spiel-Engine statt Selbstbau: Umzug nach Godot (Chef 24.10., 16:43) | E Technik | M | –; +115,14 $ | Sokrates | in Arbeit |
| 348.1 | Vergleichsbild Gebietskarte alt/neu, 64 (heute) und 128 je Kachel (Chef 24.10., 16:51, „jetzt“ 16:54) | E Technik | M | – | Team Tom | raus |
| 348.2 | Tusche nach Licht auch am Helden, Innenlinien an Bäumen: zweites Vergleichsbild jetzt (Chef 24.10., 17:30, 17:36) | E Technik | M | – | Team Tom | ruht |
| 348.6 | Umzug Godot: Fundament, Dorf als erste Gebietskarte | E Technik | M | 640,45 $ | Team Tom | zu testen |
| 348.7 | Umzug Godot: Modellregel, Kampfort Wolfsrudel MARS | E Technik | M | –; +441,15 $ | Team Jerry | ruht |
| 348.7a | Rückfrage: Geschosse flach oder in 3D | E Technik | M | 58,17 $ | Jerry | in Arbeit |
| 348.9 | Umzug Godot: Arbeitsteilung, Meilenstein, Modelle jetzt (Chef 25.10., 12:24) | B Abläufe | M | 119,56 $ | Perikles, Diogenes | wartet |
| 348.12 | Fertige CC0-Grundmodelle prüfen, Probe Mensch (Chef 25.10., 21:21, 21:36) | E Technik | M | 186,48 $ | Sokrates, Jerry | wartet |
| 348.12c | Modellpaket auch gegen Geld (Quaternius QAL, Dungeon Monsters Kit, andere), Vorschlag mit Preisen (Chef 26.10., 11:59) | G Geld | M | –; +9,24 $ | Sokrates | ruht |
| 348.12f | Probe gekaufte Riesenratte in unserem Look | E Technik | M | 199,50 $ | Jerry | gebaut |
| 348.12g | Gekaufte Monster (Ghul, Untote) zur Geschichte passend? | G Story | M | 4,29 $ | Homer | entschieden |
| 348.12i | Kaufmodelle mit `AESContext` verschlüsseln, Bedingung für Kauf Protofactor (Chef 26.10., 19:41, B) | E Technik | M | – | Tom | gebaut |
| 348.13 | Tusche nach Licht wie entschieden (Chef 26.10.) | E Technik | M | 89,13 $ | Tom | startbar |
| 348.13a | Rückfrage: Kampfort Tusche alt oder nach Licht | G Aussehen | M | 30,71 $ | Tom | gebaut |
| 348.13b | Tusche auch nach Fackeln, Feuer, Fenster; zuerst Dorf (Chef 28.10., 08:09 ja) | G Aussehen | M | – | Tom | ruht |
| 355 | Kisten: zwei bis vier je Gebietskarte, gern versteckt (Chef 24.10., 17:17) | E Welt | K | – | Team Tom | ruht |
| 356.2 | Sammelaufträge: Felle 3, Pelzumhang, Hauerdolch (356 b, Chef 24.10., 21:33) | G Balance | K | – | Team Tom | offen |
| 357 | Puppe beim Drehen nicht fein (Chef 24.10.) | E Figuren | K | – | Team Tom | ruht |
| 344.2 | Kampf mit der Fackel: Feuerschaden, Verscheuchen, beide Systeme (Chef 23.10., 18:27) | E Kampf | K | – | Team Jerry | ruht |
| 366 | bornwire.de: Abschnitt „Stand“ und „Tester gesucht“ (Chef 25.10., 18:39) | M Markt | M | –; +25,65 $ | Sokrates | offen |
| 391 | Zweit-Repo dauerhaft in den Sitzungen, ohne Ablehnung (Chef 28.10., 09:21) | B Werkzeuge | M | – | Sokrates | ruht |
| 397 | Ruhebewegungen wie im alten Spiel, mindestens drei je Figur, für alle (Chef 28.10., 11:15) | E Figuren | M | 19,54 $ | Team Tom, Team Jerry | gebaut |
| 398 | Gegenprobe: Grundsätze aus DESIGN-Dateien, die im Umzug nach Godot fehlen (Chef 28.10., 11:22) | B Umzug | M | 12,07 $ | Sokrates | wartet |
| 399 | Spielbare Godot-Fassung zuerst: Dorf begehbar, Kampf spielbar; Feintuning ruht (Chef 28.10., 12:34) | B Umzug | M | 12,45 $ | Perikles, Team Tom, Team Jerry | wartet |
| 399.1 | Spielfassung: eine APK mit Dorf, Laden, Rast, Weg in den Wald, Kampf, zurück (aus 399) | B Umzug | M | 124,12 $ | Team Tom | zu testen |
| 399.5 | Innenräume wie alt: Lichtquellen, Licht und Schatten, Einrichtung; Fenster außen wie innen (Chef „jetzt“ 28.10., 21:5x) | B Umzug | M | 51,75 $ | Team Tom | zu testen |
| 399.2 | Kampfort als aufrufbare Szene für die Spielfassung 399.1 (aus 399) | B Umzug | M | 40,83 $ | Team Jerry | zu testen |
| 399.2b | Rudel allein: drei von vier Klassen verlieren; Ursache prüfen, Balance an Chef (aus 399.2a) | E Kampf | M | 16,00 $ | Team Jerry | erledigt |
| 399.2d | Godot am Rechner freigeben (Auto-Modus lehnte Download ab), Tests ohne CI-Lauf (aus 399.2) | E Kampf | M | – | Team Jerry | wartet |
| 401 | Lebendige Welt: Laute für jedes Tier im Dorf, mindestens drei je Tier (Chef 28.10., 22:0x) | E Klang | M | 2,67 $ | Team Jerry | erledigt |
| 399.3.1 | Klang: Haken in spiel.gd übernehmen, Klangregler im Menü System (aus 399.3) | B Umzug | M | – | Team Tom | zu testen |
| 385 | Protofactor-Animsets (Zauberer u. a.) auf die Listen, Probe ob nutzbar (Chef 27.10., 20:59) | E Figuren | M | 40,87 $ | Team Tom | ruht |
| 385.2 | Feuer aus der Stabspitze bei Feuerpfeil, Feuerball (aus 385.1, Chef 28.10., 19:1x) | E Kampf | M | 9,99 $ | Team Jerry | ruht |
| 387 | Gekaufte Tiere schnell auf Bewegungen und unsere Haut prüfen, vor Eigenbau (Chef 27.10., 21:27) | E Monster | M | 98,99 $ | Team Jerry | ruht |
| 403 | Kampfort: Held je Klasse auf dem Kaufkörper (heldfigur.gd aus 376.1) statt held.bin, Kampfbewegungen aus der UAL | E Kampf | M | 24,71 $ | Team Jerry | gebaut |
| 468 | Sparplan bis Sa 19:59: Wochenlimit 36 % nach 36 h, halbes Tempo (Chef 02.11., 07:33, Bild Nutzung) | B Abläufe | M | – | Sokrates | Chef |
| 469 | Kampf auf BRS: Ring (MARS) ohne Klassen regeln (aus 406.1, Sokrates 02.11.) | E Kampf | M | – | Team Jerry | wartet |
| 467 | Ausdauer nach BRS statt SRD (ausdauer.gd: Konstitution, Stärke 13), Formel aus 427 (Chef 01.11., 21:52) | E Kampf | M | – | Team Jerry | wartet |
| 470 | Bau BRS 1.1 Erschaffung (Wochenziel 02.11., Stufe 1) | E Regeln | M | – | Team Tom | startbar |
| 470a | Rückfrage: BRS-Held in Stufe 1, Brücke zum SRD-Kampf bis 2.3? | E Regeln | M | – | Team Tom | erledigt |
| 470.1 | Erschaffung: Held auf Antippen bildschirmgroß (Idee Chef 02.11., 18:37) | E Oberfläche | K | – | Team Tom | wartet |
| 478 | Rechenkern des Kampfs in Stufe 1 auf BRS (470a C, Chef 02.11., 17:59) | E Kampf | M | – | Team Jerry | ruht |
| 479 | Projektplan: Abnahmeliste umbenennen, auf Stand bringen, Orte und Welt einzeln, Flüsterwald einplanen (Chef 02.11., 18:34) | B Abläufe | M | – | Perikles | startbar |
| 480 | Angehaltene Filme: klarere Blätter, dritter Lauf ohne Rückfrage (Chef 02.11., 18:43) | B Abläufe | M | – | Sokrates | erledigt |
| 481 | Herkünfte ausgleichen: Kräutersammler mit Kampftränken, Wachsoldat, Klosterschüler, Bewährungsprobe (Chef 02.11., 18:54, aus 427) | E Kampf | M | – | Sokrates, Team Jerry | wartet |
| 482 | Begriff „Blatt“ tilgen (Chef 02.11., 18:57): doppelt, aufgegangen in 480 bei Perikles | B Abläufe | M | – | Perikles | erledigt |
| 483 | Film-Links: jsDelivr liefert aus Zweig „bilder“ nichts mehr (über 50 MB), je Film eine Marke (Chef 02.11., 19:08) | B Werkzeuge | M | – | Sokrates | startbar |
| 484 | Keine Abkürzungen in Telegram-Meldungen; „NW“ für `DESIGN-SPIELSYSTEM-2-0-ENTWURF.md` nicht auffindbar (Chef 02.11., 19:27) | B Abläufe | M? | – | Perikles | startbar |
| 471 | Bau BRS 1.2 Fertigkeiten durch Tun (Wochenziel 02.11., Stufe 1) | E Regeln | M | – | Team Tom | startbar |
| 472 | Bau BRS 1.3 Heldenstufe aus Erfahrung (Wochenziel 02.11., Stufe 1) | E Regeln | M | – | Team Jerry | gebaut |
| 473 | Bau BRS 1.4 Monsterwerte Kapitel 1 (Wochenziel 02.11., Stufe 1) | E Kampf | M | 5,89 $ | Team Jerry | gebaut |
| 474 | Debug-Schlüssel der Godot-Builds aus dem Cache verdrängt, neu 02.11., 05:13 (aus 399.1a, Meldung Tuffy): nächster Build einmal deinstallieren; dauerhaft ohne Cache | E Technik | M? | – | Team Tom | ruht |
| 475 | Leute des Dorfs (Rowena, Borin …) auf Kaufkörper ihres Volks mit Gesicht, statt der alten Figuren (Chef 02.11., 10:52, Build 146: „Kommt da noch was?“) | E Figuren | M? | – | Team Tom | wartet |
| 476 | Symbole der Gegenstände aus den 3D-Modellen statt Pixelbild (Chef 02.11., 14:43) | E Oberfläche | M? | – | Team Tom | wartet |
| 477 | Godot-APKs laufen nicht im MuMu Player am Rechner (Chef 02.11., 14:59) | E Technik | M? | – | Team Tom | startbar |
| 466 | Neues Wort für „Handlung“ eines Pfads (Chef 01.11., 21:13: „Handlung ist alles“) | C Texte | M? | 3,68 $ | Homer | startbar |
| 465 | Chefsache „Zu entscheiden“ mit Uhrzeit in „Seit“ wie bei Anzusehen und Zu tun (Chef 01.11., 20:50) | B Abläufe | M | 2,43 $ | Perikles | startbar |
| 464 | Rote Läufe senken: Haken vor jedem Push, der baut (Skriptprüfung, Tests lokal grün), Zählung im Tagesbericht (Chef 01.11., 20:4x) | B Abläufe | M | – | Perikles | startbar |
| 461 | Grundstand Figuren und Kampf: Checkliste des Entschiedenen, Prüfer prüft jede Vorlage dagegen („jetzt“ 01.11., 20:3x) | B Abläufe | M | 22,37 $ | Perikles | gebaut |
| 463 | Umhang und Robe geschlossen: Durchscheinen und Knie, eine Ursache für alle Proben (Chef 01.11., 20:3x, „DAUERPROBLEM“) | E Figuren | M | 47,02 $ | Team Tom | startbar |
| 461.1 | Grundstand zusammenführen: ein Zweig für Tom und Jerry, jede Probe baut darauf (01.11.) | B Umzug | M | 30,19 $ | Team Tom, Team Jerry | wartet |
| 461a | Rückfrage: hält ein Verstoß gegen den Grundstand den Film an? (D58.5) | B Abläufe | M | – | Perikles | gebaut |
| 461b | Nur Gültiges steht: neu ersetzt alt im selben Commit, Commit-Prüfung, Kennzahl Widersprüche (Chef 01.11., 22:26) | B Abläufe | M | – | Perikles, Diogenes, Sokrates | in Arbeit |
| 461d | Gültige Entscheidungen an einem Ort: Grundstand in die DESIGN-Dateien einsortieren (Vorentscheid Sokrates 01.11., 22:5x) | B Abläufe | M | – | Perikles, Homer | gebaut |
| 464.1 | Befunde D61.1–2 zu 464 nachbessern: Tageszahl roter Läufe im Protokoll, Grenze 25 Dateien mit Hinweis (Diogenes Lauf 59) | B Abläufe | M | 9,74 $ | Perikles | startbar |
| 465.1 | Befund D60.1 zu 465 nachbessern: „Seit“ aus Git statt geschätzter x-Zeit (Diogenes Lauf 58) | B Abläufe | M | – | Perikles | gebaut |
| 462.1 | Befunde D59.1–3 zum Zeitstempel nachbessern: Zwischenmeldungen, Spalte stempel ohne Namen, „<Name>“ (Diogenes Lauf 57) | B Abläufe | M | – | Perikles | gebaut |
| 461.2 | Befunde D58.1–5 zum Grundstand nachbessern: E1, F6, G2/C2/E3, Gehen aufrecht, Tor vor dem Versand (Diogenes Lauf 56) | B Abläufe | M | – | Perikles | gebaut |
| 460 | Kamerafahrten im Kampfort: Eröffnung wie Drohnenflug je Blende, Wechsel der Perspektive ohne Eingabe; erst Probefilm (Chef 01.11., 20:2x) | E Kampf | M | – | Team Jerry | wartet |
| 406.1 | Schildstoß im MARS: Reaktion oder Konter am Ring, vielleicht Angriff; Regelvorschlag, dann Bau (Chef 01.11., 20:2x) | E Kampf | M | – | Team Jerry | wartet |
| 406 | Ausrüstung der Helden je Stück als eigenes Modell mit Abnahme, „noch steril“ (Chef 28.10., 23:0x, Archiv 376.1 Klassenentwürfe); zuerst Rundschild des Klerikers hell mit goldener Sonne wie alt | E Kampf | M | 105,51 $ | Team Jerry | zu testen |
| 407 | Probelauf-Grenze 389 greift nicht: neue Runde erst nach Urteil des Chefs, jeder Zweig zählt („jetzt“ 29.10., 10:05) | B Abläufe | M | – | Perikles | gebaut |
| 410 | Waffen am Körper wegstecken, alle Waffenarten (aus 376.1, Chef 29.10., 10:52, 11:40) | E Figuren | M | – | Team Tom | ruht |
| 415 | Handyprobe Beams-Free-Sample (aus 414, Chef 31.10., 20:3x; „jetzt“ 01.11.) | C Kampf | M | 25,59 $ | Team Jerry | wartet |
| 415c | Rückfrage: Strahlenprobe Lauf 181 am Tor angehalten, Film trotzdem oder zwei neue Läufe? | C Kampf | M | – | Team Jerry | erledigt |
| 416.2 | Platzwechsel mit Dorfbewohnern und Tieren, nicht stecken bleiben (Chef 31.10., 20:4x) | B Umzug | M | – | Team Tom | wartet |
| 416.4 | Rennen des Helden wirkt wie Hochsprung (Chef 31.10., 20:4x) | B Umzug | M | 41,57 $ | Team Tom | wartet |
| 416.6 | Spuren des Helden, auch bei Regen (Chef 31.10., 20:4x) | B Umzug | K | – | Team Jerry | wartet |
| 417 | Prüfung: Waffen und Schild beim Gehen und Rennen in der Hand statt auf dem Rücken (zu 410, Chef 31.10., 21:1x) | E Figuren | M | 181,99 $ | Team Tom | Chef |
| 423.1 | Spielerhandbuch BRS als Seite im Spiel, Platzhalter aus der Datendatei (Archiv 423) | A Technik | M? | – | Team Tom | wartet |
| 427 | Bestiarium: je Monsterart Name, Gebiet und Stufenband, Verhalten, Angriffe und Waffen, Werte für Spielsystem 2.0, Beute; Aussehen verweist auf `LISTE-FIGUREN.md` (Chef 31.10., 21:3x) | D Design | M | 4,47 $ | Sokrates | Chef |
| 431 | Völker als Modelle: erst Bibliothek sichten (408), Kandidaten drehend im Film vorlegen, dann Körperbau je Volk (Chef 31.10., 22:0x) | E Figuren | M | 33,23 $ | Team Tom | in Arbeit |
| 431c | Rückfrage: Völker Runde 4 am Tor angehalten, neue Läufe frei? | E Figuren | M | – | Team Tom | Chef |
| 431d | Rückfrage: Völker Lauf 3 am Tor angehalten (B1 Elf, C3, G3, A1/A3 Grak, A2), neue Läufe frei, Weg A2? | E Figuren | M | – | Team Tom | Chef |
| 431e | Rückfrage: Gesicht des Helden im Dorflicht fast weiß, Hauteichung nach Messung? | E Figuren | M | – | Team Tom | Chef |
| 432 | Eigenes Volk aus Bornim (etwa mit dem Grauen Propheten, „Tag der Asche“) prüfen, mit der Geschichte ab Kapitel 2 (Chef 31.10., 22:0x) | C Texte | K | 0,79 $ | Homer | wartet |
| 432.2 | Aschgeborene: Grundwerte und Merkmal (Chef 02.11., 16:29) | E Regeln | M? | – | Sokrates | erledigt |
| 432.3 | Aschgeborene: Abnahmeliste in LISTE-FIGUREN, Erschaffungstext (Chef 02.11., 16:29) | C Texte | M? | – | Homer | startbar |
| 434 | Prüfung: jede Vorlage zu einem Eigenbau hat die Zeile „Bestand geprüft“ (377, 408); fehlt sie, an Team und Chef (Chef 31.10., 22:1x) | B Abläufe | M | 4,45 $ | Diogenes | wartet |
| 438 | Wölfe im Kampf wirken gleitend: Angriff, Tempo, Vorbeigehen (Film 403, Chef 31.10., 23:31) | E Kampf | M | 104,30 $ | Team Jerry | gebaut |
| 439 | Kampfablauf: Neuformation vor dem Tod, Treffer vor dem Angriff (Film 403, Chef 31.10., 23:31) | E Kampf | M | – | Team Jerry | gebaut |
| 440 | Wolf verschwindet ohne sichtbare Sterbeanimation (Film 403, Chef 31.10., 23:34) | E Kampf | M | – | Team Jerry | gebaut |
| 453 | Wölfe im Kampfort: Ruhebewegungen (atmen, scharren, umblicken, knurren) (Chef 01.11., 11:05) | E Kampf | M | 47,52 $ | Team Jerry | gebaut |
| 453a | Rückfrage: Wolfsatem aus der Kampfkamera sichtbar machen, A/B/C | E Kampf | M | – | Team Jerry | startbar |
| 453b | Rückfrage: Film Wolfsatem B am Tor angehalten, neue Läufe frei? | E Kampf | M | – | Team Jerry | erledigt |
| 453.1 | Helden im Kampf: Atmen ruhiger, je Figur eigener Takt, nach Aktion schneller und abklingend (Chef 01.11., 13:0x) | E Kampf | M | 9,22 $ | Team Jerry | gebaut |
| 453.1a | Rückfrage: Heldenatem, Film am Tor angehalten (Kleriker), dritter Lauf, A/B/C | E Kampf | M | – | Team Jerry | erledigt |
| 453.2 | Atmen-Schicht für Held unterwegs, Söldner, Leute in Dorf und Innenräumen (Chef 01.11., 13:0x, ganzes Spiel) | E Figuren | M | – | Team Tom | startbar |
| 454 | Wolfsbiss: Achse des Wolfs zielt rechts neben den Helden? messen (Chef 01.11., 11:05) | E Kampf | M | 10,78 $ | Team Jerry | gebaut |
| 455.1 | Probeblatt Baukasten: Roben, Umhänge, Stiefel je Netz × Material × Zeichen (Chef 01.11., 11:24) | E Figuren | M | 30,05 $ | Team Tom | wartet |
| 455.2 | Netzliste je sichtbarem Platz, Eigenbau geschätzt, Größenfilm der Völker (Chef 01.11., 11:27, 455 ja) | E Figuren | M | – | Team Tom | startbar |
| 458.2 | Gegenstandskatalog: Werte, Preise, Beute (Chef 01.11., 458) | D Design | M | 10,87 $ | Team Jerry | gebaut |
| 458.3 | Gegenstandskatalog: Netze, Modelle, Läden (Chef 01.11., 458) | E Figuren | M | 12,15 $ | Team Tom | startbar |
| 447.4 | Texte Lehrmeister-Einladungen und Ruf-Gespräche für Stufe 3 (447) | C Texte | M | 5,57 $ | Homer | Chef |
| 457.1 | Probeskripte Tom mit Spielshadern (457) | E Figuren | M | – | Team Tom | gebaut |
| 457.2 | Probeskripte Jerry mit Spielshadern (457) | E Kampf | M | 5,56 $ | Team Jerry | gebaut |
| 416.7 | Aktionsknopf am Tresen in Schenke und Laden (Chef 31.10., 20:5x) | B Umzug | M | – | Team Tom | wartet |
| 416.8 | NPC dreht sich zum Helden, nach etwa 10 s Leerlauf (Chef 31.10., 20:5x) | B Umzug | M | – | Team Tom | wartet |
| 416.9 | Laden Verkaufen: Reiter bei „angelegt“, Vergleichswerte, nicht tragbare Gegenstände, Icon bei Menge (aus 416.3, Chef 31.10., 22:20) | B Umzug | M | 11,16 $ | Team Tom | startbar |
| 390 | Umzug: Punkte ohne Bilderrunde weiterbauen, solange Blätter beim Chef liegen (Perikles 28.10., Wochenziel 348) | E Technik | M | 39,54 $ | Team Tom, Team Jerry | gebaut |
| 383.2 | Kosten: dieselbe Aufgabe frisch gegen groß messen (Chef 27.10., 19:24) | B Werkzeuge | M | – | Sokrates | wartet |
| 383 | Wartewächter und Haken 63 verschärfen (Chef 27.10., 17:53 ja); Sitzungsgröße messen (Sokrates) | B Werkzeuge | M | 99,45 $ | Perikles | wartet |
