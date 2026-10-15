# Vorrat Team Jerry

Monster, Höhle, Kampf, Klang (`ROLLE-TEAM.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**Pause bis Fr. 16.10., nachmittags (Chef 22:2x)** (D13.7): Jerry hat ab 16.10., 03:00 wieder Guthaben, der Chef richtet erst Fr. nachmittags den Telegram-Schlüssel auf Pro ein und startet Jerry dann von Hand; Ford und Ford 2 starten bis dahin nicht.

**offen 27, davon A 0, wartet auf Chef 4**

**Übergabe (12.10., 16:59; gekürzt 77e):** **Startauftrag, vor allem anderen:** `docs/ROLLE-TEAM.md` ganz lesen (seit Umbau 98, 15.10.: Firma WireStormTCS, `CLAUDE.md` und `docs/FIRMA.md`); in jedem Zweig zuerst `git merge origin/main`; Sammelbuilds (höchstens 4 Punkte, nie mit Tom gemischt), „(Rückläufer: n)“ im `CHANGELOG.md`. Zweig `claude/jerry-13e-hoehle-diagonal` (13e.3 fertig, 13e.4 halb; 13e bleibt bei Tom (Zuteilung des Chefs, D14.3); Archiv). **65.2:** deine acht pausierten Weck-Routinen „Jerry Selbstarbeit HH:27“ auf Pro löschen (Ford weckt, 81s; D13.8d).

## Zeilen

| Nr. | Thema | Stand | Zweig |
|---|---|---|---|
| 24.6 | Kampferöffnung wartet + Herzschlag in der Blende (nach Toms 24.5 auf `main`) | offen; **wartet auf Chef** (24e: wartet, bis Kampfbilder fertig sind) | – |
| 72.10 | Probe Held plus Söldner gegen Grak auf dem gemalten Kampfort (drei Absichten, Ring, zwei Reihen mit je zwei Plätzen, Platztausch, Automatik nach 72.13); danach 72o (vorher Vorschaubilder je Zustand auf Dein Zug), 72.15, sechs Plätze (72v) | offen; Beschlüsse 72.6–72.15, 72o, 72r–72v; [Kampf-Dokument](https://claude.ai/code/artifact/af5851da-790c-46ce-a6da-98dbcf5f10b4) | – |
| 72u | Standbild Grak im Wald | offen, Entscheidung nach Probe | – |
| 95 | Atem: Keuchen hörbar machen (86.3; Chef 15.10., 16:5x: „Atem mit Anzeige … hört man nicht“) | offen (Balken bei Tom passt) | – |
| 86 | Bewegung und Übersicht: Keuchen, Initiative mit Nachteil, Rennen laut (84.4); 86.11 mit 72b/38 | offen; zur Kenntnis `GameState.winded`/`stamina`. Von Team Tom (16.10., 01:2x): **86.9** betrunken (`GameState.drunk`, fünfter Met, bis zur Rast) soll im Kampf wie SRD „Vergiftet“ wirken (Nachteil auf Angriffe); Ausdauertrank ist `ItemKind.TONIC` (nicht im Kampf); `WorldScreen.kt`: eine Zeile in `PlayScreen` (`Mode.Rest`) | – |
| 38 | Balance: `ChapterSimTest` um Gold/Einkauf erweitern, Kapitel 1 messen (38e/38f; 38g gemessen); **D4.1** Kampfwirkung Rauchbündel (nimmt Krogg den ersten Hieb), danach Diogenes neu messen (Ziel zielstrebig Stufe 2–3, Median höchstens 3 Tode); 38h Eichung durch Chef später | offen; Plan `DESIGN-BALANCE.md`; Gegenstand `Story.SMOKE_BUNDLE` (Tom) | – |
| 39 | Schwierigkeitsgrad im Menü (Werte; Menü mit Tom) | nach 38. Leicht/Normal/Schwer über Gegner-TP und -Schaden (39a); auf Leicht Questziele gold (62m) | – |
| 40 | Lautstärke im Menü: Gesamt, Musik, Effekte (40a: drei Regler, Ortsklang bei Effekten); **13e.6** Helligkeitsregler auf derselben Seite: Abgleich mit Prüfbild („Zeichen gerade noch sichtbar“), hellt die Höhle nicht auf (Wert mit Tom) | offen, neu von `main` | – |
| 84 | **D3.15:** Tiefer Wald ohne Vögel (mit D3.2), pickende Vögel scharren und flattern hörbar; Umweltklang nach `DESIGN-STIL.md` (Chef 11:1x): Tiefer Wald selten fernes Wolfsgeheul, Höhle Tropfen und Grollen (echte Aufnahmen, CC0) | offen | – |
| D1 | Diogenes Lauf 1 (Verdachte, erst bestätigen): D1.7 Leben Höhle, D1.8 stumme Quellen, D1.14 Varianten aus einer Aufnahme; **D1.14 Höhlen-Klangbett** (`grund_fs_609422`, `grund_fs_540836`, Hörner/Kreaturen ohne Quelle): Empfehlung Tropfen und Grollen behalten, Hörner heraus | **wartet auf Chef** (Hörprobe mit und ohne auf Dein Zug), erst danach ändern | – |
| D3 | Diogenes Lauf 3: D3.1 Türklang ohne Tür, D3.2 Vögel im Tiefen Wald, D3.4 Endlosklänge reißen ab, D3.5/D3.6 Monster, D3.8–D3.10, D3.12 | offen (Verdachte, erst bestätigen) | – |
| D6.4 | Diogenes Lauf 6: Fluss stumm | offen (Verdacht) | – |
| 69c | Intro: leiser Klang unter Bild 1–4 (`MusicScene.INTRO`) | offen | – |
| 68 | Tempelszene: Klang „Ancient Legend“ (`MusicScene.TEMPLE` spielt `MusicLib.amuletReturn`) | offen | – |
| 72.14 | Gefährte/Söldner/Begleiter in Spieltexten (mit Tom) | offen | – |
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
