# Offen

Nur was **in Arbeit**, **zu testen** oder **zu entscheiden** ist; nur auf `main` (Regeln in `CLAUDE.md`, auch zur Größe).

**Nächste freie Themennummer: 88**

**Ford: Co-Pilot** (Nutzer 14.10., 16:02; 81g; Stellung aus / Co-Pilot / Pilot, Startlektüre `ROLLE-FORD.md`)

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

- **Tom Sammelbuild 0.1.741** (passt bis auf D1.5 Truhe und 13e.6, Nutzer 21:1x; Konflikt mit `main` gelöst, wird nach grünem Build zusammengeführt; Höhle: 13e.5, 13e.6 B, D1.5, D1.9; PR #62, Zweig `claude/tom-13e-hoehle-fertig`): [APK](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/38609455363/artifacts/11916159370), Prüfliste `e/t738.html`.

Nach „passt“ (PR #62): zusammenführen, `CHANGELOG.md`, Prüfliste von „Dein Zug“, hier leeren.

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](LISTE-IDEEN.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](DESIGN-STIL.md) · [Umgebung](ARBEIT-UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](ARBEIT-SELBST.md) · [Themen](LISTE-THEMEN.md): eine Zeile je Nummer · [Archiv](ARBEIT-ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 86 | Bewegung und Übersicht (Nutzer 14.10., 18:5x) | Tom (86.1, 86.2, 86.4); Berater mit Nutzer (86.3) | – | **Tom, 86.1** im Testmodus Standort mit einfachen Koordinaten wie die Bildrate, beide deutlich heller; **86.4** im Menü Empfindlichkeit des Joysticks (ab wann gegangen/gerannt wird) (Nutzer 20:4x); **86.2 A** keine Minimap, Gebietskarte mit einem Tipp sofort auf, ohne Umweg übers Menü (Nutzer 20:5x): Kartenzeichen in der oberen Leiste neben dem Beutel, fingergroße Tippfläche getrennt vom Menü, im Kampf/Gespräch aus, Zeit steht bei offener Karte (Nutzer 21:1x, Beschlüsse). **86.3** Ausdauer beim Rennen: Empfehlung 20:5x (Konstitution, Stärke/Rüstung, Erschöpfung wirkt in den Kampf), Nutzer entscheidet |
| 87 | Schänke nach Test 0.1.740 (Nutzer 14.10., 20:5x): **87.1** Katze flackert beim Laufen und läuft durch den Tisch vor dem Tresen; **87.2** Rowena wischt in der Luft statt am Tresen (Klang passt, D1.10); **87.3** Borin trinkt ohne Becher (Klang passt) | Tom | – | Neu |
| 85 | Testmenü aufräumen: alte Einträge, die keiner mehr braucht („irgendwas mit Donnern“; Nutzer 14.10., 18:5x) | Tom (Technik); Jerry prüft seine Einträge | `claude/tom-85-testmenue` | Wetterleuchten-Knopf und „Garrick döst“ entfernt (beide seit 10.10. als vorübergehend markiert); kommt in Toms nächsten Sammelbuild |
| 81 | Teamleiter „Ford“ (Nutzer 14.10., 13:09) | Berater mit Nutzer | `main` (Notizen) | Beschlossen 81a–c, 81g–n (`ROLLE-FORD.md`). Co-Pilot seit 16:02; Routine in „Voll“ (`trig_013heqXJ1KkkxTYVzmTcpzaf`, :28); Telegram-Weg steht (18:1x). Pilot und Bewährung (81i) auf Zuruf; Jerry-Ford ab Fr. |
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2:** Jerry pausiert seine acht Weck-Routinen „Jerry Selbstarbeit HH:MM“ (`enabled: false`, nicht löschen). 65.8/65.9 stehen in `CLAUDE.md` |
| 13e | Höhle „Ort fertig“ (Vertretung Jerry, Nutzer 14.10., 16:0x) | Tom | `claude/tom-13e-hoehle-fertig` | In 0.1.741 (PR #62, t738); **Befund 21:1x:** Truhe in der Pilzecke ohne sichtbaren Schatten (D1.5); 13e.6 Helligkeit beim Berater; 13e.6 = B (kein Heldenlicht, Fackel → 84.1). Danach D1.7 Leben (Standbild, Absprache `WorldScreen.kt`) |
| 83 | Dorf Süd: Beete, Weizenfelder, Hühner am Südrand nicht zu sehen (Nutzer 14.10., 17:3x/19:3x, t732) | Tom | `claude/tom-83-hecke` | A (Beschlüsse) gebaut: Hecke, Ring ohne hohe Kronen vor Feld/Beet/Heu. **83a** auf „Dein Zug“: Hecke passt? Hühner (heute weiße Punkte aus der alten Ansicht in `WorldScreen.kt`) als richtige Figuren? |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | – | Auf `main` bis 5.5 |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Tom | – | Auf `main` bis 27m. **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise) |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | Abstürze beobachten (bei neuem `adb logcat` mit Anleitung von Tom); 30.7 Merkliste |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x; erneut 14.10., 21:1x (Test 0.1.741, Alrik liegt mit Brand 2, „sieht immer noch nicht richtig aus“). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); Spieldauer zählt Diogenes (38g, Zeile unten); 38h Eichung durch Nutzer später |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten |
| 41 | Storyplan; Texte Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d) Kapitel 2 fertig (ohne 5b). [Textentwurf](https://claude.ai/code/artifact/3dfb1fb7-3230-41aa-8c9e-a1ae94c5c413) beim Nutzer; offen 4.4, 5.3, 6.3 |
| 72 | Profil und Marktvergleich | Berater mit Nutzer | `main` (Notizen) | [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b) fertig. **72b Kampfsystem neu** ([Dokument](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4)): Rückfragen 72k–72o beim Nutzer; Nutzer 16:55: zu kämpferlastig, Attribute sollen wirken, Gedanken folgen; Vorschlag Abstand nah/fern und Attribute im Dokument (17:2x). 72.5 ja. **72.6** Automatik solide, nicht optimal, je Runde abschaltbar (Nutzer 18:3x); Feinheiten 72p. **72q** Gruppe beschlossen (Nutzer 14.10., 19:4x–20:3x, Beschlüsse): **72.7** ein Platz für einen Begleiter (Söldner oder aus der Geschichte), immer auf Automatik schaltbar; **72.8** gefallen = nicht tot, fällt aus, Tempel gegen Gold schneller; **72.9** „Normal“ mit Begleiter gemessen, **72s** ab Kapitel 2 (Story und Begleiter-Figuren mit 41 umbauen); **72.10** Probe Held plus Söldner gegen Grak, Technik gleich in den Umbau, hängt an 72k. **72r** Ausfall in Kämpfen, Richtwert Leicht 1, Normal 3, Schwer 5 (Nutzer 20:3x, wird gemessen). **72t** Söldner in allen vier Klassen frei wählbar, steigen nicht auf; Begleiter der Geschichte steigen mit auf (Nutzer 20:3x). Offen 72a, 72c–72j |
| 84 | Licht und Laut (Nutzer 14.10., 17:5x; baut auf Idee 4 in `LISTE-IDEEN.md` und `Perks.kt` auf) | Berater mit Nutzer | `main` (Notizen) | **84.1** Fackel als Gegenstand (Laden, nimmt die Nebenhand); **84.2** Schnellwechsel zweier Handbelegungen; **84.3** Schleichen; **84.4** Lauschen beim Stehen: Welle am Helden zur Quelle hin, Stärke = Deutlichkeit (Nutzer 18:0x), Wort nur bei deutlichem Hören; nicht für Sichtbares; Stufen Stehen > Schleichen > Gehen > Rennen (Nutzer 18:1x: „sehr gut“). Empfehlung im Gespräch 14.10.; Kampfteile mit 72b |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | „Alle“ erledigt (0.1.660). Vorrat je Laden mit 38/39 (Beschlüsse) |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | – | Bis 62r auf `main`; 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Beschlüsse). 45b zurückgestellt bis nach 38 |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | – | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`), Wegweiser `[67.schild]` in `STORY-K1-W.md`; Form `DESIGN-STIL.md` „Zwischensequenzen“. Bildentwurf gemalt mit 69 auf `claude/tom-69-intro` (Figuren Platzhalter), hängt an **69e** |
| 69 | Intro: Ankunft des Reisenden bei Nacht in Standbildern mit Text, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | `claude/tom-69e-musterbild` | 69a–69d ja (`STORY-K1.md` `[69.intro.…]`). **69e vierte Runde** (`e/69e-4.html`, Vorschau `BRUECKE69E=1`): Sokrates ja als Musterbild für Blick, Stoffe, Licht ; die drei Korrekturen sind eingebaut (Tom 14:33: Laterne auf dem Pfosten am Ufer, Mond frei, beide Geländer ab Ufer); Nutzer entscheidet. Danach 70.3 |
| 70 | Zwischensequenzen: Bildsprache für alle Kapitel (Nutzer 14.10., 08:00) | Berater mit Nutzer; Tom (69e) | `main` (Notizen) | Entschieden (Beschlüsse, `DESIGN-STIL.md`): 70.1 Musterbild nach 69e; 70.2, 70.4, 70.5 ja; 70.3 nach Stilwahl im Test-Build |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Nutzer 14.10., 08:34) | Berater mit Nutzer; Jerry (Bilder) | – | Nur Aussehen (Nutzer 09:08), Aufbau des Kampfbildes gehört zu 72b. Erst Standbild (Jerry ab Fr.), dann Entwurf nach Musterbild 70.1 |
| 80 | Kaels angesengte Laterne neben seiner Haustür im Dorf (Aussehen `LISTE-FIGUREN.md`) | Tom | – | 80a auf `main` |
| 74 | Schrittgeräusche fehlen an allen Orten („Ort fertig“ 8; Befund Diogenes D1.1) | Tom (Vertretung für Jerry, Nutzer 14.10., 13:3x) | `claude/tom-74-schritte` | **Alle fünf genommen** (Nutzer 14.10., 20:4x, Beschlüsse; Rezept `tools/klang/schritte.py` auf dem Zweig). 74a: ein Klang je Aufsetzen, beim Rennen dichter und leiser. Dann einbauen (nur Held) |
| 55 | Mehr Leerlauf für alle Leute, Szenen wie Sitzen am Tisch | Tom | – | Auf `main`; 55d so lassen (Beschlüsse) |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry; Rudelwölfe Tom (Vertretung) | – | Krogg so lassen, später alle gesamt (Jerry). Rudelwölfe auf `main` |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Steht; offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (14.10., 20:5x)
- PR #60 zusammengeführt (0.1.739 passt, Nutzer 20:5x). #61 zusammengeführt (0.1.740 passt bis auf 87). #62 (0.1.741) beim Nutzer, abonniert. Dann 87.
- **83 A** (Zweig von `main`): Felder `c`/Beete `v` in Zeile 28–30 von `Story.village`, Zeile 31 Baumreihe → Hecke; Ring `MapEdge.trees` südlich ohne Bäume bis Tiefe 3 vor Feld/Beet/Zaun/Heu. Standbilder `HELDORT=village:6:29:D:12`, `village:26:29:D:12`.
- **74 einbauen** (`claude/tom-74-schritte`): nur Held, Untergrund je Feld. **85** fertig, mit in den nächsten Sammelbuild. Draußen nachts bleibt das kleine Licht um den Helden.
### Jerry (12.10., 16:59; gekürzt 77e) – Pause bis Freitag, 03:00

- **Startauftrag Berater (76–78, 13.10.), vor allem anderen:** Startlektüre jetzt `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“) ganz lesen; in jedem Zweig zuerst `git merge origin/main`; Sammelbuilds (höchstens 4 Punkte, nie mit Tom gemischt), „(Rückläufer: n)“ im `CHANGELOG.md`.
- Pause bis Fr., 03:00. Danach 24.6, 36.6, 38–40, 51–53; 13e liegt bei Tom; Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Archiv).
## Zu testen

- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5/D1.6/D1.9/D1.15 Höhle bei Tom (13e); D1.7 Leben Höhle, D1.8 stumme Quellen, D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (`grund_fs_609422`, `grund_fs_540836`, Hörner/Kreaturen ohne Quelle): Berater empfiehlt herausnehmen, **Nutzer entscheidet nach Hörprobe** (Höhle mit und ohne auf „Dein Zug“), erst danach ändern.

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **71 Bestandsprüfung Stil und Klang** (Nutzer 13.10., 18:16): Liste „Bestandsprüfung (71)“ in `ROLLE-TESTER.md`. **B** und **C** erledigt (Lauf 1 und 2, 13.10.); **A** erst, wenn Toms Wald- und Dorfzweige auf `main` sind (Nutzer 18:24).
- **38g Spieldauer Kapitel 1** (Berater 13.10., Nutzer 16:06 ja): beim Durchspielen je Abschnitt (Dorf, Wald, Tiefer Wald, Höhle, Rückkehr) zählen statt stoppen: gelaufene Felder, Kämpfe mit Runden, gelesene Dialogzeilen, Rasten, Menüaufrufe; Tabelle im Bericht. Berater rechnet daraus menschliche Spielzeit (38h Eichung durch Nutzer später).

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.
- **72q erledigt?** (Tom, Nutzer 14.10., 20:4x: „72q ist glaube ich irgendwie auch entschieden; bitte nochmal Sokrates vorlegen, ob es erledigt ist; wenn nicht, dann beraten“). Beschlüsse 72.7–72.10 (Held plus ein Begleiter) scheinen die Gruppenfrage zu beantworten; offen wirkt nur noch die Aufstellung fest oder veränderlich. Prüfen, dann 72q von „Dein Zug“ nehmen oder beraten.
- **13e.6 Höhle zu hell?** (Tom, Nutzer 14.10., 21:0x, Test 0.1.741, Bildschirmfoto: Lagerhöhle mit Feuer unten, Kristalle und Pilze oben links, Held in der Mitte gut zu sehen): „dafür, dass es dunkel sein soll, ist es sehr hell, oder... Leg das mal mit Bild Sokrates zur Beratung vor, wie das zu schleichen und lauschen passt und zur Atmosphäre allgemein“. Standbild: Zweig `claude/tom-13e-hoehle-fertig`, Vorschau `KARTENZOOM=1 ONLY=zoom_nah_5`.
- **26 Ausgleich Magier** (Tom für Jerry, 14.10.; Simulation: Magier 45 % gegen Grak, mit Zauber Schild 78–87 %; Entwurf `claude/tom-26-magier-schild`, im Spiel aus; Bosse auf Stufe 5–6 über Ziel 50–65 %). Zurückgestellt (Nutzer 16:02): wird mit 72b entschieden (Schild als Reaktion des Magiers).


