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
| 86 | Bewegung und Übersicht (Nutzer 14.10., 18:5x) | Tom (86.1, 86.2, 86.4, 86.3 Ausdauer); Jerry (86.3 Keuchen, Lärm, Initiative; 86.11 mit 72b/38) | – | Alle Einzelheiten in den Beschlüssen. **Tom:** 86.1 Testmodus Standort mit Koordinaten, heller; 86.4 Joystick-Empfindlichkeit im Menü; 86.2 A Kartenzeichen in der Leiste; 86.3 Ausdauer (Vorrat, Erholung, Balken). **Jerry:** Keuchen, außer Atem = Initiative mit Nachteil, Rennen laut (84.4). Beschlossen, Bau offen: 86.6 Ausdauertrank, 86.9 Met und Zimmer, 86.10 Rast kostet Zeit (ersetzt `Cmd.Rest`), 86.11 Rast nur an Feuerplätzen, Überfall möglich |
| 87 | Schänke nach Test 0.1.740 (Nutzer 14.10., 20:5x): **87.1** Katze flackert beim Laufen und läuft durch den Tisch vor dem Tresen; **87.2** Rowena wischt in der Luft statt am Tresen (Klang passt, D1.10); **87.3** Borin trinkt ohne Becher (Klang passt) | Tom | `claude/tom-sammel-83-85-87` | Alle drei gebaut (Katzenweg, Tresen auch Thessa, Zinnkrug), PR #63. Jerry zur Kenntnis: eine Zeile `WorldScreen.kt` (`npcPos` ruft `MapFolk.nudge`) |
| 85 | Testmenü aufräumen: alte Einträge, die keiner mehr braucht („irgendwas mit Donnern“; Nutzer 14.10., 18:5x) | Tom (Technik); Jerry prüft seine Einträge | `claude/tom-85-testmenue` | Wetterleuchten-Knopf und „Garrick döst“ entfernt (beide seit 10.10. als vorübergehend markiert); im Sammelbuild PR #63 |
| 81 | Teamleiter „Ford“ (Nutzer 14.10., 13:09) | Berater mit Nutzer | `main` (Notizen) | Beschlossen 81a–c, 81g–n (`ROLLE-FORD.md`). Co-Pilot seit 16:02; Routine in „Voll“ (`trig_013heqXJ1KkkxTYVzmTcpzaf`, :28); Telegram-Weg steht (18:1x). Pilot und Bewährung (81i) auf Zuruf; Jerry-Ford ab Fr. |
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2:** Jerry pausiert seine acht Weck-Routinen „Jerry Selbstarbeit HH:MM“ (`enabled: false`, nicht löschen). 65.8/65.9 stehen in `CLAUDE.md`. **65.10** (Nutzer 14.10., 23:1x): Selbstarbeit ist abgeschafft, Ford ersetzt sie; Notizen nachziehen (`CLAUDE.md`-Zeile, `ARBEIT-SELBST.md` ins Archiv, Neustart ohne Nutzer: Übergabe „Nachfolger gewünscht“, Ford startet) |
| 13e | Höhle „Ort fertig“ (Vertretung Jerry, Nutzer 14.10., 16:0x) | Tom | – | 0.1.741 auf `main` (PR #62); D1.5 Truhe behoben auf `claude/tom-d1-5-truhe`. **Tom, 13e.6 dunkler** (Beschlüsse): abseits sichtbarer Quellen fast schwarz, nur Umrisse; Quellen mit klarem Radius; Held als Umriss mit Saum; kein Heldenlicht (Fackel → 84.1); Standbild vorher. Helligkeitsregler baut Jerry mit 40. Danach D1.7 Leben (Absprache `WorldScreen.kt`) |
| 83 | Dorf Süd: Beete, Weizenfelder, Hühner am Südrand nicht zu sehen (Nutzer 14.10., 17:3x/19:3x) | Tom | `claude/tom-83b-huehner` | Hecke (83a) im Sammelbuild PR #63. **83b** Hühner (`MapHen`, Stil-Abgleich Sokrates erfüllt) und **83c** Klang (Nutzer 22:0x, Tom in Vertretung für Jerry, `HenSound`, alle Proben) gebaut; **83b passt** (Nutzer 22:5x); **83c** (Nutzer 23:2x): Glucksen, Gackern, Flattern alle so; **Scharren passt nicht**, Tom sucht bessere CC0-Aufnahmen, sonst bleibt es. Beides in den nächsten Sammelbuild. Jerry zur Kenntnis |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | – | Auf `main` bis 5.5 |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Tom | – | Auf `main` bis 27m. **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise) |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | Abstürze beobachten (bei neuem `adb logcat` mit Anleitung von Tom); 30.7 Merkliste |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x; erneut 14.10., 21:1x (Test 0.1.741, Alrik liegt mit Brand 2, „sieht immer noch nicht richtig aus“). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); Spieldauer zählt Diogenes (38g, Zeile unten); 38h Eichung durch Nutzer später |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten; **Jerry, 13e.6** Helligkeitsregler auf derselben Einstellungsseite: Abgleich mit Prüfbild („Zeichen gerade noch sichtbar“), hellt die Höhle nicht auf (Wert mit Tom) |
| 41 | Storyplan; Texte Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d) Kapitel 2 fertig (ohne 5b). [Textentwurf](https://claude.ai/code/artifact/3dfb1fb7-3230-41aa-8c9e-a1ae94c5c413) beim Nutzer; offen 4.4, 5.3, 6.3 |
| 72 | Profil und Kampfsystem | Berater mit Nutzer; Jerry (Probe, Bau) | `main` (Notizen) | [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b), [Kampf-Dokument](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4). Beschlossen (Beschlüsse): 72.6, 72.7–72.10 Begleiter, 72r–72t, **72.11** B mit zwei Reihen, **72.12** „Kampfort“, **72.13** (Nutzer 22:1x) Automatik nur „gut“, Halt unter einem Drittel LP, bei starker Absicht, nie bei Bossen, ohne Zauber, Tränke, Gegenstände, Platztausch; Wunden ab Kapitel 2 mit 38; Verschleiß kommt, Feinheiten später mit Berater. **Jerry, 72.10** Probe Held plus Söldner gegen Grak auf dem gemalten Kampfort (drei Absichten, Ring, Reihen, Platztausch, Automatik nach 72.13). **72u** Kampfort aus der Karte: Standbild Grak im Wald (Jerry), Entscheidung nach Probe und Standbild. **72.14** beschlossen: Gefährte (Mensch), Söldner (bezahlt), Begleiter (kein Mensch); **Jerry, Tom:** in Spieltexten so benennen. **72.15** beschlossen (Beschlüsse): Begleiter kämpfen nie (nur Tiermeister-Wolf), Bindung in 4 Stufen, zuerst ein Hund; nicht in Kapitel 2, Bau nach 72.10, Einstieg in die Geschichte mit 41. Offen 72a, 72c–72j |
| 6l | Zoomstufe der Karte | Tom | – | **Tom, 6l beschlossen** (Nutzer 14.10., 22:1x, Beschlüsse): Grundstufe 6,75; im Menü eine Stufe näher (5,6) wählbar und gespeichert (heute setzt jeder Start auf 6,75 zurück, `MapZoom.level`); nie weiter heraus; keine Automatik nach Tageszeit; Stufen im Testmenü bleiben. Vorher prüfen, wie viele Kacheln ein Tablet zeigt |
| 84 | Licht und Laut (Nutzer 14.10., 17:5x; baut auf Idee 4 in `LISTE-IDEEN.md` und `Perks.kt` auf) | Berater mit Nutzer | `main` (Notizen) | **84.1** Fackel als Gegenstand (Laden, nimmt die Nebenhand); **84.2** Schnellwechsel zweier Handbelegungen; **84.3** Schleichen; **84.4** Lauschen beim Stehen: Welle am Helden zur Quelle hin, Stärke = Deutlichkeit (Nutzer 18:0x), Wort nur bei deutlichem Hören; nicht für Sichtbares; Stufen Stehen > Schleichen > Gehen > Rennen (Nutzer 18:1x: „sehr gut“). Empfehlung im Gespräch 14.10.; Kampfteile mit 72b |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | „Alle“ erledigt (0.1.660). Vorrat je Laden mit 38/39 (Beschlüsse) |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | – | Bis 62r auf `main`; 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Beschlüsse). 45b zurückgestellt bis nach 38 |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`), Wegweiser `[67.schild]` in `STORY-K1-W.md`; Form `DESIGN-STIL.md` „Zwischensequenzen“. Bildentwurf gemalt mit 69 auf `claude/tom-69-intro` (Figuren Platzhalter), hängt an **69e** |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | `claude/tom-69e-musterbild` | 69a–69d ja (`STORY-K1.md` `[69.intro.…]`). **69e fertig** (Tom 14.10., 23:0x): Haus links wie im Dorf (Fachwerk, Fenster, Tür, Dach), Laterne und Geländer an der Brücke auch im Spiel (`MapTownIso.BRIDGE_LANTERN`, `bridgeRail`); kommt in den nächsten Sammelbuild. **Tom, Musterbild angenommen** (Nutzer 14.10., 23:1x, „super“; Beschlüsse): übrige Intro-Bilder im selben Stil rendern (`[69.intro.1]`, `.3`, `.4`; 5 schwarz), als ein Satz auf Dein Zug „Anzusehen“, dann Intro bauen ohne neue Entscheidungsrunde; Zeile `e/69e-5.html` dort löschen. 70.3 später |
| 70 | Zwischensequenzen: Bildsprache für alle Kapitel (Nutzer 14.10., 08:00) | Berater mit Nutzer; Tom (69e) | `main` (Notizen) | Entschieden (Beschlüsse, `DESIGN-STIL.md`): 70.1 Musterbild nach 69e; 70.2, 70.4, 70.5 ja; 70.3 nach Stilwahl im Test-Build |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Nutzer 14.10., 08:34) | Berater mit Nutzer; Jerry (Bilder) | – | Nur Aussehen (Nutzer 09:08); hängt an 72u (Kampfort aus der Karte oder gemalt). Erst Standbild (Jerry ab Fr.), dann Entwurf nach Musterbild 70.1 |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Tom (Vertretung für Jerry, Nutzer 14.10., 13:3x) | `claude/tom-74-schritte` | **Eingebaut** (Tom 23:1x): fünf Untergründe je drei Fassungen (`Footsteps`, `step_*.ogg`), ein Klang je Aufsetzen, rennend dichter und leiser; Kerntest `FootstepsTest`. Kommt in den nächsten Sammelbuild. Jerry zur Kenntnis: fünf Zeilen `WorldScreen.kt` in der Laufschleife |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry; Rudelwölfe Tom (Vertretung) | – | Krogg so lassen, später alle gesamt (Jerry). Rudelwölfe auf `main` |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Steht; offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (14.10., 23:2x) – Nachfolger gewünscht
- **Vorrat, in dieser Reihenfolge:** (1) **69** übrige Intro-Bilder im Stil des Musterbilds rendern (`[69.intro.1]` Südstraße, `.3` Dorfplatz mit Fackeln, `.4` Gasthausfenster mit Rowena als Umriss; 5 schwarz), als ein Satz „Anzusehen“ auf Dein Zug mit Stil-Abgleich (88), Zeile `e/69e-5.html` dort löschen; dann Intro bauen. Vorlage `BridgeProbe.kt` auf `claude/tom-69e-musterbild`. (2) **83c Scharren** neu aus echten CC0-Aufnahmen Echte Aufnahme nur auf Freesound (wil_j_wil 571660, CC0, Hühner scharren im Gras, laute Pute; von hier 403, nur von Hand ladbar); Ersatz BigSoundBank CC0: 0163 Strohbesen (Schnitte 2,00–2,32 / 2,73–3,08 / 3,67–4,04 / 8,28–8,60 s), 0137 Füße im Laub (1,70–2,14 / 3,53–3,86 / 5,31–5,61, Hochpass 300 Hz), 0024 Besen. Hörprobe auf Dein Zug; sonst bleibt es. Dann `huehner.py` `--spiel`. (3) Danach 86.1, 86.4, 86.2, 86.3, 6l.
- **Sammelbuild** erst nach „passt“ zu 0.1.746 (PR #63 abonnieren): 69e-Welt, 83b/83c, D1.5 Truhe, 74 Schritte (alle fertig auf ihren Zweigen); Prüfliste mit Hühnern (x 33, y 28) und Brücke nachts (x 18, y 25).
### Jerry (12.10., 16:59; gekürzt 77e) – Pause bis Freitag, 03:00

- **Startauftrag Berater (76–78, 13.10.), vor allem anderen:** Startlektüre jetzt `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“) ganz lesen; in jedem Zweig zuerst `git merge origin/main`; Sammelbuilds (höchstens 4 Punkte, nie mit Tom gemischt), „(Rückläufer: n)“ im `CHANGELOG.md`.
- Pause bis Fr., 03:00. Danach 24.6, 36.6, 38–40, 51–53; 13e liegt bei Tom; Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Archiv).
## Zu testen

- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5/D1.6/D1.9/D1.15 Höhle bei Tom (13e); D1.7 Leben Höhle, D1.8 stumme Quellen, D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (`grund_fs_609422`, `grund_fs_540836`, Hörner/Kreaturen ohne Quelle): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (Höhle mit und ohne auf „Dein Zug“), erst danach ändern.
- **Diogenes Lauf 3** (14.10., Prüfbericht, Verdachte, erst bestätigen): **Jerry** D3.1 Türklang ohne Tür, D3.2 Vögel im Tiefen Wald, D3.4 Endlosklänge reißen ab, D3.5/D3.6 Monster, D3.8–D3.10, D3.12; **Tom** D3.3 Fichtenraster, D3.5 Fackelschein, D3.7 Schilder/Menhire, D3.11 Schild verdeckt Helden.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `ROLLE-TESTER.md`. **B**, **C** und **A** Wald/Tiefer Wald erledigt (Lauf 1–3); **A Dorf** nach Toms Sammelbuild 0.1.746.
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.

- **71, Diogenes Lauf 3, Klasse 2** (Prüfbericht): D3.13 Morwens Hütte fehlt, Texte nennen sie; D3.14 Heldenlicht draußen ohne Quelle (mit 84.1); D3.15 Vögel, Grillen, Eulen ohne Quelle und Entfernung; D3.16 kursiver Erzähltext (42) gegen D2.7.


