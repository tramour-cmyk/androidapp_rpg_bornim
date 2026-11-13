# Tom und Jerry · Build 284 · Wege am Kartenrand, Zeichen für Schlecht, Probekampf allein · PR #203
E Welt · Tom (1022, 756.1), Jerry (947, 980, 987, 1126, 1127) · 13.11., 14:12 · APK folgt (Lauf ab 14:09)

Drei Punkte zum Ansehen, weniger als vier: 756.1 ist „jetzt“ (Chef 13.11., 13:09); die übrigen vier Vorgänge sichert der Bau.

Ein Weg: erst Build 283 testen; dann die APK aus dem Lauf über Build 283 installieren, App starten, Hauptmenü, „Weiter“ mit deinem Spielstand; Reiter „Test“ wie in 283. Erst im Dorf an zwei Wegen zum Kartenrand (284.1, 284.2), dann die Tasche (284.3), über den Teleport im Reiter „Test“ Wald und Tiefer Wald (284.4, 284.5), zuletzt der Probekampf (284.6). Der Teleport lässt den Stand der Geschichte, wie er ist.

Verglichen (alt gegen neu): vom Bauenden gegen die alte Fassung: Kartenrand (`MapEdge.kt` CLOSE: alt endete der Weg an einer Baumreihe; jetzt läuft er gerade weiter und vergeht im Dunkel), Zeichen der Gegenstände (`GearUi.kt`, `ItemArt.kt`: alt keine Güte am Bild); Probekampf allein gegen Build 283 (dort stand der Söldner auf „wie der Held“).

Im Bau geprüft: kein Baum auf einem Weg am Rand, Wald daneben (`rand_1022`, alle drei Gebietskarten), roter Punkt an Schlecht, „Güte: Schlecht“ im Fenster, vier Güten nebeneinander (`sperre_756`), Probekampf ohne Söldner als Vorgabe und „wie der Held“ zuschaltbar (`testkampf_399`, `testmodus_399`, `probekampf_1020`), Krogg-Kampf mit festen Würfen ohne Zufall (987, `krogg_494`); Bauserver: Kaufmodelle nur aus der richtigen Datei (980), Ablage der Modelle bei gleichzeitigen Läufen (1126, 1127).

| # | Team | Nr. | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|
| 284.1 | Tom | 1022 | im Dorf am Tag nach Norden bis kurz vor den Schlagbaum gehen (nicht hindurch, sonst bist du im Wald), ganz hinauszoomen und über ihn hinaus auf den Weg sehen | der Weg läuft gerade weiter, links und rechts dichter Wald, bis er im Dunkel vergeht | der Weg endet und wird Wiese; ein Baum steht auf dem Weg; der Weg biegt ab |
| 284.2 | Tom | 1022 | im Dorf nach Süden über die Brücke gehen, bis der Held umkehrt („Erst willst du wissen …“), und nach Süden auf den Weg sehen | wie 284.1: gerader Weg, dichter Wald daneben, vergeht im Dunkel | der Weg endet am Wald |
| 284.3 | Tom | 756.1 | Reiter „Test“ → unter „Beute erzeugen“ „Vier Güten“, dann Menü → Tasche; das Stück mit dem roten Punkt antippen | dieselbe Waffe viermal: oben links ein voller roter Punkt (hell wie das Rot der Leiste), keins, ein Goldpunkt, zwei Goldpunkte; das Fenster sagt „Güte: Schlecht“ | Punkt dunkel oder kaum vom Schwarz zu trennen; Ring statt Punkt; Fenster sagt „Güte: Normal“ |
| 284.4 | Tom | 1022 | Reiter „Test“ → Teleport „Wald“; nach Süden gehen bis kurz vor den Weg ins Dorf, hinsehen; dann zum Ostrand, wo der Weg in den Tiefen Wald führt, kurz davor hinsehen (nicht hindurch, sonst wechselt die Karte) | jeder Weg läuft gerade weiter in den dichten Wald, bis er im Dunkel vergeht | Weg endet offen im Gras oder an einer Baumreihe |
| 284.5 | Tom | 1022 | Reiter „Test“ → Teleport „Tiefer Wald“ (du stehst am Westrand auf dem Weg zurück in den Wald); Kamera nach Westen drehen und auf den Weg sehen | wie 284.4 | wie 284.4 |
| 284.6 | Jerry | 947 | Reiter „Test“ → „Probekampf“: unter „Söldner“ steht „keiner“; „Probekampf starten“ gegen Wölfe; danach „Söldner“ antippen bis „wie der Held“ und nochmal starten | erster Kampf: der Held allein; zweiter Kampf: ein Söldner derselben Herkunft an seiner Seite | Söldner im ersten Kampf; „Söldner“ lässt sich nicht umstellen |
