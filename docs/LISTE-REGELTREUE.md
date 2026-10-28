# Regeltreue (347)

Zählung je Sitzung, geschrieben vom Stop-Haken `tools/zug-haken.py` in `~/.bornim-regeltreue.tsv` (Container). Vor Übergabe oder Neustart hängt jede Sitzung ihre Summenzeile hier an (`LISTE-RELEASE-NEUSTART.md` „Neustart“, Schritt 0). Auswertung Sokrates nach einer Woche (mit 318); Basis rückwirkend aus Stichproben 21.–24.10. (`list_events`), danach nur noch diese Tabelle.

**Gemessen (vorab festgelegt, Gegenprüfung 347.1):**
- Wörter: letzter Text je Zug ohne Codeblöcke; Median je Rolle, Sokrates getrennt. **Ziel: Median −30 % gegen die Basis.**
- Uhr: Anteil Stempel außerhalb Nachricht −1 bis Zugende +2 Minuten; der Haken zählt sie nur (Chef 24.10., 21:15: nicht anhalten). **Ziel: unter 5 %.**
- Entschuldigungen je Sitzung; Kontextgröße am Ende (Tsd. Token, zusätzlich `used_tokens` aus `list_sessions`).
- Wirkt erst, wo der Zweig `main` ab 24.10., 17 Uhr enthält (Kernregel-Zeile, `notiz.sh`); der Stop-Haken läuft aus `bornim-main` sofort überall.

**Basis (Sokrates 25.10., 10:36; 318):** gleiche Methode für alle drei Abschnitte: je Sitzung die letzten 100 Schritte (`list_events`, nur Assistent), gezählt werden Antworten mit Stempel „**Name** [TT.MM., HH:MM]“ (Wörter ohne Codeblöcke), Stempel gegen Ereigniszeit, Texte ohne Stempel (Zwischenstände), Entschuldigungen. Stichprobe klein (7–13 Sitzungen je Abschnitt), also Richtwert.

| Abschnitt | Sitzungen | Antworten | Wörter Median ohne Sokrates | Sokrates Median | Stempel daneben | Texte ohne Stempel | Entschuldigungen |
|---|---|---|---|---|---|---|---|
| A vor „Knapp“ (22.10. bis 21:34) | 8 | 20 | 58 | 109 | 4/20 (bis +4 min) | 10 | 1 |
| B „Knapp“ (22.10., 21:34 bis 24.10., 17:00) | 8 | 11 | 44 | 108 | 5/11 (bis +12 min) | 11 | 0 |
| C nach 347 (25.10., 07:00–10:30) | 13 | 26 | 33 | 129 | 11/26 (bis +6 min) | 13 | 0 |

Befund: Wörter der Teams −43 % gegen A (Ziel −30 % erreicht); Stempel schlechter (42 %, Ziel unter 5 %), fast immer vorgerechnet, der Stop-Haken zählt nur (Chef 24.10., 21:15); Zwischenstände unverändert; Sokrates bleibt lang (darf begründen). Vorschlag: Chefsache 318.1.

| Zeit | Rolle | Sitzung | Züge | Wörter Median | Wörter max | Entschuldigungen | Stempel daneben/gesamt | Kontext Tsd. | Haken 63 nachgeprüft: gehalten/„Keine Chefsache“/durch (383, ab 27.10., 19:15) |
|---|---|---|---|---|---|---|---|---|---|
| 24.10., 16:57 | Perikles | 9440fe84-e09 | 1 | 22 | 22 | 0 | 1/1 | 166 |
| 24.10., 21:41 | Homer | 11bcbe06-db2 | 4 | 43 | 69 | 0 | 1/4 | 189 |
| 24.10., 21:56 | Jerry | 89e59e50-e44 | 1 | 107 | 107 | 0 | 1/1 | 199 |
| 24.10., 23:05 | Sokrates | ac92fa37-3ef | 4 | 230 | 249 | 0 | 0/4 | 123 |
| 24.10., 23:06 | Jerry | 04120bc5-3b8 | 1 | 108 | 108 | 0 | 0/1 | 203 |
| 25.10., 00:07 | Tom | f5764fda-d51 | 5 | 12 | 15 | 0 | 1/5 | 194 |
| 25.10., 02:33 | Jerry | 7fb68f90-b14 | 2 | 12 | 21 | 0 | 1/1 | 218 |
| 25.10., 06:52 | Jerry | 2319359c-b90 | 6 | 20 | 29 | 0 | 0/5 | 202 |
| 25.10., 09:23 | Sokrates | 090bab64-52f | 2 | 125 | 244 | 0 | 0/1 | 157 |
| 25.10., 10:05 | Jerry | d3c604b0-559 | 1 | 8 | 8 | 0 | 0/0 | 145 |
| 25.10., 12:00 | Sokrates | bced0bfc-0fa | 18 | 137 | 373 | 0 | 0/17 | 440 |
| 25.10., 12:41 | Sokrates | 4329fd9c-34e | 1 | 93 | 93 | 0 | 0/0 | 168 |
| 25.10., 15:06 | Jerry | 71c1a5b7-770 | 1 | 14 | 14 | 0 | 0/1 | 310 |
| 25.10., 17:45 | Jerry | c8d98e6f-978 | 2 | 36 | 42 | 0 | 0/2 | 197 |
| 25.10., 19:42 | Jerry | 71fc825b-c65 | 2 | 10 | 15 | 0 | 0/2 | 275 |
| 25.10., 21:04 | Jerry | fc98d6ff-124 | 1 | 31 | 31 | 0 | 0/1 | 279 |
| 25.10., 21:41 | Tom | ec4f2d25-a94 | 1 | 5 | 5 | 0 | 0/0 | 250 |
| 25.10., 22:01 | Sokrates | 3619f4cc-542 | 12 | 64 | 460 | 0 | 0/11 | 253 |
| 25.10., 22:05 | Jerry | 82daaf72-15d | 1 | 17 | 17 | 0 | 1/1 | 250 |
| 25.10., 22:35 | Jerry | bab4e9ba-01b | 2 | 23 | 35 | 0 | 2/2 | 276 |
| 25.10., 23:56 | Jerry | 26a5949b-646 | 1 | 25 | 25 | 0 | 0/1 | 207 |
| 26.10., 00:27 | Tom | 57cc4e19-d75 | 2 | 13 | 14 | 0 | 1/2 | 230 |
| 26.10., 03:21 | Jerry | 670c9b98-39b | 1 | 9 | 9 | 0 | 1/1 | 240 |
| 26.10., 03:49 | Jerry | e84914a9-789 | 3 | 26 | 59 | 0 | 1/3 | 157 |
| 26.10., 03:57 | Tom | a3d543ce-a96 | 4 | 15 | 27 | 0 | 0/0 | 278 |
| 26.10., 11:25 | Sokrates | 5147604d-34b | 12 | 74 | 486 | 0 | 4/12 | 232 |
| 26.10., 11:55 | Sokrates | a1d42023-79c | 9 | 218 | 474 | 0 | 0/9 | 204 |
| 26.10., 13:59 | Jerry | 03b48619-44b | 1 | 6 | 6 | 0 | 0/0 | 212 |
| 26.10., 14:29 | Jerry | 47ddc8c9-812 | 1 | 12 | 12 | 0 | 0/1 | 253 |
| 26.10., 15:40 | Sokrates | dc01c9c1-6d0 | 15 | 63 | 201 | 0 | 1/13 | 207 |
| 26.10., 15:42 | Tom | a6157a47-4a7 | 3 | 30 | 40 | 0 | 0/2 | 227 |
| 26.10., 16:58 | Jerry | 89af8434-d31 | 1 | 39 | 39 | 0 | 0/1 | 258 |
| 26.10., 18:39 | Jerry | 30e7c341-d4c | 5 | 12 | 28 | 0 | 1/1 | 252 |
| 26.10., 19:47 | Jerry | 207212c7-385 | 3 | 20 | 22 | 0 | 1/3 | 231 |
| 26.10., 21:01 | Tom | a9d874da-052 | 2 | 65 | 109 | 0 | 0/2 | 280 |
| 26.10., 21:20 | Jerry | add6a2f9-c16 | 2 | 26 | 29 | 0 | 0/2 | 190 |
| 26.10., 22:25 | Tom | 186fd555-4c2 | 5 | 9 | 15 | 0 | 0/0 | 250 |
| 26.10., 23:47 | Jerry | 892eb731-fb6 | 6 | 20 | 60 | 0 | 0/6 | 281 |
| 27.10., 00:12 | Jerry | af2cc2b8-f26 | 3 | 9 | 17 | 0 | 2/3 | 220 |
| 27.10., 01:02 | Jerry | 42af22b8-ba0 | 3 | 6 | 7 | 0 | 0/0 | 297 |
| 27.10., 02:40 | Jerry | dc455aab-5da | 3 | 13 | 13 | 0 | 0/0 | 276 |
| 27.10., 05:54 | Jerry | 0b0a2bd1-ba4 | 6 | 8 | 11 | 0 | 3/6 | 216 |
| 27.10., 09:07 | Jerry | b9a2c3ed-9cb | 3 | 5 | 9 | 0 | 0/0 | 193 |
| 27.10., 10:21 | Tom | 9d9348af-c34 | 1 | 4 | 4 | 0 | 0/0 | 262 |
| 27.10., 10:41 | Jerry | e18dc88d-751 | 1 | 22 | 22 | 0 | 0/1 | 221 |
| 27.10., 11:50 | Jerry | 20adb6b5-a3b | 3 | 188 | 189 | 0 | 0/2 | 270 |
| 27.10., 12:10 | Jerry | 24eeb98b-dc4 | 2 | 33 | 37 | 0 | 0/1 | 155 |
| 27.10., 13:41 | Jerry | e64f59f6-8e7 | 3 | 20 | 21 | 0 | 0/3 | 283 |
| 27.10., 15:53 | Jerry | dc2901f7-d25 | 1 | 94 | 94 | 0 | 0/1 | 111 |
| 27.10., 18:38 | Jerry | 79341a58-233 | 2 | 12 | 14 | 0 | 0/1 | 212 |
| 27.10., 20:05 | Tom | abb87c40-811 | 3 | 5 | 8 | 0 | 0/0 | 179 | 0/0/0 |
| 27.10., 20:34 | Jerry | bca6f3f0-5e5 | 1 | 14 | 14 | 0 | 1/1 | 122 | 0/0/0 |
| 27.10., 22:33 | Tom | a183cafc-27a | 4 | 18 | 23 | 0 | 0/0 | 252 | 0/0/0 |
| 27.10., 22:50 | Jerry | c681341f-7b7 | 8 | 6 | 7 | 0 | 0/0 | 324 | 0/0/0 |
| 28.10., 00:01 | Tom | fbdaf056-352 | 8 | 21 | 40 | 0 | 0/6 | 329 | 0/0/0 |
| 28.10., 09:09 | Tom | 6d82fd6d-679 | 5 | 33 | 174 | 0 | 0/2 | 331 | 0/0/0 |
| 28.10., 10:42 | Tom | d33dc3e9-632 | 3 | 23 | 105 | 0 | 0/0 | 558 | 0/0/0 |
| 28.10., 11:29 | Tom | bb47e65b-084 | 2 | 31 | 40 | 0 | 0/1 | 232 | 0/0/0 |
| 28.10., 12:01 | Tom | a3e42198-eca | 3 | 28 | 94 | 0 | 0/0 | 356 | 1/0/1 |
| 28.10., 13:06 | Jerry | 6670c536-974 | 2 | 12 | 15 | 0 | 1/2 | 502 | 0/0/0 |
