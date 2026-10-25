#!/usr/bin/env bash
# Rollenspiegel (340.2): eigene Antwort ohne fremde. Die Datei docs/LISTE-ROLLENSPIEGEL.md nie selbst öffnen.
#   tools/rollenspiegel.sh <Rolle>                          Fragen und eigene Antwort der Vorwoche zeigen
#   tools/rollenspiegel.sh <Rolle> --antwort <datei|->      Antwort (Zeilen „0. …“ bis „10. …“) anhängen
#                          [--sitzung "<Titel>"]            Sitzungstitel für die Kopfzeile
# Rollen: Sokrates, Perikles, Homer, Ford, Diogenes, Tom, Jerry (auch „Team Tom“). Hängt unter „## Woche <Freitag>“ an;
# eine neue Woche verdrängt alles vor der Vorwoche (älteres steht in Git). Danach selbst committen und pushen.
haupt=/home/user/bornim-main
[ -d "$haupt/docs" ] || haupt="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$haupt" pull -q --no-rebase origin main >/dev/null 2>&1
# Python über -c, damit stdin frei bleibt für „--antwort -“
code=$(cat <<'PY'
import sys, re, datetime, zoneinfo
datei, args = sys.argv[1], sys.argv[2:]
try: sys.stdout.reconfigure(errors="replace")
except Exception: pass
import signal; signal.signal(signal.SIGPIPE, signal.SIG_DFL)
NAMEN = {"sokrates": "Sokrates", "perikles": "Perikles", "homer": "Homer", "ford": "Ford", "diogenes": "Diogenes",
         "tom": "Team Tom", "team tom": "Team Tom", "jerry": "Team Jerry", "team jerry": "Team Jerry"}
if not args or args[0].lower() not in NAMEN:
    sys.exit("Aufruf: tools/rollenspiegel.sh <Rolle> [--antwort <datei|->] [--sitzung \"<Titel>\"]; Rollen: Sokrates, Perikles, Homer, Ford, Diogenes, Tom, Jerry")
rolle, antwort, sitzung = NAMEN[args[0].lower()], None, ""
i = 1
while i < len(args):
    if args[i] == "--antwort" and i + 1 < len(args): antwort = args[i + 1]; i += 2
    elif args[i] == "--sitzung" and i + 1 < len(args): sitzung = args[i + 1]; i += 2
    else: sys.exit("Unbekannt: " + args[i])
text = open(datei, encoding="utf-8").read()
# Abschnitte: Kopf (bis „## Woche“), dann je Woche ein Block
teile = re.split(r"(?m)^(?=## Woche )", text)
kopf, wochen = teile[0], teile[1:]
def eigene(block):
    m = re.search(r"(?ms)^### " + re.escape(rolle) + r"\b.*?(?=^### |\Z)", block)
    return m.group(0).rstrip() if m else None
jetzt = datetime.datetime.now(zoneinfo.ZoneInfo("Europe/Berlin"))
freitag = (jetzt + datetime.timedelta(days=4 - jetzt.weekday())).strftime("%d.%m.")
kopfzeile = "## Woche " + freitag

if antwort is None:
    fragen = re.search(r"(?ms)^## Fragen\n.*?(?=^## )", kopf)
    print(re.sub(r"(?s)^# Rollenspiegel\n\n", "", kopf.split("## Fragen")[0]).strip().split("\n")[0])
    print()
    print(fragen.group(0).strip() if fragen else "(Fragen nicht gefunden)")
    print()
    alt = [(w.split("\n")[0], eigene(w)) for w in wochen if not w.startswith(kopfzeile)]
    alt = [a for a in alt if a[1]]
    if alt: print("Deine letzte Antwort (" + alt[-1][0][3:] + "):\n" + alt[-1][1])
    else: print("Keine eigene Antwort aus einer Vorwoche in der Datei (älteres in Git).")
    if any(w.startswith(kopfzeile) and eigene(w) for w in wochen):
        print("\nHinweis: Für die " + kopfzeile[3:] + " steht schon eine Antwort von " + rolle + ".")
    print("\nAntwort anhängen: tools/rollenspiegel.sh " + args[0] + " --antwort <datei> --sitzung \"<Titel>\"; danach committen und pushen.")
    sys.exit(0)

neu = (sys.stdin.read() if antwort == "-" else open(antwort, encoding="utf-8").read()).strip()
if not re.search(r"(?m)^0\. ", neu) or not re.search(r"(?m)^10\. ", neu):
    sys.exit("Antwort braucht die Zeilen „0. …“ bis „10. …“ (Fragen ohne Antwort: „nichts“ mit Begründung).")
neu = re.sub(r"(?m)^#+ .*\n?", "", neu).strip()
abschnitt = "### %s (%s%s)\n\n%s\n" % (rolle, jetzt.strftime("%d.%m., %H:%M"), ", Sitzung „%s“" % sitzung if sitzung else "", neu)
for n, w in enumerate(wochen):
    if w.startswith(kopfzeile):
        if eigene(w): sys.exit("Für die %s steht schon eine Antwort von %s; nichts geändert." % (kopfzeile[3:], rolle))
        wochen[n] = w.rstrip() + "\n\n" + abschnitt + ("\n" if n < len(wochen) - 1 else "")
        break
else:
    wochen = wochen[-1:] + [kopfzeile + "\n\n" + abschnitt]
    if wochen[0] != wochen[-1]: wochen[0] = wochen[0].rstrip() + "\n\n"
open(datei, "w", encoding="utf-8").write(kopf + "".join(wochen))
print("Angehängt unter %s: %s. Jetzt committen und pushen (Commit „340: Rollenspiegel %s“)." % (kopfzeile[3:], rolle, rolle))
PY
)
exec python3 -c "$code" "$haupt/docs/LISTE-ROLLENSPIEGEL.md" "$@"
