# 1109 · Wie machen wir die Bauläufe zuverlässig und schneller: Vorberechnung erst sicher machen, dann Leute und Prüfungen beschleunigen?
Diogenes · 13.11., 10:00 · B Werkzeuge · aus deinem Wort 09:44 („Bitte, das ist wichtig. Da sparen wir Geld und ganz viel Zeit.“) und 09:45
Kurz: die Vorberechnung trägt und spart etwa 65 von 115 Minuten je Lauf, hat aber drei stille Lücken; dazu zwei Wege, Läufe weiter zu kürzen, und einer gegen falsches Rot

Geprüft an: [Lauf 420](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/43370553634) und die Protokolle von 34 Bauläufen 12.–13.11. (Läufe 384–420), alle 104 Läufe seit 10.11. (GitHub), Werkzeug `tools/godot/kauf_cache.py` auf Jerrys Zweig `claude/jerry-1101-teile` und im Build 282, dessen Probe `kauf_cache_probe.sh` am zusammengeführten Stand (15 Prüfungen, alle gut), privates Kaufrepo (Größe, abgelegte Stände)

**Frage:** Die Vorberechnung legt die teuren Modelle in vier Teilen („Blöcken“: Held, Dorf, Held je Klasse, Kampfort) einmal gebaut im privaten Kaufrepo ab und holt sie im nächsten Lauf, statt sie neu zu bauen. Ob ein Block neu gebaut werden muss, entscheidet ein Schlüssel aus allen Dateien, die er liest. Sie trägt, hat aber Lücken, durch die du still einen alten oder halben Stand testen könntest. Sollen wir zuerst die Lücken schließen (A), danach die Läufe weiter kürzen (B, C) und das falsche Rot abstellen (D)?

**Votum:** „1109 A, D“: Vorgang 1101 (Teilen großer Dateien) in den nächsten Build, Vorgänge 1111 bis 1113 bei Jerry als Muss, Prüfliste-Test nur in Sammelbuilds; B und C erst nach einer Woche mit A, gemessen.

**Berührt:** 1101 Teilen großer Dateien, 1111 Gegenprobe, 1112 halber Block, 1113 Aufräumen Kaufrepo, 1114 Kampfort ohne Held (alle Jerry), 1115 Leute als Block (Tom), 1116 Geldwert (Perikles), 1087 Prüfliste-Test (Tom, erledigt), 909 Prüfungen nebenher, Diogenes (Nachprüfung)

**Begründung:** Ein Treffer spart viel, aber nur, wenn er sicher dem frischen Bau gleicht; sonst testest du Falsches, und das wiegt schwerer als 65 Minuten. Darum zuerst die Sicherung, dann die Beschleunigung.

**Sachverhalt:**
- Trägt: in 24 von 34 Läufen trafen Held je Klasse und Kampfort; ein Lauf mit allen Treffern dauert etwa 49 Minuten (Läufe 388, 397), ein voller Bau 115 (Lauf 420: Modelle 5,5, Held je Klasse 36, Kampfort 21, Leute 11, Prüfungen 29, Standbilder 5, übrige Schritte 8).
- Warum es zuletzt nicht trug: seit Lauf 387 scheiterte das Ablegen am Dorf (eine Datei 122 Megabyte, GitHub nimmt höchstens 100); der alte Code hörte dort auf, Held je Klasse und Kampfort wurden danach nie abgelegt (Läufe 409 bis 420 bauten sie sechsmal neu). 1101 teilt große Dateien und macht mit den übrigen Blöcken weiter; mit Build 282 zusammengeführt ohne Konflikt.
- Schlüssel: jede der 36 Bauschriften wird erkannt, dazu Kaufpakete, freie Pakete, Blender-Fassung; die 60 übrigen Dateien unter `tools/blender348` benutzt kein Block. Zwei Schriften (Figur und Bewegungsgerüst) erkennt er beim Held je Klasse nur über den Block Held; das reicht, weil dieser Block sie liest.
- Lücke 1 (1111): die Gegenprobe (Startknopf „cache=neu“, Vorgang 910: voll bauen und mit dem Abgelegten vergleichen) baut seit 11.11. nicht mehr voll und vergleicht nur Geholtes mit sich selbst; in 34 Läufen lief sie kein Mal. Damit gibt es keinen Beleg, dass ein Treffer dem frischen Bau gleicht.
- Lücke 2 (1112): scheitert im Bau ein einzelnes Monster (Skelett, Wiedergänger, Grabhund, Grimmzahn, Kauftiere) oder brechen die Leute auf dem Kaufkörper nach 40 Minuten ab, läuft der Bau weiter und legt den halben Stand ab; jeder spätere Lauf liefert ihn als Treffer, ohne Fehlerzeile. In 34 Läufen kein Fall, früher Lauf 229 und 352.
- Lücke 3 (1113): das Kaufrepo hat 524 Megabyte in 21 abgelegten Ständen seit 11.11., gelöscht wird nichts; jede Änderung an Leuten oder Held legt etwa 300 Megabyte dazu. GitHub empfiehlt unter 1 Gigabyte, ab 5 fragt GitHub nach.
- Geld: die Minuten des Bauservers kosten nichts (das Spiel-Repo ist öffentlich); gespart wird Wartezeit, bei dir und in den Sitzungen (Geldwert bei Perikles, 1116).
- Läufe seit 10.11.: 104, davon 29 grün, 56 rot, 17 abgebrochen, 2 nicht gestartet. In 11 der 34 Läufe war der Prüfliste-Test rot, immer mit 14 Fehlern „Build 281“: der Bau nimmt die neueste Prüfliste von `main`, der Zweig eines Teams hat älteren Code (1087 ist erledigt, das Rot blieb bis Lauf 415). In 5 dieser 11 Läufe war es der einzige rote Test.
- Prüfungen: 193 Spielstarts nacheinander in 29 Minuten auf 4 Rechenkernen; 4 davon laufen schon nebenher (909).

**Auswertung:**
- **A (Empfehlung):** Lücken schließen. 1101 in den nächsten Build (fertig); 1111 Gegenprobe wieder echt (etwa eine Stunde Jerry), dann einmal je Woche ein voller Lauf mit Gegenprobe; 1112 halben Block nie ablegen (etwa eine Stunde); 1113 der Bauserver löscht je Block alles außer den drei neuesten Ständen (etwa eine Stunde). Wirkung: Lauf bei Treffer etwa 49 statt 115 Minuten, belegt statt geglaubt.
- **B:** Leute als fünfter Block (1115, Tom) und Kampfort ohne Abhängigkeit vom Held (1114, Jerry): spart etwa 10 Minuten in fast jedem Lauf, 11 bis 21 Minuten bei jeder Änderung an Leuten. Jeder weitere Block braucht einen weiteren Schlüssel, und jeder Schlüssel kann still falsch sein.
- **C:** Prüfungen auf zwei Bauserver teilen: mit A und B hat ein zweiter Lauf die Modelle in etwa 4 Minuten, die Hälfte der Prüfungen läuft daneben; spart etwa 12 bis 15 Minuten je Lauf. Braucht B zuerst, sonst baut der zweite die Leute selbst (10 Minuten); zwei Protokolle statt einem.
- **D:** Prüfliste-Test nur in Sammelbuilds (Zweige `claude/build-…`), wo die Liste zum Code passt: in 5 von 34 Läufen wäre der Lauf grün gewesen, in 6 weiteren ein falscher Befund weniger; keine Erklärzeilen „Rot: … fremd“ mehr. Auf den Zweigen der Teams fällt eine kaputte Prüfliste dann erst im Sammelbuild auf.
- **Stärkstes Gegenargument gegen A:** die Vorberechnung bleibt eine Schätzung, welche Dateien ein Block liest; auch mit Gegenprobe einmal je Woche kann ein falscher Treffer bis zu sechs Tage durchrutschen. Dagegen: ohne Gegenprobe rutscht er unbegrenzt durch, und jeder Treffer nennt im Protokoll seinen Schlüssel, so lässt sich jeder Build nachprüfen.

**Folgerungen:** Bei A: Tom mischt 1101 in den nächsten Build; Jerry baut 1111 bis 1113 als Muss; Diogenes prüft nach dem ersten Lauf (Dorf in Teilen abgelegt, nächster Lauf alles Treffer) und nach der ersten Gegenprobe. Bei D: Tom stellt den Prüfliste-Test um (1087 wieder auf). B und C legt Perikles nach einer Woche mit den Zahlen vor; bis dahin bleiben 1114 und 1115 als Fragen bei Jerry und Tom.

Antwort: …
