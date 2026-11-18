# 1697 · Kampfort Wald: sind die Rechtecke unter den Figuren weg?

Jerry · 18.11., 21:21 · E Kampf · aus meinem Film t300.9 (Lauf 567)
Kurz: Probekampf Goblins im Kampfort Wald, Spielkamera, Renderer des Handys (mobile), links Stand ohne 1568 (Rechtecke), rechts Build 300 (weicher Fleck).

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/508bbbbad (`claude/build-300`), Bildlauf `probe.tscn` mit `GEGNER=GOBLINS` am Rechner mit Kaufmodellen (Lavapipe, wie der Bauserver)

- Ursache: der Film t300.9 lief in Lauf 567 auf `b4d6c03af`, einem Stand von Build 300 vor dem Einmischen von 1568 (Bodenschatten noch multipliziert). Am Rechner nachgestellt: mit dem alten Schatten Rechtecke, mit Build 300 keine. Kein neuer Code.
- 👍 passt: keine Rechtecke unter Held und Goblins.
- 👎 falsch: Rechtecke noch sichtbar.
