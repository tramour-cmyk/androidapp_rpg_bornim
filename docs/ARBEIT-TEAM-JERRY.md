# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-TEAM.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**offen 27, davon A 0, wartet auf Chef 5**

**Übergabe (16.10., 07:4x, „Jerry – 95 Keuchen hörbar“) – Nachfolger: Jerry – 38 Rauchbündel im Kampf:** 95 gebaut, PR #70 (`claude/jerry-95-keuchen`; Nachfolger abonniert neu, meldet Grün oder behebt Rot), Prüfliste 07:4x per Telegram, wartet auf Test des Chefs nach Toms #67; Prüfliste per Telegram (Pro sieht Dein Zug nicht). Nach „passt“: #70 zusammenführen, CHANGELOG. 86.9 blockiert, bis Toms `claude/tom-86-bewegung-rest` auf `main` ist (`GameState.drunk`; nie mischen). 65.2 erledigt (alle acht Weck-Routinen „Jerry Selbstarbeit“ aus). 72u (PR #69) und 72.10 (PR #68) unverändert wie zuvor. Weiter gilt: `docs/ROLLE-TEAM.md` ganz; in jedem Zweig zuerst `git merge origin/main`; Zeitstempel von der Uhr.

## Zeilen

| Nr. | Thema | Stand | Zweig |
|---|---|---|---|
| 24.6 | Kampferöffnung wartet + Herzschlag in der Blende (nach Toms 24.5 auf `main`) | offen; **wartet auf Chef** (24e: wartet, bis Kampfbilder fertig sind) | – |
| 72.10 | Probe Held plus Söldner gegen Grak auf dem gemalten Kampfort (drei Absichten, Ring, zwei Reihen mit je zwei Plätzen, Platztausch, Automatik nach 72.13); danach 72o (vorher Vorschaubilder je Zustand auf Dein Zug), 72.15, sechs Plätze (72v) | Kern auf `claude/jerry-72-10-probe-grak` (PR #68, Entwurf); wartet auf Abschrift Kampf-Dokument (Absichten, Ring), dann Oberfläche; Beschlüsse 72.6–72.15, 72o, 72r–72v; [Kampf-Dokument](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4) | – |
| 72u | Standbild Grak im Wald | **Standbild fertig** (16.10., 07:3x, Telegram): A heute gemalt, B aus der Karte Zoom 8 (gleich fein wie heute, Figuren 27 % kleiner), C Zoom 12 (heutige Größe, 1,5-mal gröber); Vorschau `KAMPFORT=forest:7:14:8,12`. Offen: Nacht (Figuren ohne Kartenlicht), Söldner nur Platzhalter (Schurke). Entscheidung stellt Kreativ | `claude/jerry-72u-standbild-grak` |
| 95 | Atem: Keuchen hörbar machen (86.3; Chef 15.10., 16:5x: „Atem mit Anzeige … hört man nicht“) | gebaut (6c2f275, PR #70, Kerntests grün): leer gerannt keucht Held/Heldin (je drei CC0-Atemzüge), erst dicht, dann leiser mit Pausen, bis er wieder rennen darf (5–10 s); **wartet auf Chef** (Test nach Toms #71; 16.10., 08:06 mit `main` neu gebaut, damit die Nummer über 0.1.757 liegt) | `claude/jerry-95-keuchen` |
| 86 | Bewegung und Übersicht: Keuchen, Initiative mit Nachteil, Rennen laut (84.4); 86.11 mit 72b/38 | offen; zur Kenntnis `GameState.winded`/`stamina`. Von Team Tom (16.10., 01:2x): **86.9** betrunken (`GameState.drunk`, fünfter Met, bis zur Rast) soll im Kampf wie SRD „Vergiftet“ wirken (Nachteil auf Angriffe); Ausdauertrank ist `ItemKind.TONIC` (nicht im Kampf); `WorldScreen.kt`: eine Zeile in `PlayScreen` (`Mode.Rest`) | – |
| 38 | Balance: `ChapterSimTest` um Gold/Einkauf erweitern, Kapitel 1 messen (38e/38f; 38g gemessen); **D4.1** Kampfwirkung Rauchbündel, danach Diogenes neu messen (Ziel zielstrebig Stufe 2–3, Median höchstens 3 Tode); 38h Eichung durch Chef später | **D4.1 gebaut** (16.10., 08:06, PR #72, Kerntests grün, Film selbst gesehen): Held wirft das Bündel zu Kampfbeginn selbst, Kroggs erster Hieb geht ins Leere (ohne Überraschungsschlag und Betäubung), bei Niederlage zurück in die Tasche; **wartet auf Chef** (Test nach #71 und #70). Danach Zeile an Diogenes: neu messen | `claude/jerry-38-rauchbuendel-kampf` |
| 39 | Schwierigkeitsgrad im Menü (Werte; Menü mit Tom) | nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m) | – |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (40a: drei Regler, Ortsklang bei Effekten); **13e.6** Helligkeitsregler auf derselben Seite: Abgleich mit Prüfbild („Zeichen gerade noch sichtbar“), hellt die Höhle nicht auf (Wert mit Tom) | offen, neu von `main` | – |
| 84 | **D3.15:** Tiefer Wald ohne Vögel (mit D3.2), pickende Vögel scharren und flattern hörbar; Umweltklang nach `DESIGN-STIL.md` (Chef 11:1x): Tiefer Wald selten fernes Wolfsgeheul, Höhle Tropfen und Grollen (echte Aufnahmen, CC0) | offen | – |
| D1 | Diogenes Lauf 1 (Verdachte, erst bestätigen): D1.7 Leben Höhle, D1.8 stumme Quellen, D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (`grund_fs_609422`, `grund_fs_540836`, Hörner/Kreaturen ohne Quelle): Empfehlung Tropfen und Grollen behalten, Hörner heraus | **wartet auf Chef** (Hörprobe mit und ohne auf Dein Zug), erst danach ändern | – |
| D3 | Diogenes Lauf 3: D3.1 Türklang ohne Tür, D3.2 Vögel im Tiefen Wald, D3.4 Endlosklänge reißen ab, D3.5/D3.6 Monster, D3.8–D3.10, D3.12 | offen (Verdachte, erst bestätigen) | – |
| D6.4 | Diogenes Lauf 6: Fluss stumm | offen (Verdacht) | – |
| 69c | Intro: leiser Klang unter Bild 1–4 (`MusicScene.INTRO`) | offen | – |
| 68 | Tempelszene: Klang „Ancient Legend“ (`MusicScene.TEMPLE` spielt `MusicLib.amuletReturn`) | offen | – |
| 72.14 | Gefährte/Söldner/Begleiter in Spieltexten (Toms Teil erledigt 16.10., 01:26) | von Team Tom: in Texten heißt kein Mensch „Begleiter“. Einziger Treffer Feuerball (`Rules.kt` FIREBALL: „Verjagt Begleiter …“, meint das gegnerische Rudel); mit eigenem Hund (72.15) mehrdeutig, Wortlaut in deinem Bereich, etwa „Verjagt Rudel und Späher des Gegners“; prüf neue Kampftexte so | – |
| 79 | Kampfhintergründe an die Diagonalwelt angleichen (Chef 14.10., 08:34; nur Aussehen) | hängt an 72u; erst Standbild, dann Entwurf nach Musterbild 70.1 | – |
| 51 | Sterbehaltung des Helden (Magier) im Kampf sieht komisch aus (liegt verdreht auf der Seite, Arm abgeknickt nach oben; Chef 12.10., 15:4x, erneut 14.10., 21:1x, Test 0.1.741) | erst Standbild der Sterbehaltungen aller Klassen, dann Vorschlag | – |
| 36 | Krogg (Vorboss Höhle) wirkt verpixelt | 36.4–36.7, 36h/36j/36k auf `main`; **offen 36.6:** Killerschlag mit Zerteilen bei Krogg noch in alter Auflösung | – |
| 52 | Feinarbeit an den Kampfanimationen (gesamt, auch Krogg) | Krogg so lassen, später alle gesamt; Rudelwölfe auf `main` | – |
| 53 | Zustände (z. B. Brennend) sitzen nicht richtig auf Krogg (Chef 12.10., 15:4x) | wenn Zeit ist; alle großen Gegner mitprüfen | – |
| 59e | Händler: Vorrat je Laden (mit 38/39) | offen | – |
| 30 | Abstürze: eigene Klang-Fäden prüfen | offen | – |
| 18 | Stimmen der übrigen Gegner (Angriff, Schmerz, Tod, je drei Fassungen), nur als Hörproben | offen (Selbstarbeit) | – |
| – | Raumklang (Idee 8), Hörproben | offen (Selbstarbeit) | – |
| – | Musik in Schichten (Idee 10), Hörproben | offen (Selbstarbeit) | – |
| 9i | Entwürfe ansehen und freigeben | **wartet auf Chef** | – |
| 19e | Ein konkretes Beispiel für „Bewegungen unrund“ | **wartet auf Chef**, falls ihm eines auffällt | – |
