# 318 · Knappheit über die Einstellung statt über eine Regel?
Sokrates · 22.10., 21:3x · B Abläufe · K (Chef 22.10., 21:28: Höflichkeit per Einstellung, JSON oder Skript ausschalten? Code-Sitzung, kein Plauderchat; Messung 316)

## Befund

`CLAUDE.md` steht in den Sitzungen als Hinweis neben vielen anderen; die Grundhaltung des Modells (höflich, erklärend, Fehler eingestehen) setzt die Systemanweisung. Zwei Stellen erreichen diese Ebene, beide heute ungenutzt:
- **Antwortstil** (`outputStyle` in `.claude/settings.json`, Datei in `.claude/output-styles/`): ersetzt den Ton der Systemanweisung für jede Sitzung des Repos.
- **Anhang an die Systemanweisung** beim Start (`append_system_prompt`, den `lauf.py` beim Anlegen einer Sitzung mitgeben kann).

## Vorschlag

1. Ein Stil „Knapp“ (wenige Zeilen): nur Stand, Befund, Frage; keine Entschuldigung, keine Ankündigung, kein Bericht über Dateien und Commits; Fehler still beheben; Ausnahme Sokrates in der Beratung.
2. Einen Tag Versuch, dann mit derselben Zählung wie 316 messen; wirkt es nicht, zurück.
3. Umsetzung Perikles; die Zeile „Sparsam“ in `CLAUDE.md` Haltung 5 bleibt, nichts kommt dazu.

## Stärkstes Gegenargument

Ganz abschalten lässt sich die Höflichkeit nicht; sie sitzt im Training, auch eine Systemanweisung dämpft sie nur. Ob Cloud-Sitzungen den Stil aus `settings.json` übernehmen, ist nicht geprüft (die übrigen Einstellungen dort wirken). Der Gewinn ist Lesezeit, kaum Geld (316: Chattext etwa 4 % einer Sitzung).

## Empfehlung

**Ja, 1 bis 3 als Versuch.**

Berührt: 316, 315.
