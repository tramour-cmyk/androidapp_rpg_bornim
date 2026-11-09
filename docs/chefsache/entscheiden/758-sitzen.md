# 758 · Wer sitzt, sitzt über ein Merkmal je Person, nicht nur Borin
Tom · 09.11., 20:26 · E Welt · aus 758 (Chef 14:29)
Kurz: neues Merkmal „sitzt“ für jede Person, Borin als Erster; Krug auf den Tisch

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/9ca3e2921/core/src/main/kotlin/de/bornim/core/art/MapFolk.kt#L103 ; `MapFolk.kt:103` (alt: nur Borin, `f.id == "borin"`), `:162–206` (Sitzposen, Hammer beiseite, Krug), `MapRoomIso.kt:2134` (Hocker und Hammer auf 8/4); Godot `leute.gd` (kein Sitzen), `geruest.py` `leute_liste` (Stehen, Gehen, Ruhe, Wenden je Person), `raum.py:963` (Hocker und Hammer stehen schon auf 8/4)

**Anlass (Chef 14:29):** Borin steht in Godot seitlich am Tisch, in der alten Fassung saß er. „Dann könnte man ihn auch einfach richtig an den Tisch setzen.“

**Kommt das wieder?** Ja: Gäste in der Schenke, der Älteste am Pult, später Wirtshäuser in jedem Kapitel. Alt war es nur für Borin fest eingebaut.

- **A (Empfehlung):** ein Merkmal „sitzt“ für jede Person in `leute.json`. Wer es hat, bekommt als Ruhebewegung das Sitzen aus dem gekauften Bewegungspaket (die gleiche Bewegung wie beim Helden in der Erschaffung). Er steht nicht zwischendurch auf, dreht sich nicht mit Schritten und schaut beim Ansprechen nur mit dem Kopf zum Helden. Er sitzt auf dem Hocker seiner Kachel, Blick zum Tisch. Borin zuerst; ein Krug aus dem Bestand (Quaternius-Kit, Mug, CC0) steht vor ihm auf dem Tisch, der Hammer lehnt wie heute an der Tischkante. Kosten: ein Bauserverlauf mit Film.
- **B:** wie alt nur Borin fest einbauen. Billiger um etwa eine Stunde, beim nächsten Sitzenden wird nachgebaut.

**Gegenargument zu A:** Ein Merkmal, das bis jetzt nur einer braucht. Das Merkmal selbst ist aber nicht teurer als Borin fest einzubauen.

**Nicht enthalten:** die alten Sitzposen (trinken, essen, umschauen) und der Krug in der Hand. Das wäre eine zweite Runde, wenn du das Sitzen im Film gesehen hast.
