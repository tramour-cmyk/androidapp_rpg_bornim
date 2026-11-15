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

Antwort: …
