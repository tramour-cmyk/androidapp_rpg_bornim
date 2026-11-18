#!/usr/bin/env python3
"""1611 (D305.2): undefinierte Namen in Python-Werkzeugen finden, bevor ein Lauf daran abstürzt (17.11. NameError nach e1cb7588c,
FREIGABE_MIN gelöscht, lauf.py brach an der ersten blockierten Sitzung ab; 15.11. 1343). Nur Standardbibliothek (symtable), kein
neues Paket: ein Name, den eine Funktion oder das Modul liest, muss im Modul angelegt (Zuweisung, import, def, class, global) oder
eingebaut sein. Dateien mit „from … import *“ werden übersprungen. Aufruf: namenpruefung.py DATEI … (Exit 1 bei Fund)."""
import builtins, symtable, sys

EXTRA = {"__file__", "__name__", "__doc__", "__builtins__", "__spec__", "__loader__", "__package__", "__path__",
         "__annotations__", "__dict__", "__module__", "__qualname__", "__class__", "__debug__"}


def befunde(quelle, name="<datei>"):
    """Liste (Name, Bereich) undefinierter Namen; Syntaxfehler als ein Befund."""
    try:
        top = symtable.symtable(quelle, name, "exec")
    except SyntaxError as e:
        return [("Syntaxfehler Zeile %s" % e.lineno, "Modul")]
    if "import *" in quelle and any(z.lstrip().startswith("from ") and z.rstrip().endswith("import *") for z in quelle.splitlines()):
        return []
    angelegt = {s.get_name() for s in top.get_symbols() if s.is_assigned() or s.is_imported() or s.is_namespace()}
    bekannt = angelegt | set(dir(builtins)) | EXTRA
    gelesen = []

    def gehe(t, pfad):
        for s in t.get_symbols():
            if t is not top and s.is_global() and (s.is_assigned() or s.is_declared_global() and s.is_assigned()):
                angelegt.add(s.get_name()); bekannt.add(s.get_name())  # „global X; X = …“ in einer Funktion legt X an
            if s.is_referenced() and (t is top or s.is_global()) and not s.is_assigned() and not s.is_imported():
                gelesen.append((s.get_name(), pfad))
        for k in t.get_children():
            gehe(k, pfad + "." + k.get_name() if pfad else k.get_name())

    gehe(top, "")
    aus, gesehen = [], set()
    for n, p in gelesen:
        if n not in bekannt and n not in gesehen:
            gesehen.add(n); aus.append((n, p or "Modul"))
    return aus


def main(argv):
    fund = 0
    for d in argv:
        try:
            q = open(d, encoding="utf-8").read()
        except OSError as e:
            print("%s: nicht lesbar (%s)" % (d, e)); continue
        for n, p in befunde(q, d):
            print("%s: undefinierter Name %s (in %s)" % (d, n, p)); fund = 1
    return fund


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
