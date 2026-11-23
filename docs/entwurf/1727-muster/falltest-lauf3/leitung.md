# Antworten Leitung (Falltest Lauf 3, 22.11., 07:16)

Ladetext: `lt3/sockel.md`, `lt3/kern-leitung.md`. Nachgesehen (nur lesend): `tools/rueckmeldung.py` (Obergrenze B), `tools/lauf.py` (`sokrates_zeilen`, `hoechstdauer_zeilen`), `docs/VORGANGSARCHIV.md`, `docs/chefsache/MUSTER.md`, `vorgang.py --hilfe`, Liste zu 1694, 1621, 1657.

## L10 · zweites „steckt fest“ zu 1694 (Stab durch die Knöchel)

### Lage, belegt

- Zweites „steckt fest“ in der Vorgangsdatei 1694 (erstes: 752 von 1540, `04bf8ffc1`; zweites: 610 von 1540, `d8dce68a2`, versucht: Griffpunkt je Waffe). `tools/rueckmeldung.py`: `MAX_FEST = 2`, also **Obergrenze B**: das Werkzeug setzt „Zustand: ruht, beim Chef“ und schreibt an mich „an den Chef: Chefsache anlegen, nicht selbst lösen“.
- Archiv 21.11., 20:59 (Chef an Sokrates): „… Ergo, es wird was angelegt für die Chefsache und du trägst es mir vor.“ → zweites „steckt fest“: Sokrates legt die Chefsache an und trägt sie vor.
- Also gebe ich **keinen dritten Versuch frei**, auch wenn mein Kern sagt „du entscheidest“: Werkzeug und Chefentscheid gehen vor, und weitere Läufe sind Geld (Vorbehalt Chef).

### Was ich tue, der Reihe nach

1. Start (Kern „Gedächtnis“, „Start“):
   ```
   cat /home/user/bornim-main/docs/leitung/gedaechtnis.md
   ```
   Ausgabe: Datei fehlt (`docs/leitung/` gibt es nicht). Startmeldung im Chat:
   > **Sokrates** [22.11., 07:16] Sokrates, opus, Aufwand hoch.

   (keine „Letzte Antwort“, da kein Gedächtnis.)

2. Zeile lesen und annehmen:
   ```
   cd /home/user/bornim-main && git pull --ff-only
   python3 tools/vorgang.py offen Sokrates
   python3 tools/vorgang.py annehmen 1694-Ü<n>
   ```
   (`<n>` = Kennung aus der Ausgabe; im Test steht keine Zeile in der echten Datei, `vorgang.py offen Sokrates` gab „0 Zeile(n)“.)

3. Bestand und Archiv (Haltung „vorher Bestand und Archiv suchen“):
   ```
   python3 tools/vorgang.py 1694
   cat docs/vorgang/1694.md
   grep -n "1694" docs/VORGANGSARCHIV.md | head -20
   git show --stat d8dce68a2; git show --stat 04bf8ffc1
   git log --oneline -5 -- docs/vorgang/1694.md
   grep -n "Zustand: ruht, beim Chef" docs/vorgang/1694.md
   ```
   Ich prüfe: Hat das Werkzeug „ruht, beim Chef“ gesetzt? Steht meine Freigabe „ein Versuch, Griffpunkt je Waffe“ oben im Archiv (Kern: „einen Entscheid, auch deinen, oben ins Vorgangsarchiv“)? Fehlt eins, melde ich es (Sockel 5) an den Besitzer, das Büro, statt es selbst zu setzen; die Liste pflegt der Disponent.

4. Vorlage als Entwurf außerhalb von `entscheiden/` schreiben (MUSTER: „Entwurf außerhalb der beiden Ordner schreiben, dann vollständig anlegen“): `<scratchpad>/1694-griff.md`, Inhalt unten.

5. Gegenprüfen (Kern: „was … in `chefsache/entscheiden/` geht, prüft vor der Vorlage ein frischer Helfer gegen Repo und ganzen Entwurf, ohne deine Begründung“): frischen Helfer starten mit nur diesem Auftrag:
   > Prüfe `<scratchpad>/1694-griff.md` gegen `/home/user/bornim-main` (Vorgangsdatei `docs/vorgang/1694.md`, `docs/LISTE-VORGAENGE.md` Zeilen 1694, 1621, 1657, `docs/VORGANGSARCHIV.md`, `docs/chefsache/MUSTER.md`, `tools/rueckmeldung.py`). Je Satz: stimmt die Quelle, fehlt eine Option, ist ein Chefwort nicht wörtlich mit Zeit? Gib nur Befunde zurück, nummeriert.

   Je Befund ein Wort (stimmt, Einwand, Frage), Stimmiges einbauen, neuer Helfer, bis nichts Neues kommt. Dann Form:
   ```
   wc -c <scratchpad>/1694-griff.md
   python3 tools/vorlage_pruefen.py <scratchpad>/1694-griff.md
   ```

6. Anlegen, committen, pushen (Notiz, nur Eigenes):
   ```
   cp <scratchpad>/1694-griff.md docs/chefsache/entscheiden/1694-griff.md   # mit Write, nicht cp (Notizen nur mit Edit/Write)
   git add docs/chefsache/entscheiden/1694-griff.md
   git commit -m "1694: Chefsache nach zweitem „steckt fest“ (Obergrenze B, Archiv 21.11., 20:59)

   Co-Authored-By: …
   Claude-Session: …"
   git push
   ```

7. Telegram (lautlos? nein: der Chef ist dran, also `--laut`):
   ```
   /home/user/bornim-main/tools/meldung.sh Sokrates "1694 (Stab durch die Knöchel): zweiter Versuch wieder rot, 610 von 1540 Fällen falsch (Commit d8dce68a2; erster 752 von 1540). Werkzeug hat 1694 angehalten (zweites „steckt fest“).\nEntscheiden: [1694](cs:1694). Votum „1694 A“: kein dritter Bauversuch; erst ohne Bau die 610 Fälle nach Figur und Gegenstand ordnen und an den zwei größten Gruppen die Ursache am Einzelbild zeigen, ein Lauf.\nBisher zwei Läufe, 11,40 Dollar (Kopf der Vorgangsdatei)." --laut
   ```

8. Chat (Ergebnis zuerst):
   > **Sokrates** [22.11., 07:xx]
   > **Entscheiden: 1694 (Stab durch die Knöchel)**, `docs/chefsache/entscheiden/1694-griff.md`: zweiter Versuch wieder rot (610 von 1540). Votum „1694 A“: kein dritter Bauversuch, erst die 610 Fehler ohne Bau aufschlüsseln, ein Lauf. Gegenargument: der Fortschritt 752 → 610 spricht für einen gezielten dritten Versuch; entkräftet dadurch, dass die Aufschlüsselung genau diesen Versuch zielt.
   > Gegengeprüft: docs/chefsache/entscheiden/1694-griff.md, <Byte vorher> → <Byte nachher>, Ladesumme <?>; Befund 1 <stimmt|Einwand|Frage>, Befund 2 …

9. Zeile schließen: `python3 tools/vorgang.py erledigt 1694-Ü<n>`.

10. Gedächtnis (höchstens 3 KB) anlegen: `docs/leitung/gedaechtnis.md` mit Write:
    ```markdown
    # Gedächtnis Leitung

    ## Lehren
    - Zweites „steckt fest“ = Obergrenze B: nicht selbst freigeben, Chefsache anlegen und vortragen (Archiv 21.11., 20:59; rueckmeldung.py MAX_FEST).

    ## Offene Fäden
    - 1694: Chefsache `entscheiden/1694-griff.md` liegt beim Chef (22.11.); 1621, 1657 warten auf 1694.

    ## Übergabe
    - Getan: 1694-Ü<n> erledigt, Chefsache 1694 angelegt und gemeldet. Nachfolger: –
    ```
    commit, push. Werkzeugsperre schlage ich nicht vor: sie besteht schon (Obergrenze B).

### Datei `docs/chefsache/entscheiden/1694-griff.md` (voller Inhalt)

```markdown
# 1694 · Griff: kein dritter Bauversuch, erst die 610 roten Fälle ohne Bau aufschlüsseln?
Sokrates · 22.11., 07:20 · E Figuren · zweites „steckt fest“ der Fachkraft (Obergrenze B)
Kurz: Nach zwei roten Läufen (752, dann 610 von 1540) erst Ursache je Figur und Gegenstand zeigen, ohne Bau; dann Vorlage zum gezielten Bau.
Beim Chef, weil: Geld (weitere Läufe an 1694 nach zweitem „steckt fest“; Archiv 21.11., 20:59: zweites „steckt fest“ trägt Sokrates dem Chef vor)

Geprüft an: `d8dce68a2` (zweiter Versuch), `04bf8ffc1` (erster)

**Frage:** Vorgang 1694 soll erreichen, dass jede Figur jeden gehaltenen Gegenstand sichtbar in der geschlossenen Faust hält. Die Prüfung über alle Figuren und Gegenstände (1540 Fälle) war nach dem ersten Bau rot (752 falsch), nach dem zweiten, von mir freigegebenen Versuch („ein Versuch, Griffpunkt je Waffe“) wieder rot (610 falsch). Das Werkzeug hat 1694 angehalten. Soll vor einem dritten Bau erst ohne Bau gezeigt werden, wo und warum die 610 Fälle scheitern?

**Votum:** „1694 A“: ein Lauf ohne Bau: die 610 roten Fälle aus `d8dce68a2` nach Figur und Gegenstand ordnen, an den zwei größten Gruppen die Ursache am Einzelbild zeigen (beschriftet, Spielkamera); danach neue Vorlage mit gezieltem Bau.

**Berührt:** 1621 Zweihänder (Spike) und 1657 Stab (Tom) warten auf 1694 (Vorgangsliste); Arbeitsplaner (Auftrag), Fachkraft (Lauf).

**Begründung:** Chef 18.11., 17:01: „Als Systemlösung, genau. … dass wir Sachzusammenhänge erkennen und deswegen auch Lösungen suchen und nicht ständig einzeln rumflicken.“ Zwei Bauversuche haben die Zahl gesenkt, aber nicht gezeigt, warum 610 Fälle scheitern. Ein dritter Bau ohne Ursache wäre Rumflicken.

**Sachverhalt:**
- Erstes „steckt fest“: 752 von 1540 falsch, Commit `04bf8ffc1` (Vorgangsdatei 1694, Rückmeldungen).
- Zweites „steckt fest“: 610 von 1540 falsch, Commit `d8dce68a2`, versucht: Griffpunkt je Waffe (ebenda).
- Kosten: zwei Läufe, 11,40 Dollar (Kopf der Vorgangsdatei); ganzer Vorgang laut Vorgangsliste 33,37 Dollar.
- Werkzeug: zweites „steckt fest“ = Obergrenze B, Zustand „ruht, beim Chef“ (`tools/rueckmeldung.py`).
- Ob die Prüfausgabe die roten Fälle einzeln nennt: nicht belegt; falls nicht, ist das Teil des Laufs.

**Auswertung:**
- **A (Empfehlung):** Aufschlüsseln ohne Bau, ein Lauf, etwa 5,70 Dollar (Schnitt der zwei Läufe). Ergebnis: ob die Fehler auf wenige Gegenstände fallen (dann gezielt nachjustieren) oder überall streuen (dann trägt der Griffpunkt je Waffe nicht, anderer Ansatz).
- **B:** dritter Bauversuch am selben Ansatz, ein Lauf, etwa 5,70 Dollar; ohne Ursache droht das dritte Rot.
- **C:** 1694 ruhen lassen, 1621 und 1657 einzeln lösen; billig jetzt, widerspricht aber „nicht ständig einzeln rumflicken“ (17:01).
- **Stärkstes Gegenargument gegen A:** 752 → 610 zeigt, dass der Griffpunkt je Waffe wirkt; Aufschlüsseln kostet einen Lauf ohne sichtbaren Fortschritt. Entkräftet: der Lauf baut nichts und macht den nächsten Bau gezielt statt zum dritten Versuch ins Blaue.

**Folgerungen:** Bei „1694 A“: Eintrag im Vorgangsarchiv, diese Datei löschen, Auftrag Nachstellen beim Arbeitsplaner über den Eingang des Büros (Sokrates); Lauf über das Büro. Bei B: Auftrag Bauen, Deckel ein Lauf. Bei C: 1694 ruht, 1621 und 1657 startbar (Büro).

Antwort: …
```

### Was ich nicht tue

- Keinen dritten Versuch freigeben, keinen Auftrag selbst an die Fachkraft, keinen Stand in der Liste setzen (Büro).
- Keinen Spielcode (Kern Vorbehalt).

## Lücken

1. **Kern gegen Werkzeug und Archiv:** Kern: „Mit dem Chef bildest du die Leitung: du entscheidest, im Zweifel legst du es ihm zum Billigen vor“. Werkzeug (`rueckmeldung.py`): beim zweiten „steckt fest“ „an den Chef: Chefsache anlegen, nicht selbst lösen“; Archiv 21.11., 20:59 ebenso. Der Kern nennt Obergrenze A/B nicht; nur über Werkzeug und Archiv weiß ich, dass ich hier nicht entscheiden darf.
2. **Wohin genau:** Kern: „In `docs/chefsache/` gehört nur, was der Chef jetzt entscheiden, billigen oder fertig ansehen kann“; er nennt weder `entscheiden/` gegen `billigen/` noch das Muster (`MUSTER.md`) noch den Grund „Beim Chef, weil:“. Die Liste im Muster kennt keinen Grund „Obergrenze“; ich nahm „Geld“.
3. **Kostenprofil:** `lauf.py` (`hoechstdauer_zeilen`): „er entscheidet über die Grenze (Profil Kosten)“. Kern: „Profile nur auf Zuruf: … Chefrunde … Markt“; ein Profil Kosten lädt der Kern nicht. Zugleich Vorbehalt „Geld entscheidet der Chef“. Unklar, ob ich einen Laufdeckel in Dollar vorschlagen oder setzen darf.
4. **Gegenprüfung:** „Byte und Ladesumme vorher/nachher“: was „Ladesumme“ bei einer Chefsache-Datei ist, sagt der Kern nicht.
5. **Gedächtnis:** „`docs/leitung/gedaechtnis.md` … beim Start lesen“: Datei und Ordner fehlen; wer sie anlegt, steht nicht da (ich tat es).
6. **Telegram laut oder leise:** Kern sagt nur „Telegram vollständig ohne Füllwort“; `--laut` nicht geregelt (ich nahm laut, weil der Chef dran ist).
7. **Name des Vorgangs:** Kern: „Vorgang immer als Nummer und Titel in den Worten des Chefs“. Der Fall nennt 1694 „Stab durch die Knöchel“; in der Vorgangsliste steht dieses Chefwort (16:56) bei 1657, 1694 heißt dort „Griff einmal für alle gehaltenen Dinge“. Welcher Titel gilt, ist nicht festgelegt.
8. **Annehmen:** Kern sagt nichts zu `vorgang.py annehmen`/`erledigt`; nur `lauf.py` gibt es im Startauftrag vor („Je Zeile `vorgang.py annehmen <Kennung>` …“).
9. **Eigener Entscheid im Archiv:** Kern verlangt, auch meinen Entscheid („ein Versuch, Griffpunkt je Waffe“) oben ins Archiv; ob er dort steht, sagt der Fall nicht, im echten Archiv fehlt er (grep 1694). Ob ich ihn nachtrage, regelt der Kern nicht ausdrücklich.
