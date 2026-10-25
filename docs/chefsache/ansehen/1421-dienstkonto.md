# 142.1 · Dienstkonto für den Upload in die Play Console · Tom · 25.10., 16:21

AAB 0.1.1032 ist im internen Test und installiert (dein Wort 16:21). Für den Upload aus GitHub fehlt nur noch ein Dienstkonto; das kannst nur du anlegen, etwa 10 Minuten.

**Votum:** jetzt anlegen, Upload aber nur per Knopf, nicht bei jedem Push auf `main`. **Stärkstes Gegenargument:** das alte Spiel ruht, ein Upload bringt heute wenig. Dagegen: dasselbe Dienstkonto und Secret trägt später die Godot-Fassung (gleicher Paketname, gleicher Upload-Schlüssel) und den Pflichttest mit 12 Testern (142). „Noch nicht“ geht auch; dann ruht 142.1 bis Godot.

## Schritte

1. [Google Cloud Console](https://console.cloud.google.com), angemeldet mit dem Konto der Play Console: neues Projekt, z. B. „bornim-play“.
2. „APIs und Dienste“ → „Bibliothek“: **Google Play Android Developer API** suchen, „Aktivieren“.
3. „IAM und Verwaltung“ → „Dienstkonten“ → „Dienstkonto erstellen“: Name „github-upload“, keine Rolle, „Fertig“. Das Dienstkonto öffnen → „Schlüssel“ → „Schlüssel hinzufügen“ → „Neuen Schlüssel erstellen“ → **JSON**. Die Datei wird heruntergeladen; sie ist ein Passwort: nie in den Chat, nie ins Repo.
4. [Play Console](https://play.google.com/console), Kontoübersicht (nicht in der App), linkes Menü „Nutzer und Berechtigungen“ → „Neue Nutzer einladen“: die E-Mail des Dienstkontos (endet auf `iam.gserviceaccount.com`, steht in der Liste aus Schritt 3); unter „App-Berechtigungen“ „Chroniken von Bornim“ hinzufügen, Recht **Apps in Test-Tracks veröffentlichen**; einladen. Eine Verknüpfung unter „API-Zugriff“ braucht es nicht mehr.
5. GitHub: Repo → „Settings“ → „Secrets and variables“ → „Actions“ → „New repository secret“: Name **`PLAY_DIENSTKONTO`**, Inhalt der ganze Text der JSON-Datei. Danach die Datei auf dem Rechner löschen.

Sag dann „Dienstkonto steht“.

## Danach (Tom)

Knopf „Play-Upload“ im Workflow (`workflow_dispatch`): lädt das AAB eines gewählten Laufs in den internen Test. Ein Upload braucht einen versionCode über 1033, also einen neuen Build. Das Recht wirkt bei Google oft erst nach Stunden (bis 48 h); ein früher Fehler „permission denied“ heißt nur: später noch einmal.
