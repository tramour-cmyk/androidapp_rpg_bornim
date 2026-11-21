# 1727e · Soll der Haken D auch die Guthabenzahl eintragen, die du im Chat nennst?
Sokrates · 21.11., 21:20 · 7 Firma · aus 1727, Profil Kosten (`profil-kosten.md` „Offen, Fragen“ 1)
Kurz: Ohne Guthabenzahl gibt es keine Guthabenstufe; heute steht sie in `ARBEIT-BETRIEB.md`, das fällt.
Beim Chef, weil: Geld; ändert Entschiedenes (Archiv 21.11., 14:37 D: Haken trägt nur Freigabe und Antwort auf eine Frage aus fremder Sitzung ein)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/74cef86e3 (`docs/entwurf/1727-muster/profil-kosten.md`:20–26; `profil-disponent.md`:24 (Stufen 80/95/100 %)

**Frage:** Die Guthabenzahl sieht nur der Chef (Bild der App). Der Disponent richtet sich nach Stufen (ab 80 % nur Muss, ab 95 % nur Rückläufer des Chefs, ab 100 % Stillstand). Bisher trägt Ford die Zahl in `ARBEIT-BETRIEB.md` ein; die Datei fällt (Gesamtbild :502). Soll der Haken D eine Guthabenzahl aus deiner Nachricht (gleich welche Sitzung) in eine feste Datei schreiben, aus der `lauf.py` die Stufe rechnet?

**Votum:** „1727e A“: ja; du nennst die Zahl in irgendeiner Sitzung („Guthaben 62 %“), der Haken trägt sie ein.

**Berührt:** Haken D (`chefwort.py`, Spike 1739), `lauf.py`, Routine Tagesbericht.

**Begründung:** Zahl an einem Ort, ohne dass eine bestimmte Sitzung laufen muss.

**Sachverhalt:**
- Haken D baut 1762 (gebaut, `34de71832`), scharf erst mit `tools/1727-SCHARF`.
- Wochenguthaben im Tagesbericht (Archiv 20.11., 08:19).

**Auswertung:**
- **A (Empfehlung):** eine Erkennungsregel mehr im Haken.
- **B:** du schreibst sie dem Disponenten; geht verloren, wenn er neu startet, bevor er sie einträgt.
- **Stärkstes Gegenargument gegen A:** eine Prozentzahl in einem anderen Zusammenhang wird falsch als Guthaben gelesen. Entkräftung: nur mit dem Wort „Guthaben“ davor; der Tagesbericht zeigt die eingetragene Zahl, du siehst einen Fehler am nächsten Morgen.

**Folgerungen:** A: Vorgang an Spike (Erweiterung Haken D).

Antwort: …
