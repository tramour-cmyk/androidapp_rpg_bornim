# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARBEIT-ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 79**

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- Nichts offen.

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](LISTE-IDEEN.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](DESIGN-STIL.md) · [Umgebung](ARBEIT-UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](ARBEIT-SELBST.md) · [Themen](LISTE-THEMEN.md): eine Zeile je Nummer · [Archiv](ARBEIT-ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2:** Jerry pausiert seine acht Weck-Routinen „Jerry Selbstarbeit HH:MM“ (`update_trigger`, `enabled: false`, nicht löschen; `ARBEIT-SELBST.md`). Regeln in `CLAUDE.md` |
| 13 | Diagonale Sicht | Tom | `claude/tom-73-laeden` | 13t auf `main` (PR #54); Tempelboden Steinplatten in 0.1.714. Verlauf im Archiv |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | – | Auf `main` (27.4, 5.3, 5.4, 5.6, 5n, 5la). Offen 5.5 (prüfen, ob noch etwas fehlt). Verlauf im Archiv |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`, auch 24.8.6 (Türen 0,5 s). **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | **26c:** (1) 24.8.6/30.8, (2) 42, (3) Diagonalsicht erledigt (auf `main`), ebenso 55.2 und 17; Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (Liste in `DESIGN-ABNAHME.md`) | Tom | `ccr-e4144697-7oy67j` | **27l ja** (Nutzer 14.10., 07:2x, Beschlüsse): Licht für stehende Dinge am Fuß messen (`WorldScreen.kt`, alle Karten, Jerry zur Kenntnis), erst Entwurf mit Standbildern vorher/nachher; Pfützen weich (`claude/tom-27-pfuetzen`) mit. Offen sonst: Kartenrand, Nähte; **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise) |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b/30.8 auf `main`. Offen: Abstürze beobachten (bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 bewusst gelassen (Merkliste) |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); Spieldauer zählt Diogenes (38g, Zeile unten); 38h Eichung durch Nutzer später |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | Kapitel 2: Rahmen, Station 1 und 2 (Rabenschanze), Figuren ja ([Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)). Weiter: Kultlager |
| 72 | Profil und Marktvergleich: Mittelweg Rollenspiel/Kampf prüfen, Profil schärfen | Berater mit Nutzer | `main` (Notizen) | Auftrag Nutzer 13.10. (Sprachmodus); [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig (18:5x); mit Wirtschaft, SWOT, Porter, Positionierungskarte; offen 72a–72j (Profil, Kampf, Wunden, zweiter Weg, Schmied, Gruppenkämpfe, Preis, Unterstützerpaket, Beschleuniger, iOS) |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | `claude/tom-73-laeden` | Bis 62r auf `main` (PR #53, #55). 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Kapitel 1 frei, Vollversion, nie Werbung/Beutekisten/Wartezeiten). **45b zurückgestellt** bis nach Messung 38. Verlauf im Archiv |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`), Wegweiser `[67.schild]` in `STORY-K1-W.md`; Form `DESIGN-STIL.md` „Zwischensequenzen“. Bildentwurf gemalt mit 69 auf `claude/tom-69-intro` (Figuren Platzhalter), hängt an **69e** |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Berater (69e); Tom (Bilder, Technik), Jerry (Klang) | – | 69a–69d ja: Texte, Ablauf, Klang in `STORY-K1.md` (`[69.intro.…]`). **69e beim Berater** (Nutzer 14.10., 07:2x: Sokrates prüft auch, ob es ins Gesamtbild passt); Sokrates 14.10., 07:3x: A fällt aus; Vorschlag Probebild Brücke in B fein gemalt und C Tusche wie eine Chronik (Gold nur für Licht), Nutzer wählt danach; Auflagen 69e.1 volle Auflösung, 69e.2 Orte wie auf der Karte (Bach statt See, keine Zypressen), 69e.3 Figuren als Rückenansicht/Schattenriss, 69e.4 Mittelgang im Tempel; wartet auf Nutzer; Entwürfe A (Karte) und B (gemalt, Empfehlung Tom) auf `claude/tom-69-intro`, Seite `e/69e.html` auf „Dein Zug“ (Dateien bleiben) |
| 77 | Dokumentnamen ordnen, Story-Kennungen K1-H/N/Z/W (Nutzer 13.10., 21:10) | Tom (Code), Berater (77e) | `main` | **Umbenannt 13.10., 22:0x**, Wächter in `notiz.sh`. Codekommentare angepasst (Tom, Zweig `claude/tom-d1-raeume`). **77e umgebaut 13.10., 22:5x** (Sokrates, [Entwurf](https://claude.ai/code/artifact/13e3b53a-e28d-40c1-9d94-30225272d38a)): Spieltexte jetzt in `STORY-K1.md`, `STORY-K1-W.md`, `STORY-BLENDE.md` (Marken `[24.…]`); Übergaben Diogenes/Sokrates oben in ihrer ROLLE-Datei; Standbilder zusätzlich als PNG-Datei (`CLAUDE.md`). 77e.3 erledigt 14.10. (Vorgaben in `LISTE-IDEEN.md` „Kapitel 2“ neu gefasst). **77.1** (Tom, nächster Sammelbuild): Leiste über der Karte noch dunkelblau ohne Goldlinie, nach 60 schwarz mit dünner Goldlinie unten: gebaut auf `ccr-e4144697-7oy67j` (e4cddf6a), berührt `WorldScreen.kt` nur in `HudChip` (Jerry zur Kenntnis) |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Jerry (Klang); Tom für Dorf und Räume | – | Berater 13.10., 19:4x: Mangel gegen bestehende Regel, kein Beschluss nötig. **Verdacht** erst bestätigen; Böden je Untergrund (Gras, Erde, Holz, Stein) |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung), Szenen wie Sitzen am Tisch | Tom | – | 55.1a/b und 55.2 (Borin sitzt am Tisch) auf `main`. Kampf geprüft 14.10.: Held 2 m (Dress, wächst mit der Größe), Skelett ebenso; Kobold (80 cm) ~0,9 m; **55d** so lassen (Nutzer 14.10., 07:0x, Beschlüsse). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry | – | Nutzer 12.10., 15:4x nach Test 0.1.587: Krogg fürs Erste so lassen, später alle Kampfanimationen gesamt überarbeiten. Nach Kapitel-1-Wichtigem. Dazu: Rudelwölfe beißen ins Leere (gemeldet 08.10., v0.1.210; Vorschlag im Archiv) |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (14.10., 00:56) – Bericht Selbstarbeit (Vorrat leer, „Bis“ 07:00 nicht gebraucht)
- **Fertig:** Paket 1–4 (Vorgänger: D1.5, D1.16-Rest, Sammelbuild **0.1.721** PR #57 (abgenommen und zusammengeführt 14.10., 07:1x), Prüfliste `e/t721.html`, 27-Lückenliste). Reserve: **55** Speer im Kampf (Held/Skelett 2 m; Kobold ~0,9 m → **55d**); **5.5** Dorf-Lückenliste (unten); **69** Intro als gemalte Nachtbilder + **68** Tempelszene als Entwurf (`claude/tom-69-intro` 05e6b18b, `CutsceneArt`, `INTROBILD=1`; Figuren Platzhalter → **69e**); 27 Pfützen weich als Entwurf (`claude/tom-27-pfuetzen` 86de0cc8, `PFUETZE=1`). Kein Build, nichts zusammengeführt.
- **Lücken** Wald (27, Vorgänger) und Dorf (5.5): Kartenrand gerade schwarze Schräge, Bäume/Kornfeld abgeschnitten; Nähte an Bodenstück-Kanten (`WorldScreen.kt`); Menhire flau mit Kante quer: Bild in Ordnung, Licht auf der Karte nach Bildschirmstelle statt Fuß (**27l**); nachts Kronen hell ums Licht (D1.15, Jerry); Schritte fehlen (74, Jerry).
- **Rückfragen auf „Dein Zug“** (Empfehlung): 55d entschieden (so lassen); 69e gemalte Bilder (B), danach Figuren als Puppen in Augenhöhe; 27l Licht am Fuß messen (`WorldScreen.kt`, mit Jerry). Routinen 03:24/06:24 aus. Nächstes nach Antworten: 69/68 Figuren, 27l, PR #57 nach Test.
### Jerry (12.10., 16:59; gekürzt 77e) – Pause bis Freitag, 03:00

- **Startauftrag Berater (76–78, 13.10., 22:0x), vor allem anderen:** (1) Notizen umbenannt, `CLAUDE.md` neu; deine Startlektüre steht jetzt in `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“), bitte ganz lesen. (2) Im Zweig `claude/jerry-13e-hoehle-diagonal` (und jedem anderen) zuerst `git merge origin/main`. (3) Ab jetzt Sammelbuilds (höchstens 4 Punkte, Zweig höchstens 1 Tag, nie mit Tom gemischt) und „(Rückläufer: n)“ im `CHANGELOG.md`. Sonst nichts zu tun.
- Pause bis Fr., 03:00 (Guthaben); Selbstarbeit beendet. Tom vertritt nicht von sich aus, nur wenn eigene Arbeit an Jerrys Themen hängt. Ab Fr. weiter mit 24.6, 36.6, 38–40, 51–53; 13e liegt seit 13y bei Tom; Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Einzelheiten im Archiv).
## Zu testen

- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5 Schatten Höhle, D1.6 Höhleneingang flach, D1.7 Leben Höhle, D1.8 stumme Quellen, D1.9 Feuer durch Wände, D1.10 Klang ohne Bewegung (mit Tom), D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (zwei Stücke mit Hörnern/Kreaturenrufen ohne sichtbare Quelle, `grund_fs_609422`, `grund_fs_540836`): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (19:44): Höhle mit und ohne die zwei Stücke auf die Seite „Dein Zug“, erst danach ändern; D1.15 Laterne.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `ROLLE-TESTER.md`. **B** und **C** erledigt (Lauf 1 und 2, 13.10.); **A** erst, wenn Toms Wald- und Dorfzweige auf `main` sind (Nutzer 18:24).
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.
- **69e** (Tom, 14.10., 07:2x), Wortlaut Nutzer: „69e übergib das an Sokrates, der soll auch schauen, ob das ins Gesamtbild passt“. Bilder der Zwischensequenzen aus der Karte (A) oder gemalt (B); Seite https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow → `e/69e.html`, Entwurf `claude/tom-69-intro` (`INTROBILD=1`). Tom empfiehlt B.
