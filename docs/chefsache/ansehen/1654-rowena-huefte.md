# 1654 · Rowena: sticht das Kleid an der Hüfte sichtbar durch?

Jerry · 18.11., 21:30 · E Figuren · aus Toms Durchstechprüfung 1631 (Lauf 560)
Kurz: Rowena in „Ruhe am Tresen“, Hüfte und Gürtel (0,9 m), vorn, 50° rechts, 50° links. Mein Befund: sichtbar, braune Zacken des Oberkleids stechen unter dem Gürtel seitlich durch die Schürze.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/508bbbbad (`claude/build-300`), Bild am Rechner mit Kaufdaten (Block klassen 5842531b), Messung `durchstich_1631`: Rowena 9–31 Ecken, meist `Kleid#0>Kleid#9` 0,9 m (Schwelle steht schon auf diesem Wert, 1667)

- Offen: Behebung im Bau der Kleidung (`kauf_kleid.py`, Unterlage unter der Schürze weg oder nach innen), dann Schwelle senken.
- Bekannt: Bild ohne Spiellicht und Tusche (Prüfbild der Kleidung).
- 👍 passt: nichts sticht sichtbar durch, so lassen.
- 👎 falsch: sichtbar, beheben.
