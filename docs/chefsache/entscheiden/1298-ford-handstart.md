# 1298 · Ford bitte von Hand starten (Tiefe 6)?
Ford · 15.11., 15:11 · Betrieb · Selbstneustart erreichte Tiefe 6 von 8
Kurz: Der Ford-Selbstneustart liegt auf Tiefe 6; der nächste muss vom Chef auf Tiefe 0 gestartet werden.
Beim Chef, weil: Rollen und Accounts

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/822f8e97d

**Frage:** Ford läuft jetzt auf Tiefe 6 (Grenze 8, Teams liegen dann auf 7). Ein weiterer Selbstneustart ist nicht mehr möglich. Startest du in claude.ai/code eine neue Sitzung „Ford“ (Umgebung Mittel `env_01F9WxikYD4TTdhscxvPi93p`, Repo `main`)? Sie liegt dann auf Tiefe 0. Dringend wird es bei Fords nächstem Kontextlimit (rund 400 Tsd. Token).

**Votum:** „1298 A“: Ford von Hand starten, wenn der Chef die nächste Pause hat; bis dahin läuft der jetzige Ford weiter.

**Berührt:** Ford, `LISTE-BETRIEB.md` „Tiefe“, Ford-Starter (1098 A)

**Begründung:** Regel `LISTE-BETRIEB.md`: „Ab Tiefe 6 … Der Chef startet in claude.ai/code eine Sitzung mit ‚Ford‘ (Tiefe 0).“

**Sachverhalt:**
- Tiefe 6 von 8 laut get_session; Sitzungen auf Tiefe 8 können weder `create_session` noch Uhr.
- Dieser Ford hat zudem kein `create_trigger` (Auto-Modus-Prüfung lehnte es ab), der alte Ford legte die Uhr an.

**Auswertung:**
- **A (Empfehlung):** Handstart auf Tiefe 0, zwei Minuten Aufwand, danach wieder viele Neustarts.
- **B:** Ford bleibt auf Tiefe 6, bis das Limit erreicht ist; dann Stillstand ohne Nachfolger.
- **Stärkstes Gegenargument gegen A:** unterbricht den Chef ohne akuten Anlass; ein Neustart wird erst in Stunden fällig.

**Folgerungen:** Nach dem Handstart trägt der neue Ford sich in `ARBEIT-BETRIEB.md` ein, legt Uhr an, archiviert diesen Ford.

**Stellungnahme Sokrates (15.11., 15:45):**
- **Stärkstes Gegenargument gegen A:** kein akuter Anlass; Ford liegt bei 191 Tsd. von 1 Mio. Token, seine Uhr „Ford-Lauf“ (:03) läuft. Hält nicht ganz: bei seinem Verbrauch (191 Tsd. in 70 min) erinnert der Neustart-Haken (400 Tsd.) gegen 17:30.
- **Was die Datei nicht sagt:** (1) Der Handstart löst die Tiefe dauerhaft: nur ein Ford auf Tiefe 0 legt den Ford-Starter an (`LISTE-BETRIEB.md` „Ford-Starter“, 1098 A; in `ARBEIT-BETRIEB.md` steht „keiner“). Danach liegt jeder Ford auf 2, jedes Team auf 3, kein Handstart mehr. In die Folgerungen gehört: „legt gleich nach der Uhr den Ford-Starter an“. (2) Bis zum Handstart darf Ford nicht selbst neu starten, auch nicht nach der Erinnerung des Hakens: auf Tiefe 7 lägen die Teams auf 8, dort gehen weder Weckruf noch `send_later` (Pflicht nach jedem Push, der baut). Er läuft über 400 Tsd. weiter; die Sitzung verdichtet erst bei 784 Tsd.
- **Widerspruch zu Entschiedenem:** keiner.
- **Kosten:** zwei Minuten des Chefs; der Starter arbeitet nur bei einem Neustart.
- **Empfehlung:** 1298 A, möglichst vor etwa 17:30; bis dahin kein Selbstneustart Fords.

Antwort: …
