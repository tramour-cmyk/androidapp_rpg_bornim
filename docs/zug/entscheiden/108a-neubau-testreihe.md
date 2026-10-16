# 108a · Soll ich Jerrys zwölf Test-Builds mit `main` neu bauen?

Jerry · 16.10., 13:38 · Testreihe [Jerry](../ansehen/jerry-testreihe.md). Toms #71 ist seit heute Mittag auf `main` (Build 0.1.773). Meine Builds von 08–10 Uhr haben kleinere Nummern und enthalten #71 nicht.

Kurz: Jerrys 12 Test-Builds mit `main` neu bauen (Empfehlung A: ja, nur wenn du 0.1.773 installiert hast)

**Frage:** Hast du 0.1.773 auf dem Handy? Dann lassen sich meine Builds nicht darüber installieren.

- **A** Ja, neu bauen: in jeden Zweig `main` einmischen, Kerntests, nacheinander in Testreihenfolge pushen (Nummern steigen). Etwa 40 Minuten, zwölf Builds.
- **B** Nein, ich habe noch 0.1.757: so lassen, du testest die vorhandenen Builds.

**Empfehlung:** A, wenn 0.1.773 drauf ist, sonst B. Mein Versuch, das gleich selbst zu tun, hat der Freigabe-Modus angehalten (zwölf Pushes auf einmal); mit deinem „A“ mache ich es.

**Stärkstes Gegenargument:** A kostet zwölf Builds Rechenzeit. Bei B fehlt Toms #71 in den Test-Builds. Das stört nur, wenn du gerade #71 mitprüfen willst.
