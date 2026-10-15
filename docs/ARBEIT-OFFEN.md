# Offen

Nur was **in Arbeit**, **zu testen** oder **zu entscheiden** ist; nur auf `main` (Regeln in `CLAUDE.md`, auch zur Größe).

**Nächste freie Themennummer: 89**

**Ford: Pilot** (Nutzer 14.10., in Toms Sitzung, eingetragen 22:5x; 81g; Stellung aus / Co-Pilot / Pilot, Startlektüre `ROLLE-FORD.md`; wer die Stellung erhöht, löst Ford sofort einmal aus)

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom Sammelbuild 0.1.746** (83 Hecke, 85, 87; PR #63, Zweig `claude/tom-sammel-83-85-87`): [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38624703687/artifacts/11923257701), Prüfliste `e/t746.html`. Nach „passt“: zusammenführen, `CHANGELOG.md`, Prüfliste von „Dein Zug“.

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](LISTE-IDEEN.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](DESIGN-STIL.md) · [Umgebung](ARBEIT-UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](ARBEIT-SELBST.md) · [Themen](LISTE-THEMEN.md): eine Zeile je Nummer · [Archiv](ARBEIT-ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 86 | Bewegung und Übersicht (Nutzer 14.10., 18:5x) | Tom (86.1, 86.2, 86.4, 86.3 Ausdauer); Jerry (86.3 Keuchen, Lärm, Initiative; 86.11 mit 72b/38) | `claude/tom-86-standort-joystick` | Einzelheiten in den Beschlüssen. **Tom:** 86.1–86.4 gebaut (`Stamina`), nächster Sammelbuild; Jerry zur Kenntnis: etwa 15 Zeilen `WorldScreen.kt`, `GameState.winded`/`stamina`. **Jerry:** Keuchen, Initiative mit Nachteil, Rennen laut (84.4). Beschlossen, Bau offen: 86.6, 86.9, 86.10, 86.11 |
| 87 | Schänke nach Test 0.1.740 (Nutzer 14.10., 20:5x): **87.1** Katze flackert beim Laufen und läuft durch den Tisch vor dem Tresen; **87.2** Rowena wischt in der Luft statt am Tresen (Klang passt, D1.10); **87.3** Borin trinkt ohne Becher (Klang passt) | Tom | `claude/tom-sammel-83-85-87` | Alle drei gebaut (Katzenweg, Tresen auch Thessa, Zinnkrug), PR #63. Jerry zur Kenntnis: eine Zeile `WorldScreen.kt` (`npcPos` ruft `MapFolk.nudge`) |
| 85 | Testmenü aufräumen: alte Einträge, die keiner mehr braucht („irgendwas mit Donnern“; Nutzer 14.10., 18:5x) | Tom (Technik); Jerry prüft seine Einträge | `claude/tom-85-testmenue` | Wetterleuchten-Knopf und „Garrick döst“ entfernt (beide seit 10.10. als vorübergehend markiert); im Sammelbuild PR #63 |
| 81 | Teamleiter „Ford“ (Nutzer 14.10., 13:09) | Berater mit Nutzer | `main` (Notizen) | Beschlossen 81a–c, 81g–n, 81p, 81r (`ROLLE-FORD.md`, `ARBEIT-ABLAEUFE.md` „Neustart“); Ford lebt in „Ford – Teamleiter“, Co-Pilot. Pilot und Bewährung (81i) auf Zuruf; Jerry-Ford ab Fr. **Nutzer:** `TELEGRAM_BOT_TOKEN` in Jerrys Umgebung. Verlauf 81o–81r im Archiv („Aus ARBEIT-OFFEN.md, 15.10., 10:2x (Sokrates, 81)“) |
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2:** Jerry pausiert seine acht Weck-Routinen „Jerry Selbstarbeit HH:MM“ (`enabled: false`, nicht löschen). 65.8/65.9 stehen in `CLAUDE.md`. **65.10** (Nutzer 14.10., 23:1x): Selbstarbeit ist abgeschafft, Ford ersetzt sie; Notizen nachziehen (`CLAUDE.md`-Zeile, `ARBEIT-SELBST.md` ins Archiv, Neustart ohne Nutzer: Übergabe „Nachfolger gewünscht“, Ford startet) |
| 13e | Höhle „Ort fertig“ (Vertretung Jerry, Nutzer 14.10., 16:0x) | Tom | `claude/tom-13e6-dunkler` | D1.5 Truhe auf `claude/tom-d1-5-truhe`, D1.3/D1.11 auf `claude/tom-d1-kerze-gitter`. **13e.6 dunkler:** Entwurf (Schalter `HOEHLEDUNKEL`), Standbilder auf Dein Zug (`e/13e6-2.html`). Helligkeitsregler Jerry mit 40. Danach D1.7 Leben (Absprache `WorldScreen.kt`) |
| 83 | Dorf Süd: Beete, Weizenfelder, Hühner am Südrand (Nutzer 14.10.) | Tom | `claude/tom-83b-huehner` | 83a Hecke in PR #63; 83b Hühner passt; 83c Klang passt bis auf **Scharren**: Hörprobe A/B/C auf Dein Zug (`e/83c-2.html`, `scharren.py`), nach Wahl `scharren.py <ordner> --spiel besen|laub`, sonst bleibt A. Nächster Sammelbuild. Jerry zur Kenntnis |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | – | Auf `main` bis 5.5 |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Tom | – | Auf `main` bis 27m. **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise) |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | Abstürze beobachten (bei neuem `adb logcat` mit Anleitung von Tom); 30.7 Merkliste |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x; erneut 14.10., 21:1x (Test 0.1.741, Alrik liegt mit Brand 2, „sieht immer noch nicht richtig aus“). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); 38g gemessen (Prüfbericht Lauf 4); **D4.1** Stufe 1 vor der Höhle auf Dein Zug (Empfehlung: Quest über Morwen); 38h Eichung durch Nutzer später |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten; **Jerry, 13e.6** Helligkeitsregler auf derselben Einstellungsseite: Abgleich mit Prüfbild („Zeichen gerade noch sichtbar“), hellt die Höhle nicht auf (Wert mit Tom) |
| 41 | Storyplan; Texte Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d) Kapitel 2 fertig (ohne 5b). [Textentwurf](https://claude.ai/code/artifact/3dfb1fb7-3230-41aa-8c9e-a1ae94c5c413) beim Nutzer; offen 4.4, 5.3, 6.3 |
| 72 | Profil und Kampfsystem | Berater mit Nutzer; Jerry (Probe, Bau) | `main` (Notizen) | [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b), [Kampf-Dokument](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4). Beschlossen (Beschlüsse): 72.6, 72.7–72.10 Begleiter, 72r–72t, **72.11** B mit zwei Reihen, **72.12** „Kampfort“, **72.13** (Nutzer 22:1x) Automatik nur „gut“, Halt unter einem Drittel LP, bei starker Absicht, nie bei Bossen, ohne Zauber, Tränke, Gegenstände, Platztausch; Wunden ab Kapitel 2 mit 38; Verschleiß kommt, Feinheiten später mit Berater. **Jerry, 72.10** Probe Held plus Söldner gegen Grak auf dem gemalten Kampfort (drei Absichten, Ring, Reihen, Platztausch, Automatik nach 72.13). **72u** Kampfort aus der Karte: Standbild Grak im Wald (Jerry), Entscheidung nach Probe und Standbild. **72.14** beschlossen: Gefährte (Mensch), Söldner (bezahlt), Begleiter (kein Mensch); **Jerry, Tom:** in Spieltexten so benennen. **72.15** beschlossen (Beschlüsse): Begleiter kämpfen nie (nur Tiermeister-Wolf), Bindung in 4 Stufen, zuerst ein Hund; nicht in Kapitel 2, Bau nach 72.10, Einstieg in die Geschichte mit 41. Offen 72a, 72c–72j |
| 6l | Zoomstufe der Karte | Tom | `claude/tom-6l-zoom` (auf 86) | Gebaut: System-Reiter „Kartenausschnitt: Normal / Näher“ (6,75 / 5,6), gespeichert; Testmenü-Stufen bleiben. Tablet geprüft (gerechnet): quer gleich viel wie Handy, hoch nur 9–11 statt 12–15 Kacheln; kein Hindernis. Nächster Sammelbuild |
| 84 | Licht und Laut (Nutzer 14.10., 17:5x; baut auf Idee 4 in `LISTE-IDEEN.md` und `Perks.kt` auf) | Berater mit Nutzer | `main` (Notizen) | **84.1** Fackel als Gegenstand (Laden, nimmt die Nebenhand); **84.2** Schnellwechsel zweier Handbelegungen; **84.3** Schleichen; **84.4** Lauschen beim Stehen: Welle am Helden zur Quelle hin, Stärke = Deutlichkeit (Nutzer 18:0x), Wort nur bei deutlichem Hören; nicht für Sichtbares; Stufen Stehen > Schleichen > Gehen > Rennen (Nutzer 18:1x: „sehr gut“). Empfehlung im Gespräch 14.10.; Kampfteile mit 72b |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | „Alle“ erledigt (0.1.660). Vorrat je Laden mit 38/39 (Beschlüsse) |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | – | Bis 62r auf `main`; 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Beschlüsse). 45b zurückgestellt bis nach 38 |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`), Wegweiser `[67.schild]` in `STORY-K1-W.md`; Form `DESIGN-STIL.md` „Zwischensequenzen“. Bildentwurf gemalt mit 69 auf `claude/tom-69-intro` (Figuren Platzhalter), hängt an **69e** |
| 69 | Intro: Ankunft bei Nacht in Standbildern, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | `claude/tom-69e-musterbild` | 69a–69e ja (`STORY-K1.md` `[69.intro.…]`, Beschlüsse). Intro und 69e-Welt gebaut (`Intro.kt`, `IntroTest`, Vorschau `INTROBILD=ms`), nächster Sammelbuild; Bilder auf Dein Zug. **Jerry, 69c:** leiser Klang unter Bild 1–4 (`MusicScene.INTRO`). 70.3 später |
| 70 | Zwischensequenzen: Bildsprache für alle Kapitel (Nutzer 14.10., 08:00) | Berater mit Nutzer; Tom (69e) | `main` (Notizen) | Entschieden (Beschlüsse, `DESIGN-STIL.md`): 70.1 Musterbild nach 69e; 70.2, 70.4, 70.5 ja; 70.3 nach Stilwahl im Test-Build |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Nutzer 14.10., 08:34) | Berater mit Nutzer; Jerry (Bilder) | – | Nur Aussehen (Nutzer 09:08); hängt an 72u (Kampfort aus der Karte oder gemalt). Erst Standbild (Jerry ab Fr.), dann Entwurf nach Musterbild 70.1 |
| 74 | Schrittgeräusche fehlen („Ort fertig“ 8; D1.1) | Tom (Vertretung Jerry) | `claude/tom-74-schritte` | Eingebaut (fünf Untergründe, `Footsteps`, `FootstepsTest`); nächster Sammelbuild. Jerry zur Kenntnis: fünf Zeilen `WorldScreen.kt` |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry; Rudelwölfe Tom (Vertretung) | – | Krogg so lassen, später alle gesamt (Jerry). Rudelwölfe auf `main` |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Steht; offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (15.10., 10:2x, „Tom – D1 Kerze und Gitter“)
- **D1.3/D1.11 gebaut** (`claude/tom-d1-kerze-gitter`, d07588cb): Kerze auf dem Herdsims (Laden) mit eigenem kleinem Licht; Höhlengitter drei Formen (Graks Gitter: von Goblins geflickt, Holzpfahl und Seil), Höhlenfackel drei Formen (Halter, Ring am Arm, im Spalt verkeilt). Standbilder geprüft. Jerry zur Kenntnis: 6 Zeilen `WorldScreen.kt` (`drawCaveTorches`). Nächster Sammelbuild.
- **Vorrat:** D1.7 Leben Höhle (Absprache `WorldScreen.kt`). 13e.6 wartet auf Dein Zug (`e/13e6-2.html`), nach „passt“ `MapLight.caveDark` fest an (`caveSeenDim` 0,45), Schalter weg. 83c Scharren wartet.
- **Sammelbuild** erst nach „passt“ zu 0.1.746 (PR #63): 69e-Welt und Intro (`claude/tom-69e-musterbild`), 83b/83c, D1.5 Truhe, 74 Schritte, 86 plus 6l (`claude/tom-6l-zoom` enthält 86), D3 (`claude/tom-d3-wald`), 13e.6, D1.3/D1.11; höchstens 4 Punkte je Build.
### Jerry (12.10., 16:59; gekürzt 77e) – Pause bis Freitag, 03:00

- **Startauftrag Berater (76–78, 13.10.), vor allem anderen:** Startlektüre jetzt `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“) ganz lesen; in jedem Zweig zuerst `git merge origin/main`; Sammelbuilds (höchstens 4 Punkte, nie mit Tom gemischt), „(Rückläufer: n)“ im `CHANGELOG.md`.
- Pause bis Fr., 03:00. Danach 24.6, 36.6, 38–40, 51–53; 13e liegt bei Tom; Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Archiv).
## Zu testen

- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5/D1.6/D1.9/D1.15 Höhle bei Tom (13e); D1.7 Leben Höhle, D1.8 stumme Quellen, D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (`grund_fs_609422`, `grund_fs_540836`, Hörner/Kreaturen ohne Quelle): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (Höhle mit und ohne auf „Dein Zug“), erst danach ändern.
- **Diogenes Lauf 3** (14.10., Prüfbericht, Verdachte, erst bestätigen): **Jerry** D3.1 Türklang ohne Tür, D3.2 Vögel im Tiefen Wald, D3.4 Endlosklänge reißen ab, D3.5/D3.6 Monster, D3.8–D3.10, D3.12; **Tom** D1.3/D1.11-Rest gebaut (`claude/tom-d1-kerze-gitter`); D3.3, D3.5, D3.7, D3.11 bestätigt und gebaut (`claude/tom-d3-wald`, Standbilder und Fackelfilm geprüft; D3.11 erledigt sich mit D3.7: dort steht jetzt das niedrige Schild, verdeckt nur die Füße); nächster Sammelbuild. Jerry zur Kenntnis: drei Zeilen `WorldScreen.kt` (Fackelschein).

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `ROLLE-TESTER.md`. **B**, **C** und **A** Wald/Tiefer Wald erledigt (Lauf 1–3); **A Dorf** nach Toms Sammelbuild 0.1.746.

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.



