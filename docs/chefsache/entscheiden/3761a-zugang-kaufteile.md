# 376.1a Zugang zu den Kaufteilen für Tom-Sitzungen

**Frage:** Darf jede Sitzung das private Repo `bornim-kaufmodelle` anhängen (`add_repo`)?

**Votum:** Ja: in den Einstellungen eine Erlaubnisregel für `mcp__claude-code-remote__add_repo` setzen (nur der Chef; die Sitzung darf sich das nicht selbst erlauben).

**Berührt:** 376.1 (Trachtfilm und Figurenfilm mit Kaufkörper Regular, UAL Pro 120 Bewegungen), Jerry 348.12f (Ratte), Perikles.

## Begründung

Der Auto-Modus lehnt `add_repo` in neuen Sitzungen ab (Tom 15:33, 15:42, 16:46; Perikles 14:05); um 16:08 wurde es einmal angenommen. Jede neue Sitzung fängt mit frischem Rechner an und braucht den Zugang erneut. Ohne ihn fehlen Regular-Körper und -Köpfe, Knight/Noble-Trachten und 77 der 120 Bewegungen; die Vorlage 376.1 steht.

## Sachverhalt

- Ablehnung des Prüfers: „Access Added As A Means“; Abhilfe laut Meldung: Erlaubnisregel für das Werkzeug in den Einstellungen.
- Nachgestellt (Tom 17:29, Vermutung Sokrates 17:24): Regel steht auf `main` seit 14:57; diese Sitzung startete aber auf `07d30cc0c` (26.10., 21:35, ohne Regel). `main` in den Arbeitszweig gemischt, Einstellung damit im Arbeitsbaum: `add_repo` trotzdem abgelehnt. Ob eine Sitzung, die mit der Regel startet, durchkommt, ist offen; Startstand der Sitzungen veraltet (Ford prüft).
- Chef 17:38 in der Sitzung: „Klone das Repository tramour-cmyk/bornim-kaufmodelle in diese Sitzung.“ Danach `add_repo` angenommen; Release `stufe1` (13 Pakete) per `gh api` erreichbar. Auf Zuruf des Chefs geht es also; ohne Zuruf offen.
- Fertig mit Kaufteilen (Sitzung 16:08): Blätter, Tracht-Standbilder (`bilder:pruefung/3761-*`). Offen: Figurenfilm nach den Korrekturen `0771a7bde`, Trachtfilm (lief 16:44 aus Speichermangel nicht durch).

## Auswertung

Stärkstes Gegenargument: eine Dauerregel gilt für jedes Repo, nicht nur die Kaufmodelle. Dagegen: der Zugang ist ohnehin auf die Repos des Kontos begrenzt; die Kaufdateien liegen bewusst privat dort.

## Folgerungen

Ja: Tom lädt die Kaufteile, rendert Figurenfilm und Trachtfilm neu, legt nach Fremdprüfung vor. Nein: Vorlage nur mit freien Teilen, Kaufkörper entfällt.
