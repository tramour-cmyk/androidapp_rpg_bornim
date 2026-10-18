# 167.10 · Übersicht „alles Offene“ für den Chef
Sokrates · 18.10., 11:27 · B Abläufe · baut Perikles mit 167.1

Kurz: Abschnitt „Offen je Rolle“ in der Chefsache-Übersicht, schreibt das vorhandene Werkzeug bei jedem Push

**Frage** (Chef 18.10., 11:2x): „gibt es irgendwo eine Übersicht für mich? … wo ich sehen kann, was überhaupt insgesamt offen ist … Vorgangsliste, aber da sind auch Sachen drin, die halt schon erledigt sind … wie könnte ich das jetzt unter Umständen neu priorisieren oder um zu gucken, warum es nicht läuft … da muss ich halt in sechs oder sieben Vorräte schauen“

**Heute:** gibt es nicht. `tools/startbar.py` rechnet es schon (je Rolle: startbares Muss, Kür, jede gesperrte Zeile mit Grund), aber nur Ford sieht die Ausgabe.

**Empfehlung: ja.** `tools/zug-index.py` schreibt die Chefsache-Übersicht (`docs/chefsache/README.md`, dein Lesezeichen) schon bei jedem Push. Darunter kommt ein Abschnitt „Offen je Rolle“ aus `startbar.py --stand`: je Rolle eine Tabelle Nr., Kl., Was (ein Satz), Stand (startbar / wartet auf X / Chef / Test / ruht), oben eine Zeile „startbar ohne Sitzung“. Keine neue Datei, keine Handarbeit, kein Ford; immer aktuell. Umpriorisieren sagst du in irgendeiner Sitzung, die trägt es ein (wie bisher).

**Stärkstes Gegenargument** (Perikles zu 167.1): die Übersicht ändert sich dann bei fast jedem Push, das Werkzeug committet öfter, Sitzungen bekommen öfter „Push abgelehnt“ und müssen `git pull` machen. Gewogen: das Werkzeug committet heute schon („Chefsache: Übersicht“), ein abgelehnter Push kostet Sekunden; die Alternative, dass du sieben Vorräte liest oder eine Sitzung fragst, kostet deine Zeit oder Guthaben. Ausweg, falls es stört: Ford schreibt den Abschnitt nur bei seinem Stundenlauf (höchstens eine Stunde alt).

**Berührt:** 167.1 (`startbar.py --stand`, Kopfzeile fällt), `tools/zug-index.py`, `.github/workflows/zug-index.yml`.
