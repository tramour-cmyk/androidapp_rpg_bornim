#!/usr/bin/env python3
"""Test zu namenpruefung.py (1611)."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from namenpruefung import befunde

F = [
    ("def f():\n    return FREIGABE_MIN\n", ["FREIGABE_MIN"]),          # 17.11.: Konstante gelöscht
    ("X = 1\ndef f():\n    return X + len([])\n", []),
    ("import os\ndef f():\n    return os.sep, __file__\n", []),
    ("def f():\n    global Y\n    Y = 2\ndef g():\n    return Y\n", []),
    ("class A:\n    b = 1\n    c = b + 1\n    def m(self):\n        return A, self.b\n", []),
    ("def f(a):\n    return [x * a for x in range(3)] + [q]\n", ["q"]),
    ("try:\n    import zz\nexcept ImportError:\n    zz = None\nprint(zz)\n", []),
    ("from os.path import *\nprint(join)\n", []),
    ("def f(:\n", ["Syntaxfehler Zeile 1"]),
    ("print(nirgends)\n", ["nirgends"]),
]
fehler = 0
for q, soll in F:
    ist = [n for n, _ in befunde(q)]
    if ist != soll:
        print("FALSCH:", repr(q), ist, "statt", soll); fehler += 1
hier = os.path.dirname(os.path.abspath(__file__))
for d in sorted(os.listdir(hier)):
    if d.endswith(".py"):
        b = befunde(open(os.path.join(hier, d), encoding="utf-8").read(), d)
        if b: print("Bestand:", d, b); fehler += 1
print("namenpruefung_test: %d Fälle, %d Fehler" % (len(F), fehler))
sys.exit(1 if fehler else 0)
