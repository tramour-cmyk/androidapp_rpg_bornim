# 431h · Der Held trägt genau das, was in den Ausrüstungsplätzen steht: Start so belegen und für etwa 70 bis 110 $ bauen?
Tom · 16.11., 07:12 · E Figuren · neu nach deinem Wort 07:05 („wenn er alles auszieht, hat er auch nichts an … Mann eine Unterhose und die Frau halt ein BH mit Unterhose“); ersetzt die Fassung von 00:12
Kurz: Jede Herkunft startet mit Gegenständen auf allen sichtbaren Plätzen, die so aussehen wie heute ihre Tracht; ein leerer Platz zeigt die Unterwäsche des Körpers, keine Tracht mehr.
Beim Chef, weil: Aussehen

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9f11d8100 (`godot/daten/werte.json` `welt.start`, `godot/daten/gegenstaende.json` Feld `netz`, `godot/daten/held-klassen.json` `herkuenfte`, `godot/skripte/heldfigur.gd` `tracht`, `godot/skripte/beute.gd` 384–396, `tools/blender348/v3/held_klassen.py` `TRACHTEN`, 571); Bestand mit Kaufrepo neu gesichtet 16.11., 07:08: „Modular Character Outfits – Fantasy“ und „Universal Base Characters“
Beim Chef, weil: Aussehen (wie der Held je Herkunft am Anfang und ausgezogen aussieht)

**Frage:** Heute trägt der Held eine ganze Tracht je Herkunft, egal was in den Plätzen steht: Kopf, Arme und Beine sind beim Start leer, trotzdem hat er Ärmel, Hose und Stiefel an; zieht er alles aus, bleibt die Tracht. Du willst: was in den Plätzen steht, trägt er; nichts im Platz, nichts an, nur Unterwäsche. Soll ich die Startausrüstung jeder Herkunft auf alle sichtbaren Plätze erweitern (Liste unten, so dass der Held am Anfang fast aussieht wie heute), die Tracht in Teile je Platz zerlegen und leere Plätze die Unterwäsche zeigen lassen?

**Votum:** „431h A“: Startausrüstung wie unten, alle vier Plätze und Umhang, ein Film (Drehteller je Herkunft: Start, alles ausgezogen, schwere Rüstung).

**Berührt:** 431 (Kleiderschrank, Tom; Stufe 2 „Spiel setzt zusammen“, der Umhang selbst ruht weiter), 455.2 (Netzliste je Platz, ruht; für Kapitel 1 damit erledigt), 1341/1309 (Ausrüstungsseite und Drehteller zeigen dann, was angelegt ist), 476 (Symbole aus den Modellen), 1297 (Schildgröße je Volk, eigener Vorgang), Erschaffung (Drehteller je Herkunft); Leute des Dorfs nicht (eigene Trachten).

**Begründung:** Du, 07:05: „das muss schon da so sein in den Ausrüstungsslots, wie es angezeigt wird“; 15.11., 17:13: „dass ich ausgerüstet habe … aber man sieht ja nichts am Helden“. Die alte Fassung (leerer Platz = Tracht) widerspricht dem, darum neu.

**Sachverhalt:**
- Start heute (`werte.json` `welt.start`): nur Waffe, Oberkörper, beim Wachsoldaten Schild. Wachsoldat Kettenhemd; Zauberlehrling Robe; alle anderen Lederrüstung.
- Tracht heute (`held-klassen.json`): Wachsoldat „Wache“ (unser Kettenhemd mit Wappenrock und Umhang, „passt“ 27.10.), Zauberlehrling „Robe“, Klosterschüler „Kloster“ (Ritter-Stoffkleid), Jägerkind und Herumtreiber „Wald“ (Waldläufer, Jägerkind mit Kapuze), Kräutersammler, Schmiedelehrling, Wanderer „Bauer“.
- Jeder Rüstungsgegenstand hat schon sein Teil aus dem Kleiderpaket (`gegenstaende.json` `netz`), z. B. Lederrüstung → Waldläufer-Wams, Armwickel → Bauern-Ärmel, Beinkleider → Bauernhose mit Schuh, Lederstiefel → Waldläuferhose mit Stiefel, Kapuze → Waldläufer-Kapuze.
- Kopf, Arme, Beine geben heute keinen Schutzwert (nur Brustrüstung mit Gewicht und Schild, `beute.gd` 395): mehr Startstücke ändern die Balance nicht, nur den Wert beim Händler (je 2 bis 5 Gold).
- Unterwäsche: im Bestand, kein Kauf. Der Kaufkörper „Universal Base Characters“, auf dem alle zehn Volkskörper stehen, hat sie in die Haut gemalt: Mann Unterhose, Frau BH und Unterhose, hellgrau-türkis. Heute schneidet der Bau die Haut unter Hose und Stiefel weg (`held_klassen.py` 571); künftig bleibt sie und wird nur unter einem angelegten Teil verdeckt. Den Farbton würde ich zu ungefärbtem Leinen abdunkeln, sonst sticht er aus dem düsteren Bild.
- Kleiderpaket neu gesichtet: fünf Sätze Ritter, Adel, Bauer, Waldläufer, Zauberer, je Mann und Frau; Teile je Körper, Arme, Beine, Füße; Köpfe Ritterhelm, Hörnerhelm, Krone, Kapuze; dazu Schulterstücke, Halsberge, Schal, Gürtel, Armschienen (Waldläufer, Adel). Das Paket sagt selbst: es passt auf den Basiskörper, von dem unter Kleidung nur der Kopf nötig ist, sonst stößt Haut durch.

**Startausrüstung (Vorschlag; Waffe und Schild unverändert):**
- Wachsoldat: Kopf leer · Kettenhemd · Armwickel · Lederstiefel · Umhang (das Netz seiner Tracht, „passt“ 27.10.; ausgezogen ist er weg).
- Zauberlehrling: Kopf leer · Robe (mit Ärmeln) · Arme leer · Beinkleider (Schuh unter der Robe).
- Jägerkind: Kapuze · Lederrüstung · Lederhandschuhe · Lederstiefel (genau die heutige Waldtracht).
- Herumtreiber: wie Jägerkind, ohne Kapuze.
- Klosterschüler, Kräutersammler, Schmiedelehrling, Wanderer: Kopf leer · Lederrüstung · Armwickel · Beinkleider.
- Abweichung vom heutigen Bild: Die Lederrüstung ist im Spiel das Waldläufer-Wams. Klosterschüler (heute Ritter-Stoffkleid) und die drei Bauern (heute Bauernhemd) sähen am Oberkörper anders aus als jetzt. Ein eigenes Stück „Kutte“ oder „Leinenhemd“ wäre Stoff ohne Schutzwert, sie verlören Schutz: Balance, darum nicht ohne dein Wort.

**Auswertung:**
- **A (Empfehlung): alle Plätze, Start wie oben, ein Film** (3 bis 4 Sitzungen, etwa 70 bis 110 $; 431 bisher etwa 93 $): `held_klassen.py` baut je Volkskörper und Geschlecht die Teile einzeln an dasselbe Skelett (etwa 18 je Körper) und den Körper mit Unterwäsche statt weggeschnittener Haut; das Spiel zeigt je Platz das Teil des angelegten Stücks, sonst nichts; `welt.start` bekommt die neuen Stücke. Prüfung am Rechner je Körper: kein Durchstoßen im Stehen, Gehen, Hieb (Standbilder selbst angesehen), Bilder je Sekunde im Dorf nicht unter heute. Film: Drehteller je Herkunft Start, ausgezogen, schwere Rüstung, dazu alt gegen neu.
- **B: zuerst Unterwäsche und Start, Teile nur für Kopf und Oberkörper** (2 Sitzungen, etwa 40 bis 60 $): Arme und Beine bleiben bis zum zweiten Schritt die Tracht; widerspricht deinem Wort für Arme und Beine, darum nur als kleinerer erster Schritt.
- **Stärkstes Gegenargument gegen A:** Sichtbare Ausrüstung steht nicht in der Abnahmeliste für Kapitel 1, Aussehen ist bis zum Durchspielen eingefroren (488), und der Umhang hat auf denselben zehn Körpern etwa 220 $ gekostet und ruht wegen Nähten. Gemischte Sätze tragen dasselbe Risiko an Hals, Handgelenk, Knie. Darum Deckel 110 $; besteht die Messung am Rechner nicht, kein Film, und es ruht wie der Umhang. **C:** bis nach dem Meilenstein ruhen lassen, 0 $.

**Folgerungen:** Bei A oder B: Tom baut auf `claude/tom-431-ausruestung`, Film an dich, dann Testbuild; die Startausrüstung wird ein eigener Punkt der Prüfliste (neues Spiel je Herkunft). Zur Oberkörper-Abweichung bei Kloster und Bauern: ohne Wort von dir bleibt es die Lederrüstung (Wams); „Kutte“ oder „Leinenhemd“ nur auf dein Wort, Name und Text dann über Homer. Bei C: 431 ruht, Tom nimmt Fehler aus den Tests.

Antwort: …
