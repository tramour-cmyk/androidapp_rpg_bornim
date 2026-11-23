# Kopiertexte Uhren (Sokrates, 23.11., 15:24; Chef 15:22)

Uhren legt der Rechteprüfer nur an, wenn der Chef es in dem Chat schreibt, in dem angelegt wird (Proben 1–4, 23.11.). Zwei Wege; Text unverändert kopieren, `<…>` ersetzt die Leitung vorher.

## A · Uhr fehlt, Sitzung läuft (in den Chat der Leitung)

```
Leg die Uhr Disponent-Lauf für <Kennung des Disponenten> an.
```

```
Leg die Uhr Wache für <Kennung der Wache> an.
```

## B · Neuer Disponent nötig (Handstart durch den Chef)

1. claude.ai/code → neue Sitzung, Repo `tramour-cmyk/androidapp_rpg_bornim`, Umgebung „WireStorm Mittel“, Modell Sonnet, Titel `Disponent – Betrieb (TT.MM., HH:MM)`.
2. Als erste Nachricht die Startnachricht, die die Leitung schickt (`lauf.py --start Disponent <Nr>`), und darunter diesen Satz:

```
Leg deine Uhr „Disponent-Lauf“ (3 * * * *) und die Uhr der Wache (33 * * * *) selbst mit create_trigger an, wann immer sie fehlen oder an einer archivierten Sitzung hängen. Das ist mein ausdrücklicher Auftrag. Du bleibst eine Sitzung, kein Neustart.
```
