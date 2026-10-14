# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARBEIT-ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 81**

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom 0.1.728** (Sammelbuild 27l Licht am Fuß, Pfützen weich, Nähte weg, 77.1 Leiste; PR #58): [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38518119453/artifacts/11872409132), Prüfliste `e/t728.html` auf „Dein Zug“.

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
| 27 | Wald „Ort fertig“ (Liste in `DESIGN-ABNAHME.md`) | Tom | `ccr-e4144697-7oy67j` | **27l ja** (Nutzer 14.10., 07:2x, Beschlüsse): Licht für stehende Dinge am Fuß messen (`WorldScreen.kt`, alle Karten, Jerry zur Kenntnis), erst Entwurf mit Standbildern vorher/nachher; Pfützen weich, Nähte weg (alle drei in PR #58). **27m ja** (Nutzer 14.10., 09:1x, Beschlüsse): Wald geht 6 Reihen über den Rand weiter und läuft ins Dunkel aus; Entwurf `claude/tom-27m-rand` fest eingebaut (Schalter weg, 14.10., 09:19), offen: Bildrate messen, mehr Bäume, Standbilder aller Ränder (unterbrochen für 69e, Nutzer 09:2x); **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise) |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b/30.8 auf `main`. Offen: Abstürze beobachten (bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 bewusst gelassen (Merkliste) |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); Spieldauer zählt Diogenes (38g, Zeile unten); 38h Eichung durch Nutzer später |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Plot Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | Kapitel 2: Rahmen, Station 1 und 2 (Rabenschanze), Figuren ja ([Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)). Station 3 Kultlager ja (Nutzer 14.10., 09:3x: 5a, 5c–5f ja, 5b noch nicht; Storyplan). Station 4 Aschfurt 6a–6f ja (Nutzer 14.10., 09:3x/09:4x; Storyplan). Weiter: Texte Kapitel 2 |
| 72 | Profil und Marktvergleich: Mittelweg Rollenspiel/Kampf prüfen, Profil schärfen | Berater mit Nutzer | `main` (Notizen) | Auftrag Nutzer 13.10. (Sprachmodus); [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig (18:5x); mit Wirtschaft, SWOT, Porter, Positionierungskarte; offen 72a–72j (Profil, Kampf, Wunden, zweiter Weg, Schmied, Gruppenkämpfe, Preis, Unterstützerpaket, Beschleuniger, iOS) |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | `claude/tom-73-laeden` | Bis 62r auf `main` (PR #53, #55). 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Kapitel 1 frei, Vollversion, nie Werbung/Beutekisten/Wartezeiten). **45b zurückgestellt** bis nach Messung 38. Verlauf im Archiv |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`), Wegweiser `[67.schild]` in `STORY-K1-W.md`; Form `DESIGN-STIL.md` „Zwischensequenzen“. Bildentwurf gemalt mit 69 auf `claude/tom-69-intro` (Figuren Platzhalter), hängt an **69e** |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | `claude/tom-69-intro` | 69a–69d ja (`STORY-K1.md` `[69.intro.…]`). **69e neu (Nutzer 14.10., 09:3x):** „Ausgangspunkt muss unsere Welt in der Diagonalansicht sein“, Schild rechts; Szene aus der Dorfkarte aufbauen, Standbild Diagonalansicht daneben, auch an Sokrates. Auftrag war (14.10., 09:1x, ersetzt B/C): dieselbe Szene zweimal, beide farbig in unserer Welt: (1) präzise an der Grafik der Diagonalwelt, (2) leicht abstrahiert, malerische Stimmung; Tusche entfällt. Stimmung deines ersten Entwurfs behalten (Nacht, Mond, Sterne), an die echten Orte angebunden, volle Auflösung ohne Pixelkorn; Ich-Perspektive oder Bild ohne den Helden (er ist wählbar, nie im Bild), andere Figuren erlaubt; Figuren an Umriss und Merkmal; Tempel 25–30 Leute, zwei Fenster am Altar. Regeln in `DESIGN-STIL.md` „Richtung“ und „Zwischensequenzen“ |
| 70 | Zwischensequenzen: Bildsprache für alle Kapitel festlegen (Nutzer 14.10., 08:00: „das ist unser Stil … muss jetzt wirklich stimmig sein“) | Berater mit Nutzer; Tom (Probebilder 69e) | `main` (Notizen) | Entschieden 14.10. (Beschlüsse, Regeln in `DESIGN-STIL.md`): 70.1 Musterbild nach den Probebildern; 70.2, 70.4 ja; 70.3 leises Leben nach der Stilwahl im Test-Build; Blickwinkel, leichte Abstraktion. Offen: Stilwahl am Probebild. **70.2 und 70.5 ja** (Nutzer 14.10., 09:3x): Aussehen wiederkehrender Leute und einmaliger Monster nur in `LISTE-FIGUREN.md`; Tom und Jerry bauen und malen danach (neu: Rowena Krug, Morwen Kräuterbündel, Gwenna Ring an der Schnur) |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Nutzer 14.10., 08:34: „genau angelehnt an der Diagonalwelt“; Befund Standbild 60i: hell, grobes Pixelkorn, Wiese mit Wölkchen) | Berater mit Nutzer; Jerry (Bilder) | – | Nur Aussehen (Farben, Licht, Formen; Nutzer 14.10., 09:08), Ansicht bleibt bei 72b. Erst aktuelles Standbild (Jerry ab Fr.), dann Entwurf nach dem Musterbild aus 70.1; Aufbau des Kampfes (Gegner vorn, Held von hinten) gehört zu 72b |
| 80 | Kaels angesengte Laterne neben seiner Haustür im Dorf (Nutzer 14.10., 09:4x: „dann sollte die aber auch da sein“; Aussehen `LISTE-FIGUREN.md`, Spur zu Aschfurt 6d) | Tom | – | Heute nicht im Spiel: Kaels Hütte hat nur Tür und Text `[73b.kael]`. **Tom:** Laterne (alt, angesengt, mit Familienzeichen) schon in Kapitel 1 neben die Tür stellen, Standbild auf „Dein Zug“; Kael selbst erst in Kapitel 2 |
| 77 | Dokumentnamen ordnen, Story-Kennungen K1-H/N/Z/W (Nutzer 13.10., 21:10) | Tom (Code), Berater (77e) | `main` | **Umbenannt 13.10., 22:0x**, Wächter in `notiz.sh`. Codekommentare angepasst (Tom, Zweig `claude/tom-d1-raeume`). **77e umgebaut 13.10., 22:5x** (Sokrates, [Entwurf](https://claude.ai/code/artifact/13e3b53a-e28d-40c1-9d94-30225272d38a)): Spieltexte jetzt in `STORY-K1.md`, `STORY-K1-W.md`, `STORY-BLENDE.md` (Marken `[24.…]`); Übergaben Diogenes/Sokrates oben in ihrer ROLLE-Datei; Standbilder zusätzlich als PNG-Datei (`CLAUDE.md`). 77e.3 erledigt 14.10. (Vorgaben in `LISTE-IDEEN.md` „Kapitel 2“ neu gefasst). **77.1** (Tom, nächster Sammelbuild): Leiste über der Karte noch dunkelblau ohne Goldlinie, nach 60 schwarz mit dünner Goldlinie unten: gebaut auf `ccr-e4144697-7oy67j` (e4cddf6a), berührt `WorldScreen.kt` nur in `HudChip` (Jerry zur Kenntnis) |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Jerry (Klang); Tom für Dorf und Räume | – | Berater 13.10., 19:4x: Mangel gegen bestehende Regel, kein Beschluss nötig. **Verdacht** erst bestätigen; Böden je Untergrund (Gras, Erde, Holz, Stein) |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung), Szenen wie Sitzen am Tisch | Tom | – | 55.1a/b und 55.2 (Borin sitzt am Tisch) auf `main`. Kampf geprüft 14.10.: Held 2 m (Dress, wächst mit der Größe), Skelett ebenso; Kobold (80 cm) ~0,9 m; **55d** so lassen (Nutzer 14.10., 07:0x, Beschlüsse). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry | – | Nutzer 12.10., 15:4x nach Test 0.1.587: Krogg fürs Erste so lassen, später alle Kampfanimationen gesamt überarbeiten. Nach Kapitel-1-Wichtigem. Dazu: Rudelwölfe beißen ins Leere (gemeldet 08.10., v0.1.210; Vorschlag im Archiv) |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (14.10., 09:52) – an Nachfolger
- **PR #58** abonniert, grün, wartet auf Test 0.1.728; nach „passt“: zusammenführen, `CHANGELOG.md`, `t728` von „Dein Zug“, „Jetzt installieren“ leeren.
- **69e** (Zweig `claude/tom-69-intro`, `BRUECKE69E=1`, `tools/preview/.../BridgeProbe.kt`): Brücke Feld für Feld aus der Dorfkarte, Diagonalansicht daneben; auf „Dein Zug“, Sokrates benachrichtigt. Wartet auf Wahl (1)/(2); danach Musterbild 70.1 und übrige Intro-Bilder genauso aus der Karte.
- **27m** (Zweig `claude/tom-27m-rand`, Rand fest eingebaut, gepusht): Standbilder aller Ränder und Bildrate erst nach Ja des Nutzers (er hatte sie abgebrochen). Dann **80** Kaels Laterne.
- **Nutzer 09:3x:** erst kurz antworten, dann höchstens etwa 5 Minuten am Stück arbeiten (unter „Für den Berater“).
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

- **Antwortzeit** (Tom, 14.10., 09:36, Nutzer: „es kann nicht sein, dass ich dir was schreibe und du dann eine halbe Stunde weiterwurschtelst“): Vorschlag Regel in `CLAUDE.md`: auf jede Nachricht zuerst ein, zwei Sätze Antwort, dann arbeiten; Arbeitsschritte höchstens etwa 5 Minuten, dazwischen Stand melden.
