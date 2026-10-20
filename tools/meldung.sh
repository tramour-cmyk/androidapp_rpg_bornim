#!/usr/bin/env bash
# Meldung an den Nutzer über Telegram (81r): Telegram ist das Protokoll, jeder meldet selbst.
#   tools/meldung.sh <Name> "<Nummer> <Stand>"          lautlos (Arbeitsstand, auch nachts)
#   tools/meldung.sh --laut <Name> "<Nummer> <Stand>"   mit Ton und ⚠ (der Nutzer ist dran; nicht 22–7 Uhr)
#   tools/meldung.sh --bild <datei> <Name> "<Text>"     Standbild mit der Zeile als Unterschrift (Telegram verkleinert)
#   tools/meldung.sh --datei <datei> <Name> "<Text>"    Bild in voller Auflösung als Datei (Pixelprüfung)
# Kostet in der Sitzung nichts: das Bild wird nur hochgeladen, nicht gelesen. Optionen kombinierbar, an jeder Stelle.
# Kopf: Name verlinkt automatisch auf die eigene Sitzung. Pflicht für alle (Nutzer 15.10.): jede Nummer mit Datei auf „Chefsache“ als Sprungmarke.
# Sprungmarke: „[72o.1](cs:72o1): …“ macht die Nummer zum Link auf docs/chefsache/*/72o1-….md auf GitHub (108, 117; alte Formen dz:72o1 und dz:e/72o1.html gehen weiter), [Wort](URL) im Text ebenso.
# Form: Kopf „Name TT.MM. HH:MM“, darunter je Thema eine Zeile „81s: …“ (Ford: je Agent „Tom: …“), getrennt mit \n; nur Nummern und Stichworte, nie Spieltexte.
# Schlüssel nur aus der Umgebungsvariable TELEGRAM_BOT_TOKEN, nie ins Repo oder in den Chat.
# Veraltete Kopie im Arbeitszweig (Nutzer 15.10.: Meldungen ohne Links): an die Notizkopie auf main weitergeben
haupt=/home/user/bornim-main/tools/meldung.sh
if [ -z "$MELDUNG_WEITER" ] && [ -f "$haupt" ] && [ "$(realpath "$0")" != "$(realpath "$haupt")" ]; then
  git -C /home/user/bornim-main pull -q --no-rebase origin main >/dev/null 2>&1
  MELDUNG_WEITER=1 exec "$haupt" "$@"
fi
laut=0; probe=0
bild=""; art=""
# Optionen an jeder Stelle (244: „--bild“ hinter dem Text wurde still übergangen, nur der Text ging raus)
rest=()
while [ $# -gt 0 ]; do
  case "$1" in
    --probe) probe=1 ;;  # nur zeigen, was gesendet würde (HTML), nichts senden
    --laut) laut=1 ;;
    --bild) art=photo; bild="$2"; shift ;;
    --datei) art=document; bild="$2"; shift ;;
    --*) echo "meldung: unbekannte Option $1, nichts gesendet" >&2; exit 2 ;;
    *) rest+=("$1") ;;
  esac
  shift
done
if [ -n "$art" ] && [ ! -f "$bild" ]; then echo "meldung: Bild $bild fehlt" >&2; exit 2; fi
if [ ${#rest[@]} -gt 2 ]; then echo "meldung: zu viele Angaben (Text in Anführungszeichen?), nichts gesendet" >&2; exit 2; fi
name="${rest[0]}"; text="${rest[1]}"
if [ -z "$name" ] || [ -z "$text" ]; then echo "Aufruf: tools/meldung.sh [--laut] <Name> \"<Text>\"" >&2; exit 2; fi
if [ $probe = 0 ] && [ -z "$TELEGRAM_BOT_TOKEN" ]; then echo "meldung: TELEGRAM_BOT_TOKEN fehlt in dieser Umgebung, Meldung nicht gesendet" >&2; exit 1; fi
zeit=$(TZ=Europe/Berlin date "+%d.%m. %H:%M"); stunde=$(TZ=Europe/Berlin date +%H)
if [ $laut = 1 ]; then
  text="⚠ $text"
  case $stunde in 22|23|0[0-6]) laut=0 ;; esac  # nachts nur lautlos
fi
still=true; [ $laut = 1 ] && still=false
# Aussehen (Nutzer 15.10.): Kopf fett in eigener Zeile; Zeilen, die mit „Name:“ oder „Nummer:“ beginnen, bis zum Doppelpunkt fett; **x** fett.
# Kopf verlinkt auf die Sitzung des Absenders (Nutzer 15.10., 16:0x), wenn die Umgebung sie kennt
sitzung=""; case "$CLAUDE_CODE_REMOTE_SESSION_ID" in cse_*) sitzung="https://claude.ai/code/session_${CLAUDE_CODE_REMOTE_SESSION_ID#cse_}" ;; esac
zug="$(dirname "$(realpath "$0")")/../docs/chefsache"
besetzung="$(dirname "$(realpath "$0")")/../docs/ARBEIT-BESETZUNG.md"
zeile=$(NAME="$name" ZEIT="$zeit" SITZUNG="$sitzung" TEXT="$text" ZUG="$zug" BESETZUNG="$besetzung" python3 -c '
import os, re, html
t = html.escape(os.environ["TEXT"].replace("\\n", "\n"), quote=False)
t = re.sub(r"\*\*(.+?)\*\*", r"<b>\1</b>", t)
import glob
gh = "https://github.com/tramour-cmyk/androidapp_rpg_bornim/"
def dz(u):  # Chefsache im Repo (108, 117): cs:72o1 -> docs/chefsache/<ordner>/72o1-….md, sonst der Ordner
    k = u[3:].removeprefix("e/").removesuffix(".html").removesuffix(".md").replace(".", "").lower()
    for f in sorted(glob.glob(os.path.join(os.environ["ZUG"], "*", "*.md"))):
        if os.path.basename(f).split("-")[0].removesuffix(".md").replace(".", "").lower() == k:
            return gh + "blob/main/docs/chefsache/" + os.path.basename(os.path.dirname(f)) + "/" + os.path.basename(f)
    return gh + "tree/main/docs/chefsache"
url = lambda u: dz(u) if u.startswith(("cs:", "dz:")) else u  # cs: Chefsache (117), dz: alte Form
# Sprungmarke (Nutzer 15.10.): Zeile „[72o.1](cs:72o1): …“ macht die fette Nummer selbst zum Link
t = re.sub(r"(?m)^(\s*(?:⚠\s*)?)\[([^\]]{1,30})\]\(([^)\s]+)\):", lambda m: m.group(1) + "<a href=\"" + url(m.group(3)) + "\"><b>" + m.group(2) + ":</b></a>", t)
t = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", lambda m: "<a href=\"" + url(m.group(2)) + "\">" + m.group(1) + "</a>", t)
# Nackte Adresse (105, Chef 16.10.: „Hyperlink nicht unterlegt, sondern extra“): „Titel“: URL -> Titel als Link, sonst das Wort „Link“
t = re.sub(r"„([^“<]+)“:?\s*(https?://[^\s<]+)", lambda m: "<a href=\"" + m.group(2) + "\">„" + m.group(1) + "“</a>", t)
t = re.sub(r"(?<![\"=>])(https?://[^\s<]+?)([.,;)]?(?:\s|$))", lambda m: "<a href=\"" + m.group(1) + "\">Link</a>" + m.group(2), t)
t = re.sub(r"(?m)^(\s*(?:⚠\s*)?)([\wÄÖÜäöüß][\wÄÖÜäöüß .,/–-]{0,30}):", r"\1<b>\2:</b>", t)
# Selbsttätig (105, Nutzer 16.10.: Links fehlen, Fettdruck uneinheitlich): auch ohne [..](cs:..) wird jede Nummer mit Datei
# auf Chefsache (72s.1, 99g, D10, 0.1.757 -> t757) fetter Link, „PR #71“ Link auf den PR, „Tom:“ am Zeilenanfang Link auf die laufende Sitzung (Besetzung).
keys = {}
for f in glob.glob(os.path.join(os.environ["ZUG"], "*", "*.md")):
    k = os.path.basename(f).split("-")[0].removesuffix(".md").lower()
    if re.search(r"\d", k): keys[k] = gh + "blob/main/docs/chefsache/" + os.path.basename(os.path.dirname(f)) + "/" + os.path.basename(f)
# Nur Nummern mit Datei auf Chefsache werden Link (Chef 16.10., 12:0x: Verlinkung auf eine Vorratsdatei „macht keinen Sinn“):
# fett mit Link heißt „du bist dran“, schlichte Nummer heißt „nur Stand“.
sitz = {}
try:
    for z in open(os.environ["BESETZUNG"], encoding="utf-8"):
        m = re.match(r"\|\s*([^|]+?)\s*\|\s*\[[^\]]*\]\((https://claude\.ai/code/session_\w+)\)", z)
        if m:
            sitz[m.group(1)] = m.group(2)
            if m.group(1).startswith("Team "): sitz[m.group(1)[5:]] = m.group(2)
except OSError: pass
def nummer(m):
    tok = m.group(0); k = tok.replace(".", "").lower()
    v = re.fullmatch(r"0\.1\.(\d+)", tok)
    if v: k = "t" + v.group(1)
    if k not in keys or len(tok) < 2 and "/chefsache/" not in keys[k]: return tok  # einstellige Zahlen („Stufe 3“) nur mit Datei auf Chefsache
    return "<a href=\"" + keys[k] + "\"><b>" + tok + "</b></a>"
def frei(seg):
    seg = re.sub(r"\bPR #(\d+)", lambda m: "<a href=\"" + gh + "pull/" + m.group(1) + "\">" + m.group(0) + "</a>", seg)
    teile = re.split(r"(<a [^>]*>.*?</a>|<[^>]+>)", seg)
    return "".join(x if x.startswith("<") else re.sub(r"(?<![\w.#/:])(?:0\.1\.\d+|[A-Za-z]?\d+[a-z]?(?:\.\d+)?[a-z]?)(?![\w.:]\w|\w)", nummer, x) for x in teile)
t = "".join(x if x.startswith("<a ") else frei(x) for x in re.split(r"(<a [^>]*>.*?</a>)", t, flags=re.S))
t = re.sub(r"(?m)^(\s*(?:⚠\s*)?)<b>([^<:]+):</b>", lambda m: m.group(1) + ("<a href=\"" + sitz[m.group(2)] + "\"><b>" + m.group(2) + ":</b></a>" if m.group(2) in sitz else "<b>" + m.group(2) + ":</b>"), t)
n = "<b>" + html.escape(os.environ["NAME"]) + "</b>"
if os.environ["SITZUNG"]: n = "<a href=\"" + os.environ["SITZUNG"] + "\">" + n + "</a>"
print(n + " <b>" + os.environ["ZEIT"] + "</b>\n" + t)')
[ $probe = 1 ] && { [ -n "$art" ] && echo "($art: $bild)"; echo "$zeile"; exit 0; }
if [ -n "$art" ]; then
  methode=sendPhoto; [ $art = document ] && methode=sendDocument
  antwort=$(curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/$methode" \
    -F "chat_id=8965432899" -F "disable_notification=$still" -F "$art=@$bild" --form-string "caption=$zeile" -F "parse_mode=HTML" 2>&1)
else
  antwort=$(curl -sS "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=8965432899" --data-urlencode "disable_notification=$still" \
    --data-urlencode "text=$zeile" --data-urlencode "parse_mode=HTML" \
    --data-urlencode "link_preview_options={\"is_disabled\":true}" 2>&1)  # keine Vorschaukarten (Nutzer 15.10.)
fi
case "$antwort" in *'"ok":true'*) echo "meldung: gesendet" ;; *) echo "meldung: Fehler: ${antwort:0:200}" >&2; exit 1 ;; esac
