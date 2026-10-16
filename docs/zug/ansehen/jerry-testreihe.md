# Jerry · Testreihe 16.10. (#70, #72–#82)

Jerry · 16.10., 13:5x · von Sokrates Projekt übertragen (11:2x), von Jerry ergänzt. Vorher-/Nachher-Bilder und Hörproben kamen per Telegram.

Kurz: Zwölf Builds von Jerry nach Toms #71: Keuchen, Rauchbündel, Lautstärke, Umweltklang, Türklang, Fluss, Intro-Klang, Glocke, Sterbehaltung, Krogg, Zustände, Absturz Klang

**Vorher wichtig:** Die Builds stammen von 08–10 Uhr, ihre Nummern liegen unter `main` 0.1.773 und sie enthalten Toms #71 noch nicht. Hast du 0.1.773 installiert, lässt Android sie nicht darüber installieren. Dann baue ich alle zwölf neu, mit `main` darin und in dieser Reihenfolge steigend; dafür brauche ich dein Okay (Rückfrage [108a](dz:108a)).

APK je PR: unten im PR unter „Checks“ → „build“ → „Artifacts“. Testmenü: Reiter „Test“ (Uhrzeit +3 h, Teleport, „Held trifft immer kritisch“, „Bosse zurücksetzen“, „Alle Vorräte auf mindestens 10“).

| # | PR | Nr. | Wo und wie | Richtig | Falsch |
|---|---|---|---|---|---|
| 1 | [#70](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/70) | 95 | draußen rennen, bis die Atemanzeige leer ist; dann stehen bleiben, 10 s zuhören | Held keucht erst dicht, dann leiser mit Pausen, 5–10 s, bis er wieder rennen darf | stumm, oder Keuchen läuft weiter, wenn er wieder rennen darf |
| 2 | [#72](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/72) | 38, D4.1 | Höhle, Rauchbündel in der Tasche (beim Händler oder „Vorräte auffüllen“), Kampf gegen Krogg beginnen; danach verlieren | Held wirft das Bündel zu Kampfbeginn selbst, Kroggs erster Hieb geht ins Leere; nach Niederlage liegt das Bündel wieder in der Tasche | Bündel bleibt ungenutzt oder ist nach der Niederlage weg |
| 3 | [#73](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/73) | 40, 13e.6 | Menü → System: drei Regler; in der Höhle „Dunkle Töne“ von 0 auf 100 % | Gesamt, Musik, Effekte wirken einzeln (Ortsklang hängt an „Effekte“); Schwarz hebt sich höchstens leicht, Prüfzeichen gerade noch sichtbar | ein Regler ohne Wirkung; Höhle sieht hell und grau aus |
| 4 | [#74](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/74) | 84, D3.15 | Tiefer Wald nachts (Uhrzeit +3 h), 3 min stehen; Höhle 3 min; Wiese am Dorf, auf pickende Vögel zugehen | Tiefer Wald ohne Vogelgesang und Eule, fernes Wolfsgeheul alle 1–2½ min von einer Seite; Höhle selten leises Grollen; Vögel flattern hörbar auf, scharren ab und zu | Vogelgesang im Tiefen Wald; Geheul laut oder im Takt |
| 5 | [#75](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/75) | D3.1, D3.4 | im Dorf durch eine Tür gehen und daneben an der Wand entlang; am Lagerfeuer stehen, während Kampfklänge spielen | Türklang nur auf der Tür; Feuer und Ortsklang reißen nicht ab | Türklang ohne Tür; Feuer verstummt |
| 6 | [#76](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/76) | D6.4 | im Dorf zum Fluss und über die Brücke, dann 10 Felder weg | Rauschen am Fluss, auf der Brücke am lautesten, ab etwa 8 Feldern still; Weiher still | kein Rauschen, oder es reißt beim Gehen ab |
| 7 | [#77](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/77) | 69c | neues Spiel, Intro nicht überspringen | Bild 1–4 je eigene leise Mischung (Wind, Grillen, Fluss), zum Schwarzbild still | Klang lauter als die Musik; Sprung zwischen den Bildern |
| 8 | [#78](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/78) | 69c.1 | wie 7, bis Bild 5; dann antippen | dumpfe Glocke schwillt an, drei Rufe, ein ferner Schrei unter der Titelmusik; Antippen: Glocke klingt aus | Glocke bricht hart ab |
| 9 | [#79](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/79) | 51 | einen Kampf verlieren (Magier und eine zweite Klasse), dreimal | Held liegt am Boden, kein Arm in der Luft, fällt nicht aus dem Bild | Arm steht nach oben; Held verschwindet links |
| 10 | [#80](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/80) | 36.6 | Test: „Held trifft immer kritisch“ an, „Bosse zurücksetzen“, Krogg töten (Schwert und Speer) | Stücke beim Zerteilen und Durchbohren so fein wie Krogg selbst | grobe Pixel an den Stücken (Oberkörper teils hinter dem Rand: bekannt) |
| 11 | [#81](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/81) | 53 | Krogg mit Feuer treffen (Feuerzauber oder Alchemistenfeuer) | Flammen sitzen auf Kroggs Umriss | Flammen links neben ihm |
| 12 | [#82](https://github.com/tramour-cmyk/androidapp_rpg_bornim/pull/82) | 30 | App starten und sofort beenden (Zurück), dreimal | kein Absturz (sonst nichts zu sehen) | „App wurde beendet“ |

**Außerdem bei Jerry, wartet auf dich:** D1.14 Höhlen-Klangbett (Empfehlung: Tropfen und Grollen behalten, Hörner heraus; Hörprobe mit und ohne folgt per Telegram). 72u Standbild Grak im Wald (A/B/C): die Frage stellt Sokrates Kreativ. 18 Gegnerstimmen: [18.11](dz:1811).
