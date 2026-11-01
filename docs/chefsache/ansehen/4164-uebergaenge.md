# 416.4 · Weiche Übergänge Stehen, Gehen, Rennen · Tom (Team Tom) · 01.11., 15:0x

[Film von 01.11., 15:02](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@bilder/2026-11/01-1502-416.4-Tom.mp4)

Film per Telegram, zwei Felder untereinander, beide Held ohne Waffe mit Rennen A (dein „A“ von 13:1x): oben **vorher**, unten **weich**. Je 7 s: Stehen, Anlaufen, Gehen, Rennen, zurück ins Gehen, Abbremsen, Stehen. Erst Spielansicht, dann von der Seite, dann dasselbe in halber Geschwindigkeit. Noch kein Build; Zweig `claude/tom-416-4-rennen`.

Was „weich“ ändert (gilt für Held, Leute und Tiere):
- **Anlaufen:** aus dem Stand mit gut einem Drittel des Gehtempos los, in etwa 0,3 s auf vollem Gehtempo (vorher sofort volles Tempo).
- **Abbremsen:** vor dem Ende des Wegs langsamer, aus dem Rennen über das Gehen bis zum Stand (vorher voller Schritt bis zum Halt).
- **In den Stand:** Haltung blendet 0,45 s über (vorher 0,25 s).
- **Leute auf ihrer Runde** stehen nicht mehr bei jeder Kachel ein Bild lang und springen dann an eine zufällige Stelle im Schritt (das war ein Ruck je Kachel); sie gehen durch. Das zeigt der Film nicht, das siehst du im nächsten Build im Dorf.

Gehen ↔ Rennen blieb, wie du es zu 417 genannt hast („Rennen und Übergang passen“).

**Prüferbefund (15:1x, nach dem Versand), Fehler, die Tom behebt:** Rennen → Gehen springt in beiden Feldern in einem Bild in die aufrechte Haltung (Film 4,6 s, 11,6 s, 23,3 s); ist es auch im Spiel so, stimmt dein „Übergang passt“ zu 417 nur für Gehen → Rennen. Füße gleiten beim Anlaufen (unten wie oben gut 20 Bildpunkte), beim Wechsel Gehen → Rennen (Tempo schon voll, Beine noch im Gehtakt) und nach dem Anhalten (Stiefel rutscht 20–27 Bildpunkte). Unten deutlich weicher: das Anhalten (oben springt das Tempo von voll auf null und die Haltung schnappt in den Stand); Anlaufen unten nur im Tempo weicher.

**Frage:** Sind die Übergänge so weich genug?
**Stärkstes Gegenargument:** Anlaufen und Bremsen machen die Steuerung träger: der Held kommt etwa 0,15 s später an als vorher, und wer schnell tippt, merkt das vielleicht. Wenn es zu träge wirkt, wird das Anlaufen kürzer, ohne den Ruck zurückzubringen.

**Zu sagen:** „416.4 passt“ (dann fährt es im nächsten Build mit) oder was anders sein soll.
