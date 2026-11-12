# 1043a · Vierter Filmlauf „Ausweichen erzwungen“ mit behobenem Test, oder ein anderer Weg?
Jerry · 13.11., 00:26 · E Kampf · Lauf 404 (dritter, frei nach Archiv „1043, dritter Lauf frei“) zeigte kein Ausweichen; nachts entscheidet Sokrates (1077)
Kurz: Lauf 404 ohne Ausweichen wegen eines Testfehlers (Zeitgrenze); behoben am Rechner, vierter Lauf nur auf Ja.

Geprüft an: Lauf 404 (`7db8fcf69`), Behebung `338458c53` auf `claude/jerry-1043-ausweichen`, am Rechner mit Seed 7

**Frage:** Der Chef sah im Probekampf (Wölfe, Klosterschüler, „Ausweichen erzwingen“) kein Ausweichen (t278.33). Der dritte Filmlauf sollte es dreimal hintereinander zeigen, auf etwa 12 s geschnitten. Er brach nach 32 s Film ab, bevor ein Wolf den Helden angriff. Darf ein vierter Lauf mit der Behebung laufen?

**Votum:** „1043a A“: ein vierter Filmlauf `kampf=1043` auf `338458c53`, Ersatz nur bei fremdem Abbruch.

**Berührt:** 1043 (Jerry); kein Spielcode, nur Test und Filmschritt.

**Begründung:** Ursache gefunden und am Rechner nachgestellt (Bekannte Fehler 334); ohne Film sieht der Chef nicht, wie das Ausweichen heute aussieht.

**Sachverhalt:**
- Lauf 404: „AUSWEICHEN1043 erzwungen nein“, Film 32 s (965 Bilder). Die Schleife im Test maß 300 s Uhrzeit; der Bauserver filmte mit 9 % der Echtzeit, also nur 32 s.
- Mit Seed 7 greifen in der ersten Runde alle drei Wölfe den Söldner Bertram an (im Film zu sehen: „Wolf 1 erwischt Bertram“); der Held wird erst bei 18,8 s Kampfzeit angegriffen.
- Behoben: die Grenze zählt jetzt Bilder (120 s Kampfzeit). Am Rechner mit Seed 7, ohne Bild: Ausweichen bei 18,8 s, 23,2 s und 30,9 s, dreimal angesprungen.
- Befund nebenbei (Messung, ohne Kaufheld): das Ausweichen ist eine Bewegung am Ort von 0,46 s, der Fuß wandert nicht. Vermutlich sah der Chef darum „nichts“. Das zeigt erst der Film mit Kaufheld.

**Auswertung:**
- **A (Empfehlung):** vierter Lauf. Kosten: ein Bauserverlauf, etwa 50 bis 80 Minuten. Danach Film selbst ansehen, dann an den Chef. Zeigt er das Ausweichen nur klein: Vorschlag für eine größere Bewegung (Schritt zur Seite oder zurück) als eigener Vorgang.
- **B:** kein Film; gleich den Vorschlag „größere Ausweichbewegung“ als Bild und Messung. Kosten: kein Lauf. Aber der Chef hat das Heutige nie im Film gesehen.
- **C:** „Ausweichen erzwingen“ gilt im Testmenü für jeden Angegriffenen der eigenen Seite (Held und Söldner), damit es schon in der ersten Runde wirkt; dazu Lauf wie A. Kosten: kleine Änderung an `mars.gd`, ein Lauf.
- **Stärkstes Gegenargument gegen A:** zwei der drei Läufe scheiterten an Fehlern in meiner Testschleife. Ein vierter kann wieder scheitern. Am Rechner ist nur ohne Bild geprüft; mit Bild zählt jeder Versuch als Lauf.

**Folgerungen:** A oder C: Jerry startet den Lauf, sieht den Film an und schickt ihn an den Chef. B: Jerry legt den Vorschlag als Bild vor. Diese Datei geht im selben Commit wie die Antwort weg.

Antwort: …
