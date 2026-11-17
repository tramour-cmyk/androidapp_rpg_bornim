# Tom und Jerry · Build 298 · Sammelbuild: Neues Spiel nur BRS, Wiesen, Dorftiere, Mana nach dem Sieg, Bodenschatten, Höhlenwasser, Stäbe, Siegtafel
E Kampf · Jerry (Handy 1591, 1478, 1568, 1566, 1587; ohne dich 1541, 1319), Tom (Handy 1205, 1167), Spike (Handy 1567) · 17.11., 21:30

Gegengelesen: Sokrates, 17.11., 21:16, mit zwei Änderungen (Magier aus 298.1, 760 raus)

Verglichen (alt gegen neu): Stäbe gegen `core/art/Dress.kt` 728–783, 1455–1460 (Schaft, Knoten, Klauen, Kristall, Messingring); Bodenschatten gegen `core/art` (weicher Fleck ohne Fläche); Höhlenwasser gegen `MapCave` POOL_S/POOL_D; Wiesen und Dorftiere ohne Vorbild (Kotlin malte Blumen als Tupfen, Tiere als Bilder ohne Atem); Funde behoben. Umbau überall: der Bodenschatten ist einer für alle Figuren im Kampfort; das Wasser nur in der Höhle neu, im Wald unverändert; die Blumen des Kits in Dorf und Wald.

Sammelbuild aus `main` (nach t297) und den Zweigen `claude/jerry-1478-mana`, `-1319-geheilt`, `-1568-schatten`, `-1587-stab`, `-1541-brechen`, `-1566-hoehlenwasser`, `claude/tom-1167-tieratem`, `claude/tom-1205-wiese`, `claude/spike-1567-sieg-leben`. Nicht dabei: 760 (Wolfssprung, Halt des Chefs 17.11., 18:15 bis 1589.1; „760 rein“ holt ihn zurück), 385.2 (Feuer aus der Stabspitze, Film beim Chef), 1569 (Umhang, Bild 2 beim Chef). Toms 1417, 1515, 1535, 1549 sind seit t297 auf `main` (Bild 297.11 bei Tom).

Ein Weg: über Build 297 installieren. 298.1 bis 298.5 in einem neuen Spiel (Zauberlehrling) vom Dorf bis zum ersten Wolfskampf, danach 298.6 (Höhle), 298.7 und 298.8 im Probekampf Wölfe, 298.9 im Probekampf Ratten.

Im Bau geprüft: Mana nach dem Sieg + Wille / 2, aufgerundet, höchstens voll; Wundsegen gestreut 0,8–1,2 (1478, `mana_1478`); Netz der Riesenspinne bricht durch Feuer (1541, `kerbe_930` Regel 19); Siegtafel nach „Schnell“ (1567, `schnell_78510`); Logiksatz 193 gut.

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 298.1 | Jerry | 1591 | Handy | Hauptmenü → Neues Spiel: Erschaffung mit Herkunft Zauberlehrling, dann durchs Dorf in den Wald bis zum ersten Wolfskampf und weiter zur Höhle; überall Texte, Werte und Menüs ansehen | nur BRS-Begriffe: Herkunft, Fertigkeiten, Leben, Mana, Schutzwert; nichts Altes zu sehen | irgendwo steht ein Klassenname (Kämpfer, Schurke, Kleriker), RK, ZP, Rettungswurf oder W20; Magier als Pfad und Magierstab sind richtig |
| 298.2 | Tom | 1205 | Handy | im Dorf aus 298.1 über die Wiesen gehen, dann im Wald über eine Blumenwiese | Gras in mehreren Büschelarten, Blumen des Kits (Margerite, Tulpe, Lavendel …) je Stück verschieden groß, im Dorf etwas kleiner als draußen; keine runden Farbkleckse mehr; das Bild läuft auf den Wiesen flüssig, ohne Ruckeln | Kleckse statt Blumen, alle Blumen gleich groß, oder das Bild ruckelt auf den Wiesen |
| 298.3 | Tom | 1167 | Handy | im Dorf nah an Rind und Ziege stehen bleiben und ein paar Sekunden zusehen | der Rücken hebt und senkt sich langsam, jedes Tier im eigenen Takt; Kopf und Beine bleiben ruhig | die Tiere stehen starr, oder Kopf und Beine zucken mit |
| 298.4 | Jerry | 1478 | Handy | im ersten Wolfskampf aus 298.1 einen Zauber wirken (Mana sinkt im Kasten des Helden), beim letzten Wolf den Wert merken; nach dem Sieg Menü → Held | Mana ist nach dem Sieg um die Hälfte des Willens höher (aufgerundet, beim Zauberlehrling 3), höchstens bis voll | Mana gleich wie am Ende des Kampfes, oder über dem Höchstwert |
| 298.5 | Jerry | 1568 | Handy | im selben Wolfskampf auf den Boden unter Wölfen und Held sehen | unter jeder Figur ein weicher, runder dunkler Fleck, der Boden daneben unverändert | ein rechteckiger dunkler Fleck unter den Figuren oder der ganze Kampfort abgedunkelt |
| 298.6 | Jerry | 1566 | Handy | Zeile 298.6 → „Lage herstellen“ (Höhle, Westflügel unten am Leuchtpilz, die hohe Wand zum Teich steht zwischen dir und dem Teich); drei Schritte nach rechts, dann an den Teich | hinter der Wand schimmert kein Wasser durch; am Teich ist das Wasser dunkel und nur im Licht der Pilze zu sehen | das Wasser leuchtet hinter der Wand oder im Dunkeln hell, ohne Licht in der Nähe |
| 298.7 | Jerry | 1587 | Handy | Zeile 298.7 → „Lage herstellen“ (Probekampf Wölfe, Testheld Zauberlehrling mit Magierstab); den Helden ansehen und einen Zauber wirken | der Held hält einen knorrigen Stab mit beiden Händen, oben ein Kristall in drei Klauen, der blau glimmt; der Zauber geht von der Spitze aus | kein Stab zu sehen, der Stab steckt im Körper, oder der Zauber kommt aus der Hand oder der Mitte |
| 298.8 | Jerry | 1587 | Handy | Zeile 298.8 → „Lage herstellen“ (wie 298.7, mit Zauberstab); den Helden ansehen und einen Zauber wirken | in der Haupthand ein kurzer Stab mit Messingring und Kugel, die Kugel glimmt blau; der Zauber geht von der Kugel aus | kein Stab zu sehen, oder der Zauber kommt aus der Hand |
| 298.9 | Spike | 1567 | Handy | Zeile 298.9 → „Lage herstellen“ (Probekampf Ratten); erst „Kämpfen“, einen Treffer nehmen, dann „Schnell ›“ unten links | Siegtafel „<Held> −n Leben“, n ist der ganze Verlust seit Kampfbeginn (Leiste vorher gegen nachher); wer nichts verlor, steht nicht da | „−0 Leben“, oder n kleiner als der Verlust |
| 298.10 | Jerry | 1541 | ohne dich (Test, die Riesenspinne hat noch kein Modell) | `kerbe_930` Regel 19: Feuer auf die Riesenspinne mit angesagtem Netz lässt es ins Leere gehen, die Seide verbrennt | Test grün | Test rot |
| 298.11 | Jerry | 1319 | ohne dich (Text von Homer) | Kampfmeldung beim Heilen „… fühlt sich wieder gesund.“ wie draußen; der Rausch bleibt | – | – |

## Lagen

- 298.6: station=Krogg ort=cave:2:11:RIGHT ruhig
- 298.7: probe=WOLVES herkunft=Zauberlehrling waffe=staff
- 298.8: probe=WOLVES herkunft=Zauberlehrling waffe=wand
- 298.9: probe=RATS
