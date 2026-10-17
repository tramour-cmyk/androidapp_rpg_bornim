# 154: Goldverlust beim Tod

**Wortlaut Chef (17.10., 17:4x):** „… alle im normalen Wald. Mit etwas Glück im Kampf gewonnen oder zwei, aber dann auf jeden Fall auch gestorben. Und da das Gold am Anfang eh so knapp ist, ist jetzt dieses äh, du verlierst 40, 30 irgendwas Gold das ist schon echt hardcore. Das ist nicht gut. Dann kann man dann noch weniger Chancen. Äh, was zu reißen. Also ich weiß nicht, ob das gut ist. Hat es erst sozusagen auf dem Schwierigkeitsgrad übernormal macht. Dass das Gold weg ist. So mal als Anregung“
**Entscheid Chef (17.10., 18:2x):** „vergiss das mit dem maximal … die 10 % waren schon richtig“ → **Goldverlust 10 % statt 50 %**; kein Zeitverlust-Ersatz (Toms Empfehlung abgelehnt); Balance über [130](130-kampfgefuehl.md). Umsetzung Jerry. (Frühere Antwort 18:0x ersetzt.)
**Heute:** Niederlage kostet die Hälfte des Golds (`Game.kt`), Held erwacht voll geheilt am sicheren Ort. Schwierigkeitsgrade gibt es noch nicht.
**Frage:** Goldverlust beim Tod abschaffen oder mildern?
**Empfehlung (Tom):** auf „Normal“ kein Goldverlust; der Tod kostet stattdessen Zeit (einige Stunden Spielzeit vergehen, Heimweg). Goldverlust erst mit einem späteren Schwierigkeitsgrad „schwer“. Klein, ein Commit.
**Stärkstes Gegenargument:** ein Tod ohne Kosten nimmt dem Kampf die Spannung („echte Wahl“, `DESIGN-LEITBILD.md`); Spieler laufen blind in Kämpfe. Mittelweg: 10 % statt 50 %.
**Dazu:** alle drei Tester starben im normalen Wald – das ist eher ein Balance-Befund (Kampf zu schwer am Anfang?) als ein Goldbefund; gehört zu [130](130-kampfgefuehl.md).
**Berührt:** 130, Team Jerry (Kampf).
