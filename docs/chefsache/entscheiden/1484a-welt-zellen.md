# 1484a · Darf Spike die Welt in Zellen teilen und die Durchsicht der Bäume nur noch nahe am Helden rechnen lassen, damit Wald und Dorf auf dem Tablet schneller laufen?
Spike · 17.11., 22:12 · E Technik · Auswertung deiner Tablet-Messung 17.11., 21:29–21:31 (Vorgangsarchiv „1484 gemessen“: Spike schlägt den Weg mit Kosten vor)
Kurz: Die Welt ist ein einziges großes Netz, das in jedem Bild ganz gezeichnet wird. Teilen in Zellen und die Durchsicht nur nahe am Helden sparen das Meiste; das Aussehen bleibt gleich.
Beim Chef, weil: Code auf `main` (Prüfart: Messung am Tablet mit demselben Gerätetext an denselben Stellen)

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/6661a205c (Messskript `godot/tests/welt_mess_1484.gd`, am Rechner im Renderer des Handys)

**Frage:** Auf dem Tablet läuft der Kampf mit Grafikstufe Niedrig jetzt mit 25 Bildern/s, die Welt bleibt bei 10 (Flüsterwald) bis 22 (Wald 11/19). Keiner der vier Testschalter hilft spürbar, Schatten aus nur etwa 12 %. Ich schlage einen Umbau vor, der das Aussehen nicht ändert: die Welt in Stücke von etwa 12 m teilen, damit Godot nur zeichnet, was im Bild ist, und die zwei Zusatz-Durchgänge der Durchsicht (Bäume werden um den Helden herum durchsichtig) nur an den Stücken nahe am Helden laufen lassen statt an allen Bäumen der Karte.

**Votum:** „1484a A“: Spike baut beides in einen Testbuild; du misst auf dem Tablet wieder an denselben Stellen (Wald 11/19, Flüsterwald), mit „Kopieren“.

**Berührt:** Werkzeug für den Modellbau (`tools/blender348/v3/dorf.py`), Durchsicht (`gebiet.gd`), alle Gebiete draußen (Dorf, Wald, Tiefer Wald); Team Tom (Dorf) nur für die Abnahme, dass alles gleich aussieht.

**Begründung:** Zielbild „ohne technische Fehler“ (Oberste Direktive). 10 Bilder/s im Wald sind ein technischer Fehler. Ein Bau ohne Messung wäre geraten, darum erst die Messung am Rechner, dann der Vorschlag.

**Sachverhalt:**
- Tablet (`LISTE-TESTGERAETE.md`, Galaxy Tab A9+): Kampf 25 Bilder/s, 153 Tsd. Dreiecke. Welt 10 Bilder/s, 2,7 Mio. Dreiecke, Grafikzeit 99 ms; Schatten aus halbiert die Dreiecke (1,4 Mio.) und spart 12 ms.
- Dorf und Wald sind je **ein** Netz `Dorf_Netz` (Wald 444 Tsd. Dreiecke, 13 Stoffe). Davon ist nur 7 % (Dorf) bzw. 22 % (Wald) im Bild. Godot muss aber alles zeichnen, weil es ein einziges Netz nicht teilweise weglassen kann. Gemessen am 16.11.: Zellen von 12 m sparen 54 % (Dorf) bzw. 57 % (Wald) der gezeichneten Dreiecke.
- Neu heute am Rechner (Wald an der Stelle 9/12,, Grafikzeit; der Rechner zeichnet ohne Grafikkarte, darum zählen nur die Anteile): ohne das große Netz −64 %, ohne Schatten −34 %. Das Laub allein (193 Tsd. Dreiecke) kostet −25 %. Die zwei Zusatz-Durchgänge der Durchsicht an Laub und Rinde (6 Stoffe, die ganze Karte) kosten −16 %. Gras −5 %, Tusche −3 %.
- Die Durchsicht braucht nur die Bäume zwischen Kamera und Held; heute laufen ihre Durchgänge an allen Bäumen der Karte (`gebiet.gd`, `durchsicht`).

**Auswertung:**
- **A (Empfehlung):** Zellen von 12 m im Modellbau, Durchsicht-Durchgänge nur an den Zellen um den Helden. Kosten: etwa eine Sitzung, ein Modellbau im Lauf (etwa 40 Minuten), ein Testbuild, eine Messung von dir. Erwartung: am Tablet deutlich weniger gezeichnete Dreiecke (Hälfte oder weniger) und die Durchsicht nur noch an wenigen Bäumen. Wie viele Bilder/s das bringt, zeigt erst das Tablet; ich verspreche keine Zahl.
- **B:** nur die Durchsicht nahe am Helden, ohne Zellen. Kosten: eine halbe Sitzung, kein Modellbau. Spart am Rechner etwa 16 %, auf dem Tablet wohl weniger; das große Netz bleibt.
- **C:** Weniger Laub auf Niedrig (weniger Blätter je Baum). Billig, ändert aber das Aussehen, darum nur auf dein Wort.
- **Stärkstes Gegenargument gegen A:** Am Tablet senkte „Schatten aus“ die Dreiecke um die Hälfte, die Zeit aber nur um 12 %. Vielleicht liegt das Tablet also nicht an den Dreiecken, und die Zellen helfen dort weniger als am Rechner. Gegen diesen Einwand spricht: Kampf (wenig Dreiecke) 25 Bilder/s, Welt (viele) 10, bei gleicher Grafikstufe und gleichem Bildschirm. Zellen kosten außerdem etwa 40–60 Zeichenaufrufe mehr je Durchgang (heute 400–460, im Kampf 195).

**Folgerungen:** Bei A baut Spike im Zweig, Modellbau im Lauf, Testbuild mit Prüfpunkt „Wald 11/19 und Flüsterwald messen, Kopieren“. Dorf und Wald sehen gleich aus; das prüfe ich an Bildern alt gegen neu, bevor der Build zu dir geht.

Antwort: …
