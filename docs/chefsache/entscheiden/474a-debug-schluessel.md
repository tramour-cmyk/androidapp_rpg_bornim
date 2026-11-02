# 474a · Debug-Schlüssel als Geheimnis statt im Cache?
Tom · 02.11., 13:4x · E Technik

**Frage:** Soll der Debug-Schlüssel der Godot-Probe (`de.bornim.game.godot`, Passwort „android“, nicht der Play-Schlüssel) als GitHub-Geheimnis `GODOT_DEBUG_KEYSTORE` hinterlegt werden statt nur im Cache?

**Votum Tom:** ja. Hast du keine Zeit dafür: „noch nicht“. Dann bleibt es beim Cache, und nach jedem Verdrängen musst du einmal deinstallieren.

**Berührt:** Builds (`godot.yml`, `godot-schluessel.yml`); dein Handy: einmal deinstallieren, das ist ohnehin fällig (Build 146 hat den alten Schlüssel).

**Begründung:** Der Cache wurde am 02.11. verdrängt (Tuffy), seit 05:13 gibt es einen neuen Schlüssel. Android lehnt das Update dann ab, du musst deinstallieren. Ein Geheimnis wird nicht verdrängt.

**Sachverhalt:** Vorbereitet ist: `godot.yml` nimmt das Geheimnis, wenn es da ist, sonst den Cache. `godot-schluessel.yml` gibt den jetzigen Schlüssel auf Knopfdruck einen Tag lang als Text zum Hinterlegen aus. Der Push wurde von der Sicherheitsprüfung dieser Sitzung abgelehnt (Schlüssel in Abläufen), darum liegt nichts auf GitHub.

**Stärkstes Gegenargument:** ein Schlüssel mehr in den Geheimnissen. Er schützt nichts, Passwort „android“, nur die Probe.

**Stellungnahme Sokrates (02.11., 18:5x, fremd geprüft):** ja, wie Tom. Das Repo ist öffentlich, darum ist das Artefakt einen Tag lang für jeden angemeldeten GitHub-Nutzer ladbar. Das Risiko ist klein: es ist nur der Probeschlüssel, das Passwort steht schon offen in `godot.yml`, und eine gefälschte APK müsstest du selbst installieren. Verworfen habe ich den Schlüssel im privaten Repo `bornim-kaufmodelle`: das umgeht die Regel „Keystore nie committen“. Dazu käme eine zweite Quelle neben dem Cache, und das Problem kehrte leise zurück. Vorteil von Toms Weg: das Geheimnis ist der Schlüssel von 05:13, Builds seitdem bleiben gültig, also höchstens einmal deinstallieren. Zusatz für Tom: steht das Geheimnis, legt `godot-schluessel.yml` keinen neuen Schlüssel im Cache mehr an. So gibt es nur eine Quelle.

**Folgerungen bei „ja“:** (1) Du erlaubst mir den Push dieser zwei Abläufe; (2) ich starte „Godot-Schlüssel“ mit „ausgeben = ja“; (3) du lädst die Textdatei herunter und legst ihren Inhalt unter Settings → Secrets and variables → Actions als `GODOT_DEBUG_KEYSTORE` an (etwa 2 Minuten).
