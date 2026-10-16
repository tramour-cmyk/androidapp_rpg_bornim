# 124 · Vorgänge in Hauptthemen gliedern und mit Preis versehen?

Sokrates Projekt · 16.10., 20:25 · Anlass Chef 16.10., 20:2x: „Alles hat eine Vorgangsnummer. Ist das soweit richtig? Wenn ja, möchte ich von dir einen Vorschlag dazu haben, wie wir das in grobe Hauptthemen und ein paar Unterthemen gliedern können. Im Sinne von, keine Ahnung, Entwicklung, Design, Qualitätsmanagement, allgemeine Betriebskosten und so weiter. Und alle Vorgänge, möchte ich, dass wir dann auch mit einem Preis versehen. Ist das machbar? Und macht das Sinn?“

Kurz: fünf Hauptthemen mit Buchstaben; Preis je Vorgang aus den Sitzungskosten, Ford trägt ihn beim Neustart ein; Probe eine Woche ab So 18.10., Bilanz 23.10.

**Stimmt „alles hat eine Nummer“?** Fast. Ohne Nummer laufen Fords und Ford 2s Stundenläufe, Starts und Übergaben (Zeile „Betrieb“). Manche Sitzungen tragen mehrere Nummern (Sammelbuilds, Umbau am Samstag). Diogenes zählt eigene Nummern (D1–D17).

**Frage:** So gliedern und bepreisen, erst als Probe für eine Woche?

**Empfehlung:** Ja, schlank.

| Kürzel | Hauptthema | Unterthemen |
|---|---|---|
| **E** | Entwicklung | Welt und Orte · Figuren und Monster · Kampf und Regeln · Klang · Oberfläche |
| **G** | Gestaltung | Story und Texte · Stil und Aussehen · Balance und Spielgefühl |
| **Q** | Qualität | QS: Builds, Prüflisten, Rückläufer · QM: Prüfläufe Diogenes |
| **B** | Betrieb (Gemeinkosten) | Steuerung (Ford, Ford 2) · Abläufe und Notizen · Werkzeuge (Haken, Skripte, Bauen) |
| **M** | Markt und Strategie | Berater, Veröffentlichung |

1. **Gliedern:** eine Spalte „Bereich“ in `LISTE-THEMEN.md` (z. B. „E Kampf“); ich ordne die 124 Nummern einmal zu, neue bekommen ihn beim Anlegen.
2. **Preis:** jede Sitzung meldet ihre Kosten (`get_session` → `usage.cost_usd`; geht auf beiden Accounts). Ford liest beim Neustart die Kosten des Vorgängers und schreibt sie in die Zeile des Vorgangs; mehrere Nummern: zu gleichen Teilen; Fords eigene Läufe auf B Steuerung. Ersetzt Ford 2s Kostenzeilen (FIRMA „Messung“), damit keine Regel dazukommt (90a).
3. **Auswertung:** einmal die Woche eine Tabelle Anteil je Hauptthema. Die wichtigste Zahl ist der Anteil E+G: unser Ziel „die meiste Zeit ins Spiel“ wird damit zum ersten Mal messbar.

**Was „Preis“ heißt:** Der Betrag in Dollar ist, was die Sitzung zu API-Preisen gekostet hätte, nicht deine Rechnung (Max und Pro sind Pauschalen mit Wochengrenze). Als Maß taugt er trotzdem: Anteile und Vergleiche zwischen Vorgängen stimmen. Deine Testzeit ist nicht enthalten; ersatzweise zählen wir Testrunden je Vorgang.

**Stärkstes Gegenargument:** Buchhaltung kostet selbst Guthaben und lädt zum Falschen ein: wer Kosten sieht, baut billig statt gut. Dagegen: Ford liest die Sitzung beim Neustart ohnehin; eine Zahl mehr kostet fast nichts, und bewertet wird nur der Anteil je Hauptthema, nicht die einzelne Sitzung. Bringt die Woche keine Entscheidung, fällt es am 23.10. wieder weg.
