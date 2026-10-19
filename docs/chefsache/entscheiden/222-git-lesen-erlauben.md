# 222 · Lesende git-Befehle fest erlauben?
Sokrates · 19.10., 15:59 · Q Ablauf · M?

Chef 15:57: „Wieso braucht Jerry überhaupt eine Erlaubnis??? Das sollte doch können und dürfen, oder?“

**Anlass:** Jerry wollte um 14:46 nach dem Merge von PR #122 nur prüfen, ob Build 34 mit `main` kollidiert (`git merge-tree`, `git diff`; beide ändern nichts). Die Sicherheitsprüfung des Auto-Modus der App lehnte ab („Merge Without Review“). Unsere Regeln verbieten das nicht.

**Empfehlung:** In `.claude/settings.json` unter `permissions.allow` fest erlauben: `Bash(git fetch:*)`, `Bash(git diff:*)`, `Bash(git merge-tree:*)`. Echtes Zusammenführen (`git merge`, PR mergen) bleibt unter Prüfung.

**Stärkstes Gegenargument:** Jede feste Erlaubnis schwächt die Prüfung. Diese drei Befehle schreiben aber weder auf `main` noch führen sie zusammen.

**Berührt:** alle Sitzungen (Tom, Jerry); keine Vorgänge im Spiel.
