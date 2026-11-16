# 601.1 · Pfeiltreffer: warum der Held im Film zum Prüfpunkt 291.8 nicht zuckte

[Film von 16.11., 23:08](https://cdn.jsdelivr.net/gh/tramour-cmyk/androidapp_rpg_bornim@film/20261116-230803-601.1/2026-11/16-2308-601.1-Tuffy.mp4) (eingetragen von meldung.sh, Tuffy)

Tuffy · 16.11., 23:07 · E Kampf · Rückläufer aus Prüfpunkt 291.8 (Chef 16.11., 12:24)
Kurz: Der Pfeil traf Hilde außerhalb des Bildes; dazu brach das Ende der Schildbewegung das Zucken ab. Beides behoben, neuer Film nach Freigabe eines Laufs.

Geprüft an: `claude/jerry-601-1-zucken` `9f5e81a38` (Film am Rechner, Telegram 16.11., 23:07)

**Was der Film zeigt:** zwei Schüsse des Goblin-Spähers. Der erste geht daneben, der zweite trifft Hilde, die links außerhalb des Bildes steht; der Pfeil fliegt auf Schildhöhe an Ansgar vorbei. Genau so sah der Film zum Prüfpunkt 291.8 aus (Kampfmeldung dort: „trifft Hilde: 7 Schaden“).

**Behoben:**
- Wer mit Schild einen Pfeil abbekommt, hebt erst den Schild und zuckt dann. Das Ende der Schildbewegung brach das Zucken nach 0,3 statt 1 Sekunde ab. Jetzt läuft es aus; der Test `zucken_6011` prüft es bei jedem Lauf.
- Die Filmkamera zeigt jetzt das Ziel des Schusses, mit mehr Rand.

**Offen:** ein Film mit dem Treffer an der Brust. Der eine Lauf ist verbraucht; Bitte um Freigabe bei Sokrates.
