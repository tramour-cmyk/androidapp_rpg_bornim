# 431h · Der Held trägt genau das, was in den Ausrüstungsplätzen steht: erst Stufe 1 (Start und Unterwäsche, etwa 50 bis 70 $), Stufe 2 (Rüstungen, etwa 30 bis 50 $) danach?
Tom · 16.11., 07:20 · E Figuren · neu nach deinem Wort 07:05 („wenn er alles auszieht, hat er auch nichts an … Mann eine Unterhose und die Frau halt ein BH mit Unterhose“) und 07:15 („Erst Toms Aufwand sehen, dann entscheiden.“); ersetzt die Fassungen von 00:12 und 07:12
Kurz: Stufe 1 legt jeder Herkunft ihre Tracht als Kleidungsstücke in die Plätze und zeigt leere Plätze in Unterwäsche; Stufe 2 macht jede Rüstung sichtbar; beide getrennt mit Aufwand.
Beim Chef, weil: Aussehen

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/9f11d8100 (`godot/daten/werte.json` `welt.start`, `godot/daten/gegenstaende.json` Feld `netz`, `godot/daten/held.json` `grundformen`, `godot/daten/held-klassen.json` `herkuenfte`, `godot/skripte/heldfigur.gd` `tracht`, `godot/skripte/beute.gd` 384–396, `tools/blender348/v3/held_klassen.py` `TRACHTEN`, 570–580); Bestand mit Kaufrepo neu gesichtet 16.11., 07:08: „Modular Character Outfits – Fantasy“ (Source, glTF) und „Universal Base Characters“ (Source)
Beim Chef, weil: Aussehen (wie der Held je Herkunft am Anfang, ausgezogen und in Rüstung aussieht)

**Frage:** Heute trägt der Held eine ganze Tracht je Herkunft, egal was in den Plätzen steht: Kopf, Arme und Beine sind beim Start leer, trotzdem hat er Ärmel, Hose und Stiefel an; zieht er alles aus, bleibt die Tracht; angelegte Rüstung sieht man nicht. Vorschlag in zwei Stufen. Stufe 1: die Tracht jeder Herkunft liegt zum Start als Kleidungsstücke in den Plätzen (der Held sieht am Anfang aus wie heute), ein leerer Platz zeigt die Unterwäsche. Stufe 2: jede Rüstung zeigt ihr eigenes Teil. Willst du Stufe 1 jetzt und Stufe 2 nach deinem „passt“ zu Stufe 1?

**Votum:** „431h A“: Stufe 1 bauen (etwa 50 bis 70 $, Deckel 70 $), Film an dich; Stufe 2 erst nach deinem „passt“.

**Berührt:** 431 (Kleiderschrank, Tom; Umhang ruht weiter), 455.2 (Netzliste je Platz, ruht; mit Stufe 2 für Kapitel 1 erledigt), 1341/1309 (Ausrüstungsseite und Drehteller zeigen dann, was angelegt ist), 476 (Symbole aus den Modellen), 1297 (Schildgröße je Volk, eigener Vorgang), Erschaffung; Leute des Dorfs nicht (eigene Trachten).

**Begründung:** Du, 07:05: „das muss schon da so sein in den Ausrüstungsslots, wie es angezeigt wird“; 15.11., 17:13: „dass ich ausgerüstet habe … aber man sieht ja nichts am Helden“. Zwei Stufen nach Sokrates (07:13): Stufe 1 erfüllt dein Wort 07:05 ganz und ändert am Startbild fast nichts; Stufe 2 trägt das Nahtrisiko gemischter Sätze und kann warten.

**Sachverhalt:**
- Start heute (`werte.json` `welt.start`): nur Waffe, Oberkörper, beim Wachsoldaten Schild. Wachsoldat Kettenhemd, Zauberlehrling Robe, alle anderen Lederrüstung.
- Tracht heute (`held-klassen.json`): Wachsoldat „Wache“ (unser Kettenhemd mit Wappenrock und Umhang, „passt“ 27.10.), Zauberlehrling „Robe“, Klosterschüler „Kloster“ (Ritter-Stoffkleid), Jägerkind und Herumtreiber „Wald“ (Waldläufer, Jägerkind mit Kapuze), Kräutersammler, Schmiedelehrling, Wanderer „Bauer“.
- Kleidungsstücke ohne Schutzwert gibt es schon: Kapuze, Armwickel (Bauern-Ärmel), Lederhandschuhe (Waldläufer-Arme), Beinkleider (Bauernhose mit Schuh), Lederstiefel (Waldläuferhose mit Stiefel). Kopf, Arme, Beine geben überhaupt keinen Schutzwert (nur Brustrüstung mit Gewicht und Schild, `beute.gd` 395). Stufe 1 braucht darum für Kopf, Arme, Beine keine neuen Gegenstände und ändert die Balance nicht, nur den Wert beim Händler (je 2 bis 5 Gold).
- Unterwäsche: im Bestand, kein Kauf. Der Kaufkörper „Universal Base Characters“, auf dem alle zehn Volkskörper stehen, hat sie in die Haut gemalt: Mann Unterhose, Frau Büstenhalter und Unterhose (in der Textur geprüft), hellgrau-türkis. Heute schneidet der Bau diese Haut unter Hose und Stiefel weg (`held_klassen.py` 570–580).
- Kleiderpaket neu gesichtet: fünf Sätze Ritter, Adel, Bauer, Waldläufer, Zauberer, je Mann und Frau, auf demselben Skelett wie unsere Trachten; Teile je Körper, Arme, Beine, Füße; Köpfe Ritterhelm, Hörnerhelm, Krone, Kapuze; dazu Schulterstücke rund und spitz, Halsberge, Schal, Gürtel, Armschienen (Waldläufer, Adel). Das Paket sagt selbst: unter Kleidung nur den Kopf des Körpers zeigen, sonst stößt Haut durch.
- Fehlt im Bestand: Lederkappe, offener Helm (beide heute Netz „Kappe“), Armschienen als eigenes Ritterteil.

**Stufe 1, Startausrüstung (Waffe und Schild unverändert):**
- Wachsoldat: Kopf leer · Kettenhemd · Armwickel · Lederstiefel · Umhang (das Netz seiner Tracht; ausgezogen ist er weg).
- Zauberlehrling: Kopf leer · Robe (mit Ärmeln) · Arme leer · Beinkleider (Schuh unter der Robe).
- Jägerkind: Kapuze · Lederrüstung · Lederhandschuhe · Lederstiefel (genau die heutige Waldtracht).
- Herumtreiber: wie Jägerkind, ohne Kapuze.
- Klosterschüler, Kräutersammler, Schmiedelehrling, Wanderer: Kopf leer · Lederrüstung · Armwickel · Beinkleider.

**Stufe 2, Rüstungen (Zuordnung steht schon im Feld `netz`):** Stirnreif → Krone (Adel) · Topfhelm → Ritterhelm · Brustplatte, Schienenpanzer → Ritter-Körper Rüstung · Halbplatte → dazu Schulterstücke · Plattenpanzer → dazu Schulterstücke und Halsberge · Kettenhemd, Schuppen-, Kettenpanzer → unser Kettenhemd · Panzerhandschuhe → Ritter-Arme · Armschienen → Waldläufer-Armschiene · Kettenbeinlinge → Waldläuferhose mit Stiefel · Beinschienen → Ritter-Beine und -Füße · Lederkappe, Helm → fehlt (Kapuze oder Eigenbau, offene Frage 4).

**Auswertung:**
- **A (Empfehlung): Stufe 1 jetzt** (2 bis 3 Sitzungen, etwa 50 bis 70 $): `held_klassen.py` baut die fünf Trachten je Volkskörper und Geschlecht als Teile je Platz (Kopf, Oberkörper, Arme, Beine mit Füßen; etwa 12 Teile je Körper, alle aus heutigen Trachten, nichts Neues am Aussehen) und den Körper mit Unterwäsche statt weggeschnittener Haut; das Spiel zeigt je Platz das Teil des angelegten Stücks, sonst nichts; `welt.start` bekommt die Stücke oben. Prüfung am Rechner je Körper: Nähte an Hals, Handgelenk, Knie, kein Durchstoßen im Stehen, Gehen, Hieb (Standbilder selbst angesehen), Bilder je Sekunde im Dorf nicht unter heute. Film: Drehteller je Tracht Start und ausgezogen, alt gegen neu.
- **Stufe 2 danach** (1 bis 2 Sitzungen, etwa 30 bis 50 $; Lederkappe und Helm als Eigenbau dazu etwa 20 $): die etwa 10 Teile aus Ritter- und Adelssatz je Volkskörper wie in Stufe 1, Prüfung und Film ebenso (leichte, mittlere, schwere Rüstung je Volk).
- **B: beide Stufen in einem Zug** (3 bis 5 Sitzungen, etwa 80 bis 120 $): ein Film statt zwei; dafür sieht der Chef das Nahtrisiko der gemischten Sätze erst am Ende.
- **Stärkstes Gegenargument:** Sichtbare Ausrüstung steht nicht in der Abnahmeliste für Kapitel 1, Aussehen ist bis zum Durchspielen eingefroren (488), und der Umhang hat auf denselben zehn Körpern etwa 220 $ gekostet und ruht wegen Nähten. Darum Stufe 1 zuerst (nur heutige Trachten, keine Mischung fremder Sätze), Deckel je Stufe; besteht die Messung am Rechner nicht, kein Film, es ruht wie der Umhang. **C:** bis nach dem Meilenstein ruhen lassen, 0 $.

**Offene Fragen (beantwortest du mit, sonst gilt der Vorschlag):**
1. Oberkörper Klosterschüler und Bauern: ihre Lederrüstung sieht im Spiel aus wie das Waldläufer-Wams, nicht wie heute Stoffkleid oder Bauernhemd. Vorschlag: so lassen. Ein eigenes Stück „Kutte“ oder „Leinenhemd“ wäre Stoff ohne Schutzwert, sie verlören Schutz (Balance), Name und Text über Homer.
2. Unterwäsche hellgrau-türkis: Vorschlag zu ungefärbtem Leinen abdunkeln, sonst sticht sie aus dem düsteren Bild.
3. Umhang des Wachsoldaten: Vorschlag als Startstück mit dem Netz seiner Tracht, obwohl der Umhang sonst ruht; ohne ihn sähe der Wachsoldat anders aus als heute.
4. Lederkappe und Helm (Stufe 2): Vorschlag bis zum Eigenbau als Kapuze zeigen; sonst bleibt der Kopf leer.

**Folgerungen:** Bei A: Tom baut Stufe 1 auf `claude/tom-431-ausruestung`, Film an dich, dann Testbuild; Startausrüstung als Punkt der Prüfliste (neues Spiel je Herkunft); Stufe 2 als neue Vorlage nach deinem „passt“. Bei B: beides auf demselben Zweig, ein Film. Bei C: 431 ruht, Tom nimmt Fehler aus den Tests.

**Stellungnahme Sokrates (16.11., 08:14):**
- **Stärkstes Gegenargument zu A:** Stufe 1 behebt deinen Fund vom 15.11., 17:13 („ausgerüstet … aber man sieht ja nichts am Helden“) noch nicht. Sie macht nur die Plätze ehrlich; eine gefundene Rüstung siehst du erst mit Stufe 2. Wer nur Stufe 1 abnimmt, hat 50 bis 70 $ für ein Startbild ausgegeben, das fast gleich aussieht. Ich halte A trotzdem für richtig: Stufe 1 ist der Unterbau (Teile je Platz, Körper mit Unterwäsche), ohne den Stufe 2 nicht geht, und sie trägt das kleinere Nahtrisiko.
- **Widerspruch in der Vorlage:** „der Held sieht am Anfang aus wie heute“ stimmt nach Frage 1 nicht für vier Herkünfte (Klosterschüler, Kräutersammler, Schmiedelehrling, Wanderer): ihr Oberkörper wird zum Waldläufer-Wams. Besser als Toms Vorschlag: je ein eigenes Stück („Kutte“, „Leinenwams“; Namen Homer) mit **denselben Werten wie die Lederrüstung**, nur mit dem Netz der heutigen Tracht. Dann bleibt das Bild wie heute und die Balance unberührt.
- **Zu Entschiedenem:** 488 (Aussehen eingefroren bis zum Durchspielen) steht dagegen; du hast 431 mit der sichtbaren Ausrüstung am 15.11., 17:13 aber ausdrücklich weiterlaufen lassen. Mit der Abnahmeliste kein Widerspruch (A6 meint die Tiefe des Schilds, nicht die Sichtbarkeit).
- **Kosten:** A und B kosten zusammen gleich viel (80 bis 120 $); der Unterschied ist nur, wann du das Nahtrisiko siehst. Maßstab Umhang: etwa 220 $ auf denselben Körpern, ruht. Der Deckel von 70 $ je Stufe und „Messung nicht bestanden, kein Film, ruht“ sind darum nötig.
- **Empfehlung:** 431h A, Frage 1 mit eigenen Stücken in Lederwerten statt Waldläufer-Wams; Fragen 2 bis 4 wie Tom.

Antwort: …
