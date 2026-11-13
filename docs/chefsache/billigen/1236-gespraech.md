# 1236 · Vorentscheid billigen: Wann ist ein Vorhaben „groß“, und wie läuft das Gespräch mit dir davor?
Sokrates · 13.11., 21:44 · B Abläufe · aus deinem Wort 21:41
Kurz: Vor dem ersten Code-Commit eines großen Vorhabens eine Zeile „gilt der Beschluss noch?“ an dich, gebündelt in der Chefrunde; bis zu deinem Wort baut der Besitzer an Anderem

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/125f57325 (`CLAUDE.md` Zusammenarbeit 3 und 4, Vorgangsarchiv 654, 827, 1129 A)

**Frage:** Du hast heute um 21:41 gesagt: „bevor irgendeiner irgendwas Großes, einen neuen Themenkomplex anpackt, müssen wir uns darüber auf jeden Fall unterhalten, weil … wenn wir das irgendwann mal beschlossen haben vor einer Woche oder vor 2 Wochen, kann ja das jetzt sich schon ganz anders darstellen. Okay, also das ist wichtig.“ Die Richtung steht damit fest, sie ist im Vorgangsarchiv eingetragen. Offen war nur, was „groß“ heißt, wann das Gespräch stattfindet und wie es abläuft. Das habe ich als Ablauf vorentschieden. Billigst du diese Einzelheiten?

**Entschieden:**
1. **Groß** ist ein Vorhaben, wenn eins davon zutrifft: (a) Es ist ein neues System oder ein neuer Themenkomplex, für den es im Spielcode noch nichts gibt. (b) Es berührt mehrere Orte oder beide Teams. (c) Es ist auf über 30 $ geschätzt, dasselbe Maß wie bei „festgefahren“ (827).
2. **Wann:** vor dem ersten Code-Commit, auch bei Vorgängen, die längst beschlossen sind und erst jetzt drankommen.
3. **Wie:** keine eigene Datei je Vorhaben. Der Besitzer setzt das Feld „wartet auf Chef Gespräch“ und schreibt eine Zeile „Zu <Nr>: Beschluss vom …, seither anders: …, Aufwand …“. Ich bündle diese Zeilen in der nächsten Chefrunde, je Zeile mit meinem Votum und dem stärksten Einwand. Du sagst „los“, „anders“ oder „noch nicht“. Bis dahin baut der Besitzer an anderem, was startbar ist.
4. **Kein Gespräch nötig:** wenn du in den letzten 3 Tagen selbst über genau dieses Vorhaben gesprochen hast (Archiveintrag mit deinem Wort, etwa die Laufwege und Plätze aller Figuren im Kampf, 1072, am 12.11. und heute), außerdem bei Fehlerbehebungen an Bestehendem und bei Tests ohne Spielcode.
5. **Regelbilanz:** Das ersetzt in `CLAUDE.md` Zusammenarbeit 3 den Teil „Nie selbst: … Umbauten über mehrere Orte oder beide Teams“, weil er in dieser Regel aufgeht.

**Berührt:** alle Entwickler (Team Tom, Team Jerry, Tuffy, Spike) vor jedem großen Vorhaben; Perikles (Bau von Regel und Werkzeug, 1236); ich (Chefrunde); `CLAUDE.md`, `ROLLE-ENTWICKLUNG.md`, `tools/startbar.py`.

**Begründung:** Dein Wort von 21:41 gibt die Richtung vor. Wie die Regel im Einzelnen läuft, ist eine Frage des Ablaufs, und Abläufe entscheide ich vor (1129 A, 783 W5). Die Grenze ist eng gezogen, damit du nicht wieder eine Vorlage nach der anderen bekommst (05.11.: „ich kriege wieder 12 Vorlagen“).

**Sachverhalt:**
- Bisher gibt es kein solches Tor. Bei Umbauten über mehrere Orte oder beide Teams verbietet `CLAUDE.md` Zusammenarbeit 3 nur, dass ein Team selbst entscheidet. Dass der Beschluss vor dem Beginn noch einmal geprüft wird, verlangt keine Regel.
- Die Systemfrage (654, `ROLLE-ENTWICKLUNG.md` „Alt zuerst“) fragt vor dem Bauen „kommt das wieder?“, nicht „gilt das noch?“. Sie bleibt daneben bestehen.
- 30 $ ist schon heute die Grenze für „festgefahren“ (827, Archiv).

**Auswertung:**
- **A (so entschieden):** eine Zeile je Vorhaben in der Chefrunde, enge Grenze, Ausnahme nach 3 Tagen. Kosten: keine eigenen.
- **B:** jedes große Vorhaben als eigene Datei in `entscheiden/`. Das ist genauer, kostet dich aber Zeit und erzeugt mehr Vorlagen.
- **Stärkstes Gegenargument gegen A:** Ein weiteres Tor verlangsamt, und du wirst zum Engpass. **Antwort:** Es kommt nur eine Zeile, keine Datei. Gewartet wird nicht, weil der Besitzer solange an Anderem baut. Sind es mehr als drei Zeilen je Woche, ist die Grenze zu weit, und ich lege sie dir neu vor. Unsicher sind die 30 $ und die 3 Tage: Sie sind geschätzt, nicht gemessen.

**Folgerungen:** Perikles baut Regeltext und Werkzeug (1236; ob `startbar.py` solche Zeilen anzeigt oder ein Haken den ersten Commit anhält, entscheidet er). Am 27.11. prüfe ich, wie viele Zeilen es waren und wie oft du „anders“ gesagt hast.

**Umgesetzt:** Archiveintrag „1236“ und Auftrag an Perikles (Commit dieser Datei); Regel und Werkzeug folgen mit 1236.

**Rückbau:** Regelzeile streichen und den alten Satz in Zusammenarbeit 3 wieder einsetzen.

**Kosten:** keine eigenen; je großem Vorhaben eine Zeile in der Chefrunde.

Antwort: …
