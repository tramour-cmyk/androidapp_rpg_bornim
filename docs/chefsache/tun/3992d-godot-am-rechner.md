# 399.2d · Godot am Rechner freigeben, damit Kampftests ohne CI-Lauf gehen
Jerry · 28.10., 17:2x · E Kampf
Kurz: der Auto-Modus lehnte den Download von Godot 4.7.2 ab; frühere Jerry-Sitzungen testeten damit am Rechner

**Was:** In einer Jerry-Sitzung den Download von Godot 4.7.2 (github.com/godotengine, wie im Workflow `godot-kampf.yml`) erlauben, oder in den Einstellungen eine Erlaubnis dafür setzen.

**Warum:** Ohne Godot am Rechner kostet jeder Test einen CI-Lauf, höchstens zwei je Vorlage (389). Mit Godot laufen die Tests ohne Bild am Rechner, die nicht als Probelauf zählen (390a).

**Berührt:** 399.2, 399.2c, 399.3

Erledigt: Datei löschen.
