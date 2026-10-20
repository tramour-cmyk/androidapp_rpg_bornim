# 244 · Bilder kommen nicht auf Telegram an: Korrektur meldung.sh
Sokrates · 20.10., 12:25 · Q Ablauf · M (Chef 12:17: „Jetzt der Grundsatz Bilder vor Builds festgehalten und berücksichtigen das alle. Ich kriege auf Telegram echt wenig Bilder zu sehen.“; berührt 228)

## Befund

Seit 19.10., 19:01 lagen 26 Bilder in der Chefsache, 13 kamen als Bild an. 8 verschluckte `meldung.sh`: `--bild` hinter dem Text wird still übergangen, nur der Text geht raus, Meldung „gesendet“. 5 wurden nie geschickt (68 ×3, 224, 211-nebeneinander). Builds 38, 42, 43 hatten sichtbare Änderungen ohne Bild vorher.

## Empfehlung

Korrektur `meldung.sh` ohne Gerätetest auf `main` (Werkzeug, keine Spiellogik, nicht in der APK): Optionen an jeder Stelle; unbekannte Option oder überzählige Angaben brechen ab, nichts geht raus. Mit `--probe` an sechs Fällen geprüft. Keine neue Regel, 228 genügt.

*Stärkstes Gegenargument:* Die Builds ohne Bild erklärt das Skript nicht; wiederholt es sich, Hinweis an die Teams.

## Antwort

„ja“ (Push) oder „nein“.
