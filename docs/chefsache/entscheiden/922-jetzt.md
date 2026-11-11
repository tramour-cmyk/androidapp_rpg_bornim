# 922 · Soll 922 „jetzt“ werden, damit B1 auf main kommt?
Sokrates · 11.11., 14:13 · E Kampf · aus 620 (Lagebild t276), dein „freigegeben“ 13:44
Kurz: B1 (Build 276) ist von dir freigegeben, darf aber erst auf main, wenn 922 behoben und der Lauf grün ist. 922 ist gesperrt, und niemand arbeitet daran. Vorschlag: 922 „jetzt“.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/363db9035

**Frage:** Soll 922 (zwei Tests erwarten noch die Lebenspunkte nach SRD) vor der Sperre 620.1 B gebaut werden?
- **A:** 922 „jetzt“. Jerry baut es nach seiner laufenden Arbeit (854) auf dem B1-Zweig. Danach folgen der Lauf und der PR B1 auf main.
- **B:** 922 wartet, bis die Sperre fällt. Das passiert erst nach dem nächsten Sammeltest. B1 kommt dann frühestens mit diesem Test auf main.

**Votum:** „922 A“.

**Berührt:** 870 (B1), 919 (main nur grün), 620.1 B (Sperre), alles „nach B1“: 945, 751, 930a, 933, 931.

**Begründung:**
- 922 ist das letzte Tor für B1. 944 ist gebaut (`9a34fec2a`), 870.4 (276.5) liegt bei Spike.
- 922 bringt nichts Neues, das ungetestet bleibt. Es passt nur die erwarteten Spannen der Tests `wildschwein_494` und `skelett_506` an `werte.json` an. Aufwand etwa eine halbe Stunde (meine Schätzung, Jerry prüft sie).
- Solange B1 nicht auf main ist, setzen alle Zweige „nach B1“ auf einem Nebenzweig auf, und die Konflikte wachsen (Jerry 13:40: 945 schon mit Konflikt gegen 870.4).

**Sachverhalt:**
- Archiv t276: „PR auf `main` erst, wenn 922 behoben und der Lauf grün ist (919), 944 dabei“.
- `startbar.py`: 922 trägt „Sperre 620.1 B: 17 ungetestete Muss … überschneidet sich mit 870.3 (json)“. Ausgenommen sind nur „jetzt“, wiederholte Funde, Rückläufer und angefangene Arbeit (`tools/startbar.py` 504–509, 561–566).
- Besetzung 14:05: Jerry arbeitet an 854, Spike an 870.4. An 922 arbeitet keiner.

**Auswertung:**
- **A (Empfehlung):** B1 kommt heute noch auf main, sobald 870.4 und der Lauf fertig sind. Danach setzen die Zweige auf main auf.
- **B:** Nichts steht still, weil der nächste Sammelbuild auf dem B1-Zweig gebaut werden kann. Dein nächster Test prüft dann aber B1 und alles Neue zugleich, und main bleibt bis dahin auf dem alten System.
- **Stärkstes Gegenargument gegen A:** Jedes „jetzt“ höhlt die Sperre aus, die du am 08.11. gegen den Stau gesetzt hast.
  - **Weg:** 922 macht den Stau nicht größer, sondern löst ihn auf.

**Folgerungen:**
- Mit A trage ich „jetzt“ mit Datum und Uhrzeit in den Titel von 922 ein und schreibe Jerry.
- Mit B bleibt alles, wie es ist.

Antwort: …
