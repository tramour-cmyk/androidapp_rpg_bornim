# 512a · Abgleichsfunde, die das BRS ohnehin ändert: jetzt nach alten Regeln bauen oder bis 478 zurückstellen?
Sokrates · 04.11., 00:14 · E Kampf, A Spiel · berührt 512, 535, 543, 478

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/4f9ca1dce (Code von Build 249, Abgleich gelesen)

**Frage:** Sollen 535 (Gegnerstufe, Elite, Gruppen, EP und Gold je Gegner) und 543 (Startgold, Start-Tränke, Wiederkehrort, Beutestufe) bis zum BRS-Rechenkern (478) zurückgestellt werden?

**Votum:** Ja, zurückstellen. Sofort bauen nur, was das Durchspielen verhindert oder klar falsch ist: 537 Kapitelende, 532 Zauber kosten nichts, 548 Kampf läuft von selbst, 533 Grimmzahn.

**Berührt:** 535, 543 (Jerry, Tom); 478 (ruht bis nach dem Durchspielen, Wochenziel 03.–08.11.).

**Begründung:** Laut Wochenziel rechnet der Kampf im Durchspiel-Build noch nach dem alten Regelwerk; 478 und danach 2.3 stellen Stufen, Werte, EP und Startausstattung auf das BRS um (470a C, Chef 02.11., 17:59). Was jetzt nach den alten Regeln nachgebaut wird, ist dann zum Teil doppelte Arbeit.

**Sachverhalt:** Abgleich 512 (Code von Build 249 gegen die alte Fassung, 03.11., 23:4x): neu läuft jeder Kampf über MARS mit festen Werten aus `tabellen.json`; Gegner wachsen nicht mit, EP nur für den Anführer, Startgold fehlt.

**Auswertung, stärkstes Gegenargument:** Beim ersten Durchspielen fühlt sich der Kampf ohne mitwachsende Gegner und mit wenig EP anders an als später; dein Urteil über Kampf und Grinden gilt dann nur bedingt. Dagegen: das gilt ohnehin, weil 2.3 die Zahlen ändert (so steht es im Wochenziel); die Fehler, die das Durchspielen verhindern, werden trotzdem jetzt behoben.

**Folgerungen:** bei Ja: 535 und 543 auf „ruht: bis 478“, ihre Befunde gehen in 478 und 2.3 ein. Bei Nein: beide bleiben startbar und werden nach den alten Regeln gebaut.

**Zu sagen:** „512a ja“ oder „512a nein“.

Erledigt: Antwort ins Vorgangsarchiv, Datei löschen (Sokrates).
