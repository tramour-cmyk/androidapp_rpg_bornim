# 1727c · Soll Sokrates bei jeder offenen Übergabezeile an ihn starten, und sollen drei weitere Anlässe als solche Zeile an ihn gehen?
Sokrates · 21.11., 21:19 · 7 Firma · aus 1727 (Umbau der Arbeitsweise), Profil Disponent (`profil-disponent.md`:22, :48)
Kurz: Entschieden sind drei Wörter (C, 14:37); `lauf.py` startet Sokrates schon heute bei jeder offenen Zeile an ihn; drei Anlässe haben noch keinen Weg zu ihm.
Beim Chef, weil: Rollen und Accounts (wann Sokrates startet); ändert Entschiedenes (Archiv 21.11., 14:37 C „Disponent startet Sokrates bei ‚steckt fest‘, ‚Frage‘, ‚wirkt nein‘“)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`tools/lauf.py`:511–535, :1260; `tools/uebergabe.py`:232–241; `docs/entwurf/1727-muster/profil-disponent.md`:22, :48; `routine-wochenzaehlung.md`:43)

**Frage:** C sagt: Sokrates startet bei „steckt fest“, „Frage“, „wirkt nein“. Gebaut ist mehr: `lauf.py` startet oder weckt Sokrates bei jeder offenen Übergabezeile an ihn, gleich mit welchem Wort (läuft heute schon). Drei Anlässe aus den Entwürfen haben noch keine Zeile an Sokrates: (1) Eingang, der keinem Bereich gehört; (2) Wochenzählung „zwei Wochen schlechter“; (3) Stillstand, der an einer Entscheidung hängt. Soll gelten: jede offene Zeile an Sokrates startet ihn (Text wie gebaut), und diese drei gehen als Zeile an ihn?

**Votum:** „1727c A“: ja.

**Berührt:** Profil Disponent :22 (Text), Routinen Wochenzählung und Büro (Zeile an Sokrates); kein Bau in `lauf.py`.

**Begründung:** Text und Werkzeug sagen dann dasselbe; ohne Zeile bleiben die drei Anlässe liegen (Chef 20.11., 22:17: „Rückläufer … dürfen nicht durchrutschen“).

**Sachverhalt:**
- `sokrates_zeilen` holt über `uebergabe.offen_lokal("Sokrates")` jede offene Zeile, nur nach Zustand und Empfänger, nie nach dem Wort; nicht an den Umschalter gebunden.
- (2) höchstens einmal die Woche, (1) und (3) selten.

**Auswertung:**
- **A (Empfehlung):** zwei Sätze Text, drei Zeilen in den Routinen.
- **B:** `lauf.py` auf die drei Wörter einschränken (Bau, Spike) und die drei Anlässe im Gespräch mit dir lesen.
- **Stärkstes Gegenargument gegen A:** jeder Start kostet Guthaben, und jeder Entwurf kann künftig Arbeit an Sokrates schieben. Entkräftung: Zeilen an Sokrates schreiben nur Werkzeuge und Routinen, die im Text stehen; die Wochenzählung zählt Sokrates-Starts.

**Folgerungen:** A: Sokrates ändert Profil Disponent und die Routinen.

Antwort: …
