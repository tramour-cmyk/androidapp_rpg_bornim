#!/usr/bin/env python3
"""1618 (D311.1): blocked und IDLE gilt in beiden Eingabeformen als need_input, nie als Freigabe; Kurzzeile blocked bleibt Freigabe."""
import os, sys, json, tempfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kosten
fehler = []
d = tempfile.mkdtemp()
def lies(name, text):
    p = os.path.join(d, name); open(p, "w", encoding="utf-8").write(text); return kosten.sitzungen(p, [])
j = {"ccr": {"has_more": False, "data": [
    {"id": "session_a", "title": "Ford", "updated_at": "2026-11-18T02:00:00Z", "created_at": "2026-11-18T01:00:00Z", "session_status": "SESSION_STATUS_IDLE", "status_bucket": "BLOCKED"},
    {"id": "session_b", "title": "Tom", "updated_at": "2026-11-18T02:00:00Z", "created_at": "2026-11-18T01:00:00Z", "session_status": "SESSION_STATUS_RUNNING", "status_bucket": "BLOCKED"}]}}
a, b = lies("seite.json", json.dumps(j))
if "BLOCKED" in a["status_bucket"] or a.get("post_turn_summary", {}).get("status_category") != "need_input": fehler.append("JSON IDLE+blocked nicht need_input: %r" % a)
if "BLOCKED" not in b["status_bucket"]: fehler.append("JSON RUNNING+blocked verloren: %r" % b)
k = lies("kurz.txt", "session_c | need_input | 2026-11-18T02:00:00Z | Ford | - \nsession_d | blocked | 2026-11-18T02:00:00Z | Tom | - \n# has_more: nein\n")
if "BLOCKED" in k[0]["status_bucket"] or k[0]["post_turn_summary"]["status_category"] != "need_input": fehler.append("Kurz need_input falsch: %r" % k[0])
if "BLOCKED" not in k[1]["status_bucket"] or k[1]["session_status"] != "SESSION_STATUS_RUNNING": fehler.append("Kurz blocked falsch: %r" % k[1])
if fehler: print("\n".join(fehler)); sys.exit(1)
print("freigabe_idle_test: 4 Fälle grün")
