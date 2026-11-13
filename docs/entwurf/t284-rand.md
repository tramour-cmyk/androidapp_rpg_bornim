# Tom und Jerry · Build 284 · Wege am Kartenrand, Zeichen für Schlecht, Probekampf allein · PR #203
E Welt · Tom (1022, 756.1), Jerry (947, 980, 987, 1126, 1127) · 13.11., 14:16 · APK folgt (Lauf ab 14:14)

Ein Weg: erst Build 283 testen; dann die APK aus dem Lauf über Build 283 installieren, App starten, Hauptmenü, „Weiter“ mit deinem Spielstand; Reiter „Test“ wie in 283. Zuerst die Bilder vom Kartenrand (284.1, 284.2, per Telegram, alt neben neu), am Handy die Tasche (284.3) und der Probekampf (284.4); der Rest ohne dich.

Verglichen (alt gegen neu): vom Bauenden gegen die alte Fassung: Kartenrand (`MapEdge.kt` CLOSE: alt endete der Weg an einer Baumreihe; jetzt läuft er gerade weiter und vergeht im Dunkel), Zeichen der Gegenstände (`GearUi.kt`, `ItemArt.kt`: alt keine Güte am Bild); Probekampf allein gegen Build 283 (dort stand der Söldner auf „wie der Held“).

Im Bau geprüft: kein Baum auf einem Weg am Rand, Wald daneben (`rand_1022`, alle drei Gebietskarten), roter Punkt an Schlecht, „Güte: Schlecht“ im Fenster, vier Güten nebeneinander (`sperre_756`), Probekampf ohne Söldner als Vorgabe und zuschaltbar (`probekampf_1020`), Krogg-Kampf mit festen Würfen (`krogg_494`).

| # | Team | Nr. | Art | Wo und wie | Passt | Falsch |
|---|---|---|---|---|---|---|
| 284.1 | Tom | 1022 | Bild | Dorf, Blick vom Helden den Weg entlang über den Kartenrand: Nord am Schlagbaum, Süd hinter der Brücke; links Build 283, rechts 284 | rechts läuft der Weg gerade weiter, links und rechts dichter Wald, bis er im Dunkel vergeht | der Weg endet und wird Wiese; ein Baum auf dem Weg; der Weg biegt ab |
| 284.2 | Tom | 1022 | Bild | Wald Süd (Weg ins Dorf), Wald Ost (Weg in den Tiefen Wald), Tiefer Wald West (Weg zurück in den Wald); links Build 283, rechts 284 | wie 284.1 | der Weg endet am Wald oder offen im Gras |
| 284.3 | Tom | 756.1 | Handy | Reiter „Test“ → unter „Beute erzeugen“ „Vier Güten“, dann Menü → Tasche; das Stück mit dem roten Punkt antippen | dieselbe Waffe viermal: oben links ein voller roter Punkt (hell wie das Rot der Leiste), keins, ein Goldpunkt, zwei Goldpunkte; das Fenster sagt „Güte: Schlecht“ | Punkt dunkel oder kaum vom Schwarz zu trennen; Ring statt Punkt; Fenster sagt „Güte: Normal“ |
| 284.4 | Jerry | 947 | Handy | Reiter „Test“ → „Probekampf“: unter „Söldner“ steht „keiner“; „Probekampf starten“ gegen Wölfe; danach „Söldner“ antippen bis „wie der Held“ und nochmal starten | erster Kampf: der Held allein; zweiter Kampf: ein Söldner derselben Herkunft an seiner Seite | Söldner im ersten Kampf; „Söldner“ lässt sich nicht umstellen |
| 284.5 | Jerry | 987 | ohne dich | `krogg_494` im Lauf der APK | grün | rot |
| 284.6 | Jerry | 980 | ohne dich | Lauf der APK, Block „kampf“ mit Kaufmodellen | Block gebaut, Spinne aus der Binär-FBX | Block bricht ab |
| 284.7 | Jerry | 1126, 1127 | ohne dich | Lauf der APK, Schritt „pruefen“/„holen“ der Kaufablage (Diogenes am Protokoll) | je Treffer „KAUF-CACHE gesichert …“, holen grün, keine Meldung „Ablegen misslungen“ nach gelungenem Ablegen | „Laden misslungen“; Fehlmeldung nach gelungenem Ablegen |
