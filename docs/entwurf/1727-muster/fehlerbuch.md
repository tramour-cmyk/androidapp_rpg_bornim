# 1727, Fehlersammlung: Rückläufer gesammelt auswerten (Fassung 2, Sokrates 21.11., 12:34, gegengeprüft)

Frage Chef 21.11., 12:29: „Wie halten wir denn die fehlerhaften Rückläufer nach? Gesammelt … was ist eine Fehlersammlung, dass wir darüber auswerten können? … Lessons learned wieder. Wie optimieren wir uns denn, wenn wir dann doch wieder bloß den Einzelfall beheben … Wenn wir keine klassische Fehlersammlung haben. Oder haben wir die?“

## Bestand (nachgesehen 12:30, gegengeprüft 12:31)

Gezählt wird, die **Ursache wird nirgends erfasst**:
- Zahl der Rückläufer je Build: Feld „(Rückläufer: n)“ in `CHANGELOG.md` (Regel 76f), „zurück t<n>“ und „Festgefahren“ von `vorgang.py build`, Marke „wiederholt“ im Titel (620.1 A), Spalte „Falsch“ der Prüflisten `ansehen/t<n>`, Zeilen „Erst der Chef am Gerät“ und „Testrunden, Rückläufer“ der Wochenzählung in `PRUEFBERICHT.md`.
- Funde des Chefs nur als Vorgangstitel (`tools/chef_fund.py` erkennt sie am Titel), Wortlaut als „Zu <Nr>“ im Vorrat.
- Lehren als „Fehler 341“-Zeilen in den Vorräten (Beratung 22, Betrieb 4, Projekt 4, Tagesbericht 2, Prüfung 1, Teams 0), teils mit Ursache und Lehre, ohne Auswertung.
Beleg der Lücke: die Auswertung 10:31 (20 Fälle mit Ursache) musste ein Helfer aus sechs Quellen zusammensuchen.

## Vorschlag (keine neue Datei)

1. **Zwei Felder an jeder Rückläufer-Zeile in der Vorgangsdatei**, die `vorgang.py` nach 3.3 ohnehin schreibt (Nein und „Beleg fehlt“ des Prüfers, Fund des Testers zu einem Vorgang, Fund des Chefs, auch nach dem Merge am alten Vorgang): **Ursache** aus fester Liste (Prüfteil des Auftrags · Regel fehlte · Regel nicht befolgt · Prüfung · Können/Technik · Übergabe · anderes · unklar), je Klasse ein Beispiel aus den 20 Fällen; **Abhilfe** (Einzelfix · Systemfix · Regel geändert: wo).
2. **Wer einteilt:** nicht die Fachkraft selbst (keine Selbstauskunft): beim Nein der Prüfer, beim Fund des Chefs oder Testers der Arbeitsplaner; Abhilfe beim Schließen der Zeile, „unklar“ erlaubt statt Füllwert.
3. **Auswerten:** ein Befehl (`vorgang.py fehler --woche`) liest alle Vorgangsdateien: je Ursache, je Profil, Wiederholungen. Die Routine Wochenzählung (6d) zählt daraus, und ihr **einziger** Vorschlagsweg wird: Häufung (dieselbe Ursache dreimal im selben Profil, oder zwei Wochen schlechter) → Vorschlag „Profil, Kern oder Auftragsvorlage ändern“ mit den Zeilen als Beleg; Sokrates legt vor. Das ergänzt die Zeile „Zusammenhänge“ (Büro-Gegenüberstellung F3) um die Ursache; der Wächter sucht dieselben Zeilen.
4. **Fällt dafür (Regelbilanz):** Feld „(Rückläufer: n)“ in `CHANGELOG.md` (zählt der Befehl), „Fehler 341“-Zeilen in den Vorräten (Vorfall als Zeile mit Ursache „Regel nicht befolgt“ in die Vorgangsdatei, Lehre ins Gedächtnis der Leitung), eigener Vorschlag „Bekannte Fehler“ in 6d (geht im Häufungsweg auf).
5. **Größe:** Profil Prüfer und Profil Arbeitsplaner je ein Satz, zusammen etwa 250 Byte; 6d ändert Zahl 1–3 auf die neue Quelle, etwa gleich groß. Werkzeug: Bauliste 7.1 (`vorgang.py`: Felder, `fehler`).

## Stärkstes Gegenargument

Eine Wochenauswertung mit Vorlage durch Sokrates nähert sich der Systemrunde, die der Chef am 20.11., 10:27 gestrichen hat („Ist implementiert und wahrscheinlich besser umgesetzt als nur einmal die Woche“). Abhilfe: kein Treffen und keine Runde; der Wächter schlägt je Fall sofort an, die Woche liefert nur die Zahl und den Vorschlag bei Häufung.

## Gegenprüfung 12:31 (frischer Helfer, 5 Befunde), mein Wort

1 Bestand: gezählt wird an mehr Stellen, nur die Ursache fehlt: **stimmt**, berichtigt · 2 Doppelung (Chefwort zweimal, 6d zählt dasselbe, zwei Vorschlagswege, Zusammenhänge, Regelbilanz unvollständig): **stimmt**, keine eigene Datei, ein Vorschlagsweg, Rückläufer-Feld fällt · 3 Nähe zur gestrichenen Systemrunde, Größe fehlte: **stimmt**, als Gegenargument und Größe · 4 Schreibweg (`schliessen`, Nein, Wächter fehlen; Fund nach Merge; Tester-Fund; zwei Schreiber): **stimmt**, Felder an der 3.3-Zeile, Bauliste; Tester-Fund zu einem Vorgang ist Rückläufer, nicht neuer Vorgang (6c nachziehen) · 5 Selbstauskunft und Füllwerte stärker; einfacher: zwei Felder plus Befehl: **stimmt**, übernommen.
