#!/usr/bin/env python3
"""Stand zum Marktstart als HTML-Seite (339). Quelle bleibt LISTE-ABNAHME-KAPITEL1.md (ein Ort);
dazu offene Chefsache (chefsache/README.md), Muss je Rolle (startbar.py --stand), Guthaben (ARBEIT-BETRIEB.md).
Aufruf: python3 tools/dashboard.py <ziel.html>   Ford veröffentlicht die Datei im Stundenlauf als Artifact (feste Adresse)."""
import html, os, re, subprocess, sys, time

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DOCS = os.path.join(ROOT, "docs")
GH = "https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/"


def lesen(p):
    with open(os.path.join(DOCS, p), encoding="utf-8") as f:
        return f.read()


def inline(t, basis=""):
    t = html.escape(t, quote=False)
    t = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", lambda m: '<a href="%s">%s</a>' % (
        m.group(2) if m.group(2).startswith("http") else GH + basis + m.group(2), m.group(1)), t)
    t = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", t)
    t = re.sub(r"`([^`]+)`", r"<code>\1</code>", t)
    t = re.sub(r"(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])", r"<em>\1</em>", t)
    return t


AMPEL = {"rot": "bad", "gelb": "warn", "grün": "ok", "gruen": "ok"}


def zelle(t, basis, ampel):
    m = re.match(r"\**(\w+)\**(.*)", t.strip())
    if ampel and m and m.group(1).lower() in AMPEL:
        return '<span class="pill %s">%s</span>%s' % (AMPEL[m.group(1).lower()], html.escape(m.group(1)), inline(m.group(2), basis))
    return inline(t, basis)


def md(text, basis=""):
    """Kleiner Umsetzer: Absätze, Listen, Tabellen; mehr steht in der Quelle nicht."""
    out, tab, liste = [], [], False
    def tab_zu():
        if not tab: return
        kopf, *rest = tab
        out.append('<div class="tw"><table><thead><tr>%s</tr></thead><tbody>%s</tbody></table></div>' % (
            "".join("<th>%s</th>" % inline(c, basis) for c in kopf),
            "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % zelle(c, basis, i < len(kopf) and kopf[i] == "Ampel") for i, c in enumerate(r)) for r in rest)))
        tab.clear()
    for z in text.splitlines():
        s = z.strip()
        if s.startswith("|"):
            if liste: out.append("</ul>"); liste = False
            zellen = [c.strip() for c in s.strip("|").split("|")]
            if not all(re.fullmatch(r":?-+:?", c) for c in zellen):
                tab.append(zellen)
            continue
        tab_zu()
        if s.startswith("- "):
            if not liste: out.append("<ul>"); liste = True
            out.append("<li>%s</li>" % inline(s[2:], basis)); continue
        if liste: out.append("</ul>"); liste = False
        m = re.fullmatch(r"\*\*(\d+)\. ([^*]+)\*\*", s)
        if m: out.append("<h2>%s</h2>" % html.escape(m.group(2))); continue
        if s: out.append("<p>%s</p>" % inline(s, basis))
    tab_zu()
    if liste: out.append("</ul>")
    return "\n".join(out)


def abschnitt(text, kopf):
    m = re.search(r"^## %s(?:[ \t][^\n]*)?$(.*?)(?=^## |\Z)" % re.escape(kopf), text, re.M | re.S)
    return m.group(1).strip() if m else None


def fehlt(was):
    return '<p class="fehlt">Nicht lesbar: %s. Ford meldet es Perikles.</p>' % html.escape(was)


def main(ziel):
    ab = lesen("LISTE-ABNAHME-KAPITEL1.md")
    stand = abschnitt(ab, "Stand zum Marktstart") or ""
    st = re.search(r"\*\*Stand ([^:]+:[^:]+): (\w+)\.\*\*\s*(.*)", stand)
    stand_rest = stand.split("\n", 1)[1] if st else stand
    farbe = AMPEL.get(st.group(2).lower(), "") if st else ""

    cs = lesen("chefsache/README.md")
    chef = ""
    for teil in ("Zu entscheiden", "Zu billigen", "Anzusehen"):
        a = abschnitt(cs, teil)
        if a is None:
            chef += "<h3>%s</h3>" % teil + fehlt("„%s“ in chefsache/README.md" % teil); continue
        zeilen = [z for z in a.splitlines() if z.startswith("|")]
        n = max(0, len(zeilen) - 2)
        chef += '<h3>%s <span class="zahl">%d</span></h3>' % (teil, n)
        chef += md("\n".join(zeilen), "chefsache/") if n else "<p class=\"leise\">Nichts offen.</p>"

    sb = subprocess.run([sys.executable, os.path.join(ROOT, "tools", "startbar.py"), "--stand"],
                        capture_output=True, text=True)
    titel = {}
    for z in lesen("LISTE-VORGAENGE.md").splitlines():
        sp = [c.strip() for c in z.split("|")]
        if len(sp) > 3: titel[sp[1]] = sp[2]
    muss = []
    for z in sb.stdout.splitlines():
        m = re.match(r"  (\w+): Muss (\S+)", z)
        if m and m.group(2) != "–":
            muss.append("<li><strong>%s</strong>: %s %s</li>" % (html.escape(m.group(1)), html.escape(m.group(2)),
                        inline(titel.get(m.group(2), ""))))
    muss = fehlt("startbar.py") if sb.returncode or not sb.stdout.strip() else \
        "<ul>%s</ul>" % "".join(muss) if muss else '<p class="leise">Kein startbares Muss.</p>'

    os.environ["TZ"] = "Europe/Berlin"; time.tzset()
    jetzt = time.strftime("%d.%m., %H:%M")
    seite = VORLAGE.format(
        farbe=farbe, ampel=html.escape(st.group(2) if st else "–"),
        standzeit=html.escape(st.group(1) if st else "–"), kern=inline(st.group(3) if st else ""),
        stand=md(stand_rest) if stand else fehlt("„Stand zum Marktstart“ in LISTE-ABNAHME-KAPITEL1.md"), chef=chef,
        muss=muss, jetzt=jetzt)
    with open(ziel, "w", encoding="utf-8") as f:
        f.write(seite)


VORLAGE = """<title>Stand zum Marktstart</title>
<meta name="claude:viewport-fit-sides" content="cover">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Alegreya:ital,wght@0,400;0,700;1,400&family=Alegreya+SC:wght@500&display=swap">
<style>
/* Eine Spalte wie ein Textkasten im Spiel: schwarz, dünner Goldrand, gebrochenes Weiß (DESIGN-STIL.md, Veil) */
:root {{ --bg: #0b0a08; --panel: #17140f; --fg: #e6ddcb; --dim: #948a78; --gold: #b59a6a; --bright: #d9bc82;
  --rim: rgba(181,154,106,.67); --ok: #86c46e; --warn: #e0b84a; --bad: #d9785a;
  --text: "Alegreya", Georgia, serif; --caps: "Alegreya SC", "Alegreya", Georgia, serif; color-scheme: dark; }}
body {{ background: var(--bg); color: var(--fg); font: 17px/1.5 var(--text); }}
main {{ max-width: 60rem; margin: 0 auto; padding-block: 24px 48px;
  padding-left: max(16px, env(safe-area-inset-left, 0px)); padding-right: max(16px, env(safe-area-inset-right, 0px));
  display: grid; gap: 28px; }}
h1, h2, h3 {{ font-family: var(--caps); font-weight: 500; letter-spacing: .06em; color: var(--bright); text-wrap: balance; margin: 0; }}
h1 {{ font-size: 1.9rem; }} h2 {{ font-size: 1.25rem; border-bottom: 1px solid var(--rim); padding-bottom: 6px; }}
h3 {{ font-size: 1.02rem; color: var(--gold); margin-top: 14px; }}
p, ul {{ margin: 8px 0; }} ul {{ padding-left: 1.2em; }} li + li {{ margin-top: 4px; }}
a {{ color: var(--bright); }} a:focus-visible {{ outline: 2px solid var(--bright); outline-offset: 2px; }}
code {{ font-size: .9em; color: var(--dim); }} strong {{ color: var(--bright); font-weight: 700; }}
section {{ min-width: 0; }}
.kopf {{ display: grid; gap: 10px; border: 1px solid var(--rim); background: var(--panel); padding: 18px; }}
.kopf .zeile {{ display: flex; flex-wrap: wrap; gap: 10px; align-items: baseline; }}
.leise {{ color: var(--dim); }} .fehlt {{ color: var(--bad); }}
.pill {{ display: inline-block; font-family: var(--caps); font-size: .85em; letter-spacing: .08em; padding: 1px 9px;
  border: 1px solid currentColor; border-radius: 2px; margin-right: 6px; }}
.pill.ok {{ color: var(--ok); }} .pill.warn {{ color: var(--warn); }} .pill.bad {{ color: var(--bad); }}
.gross {{ font-size: 1.15rem; padding: 3px 14px; }}
.zahl {{ color: var(--fg); font-family: var(--text); font-variant-numeric: tabular-nums; }}
.tw {{ overflow-x: auto; margin: 8px 0; }}
table {{ border-collapse: collapse; width: 100%; font-size: .95rem; }}
th {{ text-align: left; font-family: var(--caps); font-weight: 500; color: var(--gold); letter-spacing: .04em; }}
th, td {{ padding: 7px 10px 7px 0; border-bottom: 1px solid rgba(181,154,106,.25); vertical-align: top; }}
td {{ font-variant-numeric: tabular-nums; }}
footer {{ color: var(--dim); font-size: .9rem; }}
</style>
<main>
  <header class="kopf">
    <h1>Stand zum Marktstart</h1>
    <div class="zeile"><span class="pill gross {farbe}">{ampel}</span><span class="leise">Stand {standzeit}</span></div>
    <p>{kern}</p>
  </header>
  <section>{stand}</section>
  <section><h2>Wartet auf dich</h2>{chef}</section>
  <section><h2>Woran gearbeitet wird</h2><p class="leise">Oberstes startbares Muss je Rolle.</p>{muss}</section>
  <footer>Aus LISTE-ABNAHME-KAPITEL1.md, Chefsache und Vorräten gebaut am {jetzt} (Berliner Zeit).</footer>
</main>
"""

if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "/tmp/dashboard.html")
