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
