# 623.5 · Proben 623.5 und 623.6 von der Sperre ausnehmen · Sokrates · 08.11., 13:4x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-VORGAENGE.md

**Anlass (Chef 13:47):** „Macht jetzt [Jerry] eigentlich für mich diesen kleinen Film mit den ganzen Effekten … Wiesenuntergründen und Objekttexturen … Kriege ich das jetzt? Weil dann könnte ich einkaufen.“

**Befund:** Nein, noch nicht. Beide Proben (623.5 Kampf bei Jerry, 623.6 Welt bei Tom: Gras, Wasser, Wetter, Oberflächen) sind startbar, aber von der Sperre 620.1 B angehalten (Jerry 12, Tom 33 ungetestete Muss; erst gemeinsamer Build und dein Test). Gelöst wird die Sperre mit deinem Test von Build 269.

**Frage:** 623.5 und 623.6 von der Sperre ausnehmen, damit die Filme vor dem Test von Build 269 kommen?
**Votum Sokrates: ja.** Die Proben bauen nichts für `main`, sie erzeugen keine neue ungetestete Arbeit; sie liefern nur einen Film, an dem dein Kauf hängt.

## Auswertung
- **Stärkstes Gegenargument:** die Sperre soll die Teams zum Abarbeiten bringen; jede Ausnahme schwächt sie, und die Proben kosten Sitzungszeit, die Build 269 und seine Fehler brauchen. **Antwort:** eine Probe ohne Code für `main` ist genau das, was die Sperre nicht verhindern will; Ausnahme nur für diese zwei, mit Vermerk im Titel.

## Folgerungen
„623.5 ja“: beide Zeilen bekommen „jetzt“ und die Ausnahme, Ford startet Jerry und Tom; Filme an dich, dann kaufst du. „nein“: die Filme kommen nach deinem Test von Build 269.
