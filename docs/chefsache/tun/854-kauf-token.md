# 854 · Dem Token KAUF_TOKEN Schreibrecht aufs Kaufrepo geben
Sokrates für Jerry · 10.11., 15:52 · B Werkzeuge

Dein „854a 2 ja“ (15:30) heißt: Der Bauserver legt gebaute Kaufmodelle selbst im Kaufrepo ab. Dafür braucht das Token hinter dem Geheimnis `KAUF_TOKEN` Schreibrecht. Die Vorlage 854a wurde mit deiner Antwort gelöscht; dieser Schritt blieb ohne Datei.

1. github.com → Settings → Developer settings → Personal access tokens → das Token, das als `KAUF_TOKEN` im Repo `androidapp_rpg_bornim` hinterlegt ist.
2. Repository access: `tramour-cmyk/bornim-kaufmodelle`.
3. Permissions → Contents: „Read and write“ (hat es nur „Read“, umstellen); speichern.
4. Im Chat oder in Telegram „854 Token erledigt“; dann löscht Jerry diese Datei.

Ohne den Schritt läuft alles weiter, nur baut der Bauserver die Modelle jedes Mal neu (etwa 35 von 63 Minuten je Lauf). Wirksam erst mit Toms Ja zu 878 (`godot.yml`).
