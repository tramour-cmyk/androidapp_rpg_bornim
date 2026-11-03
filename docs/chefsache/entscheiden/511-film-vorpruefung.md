# 511 · Kein Filmlauf mehr ohne geprüftes Probebild vorher?
Sokrates · 03.11., 13:50 · B Werkzeuge · berührt A Abläufe, beide Teams

Kurz: Heute sind 6 von 6 Film-Vorgängen der Teams kaputt beim Chef angekommen; Ursache ist immer dieselbe: erst nach dem teuren Lauf hingesehen.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/chefsache/ansehen/4062a-rennen.md

**Frage:** Gilt ab sofort: Ein Filmlauf startet erst, wenn ein Probebild aus derselben Szene und demselben Filmskript vorliegt und ein Helfer bestätigt hat, dass alles Genannte zu sehen ist?

**Votum:** „511 ja“. Bis die Sperre im Werkzeug steht, starten Jerry und Spike keinen Filmlauf; die offenen Fragen 494a und 509a gelten erst mit Probebild.

**Berührt:** Jerry, Spike/Tom (alle Filmläufe), Perikles (Ablauf, Regel „höchstens zwei Läufe“ 389, 407), 494a, 509a, 506, 406.2a, 416.6, 510.

**Sachverhalt (03.11., Vorlagen in der Chefsache):**

| Vorgang | Läufe | Was beim Chef ankam | Ursache |
|---|---|---|---|
| 494 Gegner | 2 | kein Film | Bau des Hundertfüßers: Datei gepackt, Skript suchte ausgepackt |
| 509 Teich | 2 | 29 s Logo und Hauptmenü | Filmskript schließt das Menü nicht |
| 416.6 Staub | 2 | Held geht statt rennt, ein Wölkchen | Fehler 416.4 noch nicht im Bau |
| 506 Skelette | 2 | Skelette unsichtbar, nur Schatten | offen |
| 406.2a Rennen | 2 | Wolf schwarzer Umriss, keine Waffe sichtbar | Vermutung Tuschemaske, offen |
| 510 Fledermaus | 1 | freies Modell leer | Umwandlung gab leere Datei aus |

Gemessen hat jeder Lauf „grün“: Tests und Messungen sahen Frösche, Skelette, Waffen, weil sie Daten prüfen, nicht das Bild. Erst der Prüfer am fertigen Film sah, dass nichts zu sehen ist.

**Vorschlag:**
1. Vor jedem Filmlauf ein Probebild (ein Einzelbild) mit demselben Filmskript und derselben Szene; ein Helfer prüft gegen die Liste „was muss zu sehen sein“ (Figur, Waffe, Gegner, kein Menü).
2. Fehlt etwas: Ursache nachstellen, kein Lauf.
3. Ein kaputter Film geht nicht als Film an den Chef, sondern als eine Zeile; die Läufe zählen trotzdem.
4. Werkzeug: `probelauf.py` startet einen Filmlauf nur mit Verweis auf ein geprüftes Probebild (Bau Perikles).

**Stärkstes Gegenargument:** Das Probebild entsteht womöglich nicht unter denselben Bedingungen wie der Lauf (Rechner gegen Bauserver, verschlüsselte Kaufmodelle), dann prüft es das Falsche und kostet trotzdem Zeit. **Entkräftet:** Das Probebild kommt aus demselben Filmskript; wo es nur auf dem Bauserver geht, ist das Probebild der erste Schritt des Laufs, der abbricht, bevor gefilmt und gesendet wird. Drei der sechs Fehler (Menü, leeres Modell, schwarze Figuren) hätte ein einziges Bild gezeigt.

**Folgerungen:** Bei „ja“: Sperre sofort für alle Filmläufe; Perikles baut die Prüfung in `probelauf.py`; 494a, 509a erst mit Probebild. Bei „nein“: wie bisher, zwei Läufe je Vorgang, Fehler nach dem Lauf.
