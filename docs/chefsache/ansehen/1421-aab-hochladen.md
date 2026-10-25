# 142.1 · AAB von Hand in die Play Console hochladen
Tom · 25.10., 10:49 · B Betrieb · M (Chef 25.10., 08:08, über Sokrates: alten Stand vor Godot in die Play Console)

## Frage

Lädst du das AAB aus Lauf 1029 (versionCode 1030) von Hand in die Play Console hoch? Danach richte ich Dienstkonto und Upload-Action ein.

## Empfehlung

Ja, hochladen: [Lauf 1029](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/40175595311), Artefakt mit dem AAB unten auf der Seite. Track **Interner Test**. Wenn Google nach der App-Signatur fragt: „Von Google verwaltet“ wählen; unser Schlüssel ist dann nur der Upload-Schlüssel. Ist die App in der Console noch nicht angelegt, zuerst „App erstellen“.

## Berührt

142.1 (Play Console), später 348 (die Godot-Fassung zählt über 1030 weiter).

## Begründung

Google verlangt, dass das erste AAB einer App von Hand hochgeladen wird. Erst danach kann ein Dienstkonto automatisch hochladen.

## Sachverhalt

- Alter Stand vor Godot: `main` bis Merge 4083f11c (Build 89, freigegeben 07:45), Paketname `de.bornim.game`.
- versionCode 1030 (`run_number + 1`), signiert mit dem Upload-Schlüssel aus den GitHub-Secrets.

## Auswertung

Stärkstes Gegenargument: Damit liegt ein Stand in der Console, der nicht mehr weiterentwickelt wird. Das ist gewollt (dein Auftrag 08:08), im internen Test sieht ihn niemand außer dir. Außerdem: Die Godot-Fassung muss später mit demselben Upload-Schlüssel signieren und über 1030 weiterzählen, sonst ist ein Schlüsseltausch bei Google nötig. Das ist eingeplant (Vorrat Team Tom, „Zu 142.1“).

## Folgerungen

Nach dem Hochladen sag kurz „142.1 hochgeladen“. Dann folgen Dienstkonto und Upload-Action.
