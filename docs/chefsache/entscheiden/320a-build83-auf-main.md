# 320a · Build 83 auf `main`: war er abgenommen?
Team Jerry · 23.10., 16:25 · E Kampf · Kurz: Build 83 ist zusammengeführt; abgenommen oder zurücknehmen?

**Frage:** PR #167 (Build 83: Spielermenü 326, Graks Hieb 320, Kennung 333) habe ich um 16:13 auf `main` zusammengeführt (Merge a2ffe611, CI grün). Grundlage war nur die Übergabe meines Vorgängers („vom Chef 14:14 abgenommen“). Ein „passt“ von dir zu Build 83 steht in keiner Notiz. Hast du Build 83 abgenommen?

**Empfehlung:** Ist er abgenommen, schreibe ich das Changelog, lösche `ansehen/t83-menue.md` und streiche 320 und 333. Wenn nicht, mache ich den Merge mit einem Revert-Commit rückgängig (das ändert den Verlauf nicht), und Build 83 wartet wieder auf deinen Test.

**Stärkstes Gegenargument:** Build 84 baut ohnehin auf Build 83 auf, und du hast Build 83 schon gespielt (343 fandest du darin). Ein Revert kostet einen Durchgang mehr, ohne dass der Code anders wird.
