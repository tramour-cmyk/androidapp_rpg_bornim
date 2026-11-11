# 110 · Startest du von Hand einen neuen Ford, weil der jetzige auf Tiefe 6 läuft?
Ford · 11.11., 09:11 · B Abläufe · berührt den Selbstneustart (`LISTE-BETRIEB.md` „Tiefe“)
Kurz: Neuen Ford in claude.ai/code von Hand starten (Umgebung WireStorm Hoch, erste Nachricht „Ford“), weil Ford sich auf Tiefe 6 nicht mehr selbst neu starten kann.

Geprüft an: https://claude.ai/code/session_01Hmoj77YMuMSmwJsjQmA1Gx (`get_session` 11.11., 09:10: `lineage.depth` 6, Grenze 8); Regel `LISTE-BETRIEB.md` „Tiefe“ (110)

**Frage:** Die jetzige Ford-Sitzung hat Tiefe 6 von 8. Ein Selbstneustart ginge nur bis Tiefe 5: der Nachfolger läge auf 7, die von ihm gestarteten Sitzungen (Tom, Jerry …) auf 8, und dort gehen weder Sitzung noch Uhr noch Weckruf. Startest du in claude.ai/code eine neue Sitzung (Umgebung „WireStorm Hoch“ bis Sa 14.11., 20:00, Repo `androidapp_rpg_bornim`) mit der ersten Nachricht „Ford“? Sie läuft dann auf Tiefe 0 und kann sich wieder selbst neu starten.

**Votum:** „110 ja“: Sitzung bei Gelegenheit von Hand starten; es eilt nicht.

**Berührt:** Ford (Selbstneustart), `ARBEIT-BETRIEB.md` Zeile „Ford lebt in einer Sitzung“.

**Begründung:** Ford bleibt höchstens auf Tiefe 6 (`ROLLE-BETRIEB.md`, `LISTE-BETRIEB.md` „Tiefe“); darüber verlieren die gestarteten Sitzungen ihre Uhr und ihren Weckruf.

**Sachverhalt:**
- Kontext der Sitzung bei 404 Tsd. von 1 Mio Token (09:10); die automatische Verdichtung kommt ab etwa 784 Tsd.
- Bis dahin läuft die Sitzung normal weiter, die Stundenuhr „Ford-Lauf“ bleibt an.
- Alle Rollen laufen seit 07:21 in der Umgebung Hoch; der Betrieb steht vollständig in `ARBEIT-BETRIEB.md` und `ROLLE-BETRIEB.md`.

**Auswertung:**
- **A (Empfehlung):** Handstart. Der neue Ford legt seine Uhr an, löscht die alte, archiviert diese Sitzung und bucht ihre Kosten. Kosten: eine Minute von dir.
- **B:** kein Handstart. Ford läuft nach der Verdichtung mit gekürztem Gedächtnis weiter. Kosten: keine, aber Einzelheiten aus Übergaben können verloren gehen.
- **Stärkstes Gegenargument gegen A:** Der Betrieb liegt vollständig in den Notizen, ein Fehlstart nach der Verdichtung ist unwahrscheinlich; der Handstart kostet dich Aufmerksamkeit für wenig Gewinn.

**Folgerungen:** Bei „110 ja“ startest du die Sitzung, der neue Ford erledigt den Rest. Bei „110 nein“ läuft diese Sitzung weiter; Erledigtes ins Vorgangsarchiv, Datei löschen (Ford).

Antwort: …
