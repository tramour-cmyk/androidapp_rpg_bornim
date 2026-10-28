# Tom und Jerry · Build 132 · Godot 0.348.132 · 399 Spielfassung: Wald und Wolfskampf, Hauptmenü, Schrift, Gesprächsfenster · ohne PR

B Umzug · Tom und Jerry · 28.10., 15:47 · APK: [Lauf 132](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/40705569049/artifacts/12823804817) (Kennung de.bornim.game.godot neben dem alten Spiel). Nur, was in 130 nicht ging oder fehlte (deine Reihenfolge 14:38). Geprüft gegen `DESIGN-STIL.md` „Auf einen Blick“ und „Oberfläche“, `DESIGN-BLENDE.md` „Vorspann und Hauptmenü“ und das alte Hauptmenü (`App.kt`) und Gesprächsfenster (`DialogDraft.kt`).

**Vor dem Installieren, ein letztes Mal:** die Godot-Probe (Kennung de.bornim.game.godot, nicht das alte Spiel) deinstallieren. Ab 132 tragen alle Godot-Builds denselben Schlüssel (399.1a).

| # | Team | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 132.1 | Tom | 399.1 | App starten | Hauptmenü wie im alten Spiel: schwarz, Titel „CHRONIKEN VON BORNIM“ ohne Umbruch im Wort, Zier, Kapitelzeile, Bild der vier im Lichtkegel, „NEUES SPIEL“, rundes „DE“, Firmenzeichen und Versionszeile; alles mittig, keine Probeknöpfe, keine Windrose | graugrün, Text links, Knöpfe darüber |
| 132.2 | Tom | 399.1 | Neues Spiel bis „Abenteuer beginnen“, dann im Dorf Leute ansprechen | Schrift überall Alegreya; Gesprächsfenster schwarz mit dünnem Goldrand, Name klein in Gold im Kasten, Text hell, Erzähltes schräg, ▼ blinkt in Gold | alte Standardschrift, „Name: Text“ in einer Zeile |
| 132.3 | Tom, Jerry | 399.1, 399.2a | Mit Erlaubnis durch den Schlagbaum nach Norden, Flüsterwald antippen | Kampf beginnt: ein Wolf mit ein oder zwei Jungwölfen, bis zum Ende spielbar | „Grundriss folgt“, kein Kampf, Kampf hängt |
| 132.4 | Tom | 399.1 | Kampf gewinnen (fällt der Wolf, fliehen die Jungwölfe) | wieder im Dorf vor dem Waldausgang, Trefferpunkte wie am Kampfende, Gold und EP dazu | volle TP, falscher Ort |
| 132.5 | Tom | 399.1 | Kampf verlieren | „Du erwachst an einem sicheren Ort …“, ganz geheilt vor der Schenke, vier Stunden später | Spiel bleibt stehen |
| 132.6 | Tom | 399 | Nach einem Kartenwechsel die App schließen, neu starten | im Hauptmenü „WEITER“ mit Name, Stufe, Ort; antippen: am selben Ort, Gold, TP und Taschen wie zuvor | neuer Held, falscher Ort |

Bekannt, kein Testpunkt: Spielstände, Über, Musik und Klang fehlen im Hauptmenü noch; die Erschaffung hat den neuen Look, aber noch nicht den Aufbau des alten Spiels; im Dorf liegen weiter die Probeknöpfe oben rechts (nur zum Testen); der Wald ist vorerst nur der Kampf. Am Rechner verliert ein Held der Stufe 1 ohne Spieler (Autopilot) gegen das Rudel mit Kämpfer, Magier und Kleriker; Jerry prüft das (399.2b).
