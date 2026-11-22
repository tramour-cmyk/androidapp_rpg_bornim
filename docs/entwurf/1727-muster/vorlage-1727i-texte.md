# 1727i · Nimmst du die Ladetexte der neuen Arbeitsweise ab, die noch kein Wort von dir haben oder nach deinem Wort geändert wurden?
Sokrates · 22.11., 08:29 · B Abläufe · aus dem Auftrag der Übergabe 22.11., 07:25 („Texte ohne Chefwort mit Byte“) und deinem Wort 20.11., 16:49
Kurz: 15 geladene Texte ohne dein Wort, 6 nach deinem Wort geändert, 3 Unsicherheiten bei Abgenommenem; Abnahme in Gruppen.
Beim Chef, weil: Rollen und Accounts (die Ladetexte ersetzen die Rollendateien)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** In der neuen Arbeitsweise liest jede Sitzung beim Start nur kurze Ladetexte: den Sockel (für alle), einen Kern (Leitung, Büro, Arbeitsplaner, Abnahme), ein Profil für ihr Fach, für feste Routinen einen eigenen Text. Es sind 29 Texte. 8 hast du abgenommen und sie sind seitdem unverändert. 15 haben kein Wort von dir, 6 wurden nach deinem Wort geändert. Liste mit Fassung und Byte je Text: `docs/entwurf/1727-muster/texte-stand-10-00.md`. Nimmst du sie gruppenweise ab, wie unten, oder willst du einzelne vorher im Wortlaut sehen?

**Votum:** „1727i A“: alle Gruppen 1 bis 4 abnehmen und die drei Unsicherheiten so bestätigen, wie unten steht. Die Änderungsvorschläge V1 bis V6 entscheidest du getrennt (1727j); sie ändern danach Kern Arbeitsplaner, Kern Büro, Kern Leitung und Sockel noch einmal.

**Berührt:** Spike (Ablage `docs/profile/` mit dem Umschalt-Commit 1871); alle künftigen Sitzungen.

**Begründung:** Diese Texte bestimmen, was jede Sitzung nach dem Umschalten tut (1727h). Dein Wort 20.11., 16:49: „die Kerne, die wir schon abgenommen haben grundsätzlich, da müssen wir uns dann unterhalten … jedes Mal, wenn wir an einem Kern etwas ergänzen oder ein Profil erstellen, will ich wissen, wie groß das alles ist“.

**Sachverhalt** (Byte nach der Messregel in `texte-stand-10-00.md`, gemessen 22.11.):
- **Gruppe 1, ohne Wort, im Falltest gespielt, aber teils in älterer Fassung:** Kern Abnahme 1.567 (so in Lauf 3 gespielt); Profil Disponent 3.775 (gespielt Fassung 14 mit 3.761); Profil Prüfer 2.831 (gespielt Fassung 7 mit 2.730, Fassungen 8 bis 11 ungespielt); Profil Tester 2.626 (nur in Lauf 1). In Lauf 3 waren von 9 „teilweise“ 3 Werkzeuglücken, 4 Fragen fürs Gespräch (1727j), 2 hängen an den ungespielten Prüfer-Fassungen.
- **Gruppe 2, ohne eigene Archivzeile, von dir „schon von mir genehmigten Profile“ genannt** (20.11., 14:02, als ich sie umschreiben wollte): Profil Regeln 1.743, Kampf 1.482, Kataloge 1.448; seitdem unverändert.
- **Gruppe 3, ohne Falltest und ohne Wort:** Profil Figur und Prüfbild 1.303; Profil Werkzeug Teil A 1.103; Querprofil Fremde Inhalte Teil A 1.168 (die Lizenzregel darin hast du mit 1727b entschieden); Profil Release 712 (gilt erst, wenn es einen Release-Weg für Godot gibt, Vorgang 622); Routinen Rundblick 1.168, Tagesbericht 867, Wache 949, Wochenzählung 1.938 (ihre Startgründe hast du mit 1727c entschieden).
- **Gruppe 4, nach deinem Wort geändert:** Kern Büro 680 (dein „A“ 21.11., 11:46 galt dem Vorschlag, der Wortlaut entstand danach); Kern Arbeitsplaner 2.649 (dein „1727f ja“ eingebaut, dann der Meldeweg aus der Übergabekette); Profil Markt und Recherche 1.279 (Zeile zum Steckbrief vom 19.11., 17:12); Übergabekette 2.622 (Freigabewörter aus 1727d); Profil Story 1.410 (Spalte Sprechweise raus auf dein Wort 20.11., 16:53); Profil Technik Teil B 4.232 (ein Satz aus 1727d).
- **Unsicher bei den 8 Abgenommenen:** Profil Chefrunde: abgenommen ist nur der Satz aus 1727d, für den Grundtext fehlt eine Archivzeile. Sockel: dein „Passt so.“ 20.11., 12:06 galt dem Kopf (Oberstes Ziel); die übrigen Zeilen stützen sich auf 19.11., 13:58 „Mach es so.“. Kern Leitung: der Satz zum Eingang, den du mit 1727d entschieden hast (Sokrates legt einen Auftrag mit `vorgang.py neu` an und weckt den Disponenten), ist noch nicht eingebaut; Einbau mit Byte folgt deinem Wort.
- **Nicht geladen:** Kern Prüfer 2.529 (Verlauf, ersetzt durch Kern Abnahme und Profil Prüfer).
- **Was eine Sitzung heute laden würde** (`herausgezogen.md`, Tabelle „Ladesumme je Sitzungsart“): Leitung 3.946 Byte (dazu Gedächtnis bis 3 KB); Disponent 5.564; Arbeitsplaner 4.438 (mit Profil Werkzeug 5.541); Prüfer 5.507 (mit beiden Querprofilen 7.551); Tester 5.302; Wache 2.058; Werkstatt Welt 4.453, Werkstatt Text 2.519, je zuzüglich Auftrag. Zum Vergleich heute: `CLAUDE.md` 15.000 Byte plus Rollendatei 5.900 bis 13.000 Byte.

**Auswertung:**
- **A (Empfehlung):** Gruppen 1 bis 4 abnehmen, Unsicherheiten bestätigen. Gruppe 1 ist am meisten geprüft, Gruppe 2 hast du schon genehmigt genannt, Gruppe 3 trägt Inhalte, die du entschieden hast, oder Werkzeugsätze, Gruppe 4 setzt deine Entscheide um. Kosten: keine.
- **B:** Gruppen 1, 2, 4 abnehmen; Gruppe 3 erst nach einer Woche Betrieb der Routinen (erste Wochenzählung).
- **C:** jeden der 21 Texte einzeln mit dir durchgehen, etwa eine Stunde.
- **Stärkstes Gegenargument gegen A:** du nimmst 21 Texte ab, die du nicht im Wortlaut gelesen hast, darunter das Profil Prüfer in einer Fassung, die nie gespielt wurde. Entkräftet: jeder Text ging durch frische Nachprüfungen; abgenommen heißt nicht unveränderlich, jede spätere Änderung kommt mit Byte wieder zu dir. Wenn dir das beim Profil Prüfer nicht reicht: dort 1727h B (ein kurzer Lauf).

**Folgerungen:** bei A Archivzeile je Gruppe; die Texte gelten als abgenommen und gehen mit dem Umschalt-Commit nach `docs/profile/` (1871). Bei B laufen die Routinen bis zur ersten Wochenzählung in der alten Form. Bei C Gespräch je Text.

Antwort: …
