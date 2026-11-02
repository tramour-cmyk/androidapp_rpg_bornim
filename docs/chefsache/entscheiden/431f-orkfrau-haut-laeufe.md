# 431f · Haut der Orkblütigen Frau: zwei weitere Probeläufe?
Tom · 02.11., 20:5x · E Figuren
Kurz: Orkfrau-Haut: Ursache noch offen, zwei Läufe zum Nachstellen und Beheben
Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/41504744398 (Lauf 5, Commit 6af349a1f) und am Rechner (freie Körper, 20:4x)

**Frage:** Die zwei Läufe nach deinem „431 passt, nur Orkfrau Haut nachbessern“ (20:37) sind verbraucht, die Ursache ist eingegrenzt, aber nicht gefunden. Gibst du zwei weitere frei?

**Votum Tom:** ja. Lauf 1 am Rechner: der Shader zeigt, wie stark er jede Stelle der Haut tönt, als Messbild (nicht für dich), daraus die Ursache. Lauf 2 auf GitHub: Behebung, alle Völker und der Held neu gemessen, ein Standbild der Frauenreihe an dich (kein ganzer Film).

**Berührt:** 431 (Völker), 431e (eine Eichung), Held im Spiel (Heldenhaut, eben nach deinem „so“ eingetragen, noch kein Build), 470.1.

**Sachverhalt (gemessen):**
- Die Haut der Frau hat dieselbe Fläche, dasselbe Bild und dieselben Werte am Shader wie die übrigen (Lauf ohne Bild 41474466012). Die Tönung wird also gesetzt.
- Sie wirkt aber kaum: Im Lauf 5 sank die Eichung bei Rot auf ein Achtel (die Grenze), das Gesicht nur von 254 auf 226 (Ziel 142). Beim Orkblütigen Mann reichte ein Fünftel für 151. Ein großer Teil der Hautfarbe bleibt bei der Frau ungetönt.
- Am Rechner, mit den freien Körpern ohne unsere Bearbeitung: dieselbe Schwäche auch beim Mann, sobald die Hellstellung des Bildes mitläuft; ohne sie (reiner Faktor) tönt die Haut voll. Der Fehler liegt also im Hautweg des Shaders, nicht im Körper der Frau. Die übrigen Völker hat die Eichung mit starken Faktoren auf den Zielton gezogen; bei der Frau reicht der Spielraum nicht.
- Einer der zwei Läufe wurde ohne Lauf gezählt (der Haken las „PROBE=431“ im Text einer Datei); gemeldet an Perikles.

**Stärkstes Gegenargument:** Die Behebung im Hautweg ändert, wie alle Hautfarben entstehen. Held und Völker, die du abgenommen hast, können sich leicht verschieben. Darum misst Lauf 2 alle nach und nennt jede Abweichung über 15 Punkte; die Eichung bleibt eine (431e).

**Folgerungen:** Ohne Freigabe bleibt die Frau beige; 470.1 (Held groß in der Erschaffung) wartet weiter auf die Haut.

**Zu sagen:** „431f ja“ (oder „nein“).

Antwort:
