# 1141 · Goblins sterben verschieden · Team Jerry · 13.11., 16:06

[Film von 13.11., 16:07](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261113-160730-1141/2026-11/13-1607-1141-Jerry-2.mp4) (eingetragen von meldung.sh, Jerry)

[Film von 13.11., 16:07](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261113-160715-1141/2026-11/13-1607-1141-Jerry.mp4) (eingetragen von meldung.sh, Jerry)

[Film von 13.11., 16:06](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261113-160656-1141/2026-11/13-1606-1141-Jerry.mp4) (eingetragen von meldung.sh, Jerry)

E Kampf

Geprüft an: [Commit ef1fca272](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/ef1fca272) (Zweig `claude/jerry-1141-sterben`, Film am Rechner `film_tod_1141`, Test `tod_1141` gut)

Dein Fund (13.11., 14:36): Goblins und Schamane in Kraks Höhle fallen „wie Playmobil-Figuren … alle auf die gleiche Seite“. Ursache: die Regel aus 596 (zufällig zur einen oder anderen Seite) galt nur für Gegner mit eigener Sterbebewegung. Goblin, Späher, Schamane und Kobold hatten keine und kippten steif zur Seite, immer gleich.

Jetzt hat jeder dieser vier Gegner drei Sterbebewegungen wie im alten Spiel: (1) die Knie geben nach, er schlägt vornüber aufs Gesicht, die Arme vor sich; (2) vom Schlag zurückgeworfen fällt er auf den Rücken, die Arme weit; (3) herumgerissen sinkt er aufs Knie und kippt zur Seite. Welche, entscheidet der Zufall, dazu in der Hälfte der Fälle seitenverkehrt (596). Er liegt etwa dort, wo er stand, 1,2 s, dann vergeht er wie bisher.

Dabei behoben: seitenverkehrte Tote (auch Wölfe und alle anderen) waren am Rechner fast schwarz, die Beleuchtung lief auf die Innenseite. Am Handy nicht geprüft.

Je Gegner ein Film, 14 s: drei Tode hintereinander, im Kampfort mit Spiellicht, die Helden ausgeblendet. Oben links steht, welche Sterbebewegung und ob seitenverkehrt.

| Film | Gegner |
|---|---|
| 1 | Goblin |
| 2 | Goblin-Späher |
| 3 | Goblin-Schamane |
| 4 | Kobold |

Offen (gesehen, nicht behoben): beim Schamanen steht die Robe im Liegen eckig ab wie ein Brett (Film 3, erster und dritter Tod). Ob Waffen im Liegen in den Boden ragen, ist noch nicht geprüft.

Alle anderen Gegner hatten schon eine Sterbebewegung; ein automatischer Test beim Bau der App prüft künftig, dass jeder Gegner eine hat.

Passen die Sterbebewegungen? „passt“, dann fährt es im nächsten Build; sonst, was anders sein soll.
