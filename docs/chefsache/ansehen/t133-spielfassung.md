# Tom · Build 133 · Godot 0.348.133 · 399 Spielfassung: Erschaffung, Spielstände, Leiste, Menü; Dorf · ohne PR

B Umzug · Tom · 28.10., 16:49 · APK: [Lauf 133](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/40716450882/artifacts/12828143859) (Kennung de.bornim.game.godot, installiert sich über 132). Nur, was nach Test 132 neu ist (16:09: „4 Stunden später … sehe ich nicht … Gold … Trefferpunkte … Taschen … es gibt ja kein Menü“; 16:12 Dorf). Bilder dazu hast du um 16:36 mit „ja“ abgenommen (Archiv 399.1). Geprüft gegen `DESIGN-STIL.md` „Oberfläche“ und das alte Spiel (`CreateScreen.kt`, `SlotsScreen.kt`, `HudChip`, `MenuScreen.kt`).

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 133.1 | Tom | 399.1 | Hauptmenü, „Neues Spiel“ | eine Seite wie alt: oben der Held, der sich dreht, mit TP, RK, Werten; darunter Name, Volk, Klasse, Punktekauf; Wahl ändert die Werte oben sofort | Schritt für Schritt wie in 132, Held fehlt |
| 133.2 | Tom | 399.1 | „Abenteuer beginnen“, im Dorf | Leiste oben: TP, EP und Stufe, Sonne, „Tag 1 · 08:0x“, die Uhr läuft (eine Spielminute je Sekunde); Magier und Kleriker auch ZP | keine Leiste, Uhr steht |
| 133.3 | Tom | 399.1 | Leiste antippen | Menü „Held“ (Werte, Gold, Fähigkeiten) und „Tasche“ (Gold, Tränke, Ausrüstung); die Uhr steht, solange es offen ist; „Schließen“ zurück | nichts passiert, Uhr läuft weiter |
| 133.4 | Tom | 399.1 | in den Wald, Kampf verlieren | „Du erwachst …“ in der Schenke neben dem Bett (im Tempel, wenn der Priester dich zuletzt geheilt hat); Leiste vier Stunden später | vor der Tür, gleiche Uhrzeit |
| 133.5 | Tom | 399 | Kartenwechsel, App schließen, neu starten | Hauptmenü „Weiter“ mit Name, Stufe, Ort; daneben „Spielstände“ und „Über das Spiel“; „Weiter“: gleicher Ort, Gold, TP und Tasche im Menü wie zuvor | neuer Held, Tasche leer |
| 133.6 | Tom | 399.1 | Hauptmenü, „Spielstände“ | vier Plätze; „Löschen“ fragt nach; „Neues Spiel“ in einem leeren Platz | Liste leer, Löschen ohne Frage |
| 133.7 | Tom | 348.6 | Dorf südlich des Flusses; gegen Leute oder Tiere laufen | keine Kuh, eine Ziege; wer im Weg steht, tritt nach kurzem Drücken zur Seite (Wachen nicht) | Kuh, drei Ziegen, Weg bleibt zu |

Bekannt, kein Testpunkt: im Menü fehlen noch Ausrüstung, Karte, Chronik, System, Dinge benutzen; Aussehen in der Erschaffung (376.1); Musik und Klang (Jerry, 398); Wolf läuft durch Wolf (Jerry, 399.2).
