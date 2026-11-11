# 644a · Soll jedes Stück erst ab seiner Stufe tragbar sein, und wie weit darf ein Fund über dem Helden liegen?
Sokrates · 11.11., 20:34 · E Kampf · aus deinem Wort 19:56 zu 870.7
Kurz: Mindeststufe zum Tragen bauen, wie im Regelwerk vorgesehen; ab Stufe 4 doppelte Zusatzeigenschaften statt mehr Grundschaden; Funde höchstens eine Stufe über dem Helden

Geprüft an: [65ea0e915](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/65ea0e915) (Zweig `claude/build-277`) und [eb38b1de0](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/eb38b1de0) (`main`): `godot/regeln/brs_held.gd`, `godot/skripte/beute.gd`, `godot/skripte/spiel.gd`, `tools/gegenstaende/gegenstaende.json`, `tools/sim444/werte.json` („gegenstaende“); ein Helfer hat gegen den Code und alle sechs Kampfstile gegengeprüft, seine Funde sind eingearbeitet

**Frage:** Du hast gefragt (19:56): „gibt es denn nicht auch Mindestvoraussetzungen, dass ich gewisse Dinge benutzen darf? … Haupt- oder Nebenhandstufe 6. Heißt es, dass ich mindestens die Stufe 6 brauche … dass es an der Heldenstufe hängt.“ Vorgesehen ist das: Das Regelwerk nennt die Gegenstandsstufe „Stärke und Mindeststufe zum Tragen, wie die Heldenstufe“. Gebaut ist die Sperre nicht. Zu entscheiden sind drei Fragen: Kommt die Sperre? Was macht eine höhere Stufe stärker? Wie weit darf ein Fund über dem Helden liegen?

**Votum:** „644a A“:
- Ein Stück der Stufe 6 kann erst ein Held der Stufe 6 tragen.
- Ab Stufe 4 zählen die Zusatzeigenschaften eines Stücks doppelt, also etwa Leben +10 statt +5. Beim Schutzwert ist das schon so gebaut.
- Schaden und Schutz der Grundform hebt weiter nur die Güte.
- Ein Fund liegt höchstens eine Stufe über dem Helden.
- Händler verkaufen nur, was du schon tragen kannst.

**Berührt:** 644 (Gegenstandskatalog, Sokrates), 644.2 (Zahlen in der Simulation, Jerry), 633 (Boss-Beute fehlt, Jerry), 870.6 und 870.7 (Beute, Laden und Gegenstandsfenster, in Build 277), 976 (Güte), Einzelstücke im Katalog (Homer liest ihre Stufen gegen die Geschichte)

**Begründung:** Die Heldenstufe bestimmt im Kampf schon die Größenordnung, mit 10 % je Stufe Unterschied (dein Kampfmodell vom 31.10.: „Stufe für die Größe, Fertigkeit für das Können“). Würde die Gegenstandsstufe zusätzlich den Schaden heben, zählte die Stufe doppelt. Dann müssten alle Gegner von Kapitel 1 neu gerechnet werden, und jedes Stück würde mit jedem Aufstieg schlechter, auch ein meisterhaft geschmiedetes oder ein Einzelstück mit Geschichte. Mit A bleibt die Spannung, nach der du gefragt hast: Ein starker Fund liegt eine Weile in der Tasche, bis du so weit bist. Ab Stufe 4 merkst du den Sprung an den Zahlen.

**Sachverhalt:**
- **Regelwerk** (`DESIGN-BRS.md`, „Alle Stufen auf einen Blick“ und Abschnitt 11): Was die „Stärke“ der Gegenstandsstufe genau heißt, ist offen. Schaden und Schutzwert der Grundform hebt die Güte, in Build 277 um 15 % (Gut) und 30 % (Meisterhaft).
- **Sperre:** Der Code prüft nichts, die Abfrage „kann tragen“ sagt immer ja (`brs_held.gd` Zeile 352). Die Anzeige dafür gibt es schon: „Nicht tragbar“ im Laden, gesperrtes Anlegen und „Stufe 6“ im Gegenstandsfenster. Es fehlt nur die Regel.
- **Was die Stufe in Build 277 bewirkt:**
  - Sie bestimmt, welche Grundformen vorkommen, etwa Halbplatte ab 6 und Plattenpanzer ab 7.
  - Sie hebt den Preis um 20 % je Stufe.
  - Sie hebt zwei Zusatzeigenschaften: Schutzwert +2 statt +1 ab Stufe 4, Fertigkeit +2 ab Stufe 6 (nur episch).
  - Alle anderen Zusatzeigenschaften sind fest, gleich welche Stufe (`werte.json` „zusatz“, `beute.gd` „zusatz_wert“).
- **Deckel:** Alle getragenen Stücke zusammen geben in Kapitel 1 höchstens +1 auf jeden Grundwert und +2 Schutzwert (`werte.json` „deckel“). Grundwerte kann die Stufe darum in Kapitel 1 nicht weiter heben.
- **Stufe der Funde:**
  - Händler verkaufen in deiner Stufe.
  - Beute hat die Stufe des Gebiets: Tiefer Wald 2, Blutzahnhöhle 3.
  - Gaben und Einzelstücke bekommen die Stufe des Gebiets oder deine, je nachdem, was höher ist (`beute.gd`, `spiel.gd` 598, 987).
  - Ein Held der Stufe 1 in der Höhle bekommt also Stücke der Stufe 3.
- **Einzelstücke:** Im Katalog haben sie feste Stufen:
  - Waffe aus der Truhe der Blutzahnhöhle 4 (eine von vier, nach deiner Fertigkeit)
  - Handschuhe der Ogerkraft 4, Umhang des Schutzes 4
  - Grimmzahns Fang 5
  - Graks Kriegsaxt 6, Ring des Ältesten 6 (Aldric am Kapitelende)

  Der Code beachtet diese Stufen nicht. Die Boss-Stücke vergibt Godot gar nicht, das ist Vorgang 633 bei Jerry.
- **Gegner in Kapitel 1** (`werte.json`): Stufe 1 bis 6, darunter Krogg 4, Grimmzahn 5, Grak 6. Die Kapitelgrenze liegt bei 6, weich bis 8.

**Auswertung:**
- **A (Empfehlung): Sperre, doppelte Zusatzeigenschaften ab Stufe 4.**
  - **Sperre:** Anlegen erst ab der Stufe des Stücks. Was du schon trägst, bleibt angelegt, auch aus alten Spielständen oder nach dem Testmenü.
  - **Stärke:** Ab Stufe 4 zählen Leben, Mana, Kritisch, Zauberschaden und Abwehrprobe doppelt, also Leben +10, Mana +10, kritisch +6 %, Zauberschaden +20 %, Abwehrprobe +10 %. Das ist dieselbe Regel, die beim Schutzwert schon gilt. Grundwerte bleiben bei +1, weil der Deckel greift. Spätere Kapitel bekommen weitere Schritte (Startwert: dreifach ab 7). Das wirkt für alle sechs Kampfstile gleich, auch für Magier und Heiler. Ein Fokus braucht keine eigene Regel.
  - **Gewöhnliche Stücke** ohne Zusatzeigenschaft bekommen die Stufe ihrer Grundform aus dem Katalog. Ein schlichtes Langschwert ist also immer Stufe 1, ein Plattenpanzer Stufe 7. Die Sperre heißt dort: schweres Gerät erst für Erfahrene.
  - **Funde:** Beute bekommt die Stufe des stärksten Gegners im Kampf, höchstens deine Stufe plus 1. Gaben werden genauso gedeckelt. Händler bleiben bei deiner Stufe. Einzelstücke behalten ihre Stufe aus dem Katalog. Homer und Jerry prüfen, dass keines höher liegt als die Stufe, mit der der Held es laut Geschichte bekommt.
  - **Kosten:** klein. Tom baut Sperre, Gaben und Einzelstücke, Jerry die Beutestufe mit 633 und die Stufenschritte. Die Gegner müssen nicht neu gerechnet werden. Jerry misst in 644.2 nur den Abstand und die Schritte.
- **B: Sperre, und die Stufe hebt auch Schaden und Schutz**, etwa um 10 % je Stufe auf Waffe, Rüstung und Schild.
  - Dafür: Ein Fund der Stufe 6 ist deutlich stärker, ein Einhänder macht dann 20 statt 16 Schaden.
  - Dagegen: Die Stufe zählt doppelt, und alle Gegner müssten neu gerechnet werden. Güte, Herstellen und Einzelstücke verlieren mit jedem Aufstieg an Wert. Die Kampfstile gewinnen ungleich: die Armbrust 50 %, Krieger mit Schild dreifach, Dolch und Magier wenig. Der Fokus bräuchte eine eigene Regel, und der Umbau reicht durch die ganze Kampfrechnung.
- **C: keine Sperre.** Das ist am einfachsten. Die Stufe ist dann nur eine Zahl im Fenster, und die Spannung, nach der du gefragt hast, fehlt.
- **Stärkstes Gegenargument gegen A:** In Kapitel 1 bleibt der Gewinn klein, weil Beute höchstens ein oder zwei Zusatzeigenschaften hat und der Deckel die Grundwerte hält. Die Sperre spürt man darum stärker als die Stärke, und sie kann mehr ärgern als freuen. Antwort: Höchstens eine Stufe Abstand hält den Ärger kurz. Gewöhnliches Gerät sperrt nur der Katalog. Kapitel 1 ist bewusst klein, und mit jedem Kapitel wachsen die Zahl der Zusatzeigenschaften und damit das Gewicht der Stufe. Den spürbaren Sprung bei Schaden und Schutz gibt die Güte. Die erarbeitest du dir im Handwerk, die Stufe kommt mit der Zeit. Das passt zu „du wirst, was du tust“.
- **Bewusst nicht dabei:** Voraussetzungen über Grundwerte (Kraft für schwere Rüstung) oder über den Rang einer Fertigkeit. Das wäre ein drittes System. Es steht als Idee in `LISTE-IDEEN.md` („Balance und Attribute“).

**Folgerungen:**
- Bei A trage ich die Regel in `DESIGN-BRS.md` Abschnitt 11 ein und lege die Vorgänge an: Tom baut Sperre, Gaben und Stufen der Einzelstücke, Jerry die Beutestufe mit 633 und die Stufenschritte. Homer prüft die Stufen der Einzelstücke gegen die Geschichte.
- Jerry misst in 644.2, mit welcher Stufe der Held die Truhe der Höhle und das Kapitelende erreicht. Weicht das ab, lege ich dir die Zahlen vor.
- Bei B rechnet Jerry zuerst alle Gegner neu. Bei C ändere ich nur das Regelwerk.

Antwort: …
