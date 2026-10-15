# Vorrat Team Tom

Leute, Dorf, Innenräume, Technik der Blende (`ROLLE-TEAM.md`). Reihenfolge = Vorrang; eine Übergabe, oben. Größe höchstens etwa 15 KB (`CLAUDE.md`).

**offen 24, davon A 0, wartet auf Chef 3**

**Übergabe (16.10., 01:26, „Tom – 72.14 Begriffe“) – Nachfolger: „Tom – 13e Höhle D1.7 Leben“:** 72.14 erledigt ohne Code: in Spieltexten und Oberfläche (`app`, `core`, Deutsch und Englisch) heißt kein Mensch „Begleiter“; einziger Treffer Feuerball-Text (`Rules.kt`), meint das gegnerische Rudel (Kobolde, Jungwölfe, Goblin-Späher, Wölfe), kein Mensch, passt also; Mehrdeutigkeit zum eigenen Hund (72.15) als Hinweis an Jerry. Sonst unverändert: PR #67 wartet auf Test des Chefs (neu abonnieren); nach „passt“ #67 zusammenführen, #66 schließen, dann **ein** PR von `claude/tom-86-bewegung-rest` (D3.3 + 89 + 69f + 86) mit Prüfliste wie in der vorigen Übergabe (Archiv). Jetzt: 13e D1.7 Leben in der Höhle (vorher Absprache `WorldScreen.kt` mit Jerry, der bis Fr. nachmittags pausiert; bis dahin nur Entwurf ohne `WorldScreen.kt`).

## Zeilen

| Nr. | Thema | Stand | Zweig |
|---|---|---|---|
| 94 | „Hühner landen teilweise auf dem Fluss.“ (Chef 15.10., 16:5x); dazu D7.1 Hühner verschwinden schlagartig | Test 0.1.752 (Chef 20:5x): „machen es richtig, aber jetzt flackern sie leider wieder“ → behoben (625302e3: eigene Bildablage, letztes Bild bleibt stehen), im Sammelbuild PR #67 (0.1.753), **wartet auf Chef** (Test) | `claude/tom-94-huehner-sammelbuild` |
| 100 | Testschalter ans Ende von Kapitel 1 (Chef 15.10., 20:5x: „Da brauche ich eine Testumgebung. Ein Testschalter dafür, dass ich ans Ende komme … sonst müsste ich komplett durchspielen“) | Knopf „Kapitel 1 bis kurz vor Ende“ im Testreiter (cbbd8e8d), in PR #67; dann 68 prüfen | wie 94 |
| 27 | Wald „Ort fertig“ (`DESIGN-ABNAHME.md`) | Auf `main` bis 27m; 27k: nur Frosch 1–3, Chor 2, Libelle 1–2 (leise). **D3.13a** Morwens Kate (Lichtung südlich, Tür Süd, Feuer davor, ohne Wegweiser; Chef 22:2x „Passt“); harte Lichtkanten (Chef 20:5x) → weicher Übergang an Hausumrissen (12cce7ae), vorher/nachher `e/d313a-2.html`; in PR #67. **D3.14:** Heldenlicht draußen weg, nachts Mondlicht, erst mit 84.1 | wie 94 |
| 92 | Bauer Bram blockiert an der Brücke den Weg (Chef 15.10., 16:5x; Idee: „Held muss NPC schieben können. Keine Gegner, aber neutrale.“) | Kerntest `MakeWayTest` fängt Held-gegen-Bram an der Brücke (Selbstarbeit erledigt, 23:1x); Test am Gerät mit 0.1.753 | – |
| D9 | Diogenes Lauf 9 (Klasse 1, Prüfbericht): D9.1 Nähte an Häusern (5d85b13a), D9.2 Schattenschicht im Zeichnen (40d93256), D9.3 Abendstand nach Mitternacht (bb440be2) | behoben, in PR #67 | wie 94 |
| 89 | Figuren im Schatten (Chef 15.10., 18:1x: „Wenn Figuren im Schatten eines Hauses oder Objekte stehen, können sie ja nicht hell sein … wenn das aber zu viel Detail und Rechenleistung frisst, dann lassen wir das“) | Gebaut (31fb73ab, enthält D9.2): Held und Dorfbewohner im Schatten so dunkel wie der Boden (56 % im Hausschatten); mit D3.3 und 69f auf nächstem Sammelbuild, PR erst nach „passt“ zu 0.1.753 | `claude/tom-sammelbuild-nach-753` |
| D3.3 | Rest Fichtenreihe im Tiefen Wald (Diogenes Lauf 3) | behoben (1984a990: junge Fichten in drei Höhen, weiter versetzt), mit 89 | wie 89 |
| 69 | Intro: Ankunft bei Nacht in Standbildern, endet im Gasthaus | Intro auf `main` (0.1.748), Chef 20:5x „Intro ist genial“. **69f A** gebaut (0c27e7a8, Kerntests grün): Titelmusik leise unter Bild 1–4, Schwarzbild voll, im Spiel 6 s Ausklang, dann Ortsmusik; mit D3.3 + 89 im nächsten Sammelbuild | wie 89 |
| 68 | Tempelszene: Rückkehr des Sonnenamuletts, Ende Kapitel 1 | Gebaut (Build B): Ablauf, fünf Bilder, `[68.kapitelende]`, `[68.suedrand]`; `TempleSceneTest` grün (16.10., 00:5x); **wartet auf Chef** (Test mit Knopf 100 in PR #67). Zur Kenntnis Jerry: `MusicScene.TEMPLE`, `Mode.TempleScene` | – |
| 38 | D4.1 Rauchbündel, Quest vor der Höhle über Morwen, Garrick warnt unter Stufe 3 (D4.1 A, Chef 15.10., 10:5x) | gebaut (`claude/tom-runde-nach-748`, nächster Sammelbuild; Text `[D4.1.rauch.tasche]`; Gegenstand `Story.SMOKE_BUNDLE`, Merker `SMOKE_GIVEN`); weitere Texte von Kreativ, dann bauen | `claude/tom-runde-nach-748` |
| 95 | Atem: „Atem mit Anzeige (Balken rechts) hört man nicht und der Balken funktioniert nicht.“ (Chef 15.10., 16:5x) | Balken (95a) passt (Test 0.1.752); Keuchen bei Jerry | – |
| 96 | Gesprächstext zu lang für das Feld (Chef 15.10., 17:0x) | Test 0.1.752 passt; mit PR #67 auf `main`, dann streichen | wie 94 |
| 93 | „Die Beete westlich gehen nicht bis zum Zaun.“ (Chef 15.10., 16:5x) | Test 0.1.752 passt (`MapTownIso.fenceSpot`); mit PR #67 auf `main`, dann streichen | wie 94 |
| 26 | Kapitel 1 fertig: Zielliste vor Neuem (`LISTE-KAPITEL1.md`) | Toms Teil erledigt (16.10., 00:4x): Ort fertig Dorf, Räume, Wald ohne Lücke außer D3.14 (Lückenliste in der Übergabe); Zufallsspieler grün. Offen: Höhle (13e), Durchspielen durch den Chef nach #67 | – |
| 13e | Höhle „Ort fertig“ (Zuteilung des Chefs 14.10., 16:0x; bleibt bei Tom, D14.3) | D1.3/D1.11, D1.5, 13e.6 auf `main`. Helligkeitsregler bei Jerry (40). Danach D1.7 Leben (Absprache `WorldScreen.kt`). Mond mit D3.14 | – |
| 86 | Bewegung und Übersicht (Chef 14.10., 18:5x) | 86.1–86.4 auf `main` (0.1.750). 86.6/86.9/86.10 gebaut (70cea82d), nächster Sammelbuild mit 89/D3.3/69f; Preise Met 2, Zimmer 5 Gold im Test eichen; Wortlaut bei Kreativ (Rest bei Jerry) | `claude/tom-86-bewegung-rest` |
| 62c | Karte: Lücken, Bekannte/Dienste, Beschriftung, Landkarte/Gebietskarte/Grundriss (62e–62m, 62p) | bis 62r auf `main`; 62i–62k mit 64; 62l später (62m bei Jerry mit 39) | – |
| 59e | Händler: Menge „Alle“, Vorrat je Laden | „Alle“ erledigt (0.1.660); Vorrat je Laden bei Jerry mit 38/39 | – |
| 24 | Animationen nach Spielstart und Kartenwechsel; Zwischenbildschirm (Technik) | Großteil auf `main`; Inhalt (24.6) bei Jerry | – |
| 30 | Abstürze beim Testen (Technik) | beobachten (bei neuem `adb logcat` mit Anleitung); 30.7 Merkliste | – |
| 5 | Dorf draußen, Dorfbewohner als Puppen | auf `main` bis 5.5 | – |
| 63 | Eine Seite „Dein Zug“ für alles Offene | steht; **wartet auf Chef:** Freigabe für Jerry (Teilen) am Fr. | – |
| 70 | Zwischensequenzen, Bild 3 (70.6 A) | in 0.1.752 (Build B); mit PR #67 auf `main`, dann streichen | wie 94 |
| – | Eigene Zeilen kürzen | Erledigtes ins Archiv | – |
