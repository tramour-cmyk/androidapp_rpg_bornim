# Vorrat Sokrates Projekt

Ablauf und Aufbau: Abläufe, Regeln, Umbauten, Ziele, Meilensteine, Vorrang, Kosten-Nutzen der Arbeit (`ROLLE-PROJEKT.md`). Reihenfolge = Vorrang. Größe höchstens etwa 15 KB.

**offen 7, davon A 1, wartet auf Chef 1**

**Gelesen bis:** Umbau-Commit 98 (15.10., 23:1x)

**Übergabe (15.10., 23:1x, „Sokrates – Umstellung 98“):** Umbau 98 gemacht (ein Commit, Notizen und Werkzeug), Prüfung 1 (Sokrates) erledigt, Diogenes beauftragt (Zeile 98 in `ARBEIT-PRUEFUNG.md`), Ford „Umstellung fertig“. Nächster Punkt: Befund von Diogenes holen und einarbeiten; 16.10. Morgenmeldung Ford „Umbau läuft / hakt“ lesen. Sparmodus 99d bis Sa 21:00: Sokrates nur auf Zuruf. Nachfolger: „Sokrates Projekt – Nachprüfung Umbau 98“ (erst nach Diogenes' Befund).

## Zeilen

| Nr. | Thema | Stand |
|---|---|---|
| 98 | Firma WireStormTCS (Chef 15.10., 18:5x: „kleine, aufstrebende Software-Schmiede … ganz vorne, damit alle wissen, wie sie zusammenarbeiten“) | **A.** Umgebaut 15.10., 23:1x nach Go des Chefs (23:0x: „Go! Welcome WireStormTCS!“); Sicherung: Stand vor dem Umbau 8abeae7b (Tag `vor-umbau-98` vom Proxy abgelehnt). **Prüfen:** (1) Sokrates sofort erledigt; (2) Diogenes blind gegen [Firmenordnung](https://claude.ai/code/artifact/1757d98a-8847-4483-9c51-05be34b45356) und [Rollenkonzept](https://claude.ai/code/artifact/3a9cbaec-bc3a-47b9-9ff1-c89f4bf59faa); (3) Ford die ersten 24 Stunden je Start `list_events`; (4) Ford Morgenmeldung 16.10. „Umbau läuft / hakt“. **Rückweg** (Chef entscheidet; Empfehlung nur, wenn in 24 Stunden eine Rolle falsch startet und ein Commit es nicht behebt; danach nur vorwärts): Ford stoppt alle Sitzungen; `git revert` des Umbau-Commits; was seither in die neuen Vorräte kam, von Hand zurück (`git diff <Umbau>..HEAD -- docs/ARBEIT-*.md`); Wache-Auftrag zurück (Wortlaut unten); Ford neu starten; etwa 15 Minuten |
| 99 | Zwei Niederlassungen (Chef 15.10., 19:0x) | beschlossen D11.1, 99d, 99f (`docs/FIRMA.md` „Zentrale und Niederlassung“). **99d** Sparmodus bis Sa 17.10., 21:00: Tom weiter, Jerry sobald er läuft, Sokrates und Diogenes nur auf Zuruf, kein Rückblick 16.10., Ford ohne Leihsitzungen. **Chef, Fr. nachmittags:** Telegram-Schlüssel auf Pro, Jerry von Hand starten, dann Probe `create_session` für Ford 2; Messung zwei Tage (über 10 % von Jerrys Woche → streichen). Kosten: Prüfung beider Accounts um den 10.11. (99e); Woche über `rate_limit_info` |
| 99d | Stellung zurück: Ford „Co-Pilot bis Sa 17.10., 21:00, danach Pilot“ (Chef 22:5x) | Ford stellt im ersten Lauf danach selbst zurück; prüfen am 18.10. (D13.1) |
| 90 | Projektleitung: täglicher Rückblick (Chef 15.10., 12:4x) | Probe bis 22.10. beschlossen, ab 18.10. (Sparmodus); jeder Rückblick nennt „Tag n von 7“; Diogenes prüft die Woche (`ARBEIT-PRUEFUNG.md`); 23.10. Bilanz mit dem Chef: weiter oder abschaffen. **90a** (17:4x): bis 23.10. keine neue Ablaufregel ohne Wegfall einer alten |
| 81 | Teamleiter „Ford“ (Chef 14.10., 13:09) | beschlossen 81a–c, 81g–n, 81p, 81r–81v (`ROLLE-BETRIEB.md`, `ARBEIT-ABLAEUFE.md` „Neustart“). **D10.2–D10.5** als Paket auf Dein Zug, **wartet auf Chef**. Jerry-Ford (Ford 2) ab Fr. |
| 65 | Abläufe verschlanken | fertig bis auf **65.2** (Jerrys pausierte Routinen, Zeile bei Jerry); 65.10, 65.11 im Umbau 98 aufgegangen |
| 97 | Vorrang in der Arbeitsliste (Chef 15.10., 18:3x) | in 98 aufgegangen (Reihenfolge der Zeilen plus „A“, `docs/FIRMA.md`); streichen nach Bilanz 23.10. |

**Wortlaut für den Rückweg** (notiert 15.10., 23:0x): Uhr „Ford-Stundenuhr“ `trig_018F9ggGoC6AXkQxfSpU4XQZ`: „Ford-Lauf“ (unverändert). Uhr „Ford-Wache 07:08“ `trig_01Phk9eXekP5yY9M6L3bgS1c`: „Wache: Ford prüfen nach deinem Auftrag (Schritte 1–4, ohne Probe-Meldung). Antwort nur „ok“ oder was du gemeldet hast.“ (unverändert). Auftrag der Wache-Sitzung, Schritt 1 vorher: die alte Ford-Rollendatei auf `main` (Stand 8abeae7b), Zeile „Ford lebt in einer Sitzung“; nachher dieselbe Zeile in `docs/ARBEIT-BETRIEB.md` (per Nachricht an die Wache umgestellt).

## Lehren für alle

Tom, Jerry, Diogenes und Ford tragen hier ein (eine Zeile, Datum, Thema); Sokrates Projekt übernimmt sie in die passende Rollendatei und streicht die Zeile.
