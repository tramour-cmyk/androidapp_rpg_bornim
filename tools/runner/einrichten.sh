#!/usr/bin/env bash
# Richtet auf einer frischen Ubuntu-Server-24.04-VM den Build-Rechner für Bornim ein (264, LISTE-PROXMOX-RUNNER.md):
# Java 17, Android-SDK, GitHub-Runner als Dienst unter dem Benutzer "runner" (ohne sudo), Firewall ohne Zugriff aufs Heimnetz.
# Aufruf: sudo bash einrichten.sh   (fragt nach dem Runner-Schlüssel von GitHub)
set -euo pipefail

REPO_URL="https://github.com/tramour-cmyk/androidapp_rpg_bornim"
SDK=/opt/android-sdk
CLT_ZIP="commandlinetools-linux-11076708_latest.zip"

if [ "$(id -u)" != 0 ]; then echo "Bitte so starten:  sudo bash einrichten.sh"; exit 1; fi

echo
echo "=== Schlüssel von GitHub ==="
echo "Tippe den Schlüssel ab, der auf GitHub hinter  --token  steht (Groß- und Kleinbuchstaben beachten), dann Enter:"
read -r TOKEN
if [ ${#TOKEN} -lt 20 ]; then echo "Der Schlüssel ist zu kurz. Bitte das Skript noch einmal starten."; exit 1; fi

echo "=== 1/6 Programme installieren (dauert einige Minuten) ==="
export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q curl unzip git jq ufw openjdk-17-jdk-headless
# GitHub-CLI (gh): android.yml und release-notes.yml rufen sie auf
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list
apt-get update -q
apt-get install -y -q gh

echo "=== 2/6 Benutzer runner anlegen ==="
id runner >/dev/null 2>&1 || useradd -m -s /bin/bash runner

echo "=== 3/6 Android-SDK laden ==="
mkdir -p "$SDK/cmdline-tools"
curl -fsSL -o /tmp/clt.zip "https://dl.google.com/android/repository/$CLT_ZIP"
rm -rf "$SDK/cmdline-tools/latest" "$SDK/cmdline-tools/cmdline-tools"
unzip -q -o /tmp/clt.zip -d "$SDK/cmdline-tools"
mv "$SDK/cmdline-tools/cmdline-tools" "$SDK/cmdline-tools/latest"
yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" --licenses >/dev/null || true
"$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" "platform-tools" "platforms;android-35" "build-tools;35.0.0"
chown -R runner:runner "$SDK"

echo "=== 4/6 GitHub-Runner laden ==="
VER=$(curl -fsSL https://api.github.com/repos/actions/runner/releases/latest | jq -r .tag_name | sed 's/^v//')
RD=/home/runner/actions-runner
mkdir -p "$RD"
curl -fsSL -o /tmp/runner.tar.gz "https://github.com/actions/runner/releases/download/v$VER/actions-runner-linux-x64-$VER.tar.gz"
tar -xzf /tmp/runner.tar.gz -C "$RD"
printf 'ANDROID_HOME=%s\nANDROID_SDK_ROOT=%s\n' "$SDK" "$SDK" > "$RD/.env"
chown -R runner:runner "$RD"
"$RD/bin/installdependencies.sh" >/dev/null

echo "=== 5/6 Runner bei GitHub anmelden ==="
sudo -u runner bash -c "cd '$RD' && ./config.sh --url '$REPO_URL' --token '$TOKEN' --name proxmox-bornim --labels bornim --unattended --replace"
cd "$RD"
./svc.sh install runner
./svc.sh start

echo "=== 6/6 Firewall: Internet ja, Heimnetz nein ==="
ufw --force reset >/dev/null
ufw default deny incoming
ufw default allow outgoing
GW=$(ip route | awk '/default/{print $3; exit}')
for ns in $(awk '/^nameserver/{print $2}' /run/systemd/resolve/resolv.conf 2>/dev/null) "$GW"; do
  case "$ns" in *%*|"") continue ;; esac   # link-local IPv6 (fe80::…%ens18) kann ufw nicht als Ziel
  ufw allow out to "$ns" port 53
done
[ -n "$GW" ] && ufw allow out to "$GW" port 67 proto udp   # DHCP-Verlängerung beim Router
ufw deny out to 10.0.0.0/8
ufw deny out to 172.16.0.0/12
ufw deny out to 192.168.0.0/16
ufw deny out to fc00::/7
ufw --force enable

echo
echo "FERTIG. Auf GitHub unter Settings > Actions > Runners steht jetzt  proxmox-bornim  mit grünem Punkt (Idle)."
