# Offen

Nur was gerade **in Arbeit**, **zu testen** oder **zu entscheiden** ist. Gibt es nur auf `main`; Tom und Jerry tragen sofort ein und pushen (Regeln in `CLAUDE.md`). **Höchstens etwa 15 KB:** je Eintrag höchstens 3 Zeilen, je Person genau eine Übergabe (die neue ersetzt die alte, die alte wandert nach [Archiv](ARBEIT-ARCHIV.md)), getestete Builds raus (Ergebnis in die Änderungshistorie).

**Nächste freie Themennummer: 83**

**Ford: Co-Pilot** (Nutzer 14.10., 16:02; 81g; Stellung aus / Co-Pilot / Pilot, Startlektüre `ROLLE-FORD.md`)

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom Sammelbuild 0.1.732** (5.5, 27m.1–27m.5; PR #60, Zweig `claude/tom-5-5-dorf-luecken`): [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38554145752/artifacts/11889780000), Prüfliste `e/t732.html` auf „Dein Zug“. Nach „passt“: PR #60 zusammenführen, `CHANGELOG.md`, t732 und `e/5-5.html` von „Dein Zug“, hier leeren.

- **Tom Sammelbuild 0.1.733** (82, 52, 80a, D1.5/D1.10/D1.11; PR #61, Zweig `claude/tom-d1-schatten`, nach t732 testen): [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38576807017/artifacts/11902500727), Prüfliste `e/t733.html`. Nach „passt“: PR #61 zusammenführen, `CHANGELOG.md`, t733 von „Dein Zug“, hier leeren.

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](LISTE-IDEEN.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](DESIGN-STIL.md) · [Umgebung](ARBEIT-UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](ARBEIT-SELBST.md) · [Themen](LISTE-THEMEN.md): eine Zeile je Nummer · [Archiv](ARBEIT-ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 82 | Verschlossene Tür: Held verschwand beim Anklopfen hinter der Hauswand (Nutzer 14.10., 15:5x, Pims Haus); alle Zugänge | Tom | `claude/tom-d1-schatten` | Behoben (f088ebd0): Tür mit Bedingung zählt beim Laufen als Wand, Dagegenlaufen klopft an; gilt für alle bedingten Zugänge außer Umkehr am Kartenrand; Kerntest. Kommt in den nächsten Sammelbuild |
| 81 | Teamleiter „Ford“: hält Tom und Jerry beschäftigt, meldet dem Nutzer Entscheidungen, startet Sitzungen (Nutzer 14.10., 13:09) | Berater mit Nutzer | `main` (Notizen) | Beschlossen 81a–c, 81g–n (Beschlüsse/Archiv; Telegram-Push und Routinen in `ROLLE-FORD.md`). Co-Pilot seit 16:02; Pilot und drei Nächte Bewährung (81i) erst auf Zuruf; Jerry-Ford ab Fr. [Entwurf Ford](https://claude.ai/code/artifact/ff3ae8ab-a448-4a79-b928-3a09f424b45c) |
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2:** Jerry pausiert seine acht Weck-Routinen „Jerry Selbstarbeit HH:MM“ (`update_trigger`, `enabled: false`, nicht löschen; `ARBEIT-SELBST.md`). Regeln in `CLAUDE.md` |
| 13e | Höhle „Ort fertig“ (Vertretung Jerry, Nutzer 14.10., 16:0x) | Tom | `claude/tom-13e-hoehle-fertig` | Reihenfolge (16:1x): 1 D1.5 Höhlenschatten, 2 D1.9 Feuer durch Wände, 3 D1.15 Licht ohne Quelle, 4 D1.6 Eingang (Standbild zuerst) → Sammelbuild; danach 5 D1.7 Leben (Vorschlag mit Standbild). Jetzt 1 |
| 13 | Diagonale Sicht | Tom | `claude/tom-73-laeden` | 13t auf `main` (PR #54). Verlauf im Archiv |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | `claude/tom-5-5-dorf-luecken` | Auf `main` bis 5la. **5.5** Marktstand und Fahrspuren auf dem Zweig (`e/5-5.html`); Lichtfleck Ost kein Fehler |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | **26c:** (1) 24.8.6/30.8, (2) 42, (3) Diagonalsicht erledigt (auf `main`), ebenso 55.2 und 17; Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (Liste in `DESIGN-ABNAHME.md`) | Tom | `claude/tom-5-5-dorf-luecken` | 27l/27m auf `main` (PR #59). **27m.1–27m.5** in PR #60 (t732). **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise) |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | 30.1/30.2/30b/30.8 auf `main`. Offen: Abstürze beobachten (bei neuem Absturz `adb logcat` mit Anleitung von Tom); 30.7 bewusst gelassen (Merkliste) |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x mit Bildschirmfoto (Wiese, alte Kampfansicht). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); Spieldauer zählt Diogenes (38g, Zeile unten); 38h Eichung durch Nutzer später |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Texte Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | Plot Kapitel 2 fertig (5b noch nicht; [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d)). Texte: [Entwurf](https://claude.ai/code/artifact/3dfb1fb7-3230-41aa-8c9e-a1ae94c5c413) beim Nutzer zur Prüfung; offen 4.4, 5.3, 6.3. Rask, Fenn ja |
| 72 | Profil und Marktvergleich | Berater mit Nutzer | `main` (Notizen) | [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig. **72b Kampfsystem neu** (Nutzer 16:09: innovativ, griffig, SRD darf weichen): [Kampfsystem](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4), Rückfragen 72k–72n beim Nutzer; **72.5 zweiter Weg ja** (16:09). Offen sonst 72a, 72c–72j (Profil, Kampf, Wunden, zweiter Weg, Schmied, Gruppenkämpfe, Preis, Unterstützerpaket, Beschleuniger, iOS) |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | Entschieden 13.10. (Beschlüsse): „Alle“ beim Kaufen weg, beim Verkaufen mit Abfrage (in 0.1.660). Vorrat je Laden erst mit 38/39, nie nach Zeit/Rast, Menge nach Schwierigkeitsgrad |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | `claude/tom-73-laeden` | Bis 62r auf `main` (PR #53, #55). 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Kapitel 1 frei, Vollversion, nie Werbung/Beutekisten/Wartezeiten). **45b zurückgestellt** bis nach Messung 38. Verlauf im Archiv |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`), Wegweiser `[67.schild]` in `STORY-K1-W.md`; Form `DESIGN-STIL.md` „Zwischensequenzen“. Bildentwurf gemalt mit 69 auf `claude/tom-69-intro` (Figuren Platzhalter), hängt an **69e** |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | `claude/tom-69e-musterbild` | 69a–69d ja (`STORY-K1.md` `[69.intro.…]`). **69e vierte Runde** (`e/69e-4.html`, Vorschau `BRUECKE69E=1`): Sokrates ja als Musterbild für Blick, Stoffe, Licht ; die drei Korrekturen sind eingebaut (Tom 14:33: Laterne auf dem Pfosten am Ufer, Mond frei, beide Geländer ab Ufer); Nutzer entscheidet. Danach 70.3 |
| 70 | Zwischensequenzen: Bildsprache für alle Kapitel (Nutzer 14.10., 08:00) | Berater mit Nutzer; Tom (Probebilder 69e) | `main` (Notizen) | Entschieden 14.10. (Beschlüsse, Regeln `DESIGN-STIL.md`): 70.1 Musterbild nach 69e; 70.2, 70.4, 70.5 ja (Aussehen nur in `LISTE-FIGUREN.md`); 70.3 leises Leben nach der Stilwahl im Test-Build |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Nutzer 14.10., 08:34: „genau angelehnt an der Diagonalwelt“; Befund Standbild 60i: hell, grobes Pixelkorn, Wiese mit Wölkchen) | Berater mit Nutzer; Jerry (Bilder) | – | Nur Aussehen (Farben, Licht, Formen; Nutzer 14.10., 09:08), Ansicht bleibt bei 72b. Erst aktuelles Standbild (Jerry ab Fr.), dann Entwurf nach dem Musterbild aus 70.1; Aufbau des Kampfes (Gegner vorn, Held von hinten) gehört zu 72b |
| 80 | Kaels angesengte Laterne neben seiner Haustür im Dorf (Aussehen `LISTE-FIGUREN.md`) | Tom | `claude/tom-80a-sockel` | 80a gebaut (Sockel mit Zeichen A, nachts Bernsteinlicht), **passt** (Nutzer 14.10., 15:5x, Beschlüsse); kommt in Toms nächsten Sammelbuild |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Tom (Vertretung für Jerry, Nutzer 14.10., 13:3x) | `claude/tom-74-schritte` | Hörprobe auf „Dein Zug“ (`e/74.html`, 13:4x): Kenney CC0, je 3 Fassungen Gras, Erde, Pflaster, Holz, Stein (`tools/klang/schritte.py`, Quellen Runde 5). Nach „passt“: einbauen (nur Held), Untergrund je Feld. Danach aus Jerrys Vorrat 7 Ausgleich Magier, 5 Rudelwölfe; Jerry übernimmt ab Fr. |
| 55 | Mehr Leerlauf für alle Leute (Waffe, Armhaltung), Szenen wie Sitzen am Tisch | Tom | – | 55.1a/b und 55.2 (Borin sitzt am Tisch) auf `main`. Kampf geprüft 14.10.: Held 2 m (Dress, wächst mit der Größe), Skelett ebenso; Kobold (80 cm) ~0,9 m; **55d** so lassen (Nutzer 14.10., 07:0x, Beschlüsse). Verlauf im Archiv |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry; Rudelwölfe Tom (Vertretung) | `claude/tom-52-rudel` | Krogg so lassen, später alle gesamt (Jerry). **Rudelwölfe beißen ins Leere** behoben, **passt** (Nutzer 14.10., 15:5x, Beschlüsse); kommt in Toms nächsten Sammelbuild |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Angelegt 13.10. (Link oben), Regel in `CLAUDE.md`. Offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (14.10., 16:0x) – an Nachfolger
- PR #60 (t732) und #61 (t733) abonniert, Prüflisten auf „Dein Zug“ (Nachfolger 16:1x).
- **Dann Vertretung Jerry (Nutzer 16:0x: „prüfe, was anliegt und wichtig ist, auch wenn es bei Jerry liegt“):** Ziel Kapitel 1 fertig (`LISTE-KAPITEL1.md`). Wichtigster Brocken: **Höhle „Ort fertig“** (13e liegt seit 13y bei Tom): D1.5 Höhle (alte 3:1-Bodenschatten doppelt, Rautenschatten `MapCaveIso.kt:474` → Ellipse), D1.9 Feuer klingt durch Wände, D1.6 Eingang flach/schwarzes Rechteck, D1.15 Laterne ohne Quelle, D1.7 Leben. Jerrys Zweig `claude/jerry-13e-hoehle-diagonal` ist alt (ohne gemeinsame Basis mit `main`), nur als Vorlage für 13e.4 (Stalagmiten, Weiher). Erst Liste mit Reihenfolge dem Nutzer nennen, dann bauen. Offen bei Jerry außerdem 36.6, 51, 53, 40 (Regler), 24.6.
### Jerry (12.10., 16:59; gekürzt 77e) – Pause bis Freitag, 03:00

- **Startauftrag Berater (76–78, 13.10., 22:0x), vor allem anderen:** (1) Notizen umbenannt, `CLAUDE.md` neu; deine Startlektüre steht jetzt in `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“), bitte ganz lesen. (2) Im Zweig `claude/jerry-13e-hoehle-diagonal` (und jedem anderen) zuerst `git merge origin/main`. (3) Ab jetzt Sammelbuilds (höchstens 4 Punkte, Zweig höchstens 1 Tag, nie mit Tom gemischt) und „(Rückläufer: n)“ im `CHANGELOG.md`. Sonst nichts zu tun.
- Pause bis Fr., 03:00 (Guthaben); Selbstarbeit beendet. Tom vertritt nicht von sich aus, nur wenn eigene Arbeit an Jerrys Themen hängt. Ab Fr. weiter mit 24.6, 36.6, 38–40, 51–53; 13e liegt seit 13y bei Tom; Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Einzelheiten im Archiv).
## Zu testen

- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5 Schatten Höhle (Figurenschatten `WorldArt.shadow()` ist jetzt 2:1 auch für Monster, Tom 14.10.), D1.6 Höhleneingang flach, D1.7 Leben Höhle, D1.8 stumme Quellen, D1.9 Feuer durch Wände, D1.10 erledigt (Tom 14.10.: Klangschleife in `WorldScreen.kt` ruft `PlaceSound.folk`, drei Zeilen; Schänke ohne Zufalls-Wischen), D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (zwei Stücke mit Hörnern/Kreaturenrufen ohne sichtbare Quelle, `grund_fs_609422`, `grund_fs_540836`): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (19:44): Höhle mit und ohne die zwei Stücke auf die Seite „Dein Zug“, erst danach ändern; D1.15 Laterne.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `ROLLE-TESTER.md`. **B** und **C** erledigt (Lauf 1 und 2, 13.10.); **A** erst, wenn Toms Wald- und Dorfzweige auf `main` sind (Nutzer 18:24).
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.
- **26 Ausgleich Magier** (Tom für Jerry, 14.10., 13:4x, Simulation `ChapterSimTest`, 400 Kämpfe): Siege gegen Grak Stufe 5 Kämpfer 92 %, Kleriker 88 %, Schurke 82 %, Magier 45 % (mit vorher gewirkter Magierrüstung 69 %). Vorschlag: SRD-Zauber **Schild** als selbsttätige Reaktion (+5 RK bis zum nächsten Zug, 2 ZP): Magier 87 % mit Rüstung, 78 % ohne (Stufe 6: 93/85 %); Entwurf `claude/tom-26-magier-schild` (im Spiel aus). Nebenbefund: Bosse auf Stufe 5–6 für alle über dem Ziel 50–65 % (38). → Rückfrage **26d** (Sokrates 15:03, im Gespräch): Schild ja, selbsttätig mit Schalter „Schild bereit“ (Standard an); nach Boss-Anpassung (38) neu messen. **Zurückgestellt** (Nutzer 16:02): gehört zur Grundsatzfrage Kampf (72b, Marktvergleich), dort mit besprechen; Idee Sokrates: mit sichtbarer Absicht (72.2) wirkt der Spieler Schild selbst im eigenen Zug, keine Automatik.


