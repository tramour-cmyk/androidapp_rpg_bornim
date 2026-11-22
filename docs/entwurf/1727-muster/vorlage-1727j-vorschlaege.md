# 1727j · Nimmst du die fünf Textänderungen V1 bis V4 und V6 an, und wie entscheidest du die fünfzehn offenen Fragen aus Falltest und Umbau?
Sokrates · 22.11., 08:50 · B Abläufe · aus dem Falltest Lauf 1 bis 3 und deinem Wort 20.11., 16:49 (Abgenommenes nur nach Gespräch ergänzen, je Änderung Größe)
Kurz: fünf kleine Änderungen an abgenommenen Ladetexten mit Byte, dazu fünfzehn Fragen je mit Votum.
Beim Chef, weil: Rollen und Accounts (Änderung an abgenommenen Ladetexten)

Geprüft an: <Commit vor dem Anlegen>

**Frage:** Der Falltest hat an abgenommenen Ladetexten (1727i) fünf Stellen gezeigt, an denen eine Sitzung falsch oder gar nicht weiterkam, und Fragen offengelassen, die kein Text beantwortet; eine weitere (Frage 14) kam beim Umbau der Werkzeuge. Nimmst du die fünf Änderungen an, und wie entscheidest du die Fragen? Wortlaut alt und neu, Fall und Gegenargument je Änderung: `docs/entwurf/1727-muster/vorschlaege-10-00.md`.

**Votum:** „1727j A“: V1, V2, V3, V4, V6 ja; die Fragen wie mein Votum je Zeile unten.

**Berührt:** Sockel (V2), Kern Leitung (V1), Kern Arbeitsplaner (V3, V4, Frage 11), Kern Büro (V6), Profil Prüfer (Fragen 2 und 3), Profil Disponent (Frage 8); Spike (Werkzeuge zu Fragen 1, 2, 5, 6 und 7); Themenblöcke (Frage 14).

**Begründung:** Jede Änderung hat einen Fall, in dem die Sitzung mit dem alten Text falsch handelte; ohne Antwort auf die Fragen entscheidet nach dem Umschalten jede Sitzung selbst.

**Sachverhalt:**
- **V1, Kern Leitung** (2.837 → 2.962 Byte, mit Frage 10: 2.977): was etwas festlegt oder in `chefsache/entscheiden/` geht, prüft ein frischer Helfer, nach jedem Einarbeiten neu, bis nichts Neues kommt; im Chat Byte und Ladesumme vorher und nachher. Fall: die Leitung legte eine Chefsache ohne Prüfung vor; dein Wort 21.11., 21:37 „Jedes Mal, wenn du was überarbeitest, lass es gegenprüfen.“ (steht im Vorrat Sokrates, nicht im Archiv). In Lauf 3 gespielt, bestanden.
- **V2, Sockel** (1.109 → 1.129): „Vor Sitzungsende alles pushen.“ → „Vor Sitzungsende nur Eigenes committen und pushen.“ Fall: Vorfall 21.11., 20:59 (fremde Dateien mitgepusht). Gespielt.
- **V3, Kern Arbeitsplaner** (2.649 → 2.698): im Auftrag als Rückmeldewort „steckt fest“ statt „abgebrochen“. Fall: die Fachkraft meldete zweimal „Frage“ statt „steckt fest“, so griff deine Obergrenze (21.11., 14:37 B) nie. In Lauf 3 gespielt, wirkt.
- **V4, Kern Arbeitsplaner** (2.698 → 2.834): ist die Ursache unbekannt, erst den Fehler im Test rot zeigen und die Ursache mit Commit belegen, dann beheben, in einem Auftrag; Rückmeldung mit dem roten und dem behobenen Commit. Fall: der Nachstellauftrag ohne Bau ließ einen Rückläufer nie beim Chef ankommen. Gespielt nur in einer ersten Fassung; der erste Halbsatz wurde danach geändert, der zweite kam neu dazu, beide ungespielt. Gegenargument: getrennt verhindert es Bauen auf Vermutung (Bekannte Fehler: „Nie einen Fehler zweimal mit Vermutung bauen“); entkräftet, weil die Reihenfolge Pflicht bleibt und beide Commits sie in Git zeigen. Restlücke: das Profil Prüfer prüft die Reihenfolge nicht.
- **V6, Kern Büro** (680 → 759): Chefworte bleiben wörtlich, daneben in eckigen Klammern eine Lesart, wenn die Vorlage sie eindeutig macht (Beispiel: Spracherkennung „535“, gemeint 235). Ungespielt. Gegenargument: jede Lesart ist eine Auslegung, eine falsche wird gebaut (Bekannte Fehler: „Nie ein Urteil des Chefs umformulieren“); entkräftet, weil der Wortlaut unverändert daneben steht und ohne eindeutige Vorlage „Frage“ bleibt; Restgefahr bei ähnlichen Zahlen.
- **V5** ist keine Textänderung, sondern Frage 1.
- Zusammen wachsen vier Texte um 409 Byte (mit Fragen 10 und 11: 456); der Kern Arbeitsplaner um 185, mit Frage 11 um 217. Die Grenzen halten (Sockel 1,2 KB, Kern 3 KB), außer beim Kern Leitung, wenn dort auch der entschiedene Satz zum Eingang aus [1727i](cs:1727i) eingebaut wird (etwa 3.060 Byte); dann kürze ich dort an anderer Stelle und lege es mit Byte vor. Ladesumme mit allen Änderungen: Arbeitsplaner 4.438 → 4.754, Leitung 3.946 → 4.106, Disponent 5.564 → 5.663.

**Fragen, je mit Votum** (Herkunft und Gegenargument der Fragen 1 bis 13 und 15 in `vorschlaege-10-00.md`, Frage 14 aus `docs/vorgang/1893.md`):
1. Zählt ein Nein von dir unter „Bisher“ im Vorgang als erster Fehlversuch für „steckt fest“ (deine Obergrenze 21.11., 14:37)? **Votum ja:** nach deinem Fund ein Versuch der Fachkraft, beim nächsten Nein Sokrates, beim zweiten „steckt fest“ du (dein Wort 19.11., 22:17 „Rückläufer müssen aber auch weiter bearbeitet werden und dürfen nicht durchrutschen“, steht im Vorrat Sokrates, nicht im Archiv). Daran hängt bei Spike 1872 (Obergrenze zählt auch dein Nein).
2. Ist das dritte „Beleg fehlt“ des Prüfers ein „nein“? **Ja,** sonst schleift ein schlechter Beleg ohne Grenze; Profil Prüfer etwa +60 Byte, Werkzeug bei Spike (neu anzulegen).
3. Fehlt in der Rückmeldung nur eine Angabe (Zahl der Fälle, Quelle, Testausgabe), ist das „Beleg fehlt“, nicht „nein“? **Ja;** Profil Prüfer etwa +45 Byte.
4. Darf der Prüfer einen fehlenden Beleg durch eigene Prüfung im Repo ersetzen? **Nein,** der Beleg ist für dich und das Archiv; kein Textwechsel.
5. Woher kommen die „Kosten bisher“ in einer Chefsache nach zweitem „steckt fest“? **Werkzeug** schreibt sie in den Kopf der Vorgangsdatei (neu bei Spike), kein Text.
6. Liegezeit je Übergabe in die Wochenzählung? **Ja,** als Werkzeug 1868, nicht vor dem Umschalten nötig.
7. Auftrag ohne Prüffragen: was tut der Prüfer? **Lesart, kein Text:** ohne sichtbaren Mangel „nein, Auftrag“, mit Mangel „nein“ und Hinweis „Prüffrage fehlt“; verhindern soll es das Werkzeug 1879 (drei bis fünf Prüffragen je Auftrag).
8. Starten Rückläufer von dir auch, wenn du „weniger laufen“ gesagt hast? **Ja,** ein Fund von dir soll nicht über Nacht liegen; nennst du einen Umfang, setzt Sokrates ihn.
9. Wer zählt beim Build die Handypunkte („Testbitte erst ab 4“)? **Der Build-Macher** nach Checkliste 3 (`LISTE-CHECK-BUILD-TEST.md`); kein Textwechsel.
10. Gilt „Byte und Ladesumme“ aus V1 nur bei Ladetexten? **Ja** (+15 Byte); für Chefsache-Dateien prüft die Größe schon `vorlage_pruefen.py`.
11. Gehören Deckel (etwa „ein Versuch“) und Lauffreigabe mit Quelle in jeden Auftrag? **Ja,** Kern Arbeitsplaner +32 Byte; sonst baut die Fachkraft darüber hinaus oder fragt zurück. Ungespielt.
12. Ist ein Bauskript am Kaufmodell eine „fremde Datei“, sodass das Querprofil Fremde Inhalte zugeladen wird? **Ja,** nur wenn der Auftrag Kaufmodell oder Bauskript ändert (`CLAUDE.md`: Lizenz auch bei Bearbeitung des Originals).
13. Deckel für V1: höchstens drei Prüfrunden, dann mit Restbefunden vorlegen? **Votum nein,** dein Wort 21.11., 21:37 und „Qualität vor Eile“. Dazu: „bis nichts Neues kommt“ heißt „bis eine Runde nichts Neues mit Wirkung auf einen Ladetext oder eine Vorlage findet“ (**Votum ja**), als Lesart im Gedächtnis der Leitung, kein Byte im Kern.
14. Themenblöcke 8 (Marktstart: Bereiche Markt und Veröffentlichung) und 9 (Übriges) haben kein Fachprofil; Spike gibt sie an der Kopie vorläufig dem Arbeitsplaner (`docs/vorgang/1893.md`). Soll Block 8 ein Fachprofil bekommen? **Votum nein, so lassen:** der Arbeitsplaner lädt für Markt-Vorgänge das Profil Markt und Recherche zu, für Veröffentlichung das Profil Release (ab Vorgang 622); ein festes Profil für den ganzen Block passte nur auf einen der beiden Bereiche. Gegenargument: ohne festes Profil vergisst der Arbeitsplaner das Zuladen; entkräftet, weil Block 8 bis zum Meilenstein ruht (`chefsache/themenbloecke.md`: Kapitel 1 nein). Den Zuschnitt änderst nur du.
15. Bekommt jeder offene Vorgang nach dem Umzug eine Vorgangsdatei, auch ohne Absatz „Zu …“? **Ja,** kein Textwechsel; an der Kopie haben alle 331 offenen Vorgänge eine (`docs/vorgang/1871.md`: Herkunft in 331 Vorgangsdateien).
- Ohne Votum, nur zur Kenntnis: im Falltest verknüpfte der Arbeitsplaner verwandte Vorgänge nicht; das verlangt kein Text, die Liste führt der Disponent. Wenn du es willst, ist es eine neue Zeile im Kern Arbeitsplaner.

**Auswertung:**
- **A (Empfehlung):** alles wie Votum; ich baue die Texte ein, je Commit mit Byte, danach frische Nachprüfung, bis nichts Neues kommt.
- **B:** nur die gespielten Änderungen (V1, V2, V3); V4, V6 und die Textfragen 2, 3, 10, 11 erst nach dem Umschalten am ersten echten Fall; die Fragen ohne Textwechsel (1, 4 bis 9, 12 bis 15) gelten wie bei A.
- **Stärkstes Gegenargument gegen A:** V4, V6 und Frage 11 sind nicht gespielt, und jede Änderung an abgenommenen Kernen ist das „Aufblähen“, vor dem du am 20.11., 16:49 gewarnt hast (zusammen 456 Byte, mit den Fragen 2 und 3 zum Profil Prüfer etwa 560). Entkräftet: jede Änderung hat einen Fall, in dem der alte Text falsch führte, und die Grenzen halten; wer das Ungespielte nicht will, nimmt B.

**Folgerungen:** bei A Einbau durch Sokrates, Archivzeile je Änderung und Frage, Werkzeugaufträge an Spike (Fragen 2 und 5 neu; zu Frage 1 die Obergrenze mit deinem Nein 1872, zu Frage 6 die Liegezeit 1868, zu Frage 7 die Prüffragen 1879); dann Umschalten nach [1727h](cs:1727h). Bei B nur V1 bis V3.

Antwort: …
