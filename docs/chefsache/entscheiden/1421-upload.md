# 142.1 · Knopf „Play-Upload“ ohne Gerätetest auf main?
Tom · 25.10., 17:38 · T Technik · Muss
Kurz: Der Knopf, der das App-Paket für Google Play (AAB) per Dienstkonto in den internen Test lädt, ist gebaut. Darf er ohne Gerätetest auf `main`?

## Frage

Darf `claude/tom-1421-play-upload` (955d8ef2b) ohne Gerätetest auf `main`? Ja / Nein / Noch nicht.

## Votum

Ja.

## Berührt

142.1 (Play Console); 142 (Pflichttest mit 12 Testern); später die Godot-Fassung.

## Begründung

- Eine Datei (`android.yml`), keine Spiellogik: ein neues Häkchen beim Start von Hand („AAB in den internen Test der Play Console“); nur dann und nur auf `main` lädt der Lauf sein AAB mit dem Secret `PLAY_DIENSTKONTO` in den internen Test. Normale Builds laufen wie bisher und laden nichts hoch.
- Der Upload läuft absichtlich nur auf `main`; auf dem Zweig lässt er sich darum nicht ausprobieren.

## Sachverhalt

- Dienstkonto und Secret stehen (dein Wort 16:46). Der Upload braucht einen neuen Build (interne Versionsnummer höher als die zuletzt hochgeladene 1033); der Knopf baut ihn gleich mit.
- Werkzeug: `r0adkll/upload-google-play` v1 (verbreitet, quelloffen), interner Test, Freigabe sofort, Zuordnungsdatei für Absturzberichte mit.

## Auswertung

**Stärkstes Gegenargument:** das alte Spiel ruht (348); ein Upload bringt heute kaum etwas, und `main` wird ohne Not angefasst. Dagegen: die Änderung wirkt nur auf Knopfdruck, und dasselbe Dienstkonto trägt später die Godot-Fassung und den Pflichttest (142). „Noch nicht“ geht auch; dann wartet der Zweig.

Risiko: Google gibt das Recht oft erst nach Stunden frei; ein früher Fehler wegen fehlender Berechtigung (roter Lauf unter „Actions“) heißt nur: später noch einmal. Meldet Google „draft app“, stelle ich die Freigabe auf Entwurf um.

## Folgerungen

Bei „ja“: ich merge auf `main`; dann du: in GitHub „Actions“ → „Build APK“ → „Run workflow“, Branch `main`, Häkchen „AAB in den internen Test der Play Console“ setzen („Release veröffentlichen“ aus lassen) → grüner Knopf „Run workflow“ → nach etwa 10 Minuten steht der neue Build im internen Test.
