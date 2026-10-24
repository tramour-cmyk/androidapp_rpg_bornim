# Tom · Build 85 · 0.1.1012 · Absturz Speicher, Fackel in Grundrissen, Fackel ablegen · PR #169
E Technik, E Welt · Tom · 24.10., 16:36 · [APK (Artefakt bornim-apk)](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/40102983546)

Ein Weg: „Weiterspielen“; im Dorf am Tag die Fackel anlegen, in die Schänke und wieder hinaus; eine Minute weiterspielen, Fackel im Menü ablegen; dann in den Wald und den tiefen Wald, zwei Kämpfe, lange herumgehen; zum Schluss Test-Reiter; über Build 84 installieren.

| # | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|
| 85.1 | 344.1 | Dorf am Tag: Menü, Ausrüstung, Fackel in die Nebenhand, zurück; in die Schänke gehen; wieder hinaus | draußen brennt die Fackel mit Flamme; in der Schänke gehalten ohne Flamme; draußen wieder Flamme | draußen am Tag ohne Flamme oder in der Schänke mit Flamme |
| 85.2 | 345 | eine Minute nach dem Anlegen (nicht gleich nach dem ersten Start des Builds, dann wird noch alles neu gezeichnet): Menü, Ausrüstung, Fackel ablegen, zurück ins Spiel | Fackel sofort weg | 2–3 s noch in der Hand |
| 85.3 | 346 | Test-Reiter: „Kartenzoom“ antippen, bis „(weit, bisher)“ steht; in Wald und tiefem Wald zwei beliebige Kämpfe, danach mindestens 10 Minuten herumgehen; dann Test-Reiter, Zeile „Vorgezeichnet: Held …“ (steht erst nach einem Kampf) | kein Absturz; am Ende der Zeile „Speicher 512 MB, geräumt n×“ mit n unter 10 | Absturz „OutOfMemory“; oder n 10 und mehr, oder alle 20 s ein kurzes Stocken (bitte n melden) |
