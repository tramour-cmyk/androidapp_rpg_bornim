# 1727 · Wer löst was aus, woher weiß es der Nächste, wo sieht er nach

Auftrag Chef 19.11., 20:40: „woher weiß das Büro jetzt das? Woher weiß die Arbeitsvorbereitung, dass sie arbeiten muss? Wer löst das aus? Wer guckt wo nach?“ Am Beispiel 9001 (Zwerg auf dem Tisch). Werkzeuge wie heute, wo nicht anders vermerkt.

**Grundsatz:** Nur das Büro schaut nach (Stundentakt und Weckruf). Alle anderen schauen nirgends nach: Sie werden gestartet, und ihr Auftrag steht in der ersten Nachricht (Sockel 1). Wer fertig ist, schickt dem Büro eine Nachricht; die weckt es.

| Nr. | Übergabe | wer löst aus | Signal (Werkzeug) | woher weiß es der Empfänger | wo sieht er nach |
|---|---|---|---|---|---|
| S1 | Chef → Sokrates | Chef | schreibt im Chat | Sokrates ist im Gespräch | Chat |
| S2 | Sokrates → Büro | Sokrates | Eintrag im Eingang, gepusht; dazu `send_message` an die Büro-Sitzung „Eingang: 9001 neu“ | die Nachricht weckt das Büro sofort; ohne sie spätestens die Uhr des Büros (stündlich, `create_trigger`) | `docs/ARBEIT-BETRIEB.md` „Eingang“ |
| S3 | Büro legt Vorgang an | Büro selbst | `vorgang.py neu` schreibt Liste und Vorgangsdatei | – | Vorgangsliste |
| S4 | Büro → Arbeitsvorbereitung | `lauf.py` beim nächsten Durchlauf: Vorgang ohne Auftrag, Muss, Fund des Chefs vorn → Ausgabe `START Arbeitsvorbereitung 9001` | Büro führt die Zeile aus: `create_session`, erste Nachricht = Kern Arbeitsvorbereitung + „Auftrag schreiben zu 9001“ | sie wird damit gestartet; nachschauen muss sie nichts | `docs/vorgang/9001.md`, `vorgang.py 9001`, Git |
| S5 | Arbeitsvorbereitung → Büro | Arbeitsvorbereitung, wenn fertig | Auftrag in die Vorgangsdatei, gepusht; `send_message` an das Büro „9001-1 steht“ | die Nachricht weckt das Büro | – |
| S6 | Büro → Macher | `lauf.py`: Auftrag offen → `START Macher 9001-1` (oder `WEITER` an einen Macher mit gleichem Profil, der noch klein ist) | `create_session` bzw. `send_message`, erste Nachricht = Sockel + Text des Auftrags 9001-1 | wird damit gestartet; der Auftrag ist alles, was er braucht | nur der Auftrag; Code im Zweig |
| S7 | Macher → Büro | Macher, wenn fertig | Push in den Zweig; `send_message` an das Büro „9001-1 fertig, Commit …, Beleg …“ (Feld „Zurück“) | die Nachricht weckt das Büro | – |
| S8 | Büro → Prüfer | `lauf.py`: Auftrag mit Ergebnis ohne Urteil → `START Prüfer 9001-1` | `create_session`, erste Nachricht = Kern Prüfer + Auftrag + Ergebnis | wird damit gestartet | Zweig, Beleg (Bild, Prüfausgabe) |
| S9 | Prüfer → Büro | Prüfer | `send_message` an das Büro „9001-1 ja“ oder „nein, weil …“; Urteil in den Auftrag (Werkzeug) | die Nachricht weckt das Büro | – |
| S10 | Büro → Arbeitsvorbereitung (nächster Auftrag) bzw. Macher (Nachbessern) | `lauf.py` | wie S4 bzw. S6 | wie S4 bzw. S6 | wie S4 bzw. S6 |
| S11 | Büro → Macher Build | `lauf.py`, wenn die Regel für Builds greift (Grobablauf 3.19.1) | `create_session` mit Profil Build und Liste der Zweige | wird damit gestartet | Zweige in der Warteschlange |
| S12 | GitHub → Büro | GitHub-Lauf endet | Büro liest bei jedem Durchlauf `actions_list`; rot ab 3 in der Stunde laut an den Chef | Durchlauf des Büros | GitHub Actions |
| S13 | Büro → Chef | Büro, Build grün | `meldung.sh`: Link und Prüfpunkte, mit Ton | Telegram auf dem Handy | Telegram |
| S14 | Chef → Sokrates | Chef nach dem Test | Chat (oder 👍/👎 in Telegram, das liest das Büro) | Sokrates ist im Gespräch | Chat |
| S15 | Sokrates → Büro | Sokrates | Wortlaut ins Vorgangsarchiv, gepusht; `send_message` an das Büro „9001 gut“ | weckt das Büro | `docs/VORGANGSARCHIV.md` |
| S16 | Büro → Macher Build → `main` | `lauf.py`: Vorgang mit „gut“ im Archiv | `START Macher` mit Profil Build „nach main“ | wird damit gestartet | Archiv-Eintrag als Beleg |
| S17 | Büro schließt | Büro | `vorgang.py schliessen 9001 --grund erledigt` | – | – |
| S18 | Wächter | GitHub-Lauf (Herzschlag) | prüft die Zeitmarke von `lauf.py` | – | meldet dem Chef per Telegram, wenn sie älter als 2 h ist |

**Was es dafür noch nicht gibt:** S2, S5, S7, S9, S15: Die Nachricht ans Büro gibt es heute als Brauch (`send_message` an Ford), sie steht künftig im Feld „Zurück“ jedes Auftrags und im Kern; Ford wacht heute schon auf Nachricht. `lauf.py` kennt Arbeitsvorbereitung, Prüfer und Auftragsstände noch nicht (Bauliste 7.1). Herzschlag S18 ist nicht gebaut. Die Regel für Builds (S11) entscheidet der Chef.
