# 399.1a · Fester Schlüssel für die Godot-Builds
Tom · 28.10., 14:28 · B Umzug
Kurz: Build 130 ließ sich nicht installieren, weil die Builds je nach Zweig mit verschiedenen Schlüsseln signiert werden. Darf ich einen kleinen Ablauf ohne Spiellogik direkt auf `main` legen, damit alle Godot-Builds denselben Schlüssel tragen?

**Frage:**
- **a)** Ja: ein kleiner Ablauf auf `main` legt einen Schlüssel an und hält ihn mit einem wöchentlichen Lauf frisch; jeder Build holt ihn von dort. Für 130 deinstallierst du die alte Godot-Probe wie per Telegram gesagt; beim Build danach noch genau einmal, dann nie wieder.
- **b)** Noch nicht: bis zur Übernahme der Spielfassung auf `main` bleibt der Schlüssel von 130. Bei der Übernahme kommt ein neuer, dann deinstallierst du dort einmal. Läuft 7 Tage kein Build, verfällt der Schlüssel vorher, dann noch einmal.

**Votum:** a.

**Berührt:** 399.1 (Spielfassung), 348 (Umzug Godot).

## Begründung

Code auf `main` braucht dein Ja (Kleinigkeit ohne Spiellogik, ohne Gerätetest).

## Sachverhalt

- Der Schlüssel liegt im Zwischenspeicher von GitHub. Was ein Zweig dort ablegt, sieht nur dieser Zweig; was auf `main` liegt, sehen alle Zweige.
- Der Zweig der Spielfassung hat sich beim ersten Build einen eigenen Schlüssel angelegt; frühere Builds kamen von einem anderen Zweig mit anderem Schlüssel. Android lehnt ein Update mit anderem Schlüssel ab.
- Was 7 Tage niemand liest, löscht GitHub.

## Auswertung

Stärkstes Gegenargument zu a: Du deinstallierst kurz nach 130 noch einmal. Bei b deinstallierst du ebenfalls mindestens einmal, nur später, und jeder Zweigwechsel oder 7 Tage ohne Build bringen ein weiteres Mal.

## Folgerungen

- a: Ablauf auf `main`; `godot.yml` im Zweig holt den Schlüssel von dort und legt keinen eigenen mehr an. Etwa eine halbe Stunde.
- b: nichts jetzt; bei der Übernahme auf `main` dasselbe wie a.

Antwort: …
