# 431h · Angelegte Rüstung am Helden zeigen: so zuordnen und für etwa 60 bis 100 $ bauen?
Tom · 16.11., 00:12 · E Figuren · aus deinem Wort 15.11., 17:13 („dass ich ausgerüstet habe … aber man sieht ja nichts am Helden“)
Kurz: Jeder angelegte Kopf-, Brust-, Arm- und Beinschutz tauscht das passende Stück der Tracht gegen ein Teil aus dem gekauften Kleiderpaket; leere Plätze zeigen weiter die Tracht der Herkunft.
Beim Chef, weil: Aussehen

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/85126be51 (`godot/skripte/heldfigur.gd` `baue`, `tracht`, `kapuze`, `bewaffne`; `godot/daten/gegenstaende.json`; `tools/blender348/v3/held_klassen.py`); Bestand: Kaufpaket „Modular Character Outfits – Fantasy“, gesichtet 16.11., 00:08
Beim Chef, weil: Aussehen (der Held sieht je Ausrüstung anders aus; welches Stück wie aussieht, entscheidest du)

**Frage:** Heute trägt der Held eine feste Tracht je Herkunft (Wache, Robe, Kloster, Wald, Bauer). Von der Ausrüstung zeigt das Modell nur Waffe und Schild auf dem Rücken; Kapuze, Lederrüstung, Kroggs Pranken, Beinschienen sieht man nicht. Soll ich je angelegtem Stück das passende Teil der Tracht austauschen, nach der Zuordnung unten, und dir das Ergebnis als Film zeigen?

**Votum:** „431h A“: ich baue die Zuordnung wie unten für Kopf, Brust, Arme, Beine auf allen zehn Volkskörpern und sende dir einen Film; einzelne Zuordnungen änderst du danach am Film („Lederkappe anders“).

**Berührt:** 431 (Kleiderschrank, Tom; das ist Stufe 2 aus 431g, „Spiel setzt zusammen“, vorgezogen ohne das „passt“ zum Umhang, weil der Umhang ruht), 455.2 (Netzliste je sichtbarem Platz, ruht; diese Zuordnung ersetzt sie für Kapitel 1), 476 (Symbole aus den Modellen, später leichter), 1297 (Schildgröße je Volk, eigener Vorgang), Ausrüstungsseite und Drehteller (1309, 1341).

**Begründung:** Du: „man sieht ja nichts am Helden“ (15.11., 17:13); Sokrates 16.11., 00:07: Umhang ruht bis nach dem Meilenstein, der Kleiderschrank macht mit der sichtbaren Ausrüstung weiter. Das Kleiderpaket hat zu jedem Platz Teile, die auf denselben Körper und dasselbe Skelett passen wie unsere Trachten; das Übertragen auf die zehn Volkskörper kann `kleiderschrank.py` schon.

**Sachverhalt:**
- Spiel: `heldfigur.gd` lädt ein ganzes Modell `held_<Tracht>_<M|W>`; nur die Kapuze der Waldtracht ist heute schaltbar (`kapuze`). Plätze mit Rüstung: Kopf, Oberkörper, Arme, Beine (Stiefel gehören zu „Beine“), Umhang; dazu Hals und Finger.
- Gegenstände (`gegenstaende.json`): Kopf 5 Grundformen, Oberkörper 10, Arme 4 (dazu Kroggs Pranken), Beine 4, Umhang 2 (dazu Wehrmantel, Thessas Pelzumhang). Beute würfelt aus diesen Grundformen mit Vorsilbe („Vitale Kapuze“, „Göttliche Beinschienen“); der Name ändert das Aussehen nicht.
- Bestand geprüft: Kaufpaket „Modular Character Outfits – Fantasy“ genommen: fünf Sätze Ritter, Adel, Bauer, Waldläufer, Zauberer, je Mann und Frau; je Satz Körper, Arme, Beine, Füße; Ritter mit Körper Rüstung und Stoff, Beine Rüstung, Füße Rüstung; Waldläufer mit Stiefeln; Köpfe nur Ritterhelm (geschlossen), Hörnerhelm, Krone, Kapuze; dazu Schulterstücke, Halsberge, Schal. Unser Kettenhemd (Tracht Wache, „passt“ 27.10.) und unsere lange Robe (Tracht Robe) bleiben. Fehlt im Bestand: Lederkappe, offener Helm, Armschienen als eigenes Teil.
- Neu nachsehen konnte ich das Paket in dieser Sitzung nicht (Freischalten des Kaufrepos abgelehnt); die Liste ist die Sichtung von 00:08.

**Zuordnung (Vorschlag):**
- Kopf: Kapuze → Waldläufer-Kapuze (wie heute beim Jägerkind) · Stirnreif → Krone des Adelssatzes · Lederkappe → Waldläufer-Kapuze (fehlt im Bestand) · Helm, Topfhelm → Ritterhelm · Hörnerhelm nicht (früher abgewählt).
- Oberkörper: Robe → unsere lange Robe · Lederrüstung, Nietenleder → Waldläufer-Körper · Kettenhemd, Kettenpanzer, Schuppenpanzer → unser Kettenhemd · Brustplatte, Schienenpanzer → Ritter-Körper Rüstung · Halbplatte → dazu Schulterstücke · Plattenpanzer → dazu Schulterstücke und Halsberge.
- Arme: Armwickel → Bauern-Arme · Lederhandschuhe, Armschienen → Waldläufer-Arme · Panzerhandschuhe, Kroggs Pranken → Ritter-Arme.
- Beine: Beinkleider → Bauern-Beine und -Füße · Lederstiefel → Waldläufer-Beine und Stiefel (Schaft bis unters Knie gekürzt wie bei der Robe) · Kettenbeinlinge → Ritter-Beine Stoff, Füße Rüstung · Beinschienen → Ritter-Beine und -Füße Rüstung.
- Leerer Platz: das Stück der Tracht der Herkunft, wie heute (der Held steht nie nackt da).
- Umhang, Mantel: bleiben bis nach dem Meilenstein unsichtbar (Umhang ruht). Hals und Finger: nicht sichtbar, zu klein im Bild.

**Auswertung:**
- **A (Empfehlung): alle vier Plätze, ein Film** (3 bis 4 Sitzungen, etwa 60 bis 100 $; 431 bisher 93 $): `held_klassen.py` baut je Volkskörper und Geschlecht einen Satz Teile (etwa 16 je Körper) an dasselbe Skelett wie die Tracht; das Spiel blendet je angelegtem Stück das Tracht-Teil aus und das Teil ein, die Haut darunter weg; Prüfung am Rechner: kein Durchstoßen im Stehen, Gehen, Hieb je Körper (Standbilder selbst angesehen), Bilder je Sekunde im Dorf nicht unter heute. Film: Drehteller, Held je Volk mit leichter, mittlerer, schwerer Ausrüstung, dazu alt gegen neu.
- **B: erst Kopf und Oberkörper** (2 Sitzungen, etwa 40 bis 60 $): die beiden Plätze, die man am meisten sieht; Arme und Beine danach. Billiger, aber zwei Filme und zweimal Übertragen.
- **Stärkstes Gegenargument gegen A:** Sichtbare Ausrüstung steht nicht in der Abnahmeliste für Kapitel 1, und Aussehen ist bis zum Durchspielen eingefroren (488); jede Mischung aus zwei Sätzen kann an Hals, Handgelenk oder Knie eine Naht oder ein Loch zeigen, auf zehn Körpern. Darum: Mischungen am Rechner je Körper messen, nur ein Film, und kommt er zurück, ruht es wie der Umhang. **C:** bis nach dem Meilenstein ruhen lassen, 0 $.

**Folgerungen:** Bei A oder B: Tom baut auf `claude/tom-431-ausruestung`, Film an dich, dann Testbuild; 455.2 wird für Kapitel 1 erledigt. Bei C: 431 ruht bis nach dem Meilenstein, Tom nimmt Fehler aus den Tests.

Antwort: …
