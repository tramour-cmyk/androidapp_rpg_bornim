# 1727b · Gelten „ohne Nennung, jede Engine, unbefristet, ohne Umsatzgrenze“ nur für Gekauftes, für freie Inhalte nur „kommerzielle Nutzung erlaubt“?
Sokrates · 21.11., 21:19 · 7 Firma · aus 1727 (Umbau der Arbeitsweise), Querprofil Fremde Inhalte F4a
Kurz: `CLAUDE.md` ist zweideutig, `LISTE-QUELLEN.md` liest es streng für alles; unsere OFL-Schriften und der MIT-Teil im Spiel brauchen die milde Lesart.
Beim Chef, weil: Lizenz

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`CLAUDE.md` „Technik und Sicherheit“; `docs/LISTE-QUELLEN.md`:5, :82–88; `docs/LISTE-BESTAND.md`:7; `godot/skripte/hauptmenue.gd`:472, :497, :502; `godot/tests/lizenz_497.gd`)

**Frage:** `CLAUDE.md` sagt: fremde Inhalte „nur mit offener Lizenz, die kommerzielle Nutzung erlaubt (z. B. CC0), oder gekauft …, wenn die Lizenz den Verkauf in jeder Engine erlaubt, unbefristet, ohne Nennung und Umsatzgrenze“. Man kann das „wenn …“ nur auf Gekauftes beziehen oder auf beides. `LISTE-QUELLEN.md`:5 bezieht es auf alles. Im Spiel stehen aber schon die Schriften Alegreya und Fondamento (SIL Open Font License, verlangt Hinweis) und Shader-Teile von David Hoskins (MIT, verlangt Hinweis); die Hinweise stehen im Hauptmenü (`hauptmenue.gd`:497, :502; 781, von dir freigegeben 10.11.). Gilt die strenge Bedingung nur für Gekauftes?

**Votum:** „1727b A“: ja, nur für Gekauftes; für Freies reicht „kommerzielle Nutzung erlaubt“, Hinweis im Hauptmenü, wo die Lizenz ihn verlangt. Sokrates stellt den Satz in `CLAUDE.md` klar und gleicht `LISTE-QUELLEN.md`:5 und `LISTE-BESTAND.md`:7 an (öffentlich: CC0 und Lizenzen, die die Weitergabe erlauben, etwa OFL, MIT).

**Berührt:** `CLAUDE.md`, `LISTE-QUELLEN.md`, `LISTE-BESTAND.md`, Querprofil Fremde Inhalte (Sokrates); kein Bau.

**Begründung:** so ist es seit 781 gebaut und von dir freigegeben; die Liste hat die Regel strenger abgeschrieben, als sie gelebt wird.

**Sachverhalt:**
- Hinweise stehen und sind getestet (`lizenz_497.gd`:35, :39, :62–63).
- Fondamento hat einen geschützten Schriftnamen; wir ändern die Schrift nicht, also unschädlich (Lücke 4, Text, Sokrates).

**Auswertung:**
- **A (Empfehlung):** nur Text klarstellen; nichts wird ausgebaut.
- **B:** streng für alles: 781 und die Schriftzeile zurückbauen, Alegreya, Fondamento und die Hoskins-Teile ersetzen.
- **Stärkstes Gegenargument gegen A:** künftig sind auch Lizenzen mit Nennungspflicht (etwa CC-BY) zulässig, die Liste der Nennungen wächst, und zwei Maßstäbe sind fehleranfälliger. Entkräftung: jede Lizenz, die nicht sicher passt, geht als „Frage“ an Sokrates (Archiv 21.11., 20:52); eine Nennung ist eine Zeile im Hauptmenü.

**Folgerungen:** A: Sokrates ändert die drei Texte im selben Commit wie die Antwort.

Antwort: …
