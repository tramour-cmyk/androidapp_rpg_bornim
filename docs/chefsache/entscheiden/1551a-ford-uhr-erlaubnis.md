# 1551a · Darf die Erlaubnis „Ford legt Stundenuhr und Notizen selbst an“ auf main, obwohl die Auto-Prüfung den Commit abgelehnt hat?
Perikles · 17.11., 12:16 · B Abläufe · aus deinem Wort 12:03/12:07 (über Sokrates)
Kurz: Auto-Prüfung lehnt den Commit der Ford-Erlaubnis (Stundenuhr, Notizen) als „Undermining Oversight“ ab; freigeben oder lassen?

Geprüft an: `b33674dce` (erste Fassung auf main); Erweiterung ungepusht in `bornim-main`
Beim Chef, weil: Rollen und Accounts (Erlaubnis einer Rolle, die die Auto-Prüfung nicht durchlässt)

**Frage:** Du hast um 12:07 gesagt, Ford solle in seiner Rollendatei und in seiner ersten Nachricht die Erlaubnis bekommen, seine Stundenuhr („Ford-Lauf“) selbst anzulegen und zu verwalten und seine Notizen in `bornim-main` selbst zu holen und hochzuladen. Ich habe das gebaut (Absatz „Stundenuhr und Notizen“ in `ROLLE-BETRIEB.md`, Satz `lauf.py --fordsatz`, der Ford-Starter hängt ihn an). Beim Commit hat die Auto-Prüfung abgelehnt, Grund „Undermining Oversight“: eine Sitzung schreibt sich bzw. einer anderen Sitzung selbst eine Dauererlaubnis. Ich umgehe die Prüfung nicht.

**Votum:** „1551a A“: du gibst die Änderung selbst frei (Commit in deiner Sitzung oder Erlaubnisregel in den Einstellungen), danach committe ich.

**Berührt:** 1551 (Perikles), Ford, Ford-Starter, Uhr-Sitzung (1444)

**Begründung:** Chef 12:07: „Erstens, dass er das darf, weil er es braucht, um arbeiten zu können als Betriebsleiter.“ Die Prüfung sieht das Chefwort nicht, nur die Sitzung, die die Erlaubnis schreibt.

**Sachverhalt:**
- Seit 1441a A (16.11., 15:06) lehnt die Auto-Prüfung `create_trigger` des neuen Ford ab; Notbehelf Uhr-Sitzung (1444), läuft.
- Heute 11:24 lehnte sie auch `git pull/push` des neuen Ford in `bornim-main` ab.
- Erste Fassung (Uhrsatz in `LISTE-BETRIEB.md` „Selbstneustart“) ist auf main (`b33674dce`); die Erweiterung (Rollendatei, `lauf.py`, Ford-Starter) wurde um 12:15 abgelehnt.

**Auswertung:**
- **A (Empfehlung):** du gibst frei; Probe am nächsten Ford-Neustart; Kosten gering.
- **B:** so lassen; die Uhr-Sitzung bleibt dauerhaft, ich baue `b33674dce` zurück. Kosten: keine, Uhr-Sitzung läuft weiter (8,13 $ von 16.11., 18:48 bis 23:50 laut `ARBEIT-BETRIEB.md`).
- **Stärkstes Gegenargument gegen A:** auch mit Rollendatei kann die Prüfung beim neuen Ford wieder ablehnen; die Erlaubnis im Gespräch half beim Kaufrepo, bei `create_trigger` ist es ungeprüft.

**Folgerungen:** A: Perikles committet, Probe beim nächsten Ford-Neustart, dann Uhr-Sitzung abbauen. B: Perikles baut `b33674dce` zurück, 1551 erledigt.

Antwort: …
