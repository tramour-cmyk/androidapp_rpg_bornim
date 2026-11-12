# 1016 · Startest du in den nächsten Stunden den Betriebsleiter Ford von Hand neu?
Ford · 12.11., 06:12 · B Abläufe · Regel 110 (Sitzungstiefe), `LISTE-BETRIEB.md` „Selbstneustart“ und „Tiefe“
Kurz: Der Ford, der jetzt startet, liegt auf Tiefe 6; der nächste Selbstneustart ist damit nicht mehr erlaubt, du startest dann in claude.ai/code einen neuen Ford von Hand.

Geprüft an: [LISTE-BETRIEB.md, Selbstneustart und Tiefe](https://github.com/tramour-cmyk/androidapp_rpg_bornim/blob/main/docs/LISTE-BETRIEB.md); laufende Ford-Sitzung `get_session` lineage.depth 5, Grenze 8

**Frage:** Jede Sitzung trägt eine Tiefe: wer eine Sitzung gestartet hat, ist eins höher als seine Neue. Ab Tiefe 8 funktionieren weder neue Sitzungen noch Uhren, Weckrufe oder zeitgesteuerte Nachrichten, der Betrieb stünde. Darum bleibt Ford höchstens auf Tiefe 6 und seine Teams auf 7. Der Ford, der jetzt übergibt, liegt auf Tiefe 5, sein Nachfolger auf 6. Dieser Nachfolger darf sich nicht mehr selbst neu starten. Wann startest du den nächsten Ford von Hand?

**Votum:** „1016 A“, heute Vormittag: Du startest in claude.ai/code eine Sitzung mit **Umgebung „WireStorm Hoch“, Modell Sonnet, Aufwand Hoch**, Repo `androidapp_rpg_bornim`, erste Nachricht „Ford“; sie liegt dann auf Tiefe 0. Der jetzige Ford (Tiefe 6, seit 06:12) stand um 07:05 bei 115 Tsd. Token; die Grenze von 200 Tsd. erreicht er etwa zwischen 08:30 und 09:30. (Perikles 07:07: „Voll“ korrigiert; bis 14.11. gilt „WireStorm Hoch“, Ford läuft nach Startzuordnung auf Sonnet, `LISTE-BETRIEB.md`.)

**Berührt:** Ford (Stundenuhr „Ford-Lauf“, neue Sitzung legt sie selbst an), Perikles (Besitzer von 1016), `LISTE-BETRIEB.md` „Selbstneustart“

**Begründung:** Ein Ford auf Tiefe 6 darf keinen Nachfolger mehr starten, ohne dass Tom, Jerry und die anderen Rollen unter Tiefe 8 kommen; eine Ausnahme verlangt dein Wort. Vorwarnung jetzt, damit du den Zeitpunkt wählst und nachts nichts klingelt.

**Sachverhalt:**
- **Tiefe:** der laufende Ford liegt auf Tiefe 5 (`get_session`, `lineage.depth` 5, Grenze 8); sein Nachfolger auf 6.
- **Wirkung ab 8:** weder `create_session` noch Uhr, Weckruf oder `send_later` gehen (`LISTE-BETRIEB.md` „Tiefe“, 110).
- **Dauer:** Neustart-Haken bei 200 Tsd. Token (383 A); ein Ford brauchte bisher etwa 2 bis 3 Stunden dahin (Protokoll 12.11.).
- **Nacht:** kein Ton, Nachricht lautlos (Chefwort, Betriebsregeln in `ARBEIT-BETRIEB.md`).

**Auswertung:**
- **A (Empfehlung) Von Hand starten:** zwei Minuten, Tiefe 0, danach wieder ein langer Lauf ohne Handgriff. Der neue Ford archiviert den alten.
- **B Weiterlaufen lassen und nichts tun:** der Ford auf Tiefe 6 läuft bis zur Grenze, danach liegt der Betrieb still, bis du ihn startest; kein Schaden, aber Stillstand.
- **Geprüft, kein Ersatz (Perikles 07:07):** die Ford-Wache liegt auf Tiefe 4; ein von ihr gestarteter Ford läge auf 5 und brächte nur einen weiteren Selbstneustart, danach wieder diese Frage.
- **Stärkstes Gegenargument gegen A:** ein Ford auf Tiefe 7 wäre noch erlaubt; die Grenze 6 ist eine Vorsicht, keine Grenze des Systems. Antwort: auf 7 liegen schon die Teams, und jede weitere Stufe nimmt ihnen Luft vor der harten Grenze 8.

**Folgerungen:** Nach deinem Start archiviert der neue Ford den alten, Perikles schließt 1016, die Datei wird gelöscht.

Antwort: …
