# 1530 · Intro Bild 3: Fackelträger laufen wieder in den Tempel · Tom · 17.11., 12:17

[Film von 17.11., 12:18](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261117-121847-1530/2026-11/17-1218-1530-Tom.mp4) (eingetragen von meldung.sh, Tom)

E Zwischenbilder · Tom · 17.11. · aus deinem Wort 08:49 (an Sokrates): „Mit den Fackeln in den Tempel. Kann das sein? Wenn ja, das brauchen wir auf jeden Fall wieder.“

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/7bf95ee1d (`claude/tom-1530-fackeln`, Film am Rechner, Großbild: Telegram 17.11. 12:18)

Film 8 s, Bild 3 des Intros: fünf Träger gehen die Straße entlang und den Tempelweg hinauf, die Fackeln werfen Licht aufs Pflaster und spiegeln sich in der Pfütze, einer nach dem anderen verschwindet hinter dem Tempel. Vorher (Build 295) war das Bild leer.

Ursache: Die Ebene für den Zug wurde seit dem Umzug gebaut, aber nie ins Bild gehängt, darum nie gezeichnet. Code und Daten waren wie alt (`IntroScreen.kt` squareLife). Ein Test fängt das künftig.

Offen (eigene Prüfung, du urteilst):
- Aufnahme im Renderer Compatibility: Vulkan läuft am Rechner nicht. Der Zug ist reine 2D-Zeichnung, am Handy ist er gleich; Prüfzeile im nächsten Sammelbuild.
- Kein Film der alten Fassung daneben: die alte App läuft hier nicht.

👍 passt: in den nächsten Sammelbuild (Intro am Handy ansehen) · 👎 falsch: mit Fund, was im Vergleich zu alt fehlt
