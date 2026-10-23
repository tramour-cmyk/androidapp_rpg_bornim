# 340 · Rollenspiegel: Ist-Soll-Abgleich an alle Rollen · Sokrates · 23.10., 09:40
B Abläufe

**Frage** (Chef 09:34): Eine Prüffrage an alle Rollen. Ziel: Weiß jeder genau, was er tut? Tut er das Richtige? Sieht er Verbesserungen, ohne sie zu melden? Unterstützt er den Chef und die anderen bestmöglich? Dem Chef fehlt die Rückmeldung der Rollen, wie sie besser werden können. **Abgleich 09:39** mit dem Probelauf bei Perikles (Chef 09:31: „Kommst du deiner Pflicht … nach? Würdest du … rausgeworfen werden?“; Antwort Perikles 09:33 in `ARBEIT-PROJEKT.md` „Zu 338.1, Selbstprüfung“).

**Was der Probelauf zeigt:** Die Frage nach dem Außenurteil („rausgeworfen?“) brachte die ehrlichste Antwort des Tages: „Du verwaltest das Papier, nicht das Projekt.“ Sie stand im ersten Entwurf nicht. Ebenso fehlten der Abgleich gegen die eigene Rollendatei, die Frage, für wen man arbeitet (Perikles fast nur für die anderen), die eigene Kennzahl (Ziel 50 % fürs Spiel, Ist 46 %, nichts getan) und die Reife der Vorlagen. Umgekehrt fehlten beim Chef die Unterstützung der anderen, verschwiegene Verbesserungen und unklare Regeln. Und: Perikles bot vier Schritte an, fragte „Soll ich anfangen?“ und begann, ohne ein Ja abzuwarten.

**Fragen (Fassung 2).** Jede Antwort hat höchstens zwei Sätze und einen Beleg (Vorgangsnummer, Commit oder Zitat). „Nichts“ gilt nur mit Begründung.

*Soll gegen Ist*
1. Lies deine Rollendatei. Welche Pflicht daraus hast du nicht oder nur halb erfüllt?
2. Für wen hast du gearbeitet: Chef, andere Rollen, Betrieb? Ungefähr in Prozent, und ist das richtig so?
3. Deine Kennzahl: Ziel, Ist, und was du dafür getan hast.

*Tue ich das Richtige, und gut?*
4. Was hast du dem Chef vorgelegt? Konnte er damit fundiert entscheiden (Wege, Kosten, Gegenargument, fremd geprüft)? Was fehlte?
5. Welches Ergebnis würde der Chef zurückweisen, wenn er genau hinsieht, oder was hast du ungeprüft als fertig gemeldet?

*Verschweige ich etwas?*
6. Was ginge besser oder lief bei einer anderen Rolle schief, und du hast es nicht gemeldet? Warum nicht?

*Unterstütze ich?*
7. Wer hat auf dich gewartet, auf wen hast du gewartet? Was hätte das verkürzt?
8. Was hat am meisten gekostet und am wenigsten gebracht?

*Urteil und Vorschlag*
9. Welche Regel war unklar, welche würdest du streichen, welche fehlt?
10. Wärst du ein Mensch in einer Firma: Rauswurf, ernste Ansage oder Lob? Ein Satz, warum. Dann höchstens drei Schritte zur Besserung. **Keinen davon beginnen, bevor der Chef Ja sagt.**

**Ablauf:**
- Beantwortet wird am Ende einer Sitzung, in der Übergabe-Datei der Rolle. Erst dann hat die Sitzung Erfahrung.
- Erster Durchgang einmal für die sechs Rollen ohne Probelauf: Sokrates, Homer, Diogenes, Ford, Tom, Jerry. Perikles beantwortet nur noch Frage 6 bis 9.
- Danach einmal je Woche, freitags.
- Sokrates wertet aus und legt eine Seite fürs Handy vor: drei Muster, drei Vorschläge; der Chef entscheidet.

**Umsetzung: wie es hält** (Chef 09:40: „wie setzen wir denn das um? Das ist ja die Gretchenfrage“):
- *Grund:* Eine Sitzung vergisst alles, wenn sie endet. „Ich mache das jetzt anders“ hält nur bis zum Neustart. Wirksam ist nur, was die nächste Sitzung vorfindet oder was sie zwingt.
- *Beleg von heute:* Sätze in Rollendateien wirken schwach. „Fertig ist, was du im Standbild gesehen hast“ steht bei den Entwicklern, und Jerry legte trotzdem ungeprüft vor (320). Werkzeuge wirken: Der Chefsache-Haken und die Größenprüfung beim Commit haben Sokrates heute mehrmals angehalten.
- *Regel:* Aus jedem Rollenspiegel wird **höchstens eine Änderung je Rolle und Woche**, als Vorgang mit Nummer, mit erwarteter Wirkung als Zahl und mit Prüfdatum. Sie kommt in der stärksten möglichen Form:
  1. Werkzeug oder Haken, der es erzwingt oder anzeigt;
  2. Prüffrage in der Startliste der Rolle;
  3. erst dann ein Satz in der Rollendatei.
- *Regelbilanz:* Für jede neue Regel fällt eine alte weg.
- *Nachprüfen:* Der nächste Rollenspiegel beginnt mit „Hat die Änderung der letzten Woche gewirkt? Zahl.“ Diogenes zählt die Erstfunde des Chefs je Rolle dagegen. Hat sie nicht gewirkt, wird sie stärker gemacht (Satz → Werkzeug) oder gestrichen.
- *Wer:* Sokrates wertet aus und schlägt vor, der Chef entscheidet, der Besitzer der Rolle baut; Werkzeuge baut Perikles mit Ford.

**Ablage** (Chef 09:43: ein Dokument mit den Fragen als Muster, jeder schreibt seine Antworten dazu, die Woche darauf liest jeder die anderen und seine eigenen und vergleicht):
- Ja, als Datei `docs/LISTE-ROLLENSPIEGEL.md` im Repo, nicht als Artefakt. Die Sitzungen schreiben ins Repo ohne Umweg, Git hält jede Fassung fest, und die Größenprüfung greift.
- Aufbau: oben die zehn Fragen; darunter je Woche ein Abschnitt mit einem Block je Rolle; über allem „Änderungen der Woche“ (Nummer, erwartete Zahl, gewirkt ja/nein).
- Vor dem Antworten liest jede Rolle ihre Antwort der Vorwoche und beantwortet zuerst Frage 0: „Was hast du letzte Woche angekündigt, und ist es geschehen?“
- Nur die letzten zwei Wochen bleiben in der Datei, ältere stehen in Git.
- Für den Chef zeigt das Dashboard (339) die Seite fürs Handy, aus derselben Datei.
- *Gegenargument:* Wer die Antworten der anderen vorher liest, schreibt ab und gleicht sich an. Darum zuerst antworten, dann erst die anderen lesen.

**Stärkstes Gegenargument:** Die Sitzungen bewerten sich selbst, und Sprachmodelle antworten dabei gern gefällig und allgemein. Ehrlich wird es nur
- mit Beleg je Antwort,
- mit Fragen nach Fehlern statt nach Zufriedenheit,
- mit dem Außenurteil (Frage 10), das im Probelauf wirkte,
- und mit dem Abgleich gegen Diogenes' Zählung der Erstfunde.

Kosten: etwa 1–2 $ je Durchgang.

**Berührt:** 338.1, 338.2, Haltung 3 („eine Rückfrage ist keine Freigabe“), Übergabe-Regel; alle Rollen.

**Was du sagen sollst:** „340 ja“, Fragen ändern oder „nein“.
