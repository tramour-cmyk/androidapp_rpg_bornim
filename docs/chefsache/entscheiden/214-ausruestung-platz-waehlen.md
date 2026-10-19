# 214 · Ausrüstung: Tippen auf einen Platz bietet passende Teile aus dem Beutel an?
Sokrates · 19.10., 13:20 · G Bedienung · K (Bau Tom, ein Sammelbuild)

Chef 13:18: „Wenn ein Slot leer ist und ich klicke, dann wird leer angezeigt. Wäre es eine Idee, wenn dann passende Ausrüstungsteile aus dem Beutel angezeigt würden zur Auswahl?“

**Heute** (nachgesehen in `MenuScreen.kt`, `GearTab`): Tippen auf einen leeren Platz zeigt nur die Meldung „Kopf: leer“. Ein besetzter Platz bietet nur „Ablegen“ an. Anlegen geht nur über den Reiter „Tasche“: dort durch die ganze Liste scrollen, das Teil suchen, antippen, „Anlegen“.

**Frage:** Bauen wir das Auswählen am Platz?

**Vorschlag:**
- **Leerer Platz:** Tippen öffnet eine Liste der Teile im Beutel, die auf diesen Platz passen. Sie ist sortiert wie die Tasche und zeigt dieselben Zeilen mit dem Vergleich. Antippen und „Anlegen“ funktionieren wie heute.
- **Fackel und Nebenhand:** Am Platz Nebenhand stehen Schild, Fackel und Einhandwaffen in der Liste.
- **Was nicht passt:** Teile, die der Held nicht tragen kann, stehen gedämpft in der Liste, mit Grund. Passt gar nichts, steht dort „Nichts Passendes im Beutel“.
- **Besetzter Platz:** Neben „Ablegen“ gibt es den Knopf „Wechseln“, der dieselbe Liste öffnet.

**Empfehlung: ja, als Kür bei Tom, nach seinen laufenden Muss.** Das ist in Rollenspielen üblich und spart je Wechsel drei bis vier Schritte. Es hilft gerade bei Fackel und Schild, die man nachts tauscht (84.1). Es ist außerdem billig: Wir brauchen kein neues Bild, und Zeilen, Vergleich und Anlegen gibt es schon. Damit dient es der obersten Direktive (179, spielerfreundlich).

*Stärkstes Gegenargument:* Es ist neu und kein Fehler, und vor dem Meilenstein geht Fehlerbehebung vor (179). Jedes neue Fenster ist ein weiterer Prüfpunkt für dich. Die Tasche leistet das Anlegen schon heute. Darum soll es Kür bleiben und nicht vor ein Muss rutschen.

**Berührt:** 84.1 (Fackel in der Nebenhand), 213 (Testreiter-Fackeln), Reiter Tasche (`MenuScreen.kt`).
