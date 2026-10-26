# 348.7 · Godot-Kampf: Trefferwirkung wie im alten MARS · Jerry · 26.10., 16:56

**Ansehen:** Bildfolge je 9 Bilder ab dem Aufschlag (0 bis 1600 ms), Mira schlägt einen Wolf: [tödlich](bilder:pruefung/348.7-treffer-kill.png), [kritisch](bilder:pruefung/348.7-treffer-crit.png). Gebaut ist, was der alte MARS-Kampf hatte (249) und dem Godot-Kampfort fehlte, mit denselben Werten: Bei einem kritischen Treffer rückt die Szene 6 % an den Getroffenen heran und ruckt einmal in Schlagrichtung, bei einem tödlichen 10 % und länger. Der Getroffene zittert kurz. Ein Hieb, Biss oder Schuss, der trifft, lässt wenige karminrote Tropfen (nicht grell) weg vom Schlagenden spritzen, auf Schulter- bis Halshöhe (Blutstufe „wenig“, die Vorgabe im alten Spiel). Das orange Aufleuchten des Getroffenen ist heraus, das alte Spiel hatte es nicht. Zweig `claude/jerry-348-kampf`, 71f5398d5.

**Erreicht (fremde Prüfung, 3 Runden):** Kritisch abnahmereif. Zoom mit der Mitte an den Füßen des Getroffenen, ohne schwarze Ränder, die Bedienleiste bleibt ruhig. Das Blut fliegt vom Helden weg, ist nicht grell und liegt unter den Ansagen. Der Lebensbalken sinkt beim Aufschlag.

**Bekannt, nicht behoben (fremde Prüfung):**
- **Tödlich: die Ansage des Nachbarwolfs springt über den sterbenden Wolf** und verdeckt dessen Sturz und das Blut bis über 1 s. Vermutete Ursache, nicht nachgestellt: ein Wolf ohne LP zählt beim Ausweichen der Ansagen nicht mehr als Figur.
- Die Ansage des Toten zeigt bis zur nächsten Meldung („fällt“) auf leeren Boden. Sein Bodenschatten liegt noch etwa 0,4 s allein auf dem Weg, nachdem der Wolf schon ausgeblendet ist.
- Einzelne Tropfen blenden im Flug aus, statt zu fallen; das ist bei Blutstufe „wenig“ im alten Spiel genauso. Das Zittern ist in Standbildern nicht prüfbar.
- Älter als diese Änderung: Die Heldin schlägt aus etwa zwei Wolfslängen, dreht beim Treffer schon zum Rücklauf um und läuft durch den Nachbarwolf zurück. Beim Rücklauf (110–330 ms) sieht sie anders aus als davor und danach (Kettenhemd und Rundschild statt Umhang und Spitzschild), Ursache nicht nachgestellt. Auch beim kritischen Treffer springt die Ansage eines Wolfs um etwa 300 px, sobald sie zurückläuft.

**Vorschlag:** Der Nachfolger behebt zuerst die springende Ansage. Danach die Schlagbewegung der Heldin: Hieb in Waffenreichweite, Umdrehen erst nach dem Halt, Rückweg um die anderen Figuren herum.

**Sag:** „ja“ oder was anders werden soll.
