# 99 · Kosten der Leitung: Sparvorschläge jetzt, Ford 2 nach neuer Messung
Perikles · 17.10., 09:3x · Vorgang 99 (99h; berührt 99f, 124, 128)
Kurz: Ford 2 kostete am 16.10. etwa 20 % von Jerry (Grenze 10 %); vier Sparvorschläge jetzt, neue Messung Ford 2 und Ford 20.–21.10.

**Auftrag** (Chef 17.10., 09:2x): „Fords Kostenanteil an Zentrale analog zu Vorgang 99 messen. 99 nochmal bei Normalbetrieb durchführen. Kostensparvorschläge ermitteln und vorschlagen“

**Frage.** Sollen die vier Sparvorschläge unten jetzt gelten? Über Ford 2 entscheidest du nach der neuen Messung (Ergebnis hier am 22.10.).

**Bisherige Zahlen** (Vorwerte, beide aus untypischen Tagen):

| | Leitung | Arbeit | Anteil |
|---|---|---|---|
| Ford 2 an Jerry, 16.10., 06:46–20:34 (über 20 Neustarts Jerry) | 24,1 $ | 98,4 $ gemessen, mit 8 nicht messbaren Sitzungen etwa 128 $ | 19–25 % |
| Ford an Zentrale, 16.10., 22:2x – 17.10., 09:10 (Sparmodus, Nacht) | 13,7 $ | 30,3 $ | etwa 45 % |

**Messung 20.10., 00:00 – 21.10., 24:00** (Normalbetrieb: Max frisch, Jerry wieder da). Ford und Ford 2 tragen beim eigenen Neustart und am Ende der Messung ihre `cost_usd` in die Zeile „Betrieb“ von `LISTE-VORGAENGE.md`, getrennt nach Ford und Ford 2; die Arbeit steht schon dort je Vorgang (124). Perikles wertet am 22.10. aus.

**Woher die Kosten kommen.** Jeder Stundenlauf liest den ganzen bisherigen Kontext neu, auch ohne Tat. Ford 2 mit 356 Tsd. Token kostete 9,20 $ in 5 Stunden, mit 150 Tsd. etwa halb so viel je Stunde. Dazu liest jede neue Sitzung ihre Startdateien; ein Punkt von 4 Minuten kostete so 1,62 $.

**Sparvorschläge**

1. **Uhr aus, wenn nichts zu tun ist.** Ford 2 schaltet seine Stundenuhr ab, solange Jerry „Pause bis …“ hat (jetzt bis Mo 19.10., 21:00), und stellt sie per einmaliger Aufgabe zum Pausenende wieder an. Ebenso Ford nachts, wenn kein Vorrat startbar ist; die Ford-Wache bleibt. Spart ab sofort etwa 50 Läufe bis Montag.
2. **Kurzer Kontext.** Ford und Ford 2 starten sich bei etwa 150 Tsd. Token neu statt bei 220–350 Tsd. Ein Lauf ohne Tat liest nur die Kopfzeilen, kein `get_session` aller Sitzungen.
3. **Kleine Punkte bündeln.** Punkte unter etwa 15 Minuten (Text, Zeile nachtragen, „nach main“) nimmt die laufende Sitzung des Bereichs mit, statt dafür eine neue zu starten. Ändert „Eine Sitzung, ein Punkt“ für diese Fälle (90a: ersetzt nichts, darum erst zur Bilanz am 23.10., wenn du willst früher).
4. **Ford 2 entfällt,** wenn die neue Messung über 10 % liegt (99f): Jerry startet seinen Nachfolger dann selbst über eine einmalige geplante Aufgabe in 2 Minuten (`LISTE-RELEASE-NEUSTART.md` „Neustart“ 4; liegt nicht tiefer, keine Grenze bei Tiefe 6); steht Jerry, sagt Ford es dir einmal.

Geprüft und verworfen: ein billigeres Modell für Ford. Die Regeln sind dicht, Fehler kosten Neustarts und deine Zeit; erst prüfen, wenn 1 und 2 nicht reichen.

**Stärkstes Gegenargument.** Weniger Läufe und weniger Kontext heißen: Ford merkt später, wenn etwas steht, und weiß weniger aus früheren Läufen. Am 16.10. stand Jerry 3 Stunden im Sitzungslimit; mit Uhr aus in Pausen wäre das nicht schlimmer geworden, mit selbststartendem Jerry ohne Aufpasser vielleicht schon. Und Messungen kosten selbst Guthaben und Aufmerksamkeit: zwei Tage reichen, dann entscheiden.

Antwort z. B. „99 1–3 ja“, „99 1 und 2 ja, 3 noch nicht“ oder „99 noch nicht“.
