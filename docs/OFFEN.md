# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 73**

**Entscheidungsseite (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom 0.1.702** (Zweig `claude/tom-13e-kegelrand`): https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38428809928/artifacts/11829179520 · Prüfliste `e/t702.html`: Höhle Lagerfeuer (13e, Meldung 17:5x), Gebietskarte/Grundrisse im Tuschestil, Schilder (62h/62o/62n); enthält 0.1.693 (**Nutzer 19:2x zu 0.1.693: Höhle mit Licht funktioniert, Gebietskarte passt**). **Nutzer 19:3x:** 62h „passt halbwegs“: im Grundriss Tempel fehlen die zwei Leute (Bild im Chat). Offen in 0.1.702: Lagerfeuer-Raum (13e), Schilder (62n). Nach „passt“ zu 0.1.702: PR, zusammenführen.

Rückfragen und Testfragen an den Nutzer stehen nur auf der Entscheidungsseite (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2** Weck-Routinen (Jerry, Zeile unten). Regeln in `CLAUDE.md` (65.4 ein Ort, 65.7/65.8 kein „Erledigt“); Verlauf im Archiv |
| 13 | Diagonale Sicht | Tom | – | 13.4 auf `main`. **Meldung 08:43:** Tempel-Altar direkt vor dem Fenster, ansehen. **13s/13t ja:** 27, 13 Tempel, 42; dann alte Ansicht ausbauen (13t), danach 6l. Verlauf im Archiv |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | `claude/tom-27-4-baeume` | 5.1/5.2/5g/5h.1 auf `main`. **5m ja:** 27.4, 5.6, 5.3, 5l/5.5, 5.4, dann 27.5/27.6, je erst Standbilder. 27.4, 5.6, 5.3 (alle zwölf), 5n in PR #48. 5.4 (Pflaster-Entwurf, Fensterlicht-Fix) auf dem Zweig. **5la** Tagesablauf (Pim, Bram, Gwenna, Liska) als Entwurf auf `claude/tom-5l-leben`, Build 0.1.640 |
| 13e | Höhle diagonal (Phase 2 von 13); mit 10 (Flammen) und 11 (Lichtstrahl) | Tom | `claude/tom-13e-kegelrand` | Auf `main` (PR #51); Überblenden beim Drehen getestet 0.1.681. Kegelrand/Fels auf `main` (PR #52). **Meldung 17:5x (dritte!):** Raum hinter der Felsstufe am Lagerfeuer dunkel; Ursache Sichtkegel nach Kartenrichtung statt Blick, behoben im nächsten Build. **Meldung 16:3x** (zu viel Schatten hinter der Felsstufe am Lagerfeuer): niedrige Wände lassen Blick und Feuerlicht durch, im nächsten Build. Danach 13t, dann 6l |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. 24.8.6 (Türen 0,5 s) auf `claude/tender-goodall-a8zuny`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`KAPITEL1.md`](KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | **26c ja:** (1) 24.8.6 und 30.8 vom Zweig `tender-goodall-a8zuny` in den nächsten Build, (2) 42, (3) Diagonalsicht fertig (27.5, Tiefer Wald, Tempel-Altar, 27.6); dann 5l, 55.2, 17 |
| 27 | Wald „Ort fertig“ (Liste in `ENTWICKLUNG.md`): vor allem diagonale Zeichnung, Bäume rund | Tom | `claude/tom-27-wald-diagonal` | **13v/27.6 in Arbeit (13.10., 07:3x):** Wald und Tiefer Wald fest diagonal, mit 27.6a–c (ja); Lückenliste „Ort fertig“, Standbilder. 27.1/27.2/27d, 27.4/27.5/27g, 27i, 27j auf `main` (getestet 0.1.625). **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise). Verlauf im Archiv |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b auf `main` (PR #40, getestet 0.1.559). 30.8 „App aktualisiert“ auf `claude/tender-goodall-a8zuny` (kommt mit 26c in den nächsten Build). Offen: Abstürze beobachten (Nutzer 13.10.: seit Langem keine mehr; kein Android Studio, bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 (Klang 22 kHz) mit Jerry. Verlauf im Archiv |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `BALANCE.md` fertig (38a–38d ja). **38e/38f ja (11:23):** Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (Reserve der Selbstarbeit). **38g ja (16:06):** Spieldauer zählt Diogenes (Zeile unten); 38h Eichung mit Uhr durch Nutzer später. Verlauf im Archiv |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nutzer 12.10., 09:52. Nach 38 („Normal“ erst festlegen). **39a ja (10:10):** Leicht/Normal/Schwer über Gegner-TP und -Schaden, jederzeit umstellbar. **62m ja:** auf Leicht Questziele gold ab Annahme; bei der Wahl jeden Unterschied genau erklären |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | Rahmen Kapitel 2 (41a–p), **2a–2d und Station 1 (3a–3e: Kael, Südstraße, Fuhrmann Jorrit, Schilfrode mit/ohne Jorrit) ja (13.10.)**, **Station 2 Rabenschanze (4a–4d: Mauerbruch, Silber aus Aschfurt, Liste „Ring fehlt“, Hauptmann Vesk) ja (19:25)**; Figurenliste um Kapitel 2 mit Bauideen ergänzt (19:4x, Namen von Gwennas Mann, Fährmann, Frau, Händler offen) im [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d), Texte in `docs/STORY.md`. Weiter: Kultlager |
| 72 | Profil und Marktvergleich: Mittelweg Rollenspiel/Kampf prüfen, Profil schärfen | Berater mit Nutzer | `main` (Notizen) | Auftrag Nutzer 13.10. (Sprachmodus); [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig (18:5x); mit Wirtschaft, SWOT, Porter, Positionierungskarte; offen 72a–72j (Profil, Kampf, Wunden, zweiter Weg, Schmied, Gruppenkämpfe, Preis, Unterstützerpaket, Beschleuniger, iOS) |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | `claude/tom-13e-kegelrand` | 62e–62g auf `main`; 62h/62n/62o (Variante 2) und 62p entschieden (Beschlüsse, Begriffe in `CLAUDE.md`), im Spiel ab b6227e35. **Offen:** 62r „Orte“-Knopf weg, Reiter Karte öffnet Ortskarte, Hineintippen tiefer, Knopf oben rechts höher (Frage Beschriftung auf der Entscheidungsseite, Empfehlung Ziel); 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Kapitel 1 frei, Vollversion, nie Werbung/Beutekisten/Wartezeiten). **45b zurückgestellt** bis nach Messung 38. Verlauf im Archiv |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | **68a–68m ja (Nutzer 17:16–18:02):** Ablauf, Texte, Einstieg Kapitel 2 alles in `docs/STORY1.md` (`[68.…]`, auch `[67.schild]`, `[67.nach.…]` entfällt); Form `STIL.md` „Zwischensequenzen“ |
| 70 | Zwischensequenzen einheitlich (Intro 69, Tempel 68, spätere Wendepunkte) | Berater mit Nutzer | `main` (Notizen) | Nutzer 17:08: alle Zwischensequenzen ähnlich gebaut; Muster in `STIL.md` „Zwischensequenzen“ |
| 62q | Begriffe: Landkarte → Gebietskarte → Grundriss → **Ebene** (übereinander im Grundriss; „Stockwerk“ entfällt) | alle | – | **Ja (Nutzer 17:33)**, Regel in `CLAUDE.md` „Begriffe“; Tom/Jerry/Diogenes bitte so in Spiel, Prüflisten und Notizen |
| 67a | Wegweiser am Südrand: „Rabenschanze“, darunter klein „Schilfrode“ | Tom | `claude/tom-13t-alte-ansicht` | **Ja (Nutzer 17:26)**, Text `[67.schild]` in `docs/STORY1.md`; auf dem Zweig (Text beim Antippen zweizeilig), kommt mit 13t |
| 3b | Garrick sitzt links vom Feuer statt rechts, damit man in der diagonalen Sicht seine Bewegungen sieht (jetzt mit dem Rücken zur Kamera) | Tom | – | Nutzer 13.10., 17:10; Kräuterfrau prüft der Nutzer noch |
| 62s | Gebietskarte Dorf: Tippen auf erkundetes Haus (Schild da) öffnet keinen Grundriss; Wald → Höhle geht | Tom | `claude/tom-13e-kegelrand` | Nutzer 19:24 zum Testbuild (vermutlich 0.1.702). Fehler, Zusammenhang mit 62r „Hineintippen tiefer“ |
| 61b | Fußspuren im Tiefen Wald bei der Kräuterfrau, obwohl es nicht regnet | Tom | `claude/tom-13t-alte-ansicht` | Bestätigt: Boden blieb unsichtbar 4 min nass und nahm Spuren an; jetzt 1 min (Commit nach 573e0961), kommt mit 13t |
| 62s | Gebietskarte Dorf: Tippen auf ein erkundetes Haus mit Schild öffnet keinen Grundriss (Höhle im Wald geht) | Tom | – | Nutzer 13.10., 19:3x. Zusammen mit 62o/62r ansehen; ebenso fehlende Leute im Grundriss Tempel |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | – | **69a–69d ja (Nutzer 13.10., 16:31):** Texte, Ablauf und Klang in `docs/STORY1.md` (`[69.intro.…]`), wortgetreu übernehmen |
| 48 | Zufallsgenerierte Dungeons | Berater mit Nutzer; Jerry baut | – | 48a–48c ja (Einzelheiten im Archiv). **48d–48f ja (16:51):** je Spielstand nur Startwert plus **Version des Erzeugers** speichern (Updates verändern keine bestehende Höhle, alte Erzeuger bleiben im Code); Besiegtes und Geplündertes bleibt weg, neuer Auftrag darf dieselbe Höhle neu besetzen. Nach Kapitel 1 |
| 49 | Lehrer, Fertigkeiten, Talente | Berater mit Nutzer | – | 49d–49t ja ([Heldenbau](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)); **Dokument vom Nutzer freigegeben** (13.10., Namen fett markiert); abgelegt als `docs/HELDENBAU.md` (17:1x). Nach Kapitel 1 |
| 50 | Weitere Klassen (Klassenpaket, Werwolf als Fluch) | Berater mit Nutzer | – | 50a–50j ja (Matrix im Heldenbau, Verlauf im Archiv). Nach Kapitel 1 |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung) und Szenen wie Sitzen am Tisch in der Schänke | Tom | – | Nutzer 12.10., 15:5x. **55a ja:** 55.2 zuerst. **55.2 auf dem Zweig** (`SITDRAFT2`, Borin sitzt am Tisch, Sprungtest 0); **55c ja (20:1x):** ins Spiel. **55.1a** Arme verschränkt/Rücken als Entwurf auf `claude/tom-55-leerlauf` (Build 0.1.649). **55.1b B ja (Nutzer 13.10., 10:5x):** Jorin stellt den Speer ab, und Speer überall etwa 2 m (Kampf mitprüfen); auf `claude/tom-17-riemen` |
| 43 | Sichtbarkeit in der diagonalen Sicht (Leute, Ziele, Eingänge frei zur Kamera) | Tom (Wald, Dorf), Jerry (Höhle) | – | **43a ja:** Grundsatz in `STIL.md` („Ort fertig“ Punkt 9); Kisten dürfen versteckt sein. Morwen sichtbar, wenn Tiefer Wald diagonal (Tom); Höhle 13e (Jerry). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry | – | Nutzer 12.10., 15:4x nach Test 0.1.587: Krogg fürs Erste so lassen, später alle Kampfanimationen gesamt überarbeiten. Nach Kapitel-1-Wichtigem |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 56 | Alte Objekte auf den neuen Karten (Nutzer 12.10., 18:3x) | Tom | `claude/tom-27-4-baeume` | **56a–56c ja (19:4x):** Kräuter, Truhe, Steine, Steinkreis, Büsche im Wald ins Spiel (Schalter entfernt, c2b909f7). **56d ja (20:1x):** Dorf (`YARDDRAFT`, `FERNDRAFT`) ins Spiel; Innenräume ohne Altes |
| 63 | Eine Entscheidungsseite für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (13.10., 19:4x) – an Nachfolger
- 0.1.702 (Zweig `claude/tom-13e-kegelrand`) beim Nutzer, Prüfliste `e/t702.html`; nach „passt“ PR, zusammenführen.
- **13t** auf `claude/tom-13t-alte-ansicht` (fbd91a27): gerade Ansicht ganz raus, ~2.500 Zeilen tote Reste gelöscht (Kerntests grün). Bildvergleich Wald/Dorf/Schänke/Höhle vorher/nachher pixelgleich; Build 0.1.703 grün, dem Nutzer noch nicht angeboten: erst nach Merge von 0.1.702 `main` in den Zweig holen, neu bauen, kurze Prüfliste (alle Orte einmal betreten); nach Merge in `UMGEBUNG.md` die Schalter `TOWNDRAFT`, `OVERVIEW`, `MAPS`, `CAVEMAP`, `RAUMDINGE`, `ALTRAUM` streichen.
- 67a (Wegweiser) auf dem 13t-Zweig (573e0961). Nächste freie Punkte ohne Rückfrage: 3b Garrick links vom Feuer (Standbild vorher/nachher), 61b prüfen; 62r bauen, sobald entschieden (Empfehlung Ziel-Beschriftung); danach 6l, 68. Begriffe 62q beachten.
### Jerry (12.10., 16:59) – Pause bis Freitag

- **Nutzer 17:0x:** Nutzungsguthaben fast aufgebraucht, Jerry arbeitet erst ab Freitag weiter; Selbstarbeit beendet (`SELBST.md`: fertig, Weck-Routinen beenden sich von selbst). Tom arbeitet allein weiter; Jerrys Themen (13e, 24.6, 30.7, 36.6, 38, 39, 40, 51–53) ruhen, nichts davon ist dringend.
- Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Einzelheiten im Archiv, 13e jetzt bei Tom).
- **Nutzer 12.10., 18:0x:** Jerry ohne Guthaben bis Fr., 03:00; Tom vertritt nicht von sich aus (genug eigene Arbeit); nur wenn eigene Arbeit an etwas von Jerry hängt, darf Tom das übernehmen (Übergabe hier).
- **13e liegt seit 13.10., 11:2x bei Tom (13y ja);** Jerry macht am Freitag mit 24.6, 30.7, 36.6, 38–40, 51–53 weiter.
## Zu testen

- **Tom, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen; Prüfbericht oben): D1.2 Tempel nachts zu hell, D1.3 Licht/Flamme ohne Gegenstück, D1.4 Wandkram flach, D1.5 Schatten Räume, D1.11 Varianten/Mehrfeld-Möbel, D1.12 Lesepult zu hoch, D1.13 Aldric vor dem Herd, D1.16 Entwurfsschalter.
- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5 Schatten Höhle, D1.6 Höhleneingang flach, D1.7 Leben Höhle, D1.8 stumme Quellen, D1.9 Feuer durch Wände, D1.10 Klang ohne Bewegung (mit Tom), D1.14 Varianten aus einer Aufnahme, D1.15 Laterne.
- **Jerry, Weck-Routinen pausieren** (Berater 13.10., Nutzer freigegeben): deine acht Routinen „Jerry Selbstarbeit HH:MM“ mit `update_trigger` (`enabled: false`) pausieren, nicht löschen; Regel in `SELBST.md` „Feste Weck-Routinen“. Danach Zeile streichen.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/DIOGENES.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `DIOGENES.md`. **B erledigt** (Lauf 1, 13.10.); **A** erst, wenn Toms Wald- und Dorfzweige auf `main` sind (Nutzer 18:24); **C** offen.
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.

- **Diogenes D1.1** (neues Thema?): keine Schrittgeräusche an irgendeinem Ort, obwohl „Ort fertig“ 8 sie verlangt; gilt für alle Orte.
- **Diogenes, Fragen an den Nutzer** (Prüfbericht „Offen für den Nutzer“): Tempelboden Stein statt Holzdielen (Empfehlung ja); Höhlen-Klangbett mit Hörnern/Kreaturen ohne Quelle (D1.14, Empfehlung herausnehmen).


