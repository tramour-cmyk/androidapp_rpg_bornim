# Umstellung 1727: Vorgangsliste nach Bereich

Bauliste 1727 Schritt 1 (`docs/entwurf/1727-muster/werkzeuge.md` „Reihenfolge des Baus“; Chef 21.11., 22:11: in Spikes Spur, 1739). Nur bauen und an einer Kopie testen; die Liste stellt erst der Umschalt-Commit um (Schritt 8, mit `tools/1727-SCHARF`), Rückweg `git revert` dieses Commits. Vorher brechen sonst `startbar.py`, `lauf.py`, `vorgang.py`, `abgleich.py`, `rotbuch.py`, `regelcheck.py` (lesen die Spalte Besitzer).

```
P=<leerer Ordner im Notizblock>; cp -r /home/user/bornim-main/docs $P/
python3 tools/umstellung1727/umstellen.py $P/docs --bericht $P/bericht.txt   # EILT, M?, KURZ, BEREICH, HAND lesen
```

Regeln im Kopf von `umstellen.py`. Offen für Sokrates vor dem Umschalten: (1) Muster `LISTE-VORGAENGE.md` hat die Spalte Block, `chefsache/themenbloecke.md` sagt „eine Spalte Themenblock gibt es nicht“; das Werkzeug schreibt Block als gerechneten Wert aus dem Bereich. (2) Fünf alte „jetzt“ werden Eilt (513, 887 ruhen bis 23.11.); ab dem vierten Hinweis an den Chef. (3) `themenbloecke.md` Block 10 nennt noch nicht „G Regeln“, Block 4 keinen Bereich; das Werkzeug ordnet beide nach VA 20.11. zu (`ZUSATZ_BLOCK`). (4) Spalte Build fällt (Muster), steht in der Vorgangsdatei unter „## Herkunft“; Automatik B (`vorgang.py build`) muss sie dort oder im Build-Auftrag lesen. (5) Bezug ist Hilfe, kein Urteil (Messzahlen können durchrutschen).
