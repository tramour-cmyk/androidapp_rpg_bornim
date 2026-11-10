# 854a · Gebaute Kaufmodelle aus dem Kaufrepo: Werkzeug auf main, Bauserver mit Schreibrecht?
Jerry · 10.11., 15:26 · B Werkzeuge · aus deinem Wort 12:34 („Kaufmodelle im Kaufrepo ablegen, ja“), 14:17 („jedes Mal geht es bei Null los“)
Kurz: am Rechner läuft es, 26 Sekunden statt 46 Minuten; zwei Freigaben fehlen

Geprüft an: https://github.com/tramour-cmyk/androidapp_rpg_bornim/tree/claude/jerry-854-kaufcache (Bau 14:31–15:17, Ablage und zweimal Holen 15:20–15:24, alle 522 Dateien byteweise gleich dem vollen Bau)

**Frage:** (1) Darf das Werkzeug ohne Gerätetest auf `main` (nur `tools/godot/kauf_cache.py`, `tools/godot/bau_am_rechner.py`; keine Spiellogik, baut keine APK)? (2) Gibst du `KAUF_TOKEN` Schreibrecht aufs Kaufrepo, damit der Bauserver auch ablegt?

**Votum:** „854a 1 ja, 2 ja“

**Berührt:** Tom (878, `godot.yml`-Entwurf auf demselben Zweig; seine Modelle für 653/475 kommen am Rechner ebenso schnell)

**Begründung:** Jede Sitzung, die mit Kaufmodellen misst, baute bisher 46 Minuten (7 Laden, 39 Bau). Jetzt nur, wenn sich Bauskripte, Bauschritte oder Kaufdateien geändert haben; danach legt der Bau selbst ab. Stärkstes Gegenargument: ein falscher Treffer liefert alte Modelle. Dagegen steht die Kennung über alle Eingaben (Skripte, Schritte, Fassungen, Karten, Kaufdateien) und der Vergleich Byte für Byte.

**Sachverhalt:**
- Ablage als Zweig `bau/<Kennung>` im Kaufrepo, nicht als Release-Anhang: Versionen anlegen und Zweige löschen lehnt die Sitzung ab (403). Gleiche Dateien teilen sich die git-Objekte, ein neuer Stand kostet nur, was sich geändert hat (voll 362 MB ungepackt).
- Nie im öffentlichen Repo, nie als Artefakt oder Actions-Cache (Caches eines öffentlichen Repos liest auch ein Lauf aus einem fremden Fork).
- Übrig aus dem ersten Versuch: zwei Zweige `bau/78e96cdb554622f1794f` und `…-teil` (löschen kann nur du auf GitHub, schadet nicht).

**Auswertung:**
- (1) Ja: Sitzungen holen die Modelle dann vom Hauptzweig, ohne den 854-Zweig zu kennen; der Bauserver ändert sich dadurch nicht (`godot.yml` erst mit 878).
- (1) Nein: jede Sitzung muss den Zweig `claude/jerry-854-kaufcache` kennen, sonst baut sie wieder 46 Minuten.
- Gegenargument zu (1): Werkzeug ohne deinen Test auf `main`. Es ändert aber nichts am Spiel und nichts am Bauserver; schlimmstenfalls baut eine Sitzung wieder voll.
- Gegenargument zu (2): ein Token mit Schreibrecht im Bauserver könnte bei einem Fehler im Skript Dateien im Kaufrepo anlegen. Es schreibt nur neue Zweige `bau/…`, `main` und die Releases des Kaufrepos fasst es nicht an.
- (2) Ja: der Bauserver spart je Lauf etwa 35 der 63 Minuten, sobald Tom zustimmt (878). Nein: er holt nur, was Sitzungen abgelegt haben, und baut sonst voll (das Ablegen meldet dann nur einen Fehler, der Bau geht weiter).

**Folgerungen:** Nach (1) ja mischt Jerry die zwei Werkzeuge auf `main`. Nach (2) ja und Toms Ja zu 878 kommt `godot.yml` in den nächsten Testbuild. Danach geht es mit 709 weiter.

**Was du tust:** (2) auf github.com → Settings → Developer settings → das Token hinter `KAUF_TOKEN` → Repository `bornim-kaufmodelle` → Contents „Read and write“ (falls es nur „Read“ hat).

Antwort: …
