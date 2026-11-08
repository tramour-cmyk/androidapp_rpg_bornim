# 657 · Regeln radikal kürzen: eine Seite für alle · Sokrates · 08.11., 15:1x

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/CLAUDE.md

**Anlass:** Chef 14:58 „radikal kürzen“; 15:05 zur ersten Fassung: „greift mir … zu kurz … lebendige, düstere Welt … Variationen … Signatur … Licht und Schatten, Tuscheeffekt … wir sind ein Team, welche Funktion hat, wer sich an wen wenden kann … wie die Aufgaben zu erledigen sind … kurz und knackig“.

**Frage:** Ersetzt die Seite unten `CLAUDE.md` (heute mit den Rollendateien etwa 75 KB, rund 300 Regeln)? Rollendateien schrumpfen auf ihre Zeile in der Tabelle plus Handwerk; alles Übrige geht nach `docs/alt/` (in Git). `DESIGN-STIL.md` bleibt als Nachschlagewerk für Einzelheiten.

**Votum Sokrates: ja, mit drei Bedingungen (unten).**

---

## Entwurf: so sähe `CLAUDE.md` aus

**Chroniken von Bornim** · BornWire TCS · Android-Rollenspiel in Godot nach unserem Regelwerk BRS.

### Ziel
Kapitel 1 fertig: ohne Fehler, gut aussehend, düster, immersiv durch Klang, Musik, Kampf und die Freiheit des Spielers. Qualität vor Eile, kein Termin. Nie Werbung, Beutekisten, Wartezeiten gegen Geld.

### Unser Stil (gilt für alles, was man sieht oder hört)
1. **Düster und erwachsen**, nie niedlich, nie quietschbunt; Monster gefährlich; Dunkelheit erlaubt.
2. **Signatur:** Licht hat immer eine sichtbare Quelle (warm im Lichtkreis, kaltes Blauschwarz außerhalb) · Tuschelinie um jede Figur und jedes Ding, im Schatten dick, im Licht dünn · nur Gold, Feuer und Magie glänzen.
3. **Lebendig:** keine Figur steht starr (atmet immer, eigener Takt, nie im Gleichtakt); Orte leben (Rauch, Flackern, Staub im Licht, Vögel, Wind); Effekte bietest du von selbst an.
4. **Abwechslung:** alles, was wiederkommt (Gegner, Bewegung, Klang, Gesprächszeile), in mindestens drei Varianten.
5. **Klang:** echte Aufnahmen, man hört, was da ist; Musik orchestral und düster, Dorf mittelalterlich.
6. **Eine Sicht:** diagonal; schwarz-gold in der Oberfläche, eine Schrift (Alegreya).
7. **Muster statt Neuerfinden:** wer etwas baut, das es schon gibt, nimmt das abgenommene Muster und schaut es an, bevor er anfängt: Fenster und Rückfragen ohne Kasten (549a), Zwischensequenz wie das Intro mit leichten Bewegungen (613), Zeichen wie die Reiterzeichen (326), Hauptmenü (292). Die Muster mit Bild stehen in `DESIGN-STIL.md` „Muster“; neue Muster trägt Homer nach deiner Abnahme ein.

### Das Team
| Wer | Aufgabe | an ihn wendest du dich bei |
|---|---|---|
| **Chef** | entscheidet Grundsätzliches, testet jeden Build | allem, was Story, Aussehen, Balance, Geld betrifft (über die Chefsache) |
| **Homer** | Story, Texte, Stil | jedem fehlenden Text, jeder Stilfrage |
| **Perikles** | Wochenziel, Reihenfolge, Abläufe, Kosten | Vorrang, Regeln, Werkzeugen |
| **Sokrates** | berät den Chef: Strategie, Regelwerk, Markt | Grundsatzfragen, die der Chef vorgelegt bekommt |
| **Diogenes** | prüft `main` gegen die Abnahmeliste, ändert nichts | – |
| **Ford** | startet Sitzungen, verteilt, was keinem gehört | „ich brauche jemanden“ |
| **Tom** | Leute, Dorf, Innenräume, Technik | Dorf, Figuren, Oberfläche |
| **Jerry** | Monster, Höhle, Kampf, Klang | Kampf, Gegner, Klang |

Jeden gibt es einmal. Wer du bist, sagt deine erste Nachricht. Braucht ein anderer etwas: Vorgang mit ihm als Besitzer.

### Wie eine Aufgabe läuft
1. **Liste:** jede Aufgabe ist ein Vorgang in der Vorgangsliste (`vorgang.py`); was der Chef sagt, steht sofort dort, mit seinem Wortlaut.
2. **Bauen:** so, dass Welt, Licht und Klang stimmig und natürlich wirken (Stil oben); fehlt ein Text, fragst du Homer, nie erfinden.
3. **Selbst ansehen:** du spielst und siehst dein Ergebnis selbst an; zeigt es nicht, was es soll, schickst du es nicht.
4. **Vorlegen:** Bild sofort an den Chef (Telegram), Frage als Datei in der Chefsache; nur Bauten mit Test des Chefs kommen auf `main`.
5. **Abschließen:** Antwort des Chefs mit Zeit sofort ins Vorgangsarchiv, Vorlage im selben Schritt aus der Chefsache.

### Feste Grenzen
- Story, Aussehen, Balance, Geld entscheidet der Chef; alles andere der Besitzer des Vorgangs.
- Nie committen: Keystore, Passwörter; fremde Inhalte nur mit freier oder gekaufter Lizenz; kein Force-Push; Release nur auf Zuruf.
- Im Chat nur, was der Chef entscheiden, tun oder prüfen kann; Deutsch, Berliner Zeit, Name und Zeit vor jeder Nachricht.

---

## Auswertung (Beratung, Chef 15:14: „überhaupt nicht beraten … Bringt uns das etwas? … Risiken?“)

**Befund heute:** Keiner der heutigen Fehler kam daher, dass jemand eine Regel nicht kannte. 499: die Antwort kam an, wurde aber in den Vorrat statt ins Archiv geschrieben. 623.6: der Ersteller durfte sein Bild nicht ansehen (Regel 300). 656: deine Frage zu 623.5 wurde nirgends eingetragen. Nummer 660 doppelt: zwei Sitzungen zogen gleichzeitig dieselbe Nummer. Alle vier passierten an einer **Übergabe**, nicht beim Bauen.

**Was 657 bringt (sicher):**
- Jede Sitzung liest beim Start etwa 75 KB Regeln; mit einer Seite bleibt Aufmerksamkeit für das Spiel (Stil, Muster) und es spart Guthaben bei jedem Start.
- Widersprüche verschwinden (heute: „Zwischensequenzen ohne Animation“ gegen dein Wort, Regel 300 gegen „selbst prüfen“ im Leitbild).
- Die Rollen sind auf einen Blick klar: wer was, an wen wenden.

**Was 657 allein nicht löst (klar absehbar):**
- Die Übergabefehler oben. Weniger Text macht sie seltener, nicht unmöglich. Sicher wird es nur, wo ein Werkzeug den Schritt selbst macht: deine Antwort → Archiv und Vorlage weg in einem Befehl (Vorschlag: `vorgang.py antwort <Nr> "<Wortlaut>"`), Daumen auf Telegram (658), Nummern ohne Doppelvergabe.
- Die Haken: sie hängen heute an jede Antwort Regelnummern (heute zweimal falscher Alarm des Chefsache-Hakens, Abkürzungsprüfung). Kürzt man den Text und lässt die Haken, bleibt das Rauschen.

**Risiken:**
1. **Verlorene Entscheidungen:** in den 75 KB stecken Urteile von dir; beim Kürzen geht eines verloren (Bekannte Fehler: „über drei Übergaben verloren“). Gegenmittel: Diogenes prüft vorher jede Entscheidung im Archiv: steht sie noch in `DESIGN-…` oder auf der Seite?
2. **Handwerk verschwindet:** wie man einen Lauf startet, einen Build baut, ein Release macht, steht heute in den Rollendateien. Landet das in `docs/alt/`, raten die Sitzungen. Gegenmittel: Handwerk bleibt als `LISTE-…`, verlinkt von der Seite.
3. **Umbau-Unruhe:** ein Tag, an dem Perikles umschreibt und nichts gebaut wird. Gegenmittel: in einem Schritt, Rückweg über Git.
4. **Es wächst wieder:** jede neue Panne erzeugt einen neuen Satz. Gegenmittel: Obergrenze eine Seite; neuer Satz nur, wenn einer geht (Perikles hält das).

**Jobs:** heute steht je Rolle eine Seite, aber kein Ergebnis. Auf der Seite bekommt jede Rolle drei Dinge: Aufgabe, **woran man sieht, dass sie erledigt ist**, an wen man sich wendet. Beispiel Sokrates: Aufgabe „berät dich“; erledigt, wenn du zu einer Frage Nutzen, Risiken, stärkstes Gegenargument und eine Empfehlung hast; **nicht** meine Aufgabe: Umsetzungsentwürfe schreiben (das ist Perikles). Diesen Fehler habe ich bei 657 selbst gemacht.

**Woran wir merken, ob es wirkt:** Diogenes zählt schon, was du als Erster findest. Eine Woche vorher gegen eine Woche nachher; wird es nicht weniger, zurück über Git.

**Soll noch einer draufschauen?** Ja, Diogenes, vor deinem „ja“: Risiko 1 und 2 prüfen (geht etwas Entschiedenes oder Handwerk verloren?), etwa eine Sitzung.

## Votum
**657 ja mit drei Bedingungen:** (a) Diogenes prüft vorher auf Verlorenes; (b) die Übergaben bekommen Werkzeuge (Antwort ins Archiv in einem Befehl, 658, Nummern), sonst bleibt die Hälfte des Nutzens liegen; (c) Formhaken fallen mit. Ohne (b) wäre mein Votum „noch nicht“: kürzer, aber dieselben Pannen.

## Folgerungen
„657 ja“: Diogenes prüft den Entwurf gegen Archiv und Rollendateien; danach schreibt Perikles die Seite (Wortlaut ändern nur mit dir), Handwerk in `LISTE-…`, Rest nach `docs/alt/`, Formhaken raus, `vorgang.py antwort`; in einem Schritt.

## Prüfung Diogenes (08.11., 15:3x; Auftrag Chef 15:20: „das ganze Konzept … gut durchprüfen … noch nicht zur Umsetzung“)

**Urteil: Die Richtung trägt, der Entwurf in dieser Fassung nicht.** Eine Seite für Ziel, Stil, Team und Ablauf ist richtig. Aber der Entwurf widerspricht zwei Entscheidungen von heute, lässt Regeln mit rechtlicher Wirkung weg, und Werkzeuge lesen aus den Dateien, die schrumpfen sollen. Vor einem „ja“ müssten die Punkte 1 bis 4 unten erledigt sein.

**1. Der Befund trägt nur zur Hälfte.** Sokrates: alle Pannen von heute an Übergaben, keine aus Unkenntnis. Nachgezählt an den Vorgängen, die du heute neu angestoßen hast:
- an einer Übergabe: 656 (Antwort zu 623.5 verloren), 499 (Antwort in den Vorrat statt ins Archiv, Archiv 14:5x), 660 (Nummer doppelt vergeben, Blende auf 661 verschoben, Commit 15:14). Das stimmt.
- **beim Bauen**, weil Wissen fehlte oder nicht angesehen wurde: 661 (Blende nicht an das Muster „ohne Kasten“ angeglichen), 659 (Regel „Zwischensequenzen ohne Animation“ gegen dein Wort), 647 (alter Code erst nach dem Bauen gelesen, aus 512 und 499), 653 (Halt je Figur nachgemessen statt einmal festgelegt), 654 und 655 (dein Wort 14:51: „warum entsteht überhaupt das Falsche?“).
- Folge: der Entwurf löst die zweite Hälfte teilweise selbst (Muster, Selbst ansehen). Die erste Hälfte löst er nicht; da hat Sokrates recht: nur Werkzeuge (Bedingung b).

**2. Widersprüche zu Entscheidungen von heute.**
- „Vorlegen: Bild sofort an den Chef“ gegen **646** (12:34: „Bewegung … geht halt nur ein Film“). Richtig wäre: Sitz und Aussehen als Bild, Bewegung als Film.
- „Selbst ansehen … zeigt es nicht, was es soll, schickst du es nicht“ gegen **646** und **621 A**: nach der einen Probe geht das Ergebnis an dich, auch mit offenen Punkten. Mit dem Entwurf hängt eine Sitzung fest: zurückhalten darf sie, neu laufen lassen darf sie nicht (der Haken hält den zweiten Lauf an, heute geprüft). „Selbst ansehen“ selbst stimmt mit **655** (15:04) überein.
- Was du entscheidest: Entwurf „Story, Aussehen, Balance, Geld“; heute zusätzlich **Spielgefühl, Umbauten über mehrere Orte oder beide Teams, Code auf `main`**. Diese drei fehlen.
- Doppelt mit dem Leitbild: der Stilteil wiederholt `DESIGN-LEITBILD.md`, und dort steht „bei Widerspruch gilt das Leitbild“. Zwei Stellen für denselben Inhalt gegen „jeder Text an einem Ort“. Vorschlag: die Seite verweist auf das Leitbild und nennt nur die Signatur, oder das Leitbild geht in der Seite auf, nicht beides. Das Leitbild verweist außerdem auf „`CLAUDE.md` Fremde Inhalte“ und „Erst reden, dann bauen“; beides fehlt im Entwurf.

**3. Was fehlt (Auswahl, verifiziert).**
- **Rechtliches:** Lizenzregel nur noch „freie oder gekaufte Lizenz“; dein Wort 348.12c (kommerziell, jede Engine, unbefristet, ohne Nennung, ohne Umsatzgrenze; kauft nur du; Rohdateien nur im Zweit-Repo; Quelle je Datei) und der Hinweis „SRD 5.1 · CC BY 4.0“, bis alles SRD-Abgeleitete ersetzt ist. App-Kennung `de.bornim.game` nie ändern. Das muss wörtlich bleiben.
- **Spiel:** aus dem Leitbild fehlen „Grinden darf man, muss man nie“, Kampf mit echter Wahl, „du wirst, was du tust“ (BRS), flüssig auf echten Geräten, sieben Kapitel.
- **Ablauf:** 621 A (eine Probe je Aussehen-Thema, sonst Rückfrage mit Wegen und Kosten), 654 Systemfrage vor dem Bauen (14:42), 647 alter Code vor dem Bauen, 511 Probebild vor dem Film, 21 bis 7 Uhr nur Technik, Notizen nur auf `main`, Telegram-Meldung, Idee heißt prüfen statt bauen, „noch nicht“ hält auf, Vorentscheid-Rechte von Perikles, Homer, Sokrates („Entscheidet selbst“ steht nur in deren Rollendateien).
- **Haltung:** prüfen statt zustimmen, nicht raten, Bekannte Fehler, Begriffe (Glossar 648). Jobs mit „erledigt, wenn“ nennt die Auswertung, der Entwurf hat sie noch nicht.
- Weitere Entscheidungen ohne Ort: siehe Helferbefund unten.

**4. Werkzeuge lesen aus Dateien, die schrumpfen sollen.** Wer das übersieht, legt den Betrieb still:
- `notiz.sh` erkennt Tom und Jerry an den Kennungen in `ROLLE-BETRIEB.md` (Zeile 3); fehlen sie, meldet jede Teamsitzung „unbekannt“ und fängt nichts an.
- `regelcheck.py` prüft Überschriften in `ROLLE-ENTWICKLUNG.md`, nach denen der Startbefehl liest (347); `lauf.py` schickt neue Sitzungen dorthin (433).
- `regelcheck.py` und `commit-pruefung.py` messen `CLAUDE.md` (Grenze 15 KB); `neustart-haken.py` liest die Kernregeln.
- Vor dem Umbau: Liste aller Werkzeuge, die `CLAUDE.md` oder `ROLLE-…` lesen, und je eine Zeile, wohin.

**5. Haken: welche nur Form prüfen.**
- Nur Form (können fallen): Zeitstempel und Entschuldigung in jeder Antwort zählen (`zug-haken.py`), Chefsache-Erkennung im Antworttext (Wortmuster, heute zweimal falscher Alarm), Größen von Vorräten, Übergaben, Listenzeilen (`regelcheck.py`, `commit-pruefung.py`), Tabellenzeile im Vorrat, Uhrzeit in der Zukunft, Abkürzungsprüfung in `meldung.sh` (aber: keine Abkürzungen ist dein Wunsch 485, dann als Satz auf der Seite).
- Inhalt (müssen bleiben): Probezählung, Filmsperre, Figurensperre, alter Code vor dem Push (`probelauf.py`: 621 A, 646, 511, 513.1, 647), **Sperre gegen gekaufte Rohdateien** (`commit-pruefung.py`, Lizenz), Arbeiten solange Startbares da ist (`weiter-haken.py`), Neustart bei vollem Gedächtnis (`neustart-haken.py`), Antwort im Archiv und Vorlage weg im selben Commit (383.3).
- „Formhaken fallen mit“ nur mit dieser Liste beschließen, sonst fällt die Kaufsperre mit.

**6. Was sicher nicht klappt.**
- **„Obergrenze eine Seite, neuer Satz nur, wenn einer geht“** gibt es schon (Haltung 6 „Regelbilanz“, Bekannte Fehler höchstens 10 Zeilen); `CLAUDE.md` ist trotzdem auf 15 KB gewachsen. Ohne Werkzeug, das die Seite misst und den Commit anhält, wächst sie wieder. Das wäre ein Formhaken, der bleiben muss.
- **„in einem Schritt“** über `CLAUDE.md`, acht Rollendateien und die Werkzeuge aus 4: an einem Tag, an dem zugleich Build 269 offen ist und 650 docs aufräumt. Besser: erst Werkzeuge (Bedingung b und Punkt 4), dann die Seite.
- **„Wortlaut ändern nur mit dir“** und „Diogenes prüft vorher jede Entscheidung im Archiv“: das Archiv hat 400 KB; vollständig in einer Sitzung geht nicht. Machbar: Prüfung gegen `CLAUDE.md` und Rollendateien vollständig (die stehen ja zur Streichung), Archiv nur nach Stichworten (wie hier).

**Empfehlung:** „noch nicht“ zur Seite in dieser Fassung; ja zur Richtung. Reihenfolge: (1) Werkzeuge an den Übergaben (Antwort ins Archiv in einem Befehl, 658, Nummern ohne Doppelvergabe), (2) Entwurf korrigieren nach 2 und 3, Rechtliches wörtlich, Jobs mit „erledigt, wenn“, (3) Werkzeugliste nach 4 und Hakenliste nach 5, (4) dann Umbau, mit Messung Erstfunde eine Woche vorher gegen nachher (zähle ich).
**Stärkstes Gegenargument zu meinem „noch nicht“:** jede Woche mit 75 KB Regeln kostet beim Start Guthaben und Aufmerksamkeit, und Korrekturen am Entwurf sind in einer Stunde gemacht. Darum: nicht warten, bis alles perfekt ist, aber Punkte 2 bis 4 vor dem Umbau.

**Helferbefund (15:28, Abgleich `CLAUDE.md` und Rollendateien gegen den Entwurf, Archiv nach Stichworten; ungekürzt in den Punkten, gekürzt im Wortlaut):**
- *Weitere Widersprüche:* „nur Bauten mit Test des Chefs auf `main`“ streicht die Ausnahme Kleinigkeit ohne Spiellogik nach deinem Ja (201a). „Zurückhalten“ widerspricht auch 396 (28.10.: „schickt's mir doch dann einfach“) und 480 (Film geht nach dem freigegebenen Lauf immer an dich). Was du entscheidest, steht in `ROLLE-BERATUNG.md` noch weiter: Release, neue Rollen oder Accounts, Geld über etwa 10 $ oder laufende Kosten. „Jeden gibt es einmal“ mit acht Rollen: Spike und Tuffy (394, 433) fehlen. „Vorgang beim Chef“ (480) fehlt im Glossar; 648 ist Kür, weil die Begriffe „bis dahin in `CLAUDE.md`“ stehen.
- *Entscheidungen, die nur in Rollendateien oder `CLAUDE.md` leben* (fielen sie nach `docs/alt/`, liest sie keiner mehr): 646, 228 (Aussehen erst als Bild, nur mit Datei in der Chefsache), 373/373a (21–7 Uhr nur Technik; zwei, drei Fassungen in einem Bild), Testbitte nur mit Build (17.10.), 408 (Bestand, frei im Netz, Kaufvorschlag, Eigenbau), 647, 654, BRS-Nachschlagewerk bei Sokrates (02.11.), 464 rote Läufe an dich, 369.1, 516, 261.5 (Ford: Archivieren von Sitzungen), 196 Muss vor Kür vor Leerlauf, 341 Zielvereinbarung, Kostenauswertung mit Sparvorschlägen (17.10.), 486, 277 (jedes Bild der Chefsache auch auf Telegram), 75 und 374 (mein Auftrag); nur in `CLAUDE.md`: 436 Sitzungsnamen, 412 ein Vorgang je Thema, 383 „jetzt“ im Titel, 315 „1, 2, 3 richtig verstanden?“, „wie in einer Firma“ (21.10.), generisches Maskulinum, alle sechs Bekannten Fehler, 418 „fertig ist, was die Abnahmeliste erfüllt“ (steht noch im Projektplan).
- *Verweise ins Leere:* `DESIGN-ABNAHME.md` schickt für Abläufe nach `CLAUDE.md`; `LISTE-QUELLEN.md` für die Lizenz ebenso.
- *Handwerk ohne Ziel:* Projekt (etwa 2,6 KB: Wochenziel, Kosten, Tagesbericht, Doppelpack) und Beratung (etwa 2,3 KB: Chefrunde, Archiv eintragen) haben noch keine `LISTE-…`; Betrieb (3,6 KB), Entwicklung (4,6 KB), Prüfung (3,8 KB) müssen in ihre vorhandenen Listen.
- *Nebenbefund:* `CLAUDE.md` Bekannte Fehler „Helferbefund … nachsenden (396)“ und `DESIGN-ABNAHME.md` „(300)“ sind seit 655 veraltet (an Perikles mit 655.1).
