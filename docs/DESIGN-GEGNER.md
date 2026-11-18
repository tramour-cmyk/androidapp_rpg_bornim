# Gegnerverhalten (Regelblatt 1589.1)

**Entschieden 1589.1 A, Lohn A (Chef 17.11., 22:33): „Ansonsten folge ich deinem Votum … Mit A und Lohn können wir auch annehmen.“** **Begriffe (Chef 17.11., 23:44, „Ja, so machen.“, `LISTE-GLOSSAR.md` 5):** **Arena** (bisher „Blatt“), **Stellung**, **Beinarbeit**, **Denkweise**; Code `regeln/arena.gd`. In „Ergänzungen“ (Verlauf) steht noch „Blatt“ = Arena.

Das ganze Regelblatt gilt mit den Ergänzungen der vier Gegenleser, eingearbeitet unten. Der Chef ergänzte selbst Abschnitt 1 und 1a („wenn du aus meinen Ergänzungen noch was ableiten kannst, dann mach das“). Gebaut wird in vier Stufen (Abschnitt 11) ab Sa 21.11., 20:00. Der Halt bei Jerry (Chef 18:15) ist aufgehoben. Zahlen kommen aus der Rechnung 444.

## 1. Grundsatz: die Arena

- Intern ist der Kampf eine flache Arena mit X und Y, unsichtbar unter dem Kampfort. 3D ist nur die Umsetzung davon: Figuren gehen aneinander vorbei, halten Abstände, Bisse landen, neue Aufstellungen entstehen (Chef 18:15).
- **Fein wie Millimeterpapier, nicht grob wie ein Schachbrett** (Chef 22:33: „Ein Schachbrett ist mir zu grob … Millimeterpapier jetzt nicht wörtlich nehmen“). Jede Figur hat einen Punkt in Metern (x, y) und einen Umriss als Kreis, gemessen am Modell (Jerry). Es gibt keine Felder, an die eine Figur gebunden ist.
- Die Figuren stehen von oben gesehen maßstabsgetreu in der Arena. Jeder Angriff hat eine Reichweite in Metern, eingetragen in `werte.json`, etwa Klaue, vorgestreckter Biss, Schwert, Speer, Bogen (Chef 18:50).
- **Abstand wird abgeleitet, nicht gesetzt** (Chef 22:33: „dass eben die Reichweiten da ableitbar sind … wann geht es über von fern in nah“): Nah ist, wer die Reichweite des eigenen Nahangriffs erreicht oder in der des Gegners steht. Fern ist, wer außerhalb davon steht, aber in Schussweite. Weit ist alles darüber. Die drei Stufen aus `DESIGN-GLUT.md` (nah, fern, weit) bleiben als Wörter für den Spieler. Woher sie kommen, entscheidet die Arena.
- **Die Plätze im MARS sind nicht mehr bindend** (Chef 22:33: „nicht mehr so ganz fix auf die ursprünglichen Gitterpositionen gebunden, die wir ja einblenden können“). Vorn und hinten, die vier Plätze und das Raster bleiben eine Einblendung zum Lesen; die Regeln rechnen mit den Punkten in der Arena.
- Jede Regel unten wird in der Arena entschieden, nie im Bild. Der Blickwinkel der Kamera ändert keine Regel (Abschnitt 10).
- Das Blatt gilt im MARS auch ohne Kerben. Ob das Kerbensystem ins Spiel kommt, ist ein eigener Entscheid. Bis dahin heißt „3 Kerben“ in Abschnitt 4 und 9 „großer Schlag, angesagt“ (Jerry, Perikles).

## 1a. Waffe und Abstand (abgeleitet aus Chef 22:33)

- Chef 22:33: „entweder habe ich zum Beispiel einen Bogen, dann kommt einer nah an mich ran, dann muss ich auf die Waffe wechseln, um mich zu verteidigen. Weil ansonsten kriege ich halt einen Malus auf Bogenkampf im Nahkampf … Oder ich greife mit Bogen an und nähere mich und wechsle dann auf Schwert. Und wenn ich das nicht habe, ja, dann habe ich ein Problem, ein taktisches.“
- **Fernwaffe im Nahkampf mit Ungunst:** Steht ein Gegner nah (nach Abschnitt 1), schießt man mit Bogen, Armbrust oder Wurfwaffe mit Ungunst. Die Höhe rechnet Jerry mit 444; Vorschlag ist die übliche Ungunst (−25). Das ersetzt Regel 7 in `DESIGN-KAMPF.md` („aus dem Handgemenge … ohne Strafe in Kapitel 1“).
- **Waffe wechseln** bleibt klein und frei, einmal je Zug (`DESIGN-GLUT.md` Regel 10). Wer Bogen und Nahwaffe trägt, wechselt also, wenn der Gegner heran ist, oder auf dem Weg heran. Das ist die taktische Wahl, die der Chef meint.
- **Wer keine Nahwaffe hat,** kämpft mit Faustkampf oder schießt mit Ungunst. Prüfen muss Jerry mit 444, ob das Jägerkind allein damit noch durchkommt (der Grund, warum Regel 7 die Strafe einst verwarf). Wenn nicht, bekommt es eine Nahwaffe zum Start, etwa ein Jagdmesser; den Text liefert Homer.
- Dasselbe gilt für Gegner: Ein Fernkämpfer, der heranrückende Nahkämpfer nah hat, schießt mit Ungunst. Darum weicht er zurück (Abschnitt 4). Der Goblin-Späher hat keine Nahwaffe, der Schamane nur den Stab.

## 2. Denkweise (entschieden: Chef 17.11., 21:56, „Ja, vier Denkweisen passen.“)

Jede Gegnerart hat eine von vier Denkweisen, passend zu ihrem Gegenwert:

| Denkweise | Wer | Kennzeichen |
|---|---|---|
| **Instinkt** | Tiere | greift an, was nah oder schwach ist; flieht als Rudel |
| **List** | Goblins, Kobold | nutzt Lücken, sucht den Schwächsten, bleibt nicht ehrlich stehen |
| **Stur** | Untote | geht stur auf den Nächsten los, weicht nie, wird nie müde |
| **Plan** | Bosse | folgt einer festen, lesbaren Reihenfolge |

## 3. Ziel (entschieden: Chef 17.11., 21:58, „Ja, passt so.“)

- **Instinkt:** der Nächste, bei gleichem Abstand der Verwundete.
- **List:** der Schwächste oder einer hinten, aber nur, wenn der Weg frei ist. Sonst der Nächste.
- **Stur:** der Nächste.
- **Plan:** die Reihenfolge des Bosses.
- Das Ziel wird zu Beginn jedes Zugs neu gewählt. Der Gegner bleibt beim bisherigen Ziel, solange kein anderes deutlich besser passt. Ohne diese Trägheit springen die Ziele hin und her.
- **Versperren** in der Arena ist eine echte Wahl: Wer vorn steht, deckt die hinteren. Ein listiger Gegner kommt an ihnen nur vorbei, wenn eine Lücke frei ist.

## 4. Rolle im Kampf

Die Denkweise sagt, was ein Gegner will. Die Rolle sagt, wo er steht und wie er kämpft (Chefwort 17:45: Nahkampf, Fernkampf, Rudel, Zauber, Boss).

- **Nahkampf:** rückt heran und bleibt im Handgemenge. Steht er vorn, bleibt er vorn.
- **Fernkampf:** bleibt fern oder weit. Kommt ihm ein Nahkämpfer nah, weicht er einen Schritt zurück, solange hinter ihm Platz ist. Danach schießt er (Späher: „Schuss 1, Schritt zurück 1“). Ein Fernkämpfer rennt nie selbst ins Handgemenge.
- **Rudel:** handelt als Gruppe. Einer greift an, die anderen stellen sich um den Helden (Einkreisen, Flanke). Steht ein Anführer, folgt das Rudel ihm.
- **Zauber:** steht hinten, stärkt oder heilt andere und greift selbst nur schwach an. Nahkämpfer müssen an der Reihe vorbei (Schamane).
- **Boss:** 3 Kerben, ein Tun und eine Sonderregel. Der dritte Schlag ist offen angesagt („holt aus“).
- **Rollenwechsel:** Wer zwei Rollen hat (Riesenspinne: Netz, dann Biss), wechselt, sobald sein Ziel nah ist (Abschnitt 1) oder im Netz hängt (Jerry).

## 5. Bewegung

- **Vorn bleibt vorn** (Chef 17:45). Platztausch nur aus gutem Grund, etwa wenn ein hinterer Gegner einen großen Schlag hat, oder wenn der vordere wankt. Beim Platztausch gehen die Figuren nacheinander, nie ineinander; der hintere wartet seitlich, bis der Weg frei ist (Tom).
- Nach einem Angriff setzt sich der Gegner bis zwei Schritte rückwärts oder schräg rückwärts ab, mit dem Gesicht zum Helden (F7). Weitere Wege: auf der Stelle zum Weg drehen, vorwärts gehen, am Ziel zurückdrehen. Er zeigt nie den Rücken, außer auf der Flucht (Tom).
- **Ausnahmen** (Homer): Untote setzen sich nicht ab, sie bleiben stehen und drücken nach; nur der Wiedergänger weicht einen Schritt vor Weihwasser oder Licht. Krogg setzt sich nicht ab, er versperrt („an Krogg kommt keiner vorbei“, `[428.krogg]`).
- **Kein Seitwärtstraben** (Chef 17:45): Wege gehen auf dem kürzesten Weg durch die Arena, ohne Schienen und ohne Bogen. Ein Seitschritt nur als einzelner Ausweichschritt, wenn ein Vorderer Platz macht (Tom).
- **1526 geht hierin auf:** Ein vorderer Wolf, der für einen hinteren Platz macht, weicht nur auf den frei gewordenen Platz, nicht ganz nach hinten. Er läuft nicht als Nächster wieder ganz vor („ein bisschen sinnlos“, Chef 17.11., 08:12).
- **Takt:** Drehen und Absetzen fallen in die Takte der Handlung (F9), nicht davor; Maß ist die Runde des Wolfsrudels, 14,6 s (784 A).
- **Menschengestalten** brauchen dafür Rückwärtsgehen gerade und schräg sowie den Seitschritt aus dem gekauften Paket UAL2 (Tom). Tiere und Untiere prüft Jerry mit ihren eigenen Bewegungen.

## 6. Flucht (entschieden: Chef 17.11., 22:03; Lohn A 22:33)

- **Selten und lesbar.** Ein Rudel flieht, wenn der Anführer gefallen ist und die Hälfte besiegt ist. Bei Grimmzahn gilt außerdem: Fällt er unter die Hälfte, flieht das Rudel vor Feuer (915). **Fällt Grak, fliehen die Goblins** wie das Rudel ohne Grimmzahn (Homer, `[428.goblin]`). Ein Goblin oder Kobold flieht, wenn er allein übrig ist und weniger als ¼ Leben hat. Die letzte Riesenratte flieht, sobald sie verwundet ist („Allein ist sie feige“, `[428.ratte]`). **Untote, Säureschnecke und Bosse fliehen nie.**
- **Ablauf** (wie in `DESIGN-KAMPF.md`, Chef 14:23): Der Gegner sagt die Flucht einen Zug vorher an und ist nach seinem nächsten Zug fort. Bis dahin treffen ihn Schuss und Zauber von überall. Ein Nahkämpfer erreicht ihn nur, wenn sein Weg für Weg und Schlag reicht. Steht der Fliehende nah, setzt der Held nach.
- **Lohn A:** Flieht ein Gegner von selbst, gibt es die volle Erfahrung und die halbe Beute; der Kampf zählt als gewonnen, wer ihn festhält, bekommt alles. Das ersetzt „Beute weg“ in `DESIGN-KAMPF.md`, Zeile 119. **Wer Gegner mit Feuer vertreibt, bekommt weder Beute noch Erfahrung,** wie entschieden (870c 3 A, 915): der Preis des Feuers. Den Unterschied zeigen eigene Ansage und Kampfzeile (705a B).
- **Ansagen und Lohnzeile:** `STORY-BRS-KAMPF.md`, Abschnitt „Flucht und Absprache der Gegner“, Marken `[1601.…]` (Homer 1601).

## 7. Absprache

- Höchstens **eine angesagte Absprache je Begegnung**, etwa „Der Schamane sammelt Kraft für den Goblin“ oder „Das Rudel kreist dich ein“. Sie steht in der Ansage, bevor sie wirkt.
- Gemischte Begegnungen (Wolf mit Späher, Kobold mit Schamane) folgen `DESIGN-GLUT.md` Regel 22: zwei Rezepte, die sich widersprechen, damit der Spieler wählen muss.
- Begründung: Mehr als eine Absprache ist nicht mehr lesbar, und der Kampf wird zum Raten.
- Ansagen: `STORY-BRS-KAMPF.md`, Marken `[1601.absprache.…]` (Schamane heilt oder stärkt, je nach Bau; Kobolde erst mit der Kür). „Einkreisen“ hat schon eine Ansage (`[986.circle.tip]`).
- Neue Absprachen über Einkreisen und Kraft sammeln hinaus sind Kür, später (Perikles).

## 8. Fairness (fasst Entschiedenes zusammen)

- Jeder große Schlag ist angesagt und hat den Ring (1048 A). **Nie ein unangesagter großer Schlag.**
- Wie genau der Spieler die Absicht liest, hängt von der Lesestufe ab (1288b).
- Täuschen nur auf drei Arten, wie entschieden. Der Hinterhalt mit dem Rücken (1532) ist die angesagte Ausnahme beim Überfall.
- Eine Flucht des Helden steht immer zur Wahl, gelingt aber nicht sicher, nie vor einem Boss (Chef 12:56).

## 9. Je Art (Grundlage Tabelle „Gegner im Glutsystem“ in `DESIGN-AKTIONSPUNKTE.md`; mit `werte.json` abgleichen, Lücken als Einzelvorgang, Perikles)

| Art | Denkweise | Rolle | Besonderheit (Bestand) |
|---|---|---|---|
| Riesenratte | Instinkt | Nahkampf, zu dritt Rudel | viele kleine Bisse, zu dritt Gunst |
| Wolf | Instinkt | Rudel | Anspringen; setzt nach, wenn du dich löst |
| Grimmzahn | Plan | Boss, Anführer Rudel | hetzt, Umreißen, Einkreisen |
| Wildschwein | Instinkt | Nahkampf | Ansturm aus fern oder weit |
| Riesen-Hundertfüßer | Instinkt | Nahkampf | Panzer, Wucht bricht ihn |
| Riesenspinne | Instinkt | Fernkampf (Netz), dann Nahkampf | Netz zieht heran, Gift sammeln |
| Riesenfledermaus | Instinkt | Nahkampf, flatternd | beißt und löst sich |
| Blutflügler, Riesenegel | Instinkt | Nahkampf | saugt sich fest |
| Goblin | List | Nahkampf | Schwerer Hieb nur in Graks Nähe |
| Goblin-Späher | List | Fernkampf | Anlegen, Schritt zurück |
| Kobold | List | Rudel | lauert mit dem Speer; allein feige, im Rudel stärker (`[428.kobold]`) |
| Goblin-Schamane | List | Zauber | Wundsegen, Kraft sammeln |
| Wiedergänger | Stur | Nahkampf | nie zurückgedrängt, nie müde, ruft Nachschub; weicht vor Weihwasser oder Licht |
| Skelett | Stur | Nahkampf | – |
| Grabhund | Stur | Nahkampf | Ziel: der Gelähmte zuerst (`[428.ghul]`) |
| Säureschnecke | Stur | Nahkampf | flieht nie; spuckt auf Abstand |
| Krogg | Plan | Boss | Prankenhieb mit 3 Kerben, angesagt |
| Hauptmann Grak | Plan | Boss | stärker neben Verbündeten |

Die Reihenfolge der Bosse (Abschnitt 3, „Plan“) legt Jerry beim Bau mit Homer fest. Grimmzahn bleibt ein Wolf in Bild und Ansage (heult, fletscht, duckt sich), nie ein Stratege; dass er zu klug kämpft, ist der Hinweis auf die roten Augen (Homer). Zahlen kommen aus der Rechnung 444, nicht aus dem Gefühl. Kür, nur wenn der Bau es leicht hergibt: Wildschwein geht auf den, der es zuletzt getroffen hat; Riesenfledermaus auf den, der sich zuletzt bewegt hat (Homer).

**Abgleich (Perikles, 17.11., 22:39):** Die Spalte „Besonderheit (Bestand)“ stammt aus dem Kerbensystem. Im Spiel (MARS ohne Kerben) fehlen Prankenhieb (Krogg), Umreißen (Grimmzahn), Ansturm (Wildschwein), Rudel (Kobold), Säure auf Abstand (Säureschnecke), Nachschub (Wiedergänger) und die eigenen Absichten des Schamanen; Lücken in 1603, Felder Denkweise und Rolle in 1589.2.

## 10. Kamera (nicht Teil dieses Blatts)

- Der Chef möchte den Kampf mit wechselndem Blickwinkel aufpeppen (11.11., 20:11; 17.11., 16:07). Heute gibt es im Kampfort kein Drehen, nur den Zoom beim Schlag (`kampfort.gd` 654–682).
- Die Kamera bleibt ein eigenes großes Vorhaben (1402): erst eine Vorlage, dann das Gespräch, erst dann Code. Weil die Regeln in der Arena gelten (Abschnitt 1), hängt dieses Regelblatt nicht von ihr ab.

## 11. Bau (Perikles 22:15, entschieden mit 1589.1 A)

Je Stufe ein Vorgang mit eigenem Build, ab Sa 21.11., 20:00 (vorher Stillstand, 1594); nichts davon in Build 299.
1. **Arena unsichtbar** (Jerry): `regeln/arena.gd` mit Punkt, Umriss, Reichweite; Abstand abgeleitet (Abschnitt 1); Zielwahl je Denkweise mit Trägheit und Versperren (Strecken-Kreis-Prüfung); Flucht; Ungunst der Fernwaffe im Nahkampf (1a); Rechnung 444 lernt die Arena in derselben Stufe. Prüfbar mit Logiktest gegen die heutigen Wege.
2. **Bewegung Menschengestalten** (Tom, neben Stufe 1): Rückwärtsgehen gerade und schräg, Seitschritt aus UAL2, einmal gebaut für Welt und Kampf.
3. **Figuren in die Arena** (Jerry): `figur.gd` geht nur noch die Wege der Arena, mit Beinarbeit Bewegung nach Abschnitt 5 mit 1526 und den Ausnahmen; alte Regeln im Bild raus; Messtests 438, 709 neu; Film.
4. **Reihenfolge der Bosse** (Jerry mit Homer): Grimmzahn, Krogg, Grak.

Nicht auf die Arena warten 760 (Wolf springt beim Anspringen) und 1068 (Ring bei großen Schlägen): beide in den nächsten Build, mit Stufe 3 neu messen. 1532 (Hinterhalt mit dem Rücken) bleibt eigene Kür.

## Ergänzungen (Gegenlesen 17.11., eingearbeitet oben)

(je Rolle ein Absatz mit Name und Zeit)

**Tom (17.11., 22:08), zu Abschnitt 5, nur Menschengestalten** (Held, Gefährten, Söldner und wer sonst auf dem Kaufkörper steht; Tiere und Untiere prüft Jerry mit ihren eigenen Bewegungen). Nachgesehen in `godot/daten/bewegungen.bin` und den gekauften Bewegungspaketen (UAL1, UAL2 im Kaufrepo).
1. **„Absetzen rückwärts, Gesicht zum Helden“ fehlt als Bewegung.** Unsere Figuren haben nur Gehen und Rennen vorwärts (je Waffenart), Drehen 90 Grad und seit 1406 Drehen 180 Grad in einem Zug. Rückwärts hieße heute: Gehen rückwärts abgespielt, die Füße laufen falsch. Die UAL2 (gekauft, gleiches Gerüst) hat Rückwärtsgehen gerade und schräg links und rechts (`Walk_Bwd_Loop`, `Walk_Bwd_L/R_Loop`) und Seitschritte (`Walk_L/R_Loop`). Einbau wie bei 1406 im Klassenbau, eine Bewegung für alle Menschengestalten. Ohne sie gilt Abschnitt 5 für Menschen nicht.
2. **Vorschlag zur Regel:** Absetzen bis 2 Felder rückwärts oder schräg rückwärts, das Gesicht bleibt zum Gegner. Weitere Wege: auf der Stelle zum Weg drehen, vorwärts gehen, am Ziel zurückdrehen. Seitschritt nur als ein einzelner Ausweichschritt, wenn ein Vorderer Platz macht (1526). So bleibt „kein Seitwärtstraben“ und trotzdem nie der Rücken zum Gegner.
3. **Drehen kostet Zeit:** 90 Grad etwa 2 s, 180 Grad etwa 1,3 bis 1,7 s im heutigen Tempo der Leute. Im Kampf muss das Drehen in den Takt der Handlung fallen (F9) und schneller laufen, sonst wird der Zug zäh. Frage an Jerry: Wie lang darf ein Zug dauern?
4. **Platztausch:** Gleichzeitig aneinander vorbei gleiten die Figuren heute ineinander, in der Welt (691, ruht) wie im Kampfort (`figur.gd`, 438/562). Vorschlag: nacheinander, der hintere wartet seitlich, bis der Weg frei ist.
5. **Leute in der Welt** berührt das Blatt nicht; Drehen 180 Grad (1406) und Rückwärtsgehen nutzen aber beide denselben Bau, also einmal bauen für Welt und Kampf.

**Jerry (17.11., 22:08), Bau in `mars.gd`:**
- **Heute gibt es kein Blatt.** `mars.gd` kennt je Seite nur vier Plätze (vorn und hinten, je zwei; `SPOTS`, Zeile 118), das Kerbensystem drei Abstände je Gegner (nah, fern, weit; `kerbe.gd` 17–19). Wo eine Figur im Raum steht und wie sie geht, entscheiden `figur.gd` (Heimweg, Rückwärtsgehen, Gesicht zum Gegner, 1809–2100) und `kampfort.gd` im Bild. Genau das verbietet Abschnitt 1. Das Blatt ist also ein neuer Baustein, kein Umbau einer Stelle.
- **So würde ich bauen:** eine eigene Datei `regeln/blatt.gd`. Darin hat jede Figur einen Punkt (x, y in Metern), einen Umriss als Kreis (aus den Maßen, die `figur.gd` schon misst: `body_r`, `vorne`) und je Angriff eine Reichweite. `mars.gd` fragt das Blatt. Platz und Abstand (nah, fern, weit) werden daraus abgeleitet, die Regeln aus `DESIGN-GLUT.md` bleiben. `figur.gd` geht nur noch den Weg, den das Blatt vorgibt; die Einzelregeln fallen weg. Zuerst läuft das Blatt unsichtbar mit und misst gegen die heutigen Wege, erst dann wird umgeschaltet.
- **Was fehlt:** (1) Reichweite je Angriff als Feld in `werte.json`. (2) Umriss je Art, gemessen an den Modellen. (3) Prüfung, ob ein Weg einen anderen Umriss schneidet, für Versperren und Lücke; bei höchstens acht Figuren reicht eine einfache Strecken-Kreis-Prüfung. (4) Eine Zahl für „deutlich besser“ bei der Trägheit (Abschnitt 3), etwa 1 m näher oder ein Viertel weniger Leben. (5) Ansagen für Flucht und Absprache (Homer). (6) Die Rechnung 444 muss das Blatt kennen; heute rechnet sie nur nah, fern, weit. Sonst gibt es wieder zwei Wahrheiten: bei 1486 rechnete `sim.py` Teil 2 ganz anders als `handgemenge.py`.
- **Zwei Stellen im Text:** Abschnitt 4 (Boss: 3 Kerben) und 9 (Krogg: Prankenhieb mit 3 Kerben) setzen das Kerbensystem voraus. Das ist im Spiel heute aus (nur in Proben an, `probe.gd` `kerbe_an`). Das Blatt muss auch im MARS ohne Kerben gelten, oder das Kerbensystem kommt vorher ins Spiel; das wäre eine eigene Entscheidung. Bei der Riesenspinne (erst Fernkampf, dann Nahkampf) fehlt eine Regel, wann die Rolle wechselt.
- **Kosten grob, in Sitzungen:** Blatt mit Ableitung von Platz und Abstand 2–3; Denkweise, Ziel und Trägheit 1; Rolle und Bewegung (vorn bleibt vorn, Absetzen, Fernkämpfer weicht, Rudel kreist ein) 2–3; Flucht 1; `figur.gd` aufs Blatt umstellen und die alten Regeln entfernen, mit Filmen, 2–3; Messtests neu auf dem Blatt (438, 709) 1–2; Rechnung 444 1. Zusammen etwa 10–13. Gebaute Muss wie 709, 760 und 1588 gehen darin auf und werden neu geprüft.
- **Stärkstes Gegenargument:** Das ist ein großer Umbau vor dem Ende von Kapitel 1. Ein kleinerer Weg wären Abschnitt 3 und 5 auf den heutigen vier Plätzen (Ziel, Trägheit, vorn bleibt vorn, 1526), etwa 2–3 Sitzungen. Er behebt, was der Chef gesehen hat, aber nicht die Ursache (Regeln im Bild). Mein Votum: das Blatt, in der Reihenfolge oben; der kleine Weg nur, wenn Perikles für Kapitel 1 die Zeit nicht hat.
- **Zu Toms Frage 3:** Maß ist die Runde des Wolfsrudels, 14,6 s (784 A); gemessen waren zuletzt 31,8–34,1 s (1415). Drehen und Absetzen müssen also in die Takte der Handlung fallen, nicht davor.

**Homer (17.11., 22:14), Story, Stil, Spielgefühl.** Gelesen gegen `LISTE-BESTIARIUM.md` (Arten, Gegenwirkung, Hintergrund 428, freigegeben) und `STORY-BRS-KAMPF.md` (Ansagen, 915, 986).
1. **Arten fehlen in Abschnitt 9:** Skelett, Grabhund, Säureschnecke (in Kapitel 1, Nachfolger gelten seit 03.11.). Vorschlag: Skelett Stur, Nahkampf. Grabhund Stur, Nahkampf, Ausnahme beim Ziel: geht auf den Gelähmten („Wer gelähmt am Boden liegt, ist für ihn schon tot“, `[428.ghul]`). Säureschnecke Stur, Nahkampf, flieht nie; Schleim hat sonst keine Denkweise.
2. **Kobold ist Rudel, nicht Nahkampf:** Bestiarium „Rudel (stärker in der Gruppe)“, `[428.kobold]` „Allein sind sie feige, im Rudel beißen sie zu“. Flucht wie Goblin (allein übrig).
3. **Riesenratte flieht nach Abschnitt 6 nie,** weil Ratten keinen Anführer haben, obwohl `[428.ratte]` „Allein ist sie feige, zu dritt dreist“ sagt. Vorschlag: die letzte Ratte flieht, sobald sie verwundet ist.
4. **Stur und Abschnitt 5 widersprechen sich:** „Nach einem Angriff setzt er sich ein bis zwei Schritte ab“ passt nicht zu Untoten („weicht nie“). Vorschlag: Untote bleiben nach dem Schlag stehen und drücken nach. Einzige lesbare Ausnahme: der Wiedergänger weicht einen Schritt vor Weihwasser oder Licht („Weihwasser fürchtet er mehr als jede Klinge“, `[428.wiedergaenger]`). Ebenso Krogg: er setzt sich nicht ab, er versperrt („an Krogg kommt keiner vorbei“, `[428.krogg]`); das ist Abschnitt 3 „Versperren“ von der Gegnerseite.
5. **Grak und die Goblins** (Story, Vorschlag): „sie gehorchen dem, der am härtesten zuschlägt“ (`[428.goblin]`). Fällt Grak, fliehen die übrigen Goblins wie das Rudel ohne Grimmzahn. Spiegelt den Wolfskampf und erzählt den Stamm ohne Worte.
6. **Grimmzahn als „Plan“ ist richtig und trägt Story:** ein Wolf, der zu klug kämpft, ist der Hinweis auf seine roten Augen. Die Ansagen bleiben Wolfsbilder (heult, fletscht, duckt sich), nie Worte eines Strategen; nichts erklärt ihn (Roter Faden, offene Fäden).
7. **Widerspruch Lohn bei Flucht:** Abschnitt 6 (volle EP, halbe Beute) ersetzt nur `DESIGN-KAMPF.md` 119. Entschieden und gebaut gilt noch 915: vor dem Feuer geflohene Wölfe bringen weder Beute noch Erfahrung (Bestiarium Zeile 49, `STORY-BRS-KAMPF.md` 51). Beim Entscheid ausdrücklich nennen, ob 915 mit fällt; dann ändere ich die Texte.
8. **Kür, nur wenn der Bau es leicht hergibt** (Instinkt mit Eigenart, lesbar aus dem Hintergrund): Wildschwein geht auf den, der es zuletzt getroffen hat („geht jedem aus dem Weg, der es in Ruhe lässt“). Riesenfledermaus auf den, der sich zuletzt bewegt hat („hört jeden Schritt“).
9. **Stil der Ansagen:** Figur beim Namen, nie „dich“ (Gefährten und Söldner stehen mit im Kampf); keine Zahlen; „Einkreisen“ hat schon eine Ansage (`[986.circle.tip]`), keine zweite. Im Spieltext nie „Tun“.
10. **Ansagen, Entwurf** (Marken und Endfassung mit dem Bau, Vorgang an Homer):
   - Flucht angesagt: {0} weicht zurück und sucht einen Ausweg. / EN: {0} backs away, looking for a way out.
   - Flucht gelungen: {0} ist fort. / EN: {0} is gone. (Nicht „ist entkommen!“, das ist die Flucht des Helden, `[870.14.flucht]`.)
   - Festgehalten: {0} kommt nicht mehr weg. / EN: {0} can't get away now.
   - Rudel ohne Anführer: Das Rudel zerstreut sich zwischen den Bäumen. / EN: The pack scatters among the trees.
   - Goblins ohne Grak: Die Goblins sehen ihren Hauptmann fallen und laufen. / EN: The goblins see their captain fall, and run.
   - Absprache Schamane: {0} raunt seinen Knochen etwas zu. {1} schlägt gleich härter zu. / EN: {0} mutters to his bones. {1} is about to strike harder.
   - Absprache Kobolde: Die Kobolde zischen einander zu und rücken zusammen. / EN: The kobolds hiss to each other and close ranks.

**Perikles (17.11., 22:15; 1598, Umfang, Vorrang, Reihenfolge; Kosten nach Jerry).**
- **Build 299:** nichts aus diesem Blatt. Entscheid erst nach allen vier Gegenlesungen, Bau ab Mi 13:00 zu, ab Do ≈ 10:00 Stillstand bis Sa 20:00 (1594). Bau 1589 beginnt realistisch Sa 20:00.
- **Zu Jerrys Frage, Blatt oder kleiner Weg:** das Blatt. Für Kapitel 1 gibt es keinen Termin (Oberste Direktive), der Grundsatz in Abschnitt 1 ist Chefwort (18:15). Der kleine Weg (2–3 Sitzungen) behebt das Gesehene im Bild und würde nach dem Blatt ein zweites Mal gebaut (Bekannte Fehler 302.3). Stärkstes Gegenargument: 10–13 Sitzungen bei Jerry, der schon die meisten Muss trägt, und der Chef sieht lange nichts Neues. Entkräftet durch Stufen mit je eigenem Build und Tom am Bewegungsteil (unten).
- **Muss für Kapitel 1** (jeder Gegner von Kapitel 1 ist betroffen), in dieser Reihenfolge, je Stufe ein Vorgang (1589.2 …, nach dem Entscheid): (1) `blatt.gd` läuft unsichtbar mit, dazu Zielwahl je Denkweise mit Trägheit und Versperren (3) und Flucht (6). Heute wählt `announce` das Ziel zufällig aus der vorderen Reihe (`dice.pick`), also prüfbar mit Logiktest, ohne Film; Rechnung 444 lernt das Blatt in derselben Stufe, sonst zwei Wahrheiten. (2) Rückwärtsgehen und Seitschritt für Menschengestalten aus UAL2 (Tom, Punkt 1), **neben** Stufe 1, weil Stufe 3 sonst wartet. (3) `figur.gd` aufs Blatt, Bewegung (5) mit 1526 und Homers Ausnahme für Untote und Krogg (Punkt 4), alte Regeln raus, mit Film; Messtests 438, 709 neu. (4) Reihenfolge der Bosse Grimmzahn, Krogg, Grak (Plan), Jerry mit Homer. Homers fehlende Arten (Punkt 1) gehören in Tabelle 9 vor dem Entscheid, nicht in den Bau.
- **Abgleich statt Neubau:** Rollen (4) und Tabelle 9 gegen `werte.json`, Lücken als Einzelvorgang; Fairness (8) ist Entschiedenes, der Bau steckt in 1068.
- **Später (Kür):** neue Absprachen (7) über Einkreisen und Kraft sammeln hinaus, Homers Eigenarten (Punkt 8); 1532 Hinterhalt mit dem Rücken bleibt eigene Kür und geht nicht in 1589 auf, sonst trägt ein Muss eine Kür; Kamera (10) bleibt 1402.
- **Nicht koppeln:** Das Blatt gilt im MARS ohne Kerben (Jerry, Punkt 4). Ob das Kerbensystem ins Spiel kommt, ist ein eigener Entscheid; „3 Kerben“ in Abschnitt 4 und 9 bis dahin als „großer Schlag, angesagt“ lesen.
- **Was nicht auf das Blatt wartet:** 760 ist gebaut, 1068 hängt nur an Abschnitt 8. Beide nach dem Entscheid in den nächsten Build, mit Stufe 3 neu messen, statt Wochen hinter 1589 zu liegen.
- **Widersprüche:** (1) Lohn bei Flucht gegen 915 und 870c 3 A wie Homer, Punkt 7; dazu im Code `mars.gd` 343, Text 42 und 2656. (2) Die Zeile 1589 nennt „1561 geht darin auf“; 1561 ist ein erledigtes Wiederholrot (Technik), vermutlich falsche Nummer.
