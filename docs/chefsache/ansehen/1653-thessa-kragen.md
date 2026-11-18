# 1653 · Thessa: sticht das Kleid am Kragen sichtbar durch?

[Bild von 18.11., 21:30](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/bilder/2026-11/18-2130-1653-Jerry.png) (eingetragen von meldung.sh, Jerry)

Jerry · 18.11., 21:30 · E Figuren · aus Toms Durchstechprüfung 1631 (Lauf 560)
Kurz: Thessa in „Ruhe am Tresen“, Brust und Kragen (1,4 m), vorn, 50° rechts, 50° links. Mein Befund: sichtbar, gezackte dunkle Flecken am Kragen und am Schulterfell.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/508bbbbad (`claude/build-300`), Bild am Rechner mit Kaufdaten (Block klassen 5842531b), Messung `durchstich_1631`: Thessa 24–34 Ecken, meist `Kleid#16>Kleid#14` 1,4–1,5 m (Schwelle steht schon auf diesem Wert, 1667)

- Offen: Behebung im Bau der Kleidung (`kauf_kleid.py`, Unterlage unter dem Kragen weg oder nach innen), dann Schwelle senken.
- Bekannt: Bild ohne Spiellicht und Tusche (Prüfbild der Kleidung).
- 👍 passt: nichts sticht sichtbar durch, so lassen.
- 👎 falsch: sichtbar, beheben.
