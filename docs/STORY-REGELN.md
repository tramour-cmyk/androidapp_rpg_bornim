# Story-Vorlage (Inhaltsverzeichnis)

Freigegebene Spieltexte (Thema 41), festgelegt von Nutzer und Berater. Hier nur Regeln und Verzeichnis; die Texte stehen in Teildateien. Wer an einem Text baut, öffnet nur die passende Teildatei, am besten gezielt über die Marke (`grep -rn "\[67\." docs/`).

## Regeln

- Übernehmen, Übersetzen, Vorschläge und Tippfehler: `CLAUDE.md` „Story und Dialoge“.
- **Marke je Text** in eckigen Klammern: `[Thema.kurz]`, z. B. `[64d.greif]`, `[67.vor.1]`. Die Marke bleibt fest, auch wenn sich der Text ändert; sie darf im Code als Kommentar stehen.
- **Bedingung** steht hinter der Marke in Klammern: wann der Text erscheint.
- `{name}` ist der Name des Helden.
- **Bornim** hat etwa 50 Einwohner (Nutzer 14.10., 69e.4); Szenen mit „dem ganzen Dorf“ zeigen höchstens so viele, der Tempel fasst 25–30.
- **Feste Namen** (Nutzer 13.10., 21:29; D2.4/D2.13): überall gleich, auch im Englischen. Bugbear = **Grottenschrat** (Krogg heißt „Krogg der Grobian“ / „Krogg the Brute“); Tempel des Morgenlichts = **Temple of the Dawnlight**; Kräuterfrau Morwen = **Morwen the Herbalist**; Tiefer Flüsterwald = **Deep Whisperwood** (nie „Tiefer Wald“ / „Deep Forest“); Aufträge = **Quests**.
- **Gruppen je Kapitel** (77d, Nutzer 13.10.): **K1-H** Hauptquest, **K1-N** Nebenquests, **K1-Z** Zwischensequenzen, **K1-W** Welt (Chronik, Hörensagen, Stimmen hinter Türen); Kapitel 2 entsprechend K2-H usw. Die Marken `[Thema.kurz]` bleiben unverändert.
- **Teilung nach Gruppe; Kapitelübergreifendes in eigener Datei** (77e): je Kapitel `STORY-K<n>-HANDLUNG.md` (H, N, Z) und `STORY-K<n>-WELT.md` (Welt); Texte, die in allen Kapiteln gelten, in eigener Datei (`STORY-BLENDE.md`). Jede Datei höchstens etwa 15 KB; neue hier eintragen.
- Plot und Grobzusammenfassungen stehen nicht hier, sondern im Storyplan `STORY-PLAN.md` (Teile `STORY-PLAN-K1.md`, `STORY-PLAN-K2.md` mit Karte `STORY-K2-KARTE.svg`).

## Teildateien

| Datei | Inhalt | Stand |
|---|---|---|
| `STORY-K1-HANDLUNG.md` | Kapitel 1, K1-H/N/Z: geänderte Dialogzeilen (41), rund um die Tempelszene (68), Intro (69), Tempelszene (68) | freigegeben 13.10. |
| `STORY-K1-WELT.md` | Kapitel 1, K1-W: Chronik „Bisher geschehen“ (64d), Hörensagen (62i), Gwenna (41), Stimmen hinter Türen (73b), Südrand (67) | freigegeben 13.10. |
| `STORY-BLENDE.md` | Zwischenbildschirm (24), alle Kapitel: Orte, Kampfbeginn, je Gegner; Marken `[24.…]`; Einstellung Schwierigkeit `[39.2.…]`; Söldner-Namen `[72.10a.5.…]` | Texte seit 11.10., Marken 13.10. |
| `STORY-K2-ENTWURF.md` | Kapitel 2, Entwurf aller Texte `[41.…]`, `[24.ort.…]` mit Prüfpunkten; beim Bau nach `STORY-K2-HANDLUNG.md`/`-WELT.md` teilen | frei seit 18.10. (72s.1); 41.1 ja, Zeilen 19.10.; offen 6.4 (41.2) |
| `STORY-WAHLEN.md` | Vorschlag Wahlen mit Charisma in Kapitel 2 (133), keine Texte | Chefsache 133 |
| `STORY-SPIEL.md` | Kampf, Rast, Zustände, alle Kapitel: MARS `[72.10a.T.…]`, `[72.10.…]`, Aufstellung `[72.10a.8.…]`, Klassen `[72.10a.9.…]`, Zweitwaffe `[72.10a.11.…]`, Regelseite `[201.…]`, Tiptexte `[204T.…]`, Ansagen `[210T.…]`, Ring `[219T.…]`, `[219.ring.…]`, `[219.4T.…]`; Umzielen `[301.stattdessen]`; Abknien `[303.knie]`; Nahkampf von hinten `[223T.…]`; Laden `[59e.1T.…]`; Feuerball `[72.14.…]`; Rast und Rowena `[86.…]`; betrunken, außer Atem `[86.9.…]`; Fackel und Leuchtfunke `[84.1.…]`, `[84.5.…]`; Über das Spiel `[312.…]` | Texte seit 18.10. |

Die übrigen Texte von Kapitel 1 stehen bisher nur in `Story.kt`/`Jobs.kt`; sie kommen in die passende Teildatei, wenn sie geändert werden.
