# 131 · Rennen als Wahl oder als Normalfall?

Sokrates · 17.10., 15:2x · G Balance · Auftrag Chef 17.10., 00:41 („Build 11 passt. @Sokrates Müssen nochmal über Laufen, Gehen, Ausdauer und Nachteile sprechen. Oder mit Perikles?“), zu 86 (Jerry, auf `main`)

Kurz: Laufen, Gehen, Ausdauer (Empfehlung E: Rennen kurz, Steigerung sichtbar, Gehen bleibt)

**Chef 17.10., 15:2x:** „das ist ein einziges Rennen über die Karte. Man kann irgendwie fast gar nicht langsamer machen. Also ich finde die Grundgeschwindigkeit des Gehens schon schnell. Und dann bin ich eh fast immer am Rennen. Und das hält viel zu lange. Wenn ich einen Magier wähle … Magierstufe 1. Ich muss viel eher die Puste ausgehen. … entweder gibt es dann einen Fuhrmann, der einen mitnimmt, oder es gibt andere Möglichkeiten. … Aber die Karten per se sind zum Erkunden da. … und da ist keine Steigerung erkennbar, dann mit irgendwelchen Tränken, oder weil ich Level 20 bin irgendwann, dann macht das für mich gar keinen Sinn.“

**Chef 17.10., 15:2x, dazu:** „wie lange gehe ich denn sonst, wenn ich von einem Haus zum anderen gehe? Dass das so langsam muss es im Zweifelsfall nicht unbedingt sein, aber es müssen sich ja irgendwie in der Grundgeschwindigkeit Klassenunterschiede und Attributsunterschiede herausstellen lassen. Weil ansonsten bringt das alles nichts.“ Noch nicht entschieden: „Das muss ich mir erst durchlesen.“

**Zur Grundgeschwindigkeit (Ergänzung zu E):** Das SRD kennt Unterschiede nur nach Volk (Zwerg, Halbling 25 statt 30 Fuß) und Rüstung (schwere Rüstung ohne genug Stärke −10 Fuß), nicht nach Klasse oder Geschick. Für spürbare Unterschiede (Leitbild 4: SRD als Gerüst) Vorschlag: Gehen nach Volk und Rüstung wie im SRD, dazu Geschick ±5 % je Bonus; Rennen und Ausdauer nach Konstitution und Stufe wie in E. Ein Feld ist etwa 1,5 m, heute geht der Held also etwa 4,5 m/s, ein Mensch geht 1,4 m/s; das Spiel darf schneller sein, aber nicht als Joggen.

**Nachgerechnet:** Gehen etwa 3 Felder je Sekunde, also eine Bildschirmbreite (6,75 Felder) in gut 2 s; Rennen etwa 5,7 Felder je Sekunde, 20 s lang = rund 110 Felder am Stück.

**Heute (Build 11, `Stamina.kt`, `FreeWalk.kt`):** Gehen 200 ms je Schritt, Rennen 110 ms (fast doppelt so schnell), solange die Taste gedrückt ist. Vorrat 20 s Rennen bei Konstitution 10 (±3 s je Bonus, halb bei zu schwerer Rüstung); füllt sich in 40 s gehend, 20 s stehend, voll bei Rast. Leer: gehen, bis ein Viertel zurück ist. Rennend bemerken Monster den Helden 2 Felder früher; außer Atem in den Kampf = Initiative mit Nachteil. Keuchen und Balken, wenn nicht voll.

**Frage:** Wofür soll Rennen da sein?

- **A So lassen:** Rennen ist der Normalfall, Ausdauer und Nachteile setzen eine Grenze. Zahlen nur im Test eichen.
- **B Gehen schneller, Rennen für Lagen:** Gehen etwa 25 % schneller (rund 160 ms), damit es sich nicht wie Strafe anfühlt; Rennen bleibt kurz und laut, für Flucht, Aufholen, Wege im Dorf. Nachteile bleiben.
- **C Rennen ohne Ausdauer:** ein Schalter Gehen/Rennen, Rennen kostet nichts außer Lärm (früher bemerkt); kein Balken, kein Keuchen, kein Nachteil.
- **D Ausdauer nur gefährlich, nie lästig:** Vorrat deutlich größer (etwa 60 s), Erholung schneller; die Nachteile greifen nur, wenn man wirklich leer in einen Kampf rennt.

- **E (nach Rückmeldung Chef):** Gehen bleibt, wie es ist; über den Joystick (halber Ausschlag) langsamer schreiten möglich. Rennen kurz: etwa 6 s bei Konstitution 10 (±2 s je Bonus), Erholung wie heute; Steigerung sichtbar über Konstitution, Stufe (z. B. +1 s je zwei Stufen), Ausdauertrank, leichte Rüstung. Weite Wege kürzen Fuhrmann, Wegmarken oder Schnellreise, nicht das Tempo.

**Votum: E** (ersetzt B; B ging davon aus, dass Gehen sich langsam anfühlt, der Chef erlebt das Gegenteil).

~~Votum B:~~ Rennen ist nur eine Wahl, wenn Gehen gut genug ist. Heute ist Gehen fast halb so schnell; wer am Handy weit muss, hält die Taste und läuft in den Balken. Dann bestraft das Paket das normale Spielen (Leitbild 3 „keine Pflicht bei Nebensachen“, 45 „kein künstlicher Laufweg“).

<details><summary>Warum, und das stärkste Gegenargument</summary>

**Warum:** Ein Nachteil ist nur dann eine Entscheidung, wenn man ihn bewusst eingeht („ich renne zum Ausgang, obwohl der Ghul mich dann früher hört“). Das geht nur, wenn Gehen die gute Grundgangart ist. B ändert eine Zahl (Gehtempo) und lässt alles Gebaute stehen; billig und umkehrbar.

**Stärkstes Gegenargument gegen E:** am Handy beschweren sich Spieler über zähe Wege; kurzes Rennen macht jede weite Strecke länger, und Fuhrmann oder Schnellreise sind neuer Inhalt (Kosten, Story über Homer). Ohne sie verstößt E gegen 45 „kein künstlicher Laufweg“. Darum E nur zusammen mit einem Weg zum Abkürzen.

**Früheres Gegenargument (C):** Die einfachste Lösung, und in Handyspielen erwartet man freies Rennen; Ausdauer auf der Karte ist ein Pen-and-Paper-Rest, der vom Kampf ablenkt. Gegen C spricht: dann ist Rennen wieder immer richtig, und Lärm allein wirkt nur in der Nähe von Monstern.

**Zweites Gegenargument:** schnelleres Gehen verändert, wie Monster den Helden einholen (Jäger, Flucht); Jerry muss die Verfolgung neu prüfen.

**Für das Gespräch:** (1) Bist du in Build 11 meist gerannt? (2) Was hat gestört: Gehtempo, leerer Balken, Keuchen, Nachteil im Kampf? (3) Perikles braucht es nicht; Regeln und Spielgefühl gehören hierher.

</details>

Berührt: 86, 84.4, 86.3, 86.6, 86.9–86.11, 38
