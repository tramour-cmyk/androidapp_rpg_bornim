# 513a · Schild auf dem Rücken: im Stehen liegt er jetzt an, im Gehen schwingen die Beine darunter. Wie soll er sitzen?
Tom · 04.11., 12:26 · E Figuren · berührt 513, 417 (Schild auf dem Rücken), alle Klassen mit Schild

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/040c54212 (Test `schild_513` am Rechner auf dem Kaufkörper, ohne Bild)

**Frage:** Der Schild hängt unten über die Oberschenkel hinaus. Soll er höher oder kleiner sitzen, damit er auch im Gehen anliegt, oder bleibt er so?

**Votum:** A, höher, sodass die Unterkante am Gesäß endet. Erst ein Standbild von der Seite im Stehen und mitten im Schritt, dann entscheidest du nach dem Bild.

**Berührt:** `heldfigur.gd` (Lage am Rücken), alle vier Klassen, Schild und Rundschild; der Kampf nicht (dort ist der Schild am Arm).

**Begründung:** Dein Bild aus Build 257 zeigt den Magier mit dem Schild etwa eine Rumpfbreite vom Rücken ab. In Build 257 fehlte der Fix 52bb6dfe1 noch. Mit Fix habe ich jetzt am Rechner alle Klassen mit beiden Schilden auf dem Kaufkörper gemessen:
- **Im Stehen** liegt der Schild in allen Fällen oben und unten an. Unten bleiben höchstens 2,2 cm Luft, nichts ragt in den Körper.
- **Im Gehen** liegt das unterste Viertel des Schilds hinter den Oberschenkeln, nicht mehr am Rumpf. Die Beine schwingen darunter. Beim vorderen Bein bleiben unten bis zu 19 cm Luft, das hintere ragt in den Schild (bis zu 41 Ecken, Kämpfer).

Ein starrer Schild kann darum nicht zu jeder Zeit anliegen. Ich habe zwei Wege versucht, ihn mitgehen zu lassen: einmal am Becken geführt, einmal je Zeitpunkt neu angelegt. Beide waren nicht besser, darum habe ich sie verworfen.

**Möglichkeiten:**
- **A: höher.** Die Oberkante steht dann ein Stück über der Schulter. Von schräg oben sieht man mehr Schild am Hals, dafür liegt er im Gehen am Rumpf an.
- **B: kleiner nur auf dem Rücken** (etwa drei Viertel). Er passt dann zwischen Schulter und Gesäß, ist aber kleiner als im Kampf am Arm.
- **C: so lassen.** Im Stehen liegt er an, im Gehen sieht man Luft und Beine, die hindurchgehen.

**Stärkstes Gegenargument zu A:** 376.1 Lauf 1 hat den Schild absichtlich gesenkt, weil er von schräg oben über die Schultern ragte. A geht wieder ein Stück dorthin zurück, und das Bild kann dir weniger gefallen als heute. Darum erst das Standbild.

**Folgerungen:** Bei A oder B baue ich die Lage, mache ein Standbild von der Seite (Stehen und Schritt, Magier und Kämpfer) und lege es dir vor. Der freigegebene Lauf zu 513 wartet, bis du gewählt hast. Bei C kommt nur der Lauf mit den Drehteller-Bildern.

**Zu sagen:** „513a A“, „513a B“ oder „513a C“.
