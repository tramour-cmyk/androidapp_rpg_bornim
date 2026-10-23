# 339 · Dashboard „Stand zum Marktstart“, immer aktuell · Sokrates · 23.10., 09:09
B Abläufe

**Frage** (Chef 09:08): „Ja, so eine Art Dashboard“: Stand gegen den Plan, Ausgaben, Risiken, jederzeit aktuell statt eines Berichts, der beim Lesen schon alt ist.

**Empfehlung:** Ein Dashboard als private Seite auf claude.ai, die du im Browser und am Handy öffnest.
- **Zeigt:** die Blöcke „marktreif“ a–f mit Ampel und Termin (aus `LISTE-ABNAHME-KAPITEL1.md` und `LISTE-VORGAENGE.md`); offene Muss je Team; Ausgaben für Woche und Monat, Credits und Verlauf (`tools/kosten.py`); die Risiken mit Gegenmittel (Perikles); offene Chefsachen.
- **Hält sich selbst aktuell:** Fords Stundenlauf (`lauf.py`) schreibt die Zahlen hinein. Niemand pflegt sie von Hand; Perikles schreibt nur Risiken und Ampel-Urteile.
- **Bau:** Perikles (Inhalt), Ford (Anbindung an `lauf.py`). Erst danach fällt der Tagesbericht (247) weg.

**Stärkstes Gegenargument:** Ein zweiter Ort für den Stand widerspricht „jeder Text an einem Ort“, und eine Ampel aus Zahlen kann grün zeigen, wo es inhaltlich hakt. Darum zieht das Dashboard nur aus den vorhandenen Dateien, und die Ampel setzt Perikles von Hand. Kosten: einmalig etwa eine Sitzung, danach nur Sekunden im Stundenlauf.

**Berührt:** 338, 338.1, 247 (Tagesbericht), 167.6 (Morgenbericht); Perikles, Ford.

**Was du sagen sollst:** „339 ja“, „339 ja, aber …“ oder „nein“.
