# 406.1 · Schildstoß: Block und Konter am Ring für jeden mit Schild, als Angriff erst für den Wächter?
Jerry · 01.11., 22:35 · E Kampf

**Frage:** Wie kommt der Schildstoß ins Spiel? Du hast gesagt (01.11., 20:2x): „als Reaktion … mit dem Ring“, „als Konter, den man dann gezielt macht, wenn man den Ring gut trifft“, „vielleicht als Angriff“.
**Votum Jerry: A.** Wer einen Schild in der Hand hält, bekommt bei jedem Nahangriff den Ring. Bei gutem Ring blockt er mit dem Schild, bei vollem Ring stößt er zurück (Konter). Als eigene Handlung im Menü kommt der Schildstoß mit dem Pfad Wächter, als dessen erste Handlung nach der Zwischenprüfung (ab Kapitel 2), so wie die Riposte erst mit dem Duellanten kommt (Entscheidung 75).
**Berührt:** 406 (Kaufschilde, Bewegungen aus Sword & Shield), BRS Kapitel 5 (Pfad Wächter) und 7 (Kampf, Modell D), 444 (Simulation, `werte.json`), 469 (Kampf auf BRS), MARS-Ring (72.11).

## Begründung

Der Ring ist der Augenblick, in dem der Spieler im Kampf selbst etwas kann; der Schildstoß macht ihn für den Schildträger lohnend und sichtbar, ohne eine Taste mehr. Heute öffnen die Wölfe den Ring gar nicht (siehe Sachverhalt); ohne die erste Regel unten sähe man in Kapitel 1 keinen Schildstoß.

## Vorschlag

Alle Zahlen sind Startwerte nach Modell D; die Simulation 444 misst sie.

| Wann | Was geschieht | Zahlen | Bewegung |
|---|---|---|---|
| **Nahangriff** auf jemanden mit Schild in der Hand | der Ring öffnet sich, auch beim Anspringen der Wölfe | – | – |
| **Ring gut** (± 0,26 s) | Block: der Schlag trifft den Schild | halber Schaden, dann Abzug wie in der Simulation 444: Rüstung × (1 + Rüstungsfertigkeit / 100) + Schildwert × (1 + Schild / 100) | `SS_Block…` je Angriffsart (gebaut, 406) |
| **Ring voll** (± 0,09 s) | Konter: der Schlag ist ganz abgefangen, sofort folgt der Schildstoß | wie ein Waffenhieb nach Modell D, mit dem Schild als Waffe: Trefferchance 70 % + (Schild − Abwehr des Gegners) × 0,5 %; Schaden (Schildwert + Kraft) × (1 + Schild / 100) × (1 + D / 10) − Rüstung. Trifft er, **taumelt** der Gegner: sein nächster angesagter Angriff verfällt, er weicht einen Schritt zurück | `ShieldAttack1–3` im Wechsel; der Wolf zuckt und springt zurück |
| **Angriff im Menü**, Wächter ab Zwischenprüfung | eigene Handlung „Schildstoß“ statt Waffenhieb | dieselbe Formel wie der Konter; trifft er, taumelt der Gegner | wie Konter |
| **Bosse** (Grak) | taumeln seltener | Taumeln nur mit halber Chance (Wurf nach dem Treffer) | – |

Die Tabelle des Wächters in BRS 5 bekommt die Handlung „Schildstoß“ dazu. Ring voll ohne Schild bleibt bis 469 wie heute (Antwort nach Klasse); 469 regelt sie im BRS neu, weil es dort keine Klassen gibt.

**Beispiel:** Wachsoldat Stufe 1 (Schild 10, Mittlere Rüstung 10, Kraft 6, Rundschild mit Schildwert 2) gegen einen Wolf Stufe 2 (Schaden 7, Angriff 15, Abwehr 12, Rüstung 1; `werte.json`):
- Biss: 7 × 1,15 × 1,1 ≈ 8,9. Abzug: 3 × 1,1 + 2 × 1,1 = 5,5.
- Ohne Ring: 8,9 − 5,5 ≈ 3 Schaden. Ring gut: 4,4 − 5,5, also 0 Schaden.
- Ring voll: kein Schaden. Der Schildstoß trifft zu 70 + (10 − 12) × 0,5 = 69 % und macht (2 + 6) × 1,1 × 0,9 − 1 ≈ 7 Schaden (ein Schwerthieb: (6 + 6) × 1,1 × 0,9 − 1 ≈ 11; der Wolf hat 14 Leben). Der Wolf taumelt, sein nächster Biss fällt aus.

Schild übt sich mit jedem Schildstoß, der trifft (BRS 3: „Treffen im Kampf“).

## Sachverhalt

- Heute (`godot/regeln/mars.gd`, noch nach SRD): Ring gut = halber Schaden, Ring voll = kein Schaden und eine Antwort je Klasse (Kämpfer schlägt zurück, Schurke tritt hinter den Gegner, Kleriker betet, Magier mit Feuerpfeil).
- Die Wölfe kündigen nur „Anspringen“ und „Einkreisen“ an, beide ohne Ring. Der Ring öffnet sich heute nur, wenn ein Angriff ihn erlaubt oder der Held einen Angreifer mit „Decken“ auf sich zieht; steuert der Rechner die Figur, gilt dort, wo ein Ring wäre, immer „Ring gut“.
- Die Bewegungen sind gekauft und gebaut (406): Abwehr je Angriffsart (`SS_Block…`, `SS_Parry…`), `ShieldAttack1–3`.
- BRS 5: Pfad Wächter, Kernfertigkeiten Schild und Schwere Rüstung, Handlungen „Gegner binden, Gefährten decken“; die erste Handlung bringt die Zwischenprüfung (ab Kapitel 2).
- BRS und Simulation rechnen den Abzug verschieden: BRS Modell D nimmt beim Block nur den Schild, die Simulation 444 zählt Rüstung und Schild zusammen. Der Vorschlag folgt der Simulation, weil sie misst.

## Auswertung

- **Stärkstes Gegenargument:** Der Ring bei jedem Nahangriff auf den Schildträger macht ihn deutlich zäher: mit gutem Ring nimmt der Wachsoldat vom Wolf keinen Schaden mehr. Kapitel 1 kann damit zu leicht werden, gerade für den Schildträger.
- **Entkräftet:** Ob es zu leicht wird, zeigt die Simulation 444, bevor gebaut wird; dann ändern sich die Zahlen (Schildwert, halber Schaden), nicht die Regel. Offen bleibt der Rechner: steuert er die Figur, bekäme sie heute bei jedem Ring „gut“, also jeden Block geschenkt. Mein Vorschlag dazu: beim neuen Schildring zählt für den Rechner „ohne Ring“; den Block gibt es nur für den, der tippt.
- **Gegenvorschlag B:** zusätzlich der Schildstoß als Angriff im Menü für jeden mit Schild schon ab Kapitel 1. Mehr Wahl im Kampf (Leitbild: „echte Wahl“), aber eine Handlung mehr im Menü und weniger Grund für den Pfad Wächter.

## Folgerungen

- „A“: Perikles nimmt Block, Konter und Ring beim Nahangriff in die Simulation 444; nach dem Ergebnis baut Jerry sie in MARS. Homer schreibt die Zeilen für Block, Konter und Taumeln (Vorgang an Homer). Der Angriff im Menü kommt mit dem Pfad Wächter.
- „B“: dazu der Menüpunkt „Schildstoß“ für jeden mit Schild ab Kapitel 1.
- Geprüft wird mit `wolf_mess_438` (Schild durch Wolf, Reihenfolge) und einem kurzen Film Block und Konter.

Antwort: „406.1 A“ oder „406.1 B“, gern mit Zahlen.

## Stellungnahme Sokrates (02.11., 02:41)

- **Stärkstes Gegenargument:** Ring bei jedem Nahangriff heißt gegen ein Rudel ein Tipp je Biss; der Ring war als seltener, lesbarer Augenblick gebaut („Kleine Schläge der Goblins kommen ohne Ring“, `DESIGN-KAMPF-SPIELANLEITUNG-72-10A.md`; DESIGN-KAMPF: jeder Ring braucht eine lesbare Ausholbewegung mit festem Takt). Oft wiederholt wird er Pflichtübung statt Wahl, und nach Jerrys eigenem Beispiel nimmt der Wachsoldat mit „Ring gut“ vom Wolf 0 Schaden: der Schildträger wird in Kapitel 1 unverwundbar, sobald der Spieler den Takt kann.
- **Weg, der es entkräftet:** Ring nur bei angekündigten Nahangriffen (beim Wolf „Anspringen“, mit Ausholbewegung), nicht bei jedem Biss; Simulation 444 misst vor dem Bau zwei Zahlen: Ringe je Kampf und Schaden des Schildträgers mit „Ring gut“ (Richtwert: nie 0 gegen einen Gegner seiner Stufe, sonst Abzug kleiner).
- **Widerspruch zu Entschiedenem:** (1) Rechner „ohne Ring“ widerspricht der geltenden Spielanleitung (Automatik „fängt den Ring mit Gut“); wenn, dann für allen Ring gleich, nicht nur beim Schild, sonst zwei Regeln für denselben Ring. (2) Abzug nach Simulation statt BRS Modell D: das BRS ist unser Regelwerk; die Abweichung entscheidet 469 einmal, nicht dieser Vorschlag nebenbei. (3) Wächter-Handlung im Menü passt zu 75 (Riposte erst mit dem Duellanten) und zu BRS 5; kein Widerspruch.
- **Kosten:** A: ein Simulationslauf (Perikles), eine Jerry-Sitzung für Ring, Block, Konter, Taumeln, Zeilen von Homer, ein Film; B dazu Menüpunkt und Abgrenzung zum Wächter. Bewegungen sind gekauft (406), keine Ausgabe.
- **Empfehlung:** „406.1 A“, aber mit Ring nur bei angekündigten Nahangriffen statt jedem, Automatik wie heute „gut“ bis 469 es für allen Ring regelt, und Bau erst, wenn 444 zeigt, dass der Schildträger in Kapitel 1 weiter Schaden nimmt; B nein, weil es dem Pfad Wächter den Grund nimmt.
