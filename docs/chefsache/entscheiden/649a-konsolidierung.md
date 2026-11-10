# 649a · Figuren und Gegenstände je an einer Stelle: in dieser Reihenfolge konsolidieren?
Sokrates · 10.11., 11:04 · E Technik · aus deinem Wort 10:56 („jetzt wirklich mal konsolidieren an einer Stelle … vorher prüfen lassen“)
Kurz: Helfer prüfte den Plan 649 gegen den Code: tragfähig mit Änderungen; fünf Schritte, Netze zum Gegenstandskatalog, ab sofort keine neuen Werte im Code

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/ac11c5cd8 (Befund im Wortlaut: `LISTE-FIGURENKATALOG-649.md`, „Zweite Prüfung“)

**Frage:** Du willst, dass alles zu einer Figur (Werte, Aussehen, 3D-Modell, Klänge, Bewegungen) und alles zu einem Gegenstand (Form, Material, Preis) je an genau einer Stelle steht: als Tabelle, die das Spiel liest, und eine Seite zum Nachschlagen, die daraus erzeugt wird. Ein Helfer hat den Plan geprüft. Heute stehen die Monsterwerte an vier Stellen, die Gegenstandswerte an drei, das 3D-Modell je Monster an sechs. Daran hängen 16 Spielskripte, 31 Tests, drei Bauabläufe, mehrere Werkzeuge und ein Haken. Soll in dieser Reihenfolge konsolidiert werden?

**Votum:** „649a A“: fünf Schritte nacheinander, ab sofort keine neuen Werte je Art im Programmcode.

**Berührt:** 649, 649.1–649.4 (Jerry, Tom), 458.3 Gegenstandskatalog (Tom), Stufe 2.3 Kampf auf BRS (Jerry), Homer (Aussehen bleibt sein Text), Ford (alte Zweige von Jerry aufräumen)

**Begründung:** Dein Wort 10:56: „wir sollten das jetzt wirklich mal konsolidieren an einer Stelle. Weil ich glaube, es wird dann auch für die Zukunft etwas einfacher“; „bevor wir jetzt hier irgendwas machen, prüfen lassen“; „vielleicht hängen ja da auch wieder Helfer und Tools und Haken … dran“. Der Helfer fand genau das: Wird alles auf einmal zusammengelegt, ändern sich still die Werte von Jungwolf und Leibwache, denn der Kampf rechnet heute aus beiden Tabellen. Eine erzeugte Seite ohne Prüfung im Bau veraltet: Die Gegenstandsseite ist schon heute falsch (88 statt 90 Einträge).

**Sachverhalt:**
- Monsterwerte: neue BRS-Tabelle (`werte.json`), alte SRD-Tabelle (`tabellen.json`, der Kampf liest noch Abweichungen daraus, `brs_kampf.gd` 102–113), Begegnungen aus der Kotlin-Fassung, Gruppen fest im Code (`aufruf.gd`, `streuner.gd`).
- Gegenstände: `gegenstaende.json` (90), dazu Waffen und Rüstungen in `werte.json`, 12 alte in `tabellen.json`.
- 3D-Modell je Monster: Bauzeilen in zwei Abläufen, `aufruf.gd`, `figur.gd`, Info-Dateien, Blender-Skript.
- `LISTE-NETZE.md` sind die Formen der Ausrüstung, gehört zum Gegenstandskatalog (458), nicht zu den Figuren.
- Jerry baut gerade weiter neue Werte je Art in den Code (Zweig 595: `ZUNGE`, `TURN_DPS_ART`); acht seiner Zweige ändern dieselben Dateien.
- Mehrere Tests laufen in keinem Ablauf oder schlagen bei Fehlern nicht durch (Liste im Befund).

**Auswertung:**
- **A (Empfehlung):** fünf Schritte, jeder ein Vorgang:
  - (0) jetzt: die Prüfung „Seite passt zur Tabelle“ in den Bau, Gegenstandsseite richtigstellen, die stillen Tests scharf schalten (Tom);
  - (1) eine Namenstabelle je Art, also Kennung, Körper, Gruppe, Felle, Modell, statt der Listen im Code; nur Namen, keine Werte (Jerry, nach Zusammenführung oder Aufgabe seiner offenen Zweige);
  - (2) die Werte von alt auf BRS in eine Tabelle, zusammen mit Stufe 2.3 (Kampf auf BRS), weil das Balance ist (Jerry);
  - (3) Seiten erzeugen: Figuren, Gegenstände samt Netzen (458.3); das Aussehen bleibt Homers Text und wird verlinkt (Tom, Jerry);
  - (4) Bewohner, Händler, Lehrmeister (649.3, Tom).
  - Ab sofort gilt eine Regel: neue Werte je Art nur in die Tabelle, nicht als Konstante in den Code.
  - Kosten: etwa 5–7 Entwicklersitzungen über die nächsten Wochen. Schritt 0 und 1 passen neben den Kampf.
- **B:** alles jetzt in einem Zug (649.1–649.4, 458.3). Schneller fertig, aber es kreuzt acht Zweige von Jerry und den laufenden Kampf, und die stillen Werteänderungen fängt kein Test.
- **C:** alles erst nach Kapitel 1. Kein Konflikt, aber bis dahin wachsen die Stellen weiter.
- **Stärkstes Gegenargument gegen A:** Bis Schritt 2 stehen die Werte weiter an zwei Stellen, und das kann Wochen dauern. Dagegen: Schritt 2 ist ohnehin Teil des Kampfs auf BRS (2.3, Wochenziel). Die neue Regel verhindert, dass es mehr wird.

**Folgerungen:** Ich lege die Vorgänge für Schritt 0 bis 4 an, mit „Zu“ und dem Befund. Perikles ordnet sie in den Vorrang. Ford klärt mit Jerry, welche alten Zweige aufgegeben sind. Die Regel „keine Werte je Art im Code“ geht an Perikles für `ROLLE-ENTWICKLUNG.md` und ersetzt dort eine alte Regel. 649 bleibt bei mir, bis Schritt 4 fertig ist.

Antwort: …
