# 1727, Routine Ideenlauf (Vorgang 1909; Fassung 1, Sokrates 22.11., 13:10, 1931; Teil A 0 → 1.074 Byte UTF-8 nach Messregel: Inhalt des Codeblocks unter „## Teil A“, ohne letztes Zeilenende)

Auftrag: 1931 Nr. 15 (Ideenlauf als Routine, Teil A wie `routine-rundblick.md`); Gesamtbild 4.3 (G:451: „Ideen sonntags: reif, später, verworfen; Liste per Telegram“ → „Sokrates einmal die Woche über `lauf.py`, ohne feste Stunde; Chef holt zurück“; G:453: Reifes holt der Arbeitsplaner nach „ja“ des Chefs); `ein-ausgang.md` L-O15. Homer gibt es nach dem Umschalten nicht mehr (Archiv 1905; Chef 22.11., 12:43 „Es gibt keinen Homer mehr“).

Geladen von: der Ideenlauf-Sitzung, frisch je Lauf (Sockel + Teil A als Auftrag, ohne Kern; Routine nach Archiv 20.11., 07:53). Start: Wochentermin sonntags ab 9 Uhr in `startbar.WOCHENTERMINE_1727` an der Kopie `claude/spike-1871-umschalten` (1907 Spike, `tools/startbar.py`:256: „Ideenlauf (Routine, Auftrag docs/entwurf/1727-muster/routine-ideenlauf.md Teil A)“); `lauf.py` startet ihn wie den Rundblick (`tools/lauf.py`:798, :1644); `auftrag.routine_text` liest den ersten ```markdown-Block unter „## Teil A“. **Gilt ab der Umstellung;** bis dahin bereitet Homer nach `ROLLE-KREATIV.md` auf (ruht bis zum Umschalten, Archiv 1905).

Quellen: `docs/ROLLE-KREATIV.md`:31 („Sonntags den Ideenspeicher `LISTE-IDEEN.md` aufbereiten (137): … je Idee ‚reif‘, ‚später‘ oder ‚verworfen‘ mit Grund, oben ‚Reif‘; Verworfenes streichst du selbst, Liste per Telegram (1129 A)“), :37; `docs/LISTE-IDEEN.md` Kopf (Urteil je Idee ein Satz Pro und Contra, 147; Bedeutung von reif, später, verworfen; Meilenstein; Abnahmeliste; Zeile „Aufbereitet“); `CLAUDE.md` „Idee“ (sonntags urteilt und verwirft, der Chef holt zurück).

## Teil A: Routine Ideenlauf

```markdown
**Ideenlauf** (einmal die Woche). Ziel: der Ideenspeicher `docs/LISTE-IDEEN.md` ist aufbereitet; nichts geht verloren, nichts wird gebaut.

**Eingang:** neue Ideen seit der Zeile „Aufbereitet“ im Kopf der Liste und Kür der Vorgangsliste ohne Zweig, Termin und angefangene Arbeit (Kopf der Liste).

**Arbeit:** je Idee ein Satz Pro und Contra, dann ein Urteil nach dem Kopf der Liste: „reif“, „später“ (mit Bedingung) oder „verworfen“ (erledigt, überholt oder doppelt), mit Grund; Reifes oben unter „Reif“. Was die Abnahmeliste in `docs/PROJEKTPLAN.md` schon fordert, ist keine Idee: „reif, zu <Punkt>“ oder „verworfen (doppelt)“. Verworfenes streichst du selbst. Story, Aussehen, Balance und Geld entscheidet der Chef; du urteilst nur über Reife.

**Ergebnis:** Zeile „Aufbereitet“ mit Datum nachziehen, pushen; Liste der Urteile, Verworfenes zuerst, per Telegram (`tools/meldung.sh`), der Chef holt zurück. Vorgänge legst du nicht an: Reifes holt der Arbeitsplaner nach „ja“ des Chefs. Dann `vorgang.py rueckmeldung <Nr> "fertig"`.
```
