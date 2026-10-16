# Dein Zug

Was auf den Chef wartet (63, Beschluss 108 A): je Punkt eine Datei. Die Ordnerliste oben ist die Liste; erledigt heißt Datei löschen.

- `entscheiden/`: Fragen mit Empfehlung, Name `<nr>-<stichwort>.md` (Nummer ohne Punkt, z. B. `72s1-gefaehrte-kapitel2.md`)
- `ansehen/`: Testbitten, Name `t<build>-<stichwort>.md` (z. B. `t757-sammelbuild.md`) oder `<nr>-<stichwort>.md`
- `bilder/`: JPG oder WebP, höchstens 800 px breit und 60 KB, höchstens 3 je Punkt. Größere Bilder und Hörproben nur über Telegram (`meldung.sh --datei`), in der Datei vermerkt: „Großbild: Telegram TT.MM. HH:MM“.

Jede Datei: Überschrift „<Nr.> · <Frage>“, darunter Absender und Zeit, dann Frage, Empfehlung, stärkstes Gegenargument (lange Begründung in `<details>`). Telegram-Sprungmarke `[72s.1](dz:72s1)` führt auf die Datei (`tools/meldung.sh`).
