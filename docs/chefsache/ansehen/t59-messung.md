# Tom · Build 59 · 0.1.938 · Messung Ruckeln nach der Blende, Tablet · PR #144
E Technik · Tom · 21.10., 16:02 · [APK (Artefakt bornim-apk)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/39612924567)

Ein Messbuild, am Spiel ändert sich nichts. Nach Jerrys Build 58 installieren. Neu im Test-Reiter unter „Danach 10 s“: welche Hintergrundarbeit lief, während Bilder länger als 50 ms brauchten, und wie oft die Speicherbereinigung lief. Damit finde ich die Ursache der 76 bis 91 Pausen, die auch mit gespeichertem Helden auftreten. Darauf baut 267.1 (Ladeblende) auf.

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 59.1 | 267 | **Handy.** Spiel starten, einmal den Spielstand wechseln, 10 s stehen bleiben, dann Test-Reiter „Gerät zeigen …“ | Zwei neue Zeilen: „Langsame Bilder während: …“ und „Speicherbereinigung danach: …“ | Die Zeilen fehlen oder stehen auf „–“ |
| 59.2 | 267 | **Tablet (abends), Stromsparen aus**, derselbe Weg wie 59.1; vorher im Test-Reiter Langschwert und in die andere Hand die Fackel anlegen | „Held ganz gezeichnet nach … s“ deutlich unter 50,1 s (Build 51 mit Stromsparen an) | Etwa so lange wie mit Stromsparen an |

Zu 59.1 und 59.2: bitte jeweils den ganzen Text aus „Gerät zeigen …“ schicken (ersetzt 57.5).
