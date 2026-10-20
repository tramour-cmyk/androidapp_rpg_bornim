# Niederlassung einrichten (Pro-Account)

**Ruht seit 17.10. (159, Pro gekündigt).** Wiedereinschalten: Abo wieder buchen, Abschnitte 1 bis 2 neu durchgehen, Zeile „Niederlassung ruht“ in `ARBEIT-BETRIEB.md` streichen.

Anleitung für den Chef: Ford 2 und Team Jerry auf dem zweiten Account (Pro) in Betrieb nehmen. Regeln dazu: `docs/FIRMA.md` „Zentrale und Niederlassung“, `LISTE-BETRIEB.md` „Ford 2“. Stand 16.10. (Perikles).

## 1. Umgebung auf Pro (einmalig)

- **GitHub:** auf Pro unter https://claude.ai/connect-github verbinden; fehlt die Claude-GitHub-App am Repo, auf derselben Seite installieren.
- **Repo:** `tramour-cmyk/androidapp_rpg_bornim` muss beim Anlegen einer Sitzung in der Repo-Auswahl erscheinen.
- **Schreibrecht:** das GitHub-Konto von Pro muss Mitarbeiter des Repos sein (GitHub → Settings → Collaborators).
- **Telegram:** `TELEGRAM_BOT_TOKEN` als Umgebungsvariable der Umgebung (nie ins Repo oder in den Chat).
- **Netz:** „Vollzugriff“ reicht (für `api.telegram.org`); nichts weiter einstellen.

## 1a. Dokumente für Pro freigeben

Artefakte und Dokumente von Max sind privat; Pro sieht sie nur nach Freigabe (Teilen-Menü des Dokuments → E-Mail des Pro-Accounts). Eine Einladungs-E-Mail kommt nicht verlässlich. Prüfen auf Pro: Artefakte unter „Artefakte → Mit dir geteilt“; Dokumente (Typ „Dokument“) haben ein eigenes Teilen-Menü, dort den Link auf Pro direkt öffnen.

**Freigabeliste** (Stand der Spalte „Pro“ trägt ein, wer es prüft):

| Dokument | Art | Recht | Wozu | Pro |
|---|---|---|---|---|
| Prüfbericht (`docs/PRUEFBERICHT.md`, seit 16.10. im Repo, 99g; Artefakt abgelöst) | Repo | lesen | Befunde Diogenes | keine Freigabe nötig |
| Vorgangsarchiv (`docs/VORGANGSARCHIV.md`, seit 16.10. im Repo, 99g.1; Artefakt „Beschlüsse“ abgelöst) | Repo | lesen | alles Entschiedene | keine Freigabe nötig |
| Kampfsystem neu denken (`DESIGN-KAMPF.md`, seit 16.10. im Repo, 99g) | Repo | lesen | 72.x Kampf | keine Freigabe nötig |
| Storyplan (`STORY-PLAN.md`, `-K1`, `-K2`, Texte `STORY-K2-ENTWURF.md`, seit 19.10. im Repo, 99g.1; Dokument abgelöst) | Repo | lesen | Geschichte | keine Freigabe nötig |

Ein Dokument hat zwei Links (kurz `claude.ai/artifact/…`, lang `claude.ai/code/artifact/<uuid>`); in den Notizen steht oft der lange. Monster- und Kampftexte stehen in `STORY-REGELN.md` (Repo), keine Freigabe nötig.

Nicht nötig: Entwürfe 98, Firmenordnung, Rollenkonzept, Marktvergleich, Berater. **Pflege:** wer ein Dokument anlegt, das Team Jerry braucht, trägt es hier ein und bittet den Chef auf „Chefsache“ um Freigabe. Chefsache selbst liegt im Repo (`docs/chefsache/`, 108), keine Freigabe nötig.

## 2. Ford 2 starten

Neue Sitzung auf Pro, Repo auswählen, Freigabe-Modus **„Auto“** (von Ford 2 gestartete Sitzungen erben ihn; auch in „Auto“ fragt die App einmal bei Eingriffen außerhalb der Sitzung, etwa fremde geplante Aufgaben ändern: „Immer erlauben“), Titel „Ford 2 – Niederlassungsleiter (TT.MM., HH:MM)“, erste Nachricht:

> Ford 2. Telegram-Schlüssel ist eingerichtet, Jerrys Pause ist aufgehoben (Chef). Einrichten nach `LISTE-BETRIEB.md` „Ford 2“: Probe-Meldung über `meldung.sh`; deine Stundenuhr mit `create_trigger` auf diese Sitzung; Kennung von Sitzung und Uhr oben in `ARBEIT-BETRIEB.md` (Zeile „Ford 2“); „Pause bis“ in `ARBEIT-TEAM-JERRY.md` streichen; als Probe `create_session` Team Jerry starten (erste Nachricht „Jerry“), Zeile in `ARBEIT-BESETZUNG.md`; Kosten je Lauf als Zeile in `ARBEIT-BETRIEB.md`; alte Sitzungen auf Pro archivieren (außer solchen, die auf einen Test des Chefs warten).

## 3. Woran du siehst, dass es läuft

| Zeichen | heißt |
|---|---|
| Telegram „Ford 2 läuft“ | Lesen, Telegram, Uhr in Ordnung |
| Telegram „Start Jerry“ | Push auf `main` und `create_session` gehen; fertig |
| Ford 2 meldet „Push abgelehnt“ | Schreibrecht fehlt (Schritt 1) |
| Ford 2 meldet „kein `create_session`“ | Jerry von Hand starten: neue Sitzung auf Pro, erste Nachricht „Jerry“; Ford 2 trägt ihn ein |

Hinweis: Auf Pro meldet `notiz.sh` auch für Ford 2 „Jerry“; maßgeblich ist die erste Nachricht.

## 4. Danach

- **Messung zwei Tage:** Ford 2 schreibt seine Kosten; Perikles wertet aus. Über 10 % von Jerrys Woche → Ford 2 fällt weg, Jerry wieder von Hand.
- **Aufräumen:** archivieren kann nur eine Sitzung desselben Accounts (Max: Ford, Pro: Ford 2). Löschen kann kein Agent, nur der Chef in der App; Archivieren reicht.
- **Fällt Pro aus:** Ford holt Team Jerry in die Zentrale (`FIRMA.md`).
