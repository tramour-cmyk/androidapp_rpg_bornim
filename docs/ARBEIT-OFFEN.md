# Offen

Nur was **in Arbeit**, **zu testen** oder **zu entscheiden** ist; nur auf `main` (Regeln in `CLAUDE.md`, auch zur Größe).

**Nächste freie Themennummer: 97**

**Ford: Pilot** (Nutzer 14.10., in Toms Sitzung, eingetragen 22:5x; 81g; Stellung aus / Co-Pilot / Pilot, Startlektüre `ROLLE-FORD.md`; wer die Stellung erhöht, löst Ford sofort einmal aus)

**Seite „Dein Zug“ (alle Rollen, 63): https://claude.ai/artifact/5BapvnBEmqyQA1tfH4Gfow** · Beschlüsse: https://claude.ai/artifact/UJPtHAnrZn5s2gonz8YkMM · Prüfbericht Diogenes: https://claude.ai/artifact/GMig9HQKmabNkBSrbgmZiQ (wer ein Thema anlegt, zählt hier hoch, pusht und nennt dann die Nummer)

## Jetzt installieren

Nichts. 0.1.750 abgenommen und auf `main` (PR #65, 15.10., 16:5x).

Rückfragen und Testfragen an den Nutzer stehen nur auf der Seite „Dein Zug“ (65.3), nicht hier.

Die Listen: **Offen** (diese Datei) · [Merkliste](LISTE-IDEEN.md): Ideen für später · [Änderungshistorie](../CHANGELOG.md): was umgesetzt ist · [Stil-Leitlinien](DESIGN-STIL.md) · [Umgebung](ARBEIT-UMGEBUNG.md) (auch alle Vorschau-Schalter) · [Selbstarbeit](ARBEIT-SELBST.md) · [Themen](LISTE-THEMEN.md): eine Zeile je Nummer · [Archiv](ARBEIT-ARCHIV.md): Verlauf. Themen und Archiv werden nicht beim Start gelesen.

## Wer macht was

| Nr. | Thema | Wer | Zweig | Stand |
|---|---|---|---|---|
| 96 | Gesprächstext zu lang für das Feld: „Text kann nicht gescrollt werden, sondern nächster Text kommt.“ (Nutzer 15.10., 17:0x, Garrick-Warnung vor Krogg, Bild) | Tom | – | Neu |
| 92 | Bauer Bram blockiert an der Brücke den Weg, Held steckt fest (Nutzer 15.10., 16:5x, Test 0.1.750, Bild); Idee: „Held muss NPC schieben können. Keine Gegner, aber neutrale.“ | Tom | – | Neu. **92.1** Vorschlag folgt (Schieben/Platztausch mit Neutralen) |
| 93 | „Die Beete westlich gehen nicht bis zum Zaun.“ (Nutzer 15.10., 16:5x) | Tom | – | Neu |
| 94 | „Hühner landen teilweise auf dem Fluss.“ (Nutzer 15.10., 16:5x); dazu D7.1 Hühner verschwinden schlagartig | Tom | `claude/tom-build-b-tempel` | Gebaut: Abstand zum Ufer, bei Regen und Dämmerung unter die Bäume und wieder heraus (`MapHenTest`); Build B |
| 95 | Atem: „Atem mit Anzeige (Balken rechts) hört man nicht und der Balken funktioniert nicht.“ (Nutzer 15.10., 16:5x, zu 86) | Tom (Balken); Jerry (Keuchen, 86.3) | – | Neu. **Jerry, 95:** Keuchen hörbar machen (ab Fr.) |
| 86 | Bewegung und Übersicht (Nutzer 14.10., 18:5x) | Tom (86.1–86.4); Jerry (86.3 Keuchen, Lärm, Initiative; 86.11 mit 72b/38) | – | Einzelheiten in den Beschlüssen. **Tom:** 86.1–86.4 auf `main` (0.1.750). **Jerry:** Keuchen, Initiative mit Nachteil, Rennen laut (84.4); zur Kenntnis `GameState.winded`/`stamina`. Beschlossen, Bau offen: 86.6, 86.9, 86.10, 86.11 |
| 90 | Projektleitung: täglicher Rückblick (Nutzer 15.10., 12:4x) | Berater; Ford startet | `main` (Notizen) | **Probe 16.–22.10. beschlossen** (12:5x, Beschlüsse): Sokrates morgens nach Fords Morgenmeldung (`ROLLE-FORD.md` 6a, `ROLLE-BERATER.md` „Tagesrückblick“). **Sokrates** achtet auf die Woche (jeder Rückblick nennt „Tag n von 7“) und Diogenes prüft die Woche vorher (Nutzer 12:5x, „Für Diogenes“); 23.10. Bilanz mit Nutzer: weiter oder abschaffen. **90a** auf Dein Zug |
| 81 | Teamleiter „Ford“ (Nutzer 14.10., 13:09) | Berater mit Nutzer | `main` (Notizen) | Beschlossen 81a–c, 81g–n, 81p, 81r, 81s (Uhr statt Kette, bestätigt 12:03), 81t, 81u (nein), 81v (Nutzer 15.10., 13:4x: Titel mit Startzeit, Vorgänger archivieren) (`ROLLE-FORD.md`, `ARBEIT-ABLAEUFE.md` „Neustart“); Ford lebt in „Ford – Teamleiter“, Stellung oben; Jerry-Ford ab Fr. **Nutzer:** `TELEGRAM_BOT_TOKEN` in Jerrys Umgebung. Verlauf 81o–81r im Archiv („Aus ARBEIT-OFFEN.md, 15.10., 10:2x (Sokrates, 81)“) |
| 65 | Abläufe verschlanken (Nutzer 13.10. alle Punkte ja) | Berater; Jerry (65.2) | `main` (Notizen) | Fertig bis auf **65.2:** Jerry pausiert seine acht Weck-Routinen „Jerry Selbstarbeit HH:MM“ (`enabled: false`, nicht löschen). 65.8/65.9 stehen in `CLAUDE.md`. **65.10** (Nutzer 14.10., 23:1x): Selbstarbeit ist abgeschafft, Ford ersetzt sie; Notizen nachziehen (`CLAUDE.md`-Zeile, `ARBEIT-SELBST.md` ins Archiv, Neustart ohne Nutzer: Übergabe „Nachfolger gewünscht“, Ford startet). **65.11** (Nutzer 15.10., 16:4x „mach beides“: Haken und Kürzen): Dein-Zug-Haken gebaut; Entwurf CLAUDE.md halbieren ([Dokument](https://claude.ai/code/artifact/2acaeffb-b81a-40ab-8a10-d6a0380bedc5)) auf Dein Zug |
| 13e | Höhle „Ort fertig“ (Vertretung Jerry, Nutzer 14.10., 16:0x) | Tom | – | D1.3/D1.11, D1.5, 13e.6 auf `main`. Helligkeitsregler Jerry mit 40. Danach D1.7 Leben (Absprache `WorldScreen.kt`). Mond mit D3.14 (89) |
| 5 | Dorf draußen, Dorfbewohner als Puppen | Tom | – | Auf `main` bis 5.5 |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm | Tom (Technik); Jerry (Inhalt) | – | Großteil auf `main`. **Jerry:** 24.6 Kampferöffnung wartet + Herzschlag. Verlauf im Archiv |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem ([`LISTE-KAPITEL1.md`](LISTE-KAPITEL1.md)) | Tom und Jerry, je ihr Teil | `main` (Notizen) | Toms Teil von 26c fertig |
| 27 | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Tom | – | Auf `main` bis 27m. **27k:** nur Frosch 1–3, Chor 2, Libelle 1–2 (leise). **D3.13** Morwens Hütte: zweiter Entwurf (2×2, flacher, Tür zum Feuer) auf Dein Zug. **D3.14:** Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1 |
| 30 | Abstürze beim Testen | Tom (Technik); Jerry prüft seine Klang-Fäden | – | Abstürze beobachten (bei neuem `adb logcat` mit Anleitung von Tom); 30.7 Merkliste |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben) | Jerry | – | Meldung Nutzer 12.10., 15:4x; erneut 14.10., 21:1x (Test 0.1.741, Alrik liegt mit Brand 2, „sieht immer noch nicht richtig aus“). Erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | Jerry | – | 36.4–36.7, 36h/36j/36k auf `main` (PR #46, #47, getestet 0.1.587). Rest in 52, 53. **Offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung. Verlauf im Archiv |
| 38 | Balance-Langzeitplan über alle Kapitel (Stufe, Gold, Preise, Ausrüstung, Ziel-Siegquoten) | Berater (Plan), Jerry (Messung) | `main` (Notizen) | Plan in `DESIGN-BALANCE.md`. Jerry erweitert `ChapterSimTest` um Gold/Einkauf und misst Kapitel 1 (38e/38f); 38g gemessen (Prüfbericht Lauf 4); **D4.1** beschlossen, Texte freigegeben (`STORY-K1.md` [D4.1.*], 15.10.): **Tom, D4.1** gebaut (`claude/tom-runde-nach-748`, nächster Sammelbuild; Taschentext jetzt `[D4.1.rauch.tasche]` statt des vorläufigen; Jerry zur Kenntnis: Gegenstand `Story.SMOKE_BUNDLE`, Merker `SMOKE_GIVEN`); **Jerry, D4.1** Kampfwirkung Rauchbündel (nimmt Krogg den ersten Hieb), danach Diogenes neu messen; 38h Eichung durch Nutzer später. **D4.1 A** (Nutzer 15.10., 10:5x): Quest vor der Höhle über Morwen, Garrick warnt unter Stufe 3; **Sokrates** Texte mit Nutzer unter 41, dann **Tom** baut, dann Diogenes misst neu (Ziel zielstrebig Stufe 2–3, Median höchstens 3 Tode) |
| 39 | Schwierigkeitsgrad im Menü | Jerry (Werte), Menü mit Tom | – | Nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m). Beschlüsse |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (heute nur Musik an/aus) | Jerry | neu von `main` | Nutzer 12.10., 09:52. **40a ja (10:10):** drei Regler, Ortsklang bei Effekten; **Jerry, 13e.6** Helligkeitsregler auf derselben Einstellungsseite: Abgleich mit Prüfbild („Zeichen gerade noch sichtbar“), hellt die Höhle nicht auf (Wert mit Tom) |
| 41 | Storyplan; Texte Kapitel 2 | Berater mit Nutzer | `main` (Notizen) | [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d) Kapitel 2 fertig (ohne 5b). [Textentwurf](https://claude.ai/code/artifact/3dfb1fb7-3230-41aa-8c9e-a1ae94c5c413) beim Nutzer; offen 4.4, 5.3, 6.3 |
| 72 | Profil und Kampfsystem | Berater mit Nutzer; Jerry (Probe, Bau) | `main` (Notizen) | [Marktvergleich](https://claude.ai/code/artifact/34c58f65-d75c-4b93-b946-65fcb213843b), [Kampf-Dokument](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4); beschlossen siehe Beschlüsse (72.6–72.15, 72o B, 72o.1 A mit C, 72r–72t, 72v). **Jerry, 72.10** Probe Held plus Söldner gegen Grak auf dem gemalten Kampfort (drei Absichten, Ring, zwei Reihen mit je zwei Plätzen, Platztausch, Automatik nach 72.13); danach 72o (vorher Vorschaubilder je Zustand auf Dein Zug), 72.15, sechs Plätze (72v). **72u** Standbild Grak im Wald (Jerry), Entscheidung nach Probe. **Jerry, Tom, 72.14:** Gefährte/Söldner/Begleiter in Spieltexten. **72s.1** auf Dein Zug (Gefährte Kapitel 2, Empfehlung A Garrick). Offen 72a, 72c–72j |
| 84 | Licht und Laut (Nutzer 14.10., 17:5x; baut auf Idee 4 in `LISTE-IDEEN.md` und `Perks.kt` auf) | Berater mit Nutzer | `main` (Notizen) | **84.1** Fackel als Gegenstand (Laden, nimmt die Nebenhand); **84.2** Schnellwechsel zweier Handbelegungen; **84.3** Schleichen; **84.4** Lauschen beim Stehen: Welle am Helden zur Quelle hin, Stärke = Deutlichkeit (Nutzer 18:0x), Wort nur bei deutlichem Hören; nicht für Sichtbares; Stufen Stehen > Schleichen > Gehen > Rennen (Nutzer 18:1x: „sehr gut“). Empfehlung im Gespräch 14.10.; Kampfteile mit 72b. **D3.14** hängt an 84.1 (Heldenlicht draußen weg, Mondlicht); **Jerry, D3.15:** Tiefer Wald ohne Vögel (mit D3.2), pickende Vögel scharren und flattern hörbar; Umweltklang nach `DESIGN-STIL.md` (Nutzer 11:1x): Tiefer Wald selten fernes Wolfsgeheul, Höhle Tropfen und Grollen (echte Aufnahmen, CC0) |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | Tom (jetzt); Jerry mit 38/39 (Vorrat) | – | „Alle“ erledigt (0.1.660). Vorrat je Laden mit 38/39 (Beschlüsse) |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | Tom; 62m Jerry mit 39 | – | Bis 62r auf `main`; 62i–62k mit 64; 62l/62m später |
| 45 | Geschäftsmodell (Play Store) | Berater mit Nutzer | – | 45a/45c ja (Beschlüsse). 45b zurückgestellt bis nach 38 |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Tom (Szene, Bilder), Jerry (Klang „Ancient Legend“) | `claude/tom-build-b-tempel` (Build B, auf Build A) | 68a–68m ja: Texte in `STORY-K1.md` (`[68.…]`). **Tom:** Ablauf gebaut (Einladung, Kapitelende-Karte, Nacht als Rast, fünf Bilder, Lyra, Auftrag „Das Lager im Süden“, Rowena/Aldric, Südrand still; `TempleSceneTest`); Bilder erster Entwurf auf Dein Zug `e/68.html`, Bild 4 neu nach 68n (16:4x); nach Ja zu 68n–68p verfeinern, dann Build B. Jerry zur Kenntnis: `MusicScene.TEMPLE` spielt `MusicLib.amuletReturn`, `Mode.TempleScene` |
| 69 | Intro: Ankunft bei Nacht in Standbildern, endet im Gasthaus | Tom (Bilder, Technik), Jerry (Klang) | – | 69a–69e ja (`STORY-K1.md` `[69.intro.…]`, Beschlüsse). Intro auf `main` (0.1.748). **Jerry, 69c:** leiser Klang unter Bild 1–4 (`MusicScene.INTRO`). 70.3 später |
| 70 | Zwischensequenzen: Bildsprache für alle Kapitel (Nutzer 14.10., 08:00) | Berater mit Nutzer; Tom (Bild 3) | `main` (Notizen) | Entschieden (Beschlüsse, `DESIGN-STIL.md`): 70.1, 70.2, 70.4, 70.5, **70.3 B** (Licht und Luft bewegt, ein Ereignis je Bild, Figuren nie selbst), **70.6 A** (Bild 3 vom Platz, Brunnen vorn, Tempel fern, Fackelzug verschwindet hinter der Tempelecke). **Tom:** 70.6 gebaut (`claude/tom-68-tempelszene`, Standpunkt 3 Kacheln südlich wegen Marktstand), auf Dein Zug `e/706.html`; nach „passt“ in Sammelbuild B statt des alten Bilds 3 |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Nutzer 14.10., 08:34) | Berater mit Nutzer; Jerry (Bilder) | – | Nur Aussehen (Nutzer 09:08); hängt an 72u (Kampfort aus der Karte oder gemalt). Erst Standbild (Jerry ab Fr.), dann Entwurf nach Musterbild 70.1 |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Jerry; Rudelwölfe Tom (Vertretung) | – | Krogg so lassen, später alle gesamt (Jerry). Rudelwölfe auf `main` |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg | Jerry | – | Prüfthema, Nutzer 12.10., 15:4x (Test 0.1.587): wenn Zeit ist und nichts Wichtigeres ansteht; alle großen Gegner mitprüfen |
| 63 | Eine Seite „Dein Zug“ für alles Offene (alle Rollen; Beschlüsse für Entschiedenes, 57) | Tom | `main` (Notizen) | Steht; offen: Freigabe für Jerry (Nutzer, Teilen) am Fr. |
Tom: Leute auf der Karte, Dorf und Innenräume. Jerry: Monster auf der Karte, Höhle, Kampf, Klang. Keiner arbeitet an Themen des anderen.

## Übergaben

### Tom (15.10., 16:5x, „Tom – Build B Tempelszene“)
- 0.1.750 abgenommen, PR #65 zusammengeführt. Build B (`claude/tom-build-b-tempel`: 68, 70.6) wartet auf 68n–68p. Jetzt 94 (Hühner) mit D7.1, dann 92, 93, 95.
### Jerry (12.10., 16:59; gekürzt 77e) – Pause bis Freitag, 03:00

- **Startauftrag Berater (76–78, 13.10.), vor allem anderen:** Startlektüre jetzt `docs/ROLLE-ENTWICKLER.md` („Vor jeder Arbeit lesen“) ganz lesen; in jedem Zweig zuerst `git merge origin/main`; Sammelbuilds (höchstens 4 Punkte, nie mit Tom gemischt), „(Rückläufer: n)“ im `CHANGELOG.md`.
- Pause bis Fr., 03:00. Danach 24.6, 36.6, 38–40, 51–53; 13e liegt bei Tom; Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; Archiv).
## Zu testen

- **Jerry, Diogenes-Befunde Lauf 1** (Verdachte, erst bestätigen): D1.5/D1.6/D1.9/D1.15 Höhle bei Tom (13e); D1.7 Leben Höhle, D1.8 stumme Quellen, D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (`grund_fs_609422`, `grund_fs_540836`, Hörner/Kreaturen ohne Quelle): Berater empfiehlt nach Umweltklang-Regel (15.10.): Tropfen und fernes Grollen behalten, Hörner herausnehmen (passen zu keiner Quelle der Geschichte); **Nutzer entscheidet nach Hörprobe** (Höhle mit und ohne auf „Dein Zug“), erst danach ändern.
- **Diogenes Lauf 3** (14.10., Prüfbericht, Verdachte, erst bestätigen): **Jerry** D3.1 Türklang ohne Tür, D3.2 Vögel im Tiefen Wald, D3.4 Endlosklänge reißen ab, D3.5/D3.6 Monster, D3.8–D3.10, D3.12; Toms Teil auf `main` (0.1.750).
- **Diogenes Lauf 6** (15.10., 71 A Dorf, Prüfbericht, Verdachte, erst bestätigen): Toms Teil auf `main` (0.1.750). **Jerry** D6.4 Fluss stumm.
- **Diogenes Lauf 7** (15.10., 71 Nachprüfung Dorf nach 0.1.748, Prüfbericht, Verdacht, erst bestätigen): **Tom** D7.1 Hühner (mit 94). Sonst in Ordnung (Hühner, Schritte, Intro, Brücke).

## Für Diogenes

Prüfaufträge für den Tester (alle tragen ein, eine Zeile mit Themennummer; nur der Nutzer startet Diogenes; Ablauf in `docs/ROLLE-TESTER.md`).

- **90 Tagesrückblick** nach dem 22.10., 9 Uhr: die Rückblicke der Woche (Telegram, Sitzungen „Sokrates – Tagesrückblick“) gegen die Quellen in `ROLLE-BERATER.md` „Tagesrückblick“ prüfen: Stimmten die Fakten, wurden Empfehlungen umgesetzt, was hat die Woche gekostet; Ergebnis im Prüfbericht vor der Bilanz am 23.10.

## Für den Berater

Grundsatzfragen (Rollen in `CLAUDE.md`): Tom und Jerry tragen ein und arbeiten weiter; Nutzer und Berater entscheiden, der Berater streicht die Zeile und trägt die Entscheidung in „Wer macht was“ ein.

- **65.11** (Diogenes Lauf 8, 15.10., Nutzer 16:59 „Prüfe 65.11“): D8.1–D8.7 im Prüfbericht. Wichtigste: Haken wirkt nur in Zweigen, die ihn enthalten (D8.1); Neustart- und Dein-Zug-Haken widersprechen sich (D8.2); Entwurf verliert „Rolle statt Kennung“ (D8.3) und zählt `tools/` zu den Notizen (D8.4).
- **91** (Tom, 15.10., Nutzer 16:0x): „Schrittgeräusche müssen eigenständig abschaltbar sein. Zusätzlich zu den Effekten. Die Töne können auf Dauer nerven. Leg die Idee mal auch Sokrates vor.“ Tom hat einen Schalter an/aus im System-Reiter gebaut; Frage an Sokrates: reicht an/aus, oder eigener Regler neben Gesamt/Musik/Effekte (40), oder Schritte allgemein leiser? **Sokrates 91a:** an/aus reicht (Empfehlung), im Chat 16:2x.

- **68** (Tom, 15.10., Nutzer 16:1x): „68 Sokrates vorlegen, der soll das mal bewerten, bitte. Und ob das jetzt auch mit unserer neuen Musterstilkarte vereinbar ist, dann alles und so.“ Fünf Bilder der Tempelszene auf Dein Zug `e/68.html`; Bewertung gegen das Musterbild (70.1, 69e) und 70.3. **Sokrates 68n:** Aufbau ja außer Bild 4 (Ostfenster im Bild, Strahl aufs Amulett, Gesichter hell, schwebende Sonne weg), im Chat 16:2x.
- **68** (Tom, 15.10.): Der Kapitelende-Text (`Story.chapterEndText`: „Bornim feiert bis tief in die Nacht. Das Sonnenamulett leuchtet wieder im Tempel …“) kommt jetzt nach Aldric, vor Nacht und Morgenandacht; „leuchtet wieder im Tempel“ passt erst nach der Andacht. Text anpassen (41) oder Karte nach Lyras Gespräch? **Sokrates 68o:** Karte bleibt (passt zu „feiert bis tief in die Nacht“), nur „leuchtet wieder im Tempel“ → „ist zurück in Bornim“.
- **68l** (Tom, 15.10.): „Südrand frei“ nach Lyras Gespräch, Kapitel 2 fehlt aber noch: bis dahin tritt der Held am Rand still zurück. Reicht das, oder braucht es eine Zeile (41)? **Sokrates 68p:** eine ehrliche Zeile, z. B. „Der Weg nach Süden ist noch nicht begehbar. Kapitel 2 folgt mit einem späteren Update.“

