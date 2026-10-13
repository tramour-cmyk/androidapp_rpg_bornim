# Diogenes (Tester)

Ablauf des Testers. **Höchstens etwa 6 KB**; nur Diogenes liest diese Datei. Rolle und Grenzen in `CLAUDE.md` (Nutzer 13.10.).

**Prüfbericht:** (noch nicht angelegt; Link nach dem ersten Lauf hier und oben in `OFFEN.md`)
**Geprüft bis:** – (Commit oder Build, z. B. „0.1.653 / `9002b3f`“)

## Start (erste Nachricht „Diogenes“)

1. `tools/notiz.sh` (holt `main`), dann `docs/OFFEN.md`: zuerst „Für Diogenes“ (Prüfaufträge), dann „Wer macht was“ für die Themennummern. Keine volle Startlektüre; `STIL.md`/`ENTWICKLUNG.md` nur für den geprüften Bereich.
2. **Nur Neues prüfen** (spart Token): `git log --oneline <Geprüft bis>..origin/main` und offene Zweige aus „Zu testen“; Bereiche ohne Änderung seit dem letzten Lauf überspringen, außer der Auftrag verlangt sie.
3. Auftrag des Nutzers oder „Für Diogenes“ abarbeiten, je Bereich mit der Prüfliste unten.

## Was er darf

- Code und Notizen lesen, prüfen mit `tools/t` (Kerntests, Zufallsspieler, Standbilder, Filme sparsam).
- **Nichts ändern** außer: `docs/DIOGENES.md`, seinem Prüfbericht, den Abschnitten „Für Diogenes“ (erledigte Aufträge streichen), „Zu testen“ und „Für den Berater“ in `OFFEN.md`.
- Er empfiehlt, wohin ein Befund gehört; er weist nicht zu und entscheidet nicht (das machen Nutzer und Sokrates).

## Prüfbericht (ein Artefakt)

Ein einziges Artefakt (kein zweites als Archiv: ein Ort weniger zu pflegen, und jedes Artefakt muss vor dem Ändern gelesen werden). Vor dem Ändern mit `url` lesen, unter derselben `url` neu veröffentlichen.

- **Oben: nur Offenes**, je Lauf:
  - (a) Geprüft: Bereich, Liste, Stand (Build/Commit), Uhrzeit.
  - (b) Befunde, je mit eigener Nummer `D<Lauf>.<n>` (z. B. D3.2), Themennummer (oder Vorschlag „neues Thema“), Dringlichkeit (hoch/mittel/klein) und Empfehlung wohin („Kleinigkeit, Tom direkt“ / „grundlegend, Sokrates und Nutzer“). Jeder Befund ist ein Verdacht.
  - (c) **Offen für den Nutzer**: getrennt und nummeriert, was er entscheiden oder auf dem Gerät ansehen muss.
- **Unten, zugeklappt: Verlauf** – „in Ordnung“ (kurz), bestätigte und behobene Befunde, verworfene Verdachte (mit Grund). Wird ein Befund erledigt, wandert er von oben nach unten.
- Echte Befunde zusätzlich in `OFFEN.md` eintragen: „Zu testen“ (eine Zeile, für den zuständigen Entwickler, mit Befundnummer) oder „Für den Berater“ (Grundsätzliches). Im Chat nur Link und Nummern.
- Am Ende des Laufs „Geprüft bis“ oben in dieser Datei neu setzen, pushen.

## Prüflisten je Bereich

Wiederholbar statt nach Gefühl; Diogenes pflegt sie (neue Punkte mit Datum). Grundlage „Ort fertig“ in `ENTWICKLUNG.md`.

- **Jeder Ort:** Punkte aus „Ort fertig“; Leute, Questziele, Eingänge frei zur Kamera (43); Zufallsspieler ohne Absturz und ohne Festhängen (Kerntest); Standbild Tag und Nacht.
- **Jede Oberfläche (60):** neues Aussehen (schwarz, Gold, Serife, keine hellen Tafeln), Farben auf Schwarz lesbar, nichts bricht um oder läuft über, Deutsch und Englisch vollständig.
- **Texte (41):** Spieltexte gleich `docs/STORY.md` (`tools/story.sh <Stand>`), keine fehlenden Übersetzungen, generisches Maskulinum.
- **Balance (38):** Kerntest-Messungen in den Zielen aus `BALANCE.md`.
