# Vorrat Perikles

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Wochenziel, Meilensteine, Vorrang, Kosten der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang, Muss oben. Größe höchstens etwa 15 KB.

**offen 3, Muss 3, A 0, Chefsache 0**

**Gelesen bis:** `origin/main` 17.10., 19:5x (`9e2e74bb`)

**143 erledigt (17.10., 23:2x):** Wochenplan als [Artefakt](https://claude.ai/artifact/APSG9vqZwRFfWaBqQTibny) (Zentrale); ändert sich ein Termin in den Regeln, Seite mit derselben Datei neu veröffentlichen.

**Übergabe (18.10., 10:3x, „Perikles – 166.2 und Stellungnahme 167“): 166.2 behoben (`tools/startbar.py`: erledigt/Teil erledigt/erst mit/wartet auf Rolle/Dauerzeilen/Pause gegen Uhr/„gebaut“ gilt als fertig/unlesbare Zeilen, D27.1–D27.5 bis auf Wache); Stellungnahme in Chefsache 167 geschrieben. Offen: Jerry- und Homer-Kopf falsch, 130.1/72.10a „erledigt“ nicht gestrichen (Besitzer); Wache soll `startbar.py` rufen (Ford). Davor:** **Übergabe (18.10., 01:2x, „Perikles – 164 Befunde“) – Nachfolger: Perikles – Wochenziel 19.–25.10. (Mo 19.10.):** 164 erledigt (D26.1–D26.3, D26.4b): festes Testdatei-Muster in `zug-index.py` REGELN, „Wer“ = Team aus Zeile 1, Tabellenprüfung in `formfehler()`, „Tom 2“ gilt. D26.4a (ein Fehler je Datei) behoben, D26.4c (`26-…` ausgenommen) bleibt. M? entschieden: 162 Muss, 149.1 Muss, 163.1 Kür bis Regelbilanz 23.10., D23 Kür; 159.1 und 106.1 warten.

| Nr. | Kl. | Was | Termin |
|---|---|---|---|
| 167.5 | M | **von Chef (18.10., 10:5x, Wortlaut):** „die Kostenerhebung, das muss auch besser funktionieren, können wir das auch so regeln, dass das passt mit einem Werkzeug?“ Dazu 167.1: Stand-Datei oder in die Besetzung? Und: mehr Werkzeuge zum Automatisieren? Entwurf: Kosten je Sitzung und Rolle automatisch beim Archivieren in eine Logdatei (`tools/kosten.sh`), Summen rechnet ein Skript; **geprüft 18.10., 11:1x: `cost_usd` archivierter Sitzungen bleibt lesbar** (`get_session` und `list_sessions` der Zentrale, Feld `usage.cost_usd`; Ford-Vorgänger 0,7777 $ = Protokoll 0,78 $; 27 von 30 gelisteten Sitzungen archiviert, 28 mit Kosten); nicht lesbar: Sitzungen der Niederlassung (Pro, anderer Account: „nicht gefunden“). **Skript gebaut** (`tools/kosten.py`, Eingabe: gespeicherte `list_sessions`-Seiten; Rolle aus Titel, je Rolle und Tag, Anteil Spiel). Offen: Ford ruft es im Lauf (Seiten per `after_id` holen) und meldet Anteil Spiel; Abgleich mit `LISTE-VORGAENGE.md` (Handwerte) | vor der Chefrunde |
| 166 | M | **gebaut, berichtigt 18.10. (166.2), Test mit nächstem Ford-Lauf offen;** von Sokrates, Chef 18.10., 08:2x, jetzt (Vorgangsarchiv 166):** `tools/startbar.py` (Art wie `tools/zug-index.py`): liest alle `ARBEIT-*.md`, gibt je Rolle startbares Muss und Kür aus (Kl., Stand; „wartet auf X“ gegen `LISTE-VORGAENGE.md`, „ruht“, „Pause bis“, „Chef“), zählt die Kopfzeilen selbst und meldet falsche. Ford ruft es in jedem Lauf (`LISTE-BETRIEB.md` Schritt 1 und 4 umschreiben). Anlass: Nacht 17./18.10. 8 Std. Stillstand Homer (Muss 72.10a.T, Kopf „Muss 0“) und Jerry (Kür) | jetzt |
| 165 | M | Ablaufstichprobe läuft (Chef Ja 18.10.): Schritt in `ROLLE-PROJEKT.md` Tagesrückblick, Zählung in `ROLLE-PRUEFUNG.md`; Bilanz 23.10. | 23.10. |
