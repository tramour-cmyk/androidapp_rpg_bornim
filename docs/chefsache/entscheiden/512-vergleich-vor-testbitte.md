# 512 · Vor jeder Testbitte die berührten Schirme alt gegen neu vergleichen?
Perikles · 03.11., 14:17 · B Abläufe · berührt beide Teams

Kurz: Heute hast du 9 Fehler als Erster gefunden, alle im Vergleich alte gegen neue Fassung; keiner stand in der Prüfliste.

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-UMZUG-348.md

**Frage:** Gilt ab sofort: Vor jeder Testbitte legt ein Helfer die Schirme, die der Build berührt, aus der alten und der neuen Fassung nebeneinander; was fehlt oder schlechter ist, wird behoben oder steht in der Prüfliste, bevor du testest?

**Votum:** „512 ja“.

**Berührt:** Tom, Jerry, Spike (jede Testbitte), Diogenes (348.9 misst Vergleichsbilder bisher nur als Hinweis), Regel „Abgleich“ in `LISTE-UMZUG-348.md`.

**Sachverhalt:** Nach Build 204 (03.11.) sagtest du: „Aber recht viel zum Testen war da jetzt eh nicht drin. Sind mir viele Sachen aufgefallen, die gar keine Testfragen waren.“ Die 9 Funde: 489 Musik und Effekte, 497 Lizenz, 498 Schriftbild, 499 Drehteller, 500 Probeknöpfe, 501 Kaminfeuer, 502 Nebel des Krieges, 503 Ladenknopf, 416.6 Blutspuren. Die Regel steht schon im Umzug: „je Ort und Figur ein Vergleichsbild alt/neu; was fehlt … ist ein Fehler“. Sie hängt aber an keinem Zeitpunkt, und Diogenes misst nur danach (hält nichts an). Hinweis kam von Sokrates (07:45).

**Vorschlag:** Die Regel „Abgleich“ bekommt den Zeitpunkt „vor jeder Testbitte, für die Schirme, die der Build berührt“. Der Helfer arbeitet mit dem alten Spiel in der Vorschau (`tools/preview`) und den Bildern des neuen Builds. Was er findet, wird behoben oder kommt als Zeile „bekannt“ in die Prüfliste. Es kommt keine neue Regel dazu, die alte wird genauer.

**Stärkstes Gegenargument:** Jede Testbitte kostet einen Helferlauf mehr, und die alte Fassung muss für jeden Schirm erst in die richtige Lage gebracht werden. Das kostet Guthaben, und die Woche ist schon über dem Ziel. **Entkräftet:** Verglichen wird nur, was der Build berührt, nicht das ganze Spiel. Ein Fund, den du als Erster machst, kostet eine Testrunde und einen Rückläufer; das ist teurer als ein Helfer.

**Folgerungen:** Bei „ja“: Perikles schreibt den Satz in `LISTE-UMZUG-348.md` und in die Regel zur Prüfliste (`LISTE-BAUEN-TESTEN.md`), beide Teams befolgen es ab der nächsten Testbitte. Bei „nein“: wie bisher.
