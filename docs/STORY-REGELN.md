# Story-Vorlage (Inhaltsverzeichnis)

Freigegebene Spieltexte (Thema 41), festgelegt von Nutzer und Berater. Hier nur Regeln und Verzeichnis; die Texte stehen in Teildateien. Wer an einem Text baut, öffnet nur die passende Teildatei, am besten gezielt über die Marke (`grep -rn "\[67\." docs/`).

## Regeln

- Übernehmen, Übersetzen, Vorschläge und Tippfehler: `CLAUDE.md` „Story und Dialoge“.
- **Marke je Text** in eckigen Klammern: `[Thema.kurz]`, z. B. `[64d.greif]`, `[67.vor.1]`. Die Marke bleibt fest, auch wenn sich der Text ändert; sie darf im Code als Kommentar stehen.
- **Bedingung** steht hinter der Marke in Klammern: wann der Text erscheint.
- `{name}` ist der Name des Helden.
- **Bornim** hat etwa 50 Einwohner (Nutzer 14.10., 69e.4); Szenen mit „dem ganzen Dorf“ zeigen höchstens so viele, der Tempel fasst 25–30.
- **Feste Namen** (Nutzer 13.10., 21:29; D2.4/D2.13): überall gleich, auch im Englischen. Krogg ist ein **Bärenschrat** / **bearbrute**, Grak ein **Goblin-Hauptmann** / **goblin captain** (870.15, `DESIGN-BRS.md` 12; nie Grottenschrat, Bugbear, Hobgoblin); Krogg heißt „Krogg der Grobian“ / „Krogg the Brute“; Tempel des Morgenlichts = **Temple of the Dawnlight**; Kräuterfrau Morwen = **Morwen the Herbalist**; Tiefer Flüsterwald = **Deep Whisperwood** (nie „Tiefer Wald“ / „Deep Forest“); Aufträge = **Quests**; Fertigkeit Kräutersammeln = **Foraging** (857a, nie „Kräuterkunde“, „Herbalism“, „Herb lore“; Morwen bleibt „the Herbalist“).
- **Englische Spieltexte** (Homer 24.10., 338.1a; gilt für Godot, 652): (1) US-Schreibung: color, gray, smolder, recognize, practice (Verb), traveler, toward, anymore, dreamed, around (Präposition). (2) Feste Namen wie oben und `[423.namen]` (`STORY-HANDBUCH-3.md`); Main quest, Side quests, the Elder groß. (3) Der Wert heißt **Life** (Menü, Handbuch: „Leben/Life“, 683, `[423.werte.ab]`); Zahlen und Kampfmeldungen kurz **HP** („+5 HP“, deutsch „TP“); nie „life points“ (Homer 10.11., aus 817). (4) Auslassung „…“ (ein Zeichen, ohne Leerzeichen davor), nie „...“; Anführung “…”, nie »…«. (5) Regelbegriffe nur aus `[423.namen]` und `[870.14.namen]` (BRS); keine SRD-Begriffe (ability scores, Armor Class, Hit Die, spell save DC) in neuen Texten. (6) Ein Wort je Sache: Cover, switch rows, Autopilot, Combat/battle (nicht „fight“, außer „Easy fight“), potions, gear, shop, Lightspark, Equipped. (7) Kampfmeldungen im Präsens (gains, reaches, loots); keine Pokémon-Sätze („A wild … appears!“).
- **Gruppen je Kapitel** (77d, Nutzer 13.10.): **K1-H** Hauptquest, **K1-N** Nebenquests, **K1-Z** Zwischensequenzen, **K1-W** Welt (Chronik, Hörensagen, Stimmen hinter Türen); Kapitel 2 entsprechend K2-H usw. Die Marken `[Thema.kurz]` bleiben unverändert.
- **Teilung nach Gruppe; Kapitelübergreifendes in eigener Datei** (77e): je Kapitel `STORY-K<n>-HANDLUNG.md` (H, N, Z) und `STORY-K<n>-WELT.md` (Welt); Texte, die in allen Kapiteln gelten, in eigener Datei (`STORY-BLENDE.md`). Jede Datei höchstens etwa 15 KB; neue hier eintragen.
- Plot und Grobzusammenfassungen stehen nicht hier, sondern im Storyplan `STORY-PLAN.md` (Teile `STORY-PLAN-K1.md`, `kapitel2/STORY-PLAN-K2.md` mit Karte `kapitel2/STORY-K2-KARTE.svg`).

## Teildateien

| Datei | Inhalt | Stand |
|---|---|---|
| `STORY-K1-HANDLUNG.md` | Kapitel 1, K1-H/N/Z: geänderte Dialogzeilen (41), rund um die Tempelszene (68), Intro (69), Tempelszene (68), Lyras Befreiung und Sammelaufträge `[356.…]` | freigegeben 13.10. |
| `STORY-K1-WELT.md` | Kapitel 1, K1-W: Chronik „Bisher geschehen“ (64d), Hörensagen (62i), Gwenna (41), Stimmen hinter Türen (73b), Südrand (67) | freigegeben 13.10. |
| `STORY-BLENDE.md` | Zwischenbildschirm (24), alle Kapitel: Orte, Kampfbeginn, je Gegner; Marken `[24.…]`; Einstellung Schwierigkeit `[39.2.…]`; Söldner-Namen `[72.10a.5.…]` | Texte seit 11.10., Marken 13.10. |
| `kapitel2/STORY-K2-ENTWURF.md` | Kapitel 2, Entwurf aller Texte `[41.…]`, `[24.ort.…]` mit Prüfpunkten; beim Bau nach `STORY-K2-HANDLUNG.md`/`-WELT.md` teilen | frei seit 18.10. (72s.1); 41.1 ja, Zeilen 19.10.; offen 6.4 (41.2) |
| `STORY-MENUE.md` | Spielermenü, alle Kapitel: Erklärung bei langem Druck `[326.sys.…]`, Hinweis `[326.hinweis]`, Reiternamen; Zeichen Kampfsystem `[296.2.kampfsystem]` | Texte seit 23.10. |
| `alt/STORY-ANLEITUNG.md` | Anleitung im Systemmenü der Kotlin-Fassung (352.1): Regeln grob, Bildschirme, Fähigkeiten je Klasse `[352.…]` | in `alt/` seit 09.11. (650.2) |
| `STORY-HANDBUCH-1.md`, `-2.md`, `-3.md` | Spielerhandbuch Bornimer Rollenspielsystem (BRS, 451; 423), ersetzt 352 mit dem Bau: Held, Fertigkeiten, Stufe; Pfad, Kampf, Welt, Ruf; Herstellen, Abnutzung, feste englische Namen `[423.…]` | Entwurf 01.11., Chefsache 423 |
| `STORY-LEHRMEISTER-K1.md` | Kapitel 1, Pfade: Einladungen, Anwärter, Hinweise, Grenze der fünf Lehrmeister, Wechsel, Nachfrage, Karte, Varianten `[447.4.…]` | fertig 03.11. (1B 2A), Bau 447.4.1 |
| `STORY-RUF-K1.md` | Kapitel 1, Meisterschaften (Morwen, Garrick, Rowena; Borin zu Schmied und Runen) und Ruf-Gespräche `[447.4.…]`, `[447.4.ruf.…]`, mit Varianten | fertig 03.11., Bau 447.4.1 |
| `STORY-VARIANTEN-K1.md`, `-K1-WALD.md` | Kapitel 1, Gespräche in drei Wortlauten (504): jede Zeile, die man wiederholt hört `[504.…]`; Regeln für den Bau | Vorschlag 03.11., Bau 504.1 |
| `STORY-K1-FERTIGKEITEN.md` | Kapitel 1, Fertigkeiten ohne Kampf (807 A): Pim überreden, Goblin-Späher einschüchtern, Verband `[807.…]`; zweiter Knopf bei jeder Wahl `[1074.zweit]` | fest 10.11. (807a A), 1074 Homer 12.11.; Bau 841, 842 |
| `kapitel2/STORY-WAHLEN.md` | Vorschlag Wahlen mit Charisma in Kapitel 2 (133), keine Texte | Chefsache 133 |
| `STORY-BRS-KAMPF.md`, `-KOENNEN.md`, `-HELD.md` | Umzug auf das BRS (870.14): Begriffe EN `[870.14.namen]`, Würfelkasten, Meldungen, Zustände, Lohn, Tipps, Ansagen, Kampfhandlungen, Zauber; Heldenreiter (ersetzt `[817.…]`), Gegenstandsfenster, Truhe cave_3, Wanderer, Schwächen `[870.14.…]` | fertig 10.11., Bau 870.4, 870.5 |
| `STORY-BRS-ANLEITUNG.md`, `-OBERFLAECHE.md` | Umzug auf das BRS (870.15): Handbuch im Spiel (ersetzt 352, Folge der Absätze aus `[423.…]`), Oberfläche „ui“ und „rast“, Über das Spiel, Absichten der Gegner ohne Würfel, Bärenschrat und Goblin-Hauptmann, Gegenstände mit SRD-Namen `[870.15.…]` | fertig 10.11., Bau 870.9, 870.13 |
| `STORY-BRS-ERSCHAFFUNG.md` | Erschaffung: Erklärung bei langem Druck für Grundwerte, Völker, Herkünfte, Fertigkeiten `[954.1.…]` | fertig 11.11., Bau 954 (Wählbarkeit Chefsache 954a) |
| `STORY-SPIEL.md` | Kampf, Rast, Zustände, alle Kapitel: MARS `[72.10a.T.…]`, `[72.10.…]`, Aufstellung `[72.10a.8.…]`, Klassen `[72.10a.9.…]`, Zweitwaffe `[72.10a.11.…]`, Regelseite `[201.…]`, Tiptexte `[204T.…]`, Ansagen `[210T.…]`, Ring `[219T.…]`, `[219.ring.…]`, `[219.4T.…]`; Umzielen `[301.stattdessen]`; Abknien `[303.knie]`; Nahkampf von hinten `[223T.…]`; Laden `[59e.1T.…]`; Feuerball `[72.14.…]`; Rast und Rowena `[86.…]`; betrunken, außer Atem `[86.9.…]`; Fackel und Leuchtfunke `[84.1.…]`, `[84.5.…]`; Über das Spiel `[312.…]`; harte Schläge `[354.…]`; Kampfende MARS `[296.2.…]`; Fackel im Kampf `[344.2.…]`; Frisuren der Erschaffung `[405.frisur]` | Texte seit 18.10. |

Die übrigen Texte von Kapitel 1 stehen bisher nur in `Story.kt`/`Jobs.kt`; sie kommen in die passende Teildatei, wenn sie geändert werden.
