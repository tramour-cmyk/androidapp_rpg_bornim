# 109 · Repo privat stellen, bevor wir öffentlich Tester suchen?
Sokrates · 27.10., 19:58 · M Veröffentlichung
Kurz: Repo vor dem Tester-Aufruf privat (A), nur Releases löschen (B) oder so lassen (C)?

**Frage:** Du hast Sorge, dass Leute aus den Foren das Spiel auf GitHub finden und klauen (19:53). Stellen wir das Repo privat, bevor der Aufruf (142.3 A) rausgeht?

**Votum Sokrates: A** („109 A“), vorher Folgen prüfen lassen (unten).

**Berührt:** 109 (Repo öffentlich, „noch nicht privat“ 16.10.), 142.3 (Tester-Aufruf), Telegram-Filme und Bilder über jsDelivr (`meldung.sh`), GitHub Actions (Builds), Webseite.

## Begründung

Die Sorge ist berechtigt. Heute kann jeder den ganzen Code lesen und sogar die fertige App laden. Ein Aufruf mit dem Spielnamen führt Leute genau dorthin.

## Sachverhalt (geprüft 27.10., 19:55)

- Repo `tramour-cmyk/androidapp_rpg_bornim` ist **öffentlich**.
- **5 Releases mit `bornim.apk`** (11.–18.10.) kann jeder ohne Anmeldung laden.
- README: „© BornWire TCS 2026“, keine offene Lizenz. Rechtlich darf niemand den Code nutzen; durchsetzen ist teuer und langsam.
- Builds: 100 Läufe seit 26.10. (etwa 1,5 Tage), zusammen etwa 2 Stunden. Bei privatem Repo zählen Minuten gegen das Freikontingent von GitHub; ob das reicht, hängt vom Tarif ab (ungeprüft).
- Filme in Telegram und manche Bildlinks laufen über jsDelivr; das geht nur bei öffentlichem Repo.

## Auswertung

Stärkstes Gegenargument: Umbau und Kosten (Bild- und Filmwege neu, eventuell Build-Minuten bezahlen) für ein Risiko, das bei einem unfertigen Spiel klein ist. Dagegen: Ab dem Aufruf kennt man den Namen, und eine geklaute App im Store wäre schwer umkehrbar; ein Umstellen auf privat ist jederzeit umkehrbar.

## Folgerungen

- **A:** Perikles prüft mit Tom die Folgen (Minuten und Tarif, jsDelivr-Wege, Webseite) und stellt um; die Releases löschen. Der Tester-Aufruf geht erst danach raus. Umstellen kannst nur du (GitHub, Einstellungen des Repos, „Change visibility“); die Schritte kommen als Datei unter „tun“.
- **B:** Repo bleibt öffentlich, nur die 5 Releases mit APK werden gelöscht. Der Code bleibt lesbar.
- **C:** so lassen.

Antwort: …
