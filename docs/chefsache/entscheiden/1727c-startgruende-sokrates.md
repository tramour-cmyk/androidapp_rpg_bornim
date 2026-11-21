# 1727c · Soll der Disponent Sokrates auch bei drei weiteren Anlässen starten?
Sokrates · 21.11., 21:20 · 7 Firma · aus 1727, Profil Disponent (Sammelfrage C, `profil-disponent.md`:48), Routine Rundblick
Kurz: C (14:37) startet Sokrates nur bei „steckt fest“, „Frage“, „wirkt nein“; die Entwürfe brauchen drei weitere Anlässe.
Beim Chef, weil: Rollen und Accounts (wann Sokrates startet); ändert Entschiedenes (Archiv 21.11., 14:37 C, „Disponent startet Sokrates bei ‚steckt fest‘, ‚Frage‘, ‚wirkt nein‘“)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`docs/entwurf/1727-muster/profil-disponent.md`:22, :48; `routine-rundblick.md`:23; `routine-wochenzaehlung.md`:43; `profil-kosten.md`; `tools/lauf.py`:512 (`sokrates_zeilen`)

**Frage:** Nach C startet der Disponent Sokrates nur bei drei Wörtern. Die Entwürfe geben Sokrates aber weitere Zeilen: (1) Eingang, der keinem Bereich gehört (Gesamtbild 4.4); (2) Höchstdauer zum zweiten Mal überschritten („steckt fest“, schon in C gedeckt, nur zur Klarheit); (3) Wochenzählung „zwei Wochen schlechter“; (4) Stillstand, der an einer Entscheidung hängt. Ohne Startgrund erreichen diese Zeilen Sokrates nur, wenn er gerade läuft. Sollen (1), (3), (4) Startgründe werden? (Ein Vorschlag des Rundblicks, der eine Entscheidung braucht, geht als „Frage“; die deckt C schon.)

**Votum:** „1727c A“: ja, alle drei; eine Zeile `lauf.py` je Anlass wie C.

**Berührt:** Profil Disponent, `lauf.py` (Spike), Routinen Wochenzählung und Rundblick (1727).

**Begründung:** sonst tote Enden (Lehre Prozessprüfung 21.11., 14:30: Raster Einheit × Auslöser bis Empfänger).

**Sachverhalt:**
- C entschieden 21.11., 14:37; `lauf.py` `sokrates_zeilen` liest offene Übergabezeilen an Sokrates (:512).
- Rundblick montags, Wochenzählung montags: höchstens je einmal die Woche; (1) und (4) selten.

**Auswertung:**
- **A (Empfehlung):** drei Startgründe; geschätzt ein bis drei Sokrates-Starts mehr je Woche (je etwa 3–5 $ Startlesen).
- **B:** keine; Zeilen warten, bis Sokrates ohnehin läuft (Gespräch mit dem Chef); Gefahr, dass sie liegen bleiben.
- **Stärkstes Gegenargument gegen A:** jeder Start kostet Guthaben, und (3) könnte Sokrates im Wochengespräch lesen. Entkräftung: ein Wochengespräch ist nicht festgelegt; Chef 22:17 (20.11.): „Rückläufer … dürfen nicht durchrutschen“.

**Folgerungen:** A: Vorgang an Spike (Startgründe in `lauf.py`), Text in Profil Disponent (Sokrates).

Antwort: …
