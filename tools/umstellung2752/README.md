# Umstellung 275.2: eine Vorgangsliste

Chef 07.11., 21:5x (Vorgangsarchiv 275.2): eine Tabelle aller Vorgänge mit festen Feldern, zwei Automatiken, alle Werkzeuge umgestellt, **kein Parallelbetrieb**, Umschalten in einem Schritt nach dem Quertest von Diogenes, Rückweg nur `git revert`.

- `umstellen.py DOCS [--bericht DATEI] [--probe]` stellt einen docs-Ordner um (Liste neu, Vorräte ohne Tabelle, alte Zeilen als „Alt <Nr>“, Erledigtes ins Archiv) und vergleicht die alte mit der neuen Startbar-Rechnung je Rolle und Nummer (Zeilen `ABWEICHUNG` im Bericht). Handkorrekturen stehen in `HAND` mit Grund (Bericht `HAND`, `DOPPELT`).
- `startbar_alt.py`: die alte `startbar.py` (Stand 07.11., 22:41), nur für Umstellung und Vergleich; `BORNIM_DOCS` zeigt auf den Ordner.
- `TEXTE.md`: Regeltexte, die Perikles im Umschalt-Commit mit Edit ändert.

## Quertest (Diogenes) an einer Kopie

```
P=<leerer Ordner im Notizblock>
git clone -q --shared /home/user/bornim-main $P && cd $P
git remote set-url origin https://github.com/tramour-cmyk/androidapp_rpg_bornim
git fetch -q origin claude/perikles-2752-liste && git checkout -q FETCH_HEAD -- tools
python3 tools/umstellung2752/umstellen.py $P/docs --bericht $P/bericht.txt   # ABWEICHUNG, HAND, DOPPELT lesen
python3 tools/startbar.py --stand; python3 tools/vorgang.py --rolle Tom; python3 tools/vorgang.py pruefen
```
Danach je Werkzeug ein Probelauf in der Kopie (`lauf.py --ohne-pull <Kurzzeilen>`, mit `--sperre`; `regelcheck.py`, `--kurz`, `--rueckmeldung`; `abgleich.py`; `tagesbericht.py --probe`; `zug-index.py`; `dashboard.py`; `vorgangskosten.py`; `commit-pruefung.py` mit gestagter Änderung; `pflegehinweis.berechnen("HEAD", …)`), Automatik A (`vorgang.py warte <Nr> <Datum von gestern>` → `startbar.py` meldet GELÖST, `lauf.py --sperre` setzt startbar) und B (Prüfliste `ansehen/t<n>-….md` mit „## Ergebnis“, `vorgang.py build <n> --mit …`, dann `vorgang.py build <n>`; Archiveintrag „- **t<n>“ ohne diesen Schritt hält die Commit-Prüfung an).

## Nachprüfung D80 (Lauf 80)

- D80.1: `vorgang.py build N` nimmt nur Zeilen mit Build N; genannte Nummern ohne Build N bleiben und stehen als „genannt, nicht in Build N“ in der Ausgabe; ohne eine Zeile mit Build N bricht er ab.
- D80.2: Fund-Absatz „Zu NR, von Chef (Fund tN.k, Test Build N, Automatik B)“; die Commit-Prüfung nimmt ihn als fremden Hinweis (400). Die Umstellung verkleinert jeden großen Vorrat (Kurzkopf, „Alt“-Zeilen ohne Klasse und leere Zellen; Probe: Tom −611, Jerry −513 Bytes) und merkt die Liste (keine Warnung „von Hand“).
- D80.3: „wartet auf <Nr>“ sperrt bei gebaut oder zu testen nicht mehr (190.1, wie alt), geschrieben und gemeldet („GELÖST“) wird nur bei erledigt; das Feld bleibt bis dahin stehen.
- D80.4: `lauf.py --sperre` hängt an „GELÖST“ die Kennung der laufenden Sitzung des Besitzers (`| an <id>`, sonst `| -`); Text für Ford in `TEXTE.md`.
- D80.5: fremde Zeilen „wartet auf <Rolle>“ stehen hinter der letzten eigenen startbaren Zeile derselben Stufe (Muss, Kür, nach Meilenstein, Pflege), in Listenfolge; ruht, Dauer, nach Meilenstein, aufgeteilt, Idee sperren sie auch für die wartende Rolle.
- D80.6: „Gemeinsamer Build“ zählt wie alt jede eigene Zeile, die auf einen Test wartet, auch mit Build (Probe: Tom 8, Jerry 0).
- D80.7: `HAND` 275.2 bleibt „in Arbeit“ (Vorratszeile vor dem Umschalten ebenso); `pruefen` meldet „gebaut“ ohne „Geprüft an“; 483, 464, 383 mit Bau-Commit; Pflege-Zeilen Bereich „B Betrieb“.
