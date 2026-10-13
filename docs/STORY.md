# Story-Vorlage (Inhaltsverzeichnis)

Freigegebene Spieltexte (Thema 41), festgelegt von Nutzer und Berater. Hier nur Regeln und Verzeichnis; die Texte stehen in Teildateien. Wer an einem Text baut, öffnet nur die passende Teildatei, am besten gezielt über die Marke (`grep -n "\[67\." docs/STORY1.md`).

## Regeln

- **Wortgetreu übernehmen.** Englisch übersetzen Tom und Jerry beim Bauen selbst. Fehlt oder passt ein Text nicht: Vorschlag in `OFFEN.md` unter 41, nicht selbst erfinden. Tippfehler und Zeichensetzung direkt korrigieren (Commit beginnt mit „Text:“).
- **Marke je Text** in eckigen Klammern: `[Thema.kurz]`, z. B. `[64d.greif]`, `[67.vor.1]`. Die Marke bleibt fest, auch wenn sich der Text ändert; sie darf im Code als Kommentar stehen.
- **Bedingung** steht hinter der Marke in Klammern: wann der Text erscheint.
- `{name}` ist der Name des Helden.
- **Teilung:** je Kapitel eine Datei. Wird eine größer als etwa 15 KB, nach Ort oder Quest teilen (`STORY2-hoehle.md`) und hier eintragen.
- Plot und Grobzusammenfassungen stehen nicht hier, sondern im [Storyplan](https://claude.ai/code/artifact/326c63d4-c16c-4132-af0e-b03a7ff9158d).

## Teildateien

| Datei | Inhalt | Stand |
|---|---|---|
| `STORY1.md` | Kapitel 1: Intro (69), Chronik „Bisher geschehen“ (64d), Hörensagen (62i), geänderte Dialogzeilen (41), Südrand (67) | freigegeben 13.10. |

Die übrigen Texte von Kapitel 1 stehen bisher nur in `Story.kt`/`Jobs.kt`; sie kommen nach `STORY1.md`, wenn sie geändert werden.
