# 1566 (Höhlenwasser hinter Wänden) · Noch ein Messlauf zum türkisen Funkeln hinter der Höhlenwand?
Sokrates · 22.11., 18:36 · Welt · Obergrenze B (zweites „steckt fest“, deine Regel 21.11., 14:37 B und 22.11., 15:31)
Kurz: Wasserfläche hinter der Wand ist weg, ein schwaches Funkeln bleibt; Ursache noch nicht gemessen
Beim Chef, weil: dritte Laufanforderung im selben Vorgang zählt als zweites „steckt fest“ → du

Geprüft an: 01c8bc9cf (Zweig claude/emil-1566-hoehlenwasser)

**Frage:** Darf Welt einen einzigen Messlauf unter dem Handy-Renderer machen, um die Ursache des Funkelns zu finden und dann zu beheben?

**Votum:** „1566 A“.

**Bild:** `chefsache/bilder/1566-hoehlenwasser-alt-neu.webp` (Blutzahnhöhle, 19:13, Handygröße; selbst angesehen): links alt deutliche Wasserfläche hinter der Wand (Helligkeit 22,8), rechts neu fast schwarz, nur türkise Pünktchen im roten Rahmen (2,8).

**Sachverhalt:**
- Dein Fund 17.11., 14:50: „Warum sehe ich da das Wasser durch, obwohl das ja nicht in meiner Sichtlinie ist?“ Die Fläche ist behoben (auf `main`), das Funkeln nicht.
- Läufe: 17:05 Bildlauf (frei, gültig, Bild oben); 18:19 Messlauf verbraucht, weil im falschen Renderer (Kompatibilität statt Mobile); 18:31 nachgebessert: Skript bricht jetzt ab, wenn nicht Mobile läuft (belegt), und setzt Werte genau zurück (Prüferhinweis 18:30).
- Vermutung Welt, ungeprüft: Glanzlicht des Wassers läuft im Halbfloat-Puffer über und scheint durch den Nebel.

**Auswertung:**
- **A (Empfehlung):** ein Messlauf unter Mobile, dann Test rot, Behebung, grün, Bild alt gegen neu. Der Fehler des letzten Laufs ist abgesichert.
- **B:** Rest als eigener Kür-Vorgang, 1566 schließen; du siehst es am Handy im nächsten Testbuild.
- **C:** 1566 ruht bis nach deiner Reise.
- **Stärkstes Gegenargument gegen A:** Gemessen wird in einem Software-Vulkan (lavapipe), nicht auf deinem Handy; das Funkeln kann dort ein Rechenfehler sein, der am Gerät gar nicht auftritt. Entkräftet: ein Lauf ist billig; zeigt er einen Überlauf, ist die Behebung (Glanz begrenzen) auch am Handy richtig; zeigt er nichts, B.

**Folgerungen:** A: Prüfer gibt den Lauf frei, Welt misst; findet sie nichts, B ohne neue Frage. B: neuer Vorgang Welt, Kür. C: ruht mit Datum 28.11.

Antwort: …
