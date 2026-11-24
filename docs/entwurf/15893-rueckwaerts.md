# 1589.3 Rückwärts und Seitschritt der Menschengestalten (Beleg, Sabine 24.11.)

Film `15893-rueckwaerts.mp4` (14,8 s, Commit `87dd03a00`, Zweig `claude/1589.3-rueckwaerts`): Held Mann (oben), Frau (unten), von der Seite (25° schräg, damit auch der Seitschritt vorankommt); links alt (Gehen rückwärts abgespielt wie `kampf/figur.gd` 1741, 3369), rechts neu (`HeldFigur.gang_wahl`); Rückwärts, rückwärts schräg links, schräg rechts, Seitschritt links, rechts, je dreimal (speed_scale 1,39).

| Messung im Film (`tests/gang_film_1589.gd`) | alt | neu |
|---|---|---|
| Standfuß gleitet, Median (cm/s), rückwärts gerade | 2,0 / 2,6 | 1,3 / 2,1 |
| rückwärts schräg | 121–122 | 1,3 / 2,1 |
| Seitschritt | 125–129 | 0,4–2,4 |
| Kopf aus dem Blick im Stehen, höchstens | 4° | 4–11° |

Werte Mann / Frau. Das Gesicht zeigt in allen fünf nach vorn (Figur dreht nicht).

Wahl je Richtung (Systemfrage): wie Godot `AnimationNodeBlendSpace2D` im Modus „diskret“ (spielt die Bewegung, deren Punkt am nächsten liegt; docs.godotengine.org, gelesen 24.11.) und die übliche 8-Wege-Fortbewegung in Unity/Unreal (acht Richtungen zu je 45°; mocaponline.com Locomotion-Leitfaden, gelesen 24.11.); einfachste Form: Achtel des Winkels zwischen Blick und Weg → Bewegung, vorn und schräg vorn Gehen.

Test `tests/gang_wahl_1589.gd`: 29 Figuren (8 Herkünfte × Mann/Frau, 13 Leute), 849 Fälle, 0 Fehler.
