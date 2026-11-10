# 887a · Spiel-Repo privat machen und das Kaufmodell-Repo hineinlegen, damit keine Sitzung mehr `add_repo` braucht?
Sokrates · 10.11., 16:44 · B Werkzeuge · aus deinem Wort 16:31 („dann packen wir halt alles in eine Repo“), 16:33 („ja, zähl die Minuten“)
Kurz: Ein privates Repo beseitigt die Repo-Rückfrage ganz; Bauminuten kosten dann heute etwa 210 $ im Monat, nach Aufräumen 50–65 $, mit eigenem Bauserver fast nichts

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/actions (alle 11.268 Läufe 11.10.–10.11., Stichprobe Jobs je Workflow; gegengelesen von einem Helfer 16:41)

**Frage:** Die Rückfrage bei `add_repo` ist eine Vorgabe des Servers (Probe 887, 16:26: „server_policy_ask_only“); keine Einstellung hebt sie auf. Liegt alles in einem Repo, bekommt jede Sitzung es von selbst. Dafür muss das Spiel-Repo privat werden, denn die Kaufdateien dürfen nicht öffentlich liegen. Private Repos bauen auf GitHub nicht mehr unbegrenzt kostenlos. Willst du das, und wenn ja, mit welchem Weg für die Bauminuten?

**Votum:** „887a A“: erst aufräumen und Werkzeuge umstellen, dann zusammenlegen und privat; Budget auf GitHub 120 $, nach 870.9 senken.

**Berührt:** alle Sitzungen (kein `add_repo` mehr), Perikles (Workflows, Werkzeuge unten), Jerry (854 Kaufcache, `kauf_laden.sh`, `KAUF_TOKEN` entfällt), Tom (870.9), Ford (Startnachricht ohne Repo-Satz), Regel „gekaufte Rohdateien nur im privaten Zweit-Repo“ in `CLAUDE.md`

**Begründung:** Chef 16:31: „Es kann ja wieder nicht sein, dass wir jetzt hier Krücken außenrum machen“; 09.11., 22:18: „heute ist es wieder katastrophal mit der Repo-Einbindung“. Nachts stehen Sitzungen stundenlang, weil das Repo fehlt.

**Sachverhalt:**
- Bauminuten der letzten 30 Tage: etwa 30.100 (Linux). Davon „Chefsache Übersicht“ 10.500 (8.825 Läufe zu je 1,2 Min., bei fast jedem Push auf `main`), Godot 9.800, APK (Kotlin) 3.600, Godot Kampf 2.200, Vorschau (Kotlin) 1.000, Rest 3.100 (Probe-Workflows). Die letzten 7 Tage: 8.700, hochgerechnet 37.000 im Monat; der Bedarf steigt.
- Privat: 2.000 Minuten frei im Monat (Pro und Team 3.000); darüber Linux 0,006 $ je Minute (seit 01.01.2026, Plattformgebühr enthalten). Speicher für Artefakte: 500 MB frei, darüber kostet es.
- Heute privat: etwa 35.000 Minuten über dem Frei-Kontingent, also rund 210 $ im Monat.
- Nach Aufräumen: Übersicht nur bei Änderung der Chefsache (geschätzt 1.000), Godot mit Kaufcache 854 etwa halb (5.000), Godot Kampf 2.200, Probe-Workflows ausmisten (2.000), APK und Vorschau fallen mit 870.9 (Kotlin raus) weg: etwa 10.000, also 50–65 $ im Monat. Bis 870.9 mit APK und Vorschau etwa 19.600, rund 105 $. Geschätzt, nicht gemessen.
- **Eigener Bauserver** (Runner auf einem Rechner von dir, etwa NAS oder Proxmox, Vorgang 264): in privaten Repos derzeit ohne Minutenkosten; `tools/runner/einrichten.sh` liegt schon da, benutzt wird er nicht.
- Budget: Persönliche Konten stehen auf 0 $; dann halten alle Builds an, sobald die Freiminuten aufgebraucht sind.
- Was heute am öffentlichen Repo hängt und umgestellt werden muss: Filme in Telegram über jsDelivr (`meldung.sh` 105–114, `zug-index.py` 330; jsDelivr liefert nur öffentliche Repos); Tagesbericht und Probelauf fragen die Actions-Schnittstelle ohne Anmeldung ab (`tagesbericht.py` 115–123, `probelauf.py` 479); der Link „bornim.apk (neueste Version)“ in `README.md` und Links auf Dateien gehen nur noch angemeldet. Webseite (FTP) ist nicht betroffen.
- Öffentlich machen darf man das Repo danach nie wieder: Die Kaufdateien stehen dann im Verlauf.

**Auswertung:**
- **A (Empfehlung):** Perikles stellt erst Filme, Tagesbericht und Probelauf um, drosselt die Übersicht und mistet Probe-Workflows aus; dann zusammenlegen und privat, Budget 120 $. Bis 870.9 rund 105 $ im Monat, danach 50–65 $. Die Repo-Rückfrage ist weg.
- **B:** wie A, dazu eigener Bauserver bei dir: Bauminuten fast 0 $; du musst einen Rechner dauerhaft laufen lassen und einmal einrichten.
- **C:** Alles bleibt: 0 $ Bauminuten, die Repo-Rückfrage bleibt; du schreibst weiter den Satz oder klickst „Immer erlauben“ je Sitzung.
- **Stärkstes Gegenargument gegen A:** laufende Kosten für etwas, das heute nichts kostet, Umbau an fünf Werkzeugen, und ein Schritt, der sich nicht zurücknehmen lässt. Dagegen: Wartende Sitzungen kosten Stunden Arbeitszeit und dich jedes Mal die Rückfrage; die Kosten sinken mit 870.9 von selbst auf 50–65 $.

**Folgerungen:** Nach A oder B: Vorgang an Perikles (Werkzeuge umstellen, Übersicht drosseln, Probe-Workflows ausmisten, Plan für das Zusammenlegen); danach schaltest du auf GitHub privat und setzt das Budget (Schritte als Datei in `tun/`); bei B zusätzlich Runner einrichten. Nach C: Ford im Modus „default“ für das Archivieren (Probe 887), sonst bleibt alles.

Antwort: …
