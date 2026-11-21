# 1727f · Kern Arbeitsplaner um zwei Ladehinweise und eine Ausnahme bei Übersetzungen ergänzen?
Sokrates · 21.11., 21:19 · 7 Firma · aus 1727 (Umbau der Arbeitsweise), Profil Werkzeug F4a und Querprofil Fremde Inhalte F4a (Teil B)
Kurz: Der Arbeitsplaner muss wissen, wann er Profil Werkzeug oder Querprofil Fremde Inhalte dazulädt; die Prüffrage Spieltext braucht „außer markierter Übersetzung“.
Beim Chef, weil: Rollen und Accounts (Kern einer Rolle); ändert Abgenommenes (Archiv 20.11., 16:49 „Kerne nicht aufblähen … da müssen wir uns dann unterhalten“)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`docs/entwurf/1727-muster/profil-werkzeug.md`:41, :75; `profil-fremde-inhalte.md`:26, :74; `1727-gesamtbild.md`:419)

**Frage:** Zwei neue Profile werden nur geladen, wenn der Arbeitsplaner sie in den Auftrag schreibt. Soll der Kern Arbeitsplaner unter „Beachte“ zwei Sätze bekommen: „bei Firmenwerkzeugen: Profil Werkzeug“ und „bei fremder Datei oder Spieltext: Querprofil Fremde Inhalte“? Und soll die Prüffrage bei Spieltext (Gesamtbild :419, „jeder Satz wortgleich in der Quelle?“) „, außer markierter Übersetzung“ bekommen, weil englische Texte selbst übersetzt werden?

**Votum:** „1727f A“: ja, alle drei; Kern Arbeitsplaner etwa 2.375 → 2.594 Byte (+219: 87 + 36 + 64 Byte laut Messung Fassung 3, dazu 32 Byte Prüffrage).

**Berührt:** Kern Arbeitsplaner, Prüffrage Spieltext (1727).

**Begründung:** ohne Hinweis lädt keiner die Profile (totes Ende); ohne Ausnahme muss der Prüfer jede Übersetzung verneinen (`CLAUDE.md` „Englisch selbst übersetzen“).

**Sachverhalt:**
- Größen: `profil-werkzeug.md`:75 (Teil B 87 + 36), `profil-fremde-inhalte.md`:74 (Teil B 64).

**Auswertung:**
- **A (Empfehlung):** +219 Byte im Kern (etwa 9 %).
- **B:** Profile automatisch nach Bereich laden (Werkzeug erkennt Firmenwerkzeug oder Spieltext); kein Kerntext, aber ein Werkzeug mehr, das irren kann.
- **Stärkstes Gegenargument gegen A:** du willst Kerne nicht aufblähen. Entkräftung: drei kurze Sätze, B braucht ein neues Werkzeug.

**Folgerungen:** A: Sokrates ändert den Kern (Tabelle 0, Größe vorher und nachher).

Antwort: …
