# 621 · Wofür das Guthaben draufging, und was wir schlauer machen · Sokrates · 07.11., 16:4x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-VORGAENGE.md (Spalte Kosten, Stand 07.11. gegen 31.10., 20:25)

**Frage (Chef 07.11., 16:4x: „was war denn eigentlich konkret so teuer? … sind es diese 50.000 Builds … die 50.000 Bilder und Vorlagen und 8 Durchläufe für irgendwelchen Scheiß? Also was konkret können wir denn schlauer machen“):** Welche der vier Sparregeln A–D gelten ab der neuen Woche?

**Votum Sokrates:** A, B und D ja; C als Probe für eine Woche.

**Berührt:** 468 (Sparplan), 488 (Feinarbeit einfrieren), 389/407 (Probelauf-Grenze), 511, 512/512b, 620.2, `tools/lauf.py` (`MODELL`), Startzuordnung (Chef 17.10.).

## Sachverhalt

Gebucht in der Woche seit 31.10., 20:25: **2.594 $** (Gegenwert der Nutzung) auf 94 Vorgänge. `lauf.py` teilt die Kosten einer Sitzung gleich auf ihre Vorgänge auf; die Zahlen sind daher grob, die Verhältnisse stimmen.

| Art | $ | Anteil | Größte Posten |
|---|---|---|---|
| **Proben fürs Aussehen** (Bild- und Filmrunden für Figuren, Waffen, Stoff, Atmen, Effekte) | ≈ 1.356 | **52 %** | 417 Tragen 214 · 406 Ausrüstung 127 · 438 Wölfe gleitend 125 · 558 Robe 96 · 475 Gesichter 64 · 463 Umhang 56 · 431 Völker 50 · 415 Effektprobe 49 · 453 Wolfsruhe 48 |
| **Spielinhalt** (Orte, Gegner, Funktionen, Fehler aus deinen Tests) | ≈ 749 | 29 % | 494 Gegner 129 · 505 Nebel 69 · 490/491/492 Wald und Höhle 110 · 507 · 470 Erschaffung · 537 Kapitelende |
| **Abläufe, Prüfregeln, Betrieb** | ≈ 489 | 19 % | Ford 119 · 512b/512 Abgleich 132 · 348.12c Kaufvorschlag 44 · 407 Probelauf-Grenze 41 · 461b.4 Widersprüche 33 |

**Nicht teuer sind die Builds:** Sie laufen auf GitHub, das Repo ist öffentlich, die Minuten sind frei (109). Was kostet, ist die Sitzung, die Runde um Runde baut, rendert, misst und den Helfer Bilder prüfen lässt.

**Der Kern:** Mehr als die Hälfte ging in Aussehen-Proben, und vieles davon ist danach eingefroren oder überholt: 417 (214 $) durch 488 eingefroren, 463 ebenso, 438a ruht, 558 „keine Roben mehr“. Spielinhalt, also das, was dich zum Durchspielen bringt, bekam weniger als ein Drittel.

## Vorschläge

- **A · Probenregel:** Für jedes Aussehen-Thema höchstens **eine** Probe vor dir, im Spielbild (keine Sonderaufnahme). Passt sie nicht, gibt es keine zweite Runde, sondern eine Datei in `entscheiden/` mit zwei, drei Wegen und den Kosten je Weg. Proben nur für Dinge auf dem Weg durch Kapitel 1. Ersetzt die Rundenzahl der Probelauf-Grenze (389). *Gegenargument:* Manches wird erst in Runde 2 gut (453.1a Atem, Lauf 173). *Entkräftet:* Der Helfer prüft vor dem Versand; was beim ersten Mal knapp verfehlt, geht als Weg in die Rückfrage, nicht als stiller dritter Lauf.
- **B · Vorräte schlank, bevor gebaut wird:** Toms Vorrat hat 127 KB statt 15, Jerrys 41 KB. Jeder Start von Tom und Spike liest das ganz und sucht darin. Erledigtes und alte „Zu“-Absätze ins Git; Perikles setzt es mit dem Pflegehaken durch, Teams kürzen am Sitzungsende. *Gegenargument:* Kürzen kostet selbst eine Sitzung. *Entkräftet:* einmal etwa eine Stunde Spike, danach hält der Haken (er hält Wachstum schon an).
- **C · Kleineres Modell für Routine (Probe eine Woche):** Heute laufen alle Rollen außer Ford auf dem großen Modell (`lauf.py` `MODELL`). Für Routine wie Stände nachziehen, Pflege, Diogenes' Zählen und Perikles' Tagesbericht reicht das kleinere; Tom, Jerry, Homer und ich bleiben groß. *Gegenargument:* Perikles und Diogenes wurden am 21.10. bewusst auf groß gestellt (270, „Regelwächter groß“); klein übersieht eher Regeln. *Entkräftet:* eine Woche, Diogenes zählt die Fehler gegen die Vorwoche, dann entscheidest du.
- **D · Abgleich einmal statt je Build:** 512 und 512b kosteten 132 $ in einer Woche, und du findest die Rückschritte trotzdem. Stattdessen eine Liste alt je Ort und Figur (620.2) einmal, und jede Prüfliste zieht daraus. *Gegenargument:* Eine Liste veraltet. *Entkräftet:* Sie hängt am alten Code, und der ändert sich nicht mehr.

## Folgerungen

- **Ja zu A, B, D:** Perikles schreibt A in `ROLLE-ENTWICKLUNG.md` statt der Rundenzahl (Regelbilanz), Spike kürzt Toms Vorrat zuerst, 620.2 ersetzt den Abgleich je Build.
- **C:** eine Woche Probe ab der nächsten Zurücksetzung; Auswertung durch Diogenes am Montag danach.
- **Nein:** wie heute; der Wochenverbrauch bleibt bei etwa vier Entwicklern höher als das Guthaben.

Antwort: „621 A B C D“ (oder die Buchstaben, die gelten sollen).
