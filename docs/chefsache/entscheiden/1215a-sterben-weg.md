# 1215a · Physikalisches Sterben nachbessern oder gezeichnet sterben lassen?
Jerry · 15.11., 11:20 · E Kampf · aus deinem Wort 10:56 zum Film 1215 von 01:15 Uhr
Kurz: Vermutliche Ursache des Klumpens gefunden (Beine hängen nicht am Becken), am Nachbau belegt; Ragdoll mit einem Film nachbessern, sonst gezeichnet.
Beim Chef, weil: Aussehen

Geprüft an: `b78c7ee07` (Zweig `claude/jerry-1215-ragdoll`, `probe_huefte_1215`, am Rechner, Godot 4.7.2 mit Jolt)

**Frage:** Im Film 1215 stürzten die Goblins mit Physik nach vorn und nach hinten. Dein Urteil (10:56): „völliger Fleischklumpen … sieht auch katastrophal aus … das ist leider nichts“. Du hast zwei Wege genannt: das Ragdoll-Prinzip zum Laufen bringen oder anders machen. Die vermutliche Ursache ist jetzt gefunden. Soll ich die Ragdoll nachbessern und dir genau einen neuen Film zeigen, oder gleich auf gezeichnetes Sterben je Richtung gehen?

**Votum:** „1215a A“: Ragdoll nachbessern, ein Film; scheitert er, ohne weitere Frage Weg B.

**Berührt:** 1215 (Jerry), 1141 (gebackene Tode bleiben bis dahin), 1141.1 (misst erst nach 1215).

**Begründung:** Du hast gesagt (10:56): „Entweder … nochmal zu überarbeiten, dass das Ragdoll-Prinzip doch funktioniert, ansonsten müssen wir das anders machen.“ Der Fehler ist ein einzelner Baufehler in unserem Gerüst, kein Grenzfall der Physik; das spricht für einen letzten Versuch.

**Sachverhalt:**
- Im Goblin-Gerüst (`tools/blender348/v3/rig.py` Zeile 115, das Gerüst aller Goblins) hängen Becken und Hüftknochen nebeneinander an der Wurzel. Die Hüftknochen bekommen keinen Physikkörper. Godot verbindet einen Physikkörper nur mit dem nächsten Physikkörper darüber; der Oberschenkel findet keinen, also hängen die Beine an nichts.
- Nachgestellt am Rechner an einem nachgebauten Gerüst, die Beine wie in `rig.py` an die Wurzel gehängt: Abstand Hüfte zu Becken vorher 0,085 m, im Fall bis 0,507 m. Die Beine fallen für sich, der Rumpf für sich, die Haut dazwischen zieht sich zu Zacken und Klumpen (im Film die hellen Zacken über dem Körper). Im selben Nachbau mit den Beinen am Becken bleibt der Abstand 0,085 m. Am echten Goblin ist das noch nicht gemessen, die Nachbesserung noch nicht gebaut.
- Der Test vom 13.11. (`ragdoll_1215`) hat den Fehler nicht gesehen: sein Nachbau hängt die Beine ans Becken, anders als unser Gerüst.
- Die Gelenke selbst (Grenzen der Knie, Ellbogen, Schultern) springen beim Übergang nicht (0–2 Grad ohne Schwerkraft).
- Zweiter Fehler im Film: die Waffe bleibt in der Luft stehen; das Mitfallen der Waffe ist noch nicht gebaut.

**Auswertung:**
- **A (Empfehlung): Ragdoll nachbessern.** Beim Übergang zur Physik die Hüftknochen ans Becken hängen (nur am toten Goblin, keine Änderung an Gerüst und Bewegungen), die Waffe fällt aus der Hand, Test am echten Goblin-Gerüst statt am Nachbau. Etwa 4–6 $ und ein Film.
- **B: gezeichnetes Sterben je Richtung.** Schlüsselbilder wie die Tode aus 1141 (am 13.11. „hundertmal besser als vorher“), dazu je Gerüst ein Fall nach links, rechts, vorn, hinten mit knickenden Beinen. Etwa 10–15 $ und zwei bis drei Filme; die Beine knicken so, wie wir es zeichnen, nicht nach dem Treffer.
- **C: Mischform.** Gezeichnet bis zum Boden, Physik nur für Arme und Kopf beim Aufschlagen. Etwa 6–8 $, ein bis zwei Filme; Nachteil: das Becken landet bei jedem Tod gleich, nur Arme und Kopf ändern sich.
- **Stärkstes Gegenargument gegen A:** Der Film war schlecht, und unter dem einen Fehler können weitere liegen (Knie, Kleidung); dann ist wieder ein Film weg, und 1215 steht schon bei 37 $. Antwort: A ist auf einen Film begrenzt, danach gilt B ohne neue Frage.

**Folgerungen:** Bei A baut Jerry die Nachbesserung, dann Film an dich. Bei B oder C baut Jerry den gewählten Weg; die Ragdoll-Teile bleiben auf dem Zweig liegen.

Antwort: …
