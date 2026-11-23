# Fälle Büro / Arbeitsplaner

Jeder Fall ist eine eigene Lage: eine offene Zeile an dich mit dem, was in der Vorgangsdatei steht. Die Vorgangsdateien `docs/vorgang/<Nr>.md` gibt es heute nur für wenige Nummern; was hier steht, gilt als ihr Inhalt. Lesen im Repo (`/home/user/bornim-main`, nur lesend) ist erlaubt: Vorgangsliste über `python3 tools/vorgang.py <Nr>`, Archiv, Git.

Wo ein Auftrag verlangt ist: schreibe ihn vollständig in eine eigene Datei `<Fall>.auftrag.md` neben deine Antwortdatei und prüfe ihn mit `python3 tools/vorgang.py auftrag <Nr> --datei <Pfad> --pruefen` (nur prüfen, schreibt nichts); steht die Nummer nicht in der Liste, nimm für die Prüfung 1694.

A1. Chefwort 18.11., 17:01 zu 1694 (Stab durch die Knöchel): „Als Systemlösung, genau. Jetzt sind wir nämlich wieder mal so weit damit, dass wir Sachzusammenhänge erkennen und deswegen auch Lösungen suchen und nicht ständig einzeln rumflicken.“

A2. Chefwort 18.11., 21:37 zu Bild 1694: „1694 ist nix zu erkennen...“

A3. Build-Auftrag mit Prüfpunkten liegt dir zum Ausarbeiten vor: „299.1 Handy: Hauptmenü, Wachsoldatin mit Schild ansehen“, „299.2 Handy: Fläche vor dem Schild“.

A4. Telegram: 👎 des Chefs zur Meldung „1535 Garrick alt gegen neu“, ohne Wort.

A5. Chefwort aus der Spracherkennung, vom Haken in die Vorgangsdatei 1727 getragen, 21.11., 15:15: „Ja, soweit alles klar. Profiltechnik-Jahr zu 535 Jahren“ (Antwort auf eine Vorlage, die Profil Technik und Vorgang 235 nannte).

A6 (Kette K1.2). Vorgangsdatei 1724 mit Chefwort 19.11., 07:24 (Archiv): „wir geben den von mir gestern getesteten Build frei … mit der Einschränkung, dass 760 nicht drin ist … lass es klar ziehen“. Build 300 liegt auf Zweig `claude/build-300`, darin die Commits zu 760.

A7 (Kette K2.2). Vorgangsdatei 1535 (Kleidung bei gehobenem Arm, Garrick und Kittel): Fund des Chefs aus Test 299: „299.3 ✗“; 15:33 „zieht sich da auch wieder irgendwas von der Jacke“; 15:59 „Das sieht man ja die Beule direkt“. Bisher: Commit `7ffa715`, Gewichte am Rumpf geändert, Bild alt gegen neu ohne sichtbaren Unterschied.

Für die folgenden Fälle schreibst du den Auftrag; eine Fachkraft bzw. ein Prüfer arbeitet danach nur mit Sockel und deinem Auftrag.

A8 (für W1). Vorgang 1650 Stiefel: Sohle des Helden schwebt etwa 2 cm über dem Boden in der Ruhepose (Fund des Prüfers, Bild `ansehen/1650-stiefel.webp`). Betroffen sind voraussichtlich das Modellskript `tools/bau/held_klassen.py` und die Szene `godot/scenes/held.tscn`.

A9 (für W2). Vorgang 1653 Thessa: Kragen sticht in der Ruhepose sichtbar durch den Umhang (Fund des Prüfers). Bild an den Chef nur alt gegen neu.

A10 (für W3). Vorgang 1613 Glanz: Waffen glänzen im Dorf nachts wie Metall bei Tag (Chef 17.11.: „Das glänzt wie Plastik“). Ein Filmlauf ist freigegeben (Sokrates).

A11 (für W4). Vorgang 1655 Morwen: Kopf sticht durch die Kapuze (Chef 18.11.). Die Kapuze muss im Modellbau (Blender-Skript, Kaufdateien) neu gebaut werden. Ein Bildlauf ist frei für „alt gegen neu“.

A12 (für W5). Vorgang 1569 Umhang Wachsoldat: Umhang aus dem gekauften Modell (Kaufrepo `tramour-cmyk/bornim-kaufmodelle`) statt des einfachen Tuchs.

A13 (für P2). Vorgang 1621 Waffenlänge: Chef 17.11.: „Die Waffen sind viel zu lang.“ Bild alt gegen neu verlangt.

A14 (für P4). Vorgang 431 Umhang im Film: Umhang flattert beim Gehen nicht, steht starr (Chef). Ein Filmlauf frei.

A15 (für P5). Vorgang 1619 Gang des Helden über die Wiese: Füße gleiten (Chef). Ein Filmlauf frei.

A16 (für P7). Vorgang 760 Wolfsbiss: Biss trifft den Helden nicht sichtbar (Chef 18.11.); drei Wolfsangriffe im Film zeigen.
