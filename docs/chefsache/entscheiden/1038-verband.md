# 1038 · Wofür braucht der Held den Verband, und wird die Rast knapper?
Sokrates · 12.11., 16:18 · G Balance · aus deinem Wort 16:09–16:16 zum Vorentscheid 1038 (zurückgezogen)
Kurz: Der Verband stillt Blutung statt nur Leben zu heilen; die kurze Rast gibt kein Leben mehr, damit man Verband, Trank oder Essen dabeihaben muss

Geprüft an: [Rast auf main](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/godot/skripte/rast.gd), [Zustände nach dem Kampf](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/godot/skripte/spiel.gd) (`leiden_nach`), Kotlin `core/Game.kt:778`, Zahlen Jerry [7696371e0](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/7696371e0)

**Frage:** Mit 807 A soll es in Kapitel 1 einen Verband geben, den man bei Osric und Thessa kauft und mit Heilkunde besser anlegt. Mein Vorentscheid gab ihm nur Leben (anfangs 7). Du hast gefragt, wozu, wenn der Heiltrank mehr heilt: Er muss Wunden heilen, und herstellen muss man ihn auch können. Dazu: Es gibt zu viele bequeme Rastplätze, der Held soll sich darum kümmern müssen, einen Verband dabeizuhaben. Zu entscheiden sind zwei Dinge: (1) was der Verband tut, (2) wie viel die Rast hergibt.

**Votum:** „1038 A, R1“: Der Verband stillt Blutung, kaufen jetzt, herstellen mit dem Rezeptbuch; die kurze Rast gibt nur noch Ausdauer, kein Leben.

**Berührt:** 842 (Tom, Verband in Tasche und Laden), 1037 (Jerry, Werte), 72c (Wunden bis zur Rast, nach dem Meilenstein), Rezeptbuch (`DESIGN-BRS.md` 8), Homer (Text des Verbands), Simulation 444 (Jerry rechnet die Rast neu)

**Begründung:** Dein Wort 16:12: „Also um Lebenspunkte zu heilen nicht, sondern er muss Wunden heilen. Aber mit Wunden arbeiten wir ja noch nicht. Und wie kann ich ihn herstellen?“ und 16:16: „im Moment sind wir verwöhnt, weil wir recht viele Raststätten haben … da muss sich der Held auch darum kümmern, dass er zum Beispiel einen Verband dabei hat, weil er nicht einfach rasten kann an einem Lagerfeuer.“ Die Wunde, die es heute schon gibt, ist die Blutung; und verwöhnt macht nicht die Zahl der Feuer, sondern dass die kurze Rast beliebig oft kostenlos Leben gibt.

**Sachverhalt:**
- **Blutung ist die Wunde von heute:** Kotlin ließ sie nach dem Kampf weiterlaufen („Die Wunde blutet weiter (−{0} TP)“, `Game.kt:778`); Godot ebenso, Blutung und Gift bleiben nach dem Kampf und klingen je Punkt Zähigkeit über 5 eine Runde früher ab (`spiel.gd`, `leiden_zaehigkeit_ab`). Kein Heiltrank stillt sie; Zustände heilt nur der Kräutertrank.
- **Rast heute** (`rast.gd`): kurze Rast am Feuer 2 Stunden, Ausdauer voll und ein Viertel des Lebens, **beliebig oft, kostenlos**; lange Rast 9 Stunden, alles voll, einmal je Spieltag, am Feuer kostenlos, im Zimmer der Schenke 5 Gold. In der Höhle kein Rasten („viel zu gefährlich“).
- **Heilung sonst:** Heiltrank 14 Leben für 25 Gold, Braten 14 Leben, Startgeld 20 Gold.
- **Herstellen:** Heilkunde steht im Regelwerk beim Handwerk mit „herstellen, verbinden“ (`DESIGN-BRS.md` 6). Eigene Rezepte des Helden gibt es noch nicht (nur Morwens Rezepte im Laden); das Rezeptbuch ist entschieden (Chef 11.11., 16:31), nicht gebaut. Heilkräuter sammelt der Held schon; Leinen gibt es noch nicht; Spinnseide ist Beute der Riesenspinne.
- **Wunden als eigenes System** (Baustein 4 in `DESIGN-KAMPF.md`, 72c): wer unter ein Viertel seines Lebens fällt, behält eine Wunde bis zur Rast oder zum Heiler; steht für nach dem Meilenstein.

**Auswertung:**
- **A (Empfehlung) Verband stillt Blutung:** Anlegen beendet die Blutung sofort und gibt einen kleinen Teil Leben (Jerrys Zahl, 5 + 1 je 5 Punkte Heilkunde); nur außerhalb des Kampfs; kaufen bei Osric und Thessa, etwa 8 Gold. Herstellen mit dem Rezeptbuch: Heilkräuter und Leinen (neu, billig bei Thessa) am Lagerfeuer ab Heilkunde Anfänger; mit Spinnseide stillt er auch schwere Blutung. Später schließt er die Wunden aus 72c. Kosten: klein, Tom und Jerry am schon gebauten Verband.
- **B Verband erst mit dem Wundensystem:** raus aus Kapitel 1, 807 A teilweise zurück; Heilkunde hat in Kapitel 1 dann keinen Nutzen außerhalb des Kampfs.
- **R1 (Empfehlung) kurze Rast nur Ausdauer:** die kurze Rast gibt Ausdauer, aber kein Leben mehr; Leben kommt aus der langen Rast (einmal am Tag oder 5 Gold), Trank, Verband, Braten. Keine Karte ändert sich. So muss der Held vorsorgen, wie du es willst.
- **R2 Feuer ausdünnen:** Rastplätze von der Karte nehmen. Ändert Karten und Geschichte (Garricks Lager), und die kostenlose kurze Rast an den übrigen bleibt beliebig oft.
- **R3 so lassen.**
- **Stärkstes Gegenargument gegen R1:** Der Kampf wird zäher, man muss öfter zurück ins Dorf, und Baustein 4 verspricht „die Rast ist nie weit weg“. Antwort: Die lange Rast bleibt jeden Tag kostenlos am Feuer, das Zimmer kostet 5 Gold; zurücklaufen muss nur, wer nichts dabeihat. Jerry rechnet mit Simulation 444 nach, ob Kapitel 1 ohne Grinden durchspielbar bleibt (Leitbild); fällt es durch, kommt die Zahl vor dem Bau zu dir.

**Folgerungen:** Bei A: Jerry ändert den Verband (stillt Blutung), Tom passt Tasche und Laden an, Homer prüft den Text (`[807.verband.an]` „Ein fester Knoten, und das Blut steht.“ passt schon); Leinen und Rezept kommen mit dem Rezeptbuch. Bei R1: Jerry ändert die kurze Rast und rechnet Kapitel 1 nach, Homer passt den Rasttext an. Bei B nimmt Tom den Verband aus 842 heraus.

Antwort: „1038 A, R1“, auch andere Kombination, z. B. „1038 A, R3“ oder „1038 B“
