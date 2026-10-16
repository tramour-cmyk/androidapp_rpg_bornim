# 128 · Kennzahl Stillstand wegen Guthaben, und Guthaben einteilen?

Sokrates Projekt · 16.10., 20:45 · Anlass Chef 16.10., 20:4x (Bild Niederlassung: Sitzungslimit 100 %, zurück in 2 Std. 36 Min.; wöchentlich 49 %, zurück Fr., 03:00): „Ein KPI sollte auch sein, wie oft der Betrieb nicht arbeitet“ und „Oder wie lange er still steht, aber nicht weil keine Arbeit da ist, sondern weil keiner bezahlt wird“

Kurz: Stillstand je Account nach Ursache zählen (Ford trägt es ohnehin ein); Pro ist nach einem Tag bei 49 % der Woche: einteilen, sonst ab etwa So kein Jerry bis Fr.

**Befund:** Die Niederlassung stand heute zweimal wegen des Sitzungslimits (Läufe 16:33 und 17:33 in der Sperre; jetzt bis etwa 23:30). Ernster ist die Woche: 49 % nach rund 18 Stunden (Woche seit Fr. 03:00). In diesem Tempo ist das Guthaben von Pro am Sonntag aufgebraucht, und Jerry steht bis Fr. 23.10.; Tom übernimmt dann (118), auf Kosten von Max.

**Frage:** Kennzahl so einführen und Pro einteilen?

**Empfehlung:** Ja.
1. **Kennzahl „Stillstand“** in Stunden je Woche und Account, nach Ursache getrennt: *Guthaben* (Sitzungs- oder Wochenlimit), *wartet auf Chef* (Test, Entscheidung), *keine Arbeit* (Vorrat leer), *Fehler* (Ford steht, Sitzung hängt). Nur *Guthaben* und *Fehler* sind schlecht für den Betrieb; *wartet auf Chef* zeigt deinen Engpass. Ford und Ford 2 schreiben bei jedem Stundenlauf ohnehin „Jerry: läuft/steht“; es kommt nur die Ursache dazu. Auswertung mit 124 im Wochenrückblick.
2. **Gegenstück „Auslastung“:** Anteil des Wochenguthabens, der am Ende der Woche verbraucht ist; Ziel nahe 100 %, aber gleichmäßig. Ein Sitzungslimit am Abend ist harmlos; ein leeres Wochenguthaben nach zwei Tagen kostet fünf Tage.
3. **Einteilen:** Ford 2 startet Jerry nur, solange der Wochenverbrauch höchstens dem Anteil der verstrichenen Woche plus 10 % entspricht (heute Abend: etwa 21 % erlaubt, 49 % verbraucht → Pause bis Montag früh). Gleiches für Max mit Ford. Kein neuer Schritt: Ford 2 liest `rate_limit_info` schon.

**Stärkstes Gegenargument:** Einteilen heißt, Jerry jetzt anzuhalten, obwohl er könnte; die Arbeit kommt nicht schneller, nur gleichmäßiger, und dein Testvorrat (sechs Builds) reicht ohnehin für Tage. Genau deshalb kostet die Pause jetzt wenig. Zweites: Der Prozentwert ist nur auf deinem Bildschirm genau; Ford 2 sieht nur „allowed_warning“. Dann braucht es einmal am Tag eine Zahl von dir oder eine grobe Schätzung aus den Sitzungskosten (124).
