# 348.12k · Grak-Film mit den alten Helden: Ursache und neuer Lauf
Sokrates · 01.11., 22:47 · E Kampf

**Anlass** (Chef 22:42): „Das sind jetzt wieder welche mit zwei Schilden und uralte Fassung. Warum? Hatten wir nicht gesagt, wir nehmen das jetzt mal von Tom? … Das haben wir doch schon alles entschieden. Warum schon wieder?“

**Ursache (im Code nachgesehen, `claude/grundstand-461`):**
1. Der Grak-Film läuft über einen eigenen Ablauf (`godot-kampf.yml`). Der baut die Kampfbewegungen des gekauften Helden nicht (`held_kampf.py`, `kampf-bewegungen.bin` fehlen). Die Wolf-Filme, die du gelobt hast (453), laufen über `godot.yml`, der sie baut.
2. Fehlen diese Dateien, nimmt der Kampfort **still** den alten Helden (`figur.gd` `_kaufheld`: „bleibt der bisherige Held“). Kein Fehler, keine Warnung.
3. Jerrys Vorlage hakte B2 und C1/C2 ab, nicht A5 („Held wie Film 403“). Das Tor, das so einen Film anhält, wartet auf dein Wort ([461a](461a-grundstand-tor.md)).

**Votum Sokrates:**
- Jerry behebt (1) und (2): ein Ablauf für alle Kampfort-Filme; fehlt der gekaufte Held, bricht der Film ab statt still zu tauschen (alter Held nur mit ausdrücklichem Schalter `ALTHELD`).
- Danach **ein** neuer Lauf für den Grak-Film (über 389 hinaus), Film an dich.
- Und **461a ja**: dann wäre dieser Film nicht rausgegangen.

**Stärkstes Gegenargument:** noch ein Lauf für Grak, nach dem dritten und dem Filmlauf. **Entkräftet:** der Fehler ist eine Ursache für alle künftigen Kampfort-Filme (Grak, Kobold, Zombie, 460 Kamerafahrten), einmal behoben, nicht je Film.

**Zu sagen:** „348.12k ja“ (beheben, ein Lauf) und „461a ja“, oder was anders sein soll.
