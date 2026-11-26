#!/usr/bin/env python3
"""2042 Fassung 5 (Auftrag 26.11., 15:32): (a) lauf.py druckt höchstens 3.072 Byte, jede Tat-Zeile, Rest vollständig in einer Datei,
deren Pfad die letzte Zeile nennt; (b) Haken: der Disponent liest keine tool-results/* (Read, Grep, cat …), lauf.py mit der Datei
als SEITE geht durch, andere Rollen auch; (c) Rückfall bei need_input ohne Frage: „Frage siehe get_session post_turn_summary“.
Ohne Netz. Aufruf: python3 tools/lauf_2042e_test.py"""
import json, os, re, subprocess, sys, tempfile
H = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, H)
sys.argv = [sys.argv[0]]
import lauf

fehler = 0; faelle = 0
def pruefe(ok, was, zeige=""):
    global fehler, faelle
    faelle += 1
    if not ok:
        fehler += 1
        print("FEHL", was, str(zeige)[:400])

tmp = tempfile.mkdtemp()

# (a) Takt mit allen Zeilenarten, über 3 KB
lang = "x" * 1400
taten = ["STREICHEN 2042-Ü1 | Disponent | erledigt", "NEUSTART-LEITUNG session_A | Sokrates | 310 Tsd. Token | Übergabe",
         "START Figur | opus | env_1 | https://github.com/x/y | main | Anna – 2024 | Dein Rufname: Anna (Rolle Figur). " + lang,
         "ARCHIVIERE session_B | Arbeitsplaner | 1,20 $ | 2042", "WEITER session_C | Kampf | 1589.4 | Weiter: 1589.4",
         "ÜBERTRAGE session_D | Story | Soll der Wolf bellen?", "NACHRICHT Arbeitsplaner | session_E | Offene Zeilen: " + lang,
         "NACHRICHT Ford | - | Offene Zeilen an Disponent: " + lang, "TITEL session_F Disponent – Betrieb",
         "RÜCKMELDUNG 2042 | Werkzeug | fertig", "STARTSPERRE 15:03 Start Figur", "WARNUNG-LAUT Start Figur nicht angekommen (837)",
         "TOKEN session_G | Sokrates: get_session, lauf.py neu mit --token session_G=<used_tokens> (2042 d)",
         "URTEIL 26.11., 13:12 👍 auf Meldung, Nachricht 5071", "KLASSE 2051 (Tom): Muss oder Kür", "BUCHE session_H | Tom | 2,00 $ | 9001",
         "NICHTS Tom: Wochentermin 2060 angelegt, „Zählung“ (719; Notizen pushen)",
         "WARNUNG Seite abgeschnitten (has_more) in s.txt: Plan unvollständig, weitere Seite bis created_at vor 12:00 holen (2042)"]
rest = ["NICHTS %s: belegt (Sitzung …abc%d läuft)" % (r, i) for i, r in enumerate(["Tom", "Jerry", "Story", "Klang", "Welt"] * 5)]
rest += ["SITZUNG …abc%03d | Titel %d – in Arbeit – 2042 | idle | 120 Tsd." % (i, i) for i in range(12)]
# Chef 👍 16:28 (2042 A): WARNUNG und AUSGESCHLOSSEN gekürzt in die Konsole, eine Zeile je Warnung
WARN = ["WARNUNG Sitzung session_X „Yvonne – Auftrag 1694: nur Kostenschätzung, Deckel 3 $ (26.11., 15:15)“ hat keine Rolle im Titel: bleibt stehen, nicht archiviert (261.5) " + "z" * 200,
        "AUSGESCHLOSSEN 2024: Figur wartet auf Chef (190.2)"]
taten += WARN
rest += [
         "LIEGT 79 (gebaut 29, ruht 27) | Einzelheiten: python3 tools/liegt.py [Art]", "HINWEIS Sokrates läuft schon (2049)",
         "GUTHABEN 63 %: Stufe frei (287)", "LAUFSPERRE 287: höchstens 3 Fachkräfte zugleich", "NUR MUSS: 6 Muss/Eilt startbar, Kür ruht (2052)"]
ausgabe = []
for i in range(max(len(taten), len(rest))):  # gemischt wie im echten Takt
    if i < len(taten): ausgabe.append(taten[i])
    if i < len(rest): ausgabe.append(rest[i])
pruefe(sum(len(l.encode()) + 1 for l in ausgabe) > 3072 * 2, "Testtakt über 6 KB")
pfad = os.path.join(tmp, "rest.txt")
f = getattr(lauf, "konsole", None)
if f is None:
    pruefe(False, "lauf.konsole fehlt")
else:
    zeilen = f(ausgabe, pfad)
    druck = "".join(l + "\n" for l in zeilen) + lauf.rest_zeile(ausgabe, pfad) + "\n"
    pruefe(len(druck.encode()) <= 3072, "höchstens 3.072 Byte gedruckt", len(druck.encode()))
    for t in taten:
        pruefe(any(z == t or (pfad in z and len(z.split(" … (voll:")[0]) >= 40 and t.startswith(z.split(" … (voll:")[0])) for z in zeilen), "Tat-Zeile in der Ausgabe: " + t[:60])
    for r in rest: pruefe(r not in zeilen, "Rest nicht in der Ausgabe: " + r[:60])
    datei = open(pfad, encoding="utf-8").read().split("\n")
    pruefe(all(l in datei for l in ausgabe), "jede Zeile vollständig in der Restdatei")
    for z in zeilen:  # gekürzte Tat: Verweis mit Zeilennummer auf den vollen Wortlaut
        m = re.search(r"sed -n (\d+)p (\S+)\)$", z)
        if m: pruefe(datei[int(m.group(1)) - 1] in taten and m.group(2) == pfad, "Verweis zeigt auf die volle Zeile", z[-80:])
    letzte = lauf.rest_zeile(ausgabe, pfad)
    pruefe(letzte.startswith("REST ") and pfad in letzte and "NICHTS 25" in letzte and "SITZUNG 12" in letzte, "Restzeile mit Pfad und Zahl je Art", letzte)
    # Beleglauf 15:55: 200 Zeichen je Tat reichten nicht; 18 Taten und 6 lange STARTs/NACHRICHTen (Grenze: etwa 22 lange Taten)
    viele = taten + [l + " " + "y" * 300 for l in taten if l.startswith(("START ", "NACHRICHT "))] * 2 + rest
    zv = f(viele, pfad)
    pruefe(len(("".join(l + "\n" for l in zv) + lauf.rest_zeile(viele, pfad) + "\n").encode()) <= 3072 - lauf.KONSOLE_NACH, "24 Taten: Schleife und Restzeile im Budget",
           len("".join(l + "\n" for l in zv).encode()))
    pruefe(len(zv) == len(taten) + 6, "24 Taten: jede Tat-Zeile da", len(zv))
    kurz = ["START Tom | opus | x", "NICHTS Tom: belegt"]
    pruefe(f(kurz, pfad) == ["START Tom | opus | x"], "kleiner Takt: Taten unverändert")
    pruefe(lauf.ist_tat("WARNUNG-LAUT x") and lauf.ist_tat("WARNUNG x") and lauf.ist_tat("AUSGESCHLOSSEN 1: y") and not lauf.ist_tat("NICHTS Tom: belegt")
           and lauf.ist_tat("NEUE-ART unbekannt"), "Einordnung: WARNUNG, WARNUNG-LAUT, AUSGESCHLOSSEN Tat, NICHTS Rest, unbekannte Art Tat")
    w = [z for z in f(["WARNUNG " + "w" * 400, "START Tom | x"], pfad) if z.startswith("WARNUNG ")]
    pruefe(len(w) == 1 and len(w[0]) <= lauf.KURZ_WARNUNG + 80 and "sed -n 1p" in w[0], "WARNUNG immer gekürzt, eine Zeile mit Verweis", w)

# (a) im echten Programmlauf: letzte Zeile nennt die Restdatei (lauf.py-Hilfe druckt nur __doc__, darum Quelltext prüfen)
q = open(os.path.join(H, "lauf.py"), encoding="utf-8").read()
pruefe("for l in konsole(ausgabe" in q and "print(rest_zeile(" in q, "main druckt über konsole() und zuletzt rest_zeile()")

# (c) Rückfalltext
pruefe("Frage siehe list_events" not in q, "Rückfall nicht mehr „Frage siehe list_events“")
pruefe("Frage siehe get_session post_turn_summary" in q, "Rückfall „Frage siehe get_session post_turn_summary“")

# (b) Haken: neustart-haken.py vor
HAKEN = os.path.join(H, "neustart-haken.py")
ENV = {k: v for k, v in os.environ.items() if k not in ("CLAUDE_CODE_REMOTE_SESSION_ID",)}
ENV.update(BORNIM_KAUF=os.path.join(tmp, "kein-kauf"), CLAUDE_PROJECT_DIR=tmp, HOME=tmp)
n = [0]
def vor(erste, werkzeug, eingabe):
    n[0] += 1
    p = os.path.join(tmp, "p%d.jsonl" % n[0])
    with open(p, "w") as fh:
        fh.write(json.dumps({"type": "user", "message": {"content": erste}}) + "\n")
        fh.write(json.dumps({"type": "assistant", "message": {"usage": {"input_tokens": 2, "cache_read_input_tokens": 1000}}}) + "\n")
    sid = "t2042e-%d-%d" % (os.getpid(), n[0])
    e = {"session_id": sid, "transcript_path": p, "tool_name": werkzeug, "tool_input": eingabe}
    r = subprocess.run([sys.executable, HAKEN, "vor"], input=json.dumps(e), capture_output=True, text=True, env=ENV)
    for x in ("/tmp/bornim-name-" + sid, "/tmp/bornim-neustart-" + sid + ".json"):
        try: os.remove(x)
        except OSError: pass
    return r.returncode, r.stderr
D = "Du bist **Disponent**.\n\nTakt"
D2 = "Dora – Disponent – Betrieb (26.11.)"
TR = "/root/.claude/projects/-home-user-x/abc/tool-results/x.txt"
for erste in (D, D2):
    c, err = vor(erste, "Read", {"file_path": TR})
    pruefe(c == 2 and "als SEITE an lauf.py" in err, "Disponent Read tool-results → Exit 2 mit Hinweis", (c, err))
    c, err = vor(erste, "Bash", {"command": "cat %s | head -50" % TR})
    pruefe(c == 2 and "als SEITE an lauf.py" in err, "Disponent cat tool-results → Exit 2", (c, err))
for b in ("head -c 3000 %s" % TR, "sed -n 1,20p %s" % TR, "grep -n Disponent %s" % TR, "jq . < %s" % TR, "tail %s" % TR):
    pruefe(vor(D, "Bash", {"command": b})[0] == 2, "Disponent Bash liest tool-results → Exit 2: " + b[:30])
pruefe(vor(D, "Grep", {"pattern": "x", "path": TR})[0] == 2, "Disponent Grep tool-results → Exit 2")
pruefe(vor(D, "Bash", {"command": "python3 tools/lauf.py --sperre %s" % TR})[0] == 0, "Disponent lauf.py SEITE → durch")
pruefe(vor(D, "Bash", {"command": "cd /home/user/bornim-main && python3 tools/lauf.py %s && git push" % TR})[0] == 0, "Disponent cd && lauf.py SEITE → durch")
pruefe(vor(D, "Bash", {"command": "python3 tools/lauf.py %s; cat %s" % (TR, TR)})[0] == 2, "Disponent lauf.py und danach cat → Exit 2")
pruefe(vor(D, "Read", {"file_path": "/home/user/bornim-main/docs/ARBEIT-BETRIEB.md"})[0] == 0, "Disponent liest andere Datei → durch")
pruefe(vor(D, "Bash", {"command": "sed -n 3p /tmp/bornim-lauf-rest.txt"})[0] == 0, "Disponent liest Restdatei → durch")
W = "Dein Rufname: Emil (Rolle Werkzeug; Titel)\n\nAuftrag"
pruefe(vor(W, "Read", {"file_path": TR})[0] == 0, "andere Rolle Read tool-results → durch")
pruefe(vor(W, "Bash", {"command": "cat " + TR})[0] == 0, "andere Rolle cat tool-results → durch")

print("LAUF2042E %d Fälle, %d FEHL" % (faelle, fehler))
sys.exit(1 if fehler else 0)
