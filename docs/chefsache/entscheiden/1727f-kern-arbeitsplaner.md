# 1727f · Kern Arbeitsplaner um zwei Ladehinweise und eine Ausnahme bei Übersetzungen ergänzen?
Sokrates · 21.11., 21:20 · 7 Firma · aus 1727, Profil Werkzeug F4a und Querprofil Fremde Inhalte F4a (Teil B)
Kurz: Der Arbeitsplaner muss wissen, wann er Profil Werkzeug oder Querprofil Fremde Inhalte dazulädt; Prüffrage Spieltext braucht „außer markierter Übersetzung“.
Beim Chef, weil: Rollen und Accounts (Kern einer Rolle); ändert Abgenommenes (Kern Arbeitsplaner, Archiv 20.11., 16:49 „Kerne nicht aufblähen … da müssen wir uns dann unterhalten“)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`docs/entwurf/1727-muster/profil-werkzeug.md` Teil B, :45; `profil-fremde-inhalte.md` Teil B, :26; `1727-gesamtbild.md`:419

**Frage:** Zwei neue Profile werden nur geladen, wenn der Arbeitsplaner sie in den Auftrag schreibt. Soll der Kern Arbeitsplaner unter „Beachte“ zwei Sätze bekommen: „bei Firmenwerkzeugen: Profil Werkzeug“ und „bei fremder Datei oder Spieltext: Querprofil Fremde Inhalte“? Und soll die Prüffrage bei Spieltext (G:419, „jeder Satz wortgleich in der Quelle?“) „außer markierter Übersetzung“ bekommen, weil englische Texte selbst übersetzt werden?

**Votum:** „1727f A“: ja, alle drei; etwa 2.375 → 2.545 Byte (+170).

**Berührt:** Kern Arbeitsplaner, Prüffrage Spieltext (1727).

**Begründung:** ohne Hinweis lädt keiner die Profile (totes Ende); ohne Ausnahme muss der Prüfer jede Übersetzung verneinen (`CLAUDE.md` „Englisch selbst übersetzen“).

**Sachverhalt:**
- Größe laut `profil-werkzeug.md`:45.

**Auswertung:**
- **A (Empfehlung):** +170 Byte im Kern.
- **B:** Profile automatisch nach Bereich laden (Werkzeug erkennt Firmenwerkzeug oder Spieltext); kein Kerntext, aber ein Werkzeug mehr, das irren kann.
- **Stärkstes Gegenargument gegen A:** der Chef will Kerne nicht aufblähen. Entkräftung: 7 % mehr, und B braucht ein neues Werkzeug.

**Folgerungen:** A: Sokrates ändert den Kern (Tabelle 0, Größe).

Antwort: …
