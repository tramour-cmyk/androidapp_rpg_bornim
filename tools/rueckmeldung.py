#!/usr/bin/env python3
"""1763 (1727, Archiv 21.11., 14:37 A, B, C; prozesspruefung-21-11.md): Rückmeldung in die Vorgangsdatei, Obergrenzen A und B,
Weitergabe an Sokrates bei „steckt fest“, „Frage“, „wirkt nein“ (C; den Start macht lauf.py, Zeile „1763 C“).

  vorgang.py rueckmeldung NR "Text" [--sitzung ROLLE]

Schreibt die Rückmeldung wörtlich mit Zeit und Sitzung in docs/vorgang/NR.md (Abschnitt „Rückmeldungen“) und, je nach erstem Wort,
im selben Commit eine offene Übergabezeile (1760):
  „steckt fest“ (auch „nein … steckt fest“ des Prüfers), „Frage“, „wirkt nein“ → an Sokrates (C)
  „nein, Auftrag“ → an den Arbeitsplaner (Gesamtbild 6.1)
  zweites „nein“ je Vorgang → an Sokrates „steckt fest (Laufbremse)“ (1766, Archiv 19.11., 13:02)
  1739 (Gesamtbild 3.3 Nr. 5, Kern Büro „Rückläufer“): „fertig“ mit Commit → an den Prüfer; „fertig“ ohne Commit → an den Disponenten
  (nimmt es nicht an; Routine, Titel „(Routine, Auftrag …)“: „fertig“ ohne Commit → Disponent legt die Vorschläge an und schließt, 1789); erstes „nein“ und „Beleg fehlt“ → mit dem Satz an dieselbe Fachkraft (wer zuletzt „fertig“ meldete; unbekannt →
  Disponent); „ja“ des Prüfers → Disponent (an den Chef nur nach diesem Ja); „Hinweis“ → Disponent (wie ein Eingang)
  1873: „nein … steckt fest“ → an Sokrates und mit den Mängelsätzen an denselben Macher (wartet, bis Sokrates löst);
  „Hinweis: Prüffrage fehlt“ → an den Arbeitsplaner (er schreibt die Prüffragen)
  1877: „Hinweis“ des Disponenten (Ford) zu einem bestehenden Vorgang → an dessen Besitzer (Liste; ohne Besitzer der Macher, sonst
  der Arbeitsplaner) und eine Zeile „Hinweis“ an Sokrates (Soll D1), nicht an den Disponenten selbst
  1795: „Befunde: n“ des Testers → Disponent (je Befund ohne Nummer Vorgang anlegen), je Befund mit Nummer Rückläufer an den Arbeitsplaner
  1952 (1727, Chef 22.11., 15:31, Archiv): „Laufanforderung“ (ersetzt „abgebrochen“) nur mit Commit der Behebung → an den Prüfer; sein
  „ja“ → Disponent startet die Fachkraft einmal neu (Auftrag unverändert), sein „nein“ → zurück an die Fachkraft; die zweite
  Laufanforderung je Vorgang zählt als „steckt fest“ (an Sokrates, auch für Obergrenze B). Fremder Abbruch (Sitzung endet mit Fehler)
  bleibt beim Werkzeug (uebergabe.frei: Halter abgebrochen, ein Neustart). Katalog der Rückmeldewörter (KATALOG): anderes erstes
  Wort wird eingetragen und mit der Liste zurückgewiesen (Exit 2), ebenso Laufanforderung ohne Commit; Chefworte nie
  1797: „Auftrag steht“ → Disponent startet
  die Fachkraft; „kein Auftrag nötig“ → Disponent schließt oder fragt Sokrates; „Hinweis:“ hinter einem anderen Signalwort → zweite Zeile
  an den Disponenten
  1947: „fertig“ ohne Commit einer Routine-Sitzung (Rundblick, Ideenlauf, Wache, Tagesbericht, Wochenzählung) gilt wie unter einem
  Routine-Titel, auch unter einem anderen Vorgang · 1950: „fertig“ mit Commit zu einem Werkzeug (Bereich B), dessen Commit nicht auf
  origin/main steht: im selben Commit dazu eine Zeile an die meldende Fachkraft „auf main, Vollzug mit Commit“ · 1949: Build n meldet
  man unter B<n>; bloße Nummer n mit „Build n“/„tn“ im Text, die kein offener Vorgang ist, hält an · 1948: Chef-Nein auch ohne
  „nein“ am Anfang („fail“, „daneben“, „kein Unterschied“, „n.k ✗“) und einmal aus Feld „Bisher“ des jüngsten Auftrags
  Empfänger „Prüfer“ und „Disponent“ sind bis zur Umschaltung Diogenes und Ford (lauf.py, tools/1727-SCHARF)
Obergrenzen je Vorgang, über alle Aufträge gezählt (Rückmeldungen der Datei):
  A  zweites „nein, Auftrag“ oder drittes „nein“ (abgelehnter Auftrag = Runde, auch Chef-Nein; „nein, Auftrag“ zählt nicht, „Beleg fehlt“ erst jedes dritte je Auftrag, 1926)
  B  zweites „steckt fest“ (1927: dazu „Kosten bisher“ aus der Kostenspalte der Liste in den Kopf der Vorgangsdatei)
→ Zustand „ruht, beim Chef“ in der Vorgangsdatei, Stand in der Vorgangsliste (solange sie Stände trägt), Zeile an Sokrates
  „an den Chef: Chefsache anlegen, nicht selbst lösen“ statt der normalen Weitergabe. 1976 (1566): weitere Rückmeldungen danach gehen
  nie still unter: Laufanforderung mit Commit → Prüfer, jedes andere Signalwort → Sokrates; ohne Signalwort zurückgewiesen.
  Das Chefwort (`vorgang.py chefwort`) hebt „ruht“ in der Vorgangsdatei und in der Liste auf.

Muster (erst nachsehen, wie andere es lösen): Wiederholgrenze mit Ablage (Dead-Letter-Queue: maxReceiveCount in Amazon SQS,
Celery max_retries): nach n Fehlversuchen geht die Nachricht nicht in die nächste Runde, sondern in eine Ablage, die ein Mensch sieht.
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import uebergabe as ue

SOKRATES = "Sokrates"
PLANER = os.environ.get("BORNIM_CHEFWORT_AN", "Arbeitsplaner")
RUHT = "ruht, beim Chef"
RUHT_SCHON = "Vorgang ruht schon, beim Chef: Zeile trotzdem"  # 1976
MAX_NEIN_AUFTRAG, MAX_NEIN, MAX_FEST = 2, 3, 2
LAUFBREMSE_NEIN = 2  # 1766 (Archiv 19.11., 13:02 Laufbremse): zweites „nein“ des Prüfers → „steckt fest“ an Sokrates; drittes ist Obergrenze A
SIGNAL = {"nein", "ja", "fertig", "frage", "hinweis", "laufanforderung"}
MAX_LAUF = 2  # 1952 (Chef 22.11., 15:31): zweite „Laufanforderung“ je Vorgang zählt als „steckt fest“ (auch Obergrenze B)
# 1952: Katalog der Rückmeldewörter (erstes Wort; Gesamtbild „Feste Werte“): Wort → wer es meldet, was folgt
KATALOG = [
    ("fertig", "Fachkraft, mit Commit und Beleg → Prüfer"),
    ("Frage", "jede Rolle → Sokrates"),
    ("steckt fest", "jede Rolle, nach Ursache und Behebung geht es nicht weiter → Sokrates"),
    ("Laufanforderung", "Fachkraft, Lauf endete ohne Ergebnis; Ursache und Commit der Behebung → Prüfer gibt frei"),
    ("ja", "Prüfer → Disponent"),
    ("ja, Lauf frei", "Prüfer gibt eine Laufanforderung frei → Disponent startet neu, keine Testbitte"),
    ("nein", "Prüfer, je Mangel ein Satz → dieselbe Fachkraft"),
    ("nein, Auftrag", "Prüfer → Arbeitsplaner"),
    ("Beleg fehlt", "Prüfer → dieselbe Fachkraft"),
    ("wirkt nein", "jede Rolle, Chefwort klingt wie ein Nein → Sokrates"),
    ("Hinweis", "jede Rolle, „Hinweis: was, wo“ → Disponent"),
    ("Befunde: n", "Tester → Disponent"),
    ("Auftrag steht", "Arbeitsplaner → Disponent startet die Fachkraft"),
    ("kein Auftrag nötig", "Arbeitsplaner, mit Begründung → Disponent"),
]
PRUEFER, DISPONENT = "Prüfer", "Disponent"  # 1739: neue Profile; lauf.py setzt bis tools/1727-SCHARF Diogenes, Ford ein
COMMIT = re.compile(r"\b[0-9a-f]{7,40}\b")
BLOCK = re.compile(r"(?m)^- \*\*(?P<zeit>[^*]+)\*\*, (?P<wer>[^\n]*?)(?: \(`(?P<sid>[^`]*)`\))?:\n> (?P<text>.*)$")


def worte(text):
    """Signalworte am Anfang (Meldung Prüfer: „nein“ + „steckt fest“ in einer Meldung)."""
    t = (text or "").strip()
    # Stempel davor („**Spike** [21.11., 20:41]“, „Spike [..]:“) zählt nicht (Hinweis Diogenes zu 1763)
    m = re.match(r"^\W*?(?:\*\*([A-ZÄÖÜ][\wäöüß]*(?: \d+)?)\*\*|([A-ZÄÖÜ][\wäöüß]*(?: \d+)?)(?=\s*\[\d))\s*(\[\d{1,2}\.\d{1,2}\.(?:\d{4})?,? ?\d{1,2}:\d{2}\])?\s*", t)
    if m and (m.group(3) or (m.group(1) and m.group(1).lower() not in SIGNAL)): t = t[m.end():]  # D329.2: fettes Signalwort bleibt
    t = re.sub(r"^\W+", "", t).lower()
    w = set()
    if re.match(r"nein,?\s+auftrag\b", t): w.add("nein, Auftrag")
    elif re.match(r"beleg fehlt\b", t): w.add("Beleg fehlt")
    elif re.match(r"wirkt nein\b", t): w.add("wirkt nein")
    elif re.match(r"nein\b", t): w.add("nein")
    elif re.match(r"steckt fest\b", t): w.add("steckt fest")
    elif re.match(r"frage\b", t): w.add("Frage")
    elif re.match(r"fertig\b", t): w.add("fertig")
    elif re.match(r"ja\b", t):
        w.add("ja")
        if re.match(r"ja\W+lauf\s+frei\b", t): w.add("Lauf frei")  # 1952 (Endvorlage Lauf 4 Nr. 21, 22): keine Testbitte
    elif re.match(r"hinweis\b", t): w.add("Hinweis")
    elif re.match(r"laufanforderung\b", t): w.add("Laufanforderung")  # 1952 (ersetzt „abgebrochen“, 1782/1797)
    elif re.match(r"befunde:\s*\d+", t): w.add("Befunde")  # 1795: Meldung des Testers (profil-tester.md „Meldung“)
    elif re.match(r"auftrag steht\b", t): w.add("Auftrag steht")  # 1797 Kern Arbeitsplaner :3
    elif re.match(r"kein auftrag nötig\b", t): w.add("kein Auftrag nötig")  # 1797 Ausgang des Arbeitsplaners
    if "nein" in w and re.search(r"\bsteckt fest\b", t): w.add("steckt fest")
    if "Hinweis" not in w and re.search(r"(?:^|[\s.;,(])hinweis:", t):  # 1797: „Hinweis:“ auch hinter dem ersten Wort
        w.add("Hinweis im Text" if w else "Hinweis")
    return w


BELEG_ALS_NEIN = 3  # 1926 (1727j Frage 2, Chef 22.11., 11:22): drittes „Beleg fehlt“ je Auftrag gilt als „nein“
_ZEIT = re.compile(r"(\d\d)\.(\d\d)\.,? (\d\d):(\d\d)")

def _zeit(s):
    m = _ZEIT.search(s or "")
    return tuple(int(x) for x in (m.group(2), m.group(1), m.group(3), m.group(4))) if m else None

def beleg_als_nein(text):
    """1926: „Beleg fehlt“ des Prüfers zählt je Auftrag (Rückmeldungen ab dem jüngsten Abschnitt „## Auftrag (TT.MM., HH:MM)“ davor);
    jedes dritte gilt als „nein“ und zählt so für Laufbremse und Obergrenze A. Zahl solcher „nein“ in der Datei."""
    auftraege = sorted(t for t in (_zeit(m.group(0)) for m in re.finditer(r"(?m)^## Auftrag \([^)]*\)", text or "")) if t)
    je = {}
    for m in BLOCK.finditer(ue.abschnitt(text, "Rückmeldungen")):
        if "Beleg fehlt" not in worte(m.group("text")): continue
        t = _zeit(m.group("zeit"))
        a = max((x for x in auftraege if t and x <= t), default=None)
        je[a] = je.get(a, 0) + 1
    return sum(n // BELEG_ALS_NEIN for n in je.values())


def zaehlen(text):
    """Zählt die Signalworte der Rückmeldungen einer Vorgangsdatei; 1872: jedes Chef-Nein unter „Chefworte“ (chefwort.chef_nein,
    ganzer Wortlaut) zählt als abgelehnter Auftrag („nein“), sonst stoppt „Prüfer ja, Chef nein“ nie.
    1925 (1727j Frage 1, Chef 22.11., 11:21 „Frage 1 ja.“): das Chef-Nein zählt auch für die Laufbremse (Rückbau 1910): Chef-Nein,
    ein Versuch der Fachkraft, beim nächsten Nein „steckt fest“ an Sokrates."""
    z = {"nein, Auftrag": 0, "nein": 0, "steckt fest": 0, "Laufanforderung": 0}
    zuletzt = None  # 1952: jüngste Meldung der Fachkraft (fertig/Laufanforderung mit Commit)
    for m in re.finditer(r"(?m)^- \*\*[^*]+\*\*, [^\n]*:\n> (.*)$", ue.abschnitt(text, "Rückmeldungen")):
        ws = worte(m.group(1))
        if "Laufanforderung" in ws and not COMMIT.search(m.group(1)): continue  # 1952: ohne Commit zurückgewiesen, zählt nicht
        if ws & {"fertig", "Laufanforderung"} and COMMIT.search(m.group(1)): zuletzt = "Laufanforderung" if "Laufanforderung" in ws else "fertig"
        if "nein" in ws and zuletzt == "Laufanforderung":  # Profil Prüfer: dieses „nein“ zählt nicht (zählt die Laufanforderung)
            ws = ws - {"nein"}
        for w in ws:
            if w in z: z[w] += 1
    z["steckt fest"] += max(0, z["Laufanforderung"] - (MAX_LAUF - 1))  # 1952: zweite und jede weitere zählt als „steckt fest“
    z["nein"] += beleg_als_nein(text)  # 1926
    import chefwort
    vorher = z["nein"]
    for m in re.finditer(r"(?m)^- \*\*[^*]+\*\*, Chef[^\n]*:\n((?:> .*\n?)+)", ue.abschnitt(text, "Chefworte")):
        if chefwort.chef_nein("\n".join(l[2:] for l in m.group(1).splitlines())): z["nein"] += 1
    if z["nein"] == vorher and nein_unter_bisher(text): z["nein"] += 1  # 1948: einmal, wenn „Chefworte“ es nicht schon zählte
    return z


def nein_unter_bisher(text):
    """1948 (Falltest Lauf 4 P1, P2, P6; Profil Prüfer: „jedes Nein unter ‚Bisher‘ oder in der Vorgangsdatei“; 1727j Frage 1, Chef
    22.11., 11:21: dein Nein unter „Bisher“ zählt als erster Fehlversuch): Feld 3 „Bisher“ des jüngsten Auftrags nennt ein Nein des Chefs
    (chefwort.bisher_nein)."""
    import auftrag, chefwort
    auf = [m for m in re.finditer(r"(?m)^## Auftrag \([^)]*\)\n", text or "")]
    if not auf: return False
    best = max(auf, key=lambda m: _zeit(m.group(0)) or (0, 0, 0, 0))
    teil = text[best.end():]
    n = re.search(r"(?m)^## ", teil)
    return chefwort.bisher_nein(auftrag._feld(teil[:n.start()] if n else teil, 3, "Bisher") or "")


def kosten_summe(kost):
    """Kostenspalte als Zahl wie vorgangskosten.py (Freitext „8,97 $; Jerry 1,26 $; +1,25 $“: alle Beträge addiert); None ohne Betrag."""
    zahlen = [float(z.replace(",", ".")) for z in re.findall(r"(\d+(?:,\d+)?)\s*\$?", kost or "")]
    return sum(zahlen) if zahlen else None


def kosten_bisher(nr):
    """1927 (1727j Frage 5, Chef 22.11., 11:31): Summe der Sitzungen auf dem Vorgang aus der Kostenspalte der Vorgangsliste
    (alte und umgestellte Liste, startbar liest beide), None, wenn die Zeile fehlt oder keinen Betrag trägt (nie „0 $“)."""
    try:
        import startbar
        d = next((x for x in startbar.zeilen_liste() if x["nr"] == nr), None)
    except Exception:
        d = None
    return kosten_summe(d.get("kosten")) if d else None


def kopf_kosten(t, nr, zeit):
    """1927: Zeile „Kosten bisher: …“ in den Kopf der Vorgangsdatei (vor dem ersten „## “; eine alte Zeile wird ersetzt), damit die
    Leitung sie in die Chefsache übernimmt (Soll K3.6)."""
    k = kosten_bisher(nr)
    wert = ("%.2f $" % k).replace(".", ",") if k is not None else "kein Betrag in der Vorgangsliste"
    zeile = "Kosten bisher: %s (Stand %s, Summe der Sitzungen laut Vorgangsliste; 1927)" % (wert, zeit)
    if re.search(r"(?m)^Kosten bisher: .*$", t):
        return re.sub(r"(?m)^Kosten bisher: .*$", lambda m: zeile, t, count=1)
    i = t.find("\n## ")
    if i < 0: return t.rstrip("\n") + "\n\n" + zeile + "\n"
    return t[:i].rstrip("\n") + "\n\n" + zeile + "\n" + t[i:]


def zustand_ruht(t, zeit, grund):
    """Zeile „Zustand: ruht, beim Chef …“ oben in „## Rückmeldungen“ (legt den Abschnitt an, falls er fehlt; 1763, 1872)."""
    if "\n## Rückmeldungen\n" not in t:
        t = ue.anhaengen(t, "Rückmeldungen", "Wörtlich, mit Zeit; trägt `vorgang.py rueckmeldung` ein (1763).", "")
    return t.replace("\n## Rückmeldungen\n", "\n## Rückmeldungen\n\nZustand: %s seit %s (%s, 1763)\n" % (RUHT, zeit, grund), 1)


def _listen_besitzer(nr):
    try:
        import startbar
        b = next((d.get("besitzer") for d in startbar.zeilen_liste() if d["nr"] == nr), None)
    except Exception:
        b = None
    b = (b or "").strip()
    return b if b and b not in ("-", "–") else None


def macher(text, nr=None):
    """1739: wer zuletzt „fertig“ meldete (Rückmeldungen der Datei, ohne die gerade eingetragene); None, wenn keiner.
    1888 (Lauf 3 Prüfer-1 L9): steht dort „unbekannt“ (Sitzung ohne Besetzungszeile), die Rolle ihrer Sitzung aus der Besetzung
    von jetzt, sonst der Besitzer des Vorgangs in der Liste (Nummer aus der Kopfzeile „# NR · …“); erst dann None (Disponent)."""
    ms = [m for m in BLOCK.finditer(ue.abschnitt(text, "Rückmeldungen")) if worte(m.group("text")) & {"fertig", "Laufanforderung"}]
    if not ms: return None
    w = ms[-1].group("wer").strip()
    if w and w != "unbekannt": return w
    sid = ms[-1].group("sid") or ""
    if sid:
        try:
            import chefwort
            r = chefwort._rolle_aus_besetzung(sid)
            if r: return r
        except Exception:
            pass
    if nr is None:
        k = re.match(r"#\s*(\d+(?:\.\d+)?[a-z]?)\b", text or "")
        nr = k.group(1) if k else None
    return _listen_besitzer(nr) if nr else None


ROUTINEN = ("Rundblick", "Ideenlauf", "Wache", "Tagesbericht", "Wochenzählung")  # 1947: Rolle der Routine-Sitzung (lauf.py START)

def ist_routine(nr, wer=None):
    """1947 (Falltest Lauf 4 R1): auch wenn die meldende Sitzung eine Routine ist (Rolle aus der Besetzung oder --sitzung), gleich unter
    welchem Vorgang sie meldet; der Titel trägt die Marke dann nicht (Rundblick unter 1734)."""
    if re.sub(r" \d+$", "", wer or "") in ROUTINEN: return True
    return _ist_routine(nr)


def _ist_routine(nr):
    """1789: Vorgang nr ist eine Routine (Titel „(Routine, Auftrag …)“, auftrag.routine); sie baut nichts, „fertig“ ohne Commit gilt."""
    try:
        import auftrag, startbar
        return any(d["nr"] == nr and auftrag.routine(d["titel"]) for d in startbar.vorgangsliste(startbar.lesen(startbar.LISTE)))
    except Exception:
        return False


NR_BEFUND = re.compile(r"(?:\bNr\.?\s*|\bVorgang\s+|#)(\d{1,4}[a-z]?(?:\.\d+[a-z]?)*)\b|,\s*(\d{1,4}[a-z]?(?:\.\d+[a-z]?)*)\s*\.?\s*$")


def befunde(text):
    """1795 (profil-tester.md „Meldung“): (n, [(Zeile, Nummer oder None)]) aus „Befunde: n“; je Befund eine Zeile (Art, Ort, Sachverhalt,
    Beleg, gegebenenfalls Nummer) bis zur Leerzeile, zur Abnahmeliste oder zum ersten „Hinweis:“. Nummer: „Nr. X“, „Vorgang X“, „#X“
    oder letztes Feld nach Komma."""
    L = (text or "").strip().splitlines()
    m = re.search(r"(?i)befunde:\s*(\d+)", L[0] if L else "")
    n = int(m.group(1)) if m else 0
    rest = (L[0][m.end():] if m else "").strip(" :–-")
    aus = []
    for z in ([rest] if rest else []) + L[1:]:
        zz = z.strip()
        if not zz:
            if aus: break
            continue
        if re.match(r"(?i)\W*(abnahmeliste|hinweis\b|nicht prüfbar)", zz): break
        zz = re.sub(r"^(?:[-*•]|\d+[.)])\s+", "", zz)
        g = NR_BEFUND.search(zz)
        aus.append((zz, (g.group(1) or g.group(2)) if g else None))
    return n, aus


def befund_weitergabe(nr, text, zeit, wer):
    """1795: [(an, was)]: eine Zeile „Befunde: n“ an den Disponenten (ohne Nummer: Vorgang anlegen), je Befund mit Nummer ein Rückläufer
    an den Arbeitsplaner dieses Vorgangs; weicht n von der Zahl der Zeilen ab, steht es in der Zeile an den Disponenten."""
    n, bs = befunde(text)
    von = "Befunde des Testers zu %s (Rückmeldung %s von %s)" % (nr, zeit, wer or "unbekannt")
    ohne = [b for b, x in bs if not x]
    satz = "Befunde: %d (%s)" % (n, von)
    if len(bs) != n: satz += "; %d Zeilen gelesen, nachsehen" % len(bs)
    satz += ("; ohne Nummer je Befund einen Vorgang anlegen: " + " | ".join(ue._rein(b)[:120] for b in ohne)) if ohne else "; nichts anzulegen"
    aus = [(DISPONENT, satz)]
    for b, x in bs:
        if x: aus.append((PLANER, "Rückläufer zu %s (%s): „%s“; Auftrag nachbessern oder neu (1795)" % (x, von, ue._rein(b)[:160])))
    return aus


def ist_werkzeug(nr):
    """1790: Vorgang nr ist ein Werkzeug (Bereich B, 724 A); es geht nach grünem Lauf ohne Test des Chefs nach main (1311)."""
    try:
        import startbar
        return any(d["nr"] == nr and d.get("bereich", "").startswith("B ") for d in startbar.vorgangsliste(startbar.lesen(startbar.LISTE)))
    except Exception:
        return False


def nicht_auf_main(text, nr, zeit, wer):
    """1950 (Falltest Lauf 4 D3; Chef 19.11., 22:16 Anhalt 5 Minuten): „fertig“ mit Commit zu einem Werkzeug (Bereich B, nach grünem Lauf
    sofort auf main, 1311): steht der Commit nicht auf origin/main, im selben Commit eine Zeile an die Fachkraft (wer meldete; unbekannt:
    Disponent) „auf main, Vollzug mit Commit“; (an, was) oder None, wenn er dort steht."""
    import liegt
    try: ue._git("fetch", "-q", "origin", "main")
    except Exception: pass
    for c in COMMIT.findall(text or ""):
        r = liegt.auf_main(c, ue.WURZEL)
        if r is True: return None
        if r is False or r is None:
            an = re.sub(r" \d+$", "", wer or "")
            an = an if an and an not in ("unbekannt", DISPONENT, "Ford") else DISPONENT
            grund = "steht nicht auf origin/main" if r is False else "ist auf origin nicht bekannt (nicht gepusht?)"
            return an, "auf main, Vollzug mit Commit: %s %s (Prüfung beim Eintrag %s, 1950); Werkzeug nach grünem Lauf sofort auf main (1311), dann `vorgang.py rueckmeldung %s` „fertig“ mit dem Commit auf main" % (c, grund, zeit, nr)
    return None


PRUEFFRAGE_FEHLT = re.compile(r"(?i)^\W*hinweis\W+pr(ü|ue)ffrage\w*\s+fehl")


def besitzer(nr, vorher):
    """1877: Besitzer des Vorgangs aus der Liste (bis zur Umschaltung); ohne Besitzer der Macher (letztes „fertig“), sonst None."""
    return _listen_besitzer(nr) or macher(vorher, nr)


def hinweis_weitergabe(nr, text, zeit, wer, vorher):
    """1873, 1877: [(an, was)] für „Hinweis“: Prüffrage fehlt → Arbeitsplaner; vom Disponenten → Besitzer und Sokrates; sonst Disponent."""
    satz = ue._rein(text)[:160]
    von = "Rückmeldung %s von %s" % (zeit, wer or "unbekannt")
    if PRUEFFRAGE_FEHLT.match(re.sub(r"^\W*?\*\*[^*]+\*\*\s*(\[[^\]]*\])?\s*", "", text or "")):
        return [(PLANER, "Hinweis Prüffrage fehlt (%s): „%s“; Prüffragen des Auftrags ergänzen (1873)" % (von, satz))]
    if re.sub(r" \d$", "", wer or "") in (DISPONENT, "Ford"):
        b = besitzer(nr, vorher) or PLANER
        return [(b, "Hinweis des Disponenten (%s): „%s“; im Vorgang bearbeiten (1877)" % (von, satz)),
                (SOKRATES, "Hinweis (%s, an %s weitergegeben): „%s“ (1877, Soll D1)" % (von, b, satz))]
    return [(DISPONENT, "Hinweis (%s): wie einen Eingang behandeln (1739)" % von)]


def weitergabe(w, t, zeit, wer, text, vorher, routine=False, werkzeug=False):
    """1739 (3.3 Nr. 5): Empfänger und Zeile für „fertig“, „nein“, „Beleg fehlt“, „ja“, „Hinweis“; (None, None) sonst."""
    satz = ue._rein(text)[:160]
    von = "Rückmeldung %s von %s" % (zeit, wer or "unbekannt")
    if w & {"nein", "Beleg fehlt"}:
        m = macher(vorher)
        wort = "nein" if "nein" in w else "Beleg fehlt"
        if m: return m, "Rückläufer (%s des Prüfers, %s): „%s“; nachbessern, dann `vorgang.py rueckmeldung` „fertig“ mit Commit (1739)" % (wort, von, satz)
        return DISPONENT, "Rückläufer (%s, %s), Fachkraft unbekannt (kein „fertig“ in der Vorgangsdatei): an dieselbe Fachkraft zurückgeben (1739)" % (wort, von)
    if "fertig" in w:
        if routine and not COMMIT.search(text):  # 1789: Rundblick endet ohne Commit (routine-rundblick.md Teil A „Ergebnis“)
            return DISPONENT, "Routine fertig (%s): Vorschläge aus den offenen Übergabezeilen als Vorgänge anlegen, dann `vorgang.py schliessen` (1789)" % von
        if COMMIT.search(text): return PRUEFER, "prüfen: „fertig“ (%s): „%s“ (1739)" % (von, satz)
        return DISPONENT, "„fertig“ ohne Commit (%s): nicht annehmen, Fachkraft nennt Commit und Beleg (1739)" % von
    if "ja" in w and (lauf_offen(vorher) or "Lauf frei" in w):  # 1952: Prüfer gibt die Laufanforderung frei, nie Testbitte
        m = macher(vorher)
        if not lauf_offen(vorher):
            return DISPONENT, "ja, Lauf frei (%s) ohne offene Laufanforderung: keine Testbitte; Prüfer fragen, welcher Lauf gemeint ist (1952)" % von
        return DISPONENT, "Laufanforderung freigegeben (ja, Lauf frei des Prüfers, %s): %s einmal neu starten, Auftrag unverändert; keine Testbitte (1952)" % (von, m or "dieselbe Fachkraft")
    if "ja" in w and werkzeug:  # 1790 (Sokrates 1727 Nachprüfung 22:20): Werkzeug, keine Testbitte an den Chef
        return DISPONENT, "ja des Prüfers (%s): Werkzeug (Bereich B), kein Test des Chefs (1311): liegt der Zweig nicht auf main, mischt der Macher jetzt; dann `vorgang.py fertig`" % von
    if "ja" in w: return DISPONENT, "ja des Prüfers (%s): an den Chef vorlegen (Testbitte), nicht selbst nach main (1739)" % von
    if "Hinweis" in w: return DISPONENT, "Hinweis (%s): wie einen Eingang behandeln (1739)" % von
    if "Auftrag steht" in w: return DISPONENT, "Auftrag steht (%s): Fachkraft nach Profil des Auftrags starten (1797)" % von
    if "kein Auftrag nötig" in w: return DISPONENT, "kein Auftrag nötig (%s): Begründung lesen, Vorgang schließen (`vorgang.py schliessen`) oder an Sokrates (1797)" % von
    return None, None


def lauf_offen(text):
    """1952: die jüngste Meldung der Fachkraft („fertig“ oder „Laufanforderung“ mit Commit) ist eine Laufanforderung."""
    ms = [worte(m.group("text")) for m in BLOCK.finditer(ue.abschnitt(text, "Rückmeldungen"))
          if worte(m.group("text")) & {"fertig", "Laufanforderung"} and COMMIT.search(m.group("text"))]
    return bool(ms) and "Laufanforderung" in ms[-1]


def unbekannt(text, wer):
    """1952: Grund zum Zurückweisen (Text bleibt eingetragen) oder None. Chefworte nie."""
    if (wer or "").strip().lower() == "chef": return None
    w = worte(text)
    if not w:
        return "erstes Wort nicht im Katalog der Rückmeldewörter; neu melden mit einem davon (1952):\n" + "\n".join("  %s: %s" % k for k in KATALOG)
    if "Laufanforderung" in w and not COMMIT.search(text):
        return "Laufanforderung nur mit Ursache und Commit der Behebung; neu melden (1952)"
    return None


def _datei(nr):
    """Vorgangsdatei nach dem Eintrag: lokal, sonst von origin/main (1789: neue Datei, Notizkopie mit ungepushten Änderungen
    zog nicht nach; Absturz FileNotFoundError nach erfolgreichem Push, ein zweiter Aufruf trug doppelt ein)."""
    p = os.path.join(ue.WURZEL, ue._pfad(nr))
    if os.path.exists(p): return open(p, encoding="utf-8").read()
    import subprocess
    r = subprocess.run(["git", "-C", ue.WURZEL, "show", "origin/main:" + ue._pfad(nr)], capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else ""


def ruht(text):
    return re.search(r"(?m)^Zustand: " + re.escape(RUHT), text) is not None


def eintragen(nr, text, wer, sid=""):
    """Ein Commit: Rückmeldung, ggf. Zustand und Übergabezeile. Rückgabe (Kennung oder None, Grund)."""
    text = (text or "").strip()
    if not text: raise ue.Fehler("Text nötig")
    zeit = ue.fmt(ue.jetzt())
    block = "- **%s**, %s%s:\n%s\n" % (zeit, wer or "unbekannt", (" (`%s`)" % sid) if sid else "", "\n".join("> " + z for z in text.splitlines()))
    w = worte(text)
    def f(alt):
        t = ue._mit_abschnitt(alt, nr)
        if block in t: return alt, (None, "schon eingetragen")
        schon = ruht(ue.abschnitt(t, "Rückmeldungen"))
        vorher = t
        t = ue.anhaengen(t, "Rückmeldungen", "Wörtlich, mit Zeit; trägt `vorgang.py rueckmeldung` ein (1763).", block)
        z = zaehlen(t)
        if "Beleg fehlt" in w and beleg_als_nein(t) > beleg_als_nein(vorher):  # 1926: drittes „Beleg fehlt“ je Auftrag gilt als „nein“
            w.discard("Beleg fehlt"); w.add("nein")
        grund = None
        lauf_ok = "Laufanforderung" in w and COMMIT.search(text)
        lauf2 = bool(lauf_ok) and z["Laufanforderung"] >= MAX_LAUF  # 1952: zählt als „steckt fest“
        aus = None  # mehrere Zeilen in einem Commit (1795 Befunde, 1873, 1877); sonst nur (an, was)
        if not schon:
            if "nein, Auftrag" in w and z["nein, Auftrag"] >= MAX_NEIN_AUFTRAG: grund = "Obergrenze A: %d. „nein, Auftrag“" % z["nein, Auftrag"]
            elif "nein" in w and z["nein"] >= MAX_NEIN: grund = "Obergrenze A: %d. abgelehnter Auftrag" % z["nein"]
            elif (lauf2 or "steckt fest" in w) and z["steckt fest"] >= MAX_FEST: grund = "Obergrenze B: %d. „steckt fest“" % z["steckt fest"]
        if grund:
            t = zustand_ruht(t, zeit, grund)
            if grund.startswith("Obergrenze B"): t = kopf_kosten(t, nr, zeit)  # 1927
            an, was = SOKRATES, "an den Chef: Chefsache anlegen, nicht selbst lösen (%s; Rückmeldung %s von %s)" % (grund, zeit, wer or "unbekannt")
        elif schon and lauf_ok:  # 1976 (1566): Laufanforderung mit Commit an ruhenden Vorgang → Prüfer, nie still
            an, was = PRUEFER, "Laufanforderung prüfen, Vorgang ruht, beim Chef (Rückmeldung %s von %s): „%s“; Ursache und Commit der Behebung ansehen: „ja“ gibt den erneuten Lauf frei, „nein“ mit Satz zurück an die Fachkraft (1952, 1976)" % (zeit, wer or "unbekannt", ue._rein(text)[:160])
        elif schon and w and not unbekannt(text, wer):  # 1976: jedes andere Signalwort an ruhenden Vorgang → mindestens Sokrates
            an, was = SOKRATES, "%s an ruhenden Vorgang (ruht, beim Chef): Rückmeldung %s von %s lesen; Chefsache ergänzen oder Zustand aufheben (1976)" % (" und ".join(sorted(w)), zeit, wer or "unbekannt")
        elif schon:
            an = was = None
        elif w & {"steckt fest", "Frage", "wirkt nein"}:
            an, was = SOKRATES, "%s: Rückmeldung %s von %s lesen (1763 C)%s" % (" und ".join(sorted(w & {"steckt fest", "Frage", "wirkt nein"})), zeit, wer or "unbekannt",
                                                                            "; gelöst: `vorgang.py warte %s –`" % nr if "steckt fest" in w else "")
            m = macher(vorher, nr) if "nein" in w else None
            if m:  # 1873 (Lauf 3 Prüfer-2 Lücke 1): die Mängelsätze erreichen auch den Macher; er wartet, bis Sokrates löst
                aus = [(an, was), (m, "Rückläufer (nein des Prüfers, steckt fest, Rückmeldung %s von %s): „%s“; erst nach Sokrates (`wartet auf`) nachbessern, dann `vorgang.py rueckmeldung` „fertig“ mit Commit (1873)" % (zeit, wer or "unbekannt", ue._rein(text)[:160]))]
        elif "nein" in w and z["nein"] == LAUFBREMSE_NEIN:  # 1925: Chef-Nein zählt mit (Chef 22.11., 11:21)
            an, was = SOKRATES, "steckt fest (Laufbremse, %d. Nein; Chef 19.11., 13:02): Rückmeldung %s von %s lesen (1766)" % (z["nein"], zeit, wer or "unbekannt")
        elif "nein, Auftrag" in w:
            an, was = PLANER, "nein, Auftrag: Rückmeldung %s von %s lesen" % (zeit, wer or "unbekannt")
        elif "Befunde" in w:  # 1795
            aus = befund_weitergabe(nr, text, zeit, wer); an, was = aus[0]
        elif "Hinweis" in w:  # 1873, 1877
            aus = hinweis_weitergabe(nr, text, zeit, wer, vorher); an, was = aus[0]
        elif "Laufanforderung" in w and not lauf_ok:
            an = was = None  # 1952: ohne Commit zurückgewiesen (haupt)
        elif lauf2:
            an, was = SOKRATES, "steckt fest (%d. Laufanforderung, 1952): Rückmeldung %s von %s lesen; gelöst: `vorgang.py warte %s –`" % (z["Laufanforderung"], zeit, wer or "unbekannt", nr)
        elif "Laufanforderung" in w:
            an, was = PRUEFER, "Laufanforderung prüfen (Rückmeldung %s von %s): „%s“; Ursache und Commit der Behebung ansehen: „ja“ gibt den erneuten Lauf frei, „nein“ mit Satz zurück an die Fachkraft (1952)" % (zeit, wer or "unbekannt", ue._rein(text)[:160])
        else:
            an, was = weitergabe(w, t, zeit, wer, text, vorher, "fertig" in w and ist_routine(nr, wer), "ja" in w and ist_werkzeug(nr))
            if "fertig" in w and an == PRUEFER and ist_werkzeug(nr):  # 1950: Werkzeug sofort auf main prüfen, nicht beim nächsten Wecker
                z2 = nicht_auf_main(text, nr, zeit, wer)
                if z2: aus = [(an, was), z2]
        if not an: return t, (None, "eingetragen, zurückgewiesen (1952; Vorgang ruht)" if schon else "eingetragen, zurückgewiesen (1952)"
                              if unbekannt(text, wer) else "eingetragen, kein Signalwort zum Weitergeben")
        ks = [int(x["k"].rsplit("Ü", 1)[1]) for x in ue.zeilen(t)]
        start = max(ks, default=0) + 1
        k = "%s-Ü%d" % (nr, start)
        t = t.rstrip("\n") + "\n"
        for j, (a2, w2) in enumerate(aus or [(an, was)]):
            t += "| %s-Ü%d | %s | %s | %s | offen |\n" % (nr, start + j, a2, ue._rein(w2), zeit)
        if "Hinweis im Text" in w and not grund:  # (schon: grund ist hier noch None, Zeile auch an ruhenden Vorgang)  # 1797: Hinweis hinter einem anderen Signalwort → zweite Zeile an den Disponenten
            h = re.search(r"hinweis:\s*(.*)", text, re.I | re.S)
            t += "| %s-Ü%d | %s | %s | %s | offen |\n" % (nr, start + len(aus or [1]), DISPONENT, ue._rein("Hinweis (Rückmeldung %s von %s): „%s“; wie einen Eingang behandeln (1797)" % (zeit, wer or "unbekannt", ue._rein(h.group(1))[:160] if h else "")), zeit)
        return t, (k, grund or (RUHT_SCHON if schon else ""))
    return ue.atomar(nr, f, "Rückmeldung %s von %s (1763)" % (nr, wer or "unbekannt"))


def liste_atomar(nr, stand, warte_dazu=(), nachricht=""):
    """1800 (Falltest Lauf 2, D10/D11): Stand und „wartet auf“ der Zeile nr in einem eigenen Commit auf origin/main setzen, wie
    uebergabe.atomar (vorher nur lokal, ungepusht: lauf.py startete die Fachkraft weiter). stand: Text oder Funktion(alter Stand, Wort).
    Rückgabe: Text der Meldung."""
    import startbar
    def f(alt):
        if not alt.strip(): return alt, "Liste nicht gelesen"
        d = next((x for x in startbar.vorgangsliste(alt) if x["nr"] == nr), None)
        if not d: return alt, "%s nicht in der Liste" % nr
        n = dict(d, stand=stand(d["stand"], d["wort"]) if callable(stand) else stand,
                 warte=list(d["warte"]) + [w for w in warte_dazu if w not in d["warte"]])
        L = alt.split("\n"); L[d["i"]] = startbar.zeile_text(n)
        return "\n".join(L), "Stand „%s“%s" % (n["stand"], (", wartet auf " + ", ".join(n["warte"])) if n["warte"] else "")
    return ue.atomar(nr, f, nachricht or "%s: Stand nach Rückmeldung (1800)" % nr, pfad="docs/" + startbar.LISTE)


def fest_stand(alt, wort):
    """Erstes „steckt fest“: Wort bleibt, Zusatz „steckt fest“ (liegt.stand_von zählt es als Stand; 14.2.12)."""
    return alt if "steckt fest" in (alt or "") else "%s, steckt fest" % (wort or "startbar")


def liste_ruht(nr, grund):
    """Solange die Vorgangsliste Stände trägt: Stand „ruht, beim Chef“, gepusht (1800)."""
    try: print("LISTE %s: %s (gepusht)" % (nr, liste_atomar(nr, "%s (%s)" % (RUHT, grund.split(":")[0]), (), "%s: ruht, beim Chef (%s, 1763 B)" % (nr, grund))))
    except ue.Fehler as e: print("LISTE nicht geändert (%s); von Hand: vorgang.py stand %s \"%s\"" % (e, nr, RUHT))


def liste_fest(nr):
    """1800: erstes „steckt fest“ → Zusatz „steckt fest“ und „wartet auf Sokrates“, gepusht; lauf.py startet die Fachkraft nicht mehr."""
    try: print("LISTE %s: %s (gepusht)" % (nr, liste_atomar(nr, fest_stand, (SOKRATES,), "%s: steckt fest, wartet auf Sokrates (1763 C, 1800)" % nr)))
    except ue.Fehler as e: print("LISTE nicht geändert (%s); von Hand: vorgang.py warte %s Sokrates" % (e, nr))


def fest_an_sokrates(nr, kennung, an, grund):
    """1904 (D340.2): „steckt fest“ einer Übergabezeile → Zeile an Sokrates und Liste „steckt fest, wartet auf Sokrates“ in EINEM Commit
    auf origin/main (uebergabe.atomar_dateien). Steht schon eine Zeile an Sokrates zu KENNUNG, nichts (je Lauf nachholbar, gleich ob
    der Zustand in lauf.py, von Hand mit `vorgang.py offen --sitzungen` oder über „abgebrochen“ entstand, und nach einem Fehler).
    Rückgabe: neue Kennung oder None (schon da). Fehler (ue.Fehler) gehen an den Aufrufer."""
    import startbar
    vp, lp = ue._pfad(nr), "docs/" + startbar.LISTE
    marke = "Übergabe %s an " % kennung
    was = ue._rein("steckt fest: Übergabe %s an %s zweimal ohne Ergebnis (%s; 1782, 1904); gelöst: `vorgang.py warte %s –`" % (kennung, an, grund, nr))
    def f(alt):
        if any(z["an"] == SOKRATES and marke in z["was"] for z in ue.zeilen(alt[vp])): return {}, None
        t = ue._mit_abschnitt(alt[vp], nr)
        ks = [int(z["k"].rsplit("Ü", 1)[1]) for z in ue.zeilen(t)]
        k = "%s-Ü%d" % (nr, max(ks, default=0) + 1)
        aus = {vp: t.rstrip("\n") + "\n| %s | %s | %s | %s | offen |\n" % (k, SOKRATES, was, ue.fmt(ue.jetzt()))}
        L = alt[lp]; d = next((x for x in startbar.vorgangsliste(L) if x["nr"] == nr), None) if L.strip() else None
        if d:
            n = dict(d, stand=fest_stand(d["stand"], d["wort"]), warte=list(d["warte"]) + ([SOKRATES] if SOKRATES not in d["warte"] else []))
            Z = L.split("\n"); Z[d["i"]] = startbar.zeile_text(n); aus[lp] = "\n".join(Z)
        return aus, k
    k = ue.atomar_dateien([vp, lp], f, "%s: Übergabe %s steckt fest, Zeile an Sokrates, wartet auf Sokrates (1782, 1904)" % (nr, kennung))
    if k: ue.wecker(nr, k, SOKRATES)
    return k


def nein_waechter(nr, text):
    """1739 (7.1, Büro-Gegenüberstellung F3): Wiederholungswächter auch auf jedes Nein; Treffer „Systemlösung?“.
    1887 (Lauf 3 Prüfer-1 L4): der Prüfer ändert nichts und committet nur Eigenes; darum ändert der Wächter hier die Liste nicht,
    sondern gibt je Treffer eine Zeile an den Disponenten, der die Zeile „Systemlösung?“ für Sokrates anlegt (`vorgang.py neu`).
    1913 (D344.2): liegt zum Stichwort schon eine offene Wächterzeile beim Disponenten (gleich in welchem Vorgang), keine zweite."""
    if not worte(text) & {"nein", "nein, Auftrag"}: return
    try:
        import vorgang, startbar, bereiche
        d = [x["bereich"] for x in startbar.zeilen_liste() if x["nr"] == nr and bereiche.gueltig(x["bereich"])]
        bereich = d[0] if d else "B Abläufe"
        try: offen = [was for _, was in ue.offen_lokal(DISPONENT)]  # 1913 (D344.2)
        except Exception: offen = []
        for w, frueher in vorgang.waechter_funde(nr, text):
            if any("Wiederholungswächter" in was and "Stichwort „%s“" % w in was for was in offen):
                print("Wächter: Stichwort „%s“ liegt schon offen beim Disponenten, keine zweite Zeile (1913)" % w); continue
            ue.uebergabe(nr, DISPONENT, "Wiederholungswächter (654, 1887): Stichwort „%s“ im Nein, %d frühere Vorgänge; anlegen: `vorgang.py neu \"%s\" \"%s\" K Sokrates`"
                         % (w, len(frueher), vorgang.waechter_titel(w, frueher, nr).replace('"', "'"), bereich))
    except ue.Fehler as e:
        print("Wächter: Zeile an den Disponenten nicht geschrieben (%s)" % e)
    except SystemExit as e:
        print("Wächter nicht gelaufen (%s)" % e)


def build_falsch(nr, text):
    """1949 (Falltest Lauf 4 T2: Tester meldete zu Build 300 in den fremden, erledigten Vorgang 300): bloße Nummer n, der Text nennt
    „Build n“ oder „tn“, und n ist kein offener Vorgang der Liste → Grund zum Anhalten (Meldung unter B<n>), sonst None."""
    if not re.fullmatch(r"\d+", nr or "") or not re.search(r"(?i)\bbuild\s+%s\b|(?<![\w.])t%s\b" % (nr, nr), text or ""): return None
    try:
        import startbar
        d = next((x for x in startbar.vorgangsliste(startbar.lesen(startbar.LISTE)) if x["nr"] == nr), None)
    except Exception:
        d = None
    if d and d.get("wort") not in (None, "erledigt", "verworfen", "aufgeteilt"): return None
    return "%s ist kein offener Vorgang, der Text meint Build %s: Build-Meldungen unter B%s (`vorgang.py rueckmeldung B%s …`, 1949)" % (nr, nr, nr, nr)


def haupt(a):
    a = list(a[1:]) if a[:1] == ["rueckmeldung"] else list(a)
    wer = None
    if "--sitzung" in a:
        i = a.index("--sitzung"); wer = a[i + 1]; del a[i:i + 2]
    if len(a) != 2: sys.exit(__doc__)
    sid = ""
    try: sid = ue.sitzung()
    except ue.Fehler: pass
    if wer is None:
        import chefwort
        wer = chefwort._rolle_aus_besetzung(sid) or "unbekannt"
    f = build_falsch(a[0], a[1])
    if f: sys.exit("vorgang.py rueckmeldung: %s; nichts geschrieben" % f)
    try:
        k, grund = eintragen(a[0], a[1], wer, sid)
    except ue.Fehler as e:
        sys.exit("vorgang.py rueckmeldung: %s; nichts geschrieben" % e)
    if grund != "schon eingetragen":  # 1739 Lehrenbuch, „Roh sammeln“: ja mit Ursache, zweites Nein
        import lehren
        dt = _datei(a[0])
        r = lehren.roh_aus_rueckmeldung(a[0], a[1], wer, dt, zaehlen(dt)["nein"])
        if r: print("LEHRENBUCH %s angehängt" % r)
    if not k:
        print("EINGETRAGEN %s: %s" % (a[0], grund))
        if grund != "schon eingetragen": nein_waechter(a[0], a[1])
        u = unbekannt(a[1], wer) if grund != "schon eingetragen" else None
        if u: sys.exit("vorgang.py rueckmeldung %s: ZURÜCKGEWIESEN, %s" % (a[0], u))
        return
    zeile = [x for x in ue.zeilen(_datei(a[0])) if x["k"] == k]
    an = zeile[0]["an"] if zeile else "?"
    if grund == RUHT_SCHON:  # 1976: Liste bleibt „ruht“ (kein liste_fest), keine zweite Obergrenze
        print("EINGETRAGEN %s, OFFEN %s an %s (%s, 1976)" % (a[0], k, an, RUHT_SCHON))
    else:
        print("EINGETRAGEN %s, OFFEN %s an %s%s" % (a[0], k, an, (" (%s → %s)" % (grund, RUHT)) if grund else ""))
    if grund == RUHT_SCHON: pass
    elif grund: liste_ruht(a[0], grund)
    elif an == SOKRATES and worte(a[1]) & {"steckt fest", "Laufanforderung"}: liste_fest(a[0])  # 1800, 1952
    nein_waechter(a[0], a[1])
    alt = {"Prüfer": "Diogenes", "Disponent": "Ford", PLANER: "Ford"}.get(an, "")  # 1739: bis zur Umschaltung (lauf.ALT_EMPFAENGER)
    if an == SOKRATES and not ue.besetzung(an):
        print("KEINE SITZUNG Sokrates läuft: lauf.py startet ihn (1763 C)")
    ue.wecker(a[0], k, an, alt)  # 1760: läuft keine Sitzung, Wecker an den Disponenten
    n0 = int(k.rsplit("Ü", 1)[1])  # 1795, 1873, 1877: weitere Zeilen desselben Commits ebenso wecken
    for x in ue.zeilen(_datei(a[0])):
        if x["k"] != k and x["k"].startswith(a[0] + "-Ü") and int(x["k"].rsplit("Ü", 1)[1]) > n0 and x.get("seit") == (zeile[0].get("seit") if zeile else None):
            print("OFFEN %s an %s" % (x["k"], x["an"]))
            ue.wecker(a[0], x["k"], x["an"], {"Prüfer": "Diogenes", "Disponent": "Ford", PLANER: "Ford"}.get(x["an"], ""))


if __name__ == "__main__":
    haupt(sys.argv[1:])
