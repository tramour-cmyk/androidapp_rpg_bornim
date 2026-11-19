# 1727 · Ablauftabelle: wer macht was, wann geht es weiter, wer erfährt es wie

Auftrag Chef 19.11., 20:38. Gilt für jeden Vorgang; Beispiel: `durchlauf-zwerg.md`, Muster `vorgang/9001.md`. Fristen aus Grobablauf 14.2 (Annahmen bis zur Probewoche). „Weckt sofort“ ist Vorschlag aus Lücke 2 des Durchlaufs (nicht entschieden); bis dahin wartet jeder Schritt auf den Stundentakt des Büros.

| Nr. | Stand (Vorgang / Auftrag) | wer bewegt | tut | Werkzeug | wer erfährt es, wie | weiter, sobald | Frist; wenn nichts passiert |
|---|---|---|---|---|---|---|---|
| A1 | Wort des Chefs | Sokrates | Wortlaut mit Zeit in den Eingang; Entscheid ins Vorgangsarchiv; Idee in die Ideenliste | Edit, `git push` | Chef: eine Zeile im Chat; Büro: liest den Eingang beim Weckruf (Vorschlag: `send_message` weckt sofort) | eingetragen | in derselben Antwort |
| A2 | Fund eines Machers oder Prüfers außerhalb des Auftrags | Macher, Prüfer | meldet ans Büro, behebt nicht | Rückmeldung (`send_message`) | Büro | gemeldet | sofort; ohne Nummer nimmt das Büro ihn nicht an |
| A3 | Eingang → **neu** | Büro | Abgleich; bestehender Vorgang oder neuer mit Bezug, Block, Klasse; Vorgangsdatei mit Chefwort | `vorgang.py` | – | Vorgang angelegt | 1 Tag; Tagesbericht „ohne Auftrag“ |
| A4 | neu → **Auftrag offen** | Arbeitsvorbereitung (vom Büro gestartet) | schreibt Auftrag; Ursache unbekannt → Nachstellen; Geschmack → Varianten; Frage an den Chef → an Sokrates statt Auftrag | `lauf.py` startet, `vorgang.py auftrag` | Büro: Rückmeldung „fertig“ | Auftrag steht | nach Reihenfolge (Eilt 2 h, Muss 1 Tag, Kür 2 Tage) |
| A5 | Auftrag offen → **in Arbeit** | Büro | startet Macher (oder derselbe Macher macht weiter) | `lauf.py` | – | Macher läuft | nach Reihenfolge |
| A6 | in Arbeit → **beim Prüfer** | Macher | baut im Zweig, beantwortet die Prüffragen, meldet mit Commit und Beleg | Git, Rückmeldung | Büro | „fertig“ mit Beleg; ohne Beleg nimmt das Büro nicht an | Höchstdauer und -kosten je Auftrag; Abbruch → zurück auf „offen“, ein Neustart, beim zweiten Mal „steckt fest“ |
| A7 | beim Prüfer → **angenommen** oder **abgelehnt** | Prüfer (vom Büro gestartet) | prüft nach den Prüffragen; Nachstellen: nur den Beleg | `lauf.py` startet; Ergebnis in den Auftrag (Werkzeug) | Büro | Urteil | 1 Tag; sonst neuer Prüfer |
| A8 | abgelehnt, 1. Mal | Büro | zurück an denselben Macher: erst Ursache nachstellen | `lauf.py` | Macher | – | wie A6 |
| A9 | abgelehnt, 2. Mal → **steckt fest** | Sokrates mit Arbeitsvorbereitung | Auftrag, Profil oder Ursache falsch? neuer Auftrag an frischen Macher, sonst Chefsache | – | Chef nur, wenn er entscheiden muss (Chefsache, Telegram) | neuer Auftrag | 48 h; dann Chefsache von selbst |
| A10 | angenommen, Nachstellen | Büro | nächster Auftrag (Bauen) | `lauf.py` startet Arbeitsvorbereitung | – | wie A4 | wie A4 |
| A11 | angenommen, Bauen → **Warteschlange Build** | Büro | merkt für den nächsten Build vor | `lauf.py` | – | Build beginnt | Grobablauf 3.19.1: Werkzeug löst aus bei 5 abgenommenen Vorgängen, ältestem über 2 Tage, abgenommenem Fund des Chefs, „Eilt“ oder Wort „Build“ (Teil der Richtung 13:02, nicht einzeln entschieden) |
| A12 | Warteschlange → **im Build** | Macher mit Profil Build (vom Büro gestartet) | Testbuild aus allen vorgemerkten Zweigen | `lauf.py`, GitHub-Lauf | Büro; bei rotem Lauf: Büro, ab 3 in der Stunde laut an den Chef | Build grün | Build-Lauf; rot → zurück ans Büro, zweites Mal Sokrates |
| A13 | im Build → **Chef testet** | Büro | schickt Link und Prüfpunkte (gesammelt aus den Prüffragen der Aufträge) | `meldung.sh` (Telegram) | **Chef** | gesendet | 5 Tage Erinnerung im Tagesbericht; nach 14 Tagen „ruht“ mit Datum |
| A14 | Chef testet → **erledigt** | Chef, dann Sokrates, dann Büro | „gut“: Sokrates trägt Wortlaut ins Archiv; Macher Build bringt nach `main`; Büro schließt „erledigt“ | Archiv, Git, `vorgang.py schliessen` | Chef: Vollzug per Telegram | geschlossen | nächster Weckruf |
| A15 | Chef testet → **Auftrag offen** (Nachbessern) | Chef, Sokrates, Büro | „nein“: Wortlaut ins Archiv und in die Vorgangsdatei; Runde +1; Arbeitsvorbereitung schreibt Nachbessern | wie A4 | – | wie A4 | wie A4 |
| A16 | **ruht** | Büro | nur mit Datum und Grund; am Datum zurück auf den letzten Stand | `vorgang.py` lehnt „ruht“ ohne Datum ab | – | Datum erreicht | Pflichtdatum |
| A17 | **verworfen, doppelt, überholt** | Büro auf Wort von Chef oder Sokrates | schließen mit Grund (bei doppelt und überholt mit Ersatznummer) | `vorgang.py schliessen` | – | – | – |
| A18 | Herzschlag | GitHub-Lauf (kostet keine Token) | prüft, ob `lauf.py` in den letzten 2 h lief | GitHub Actions | Chef per Telegram, wenn nicht | – | 2 h |
