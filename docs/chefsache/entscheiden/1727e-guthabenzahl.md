# 1727e · Soll ein Haken deine Nutzungszahl („81 Prozent Nutzung“) aus jeder Sitzung eintragen?
Sokrates · 21.11., 21:19 · 7 Firma · aus 1727 (Umbau der Arbeitsweise), Profil Kosten (`profil-kosten.md` „Offen, Fragen“ 1)
Kurz: Ohne Nutzungszahl keine Guthabenstufe; heute steht sie in `ARBEIT-BETRIEB.md`, das fällt.
Beim Chef, weil: Geld; ändert Entschiedenes (Archiv 21.11., 14:37 D: „Haken trägt Chefwort aus fremder Sitzung in die Vorgangsdatei“; eine Nutzungszahl hat keine Vorgangsnummer, D greift dann nicht)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`docs/entwurf/1727-muster/profil-kosten.md`:20–26; `profil-disponent.md`:24; `docs/ARBEIT-BETRIEB.md`:20)

**Frage:** Die Nutzungszahl siehst nur du (Bild der App). Der Disponent richtet sich nach Stufen der Nutzung (ab 80 % nur Muss, ab 95 % nur deine Rückläufer, ab 100 % Stillstand). Du sagst sie bisher so: „93 Prozent“, „81 Prozent Nutzung“ (`ARBEIT-BETRIEB.md`:20); Ford trägt sie ein. Die Datei fällt. Soll der Haken D eine Zahl mit „Prozent Nutzung“ oder „Nutzung … Prozent“ aus deiner Nachricht in jeder Sitzung in eine feste Datei schreiben, aus der `lauf.py` die Stufe rechnet?

**Votum:** „1727e A“: ja; du sagst wie bisher „81 Prozent Nutzung“; eine bloße Prozentzahl ohne „Nutzung“ trägt der Haken nicht ein, die trägt die Sitzung ein, die sie hört.

**Berührt:** Haken D (`chefwort.py`, Spike), `lauf.py`, Routine Tagesbericht (zeigt die eingetragene Zahl).

**Begründung:** Zahl an einem Ort, ohne dass eine bestimmte Sitzung laufen muss.

**Sachverhalt:**
- Haken D gebaut mit 1762 (`34de71832`), scharf erst mit dem Umschalter.
- Wochenguthaben im Tagesbericht (Archiv 20.11., 08:19).

**Auswertung:**
- **A (Empfehlung):** eine Erkennungsregel mehr im Haken.
- **B:** wer die Zahl hört (meist Sokrates), trägt sie mit `vorgang.py` ein; geht verloren, wenn die Sitzung vorher endet.
- **Stärkstes Gegenargument gegen A:** „93 Prozent“ ohne „Nutzung“ wird nicht erkannt, und du musst dir eine Form merken. Entkräftung: dann trägt die Sitzung ein (B als Rückfall); der Tagesbericht zeigt die Zahl, einen Fehler siehst du am nächsten Morgen.

**Folgerungen:** A: Vorgang an Spike (Erweiterung Haken D).

Antwort: …
