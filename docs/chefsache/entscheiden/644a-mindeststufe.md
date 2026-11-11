# 644a · Soll jedes Stück erst ab seiner Stufe tragbar sein, wie weit darf ein Fund über dem Helden liegen, und fällt der Deckel?
Sokrates · 11.11., 21:04 · E Kampf · aus deinem Wort 19:56 zu 870.7, Deckel 21:01
Kurz: Mindeststufe zum Tragen bauen, wie im Regelwerk vorgesehen; ein Stück ab Stufe 4 trägt die doppelte Zusatzeigenschaft (Leben +10 statt +5) statt mehr Grundschaden; Funde höchstens eine Stufe über dem Helden; Deckel streichen, Menge an der Quelle steuern

Geprüft an: [65ea0e915](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/65ea0e915) (Zweig `claude/build-277`) und [eb38b1de0](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/eb38b1de0) (`main`): `godot/regeln/brs_held.gd`, `godot/skripte/beute.gd`, `godot/skripte/spiel.gd`, `tools/gegenstaende/gegenstaende.json`, `tools/sim444/werte.json` („gegenstaende“); ein Helfer hat gegen den Code und alle sechs Kampfstile gegengeprüft, seine Funde sind eingearbeitet

**Frage:** Du hast gefragt (19:56): „gibt es denn nicht auch Mindestvoraussetzungen, dass ich gewisse Dinge benutzen darf? … Haupt- oder Nebenhandstufe 6. Heißt es, dass ich mindestens die Stufe 6 brauche … dass es an der Heldenstufe hängt.“ Vorgesehen ist das: Das Regelwerk nennt die Gegenstandsstufe „Stärke und Mindeststufe zum Tragen, wie die Heldenstufe“. Gebaut ist die Sperre nicht. Zu entscheiden sind vier Fragen: Kommt die Sperre? Was macht eine höhere Stufe stärker? Wie weit darf ein Fund über dem Helden liegen? Fällt der Deckel? Deine Nachfrage um 21:00 („Es steht plus 5 da, aber es zählt dann doppelt. Das verstehe ich 0,0“) ist eingearbeitet: Am Stück steht immer der Wert, der wirkt. Zum Deckel hast du um 21:01 gesagt: „das mit dem Deckel … hat vielleicht bei SRD noch Sinn gemacht, finde ich hier aber nicht gut, dann darfst du halt nicht so viele Gegenstände geben, die irgendwelche Grundwerte erhöhen … das, was ich trage, das habe ich. Bin ich grundsätzlich nicht für einen Deckel … wir diskutieren“.

**Votum:** „644a A“:
- Ein Stück der Stufe 6 kann erst ein Held der Stufe 6 tragen.
- Ein Stück ab Stufe 4 trägt die doppelte Zusatzeigenschaft: Am Stück steht „Leben +10“ statt „Leben +5“, und genau das wirkt. Nichts zählt verdeckt. Die Schritte sind fest, nicht „mal Stufe“: doppelt ab Stufe 4, dreifach ab 7, vierfach ab 10 (Tabelle unten). Beim Schutzwert ist das schon so gebaut.
- Schaden und Schutz der Grundform hebt weiter nur die Güte.
- Ein Fund liegt höchstens eine Stufe über dem Helden.
- Händler verkaufen nur, was du schon tragen kannst.
- **Deckel streichen:** Was du trägst, wirkt voll. Die Menge steuern wir dort, wo die Stücke entstehen (Teil D unten). Vorher rechnet Jerry den schlimmsten Fall durch. Erst wenn der vertretbar ist, fällt der Deckel.

**Berührt:** 644 (Gegenstandskatalog, Sokrates), 644.2 (Zahlen in der Simulation, Jerry), 633 (Boss-Beute fehlt, Jerry), 870.6 und 870.7 (Beute, Laden und Gegenstandsfenster, in Build 277), 976 (Güte), Einzelstücke im Katalog (Homer liest ihre Stufen gegen die Geschichte)

**Begründung:** Die Heldenstufe bestimmt im Kampf schon die Größenordnung, mit 10 % je Stufe Unterschied (dein Kampfmodell vom 31.10.: „Stufe für die Größe, Fertigkeit für das Können“). Würde die Gegenstandsstufe zusätzlich den Schaden heben, wirkte die Stufe zweimal im selben Schlag. Dann müssten alle Gegner von Kapitel 1 neu gerechnet werden, und jedes Stück würde mit jedem Aufstieg schlechter, auch ein meisterhaft geschmiedetes oder ein Einzelstück mit Geschichte. Mit A bleibt die Spannung, nach der du gefragt hast: Ein starker Fund liegt eine Weile in der Tasche, bis du so weit bist. Ab Stufe 4 siehst du den Sprung an der Zahl am Stück.

**Sachverhalt:**
- **Regelwerk** (`DESIGN-BRS.md`, „Alle Stufen auf einen Blick“ und Abschnitt 11): Was die „Stärke“ der Gegenstandsstufe genau heißt, ist offen. Schaden und Schutzwert der Grundform hebt die Güte, in Build 277 um 15 % (Gut) und 30 % (Meisterhaft).
- **Sperre:** Der Code prüft nichts, die Abfrage „kann tragen“ sagt immer ja (`brs_held.gd` Zeile 352). Die Anzeige dafür gibt es schon: „Nicht tragbar“ im Laden, gesperrtes Anlegen und „Stufe 6“ im Gegenstandsfenster. Es fehlt nur die Regel.
- **Was die Stufe in Build 277 bewirkt:**
  - Sie bestimmt, welche Grundformen vorkommen, etwa Halbplatte ab 6 und Plattenpanzer ab 7.
  - Sie hebt den Preis um 20 % je Stufe.
  - Sie hebt zwei Zusatzeigenschaften: Schutzwert +2 statt +1 ab Stufe 4, Fertigkeit +2 ab Stufe 6 (nur episch).
  - Alle anderen Zusatzeigenschaften sind fest, gleich welche Stufe (`werte.json` „zusatz“, `beute.gd` „zusatz_wert“).
- **Deckel:** Alle getragenen Stücke zusammen geben höchstens so viel auf jeden Grundwert, wie die Nummer des Kapitels sagt (Kapitel 1: +1), und beim Schutzwert eins mehr (Kapitel 1: +2) (`werte.json` „deckel“, `brs_held.gd` „ausruestungs_bonus“). Das stammt aus der alten Fassung („Rules.gearCap“). Wer mehr trägt, sieht die Zahl am Stück, aber sie wirkt nicht.
- **Ohne Deckel, schlimmster Fall:** Ein Held hat neun Plätze. Gewandtheit darf auf allen neun als Zusatzeigenschaft vorkommen, Kraft auf acht (`werte.json` „erlaubt“). Wer jedes Stück mit „Gewandtheit +1“ findet, hätte +9 auf einen Grundwert, der beim Start zwischen 3 und 8 liegt. Gewandtheit gibt seit 952 D auch die Häufigkeit kritischer Treffer. In Kapitel 1 hat Beute höchstens eine Zusatzeigenschaft (ungewöhnlich), Bosse höchstens zwei (selten). Wie oft das geschieht, misst erst die Rechnung unten.
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
- **A (Empfehlung): Sperre, Zusatzeigenschaften in festen Stufenschritten.**
  - **Sperre:** Anlegen erst ab der Stufe des Stücks. Was du schon trägst, bleibt angelegt, auch aus alten Spielständen oder nach dem Testmenü.
  - **Stärke:** Beim Fund bekommt das Stück den Wert seiner Stufe, und dieser Wert steht am Stück. Ein Ring der Stufe 4 heißt also „Leben +10“, einer der Stufe 2 „Leben +5“. Die Schritte (Startwerte):

    | Gegenstandsstufe | Leben | Mana | kritisch | Zauberschaden | Abwehrprobe | Schutzwert |
    | --- | --- | --- | --- | --- | --- | --- |
    | 1–3 | +5 | +5 | +3 % | +10 % | +5 % | +1 |
    | 4–6 (Kapitel 1 endet bei 6) | +10 | +10 | +6 % | +20 % | +10 % | +2 |
    | 7–9 | +15 | +15 | +9 % | +30 % | +15 % | +3 |
    | 10–12 | +20 | +20 | +12 % | +40 % | +20 % | +4 |
    | danach | alle drei Stufen ein Schritt mehr | | | | | |

    Der Schutzwert folgt schon heute dieser Regel (+2 ab Stufe 4). Grundwerte bleiben je Stück bei +1 in jeder Stufe, weil ein Grundwert zugleich Schaden, Treffer, Leben oder Mana bewegt. „Fertigkeit +1/+2“ bleibt, wie du sie für episch entschieden hast. Das wirkt für alle sechs Kampfstile gleich, auch für Magier und Heiler. Ein Fokus braucht keine eigene Regel.
  - **Gewöhnliche Stücke** ohne Zusatzeigenschaft bekommen die Stufe ihrer Grundform aus dem Katalog. Ein schlichtes Langschwert ist also immer Stufe 1, ein Plattenpanzer Stufe 7. Die Sperre heißt dort: schweres Gerät erst für Erfahrene.
  - **Funde:** Beute bekommt die Stufe des stärksten Gegners im Kampf, höchstens deine Stufe plus 1. Gaben werden genauso gedeckelt. Händler bleiben bei deiner Stufe. Einzelstücke behalten ihre Stufe aus dem Katalog. Homer und Jerry prüfen, dass keines höher liegt als die Stufe, mit der der Held es laut Geschichte bekommt.
  - **Kosten:** klein. Tom baut Sperre, Gaben und Einzelstücke, Jerry die Beutestufe mit 633 und die Stufenschritte. Die Gegner müssen nicht neu gerechnet werden. Jerry misst in 644.2 nur den Abstand und die Schritte.
- **B: Sperre, und die Stufe hebt auch Schaden und Schutz**, etwa um 10 % je Stufe auf Waffe, Rüstung und Schild.
  - Dafür: Ein Fund der Stufe 6 ist deutlich stärker, ein Einhänder macht dann 20 statt 16 Schaden.
  - Dagegen: Die Stufe wirkt zweimal im selben Schlag, und alle Gegner müssten neu gerechnet werden. Güte, Herstellen und Einzelstücke verlieren mit jedem Aufstieg an Wert. Die Kampfstile gewinnen ungleich: die Armbrust 50 %, Krieger mit Schild dreifach, Dolch und Magier wenig. Der Fokus bräuchte eine eigene Regel, und der Umbau reicht durch die ganze Kampfrechnung.
- **C: keine Sperre.** Das ist am einfachsten. Die Stufe ist dann nur eine Zahl im Fenster, und die Spannung, nach der du gefragt hast, fehlt.
- **Stärkstes Gegenargument gegen A:** In Kapitel 1 bleibt der Gewinn klein, weil Beute höchstens ein oder zwei Zusatzeigenschaften hat und Grundwerte je Stück bei +1 bleiben. Die Sperre spürt man darum stärker als die Stärke, und sie kann mehr ärgern als freuen. Antwort: Höchstens eine Stufe Abstand hält den Ärger kurz. Gewöhnliches Gerät sperrt nur der Katalog. Kapitel 1 ist bewusst klein, und mit jedem Kapitel wachsen die Zahl der Zusatzeigenschaften und damit das Gewicht der Stufe. Den spürbaren Sprung bei Schaden und Schutz gibt die Güte. Die erarbeitest du dir im Handwerk, die Stufe kommt mit der Zeit. Das passt zu „du wirst, was du tust“.
- **D (Empfehlung zum Deckel): streichen, Menge an der Quelle steuern.**
  - Der Deckel fällt für Grundwerte und Schutzwert. Was am Stück steht, wirkt.
  - Steuerung an der Quelle: Grundwerte als Zusatzeigenschaft würfeln seltener (Startwert halbes Gewicht gegenüber Leben, Mana und Schutzwert). In Kapitel 1 bleibt Beute höchstens ungewöhnlich. Händler verkaufen in Kapitel 1 keine Stücke mit Grundwert.
  - Vorher rechnet Jerry in 644.2 den schlimmsten Fall (alle Plätze +1 auf denselben Wert, mit kritischen Treffern nach 952 D) und den üblichen Fall eines Durchgangs durch Kapitel 1. Liegt der übliche Fall über +3 auf einem Grundwert, lege ich dir die Zahlen vor.
  - **Stärkstes Gegenargument:** Ohne Deckel hängt die Stärke am Glück beim Würfeln. Ein Held mit fünf Mal „Gewandtheit +1“ trifft spürbar öfter kritisch, und die Gegner von Kapitel 1 sind ohne diese Spitze gerechnet. Antwort: Der Deckel verdeckt das nur. Er zeigt eine Zahl, die nicht wirkt, und das widerspricht deinem „das, was ich trage, das habe ich“. Die Spitze kappt man ehrlicher über die Häufigkeit der Funde, und die Rechnung zeigt vorher, ob sie trägt.
  - **E: Deckel behalten, aber anzeigen**, etwa „Gewandtheit +1 (wirkt nicht, Höchstwert erreicht)“. Das ist sicher für die Balance, bleibt aber ein unsichtbares Gesetz gegen dein Wort.
- **Bewusst nicht dabei:** Voraussetzungen über Grundwerte (Kraft für schwere Rüstung) oder über den Rang einer Fertigkeit. Das wäre ein drittes System. Es steht als Idee in `LISTE-IDEEN.md` („Balance und Attribute“).

**Folgerungen:**
- Bei A trage ich die Regel in `DESIGN-BRS.md` Abschnitt 11 ein und lege die Vorgänge an: Tom baut Sperre, Gaben und Stufen der Einzelstücke, Jerry die Beutestufe mit 633 und die Stufenschritte. Homer prüft die Stufen der Einzelstücke gegen die Geschichte.
- Jerry misst in 644.2, mit welcher Stufe der Held die Truhe der Höhle und das Kapitelende erreicht. Weicht das ab, lege ich dir die Zahlen vor.
- Bei B rechnet Jerry zuerst alle Gegner neu. Bei C ändere ich nur das Regelwerk.
- Bei D rechnet Jerry in 644.2 zuerst den schlimmsten und den üblichen Fall, dann streicht er den Deckel und halbiert das Gewicht der Grundwert-Zusätze. Tom nimmt Stücke mit Grundwert aus dem Laden in Kapitel 1. Bei E zeigt Tom die nicht wirkende Zahl im Gegenstandsfenster an.

<details><summary>Befund des Helfers (Gegenprüfung 20:32, Wortlaut gekürzt; geprüft war die erste Fassung, Empfehlung damals B)</summary>

- Stimmt: `kann_tragen` immer wahr; Beute nach Gebietsstufe, Gaben nach Gebiet oder Held; Händler in Heldenstufe; Rüstungswerte 1/3/5, Schild 2; Schutzwert nur Brust und Schild; Katalogstufen; Gegnerstufen; alte Sperre nur nach Klasse; Rechnung 16 → 20.
- Fokus: Zauberstab, Magierstab, Zauberkugel, Foliant, Heiligensymbol; Stäbe sind zugleich Stumpfe Waffen, würden unter B doppelt wachsen.
- Auf `main` wirken AC, HP, SP, SPELL, DAMAGE, ATTACK, CRIT im Kampf nicht, die Anzeige „Schutzwert 11–18“ ist alt (in Build 277 durch 870.6 behoben, von mir nachgeprüft).
- Boss-Einzelstücke (Graks Kriegsaxt, Grimmzahns Fang, Ogerhandschuhe, Umhang des Schutzes) werden in Godot nicht vergeben (Vorgang 633).
- Die Stufe wirkt auch auf die Auswahl der Grundformen (vier Wirkungen, nicht drei).
- Unter B gewinnt je nach Waffe 20 % (Dolch) bis 50 % (Armbrust ohne Grundwert); Krieger mit Rüstung und Schild am meisten, Späher am wenigsten.
- Gaben „wie heute“ widerspricht „höchstens plus 1“ (Held 1 in der Höhle bekommt Stufe 3).
- Lücken: welche Gegnerstufe bei Rudeln zählt (Vorschlag: der Anführer); Nebenhandwaffe und Ersatzwaffe; alte Spielstände und Testmenü (Getragenes bleibt oder fällt ab); Güte und Stufe auf derselben Zahl ohne Regel; der Vergleich zeigt keine Zeile für Zauber; Ring des Ältesten Stufe 6 am Kapitelende ist für einen Helden unter 6 nicht tragbar; Truhe gibt Bogen-, Armbrust-, Zweihänder- und Stangenwaffen-Kämpfern eine fremde Waffe.
- Stärkstes Gegenargument gegen B: Die Stufe zählt doppelt (Kampfmodell plus Gerät), Kapitel 1 wird leichter, wenn nicht alle Gegner neu gerechnet werden; Tretmühle beim Gerät, entwertet Güte, Herstellen und Einzelstücke. Daraufhin habe ich die Empfehlung auf A gedreht.
</details>

Antwort: …
