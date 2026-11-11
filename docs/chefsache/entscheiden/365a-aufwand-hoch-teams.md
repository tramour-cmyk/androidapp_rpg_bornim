# 365a · Sollen Tom und Jerry bis Samstag 20:00 mit Aufwand „Hoch“ starten?
Sokrates · 11.11., 07:16 · B Abläufe · aus deinem Wort 07:13
Kurz: Nach dem Wochenreset reicht das Guthaben; „Hoch“ nur für die Entwickler, damit weniger Läufe rot werden, Auswertung am Samstag.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/0221c8a5e/tools/lauf.py#L68-L70 (`HOCH` „WireStorm Hoch“, `UMGEBUNG = {}`); Archiv 365 (25.10., 09.11.); fremd geprüft 07:15

**Frage:** Tom und Jerry starten zurzeit mit Aufwand „Mittel“ (dein Wort 09.11.). Sollen ihre nächsten Sitzungen bis Sa 14.11., 20:00 mit „Hoch“ starten, damit sie vor jedem Lauf gründlicher prüfen? Das Modell bleibt in jedem Fall dasselbe.

**Votum:** „365a A“: nur Tom und Jerry mit „Hoch“ bis Samstag 20:00, alle anderen bleiben auf „Mittel“.

**Berührt:** `tools/lauf.py` (`UMGEBUNG` für Tom und Jerry auf `HOCH`, Perikles oder Ford); Ford startet die Nachfolger; Tom und Jerry (870.4, 870.6–870.9, 900); Auswertung bei mir (365).

**Begründung:** Chef 07:13: „überleg doch bitte mal, ob wir den Aufwand nicht auf hochsetzen wollen. Bei den Leuten, die jetzt arbeiten müssen, den Entwicklern zum Beispiel.“ Beim Umzug bestimmen rote Läufe das Tempo, nicht das Guthaben; jeder rote Lauf kostet etwa eine Stunde.

**Sachverhalt:**
- Nach dem kostenlosen Wochenreset steht die Woche auf 0 % (dein Bild 07:11). Bis Sa 14.11., 20:00 sind es etwa 85 Stunden. Weil 287 ab 80 % nur noch Muss erlaubt, liegt die sichere Grenze bei etwa 1,1 % je Stunde. Bisher lag die ganze Firma bei etwa 0,7 bis 0,8 % je Stunde (`ARBEIT-BETRIEB.md` Guthaben).
- Heute Nacht wurde Lauf 335 an der Wolfsmessung rot (900). Den Krogg-Test und die Knopfbreite im Testmenü fand Tom erst danach am Rechner. Beide hätten den nächsten Lauf ebenfalls rot gemacht.
- Die Probe vom 25.10. (Teams mit „Hoch“, Maß: Rückläufer je Build und Verbrauch) wurde nie ausgewertet. Ob „Hoch“ weniger Fehler bringt und wie viel mehr es kostet, ist offen. Die Wochenzahlen gelten für die ganze Firma und lassen „Hoch“ und „Mittel“ nicht trennen.

**Auswertung:**
- **A (Empfehlung):** Tom und Jerry mit „Hoch“, Rest „Mittel“. Laufende Sitzungen arbeiten zu Ende, erst ihre Nachfolger starten mit „Hoch“ (wie 365.1 A). Messen: rote Läufe je Build und deine Rückläufer gegen t274/t275. Liegt das Tempo zweimal hintereinander über 1,1 % je Stunde, geht es zurück auf „Mittel“.
- **B:** alle Rollen mit „Hoch“. Homer, Perikles, Diogenes und Ford schreiben und verwalten vor allem. Dort bringt mehr Nachdenken wenig und kostet am meisten.
- **C:** alles bleibt auf „Mittel“. Ungenutztes Guthaben verfällt am Samstag, und rote Läufe kosten weiter Stunden.
- **D:** nur ein Team mit „Hoch“, als Vergleich. Beide arbeiten am selben B1, rote Läufe lassen sich kaum einem Team zuordnen. Der Vergleich bliebe unscharf.
- **Stärkstes Gegenargument gegen A:** Der Nutzen ist nicht belegt, die Probe vom 25.10. hatte dasselbe Maß und blieb liegen. Antwort darauf: Die Auswertung bekommt diesmal einen Termin (Sa 14.11.). Das Guthaben trägt den Aufschlag sicher, und schon ein roter Lauf weniger am Tag spart mehr Zeit, als „Hoch“ an Tempo kostet.

**Folgerungen:** Bei A stellt Perikles `UMGEBUNG` in `lauf.py` für Tom und Jerry bis Sa 20:00 auf `HOCH`, Ford startet die Nachfolger so. Ich lege dir am Samstag die Auswertung vor. Bei C bleibt alles, wie es ist.

Antwort: „365a A“, „365a B“, „365a C“ oder „365a D“.
