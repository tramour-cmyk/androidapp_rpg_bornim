#!/usr/bin/env python3
"""Rufnamen (1739, Bauliste 1727 „Rufnamen“; VA „Rufname je Sitzung“ 20.11., 07:57, „Rufnamen im Alphabet“ 20.11., 08:04).

Jede Sitzung bekommt beim Start einen Vornamen aus fester Liste: je Tag (Berliner Zeit) in Startreihenfolge A, B, C …,
nie doppelt am Tag, nie der Name einer Spielfigur oder einer alten Rolle (Sperrliste, RF:13). Sokrates behält seinen Namen.
Vergeben wird von einem Werkzeug (`lauf.py`), nicht von einer Sitzung (P20:12).

Titelform: „<Rufname> – <Nr>: <Thema> (TT.MM., HH:MM)“ (wie 436, Rufname statt Rolle, stets mit Vorgang). Der Bereich
einer Rufnamen-Sitzung ist der Besitzer des ersten Vorgangs im Titel (`bereich()`); so bleiben Kosten und Besetzung
ohne eigenes Verzeichnis zählbar.

    python3 tools/rufname.py [Sitzungsdatei]   # nächster freier Rufname; Datei im Format der lauf.py-Eingabe (sonst stdin)
    python3 tools/rufname.py --pruefen         # Namensliste gegen die Sperrliste; Exit 1, wenn ein Buchstabe keinen freien Namen hat
    python3 tools/rufname.py --titel "<Titel>" # Rufname und Bereich eines Titels

Rückwärtsverträglich: Titel mit altem Rollennamen liefern `aus_titel() is None`; Aufrufer behandeln sie wie bisher.
"""
import datetime
import glob
import os
import re
import sys
from zoneinfo import ZoneInfo

BERLIN = ZoneInfo("Europe/Berlin")
HIER = os.path.dirname(os.path.abspath(__file__))
DOCS = os.path.join(HIER, "..", "docs")

# Feste Liste, je Buchstabe in Vergabefolge (ohne Q, X, Y). Bürovornamen, keine Fantasynamen, damit sie nie mit
# Spielfiguren verwechselt werden; die Sperrliste prüft das trotzdem bei jeder Vergabe.
NAMEN = {
    "A": ["Anna", "Arne", "Alma"], "B": ["Britta", "Benno", "Bettina"], "C": ["Carla", "Conrad", "Clara"],
    "D": ["Dana", "Dirk", "Doris"], "E": ["Elke", "Emil", "Erna"], "F": ["Frieda", "Fritz", "Fenja"],
    "G": ["Gerda", "Gustav", "Greta"], "H": ["Heike", "Hugo", "Hanna"], "I": ["Ida", "Ingo", "Ilse"],
    "J": ["Jana", "Jonas", "Jutta"], "K": ["Karla", "Knut", "Katja"], "L": ["Lena", "Lutz", "Lotte"],
    "M": ["Marta", "Moritz", "Margit"], "N": ["Nora", "Nils", "Nadine"], "O": ["Olga", "Otto", "Oda"],
    "P": ["Paula", "Pit", "Petra"], "R": ["Rita", "Rudi", "Ruth"], "S": ["Sabine", "Sven", "Silke"],
    "T": ["Tanja", "Timo", "Thea"], "U": ["Ulla", "Uwe", "Ute"], "V": ["Vera", "Volker", "Viola"],
    "W": ["Wiebke", "Werner", "Wanda"], "Z": ["Zora", "Zeno", "Zita"],
}
BUCHSTABEN = list(NAMEN)
ALLE = {n for ns in NAMEN.values() for n in ns}

# Alte Rollen- und Sitzungsnamen (CLAUDE.md „Rollen“, startbar.BESITZER, Account); Sokrates bleibt, vergeben wird er nie.
ALTE_ROLLEN = {"Chef", "Sokrates", "Homer", "Perikles", "Diogenes", "Ford", "Tom", "Jerry", "Spike", "Tuffy", "Max", "Zentrale"}
# Wo Spielfiguren stehen: Aussehen (LISTE-FIGUREN.md) und alle Spieltexte (STORY-*.md).
FIGUREN_QUELLEN = ["LISTE-FIGUREN.md", "STORY-*.md"]

_SPERRE = {}
_ZEILEN = {}  # Vorgangsliste einmal je Aufruf (bereich() ohne zeilen)


def sperrliste(docs=None):
    """Namen aus NAMEN, die gesperrt sind: alte Rollen und jeder Name, der als ganzes Wort in einer Figurenquelle steht."""
    docs = docs or DOCS
    if docs in _SPERRE: return _SPERRE[docs]
    text = ""
    for muster in FIGUREN_QUELLEN:
        for p in sorted(glob.glob(os.path.join(docs, muster))):
            try: text += open(p, encoding="utf-8").read() + "\n"
            except OSError: pass
    gesperrt = {n for n in ALLE if n in ALTE_ROLLEN or re.search(r"(?<![\wÄÖÜäöüß])%s(?![\wÄÖÜäöüß])" % re.escape(n), text)}
    _SPERRE[docs] = gesperrt
    return gesperrt


def aus_titel(titel):
    """Rufname am Anfang des Titels („Anna – 1739: …“, auch „Anna, …“, „Anna:“), sonst None (alte Rolle, Sokrates, fremd)."""
    m = re.match(r"\s*([A-ZÄÖÜ][a-zäöüß]+)(?=$|[ ,:])", titel or "")
    return m.group(1) if m and m.group(1) in ALLE else None


def berlin_tag(iso):
    """TT.MM.JJJJ (Berliner Zeit) eines ISO-Zeitstempels; None, wenn unlesbar."""
    try: z = datetime.datetime.fromisoformat(str(iso).strip().replace("Z", "+00:00"))
    except ValueError: return None
    if z.tzinfo is None: z = z.replace(tzinfo=datetime.timezone.utc)
    return z.astimezone(BERLIN).strftime("%d.%m.%Y")


def heute_vergeben(sitzungen, jetzt=None):
    """Rufnamen der Sitzungen, die heute (Berlin) angelegt wurden, in Startreihenfolge. sitzungen: (Titel, created_at)."""
    tag = (jetzt or datetime.datetime.now(BERLIN)).astimezone(BERLIN).strftime("%d.%m.%Y")
    heute = sorted((str(c), t) for t, c in sitzungen if berlin_tag(c) == tag)
    return [n for _, t in heute for n in [aus_titel(t)] if n]


def naechster(vergeben, docs=None):
    """Nächster Rufname: Buchstabe nach Zahl der heute vergebenen (A, B, C …, nach Z wieder A), erster freier Name dort;
    ist der Buchstabe erschöpft oder gesperrt, der nächste Buchstabe. None nur, wenn die ganze Liste vergeben ist."""
    belegt = set(vergeben)
    gesperrt = sperrliste(docs)
    start = len(vergeben) % len(BUCHSTABEN)
    for i in range(len(BUCHSTABEN)):
        for n in NAMEN[BUCHSTABEN[(start + i) % len(BUCHSTABEN)]]:
            if n not in belegt and n not in gesperrt: return n
    return None


def titel(rufname, nr, thema, jetzt=None):
    """„<Rufname> – <Nr>: <Thema> (TT.MM., HH:MM)“ (Berliner Zeit)."""
    j = (jetzt or datetime.datetime.now(BERLIN)).astimezone(BERLIN)
    return "%s – %s: %s (%s)" % (rufname, nr, thema, j.strftime("%d.%m., %H:%M"))


def bereich(titel_, zeilen=None):
    """Bereich einer Rufnamen-Sitzung = Besitzer des ersten Vorgangs im Titel; None ohne Rufname oder ohne Treffer.
    zeilen: Liste von dicts mit „nr“, „besitzer“ (startbar.vorgangsliste); ohne Angabe aus der Vorgangsliste gelesen."""
    if not aus_titel(titel_): return None
    m = re.search(r" – (\d{2,4}[a-zA-Z]?(?:\.\d+[a-z]?)*)\b", titel_)
    if not m: return None
    if zeilen is None:
        if "liste" not in _ZEILEN:
            try:
                sys.path.insert(0, HIER)
                import startbar
                _ZEILEN["liste"] = startbar.vorgangsliste(startbar.lesen(startbar.LISTE))
            except Exception:
                _ZEILEN["liste"] = []
        zeilen = _ZEILEN["liste"]
    for d in zeilen:
        if d.get("nr") == m.group(1): return d.get("besitzer")
    return None


BETRIEB = None  # Pfad zu ARBEIT-BETRIEB.md; lauf.py setzt ihn auf seine DOCS, sonst docs/ neben tools/
_SPERREN = {}  # (Pfad, mtime, Größe) → Einträge


def sperr_eintraege(text, jahr):
    """1957: (Zeitpunkt naiv, Rolle, Rufname) aus Startsperren „… Start <Rollen> (lauf.py, <Rolle> <Nr> <Rufname>, …)“.
    Ein Eintrag nur, wo im selben Abschnitt der Klammer (bis Komma/Semikolon) eine Rolle der Zeile und ein Rufname stehen."""
    aus = []
    for l in text.splitlines():
        m = re.search(r"Startsperre (\d\d):(\d\d) Start (\w+(?:, \w+)*)(.*)", l)
        k = re.match(r"- \d\d:\d\d (\d\d)\.(\d\d)\.:", l)
        if not m or not k: continue
        try: d = datetime.datetime(jahr, int(k.group(2)), int(k.group(1)), int(m.group(1)), int(m.group(2)))
        except ValueError: continue
        rollen = m.group(3).split(", ")
        for teil in re.split(r"[,;]", m.group(4)):
            w = re.findall(r"[\wÄÖÜäöüß]+", teil)
            r = next((x for x in w if x in rollen), None); n = next((x for x in w if x in ALLE), None)
            if r and n: aus.append((d, r, n))
    return aus


def rolle(titel_, created_at=None, betrieb=None):
    """1957: Startrolle einer Rufnamen-Sitzung aus der Startsperre, die lauf.py beim START schreibt (Rufname je Tag eindeutig):
    Sperre am Berliner Tag von created_at mit diesem Rufnamen, die jüngste bis 5 Minuten nach created_at. None ohne Rufname
    oder ohne passende Sperre (dann wie bisher bereich()). Ohne created_at die jüngste Sperre mit diesem Rufnamen."""
    n = aus_titel(titel_)
    if not n: return None
    p = betrieb or BETRIEB or os.path.join(DOCS, "ARBEIT-BETRIEB.md")
    c = None
    if created_at:
        try: c = datetime.datetime.fromisoformat(str(created_at).strip().replace("Z", "+00:00"))
        except ValueError: return None
        if c.tzinfo is None: c = c.replace(tzinfo=datetime.timezone.utc)
        c = c.astimezone(BERLIN).replace(tzinfo=None)
    jahr = c.year if c else datetime.datetime.now(BERLIN).year
    try:
        st = os.stat(p); schl = (p, st.st_mtime_ns, st.st_size, jahr)
        if schl not in _SPERREN: _SPERREN.clear(); _SPERREN[schl] = sperr_eintraege(open(p, encoding="utf-8").read(), jahr)
        e = _SPERREN[schl]
    except OSError:
        return None
    e = [x for x in e if x[2] == n and (c is None or (x[0].date() == c.date() and x[0] <= c + datetime.timedelta(minutes=5)))]
    return max(e)[1] if e else None


def lies_sitzungen(text):
    """(Titel, created_at) aus Zeilen im Format der lauf.py-Eingabe: Kennung | Stand | updated_at | Titel | Kosten | created_at | …"""
    aus = []
    for z in text.splitlines():
        f = [x.strip() for x in z.split("|")]
        if len(f) >= 6 and f[0].startswith("session_"): aus.append((f[3], f[5]))
    return aus


def main(a):
    if a[:1] == ["--pruefen"]:
        g = sperrliste()
        leer = [b for b in BUCHSTABEN if all(n in g for n in NAMEN[b])]
        for n in sorted(g): print("gesperrt: %s" % n)
        if leer: print("rufname.py: Buchstabe ohne freien Namen: %s" % ", ".join(leer)); return 1
        print("rufname.py: %d Namen, %d gesperrt, jeder Buchstabe hat einen freien" % (len(ALLE), len(g)))
        return 0
    if a[:1] == ["--titel"] and len(a) > 1:
        print("Rufname: %s · Bereich: %s" % (aus_titel(a[1]) or "-", bereich(a[1]) or "-"))
        return 0
    text = open(a[0], encoding="utf-8").read() if a else sys.stdin.read()
    n = naechster(heute_vergeben(lies_sitzungen(text)))
    if not n: print("rufname.py: alle Namen heute vergeben"); return 1
    print(n)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
