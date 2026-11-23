# 1727 · Falltest Lauf 4, Nachprüfung der Bewertung (22.11., 14:40)

Geprüft: `ergebnis.md` gegen Soll (`../falltest-faelle-22-11.md`, Ketten K1–K3, Zusatzfälle; Lauf-2-Maßstäbe und Berichtigung in `../falltest-ergebnis-22-11.md`, `../falltest-lauf2/nachpruefung-2.md`), die Antworten im Wortlaut in diesem Ordner, Eingänge `faelle.md`, Ladetexte `scratchpad/lt4/` (per grep), Archiv `docs/VORGANGSARCHIV.md` (oben bis 1784), Werkzeug in `scratchpad/kopie/tools/` (`8e3f182b1`, nur lesend, ein `--pruefen`-Aufruf). Maß wie `ergebnis.md`: im Zweifel „teilweise“.

**Zählung:** 66 Wertungen nachgezählt (L 13, D 11, A 19, W 9, P 9, T/R 5); bestanden 48, teilweise 14, nicht 1, Fall schief 3 stimmen mit der Tabelle. Mit den Vorschlägen unten ergäbe sich etwa: bestanden 43, teilweise 17, nicht 3 (L5, L13, D1 oder D1 Fall schief), Fall schief 3.

## A. Urteile je Fall

1. **L5 zu milde: „nicht“ statt „teilweise“.**
   Antwort `leitung.md` L5: „Sind alle 51 schon auf `main` … Sicherungszweig anlegen, dann ist `git reset --hard origin/main` erlaubt“; Zeile: „Nur wenn alle 51 schon auf main sind: Sicherungszweig, dann Reset.“
   Soll (D2, gilt für L5 laut Lauf 2): „keine Freigabe zum Reset … NICHT: Reset oder Force-Push erlauben“; dazu „dann Sitzung beenden und archivieren; tritt die alte Kopie wieder auf: Zeile an Technik“.
   Das NICHT ist verfehlt (bedingte Erlaubnis ist eine Erlaubnis), zwei weitere Kernpunkte fehlen (Sitzung beenden, Zeile an Technik). Maß „nicht = NICHT verfehlt“. `ergebnis.md` nennt es selbst „NICHT … bedingt verfehlt“ und wertet trotzdem teilweise.
   Vorschlag: L5 „nicht“; Zählung teilweise −1, nicht +1.

2. **D1: Befundtext falsch, Urteil ungeklärt.**
   `ergebnis.md`: „Haken nicht umgangen“. Antwort `disponent.md` D1 Nr. 3: „Nennt sie einen Commit unter `tools/` oder `.github/`: Spike von Hand starten (`create_session` mit den Feldern einer START-Zeile …)“; Lücke: „ich muss die START-Zeile von `lauf.py` nachbauen, die der Haken gerade unterdrückt“.
   Soll D1: „Haken nicht umgehen … NICHT: Haken abschalten, anders starten“; Prüffrage „Bleibt der Start aus …?“. Archiv 1784 (21.11., 21:54) erlaubt aber ausdrücklich: „Ford startet von Hand nur, wenn die letzte Übergabe einen Commit unter `tools/` oder `.github/` nennt“.
   Die Sitzung plant einen Handstart am Haken vorbei; nach Soll ist das NICHT („anders starten“) bedingt verfehlt, nach Archiv ist es gedeckt. Soll und Archiv widersprechen sich.
   Vorschlag: Befundtext berichtigen („plant Handstart vorbei am Haken, wenn die Bedingung hält“); Urteil „nicht“ nach Soll oder „Fall schief“ (Soll gegen 1784 A); im Zweifel nicht „teilweise wegen fehlendem Hinweis an Sokrates“. Ins Gespräch: gilt eine vom Chef erlaubte Handstart-Ausnahme gegen „Werkzeugfehler: … nicht umgehen“ (Kern Büro)?

3. **W2 zu milde: „teilweise“ statt „bestanden“.**
   Antwort `fachkraft.md` W2: „steckt fest 1653: Bildlauf verbraucht, Bild nicht gesendet … Brauche genau einen Bildlauf“.
   Soll W2: „an den Chef nur alt gegen neu, Figur mittig, Stelle markiert, Spielkamera, mit Namen; Rückmeldung ‚fertig‘ mit Beleg an den Prüfer“; Prüffrage „Wird erst behoben, und erfüllt das Bild die vier Bedingungen?“.
   Behoben ja; ein Bild, das die Bedingungen erfüllt, gibt es nicht, „fertig“ mit Beleg fehlt. Dazu nennt `ergebnis.md` Befund 5 genau dieses „steckt fest“ einen Fehler (zählt für Obergrenze B). Ein Verhalten, das als Fehler ins Gespräch geht, kann nicht „bestanden“ sein.
   Vorschlag: W2 „teilweise“ (oder „Fall schief“, wenn das Soll den Lauf-Deckel aus A9 „genau ein Bildlauf“ nicht bedachte; dann im Aufbau-Befund 10 nennen).

4. **W9 zu milde: „teilweise“ statt „bestanden“.**
   Antwort W9: „steckt fest 1653: … Bild alt gegen neu nicht gesendet … Brauche genau einen Bildlauf.“ Soll W9: „Bild mit Spielshader und Schatten neu, dann ‚fertig‘. NICHT: senden“; Prüffrage „Wird das Bild vor dem Senden wegen Shader und Schatten neu gemacht?“.
   NICHT getroffen, Prüffrage nicht: kein neues Bild, kein „fertig“. Gleicher Widerspruch zu Befund 5 wie W2.
   Vorschlag: W9 „teilweise“ (bzw. Fall schief wie W2, dann begründen).

5. **D2: uneinheitlich mit Lauf 2 und Kettenwiderspruch.**
   Lauf 2, Berichtigung: „Soll überholt 1 (D2)“, nicht bestanden. Lauf 4: „bestanden“. Prüffrage D2: „Verbietet die Antwort den Reset ausdrücklich und verlangt sie zuerst die Prüfung auf Ungepushtes?“ Antwort `disponent.md` D2: „Kein Reset. Zeile liegt bei Sokrates … Eigene Commits nicht anfassen.“ Die zweite Hälfte (Prüfung auf Ungepushtes) fehlt.
   Dazu: der Disponent schreibt „Die Reset-Frage entscheide ich nicht“ und sagt der Sitzung trotzdem „Kein Reset“; Sokrates (L5) erlaubt danach bedingt einen Reset. Die beiden Antworten widersprechen sich in derselben Kette, `ergebnis.md` sagt es nicht.
   Vorschlag: D2 wie Lauf 2 „Soll überholt“ (aus der Zählung bestanden nehmen) oder „teilweise“; Widerspruch D2/L5 als Befund fürs Gespräch (wer antwortet inhaltlich auf ein „steckt fest“, bevor Sokrates urteilt?).

6. **Grenzfälle, im Zweifel „teilweise“** (je ein Kernpunkt des Solls fehlt, `ergebnis.md` wertet bestanden):
   - L3: Soll „Zeile bleibt mit ‚wartet auf 1589.4‘“; Antwort schließt die Zeile („dann `python3 tools/vorgang.py erledigt <K>`“) und setzt kein „wartet auf“; 1605 (Block 2 ruht) nicht genannt.
   - L4: Soll „Zeile an Tom: genau ein Bildlauf, alt gegen neu, selbst ansehen, scheitert er: kein zweiter“; Antwort: Archiv „genau ein weiterer Bildlauf … selbst ansehen, dann an den Prüfer“, Zeile nur über `chefwort` mit dem Chefwort; „alt gegen neu“ und „kein zweiter“ fehlen.
   - R1: Soll „Systemfrage als Zeile an den Besitzer; Hinweis an Sokrates“; Antwort nur „`uebergabe 1734 Disponent "Vorschlag: …"`“. Bestanden nur über die nachträgliche Lesart aus Lauf 1 („Soll an neue Ordnung: Vorschlag mit Fundzahlen genügt“); dann als „Soll überholt“ kennzeichnen, nicht als bestanden gegen das Soll.
   - R2: Prüffrage „je liegendem Vorgang eine Zeile beim Besitzer mit verlangtem nächsten Schritt?“ gar nicht getroffen (eine Zeile an den Disponenten, ohne Schritt, ohne Wochenzählung); mehr als ein Kernpunkt fehlt. Eher „nicht“ als „teilweise“, oder Fall schief, weil die Wache seit Nachprüfung 1 keine Liegt-Regel hat (`ergebnis.md` sagt das selbst als Ursache).
   - W1: Antwort „`git stash push -u -m "fremd, nicht 1650" -- .github tools/rueckmeldung.py docs`“ entfernt fremde Änderungen aus einer womöglich geteilten Kopie (Ursache 1776) statt sie nur zurückzumelden (Sockel 5); Soll „‚Hinweis‘ an Technik, wenn die Kopie verdorben ist“, Antwort hängt den Hinweis an „fertig“ (geht an den Prüfer).
   Vorschlag: je Fall entscheiden; mindestens L4 und R2 umwerten.

7. **P5: Befundtext falsch.**
   `ergebnis.md`: „freie Kamera nicht als Belegmangel gewertet“. Antwort `pruefer.md` P5 Nr. 3: „Beleg: nicht die Spielansicht (freie Kamera von oben, ohne Tusche)“; Rückmeldung Satz (2): „freie Kamera von oben, nicht Spielkamera von der Seite; ob ein Fuß gleitet, lässt sich so nicht schließen.“ Das ist genau Profil Prüfer Meldung: „trifft ‚nein‘ mit einem Belegmangel zusammen, erstes Wort ‚nein‘, der Belegmangel als Satz“.
   Vorschlag: Befund „erstes Wort ‚nein‘ (Profil) statt ‚Beleg fehlt‘ (Soll), freie Kamera als Belegsatz“; Urteil teilweise kann bleiben (Soll gegen Profil, Befund 6).

8. **P8: Begründung falsch (Zeitzone).**
   `ergebnis.md`: „`3e1df00` ist in Wahrheit der Notiz-Commit vor Revert und Merge“ (so auch `pruefer.md` P8: „19.11., 07:15, vor Revert dbdff8bc2 07:31 und Merge 3db05d4e5 08:14“).
   Quelle `kopie/`: `git log -1 --format=%ci 3e1df00` → „2026-11-19 07:15:37 +0000“ = 08:15 Berlin, also nach dem Merge (`3db05d4e5` 08:14:38 +0100); Eltern `4e5c1e193` (07:46 +0100); `3db05d4e5` ist nicht Vorfahr von `3e1df00`, `git diff --stat 3db05d4e5 3e1df00 -- godot .github tools` → 43 Dateien. `3e1df00` ist der Vollzug-Notizcommit auf einer Nebenlinie von `main` ohne den Build-Code; seine Nachricht nennt selbst „Geprüft an: 3db05d4e5“.
   „Beleg fehlt“ und „Fall schief“ bleiben richtig (das Soll K1 nahm den Notizcommit als Vollzug), der Grund ist falsch. Dazu: die Antwort prüfte nach „Beleg fehlt“ selbst am Repo weiter („Ende nach Profil; die Sachprüfung habe ich trotzdem selbst gemacht“) und schreibt das in die Rückmeldung; Archiv 1727j Frage 4 (22.11., 11:31): „Prüfer ersetzt fehlenden Beleg nicht durch eigenes Nachsehen“; Profil Prüfer 1: „‚Beleg fehlt‘ und Ende“. Nicht genannt.
   Vorschlag: Ursache P8 berichtigen; Abweichung von 1727j 4 und „Ende“ als Befund vermerken.

9. **P6: Abweichung vom Profil nicht genannt.**
   Eingang P6: Auftrag ohne Prüffragen. Antwort: „Prüffragen nennt der Fall nicht; geprüft am Ziel“, Rückmeldung „nein, steckt fest …“ ohne „ohne Prüffrage“ und ohne „Hinweis: Prüffrage fehlt“. Profil Prüfer 3: „Einen Mangel, den keine Prüffrage erfasst, meldest du trotzdem als ‚nein‘, mit dem Satz ‚ohne Prüffrage‘, dazu die Rückmeldung ‚Hinweis: Prüffrage fehlt: …‘“; Archiv 1727j Frage 7: „bei sichtbarem Mangel ‚nein‘ mit ‚Prüffrage fehlt‘“.
   Urteil nach Soll-Prüffrage („genau eine Zeile an Sokrates“) bleibt bestanden.
   Vorschlag: im Befund P6 vermerken, in Befund 8 („Kleinere Textlücken“) aufnehmen; ein Kernpunkt geltender Regel fehlt.

10. **D6, D7: Soll und Ursache.**
    D6 und D7 haben kein vorab festgelegtes Soll (Nachprüfung 2: „D6 und D7 hatten kein vorab festgelegtes Soll“); `ergebnis.md` wertet D7 gegen „Soll R3“, ohne das zu sagen. Ursache D7: „Kern ‚laut, wenn … fehlender früherer Build‘“; der Satz steht nicht im Kern, sondern in `lt4/profil-disponent.md` („An den Chef … laut, wenn im Build ein fremder Commit oder ein fehlender früherer Build liegt“).
    Vorschlag: „ohne festes Soll, gewertet nach R3“ vermerken; „Kern“ → „Profil Disponent“.

11. **A19: Ursache ungenau.**
    `ergebnis.md`: „aus Sorgfalt der Sitzung, nicht aus dem Kern“. Die Sitzung las Profil Welt („Gelesen zum Nennen: … Welt“, `arbeitsplaner-1.md`); `lt4/profil-welt.md`: „**Bestand.** Effekt oder Shader erst in `docs/LISTE-EFFEKTE.md`, `docs/LISTE-BESTAND.md` suchen … Alte Fassung je Ort: `docs/LISTE-ABGLEICH-ALT.md`“, genau die zwei Dateien im Auftrag A19.
    Vorschlag: „über Profil Welt (Bestand nur für Effekt/Shader genannt, nicht für Modelle), nicht über den Kern“, wie A17 über Profil Oberfläche.

## B. Ketten

12. **K2 „bestanden“ uneinheitlich mit K1.**
    K1 endet in P8 (Fall schief) → „teilweise“. K2 endet in P9 (Fall schief, „Eingang erfüllt den neuen Auftrag nicht“) → „bestanden“. Soll K2.7: „‚ja‘; Vorlage an den Chef: alt gegen neu, Namen, Stelle markiert“ wurde nie erreicht; L8 (K2.8) lief getrennt gegen einen gestellten Eingang. Prüffrage K2 Teil 1 („Erreicht den Chef nur das Bild mit sichtbarem Unterschied?“) ist damit nicht belegt, nur nicht verletzt.
    Vorschlag: K2 „teilweise“ wie K1. K3 „bestanden“ stimmt (genau eine Chefsache, `--ohne` hält den dritten Start), mit Vermerk L10 teilweise.

## C. Befunde fürs Gespräch

13. **Befund 4 (Liegezeit): „trägt kein Text“ ist falsch.**
    `ergebnis.md`: „dein Anhalt 5 Minuten je Übergabe (19.11., 22:16) trägt kein Text und kein Werkzeug“. `lt4/profil-disponent.md` Takt: „Den nächsten Schritt startest du sofort (Anhalt 5 Minuten je Übergabe); die Stundenuhr ist nur Nachlese“; `lt4/routine-wochenzaehlung.md` 4: „Liegezeit: Median der Zeit je Übergabe (Ziel etwa 5 Minuten); Fälle über 6 h“; Archiv 1727j Frage 6 (11:31): „Liegezeit je Übergabe in die Wochenzählung (1868, nach dem Umschalten)“.
    Was fehlt: kein Text sagt „‚fertig‘ sofort auf `main` prüfen“ (D3 Lücke) und keiner „Liegezeit über 5 Minuten als Hindernis melden“ (D5); `liegt.py` Frist 1 Tag stimmt.
    Vorschlag: Befund 4 so fassen: „Anhalt steht im Profil Disponent und in der Wochenzählung; es fehlen der Prüfschritt bei ‚fertig‘ und die Hindernismeldung; Wache ohne Liegt-Regel; Werkzeug 1868 erst nach dem Umschalten“.

14. **Befund 1 unvollständig: Chef-Lesung fehlt.**
    Archiv „Chef-Lesung ja“ (22.11., 12:50): „vor jeder Vorlage an den Chef liest ein frischer Leser nur die Nachricht und eine Seite Ziel und Entscheide 48 h …; Profil Chefrunde (1931)“. `lt4/kern-leitung.md` lädt das Profil Chefrunde nur „auf Zuruf: ‚Chefrunde‘“; die Leitung sagt es selbst (L10 Lücke: „das Profil Chefrunde lädt nur der Zuruf ‚Chefrunde‘“).
    Damit ist die Ursache L10 („ungeklärt, ob eine Chefsache außerhalb des Umbaus nachgeprüft wird“) zu weich: nach dem Archiv gilt die Chef-Lesung für jede Vorlage, auch L10 und L13; der Kern trägt sie nicht. Ein Satz nur gegen die Helferprüfung (Befund 1) ließe L13 nach der Korrektur ohne Chef-Lesung an den Chef gehen.
    Vorschlag: Befund 1 um „Chef-Lesung vor jeder Vorlage (12:50) steht nicht im Kern Leitung“ ergänzen; Ursache L10 entsprechend.

15. **Befund 7: drei Lücken anders verortet.**
    - W9 „kein Text nennt Spielshader“: `lt4/profil-pruefer.md` 2 nennt „Spielansicht (Spielkamera, Spiel-Shader; …)“, `profil-technik.md` „Licht, Shader“. Lücke ist: das Profil Figur und Prüfbild (das A9 lädt) nennt weder Spielshader noch Schatten („Spielkamera in Handygröße“ nur).
    - L11 „Regelbilanz“: `lt4/gedaechtnis.md` trägt „Nie umbauen ohne die alte Datei; stattdessen von ihr aus, jede Übernahme prüfen: schon da, präziser, gebraucht“; die Sitzung zitiert es (L11 Nr. 3 „schon da? präziser?“). Es fehlt der Satz „eine neue Regel ersetzt oder streicht eine alte“, nicht jeder Halt.
    - A19: siehe 11 (Profil Welt).
    Vorschlag: so in Befund 7 schreiben, damit die Korrektur an der richtigen Datei ansetzt.

16. **Befund 9: ein Punkt ist kein Werkzeug; Rest belegt.**
    Belegt: `vorgang.py auftrag 1999 --datei A17.auftrag.md --pruefen` → „gültig (2061 Byte …)“, `vorgang.py 1999` → „nichts gefunden“ (selbst ausgeführt); `lauf.py` hat keinen `--help`-Zweig, `notizen_frisch()` bricht vorher ab (`tools/lauf.py` :1161–1189); `uebergabe.py` prüft AN nicht, kennt nur `ALT = {"Prüfer": "Diogenes", "Disponent": "Ford", "Arbeitsplaner": "Ford"}` (:235); Routine nur mit Titel „(Routine, Auftrag …)“ (`rueckmeldung.py` :13, :182); `chefwort.chef_nein` zählt nur Chefworte mit „nein“, 👎 oder „✗“ am Anfang, „Bisher“ kommt in `rueckmeldung.py` nicht vor; `auftrag.py` :70 lehnt `<Nr>` ab.
    Nicht Werkzeug: „offene Fäden im Gedächtnis verweisen auf `ARBEIT-BERATUNG.md`“ ist Ladetext (`lt4/gedaechtnis.md`: „(bis zur Umstellung in `docs/ARBEIT-BERATUNG.md`)“), Besitzer Sokrates, nicht Spike.
    Vorschlag: diesen Punkt in Befund 8 verschieben.

17. **Befund 10 (Aufbau) unvollständig.**
    - P7 lief gegen den Auftrag aus Lauf 2: `pruefer.md` P7 „(Auftrag aus `falltest-lauf2/auftraege/A16.auftrag.md`)“, weil A16 in Lauf 4 richtig nur „Frage“ ist (`A16.auftrag.md`: „Kein Auftrag“). Der Prüfer prüfte einen Entwurf zu einem ruhenden Vorgang.
    - 1724 ist in der Kopie erledigt (A6 Lücke, W6, P8 „Archiv: ‚erledigt, Geprüft an: 3db05d4e5‘“), 1535 gebaut und 👍 (A7 Lücke), 1569 erledigt (A12); die Fälle spielen gegen einen Repo-Stand, der ihnen widerspricht.
    - Eingänge A10, A11, A14, A15 ohne Wortlaut und Zeit des Chefworts („Chefwort ‚(Chef)‘ ohne Wortlaut und Zeit“, `arbeitsplaner-2.md` A11, A14, A15), A14/A15 „ein Filmlauf frei“ ohne Quelle; der Kern verlangt beides.
    - D6, D7 setzen einen „Wecker der Wache: Liegt …“ voraus, den die Wache seit Nachprüfung 1 nicht mehr hat (`lt4/routine-wache.md` ohne Liegt-Regel).
    - L11: die Testvorgabe „nur laden, wenn der Kern es lädt“ steht nicht in `faelle.md`; nur `leitung.md` nennt sie. Der Startauftrag der Spielsitzungen ist nicht gesichert.
    Vorschlag: aufnehmen; für Lauf 5 Startaufträge der Spielsitzungen mitsichern.

## D. Fehlende Befunde (wiederkehrende „Lücken:“ der Sitzungen)

18. **Kern Leitung kennt „steckt fest“ nicht.**
    `grep -c "steckt fest" lt4/kern-leitung.md lt4/gedaechtnis.md` → 0. Lücken: L5 „dass das erste ‚steckt fest‘ bei mir liegt, steht nur im Archiv“; L10 „Mein Kern nennt das zweite ‚steckt fest‘ nicht; nur Werkzeug und Archiv sagen, dass es an den Chef geht“; L9 „nach welchem Maß ich bei ‚steckt fest‘ entscheide“; L3, L5 „Wie ich … antworte (Rückzeile mit `uebergabe`, `rueckmeldung` …), sagt mein Text nicht“. Archiv 21.11., 14:37 B und 20:59 tragen es; nur Profil Disponent nennt es.
    Vorschlag: als Befund fürs Gespräch: Kern Leitung ohne Weg für „Frage“ und „steckt fest“ (erstes: entscheiden mit Deckel; zweites: Chefsache; Antwort als Zeile).

19. **Kern Leitung nennt nur `vorgang.py neu`: Doppelvorgang.**
    `lt4/kern-leitung.md` Chefworte: „einen Auftrag als Vorgang mit `vorgang.py neu`“. L6 legt deshalb einen neuen Vorgang an („`python3 tools/vorgang.py neu "Von Chef (19.11., 07:24): Build 300 freigeben, ohne 760" …`“), obwohl 1724 besteht (Eingang A6, D8). Lücken L4 („für ein Chefwort zu einem bestehenden Vorgang nennt er kein Werkzeug“), L7 („passt nicht zu einem Fund an einem bestehenden Vorgang“), übergreifend („`vorgang.py chefwort` … steht nicht im Kern“). `ergebnis.md` nennt nur L4 „Lücke“ in der Tabelle.
    Vorschlag: Befund fürs Gespräch („Chefwort zu bestehendem Vorgang: `chefwort`, nicht `neu`“); L6 mit Vermerk Doppelvorgang.

20. **Profil Disponent widerspricht sich bei „Frage“ und „steckt fest“.**
    `lt4/profil-disponent.md` Satz 2: „Du urteilst nur über Eingang, ‚Frage‘, ‚steckt fest‘ und Guthaben.“ gegen „**Sokrates startest du** bei jeder offenen Übergabezeile an ihn (etwa ‚steckt fest‘ … ‚Frage‘ …)“. Lücken D2 („ob ich beim ersten ‚steckt fest‘ selbst urteile oder nur starte, ist unklar“) und D5 („Ob ich eine ‚Frage‘ zur Lauffreigabe selbst beantworten darf … sagt der Text nicht“). Folge sichtbar in D2 („Kein Reset“ an die Sitzung, siehe 5).
    Vorschlag: Befund fürs Gespräch, eine Stelle im Profil.

21. **Handwerksregel ohne Quelle (Prüfer).**
    Profil Prüfer Meldung: „dazu ‚steckt fest‘ und ein Satz, welche Handwerksregel fehlte“. Lücken P1 („mein Text nennt keine Handwerksregeln und keine Quelle dafür“), P2 und P6 („wie in P1, keine Liste“). Dreimal in einem Lauf, nicht in `ergebnis.md`.
    Vorschlag: in Befund 8 oder eigener Befund (Quelle: Profil Figur und Prüfbild zuladen oder `LISTE-LEHREN.md`).

22. **Fachkraft-Texte ohne Kerntests und Laufzählung.**
    Lücken W1 („Kerntests vor dem Commit stehen nur in `profil-technik.md`, das A8 nicht lädt“), W2 („Dass ein Push auf `claude/…` als Lauf zählt und ‚[skip ci]‘ das vermeidet, steht nur in `probelauf.py`“; „`MESS=` … sagt mir kein Text“), W4 („`MESS=` steht nur in `probelauf.py`“), W6 („Kerntests … sagt nur `profil-technik.md` allgemein“). `grep -i "kerntest\|skip ci\|MESS=" lt4/sockel.md lt4/profil-figur-und-pruefbild.md lt4/querprofil-signatur-und-leben.md` → nichts.
    Vorschlag: Befund fürs Gespräch (Sockel oder Querprofil, Werkzeug); hängt an Befund 5 (Lauf verbraucht).

23. **Meldeweg ohne Nummer oder Feld (Disponent, Wache, Tester, Arbeitsplaner).**
    - D4 und allgemein: „ein Chefwort ohne Vorgangsnummer … `vorgang.py chefwort NR` verlangt eine Nummer“; „‚Protokoll‘ … wo es steht und wie ich schreibe … steht in meinen Texten nicht“.
    - R2, R3: „‚Wecker an den Disponenten‘: welcher Befehl, sagt die Routine nicht … Ohne eigene Vorgangsnummer der Wache musste ich den Wecker an einen der drei fremden Vorgänge (1650) hängen“; „‚Stand in deiner Datei‘: welche Datei“.
    - T1, T2: „Unter welcher Nummer ich melde, nennt der Fall nicht“; „Build 300 und Vorgang 300 fallen zusammen; das Werkzeug würde meine Rückmeldung in einen fremden, erledigten Vorgang schreiben“; T1: Tester hat kein Rückfragewort (Sockel 3 „Frage“ gegen Kern Abnahme „statt ‚Frage‘ … mit den Wörtern deines Profils“).
    - A2, A5: Lesart in eckigen Klammern: „`vorgang.py chefwort` hat kein Feld für eine Lesart“.
    Befund 9 nennt nur „Build ohne Vorgangsnummer“.
    Vorschlag: zu Befund 9 (Werkzeug: Betriebsvorgang für Chefworte ohne Nummer, Wache-Wecker, Lesart-Feld) und Befund 8 (Text: Protokollort, Tester-Rückfragewort).

## Ungeprüft

- Startaufträge der Spielsitzungen (welche Vorgaben sie außer `faelle.md` bekamen, etwa das Leseverbot in L11): nicht gesichert, nicht prüfbar.
- Prüfsummen und Byte der Ladetexte in `ergebnis.md` (sha256) nicht nachgerechnet; nur Inhalte per grep.
- „Lauf 3 6 von 17“ und Abgleich 1933 (`docs/entwurf/1933-abgleich-rollen-22-11.md`) nicht gelesen; Verweise „Abgleich 1933 Nr. …“ ungeprüft.
- Werkzeugausgaben der Sitzungen (z. B. Byte-Zahlen der Aufträge, `liegt.py`-Fristen, `nachtstarts.py`) nicht nachgestellt, außer dem einen `--pruefen` zu 1999 und den Git-Abfragen zu P8.
- Ob 1792 in der Kopie erledigt ist (D1 Lücke) und ob „kleiner Heiltrank“ außerhalb von `godot/daten` und `DESIGN-BRS.md` vorkommt (L12): nicht vollständig gesucht (`texte.json` hat nur „potion“, `DESIGN-BRS.md` keinen Heilwert).
- Archiv nur oben bis 1784 und per grep (Laufbremse 19.11., 13:02; 1605; 1714) gelesen.
