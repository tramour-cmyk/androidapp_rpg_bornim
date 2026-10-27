# 275 · Eine zentrale Vorgangsliste, und zwar jetzt?

Sokrates · 27.10., 15:02 · B Werkzeuge

**Frage (Chef 15:00):** „Können wir das Problem entschärfen, wenn es eine große Vorgangsliste gibt und ein Vorgangsarchiv, wo die erledigten Sachen einfach drinstehen? Löst das mit unser Problem? Ja, nein.“

**Votum:** Ja, wenn zwei Bedingungen erfüllt sind:
- (a) Der Stand steht in prüfbaren Feldern, und ein Werkzeug meldet, was überholt ist.
- (b) Deine Seite „Heute für dich“ erzeugt ein Werkzeug, keiner schreibt sie von Hand.

Die Liste allein behebt nur etwa ein Drittel der Leichen. Ich empfehle **Stufe 1 jetzt** (Werkzeug, Felder und deine Seite; etwa 2–3 Sitzungen Perikles). **Stufe 2** (die Vorräte werden zur reinen Übergabe) folgt eine Woche später, wenn Stufe 1 fehlerfrei läuft. Damit ändert sich der Termin aus 274: Dort steht „zentrale Liste nach dem Meilenstein“.

**Berührt:**
- 275 selbst (heute Kür im Ideenspeicher; würde Muss bei Perikles) und 274 (Termin);
- alle Rollen;
- die Werkzeuge `startbar.py`, `lauf.py`, `regelcheck.py`, `commit-pruefung.py`;
- „Heute für dich“ in `LISTE-ABNAHME-KAPITEL1.md`.

## Begründung

Du findest die Leichen als Erster, und das zählt nach unserem Maß als Fehler von uns allen (Haltung 7). Die Durchsicht zeigt: Die meisten Leichen entstehen nicht dadurch, dass es mehrere Listen gibt. Sie entstehen, weil ein Stand als freier Satz dasteht und keiner merkt, dass er überholt ist. Eine Liste macht das Abschreiben überflüssig. Erst ein Werkzeug, das prüft, macht die Leichen sichtbar, bevor du sie findest.

## Sachverhalt

Die Durchsicht von 14:45 (378, `LISTE-DURCHSICHT.md`) fand etwa 42 Befunde. Nach Ursache:

| Ursache | Beispiele | etwa | Behebt die eine Liste? |
|---|---|---|---|
| Doppelter Stand (Vorrat und `LISTE-VORGAENGE.md` laufen auseinander) | 296.2a, 353a, 348.7a, 348.13a, 149 noch „offen“; 24, 316, 348.2, 142.2, 134 ohne Vorratszeile | 11 | ja |
| Text verloren (Vorrat voll, Eintrag abgelehnt, oder Verweis ins Leere) | Jerrys Befunde an Tom; Doppelbuchung 7,10 $; „Zeile 26 in `ARBEIT-PROJEKT.md`“ gibt es nicht | 3 | ja |
| Bedingung erfüllt oder Frist vorbei, keiner merkt es | „ruht bis Urteil 348“ (10 Zeilen); Chefsache 348 geschlossen (Tom, Jerry); 339, 261.5, 167.6, 302, 236, 348.12i | 19 | **nein**, nur mit (a) |
| „beim Chef“ ohne Datei, Seite von Hand | Dorf r13b, Fledermaus, Wildschwein, 377.2; „Heute für dich“ mit sieben erledigten Punkten | 6 | **nein**, nur mit (b) |
| Sitzungen (Freigabe offen, nicht archiviert) | Tom und Perikles warten auf deinen Satz; acht Sitzungen | 3 | nein, nur über `lauf.py` in (b) |

Es gibt auch einen Gegenbeleg: Die Übersicht der Chefsache schreibt ein Werkzeug (`zug-index.py`), und sie war heute die einzige Seite, die stimmte. „Heute für dich“ schreibt Perikles von Hand, und diese Seite war falsch.

## Auswertung

**Was (a) heißt:** Der Stand besteht aus Feldern, die eine Maschine prüfen kann.
- `wartet: 348`: Ist 348 erledigt, meldet das Werkzeug die Zeile, und Ford startet den Besitzer.
- `bis: 31.10.`: Ist das Datum vorbei, passiert dasselbe.
- `Chef: ansehen/3761`: Fehlt die Datei, lehnt die Commit-Prüfung ab. Damit gibt es kein „beim Chef“ ohne Vorlage mehr.

**Was (b) heißt:** „Heute für dich“ (entscheiden, ansehen, tun, testen) entsteht aus der Liste, der Chefsache und den offenen Freigaben der Sitzungen (`list_sessions`).

**Stärkstes Gegenargument:** Wir stecken mitten im Umzug nach Godot (6 von 76 Punkten), und die Oberste Direktive heißt Kapitel 1. Ein Umbau, der jede Rolle und jedes Werkzeug berührt, bringt neue Fehler. Übergänge waren bisher unsere teuerste Fehlerquelle (zwei Quellen gleichzeitig, alte Regeln in den Rollendateien). Genau deshalb haben wir am 21.10. „nach dem Meilenstein“ gesagt.

**Warum ich trotzdem für jetzt bin:**
- Der Meilenstein ist Wochen entfernt, die Pflege kostet aber schon täglich: eine Durchsicht wie heute (etwa 2–4 $ und deine Nerven), dazu Arbeit, die hängt (Jerrys Befunde kamen nie bei Tom an; 348.12i hält vermutlich den Protofactor-Kauf auf), dazu Vorlagen, die du nicht bekommst.
- Stufe 1 bricht nichts: Das Werkzeug schreibt zuerst beide Orte und prüft nur. Versagt es, bleibt der heutige Weg.

**Was ich nicht empfehle:** eine Riesendatei ohne Werkzeug, in die alle von Hand schreiben. Das bringt Zugriffskonflikte und Formatfehler und verlagert die Leichen nur.

## Folgerungen, wenn ja

1. Aus der Kür 275 wird ein Muss bei Perikles. Vorgangsarchiv: „ersetzt den Termin aus 274“.
2. **Stufe 1, jetzt (Perikles):**
   - `tools/vorgang.py` (anlegen, Stand setzen, übergeben) schreibt Liste und Vorrat zugleich;
   - Felder `wartet:`, `bis:`, `Chef:`;
   - `regelcheck.py` meldet erfüllte Bedingungen, abgelaufene Fristen und „Chef“ ohne Datei an Ford, Ford startet den Besitzer;
   - „Heute für dich“ erzeugt ein Werkzeug, mit den Freigaben, auf die Sitzungen warten.

   Diogenes prüft vor dem Einsatz. Die Schätzung macht Perikles; meine Annahme von 2–3 Sitzungen und etwa 20–35 $ ist ungeprüft.
3. **Stufe 2, eine Woche später, wenn sauber:**
   - Die Vorräte enthalten nur noch die Übergabe und „Zu ‹Nr›“.
   - `LISTE-VORGAENGE.md` wird die einzige Quelle, die Ansicht je Rolle ist eine Suche.
   - Bauplan nach `LISTE-ZENTRALE-VORGAENGE-275.md`.
4. Das Vorgangsarchiv (Entschiedenes) bleibt. Neu Erledigtes bleibt als Stand „erledigt“ in der Liste. `LISTE-VORGAENGE-ARCHIV.md` bleibt für das Alte und wird nicht weiter gefüllt.

**Sag:** „275 ja“ (beide Stufen), „275 nur Stufe 1“ oder „275 noch nicht“.

Antwort:
