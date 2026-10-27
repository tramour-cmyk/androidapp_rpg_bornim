# 348.12f (Jerry): größter Knick der Rute je Bewegung aus Film-Logs mit RUTE_MESS=1: senkrecht (Steigungsdifferenz benachbarter
# Glieder) und ab Runde 4 räumlich (Winkel zwischen Nachbargliedern, „| Knick räumlich …“ in probe.gd)
# Aufruf: python3 rutenknick.py <film.log> ...   Ziel ≤ ~20° (Runde 3: Tod 16°, Treffer 18° senkrecht; Prüfer: Messung nur senkrecht)
import sys, re, collections
for p in sys.argv[1:]:
    m, r3 = collections.OrderedDict(), collections.OrderedDict()
    for l in open(p, errors='replace'):
        r = re.match(r'Rute (.+?)\s+(\d+) ([\d.]+) Steigung je Glied ([-+\d ]*?)(?: \| Knick räumlich (.*))?$', l.rstrip())
        if not r: continue
        s = [int(x) for x in r.group(4).split()]
        k = max(abs(a - b) for a, b in zip(s, s[1:]))
        i = max(range(len(s) - 1), key=lambda j: abs(s[j] - s[j + 1]))
        if k > m.get(r.group(1), (-1,))[0]: m[r.group(1)] = (k, r.group(3), i, r.group(4))
        if r.group(5):
            w = [int(x) for x in r.group(5).split()]
            j = max(range(len(w)), key=lambda j: w[j])
            if w[j] > r3.get(r.group(1), (-1,))[0]: r3[r.group(1)] = (w[j], r.group(3), j)
    print('==', p)
    for n, (k, t, i, s) in m.items():
        z = '  %-18s Knick %3d° bei %s s, Glied %d/%d: %s' % (n, k, t, i, i + 1, s)
        if n in r3: z += '  | räumlich %d° bei %s s, Glied %d/%d' % (r3[n][0], r3[n][1], r3[n][2], r3[n][2] + 1)
        print(z)
