# Selbstarbeit und gemeinsame Zeit

Nur lesen, wenn der Nutzer Selbstarbeit vergibt („Tom, arbeite bis 17 Uhr selbstständig“, früher „Nachtpaket“), eine Weck-Sitzung startet oder gemeinsame Zeit ansagt. Stand: 11.10.2026, 13:40 (Berliner Zeit; Thema 22, vorher `NACHT.md`).

Ziel: Zeit ohne den Nutzer (Nacht oder Tag) wird voll genutzt, auch wenn eine Sitzung fertig ist, an die Nutzungsgrenze stößt oder abbricht. Zeit mit dem Nutzer geht an das, was ihn braucht.

## Stand

Jede Sitzung pflegt nur ihre eigene Zeile, nach jedem Schritt (Herzschlag), committet und pusht sofort auf `main`.

| Wer | Stand | Bis | Gestartet | Herzschlag | Gerade an | Zweig |
|---|---|---|---|---|---|---|
| Tom | – | – | – | 11.10., 11:10 | – | – |
| Jerry | – | – | – | 11.10., 11:30 | – | – |

Stand ist einer von: `läuft`, `wartet auf Grenze`, `fertig`, `blockiert`. „Bis“: Ende der Selbstarbeit (Berliner Zeit), danach Bericht.

## Zwei Arten von Aufgaben

Jede Sitzung führt unten im eigenen Abschnitt zwei Listen, mit Themennummer, Reihenfolge und „fertig, wenn …“ (messbar). Neue passende Aufgaben trägt sie laufend ein, Erledigtes streicht sie.

- **Vorrat für Selbstarbeit:** geht ohne den Nutzer. Nur schon Freigegebenes, Entwürfe (Standbilder, nichts ins Spiel ohne Freigabe), Werkzeuge, Tests, Aufräumen. Keine neuen Grundsatzentscheidungen; was offen ist, entscheidet die Sitzung nach ihrer Empfehlung und schreibt es in den Bericht. Aus der Merkliste nur, was der Nutzer ausdrücklich dafür freigibt.
- **Für gemeinsame Zeit:** braucht den Nutzer. Entwürfe ansehen und entscheiden, Builds auf dem Gerät testen, Freigaben (PR, Release), Rückfragen, neue Ideen besprechen. Sagt der Nutzer „ich habe zwei Stunden Zeit, lass uns gemeinsam arbeiten“, legt die Sitzung diese Liste vor (mit dem Ergebnis der letzten Selbstarbeit obenauf) und arbeitet sie mit ihm ab; Selbstarbeit läuft dann nicht.

## Ablauf der Selbstarbeit

### Feste Weck-Routinen (seit 11.10.)

Alle drei Stunden rund um die Uhr je Account eine Routine, die eine frische Sitzung startet: **Tom** 00:24, 03:24, 06:24, 09:24, 12:24, 15:24, 18:24, 21:24 („Tom Selbstarbeit HH:MM“), **Jerry** drei Minuten später (00:27, 03:27, … 21:27, „Jerry Selbstarbeit HH:MM“; umgestellt 11.10., 13:44: die drei alten behalten ihre Repo-Einstellung, 09:27, 12:27, 15:27, 18:27, 21:27 sind neu und brauchen die Einstellung vom Nutzer). Eine Routine arbeitet nur, wenn die eigene Zeile oben `läuft` oder `wartet auf Grenze` steht und „Bis“ noch nicht vorbei ist; sonst beendet sie sich sofort (kostet fast nichts). Der Abstand von drei Stunden sorgt dafür, dass nach jedem Zurücksetzen der Nutzungsgrenze (alle fünf Stunden) bald eine weitermacht.
- Jede Routine braucht einmal vom Nutzer (am PC im Browser, claude.ai, Routinen): Repository `tramour-cmyk/androidapp_rpg_bornim` auswählen, Freigabe auf automatisch. Fehlt das Schreibrecht, hängt die Sitzung das Repo selbst mit `add_repo` an.
- Ursache der Ausfälle in der Nacht 10./11.10.: von einer Sitzung angelegte Routinen bekommen kein Repo als Quelle mit; darum diese Einstellung von Hand.
- Letzte Tests: Tom 11.10., 11:27 (Push ok); Jerry 11.10., 11:40 (Push ok, keine Rückfragen).

### 1. Vergeben (mit dem Nutzer)

1. Offene Rückfragen, die das Paket berühren, klären; den Rest entscheidet die Sitzung nach ihrer Empfehlung (in den Bericht).
2. Paket im eigenen Abschnitt unten: Aufgaben aus dem Vorrat in **Reihenfolge**, je **fertig, wenn …**, dazu **Reserve** (mehr, als die Zeit schafft).
3. Eigene Zeile oben: `läuft`, „Bis“, Gestartet, Herzschlag; pushen; mit der ersten Aufgabe anfangen. Die laufende Sitzung arbeitet selbst weiter, solange sie kann (Erinnerungen mit `send_later`, etwa für Builds); die Routinen übernehmen nur nach Abbruch oder Grenze.

### 2. Während der Selbstarbeit

- **Nicht fragen, nicht warten.** Rückfragen sammeln, sie kommen in den Bericht. Ist eine Aufgabe blockiert: aufschreiben, nächste nehmen.
- **Kleine, sichere Schritte.** Nach jedem fertigen Schritt: Kerntests (`./gradlew -p core test`, Exit-Code prüfen), Commit und Push auf den eigenen Zweig, Herzschlag. So geht beim Abbruch höchstens ein Schritt verloren.
- **Nichts auf `main` außer Notizen.** Kein PR zusammenführen, keine Freigaben vorwegnehmen; Optisches nur als Entwurf (Standbilder mit Uhrzeit, Schalter im Testreiter).
- **Sparsam:** Filme nur, wo sich eine Bewegung sichtbar ändert; große Ausgaben gefiltert lesen; nach jeder Aufgabe prüfen, ob das Gespräch groß ist. Wenn ja: Übergabe schreiben, Zeile auf `läuft` lassen, Herzschlag setzen, Antwort beenden; die nächste Routine macht frisch weiter.
- **Zweig-Build:** höchstens einen pro Aufgabe; Build-Meldung wie in `CLAUDE.md`.
- **Paket fertig:** Reserve, dann weiter aus dem Vorrat. Ist nichts mehr da oder „Bis“ erreicht: Zeile auf `fertig`, Bericht, Antwort beenden.

### 3. Nutzungsgrenze

- Gilt je Account, setzt sich alle fünf Stunden zurück; Chat und Code teilen sie sich.
- Wird es knapp oder bricht ein Schritt ab: Übergabe (fertig, halb, nächster Schritt), Zeile auf `wartet auf Grenze`, pushen. Die nächste Routine macht weiter.

### 4. Weck-Sitzung (startet frisch, kennt das Gespräch nicht)

1. Sitzungsstart wie in `CLAUDE.md` (`tools/notiz.sh`), dann diese Datei und den eigenen Abschnitt in `docs/OFFEN.md`.
2. Eigene Zeile nicht `läuft`/`wartet auf Grenze`, oder „Bis“ vorbei, oder kein Paket: sofort beenden, nichts ändern.
3. **Läuft noch jemand?** Herzschlag oder letzter Commit auf dem eigenen Zweig jünger als 40 Minuten: sofort beenden, nichts ändern.
4. Sonst: Zeile auf `läuft`, Gestartet und Herzschlag setzen, pushen, am letzten offenen Punkt weitermachen (Übergabe lesen, Zweig auschecken, `git log`).
5. Keine neuen Routinen anlegen.

### 5. Bericht

Am Ende („Bis“ oder Vorrat leer) in den eigenen Abschnitt von `docs/OFFEN.md` und als Nachricht im Chat der letzten Sitzung: was fertig ist (mit Nummern), was halb, was blockiert und warum; Zweig und Zweig-Build mit Link und Testliste; Entwürfe als Standbilder mit Uhrzeit; selbst entschiedene und neue Rückfragen, nummeriert; Verbrauch (Grenze erreicht? welche Routinen haben gearbeitet). Die Punkte für den Nutzer wandern in „Für gemeinsame Zeit“.

## Text der Weck-Routine

> Weck-Sitzung Selbstarbeit für Chroniken von Bornim (Repo tramour-cmyk/androidapp_rpg_bornim), du bist **Tom**. (1) Repo nicht da: nach /home/user/androidapp_rpg_bornim klonen; lehnt der erste Push ab („not in this session's authorized repository set“), mit add_repo anhängen (access push) und noch einmal; geht Schreiben dann nicht: kurze Nachricht mit dem Fehler, beenden. (2) `docs/SELBST.md` auf `main` lesen; steht die Zeile „Tom“ nicht auf `läuft` oder `wartet auf Grenze`, ist „Bis“ vorbei oder kein Paket eingetragen: sofort beenden, nichts ändern. (3) Sonst nach `CLAUDE.md` und `docs/SELBST.md`, Abschnitt „Weck-Sitzung“. Der Nutzer ist nicht da: nichts fragen, nichts auf `main` außer Notizen, Rückfragen in den Bericht.

## Tom

**Vorrat für Selbstarbeit** (Reihenfolge):
1. **5.1 Häuser diagonal** fertig einbauen (Zweig `tom-dorf`): alle Häuser nach Grundriss und Hausstil, Fenster wie innen (5h.1), Glockenturm (5g). Fertig, wenn: Kerntests grün (`HouseWindowsTest`), Standbilder Tag/Nacht aus dem Spiel, Lauf-Film hinter einem Haus ohne Fehler.
2. **5.2 Dinge auf dem Platz** diagonal, je drei Varianten (Stände, Brunnen, Laternen, Bänke, Wäscheleine, Fässer), Musterblatt. Fertig, wenn: Blatt mit Uhrzeit.
3. **17 Nachschwingen** als Entwurf. Fertig, wenn: Sprungtest 0 Meldungen, Standbilder Stehen↔Gehen↔Drehen.
4. **14 Neustart-Haken** (Werkzeug, Zweig von `main`, PR). Fertig, wenn: Haken meldet über Schwelle, Test dokumentiert.

**Für gemeinsame Zeit:**
- 13: PR #20 (Ältester, Laden, Tempel) zusammenführen, falls noch offen.
- 20: PR #21 (Uhrzeit im ZIP), nach meiner Prüfung zusammenführen.
- 5.1: Standbilder ansehen, dann Zweig-Build auf dem Gerät testen.

**Paket:** – (keine Selbstarbeit vergeben)

## Jerry

**Vorrat für Selbstarbeit** (Reihenfolge):
1. **18 Runde 2:** 17 Klänge (Begegnung, Bemerkt, Hinterhalt, Held fällt, Feuer, Magie, Heilig, Heilung, Stärkung, Gift, Trank, Wurf, Vogel, Grille, Eule, Tropfen, Knistern) aus CC0-Aufnahmen, je drei Fassungen, nur als Hörproben. Fertig, wenn: Rezepte in `tools/klang/rezepte.py`, Quellen in `QUELLEN.md`, Proben-ZIP bereit, auf dem Zweig gepusht.
2. **18 Stimmen der übrigen Gegner** (Angriff, Schmerz, Tod, je drei Fassungen), nur als Hörproben. Fertig, wenn: wie 1.
3. **9i Übrige Gegner auf der Karte**, nur als Entwürfe (Standbilder mit Uhrzeit, alle Blickrichtungen). Fertig, wenn: Sprungtest und Kollisionsprüfung 0, Musterblatt.

**Für gemeinsame Zeit:**
- 18: Hörproben anhören und je Klang eine Fassung bzw. drei wählen, danach Einbau und Zweig-Build auf dem Gerät testen.
- 9i: Entwürfe ansehen und freigeben.
- 19e: ein konkretes Beispiel für „Bewegungen unrund“, falls dir eines auffällt.

**Paket:** –
