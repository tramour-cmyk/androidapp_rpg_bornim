# 1727b · Gilt für freie Lizenzen weiter nur „kommerzielle Nutzung erlaubt“, mit Lizenzhinweis im Spiel, wo die Lizenz ihn verlangt?
Sokrates · 21.11., 21:20 · 7 Firma · aus 1727, Querprofil Fremde Inhalte F4a
Kurz: `LISTE-QUELLEN.md` ist strenger als `CLAUDE.md`; angleichen, MIT- und OFL-Hinweis in „Über das Spiel“.
Beim Chef, weil: Lizenz

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`CLAUDE.md` „Technik und Sicherheit“; `docs/LISTE-QUELLEN.md`:5, :82–88 (Lücken 2, 4); `docs/LISTE-BESTAND.md`:7; `docs/entwurf/1727-muster/profil-fremde-inhalte.md`:24

**Frage:** `CLAUDE.md` verlangt von freien Inhalten nur „offene Lizenz, die kommerzielle Nutzung erlaubt“; die strengen Bedingungen (jede Engine, unbefristet, ohne Nennung, ohne Umsatzgrenze) gelten für Gekauftes. `LISTE-QUELLEN.md`:5 nennt die strengen Bedingungen für alles. Im Spiel liegen schon Schriften unter OFL und Shader-Teile unter MIT (REEBOO), die einen Lizenzhinweis verlangen. Soll `CLAUDE.md` gelten (Liste angleichen, Hinweis in „Über das Spiel“ wie bei Godot), oder sollen die strengen Bedingungen auch für Freies gelten?

**Votum:** „1727b A“: `CLAUDE.md` gilt; `LISTE-QUELLEN.md`:5 angleichen; Lizenzhinweise für MIT und OFL in „Über das Spiel“ (wie Godot, 497); öffentlich ablegen darf man CC0 und Lizenzen, die die Weitergabe erlauben (OFL, MIT), sonst nur privat (`LISTE-BESTAND.md`:7).

**Berührt:** `LISTE-QUELLEN.md`, `LISTE-BESTAND.md` (Sokrates), „Über das Spiel“ (Tom, Vorgang bei A), Querprofil Fremde Inhalte (1727).

**Begründung:** `CLAUDE.md` ist die Quelle der Regel (348.12c a); die Liste hat sie verschärft abgeschrieben. Nennung ist bei Freiem billig (eine Zeile im Menü), Verzicht kostet die Schriften Fondamento und Alegreya.

**Sachverhalt:**
- OFL-Schriften im öffentlichen Repo: `godot/daten/fondamento.ttf`, `godot/kampf/schrift/alegreya_*.ttf` (`tools/schrift/QUELLEN.md`:3).
- MIT-Teil in REEBOO (Hashfunktionen in Grass, Water, Surface; `LISTE-QUELLEN.md` Lücke 2).
- Fondamento hat einen Reserved Font Name; wir ändern die Schrift nicht, also unschädlich; Kopf von `QUELLEN.md` berichtigt Sokrates (Lücke 4, Text).

**Auswertung:**
- **A (Empfehlung):** angleichen, eine Zeile Lizenzhinweise; kein Inhalt fällt weg.
- **B:** strenge Bedingungen für alles; OFL-Schriften und REEBOO-Teil müssen ersetzt werden.
- **Stärkstes Gegenargument gegen A:** zwei Maßstäbe sind fehleranfälliger als einer. Entkräftung: das Querprofil Fremde Inhalte schickt jede Lizenz, die nicht sicher passt, als „Frage“ an Sokrates (Archiv 21.11., 20:52).

**Folgerungen:** A: Sokrates gleicht beide Listen an; Vorgang an Tom „Lizenzhinweise MIT/OFL in ‚Über das Spiel‘“.

Antwort: …
