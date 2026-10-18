# 177 · Ford-Start: sofort bei Übergabe oder stündlich lassen
Perikles · 18.10., 15:35 · B Abläufe · Frage des Chefs 18.10., 15:30: „Sollte bei einem Push nicht automatisch geprüft werden, ob eine Sitzung zu starten ist?“

Kurz: Starten kann nur eine Claude-Sitzung (`create_session`), ein Push-Haken kann es nicht; heute weckt die Stundenuhr (:03) Ford, ein Start wartet bis zu eine Stunde.

**Frage:** Soll der Start sofort nach einer Übergabe passieren (Weg 1) oder bleibt es stündlich (Weg 2)?

**Empfehlung:** Weg 2 bis zur Messung 20.–21.10., dann entscheiden.
- **Weg 1:** Der Starthaken der pushenden Sitzung schickt bei Übergabe mit „Nachfolger: …“ Ford automatisch „Neustart <Name>, <Commit>“ (der Weg besteht schon, 81r, nur von Hand). Umbau am Haken, kein neues Werkzeug. Ford rechnet weiter mit `lauf.py`.
- **Weg 2:** nichts bauen, messen, wie oft Arbeit wegen der Stundenwartezeit stand.

**Stärkstes Gegenargument:** Jede Wartestunde ist Leerlauf, Tom und Jerry stehen sonst; ein Haken ist billig. Dagegen: mehr Ford-Läufe kosten Guthaben, und ein Haken ist eine weitere Regel (90a), die ausfallen kann; unbelegt, ob die Wartezeit überhaupt schmerzt.

**Anders möglich:** Uhr dichter als stündlich; laut Werkzeug nicht möglich (Minimum stündlich).

**Berührt:** 167.2 (`lauf.py`), 81r (Neustart über Ford), 99h (Messung Pausenläufe), 90a (Regelbilanz).
