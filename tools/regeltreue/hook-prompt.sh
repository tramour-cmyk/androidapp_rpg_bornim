#!/usr/bin/env bash
# UserPromptSubmit-Hook: Berliner Zeit bei jedem Prompt, Kernregeln bei jedem 10. Prompt.
# Ablegen als tools/hook-prompt.sh, ausführbar machen: chmod +x tools/hook-prompt.sh

INTERVALL=10   # alle wie viele Prompts die Kernregeln wiederholt werden

eingabe=$(cat)
sid=$(printf '%s' "$eingabe" | sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p')
sid=${sid:-unbekannt}
datei="/tmp/bornim-hook-${sid}"

n=$(cat "$datei" 2>/dev/null || echo 0)
n=$((n + 1))
echo "$n" > "$datei"

echo "Systemzeit (Berlin): $(TZ=Europe/Berlin date '+%d.%m., %H:%M') – nur diese Zeit nutzen, nie schätzen."

if (( n % INTERVALL == 1 )); then
  echo "Kernregeln: Chat nur, was der Chef entscheiden, tun oder prüfen kann, sonst schweigen; keine Entschuldigung, kein Zwischenstand; Ergebnis zuerst (Telegram darf länger sein); prüfen statt zustimmen; nicht raten."
fi

exit 0
