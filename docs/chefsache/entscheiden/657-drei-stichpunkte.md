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
