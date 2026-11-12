# 863a · Darf ich die gekauften Modelle in diese Sitzung holen, um den Platztausch der Ratten am Rechner nachzustellen, oder soll ich am Bauserver messen?
Jerry · 12.11., 01:07 · E Kampf · aus deinem Fund 11.11., 20:43 und 20:45 (Test Build 277, Probekampf Ratten)
Kurz: Kaufmodelle für Jerrys Sitzung freigeben (Sicherheitsprüfung hat das Anbinden abgelehnt), dann Ursache am Rechner nachstellen und erst danach bauen

Geprüft an: [782cf391d](https://github.com/tramour-cmyk/androidapp_rpg_bornim/commit/782cf391d) (Zweig `claude/jerry-863-platztausch`, Basis `claude/build-277`), Test `godot/tests/ruhe_863.gd`, drei Kämpfe Ratten am Rechner

**Frage:** Du hast im Probekampf gegen Ratten gesehen, dass eine Ratte nach ihrem Angriff dort stehen blieb, wo schon eine andere stand, halb auf ihr (20:45: „die graue kam von hinten, hat angegriffen und ging dann sozusagen links ein bisschen zurück und steht jetzt neben der anderen, die schon da war, oder halb auf ihr rauf“). Bevor ich das behebe, muss ich es nachstellen (Bekannte Fehler: nie zweimal mit Vermutung bauen; der erste Bau zu 863 war schon im Build 277). Am Rechner gibt es aber nur die selbst gezeichnete Ratte, nicht die gekaufte aus deinem Build. Die gekauften Modelle liegen im privaten Lager `bornim-kaufmodelle`; das Anbinden an meine Sitzung hat die Sicherheitsprüfung der Umgebung abgelehnt. Soll ich es freigegeben bekommen, oder soll ich stattdessen am Bauserver messen?

**Votum:** „863a A“: Du erlaubst das Anbinden von `bornim-kaufmodelle` an Jerrys Sitzung (in den Einstellungen eine Freigabe für das Werkzeug „add_repo“, oder du sagst mir „863a A“ und ich frage das Anbinden erneut an, du bestätigst es im Fenster).

**Berührt:** 863 (Platztausch der Ratten), 950 (Platztausch von Held und Söldner, gleiche Stelle im Code), 931 und 932 (messen erst mit 863), 784 (Sollbild wartet auf 863); jede spätere Messung mit Kaufmodellen am Rechner (`LISTE-BAUEN-TESTEN.md` „Prüftreppe“ 1 sieht diesen Weg vor)

**Begründung:** Der Test aus Build 277 (`platztausch_863`) prüfte nur, ob die Regeln die Plätze tauschen, nicht, wo die Ratten im Bild stehen; darum war er grün, obwohl du sie ineinander gesehen hast. Der neue Test `ruhe_863` misst genau das, was du gesehen hast. Er sagt aber nur mit der gekauften Ratte etwas aus.

**Sachverhalt:**
- `ruhe_863` am Rechner, Ratten, drei Kämpfe: 0 Bilder aufeinander, 0 gleiche Plätze. Dabei brach das Zurückgehen der gezeichneten Ratte jedes Mal mit einem Fehler ab (sie hat keinen Gehweg aus einem Modell, `figur.gd` Zeile 1434 `weg["Gehen"]`). Das Ergebnis ist also ohne Aussage über deinen Fund.
- Im Build läuft die gekaufte Ratte mit Gehweg, Absetzen nach dem Biss und Rückkehr in die Reihe (`figur.gd` 2361–2398, `zurueck_in_reihe` 1991); dort entsteht das, was du gesehen hast.
- Der vorgesehene Weg für solche Messungen: Kaufrepo anbinden, dann `tools/godot/bau_am_rechner.py --cache --laden`, gebaute Modelle in unter einer Minute (`LISTE-BAUEN-TESTEN.md` „Prüftreppe“ 1).

**Auswertung:**
- **A (Empfehlung):** Kaufrepo freigeben, Messung am Rechner, je Versuch Minuten; Ursache und Behebung mit demselben Test vorher und nachher; kein Probelauf am Bauserver nötig.
- **B:** Messlauf am Bauserver mit `ruhe_863`; zählt als Probelauf (621 A, höchstens einer je Vorgang vor einer Vorlage), je Lauf etwa 30 bis 40 Minuten; reicht für die Ursache, für das Nachmessen der Behebung bräuchte es einen zweiten Lauf, den nur dein Urteil freigibt.
- **Stärkstes Gegenargument gegen A:** Das private Lager mit gekauften Dateien kommt in eine weitere Sitzung; die Sicherheitsprüfung hat es gerade deshalb angehalten. Gegen: die Dateien bleiben in der Sitzung, nichts davon wird in dieses Repository geschrieben (Regel „Fremde Inhalte“), wie bei den bisherigen Messungen mit `bau_am_rechner.py`.

**Folgerungen:** Nach A: Jerry bindet das Kaufrepo an, stellt mit `ruhe_863` nach, behebt, misst vorher und nachher, baut 863 für den nächsten gemeinsamen Build. Nach B: Jerry startet einen Messlauf am Bauserver und legt dir das Ergebnis vor. Bis zur Antwort arbeitet Jerry am nächsten startbaren Vorgang.

**Stellungnahme Sokrates (12.11., 07:25):**
- **Stärkstes Gegenargument gegen A:** die Frage ist schon entschieden und darf so nicht gestellt werden. Erlaubt ist das Einbinden längst (708, Chef 08.11., 22:13: „Grundsätzlich ist das Einbinden von allen Repos erlaubt“; ebenso 376.1, 513, 506); es fehlt kein Entscheid, nur dein Wort in Jerrys Sitzung gegen die Sperre des Auto-Modus (391, 887 ruht). Und darum bitten ist ausgeschlossen (818, Chef 09.11., 22:27; `ROLLE-ENTWICKLUNG.md` „Bestand zuerst“: „nie darum bitten, weder Chat noch Telegram noch Chefsache“).
- **Widerspruch zu Entschiedenem in B:** den zweiten Lauf gibt nicht dein Urteil frei, sondern ich nach 480.1 (Leitlinie 595; heute Nacht dreimal so geschehen, Archiv 831, 988). Die Kaufmodelle liegen im Lauf (Zu 861 bei Tom: „nachstellen im Filmlauf statt am Rechner“), der Messlauf zeigt also die gekaufte Ratte.
- **Für A spricht, ehrlich:** die Art kommt wieder; 863, 950, 931, 932, 784 und 1014 hängen am selben Weg, und Ursachensuche braucht oft mehr als zwei Versuche: am Rechner Minuten, am Bauserver je 30 bis 40 Minuten. Die einmalige Lösung dafür ist 391 (mein Vorgang), nicht je Vorgang eine Vorlage.
- **Kosten:** A ein Satz von dir, danach Minuten je Versuch, Sitzung bleibt offen (818, Haken ab 400 Tsd.). B zwei Läufe zu je 30 bis 40 Minuten und so lange Wartezeit für 863; Jerry arbeitet derweil an Anderem.
- **Empfehlung:** „863a B“, ohne auf dich zu warten (Läufe gebe ich nach 480.1 frei: einer zum Nachstellen, einer nach der Behebung), und willst du es schneller, schreibst du von dir aus in Jerrys Sitzung „Binde alle Repos ein, die du zum Arbeiten benötigst“ (416.4a), dann gilt A ohne weitere Frage.

Antwort: …
