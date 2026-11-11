#!/usr/bin/env python3
"""658 (Chef 08.11., 15:00): Reaktionen des Chefs auf Telegram-Meldungen auslesen.

  tools/reaktionen.py            holt neue Reaktionen und Nachrichten (getUpdates), legt sie im Zweig „reaktionen“ ab
                                 (reaktionen.tsv), bestätigt dann bei Telegram und zeigt die der letzten 120 Minuten
  tools/reaktionen.py --minuten N   Zeitraum der Anzeige
  tools/reaktionen.py --still    nur holen und ablegen, nichts zeigen

Zuordnung: meldung.sh schreibt die Telegram-Kennung jeder Meldung als fünfte Spalte in meldungen.tsv (Zweig „meldungen“).
Eine Reaktion auf eine Meldung mit genau einem Vorgang ist eindeutig; mit mehreren steht „mehrdeutig“ dabei.
Bedeutung (Chef 15:00): 👍 = gebilligt, passt; ✅ = erledigt. Den Archiveintrag mit Wortlaut „👍 (Telegram, HH:MM)“
und „Nachricht <Kennung>“ schreibt der Absender der Meldung; bis dahin zeigt notiz.sh die Reaktion als offen,
ohne Zeitgrenze (Sokrates 17:03: eine Anzeige allein trug 21 Minuten nichts ein). Das Werkzeug schreibt nichts nach docs/.
Ohne TELEGRAM_BOT_TOKEN oder ohne Netz: still nichts (notiz.sh ruft es bei jedem Aufruf).
"""
import datetime, json, os, subprocess, sys, tempfile, time, urllib.parse, urllib.request

CHAT = 8965432899
ZWEIG = "reaktionen"
REPO = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
try:
    from zoneinfo import ZoneInfo
    BERLIN = ZoneInfo("Europe/Berlin")
except Exception:
    BERLIN = datetime.timezone(datetime.timedelta(hours=1))


def git(*a, eingabe=None, env=None):
    return subprocess.run(["git", "-C", REPO] + list(a), input=eingabe, capture_output=True, text=True, timeout=60,
                          env=dict(os.environ, **(env or {})))


def zweig_lesen(zweig, datei, streng=False):
    """Eigene Referenz statt FETCH_HEAD: ein gleichzeitiger fetch (zweiter notiz.sh, Haken) überschreibt FETCH_HEAD,
    dann las meldungen_je_kennung nichts und die Reaktion blieb ohne Zuordnung (658, 👍 16:42 auf 2980)."""
    ref = "refs/bornim/" + zweig
    if git("fetch", "-q", "origin", "+refs/heads/%s:%s" % (zweig, ref)).returncode:
        if streng: raise RuntimeError("Zweig %s nicht geholt" % zweig)
        return None, ""
    kopf = git("rev-parse", ref).stdout.strip()
    r = git("show", "%s:%s" % (ref, datei))
    if streng and r.returncode: raise RuntimeError("%s fehlt in %s" % (datei, zweig))
    return kopf, r.stdout


def telegram(methode, **p):
    url = "https://api.telegram.org/bot%s/%s?%s" % (os.environ["TELEGRAM_BOT_TOKEN"], methode, urllib.parse.urlencode(p))
    with urllib.request.urlopen(url, timeout=20) as r:
        d = json.load(r)
    if not d.get("ok"): raise RuntimeError(str(d)[:200])
    return d["result"]


def meldungen_je_kennung(streng=False):
    _, roh = zweig_lesen("meldungen", "meldungen.tsv", streng)
    m = {}
    for l in roh.splitlines():
        t = l.split("\t")
        if len(t) >= 5 and t[4].strip(): m[t[4].strip()] = (t[0], t[1], t[2])
    return m


def zeit(sek):
    return datetime.datetime.fromtimestamp(sek, BERLIN).strftime("%Y-%m-%d %H:%M")


def zeilen_aus(updates, kennung):
    aus = []
    for u in updates:
        r = u.get("message_reaction"); n = u.get("message")
        if r and r.get("chat", {}).get("id") == CHAT:
            emo = "".join(x.get("emoji", "?") for x in r.get("new_reaction", [])) or "(zurückgenommen)"
            mid = str(r.get("message_id"))
            wann, nrn, name = kennung.get(mid, ("", "", ""))
            aus.append([str(u["update_id"]), zeit(r.get("date", 0)), "reaktion", emo, mid, nrn, name, wann])
        elif n and n.get("chat", {}).get("id") == CHAT:
            text = (n.get("text") or n.get("caption") or "(ohne Text)").replace("\t", " ").replace("\n", " ")[:300]
            bezug = n.get("reply_to_message", {}).get("message_id")
            wann, nrn, name = kennung.get(str(bezug), ("", "", "")) if bezug else ("", "", "")
            aus.append([str(u["update_id"]), zeit(n.get("date", 0)), "nachricht", text, str(bezug or ""), nrn, name, wann])
    return aus


def ablegen(neu):
    """Hängt neue Zeilen (nach update_id eindeutig) an reaktionen.tsv im Zweig an; True, wenn abgelegt."""
    for versuch in range(3):
        kopf, alt = zweig_lesen(ZWEIG, "reaktionen.tsv")
        da = {l.split("\t")[0] for l in alt.splitlines() if l}
        dazu = [z for z in neu if z[0] not in da]
        if not dazu: return True
        text = "".join(l + "\n" for l in alt.splitlines()[-3000:]) + "".join("\t".join(z) + "\n" for z in dazu)
        blob = git("hash-object", "-w", "--stdin", eingabe=text).stdout.strip()
        idx = tempfile.mktemp()
        try:
            env = {"GIT_INDEX_FILE": idx}
            git("update-index", "--add", "--cacheinfo", "100644,%s,reaktionen.tsv" % blob, env=env)
            baum = git("write-tree", env=env).stdout.strip()
        finally:
            if os.path.exists(idx): os.remove(idx)
        neu_c = git("commit-tree", baum, *(["-p", kopf] if kopf else []), "-m", "Reaktionen %d" % len(dazu)).stdout.strip()
        if git("push", "-q", "origin", "%s:refs/heads/%s" % (neu_c, ZWEIG)).returncode == 0: return True
        time.sleep(versuch + 1)
    return False


def archiv_text():
    try:
        with open(os.path.join(REPO, "docs", "VORGANGSARCHIV.md"), encoding="utf-8") as f: return f.read()
    except OSError: return ""


def zeigen(minuten):
    """Zuordnung beim Zeigen aus meldungen.tsv (auch für früher ohne Zuordnung abgelegte Zeilen).
    Offen bleibt ein 👍/✅ auf eine zugeordnete Meldung, bis ein Archiveintrag „Nachricht <Kennung>“ nennt, ohne Zeitgrenze."""
    import re
    _, alt = zweig_lesen(ZWEIG, "reaktionen.tsv")
    kennung = meldungen_je_kennung()
    archiv = archiv_text()
    grenze = (datetime.datetime.now(BERLIN) - datetime.timedelta(minutes=minuten)).strftime("%Y-%m-%d %H:%M")
    zeilen = [l.split("\t") for l in alt.splitlines() if l]
    zeilen = [z for z in zeilen if len(z) >= 8]
    letzte = {}
    for z in zeilen:
        if z[2] == "reaktion": letzte[z[4]] = z
    offen = []
    for mid, z in letzte.items():
        if mid not in kennung or z[3] == "(zurückgenommen)": continue
        if re.search(r"(Nachricht|Telegram)\s+%s\b" % re.escape(mid), archiv): continue
        offen.append(z)
    neu = [z for z in zeilen if z[1] >= grenze and z not in offen]
    if not offen and not neu: return

    def bezug(mid):
        if mid in kennung:
            mwann, nrn, name = kennung[mid]
            return "Meldung %s %s zu %s%s" % (name, mwann[11:], nrn, " (mehrdeutig)" if "," in nrn else "")
        return "Nachricht %s, ohne Zuordnung" % mid if mid else ""
    if offen:
        print("Telegram, offen (658; der Absender der Meldung trägt ins Vorgangsarchiv ein, mit „Nachricht <Kennung>“, dann ist es weg):")
        for z in sorted(offen, key=lambda z: z[1]):
            mwann, nrn, name = kennung[z[4]]
            sinn = "erledigt" if "✅" in z[3] else "gebilligt" if "👍" in z[3] else "Reaktion"
            tag = "%s.%s., %s" % (z[1][8:10], z[1][5:7], z[1][11:])
            print("  → %s: %s %s %s = %s, Nachricht %s" % (name, tag, z[3], bezug(z[4]), sinn, z[4]))
    if neu:
        print("Telegram vom Chef (letzte %d Minuten; 👍 gebilligt, ✅ erledigt):" % minuten)
        for z in neu:
            if z[2] == "reaktion": print("  %s %s auf %s" % (z[1][11:], z[3], bezug(z[4])))
            else:
                b = bezug(z[4]) if z[4] else ""
                print("  %s „%s“%s" % (z[1][11:], z[3], (" (Antwort auf " + b + ")") if b else ""))


def main(a):
    minuten = 120
    if "--minuten" in a: minuten = int(a[a.index("--minuten") + 1])
    if os.environ.get("TELEGRAM_BOT_TOKEN"):
        try:
            ups = telegram("getUpdates", timeout=0, allowed_updates=json.dumps(["message", "message_reaction"]))
            if ups:
                if ablegen(zeilen_aus(ups, meldungen_je_kennung(streng=True))):
                    telegram("getUpdates", timeout=0, offset=max(u["update_id"] for u in ups) + 1, limit=1)
        except Exception as e:
            if "--still" not in a: print("reaktionen: nicht geholt (%s)" % str(e)[:120], file=sys.stderr)
    if "--still" not in a:
        try: zeigen(minuten)
        except Exception: pass


if __name__ == "__main__":
    main(sys.argv[1:])
