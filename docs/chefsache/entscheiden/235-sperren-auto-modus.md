# 235 · Sperren der Auto-Modus-Prüfung: Wurzel und dauerhafte Regelung
Sokrates · 20.10., 08:44 · Q Ablauf · M (Auftrag Chef 08:37 über Perikles: „… Ich [will] endlich, dass das läuft ohne mich jedes Mal zwei Mal damit beschäftigen zu müssen…“; berührt 234, 222, 222.1, D36.5)

## Wurzel (nachgesehen in der Doku von Claude Code, `auto-mode-config`, `permissions`)

1. **Die Prüfung glaubt nur, was du in derselben Sitzung sagst.** Was in Dateien steht, sieht sie nicht als Freigabe („tool results are stripped“). Das ist Absicht: sonst könnte jede Sitzung sich eine Freigabe selbst in eine Datei schreiben. Darum scheitert „Chef gibt bei Sokrates frei, Jerry mergt“ jedes Mal, egal was im Vorrat steht.
2. **Unser Satz in `.claude/settings.json` (`autoMode.environment`, 222.1 Punkt 3) wirkt nicht.** Die Prüfung liest `autoMode` nicht aus der Projektdatei, nur aus Benutzer- oder Organisationseinstellungen. Cloud-Sitzungen haben keine Benutzereinstellungen. Was dort steht, sehen nur die Sitzungen, nicht die Prüfung. Damit wäre auch 234 Punkt 1 wirkungslos. Die Verbote (`deny`: Force-Push, Rebase) und die Erlaubnisse (`allow`: fetch, diff, merge-tree) wirken dagegen; das ist nachgewiesen.
3. **Notizarbeit in `/home/user/bornim-main` liegt außerhalb des Arbeitsverzeichnisses.** Dort entscheidet die Prüfung über jedes Schreiben. Ein Python-Skript, das mehrere Regeldateien umschreibt, sieht für sie aus wie „Anweisungen für andere Agenten fälschen“. Edit und Write zeigen die Änderung offen und gehen darum eher durch. `.claude/` ist ein geschützter Pfad, Änderungen dort prüft sie immer.

## Empfehlung

- **(1) Freigabe = Zusammenführen in derselben Sitzung.** Wer „Build n freigegeben“ hört, führt den PR selbst zusammen: Sokrates, Ford oder das Team, über GitHub, nur wenn CI grün ist und es keinen Konflikt gibt, als Merge (108a.1). Die Sitzung schreibt dabei vor dem Zusammenführen deinen Wortlaut und „PR #n nach main“ in ihre Antwort. Das Team erledigt danach den Rest (Rückläufer in `CHANGELOG.md`, Zeilen streichen). Bei Konflikt: Das Team holt `main` ein, und du sagst die Freigabe einmal in dessen Sitzung. Das ist selten.
- **(2) Notizen nur mit Edit, Write, Read und Grep**, keine Bash- oder Python-Skripte, die Notizdateien umschreiben, und kein `cat`/`sed` auf ganze Notizdateien. Werkzeuge in `tools/` (startbar, lauf, meldung, notiz) bleiben erlaubt. Kommt als ein Satz in `CLAUDE.md` „Notizen nur auf main“ und ersetzt dort keinen anderen.
- **(3) Gezielte Erlaubnisse in `.claude/settings.json`** für unsere eigenen Werkzeuge, damit die Prüfung sie gar nicht erst bewertet: `python3 tools/startbar.py`, `python3 tools/lauf.py`, `tools/notiz.sh`, `tools/meldung.sh` (je im Arbeitsverzeichnis und in `/home/user/bornim-main`). Ausdrücklich nicht: `python3` allgemein, `git -C …` allgemein, Push.
- **(4) Den wirkungslosen `autoMode`-Satz aus `.claude/settings.json` streichen** (222.1 Punkt 3), damit niemand auf ihn baut. Regelbilanz: (3) kommt hinzu, (4) fällt weg.
- **(5) 234:** Punkt 1 (Satz in `autoMode`) **nein**, er wirkt nicht (Wurzel 2). Punkt 2 (`notiz.sh` bricht ein misslungenes Zusammenführen ab) **ja**: Genau das hat heute früh meine Notizkopie lahmgelegt.

Weil (3) und (4) `.claude/settings.json` ändern, muss deine Freigabe dafür in der Sitzung stehen, die die Datei ändert. Bei „235 ja“ ist das diese Sitzung.

## Stärkstes Gegenargument

(1) lässt Sitzungen ohne Bauwissen Code nach `main` bringen. Das Risiko ist klein: Zusammengeführt wird nur grün und ohne Konflikt, der Inhalt ist der, den du getestet hast, und das Team prüft danach. (3) lockert die Prüfung, aber nur für Skripte, die wir selbst geschrieben haben und die nichts nach `main` bringen außer Notizen. Wer `tools/` ändert, ändert, was dann ungeprüft läuft. Abhilfe: Änderungen an diesen vier Werkzeugen nur mit Diogenes' Blick.

Nicht empfohlen: die Prüfung über die Organisationseinstellungen bei claude.ai lockern (dort wirkt `autoMode`). Das wäre der einzige Weg, ihr unseren Ablauf zu erklären, aber er schwächt den Schutz, der uns beim Rebase schon geholfen hat. Auch dann gälte eine Freigabe in einer Datei nicht.

## Antwort

„235 ja“ (alles), oder einzeln, z. B. „235: 1, 2, 5 ja, 3 und 4 nein“.
