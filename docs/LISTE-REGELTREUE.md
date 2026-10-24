# Regeltreue (347)

Zählung je Sitzung, geschrieben vom Stop-Haken `tools/zug-haken.py` in `~/.bornim-regeltreue.tsv` (Container). Vor Übergabe oder Neustart hängt jede Sitzung ihre Summenzeile hier an (`LISTE-RELEASE-NEUSTART.md` „Neustart“, Schritt 0). Auswertung Sokrates nach einer Woche (mit 318); Basis rückwirkend aus Stichproben 21.–24.10. (`list_events`), danach nur noch diese Tabelle.

**Gemessen (vorab festgelegt, Gegenprüfung 347.1):**
- Wörter: letzter Text je Zug ohne Codeblöcke; Median je Rolle, Sokrates getrennt. **Ziel: Median −30 % gegen die Basis.**
- Uhr: Anteil Stempel außerhalb Nachricht −1 bis Zugende +2 Minuten; der Haken hält solche Antworten an. **Ziel: unter 5 %.**
- Entschuldigungen je Sitzung; Kontextgröße am Ende (Tsd. Token, zusätzlich `used_tokens` aus `list_sessions`).
- Wirkt erst, wo der Zweig `main` ab 24.10., 17 Uhr enthält (Kernregel-Zeile, `notiz.sh`); der Stop-Haken läuft aus `bornim-main` sofort überall.

| Zeit | Rolle | Sitzung | Züge | Wörter Median | Wörter max | Entschuldigungen | Stempel daneben/gesamt | Kontext Tsd. |
|---|---|---|---|---|---|---|---|---|
| 24.10., 16:57 | Perikles | 9440fe84-e09 | 1 | 22 | 22 | 0 | 1/1 | 166 |
| 24.10., 21:41 | Homer | 11bcbe06-db2 | 4 | 43 | 69 | 0 | 1/4 | 189 |
| 24.10., 21:56 | Jerry | 89e59e50-e44 | 1 | 107 | 107 | 0 | 1/1 | 199 |
| 24.10., 23:05 | Sokrates | ac92fa37-3ef | 4 | 230 | 249 | 0 | 0/4 | 123 |
