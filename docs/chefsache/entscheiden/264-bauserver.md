# 264 · Den eigenen Bauserver auf deinem Proxmox abschalten, als Ausweich behalten oder zum Hauptbauplatz machen?
Sokrates · 12.11., 01:12 · B Abläufe · aus deinem Wort 10.11., 16:53 („jetzt“), Messung Perikles 11.11., 10:13
Kurz: Abschalten und bei GitHub abmelden, der Bauplan bleibt im Repo; wieder einschalten, wenn das Repo privat wird oder GitHub einen ganzen Arbeitstag nicht baut

Geprüft an: [Lauf 340](https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions/runs/42976949004) (eigener Runner, Zweig `claude/perikles-264-runner`) gegen GitHub-Lauf 322; Störung gestern Abend laut githubstatus.com, Läufe 358 bis 364

**Frage:** Du wolltest am 10.11. einen eigenen Bauserver auf deinem Proxmox: einrichten, gegen GitHub messen und klären, ob das bei einem öffentlichen Repo sicher ist. Er ist eingerichtet und gemessen. Bauserver heißt hier: dein Rechner baut das APK statt der Rechner von GitHub; GitHub nennt so etwas „Runner“. Jetzt ist zu entscheiden, was aus ihm wird: abschalten (A), als Ausweich behalten (B) oder zum Hauptbauplatz machen (C).

**Votum:** „264 A“: Du meldest den Runner `proxmox-bornim` bei GitHub ab (Settings → Actions → Runners → entfernen) und schaltest die VM aus, etwa 2 Minuten.

**Berührt:** 264.1 (Einrichtung, Perikles, erledigt), 109 (Repo privat, „noch nicht“), 854 (Bauzeit kürzen; der größte Hebel bleibt dort: die Modelle brauchen 38 von 63 Minuten)

**Begründung:** Dein Rechner baut fast doppelt so lange wie GitHub, GitHub kostet uns nichts, als Ausweich hätte er gestern nicht geholfen, und solange er angemeldet und an ist, können Fremde über einen Änderungsvorschlag Code auf deinem Rechner laufen lassen. Lohnend wird er erst, wenn das Repo privat wird.

**Sachverhalt:**
- **Dauer:** ein voller Build bei dir 119 Minuten, bei GitHub 63 (Messung Perikles, Lauf 340 gegen 322). Dein Rechner hat einen sparsamen Prozessor mit 4 Kernen (Intel N95), die VM nutzt schon alle 4. Schneller ginge es nur mit einer anderen Maschine.
- **Kosten:** bei einem öffentlichen Repo sind die Bauminuten bei GitHub frei (deine Abrechnung 11.11., 21:58: nichts fällig). Privat wären es etwa 70 bis 100 $ im Monat (109).
- **Störung gestern:** GitHub stand von 21:22 bis 22:01, also 39 Minuten (githubstatus.com; unsere Läufe 358 und 359 starteten nicht). Seit 09.11. meldet githubstatus.com vier Störungen, die Actions betrafen.
- **Sicherheit:** bei einem öffentlichen Repo kann jeder einen Änderungsvorschlag (Pull Request) einreichen und darin seinen eigenen Bauablauf mitbringen, der ausdrücklich auf deinem Runner laufen soll. Er braucht dafür nichts von uns; der Ablauf liefe auf deinem Rechner in deinem Heimnetz. Je nach Einstellung hält GitHub solche Läufe nur bei Neulingen an, alle anderen laufen ohne deine Freigabe durch. Man kann einstellen, dass jeder Fremde erst deine Freigabe braucht; dann hängt die Sicherheit an jedem deiner Klicks. GitHub rät deshalb von eigenen Runnern an öffentlichen Repos ab.
- **Abmeldung von selbst:** GitHub entfernt einen eigenen Runner, der 14 Tage nicht verbunden war.
- **Bauplan:** alle Schritte stehen im Zweig `claude/perikles-264-runner`, die Ursachen der acht Einrichtungsläufe im Archiv (264.1); der Zweig ist nicht auf `main`.

**Auswertung:**
- **A (Empfehlung) Abschalten:** abmelden, VM aus, Bauplan bleibt. Kostet dich 2 Minuten, danach nichts. Ein Wiederanlauf ist ein Lauf bis wenige Läufe, keine neue Einrichtung. Wieder einschalten, wenn das Repo privat wird (dann spart er das Geld, und Fremde kommen nicht heran) oder GitHub einen ganzen Arbeitstag nicht baut.
- **B Als Ausweich behalten:** angemeldet und an, gebaut wird nur von Hand, wenn GitHub stockt. Gestern hätte es nicht geholfen: abwarten und dann bei GitHub bauen dauerte 39 + 63 = 102 Minuten, sofort bei dir bauen 119 Minuten. Dein Rechner ist erst schneller, wenn GitHub länger als 56 Minuten steht. Dafür bleibt die Tür für Fremde offen, und er will gepflegt werden.
- **C Hauptbauplatz:** jeder Testbuild kommt fast eine Stunde später bei dir an. Spart kein Geld, solange das Repo öffentlich ist.
- **Stärkstes Gegenargument gegen A:** angemeldet lassen und nur die VM ausschalten; ein ausgeschalteter Runner führt nichts aus, auch nichts Fremdes, und die Anmeldung bliebe für den Notfall. Antwort: nach 14 Tagen meldet GitHub ihn ohnehin ab, dann ist es dasselbe wie A, nur ohne dass wir es wissen; und im Notfall eingeschaltet, steht die Tür wieder offen. Zweiter Einwand: abgeschaltet veraltet er (neue Godot-, Blender- oder Python-Fassung), der Wiederanlauf kann ein paar Läufe kosten. Das stimmt; ihn ungenutzt warm zu halten, kostet aber jede Woche Pflege.

**Folgerungen:** Bei A trage ich deine Antwort ins Archiv ein, 264 ist erledigt, der Zweig bleibt stehen; Perikles nimmt „wieder einschalten, wenn privat oder ein Arbeitstag ohne GitHub“ in seine Ablaufliste. Bei B richtet Perikles den Bau von Hand auf deinem Rechner ein. Bei C stellt Perikles alle Builds um.

Antwort: „264 A“, „264 B“ oder „264 C“
