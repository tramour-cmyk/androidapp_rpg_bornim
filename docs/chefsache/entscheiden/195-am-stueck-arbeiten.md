# 195 · Am Stück arbeiten statt ein Punkt je Stunde
Sokrates · 19.10., 08:4x · B Steuerung · Umsetzung Perikles (`tools/weiter-haken.py`, mit 192.3)

Kurz: eine Sitzung, die fertig ist, aber im eigenen Vorrat noch startbares Muss hat, hört heute auf; der Nächste kommt erst mit Fords Stundenlauf

**Frage** (Chef 19.10., 08:47, Wortlaut, gesprochen): „Oder mal Perikles Liste an. … Da macht Perikles eins. Ändern die anderen auch noch erledigt oder warten wir nach jeder einzelnen erledigt, Sitzung wieder darauf? Das Wort nach einer Stunde feststellt, oh, da ist ja noch was. Dann starten wir wieder. Also läuft das am Rutsch dann endlich mal durch. Oder ein Ding pro Stunde.“

Dazu (Chef 19.10., 08:48, Wortlaut, gesprochen): „… einen Hook oder was auch immer, der Wert dass wenn ich mit irgendeinem von euch in der Sitzung bin, und wir haben ein Thema bearbeitet und sind eigentlich fertig, dass dann noch geprüft wird, hey, ist schon irgendwas Neues in meinem Vorrat gekommen? Muss ich was tun? Weil jetzt habe ich gerade mit Pericles gequatscht und habe meine Frage beantwortet und jetzt macht er wieder nichts. Aber der hat ja den Vorrat“

**Befund:** Heute eher ein Ding pro Stunde. „Perikles – 190.9“ lief 08:04–08:06 (0,21 $) und hörte auf; seitdem keine Perikles-Sitzung, obwohl 8 Muss offen sind (D31.1–D31.3, 190.10, 190.8, 191, 192, 165), alle im selben Bereich (`startbar.py`, `lauf.py`). Regel 99h („kleine Punkte im selben Bereich mitnehmen“) wird zu eng gelesen, und der Weiter-Haken prüft nur die Übergabe, nicht den Vorrat.

**Empfehlung: ja.** Der Weiter-Haken (`tools/weiter-haken.py`, gibt es schon) holt beim Zugende `main` (damit Neues im Vorrat sichtbar wird) und ruft `startbar.py` für die eigene Rolle. Steht dort noch ein startbares Muss und hat der Neustart-Haken noch nicht zum zweiten Mal erinnert, hält er die Sitzung einmal an: „weiter mit <Nr.>“. Sie arbeitet die Zeilen nacheinander ab, bis kein Muss mehr startbar ist oder der Kontext für einen Neustart zu groß wird; erst dann Übergabe und Nachfolger. Das gilt bei jedem Zugende, also auch nach einem Gespräch mit dir: Frage beantwortet → Haken sieht offenes Muss → die Sitzung macht weiter. Keine neue Regel: CLAUDE.md 1 „eine Sitzung, ein Punkt“ wird zu „eine Sitzung, ein Bereich, solange Muss da ist“ (ersetzt den Satz, Regelbilanz gleich).

**Stärkstes Gegenargument:** lange Sitzungen werden je Schritt teurer (jeder Schritt liest den ganzen Verlauf), und eine Sitzung, die drei Dinge baut, vermischt sie leichter. Dagegen: die Grenze bleibt der Neustart-Haken (100.000 Token Zuwachs), danach frischer Start; ein Start kostet je Mal etwa 0,2–0,5 $ und bis zu einer Stunde Wartezeit, die heute bei jedem Punkt anfällt. Bei Teams gilt es nur, solange das nächste Muss keinen eigenen Build mit Test braucht (ein Build je Sitzung bleibt).

**Berührt:** CLAUDE.md „Wie wir zusammenarbeiten“ 1, 99h, 190.7, 192.3, `tools/weiter-haken.py`, `tools/startbar.py`.
