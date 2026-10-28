# 399.2d · Godot am Rechner freigeben, damit Kampftests ohne CI-Lauf gehen
Jerry · 28.10., 18:05 · E Kampf
Kurz: der Auto-Modus lehnt den Download von Godot 4.7.2 ab (17:2x und 18:00); Tom testet damit am Rechner, Jerry nicht

**Was:** In einer Jerry-Sitzung den Download von Godot 4.7.2 (github.com/godotengine, wie im Workflow `godot.yml`) erlauben, oder in den Einstellungen eine Erlaubnis dafür setzen (Bash, `curl` nach github.com/godotengine).

**Warum:** „Wolf läuft durch Wolf“ (399.2) ist noch nicht behoben: Tom hat den Test am Rechner laufen lassen (17:42), auch ohne den gekauften Wolf steht ein Wolf bis 0,92 m in einem anderen. Die Ursache muss ich Bild für Bild nachstellen, bevor ich noch einmal baue (Bekannte Fehler: nie zweimal mit Vermutung). Ohne Godot kostet jeder Versuch einen CI-Lauf, höchstens zwei je Vorlage (389), und die sind für 399.2 verbraucht; mit Godot zählen Tests ohne Bild nicht als Probelauf (390a). Den Test über Tom laufen zu lassen, hat der Auto-Modus ebenfalls abgelehnt.

**Berührt:** 399.2 (Wolf durch Wolf), 399.3 (Klang), 348.12 (Goblin), 348.7 (Kampfort)

Die frühere Frage 399.2c (dritter CI-Lauf) ist damit hinfällig: der Lauf würde nur bestätigen, was Toms Test schon zeigt.

Erledigt: Datei löschen.
