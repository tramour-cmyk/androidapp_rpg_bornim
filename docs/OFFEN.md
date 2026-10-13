# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 70**

**Entscheidungsseite (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom 0.1.689** (Zweig `claude/tom-13e-kegelrand`, ersetzt 0.1.681): https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38411397400/artifacts/11822061953 · Prüfliste `e/t689.html`: Höhle Blickrand und Fels weich (13e), Chronik (64), Laternen (66), Südrand (67), noch Kartenschalter (62f aus 0.1.681). Nach „passt“: PR, zusammenführen.

Rückfragen und Testfragen an den Nutzer stehen nur auf der Entscheidungsseite (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](MERKLISTE.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](STIL.md) · [Umgebung](UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](SELBST.md) · [Themen](THEMEN.md): eine Zeile je Nummer · [Archiv](ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 65 | Abläufe verschlanken (Ablaufprüfung, Nutzer 13.10. alle sechs Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | 65.1, 65.3, 65.4, 65.6 fertig. **65.2** Weck-Routinen: Jerry offen (Zeile unten). **65.5** Sprachsitzung bespricht nur, festgehalten erst nach Commit der Textsitzung. **65.4 (Regel in `CLAUDE.md`):** jeder Text an einem Ort. **65.7/65.8 ja (16:14):** Abschnitt „Erledigt“ gestrichen, Entschiedenes und getestete Builds sofort löschen (Regel in `CLAUDE.md`); Berater hat einmal aufgeräumt (64, 62h, 67, 0.1.681 und Erledigt-Liste entfernt). |
| 13 | Diagonale Sicht | Tom | – | 13.4 auf `main`. **Meldung 08:43:** Tempel-Altar direkt vor dem Fenster, ansehen. **13s/13t ja:** 27, 13 Tempel, 42; dann alte Ansicht ausbauen (13t), danach 6l. Verlauf im Archiv |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | `claude/tom-27-4-baeume` | 5.1/5.2/5g/5h.1 auf `main`. **5m ja:** 27.4, 5.6, 5.3, 5l/5.5, 5.4, dann 27.5/27.6, je erst Standbilder. 27.4, 5.6, 5.3 (alle zwölf), 5n in PR #48. 5.4 (Pflaster-Entwurf, Fensterlicht-Fix) auf dem Zweig. **5la** Tagesablauf (Pim, Bram, Gwenna, Liska) als Entwurf auf `claude/tom-5l-leben`, Build 0.1.640 |
| 17 | Nachschwingen: Umhang, Haare, Köcher | Tom | `claude/tom-17-riemen` | 17a auf `main`. 17r (Haare/Köcher) im Build 0.1.660; Riemen verworfen (kaum sichtbar). Fertig mit dem PR des Zweigs |
| 13e | Höhle diagonal (Phase 2 von 13); mit 10 (Flammen) und 11 (Lichtstrahl) | Tom | `claude/tom-13e-kegelrand` | Auf `main` (PR #51); Überblenden beim Drehen getestet 0.1.681. Kegelrand und Fels weich in 0.1.689: Kästchen weg, Blick nach Süden passt. **Meldung 16:3x (Bild, Lagerfeuer, Blick nach Norden über die Felsstufe):** dahinter zu viel Schatten, wird geprüft. Danach 13t, dann 6l |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. 24.8.6 (Türen 0,5 s) auf `claude/tender-goodall-a8zuny`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`KAPITEL1.md`](KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | **26c ja:** (1) 24.8.6 und 30.8 vom Zweig `tender-goodall-a8zuny` in den nächsten Build, (2) 42, (3) Diagonalsicht fertig (27.5, Tiefer Wald, Tempel-Altar, 27.6); dann 5l, 55.2, 17 |
| 27 | Wald „Ort fertig“ (Liste in `ENTWICKLUNG.md`): vor allem diagonale Zeichnung, Bäume rund | Tom | `claude/tom-27-wald-diagonal` | **13v/27.6 in Arbeit (13.10., 07:3x):** Wald und Tiefer Wald fest diagonal, mit 27.6a–c (ja); Lückenliste „Ort fertig“, Standbilder. 27.1/27.2/27d, 27.4/27.5/27g, 27i, 27j auf `main` (getestet 0.1.625). **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise). Verlauf im Archiv |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b auf `main` (PR #40, getestet 0.1.559). 30.8 „App aktualisiert“ auf `claude/tender-goodall-a8zuny` (kommt mit 26c in den nächsten Build). Offen: Abstürze beobachten (Nutzer 13.10.: seit Langem keine mehr; kein Android Studio, bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 (Klang 22 kHz) mit Jerry. Verlauf im Archiv |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `BALANCE.md` fertig (38a–38d ja). **38e/38f ja (11:23):** Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (Reserve der Selbstarbeit). **38g ja (16:06):** Spieldauer zählt Diogenes (Zeile unten); 38h Eichung mit Uhr durch Nutzer später. Verlauf im Archiv |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nutzer 12.10., 09:52. Nach 38 („Normal“ erst festlegen). **39a ja (10:10):** Leicht/Normal/Schwer über Gegner-TP und -Schaden, jederzeit umstellbar. **62m ja:** auf Leicht Questziele gold ab Annahme; bei der Wahl jeden Unterschied genau erklären |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan: je Kapitel Zusammenfassung, Quests, Dialoge; dann Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | 41a–41d ja: Entwurf Kapitel 1 steht ([Dokument](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)), Texte in `docs/STORY.md` (Verzeichnis, Teildateien je Kapitel); Regel „Story und Dialoge“ in `CLAUDE.md`. Kapitel 2: Grobzusammenfassung „Das Graumoor“ im Dokument (15:2x), Grundidee gut (Nutzer 15:28); Kapitel 2 muss im Umfang deutlich mehr bieten als Kapitel 1 (41i), **41j ja (15:58):** 5 Gebiete (Südstraße, Rabenschanze, Schilfrode, Graumoor dreiteilig, Aschfurt mit Katakomben), 3 Zufallshöhlen aus Schilfrode, 5–6 Nebenaufgaben; **41k ja:** Moor bei Nacht gefährlicher, Fähre nur bei Tag; **41l:** kein fester Begleiter, Fuhrmann bis zur Rabenschanze. **41m ja (16:29):** je eine Zufallshöhle pro Landschaft (Steinbruch Südstraße, Lehmhang Schilfrode, Hügelgrab Bruchwald), Aufträge am Aushang Schilfrode ([Karte](https://claude.ai/artifact/LUvNvJofCbNpvv7Rm7zJsu), 16:3x). Offen 41n–41p |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, drei Ebenen (62e–62m) | Tom; 62m Jerry mit 39 | `claude/tom-13e-kegelrand` | 62e–62g im Spiel. **62h ja (Nutzer 16:3x, Beschlüsse):** zweiter Entwurf ins Spiel, derselbe Stil für Ebene 2 und 3 (in Arbeit); **62n/62o ja (16:09, Beschlüsse, Sokrates):** Beschriftung in Textkasten-Schrift/Sepia, Ebene 2 Zeichen statt Hausnamen (ersetzt Handschrift 62g), Höhlenkarte als Skizze mit festem Ausschnitt; erst zwei Standbilder; 62i–62k mit 64; 62l/62m später |
| 64 | Questlog als Reiter „Chronik“ (Aufträge, Bisher geschehen) | Tom; Texte Berater mit Nutzer | `claude/tom-13e-kegelrand` | **Entwurf ja (Nutzer 13.10., 16:08, Beschlüsse):** ins Spiel; Texte aus `docs/STORY1.md` (`[64d.…]`) |
| 66 | Licht im Dorf bei Nacht: Wache Jorin steht im Dunkeln | Tom | `claude/tom-13e-kegelrand` | 66a A (Beschlüsse): zwei Laternen am Schlagbaum, kommt mit 67 in den nächsten Build; Handlaterne auf der Merkliste |
| 67 | Südrand des Dorfes: Feldweg hinter der Brücke, Wegweiser, Umkehr am Kartenrand | Tom | `claude/tom-13e-kegelrand` | **ja (Nutzer 13.10., 16:08):** ins Spiel mit 66 (Zweig `tom-67-suedrand` hineingeführt), kommt in den nächsten Build |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Kapitel 1 frei, Vollversion, nie Werbung/Beutekisten/Wartezeiten). **45b zurückgestellt** bis nach Messung 38. Verlauf im Archiv |
| 68 | Szene im Tempel: Rückkehr des Sonnenamuletts als Abschluss von Kapitel 1 | Berater mit Nutzer (Text); Tom (Szene), Jerry (Klang) | – | Nutzer 13.10., 15:33; Anmerkung 4 im Storyplan; Musik „Ancient Legend“ schon dafür vorgesehen (37). Entwurf im Gespräch |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | – | **69a–69d ja (Nutzer 13.10., 16:31):** Texte, Ablauf und Klang in `docs/STORY1.md` (`[69.intro.…]`), wortgetreu übernehmen |
| 48 | Zufallsgenerierte Dungeons | Berater mit Nutzer; Jerry baut | – | 48a–48c ja (Einzelheiten im Archiv). Nach Kapitel 1 |
| 49 | Lehrer, Fertigkeiten, Talente | Berater mit Nutzer | – | 49d–49t ja ([Heldenbau](https://claude.ai/code/artifact/b8298ae5-2129-4aba-95bf-d262644fdd14)); als `docs/HELDENBAU.md` ablegen, sobald der Nutzer die kursiven Namen durchgesehen hat. Nach Kapitel 1 |
| 50 | Weitere Klassen (Klassenpaket, Werwolf als Fluch) | Berater mit Nutzer | – | 50a–50j ja (Matrix im Heldenbau, Verlauf im Archiv). Nach Kapitel 1 |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung) und Szenen wie Sitzen am Tisch in der Schänke | Tom | – | Nutzer 12.10., 15:5x. **55a ja:** 55.2 zuerst. **55.2 auf dem Zweig** (`SITDRAFT2`, Borin sitzt am Tisch, Sprungtest 0); **55c ja (20:1x):** ins Spiel. **55.1a** Arme verschränkt/Rücken als Entwurf auf `claude/tom-55-leerlauf` (Build 0.1.649). **55.1b B ja (Nutzer 13.10., 10:5x):** Jorin stellt den Speer ab, und Speer überall etwa 2 m (Kampf mitprüfen); auf `claude/tom-17-riemen` |
| 43 | Sichtbarkeit in der diagonalen Sicht (Leute, Ziele, Eingänge frei zur Kamera) | Tom (Wald, Dorf), Jerry (Höhle) | – | **43a ja:** Grundsatz in `STIL.md` („Ort fertig“ Punkt 9); Kisten dürfen versteckt sein. Morwen sichtbar, wenn Tiefer Wald diagonal (Tom); Höhle 13e (Jerry). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry | – | Nutzer 12.10., 15:4x nach Test 0.1.587: Krogg fürs Erste so lassen, später alle Kampfanimationen gesamt überarbeiten. Nach Kapitel-1-Wichtigem |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 56 | Alte Objekte auf den neuen Karten (Nutzer 12.10., 18:3x) | Tom | `claude/tom-27-4-baeume` | **56a–56c ja (19:4x):** Kräuter, Truhe, Steine, Steinkreis, Büsche im Wald ins Spiel (Schalter entfernt, c2b909f7). **56d ja (20:1x):** Dorf (`YARDDRAFT`, `FERNDRAFT`) ins Spiel; Innenräume ohne Altes |
| 59–62, 60j | Händler, ein Aussehen, Spuren, gezeichnete Karte, Menüreiter (Verlauf im Archiv, Entschiedenes in den Beschlüssen) | Tom | `claude/tom-17-riemen` | Getestet bis 0.1.676 (62d ja, 62e, 61, 60j, 5la.3 passen); Jorins Speer beim Abstellen behoben (230c2890), in 0.1.681; nach „passt“ PR |
| 63 | Eine Entscheidungsseite für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (13.10., 16:2x) – vor Neustart
- **Nutzer 16:2x: hat Feedback vom Testen.** Nachfolger fängt keine Arbeit an, sondern wartet nach der Startmeldung auf dieses Feedback (zu 0.1.689) und bespricht es zuerst.
- **0.1.689** (Zweig enthält riemen, 13e, 66, 67, 64; alte Zweige nicht mehr benutzen); 62h-2 danach auf dem Zweig, nicht im Spiel. Nach „passt“: PR (Merge-Commit), Änderungshistorie (59, 60e–k, 60j, 17r, 5la–5la.3, 6g, 6f, 61a, 61, 62a, 62c, 62e–g, 59e, 55.1a/b, 13x, 13v/27.6, 13e weich, Kegelrand, Fels).
- **13t erst nach diesen Merges** (alte Ansicht ausbauen, ~100 Stellen in `WorldScreen`/`core/art`, sonst Konflikte mit 62h/66/67); eigener Zweig von `main`.
- Vorschau-Schalter neu: `UNERKUNDET=1`.
### Jerry (12.10., 16:59) – Pause bis Freitag

- **Nutzer 17:0x:** Nutzungsguthaben fast aufgebraucht, Jerry arbeitet erst ab Freitag weiter; Selbstarbeit beendet (`SELBST.md`: fertig, Weck-Routinen beenden sich von selbst). Tom arbeitet allein weiter; Jerrys Themen (13e, 24.6, 30.7, 36.6, 38, 39, 40, 51–53) ruhen, nichts davon ist dringend.
- Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Einzelheiten im Archiv, 13e jetzt bei Tom).
- **Nutzer 12.10., 18:0x:** Jerry ohne Guthaben bis Fr., 03:00; Tom vertritt nicht von sich aus (genug eigene Arbeit); nur wenn eigene Arbeit an etwas von Jerry hängt, darf Tom das übernehmen (Übergabe hier).
- **13e liegt seit 13.10., 11:2x bei Tom (13y ja);** Jerry macht am Freitag mit 24.6, 30.7, 36.6, 38–40, 51–53 weiter.
## Zu testen

- **Jerry, Weck-Routinen pausieren** (Berater 13.10., Nutzer freigegeben): deine acht Routinen „Jerry Selbstarbeit HH:MM“ mit `update_trigger` (`enabled: false`) pausieren, nicht löschen; Regel in `SELBST.md` „Feste Weck-Routinen“. Danach Zeile streichen.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/DIOGENES.md`).

- **Build 0.1.662 am Stück** (Berater 13.10., Nutzer ja; Nutzer startet): Dorf, Wald, Tiefer Wald, Menü, Laden, Karte bei Tag und Nacht; Fehler und veraltetes Aussehen melden. Höhle (13e) noch nicht, ist Entwurf.
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.

