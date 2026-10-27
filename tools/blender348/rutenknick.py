# 348.12f (Jerry): größter Knick der Rute (Steigungsdifferenz benachbarter Glieder) je Bewegung aus Film-Logs mit RUTE_MESS=1
# Aufruf: python3 rutenknick.py <film.log> ...   Ziel Tod und Treffer ≤ ~20° (Runde 3: 18°, 16°)
import sys, re, collections
for p in sys.argv[1:]:
    m = collections.OrderedDict()
    for l in open(p, errors='replace'):
        r = re.match(r'Rute (.+?)\s+(\d+) ([\d.]+) Steigung je Glied (.*)', l)
        if not r: continue
        s = [int(x) for x in r.group(4).split()]
        k = max(abs(a - b) for a, b in zip(s, s[1:]))
        i = max(range(len(s) - 1), key=lambda j: abs(s[j] - s[j + 1]))
        if k > m.get(r.group(1), (-1,))[0]: m[r.group(1)] = (k, r.group(3), i, r.group(4))
    print('==', p)
    for n, (k, t, i, s) in m.items(): print('  %-18s Knick %3d° bei %s s, Glied %d/%d: %s' % (n, k, t, i, i + 1, s))
