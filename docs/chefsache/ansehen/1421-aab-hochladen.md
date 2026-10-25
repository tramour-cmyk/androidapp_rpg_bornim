# 142.1 · AAB von Hand in die Play Console hochladen
Tom · 25.10., 11:33 · B Betrieb · M (Chef 25.10., 08:08, über Sokrates: alten Stand vor Godot in die Play Console)

**Stand (Sokrates, Bild Chef 25.10., 11:50):** Im internen Test aktiv ist 1030 (0.1.1029), veröffentlicht 11:44, nicht 1031. Signatur: Google verwaltet, ohne Rückfrage. Offen: 1031 nachladen, Tablet prüfen, Tester-Link aus dem Reiter „Tester“ weitergeben. 11:58: Chef am Handy über den Tester-Link: „kann nicht heruntergeladen werden“ (alte App deinstalliert).

## Frage

Lädst du das neue AAB von Hand in die Play Console hoch? Es kommt aus Lauf 1030 auf dem Zweig `claude/tom-1421-sdk36` und trägt versionCode 1031 (Versionsnummer = Lauf + 1) mit Zielversion 36. Das erste AAB (versionCode 1030 aus Lauf 1029) hat Google wegen Zielversion 35 abgelehnt; zur Umstellung siehe [1421-sdk36](../entscheiden/1421-sdk36.md). Danach richte ich Dienstkonto und Upload-Action ein.

## Empfehlung

Ja, hochladen: [Lauf 1030](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/40184602458), Artefakt **bornim-aab** unten auf der Seite (ZIP, darin `bornim.aab`). Track **Interner Test**. Fragt Google nach der App-Signatur: „Von Google verwaltet“ wählen; unser Schlüssel ist dann nur der Upload-Schlüssel. **Am Tablet prüfen: Tablet drehen, das Spiel muss im Hochformat bleiben.**

## Berührt

142.1 (Play Console), später 348 (die Godot-Fassung zählt über 1031 weiter).

## Begründung

Google verlangt, dass das erste AAB einer App von Hand hochgeladen wird. Erst danach kann ein Dienstkonto automatisch hochladen.

## Sachverhalt

- Alter Stand vor Godot: `main` bis Merge 4083f11c (Build 89, freigegeben 07:45), dazu nur die Zielversion 36 (Zweig `claude/tom-1421-sdk36`, 5c6c707e5). Paketname `de.bornim.game`.
- versionCode 1031 (`run_number + 1`), signiert mit dem Upload-Schlüssel aus den GitHub-Secrets.

## Auswertung

Stärkstes Gegenargument: Damit liegt ein Stand in der Console, der nicht mehr weiterentwickelt wird. Das ist gewollt (dein Auftrag 08:08), im internen Test sieht ihn niemand außer dir. Die Godot-Fassung muss später mit demselben Upload-Schlüssel signieren und über 1031 weiterzählen, sonst ist ein Schlüsseltausch bei Google nötig. Das ist eingeplant (Vorrat Team Tom, „Zu 142.1“).

## Folgerungen

Nach dem Hochladen sag kurz „142.1 hochgeladen“ und ob das Hochformat am Tablet hält. Dann geht die Zielversion auf `main`, und es folgen Dienstkonto und Upload-Action.
