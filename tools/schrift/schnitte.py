import sys
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools import subset
U="U+0020-007E,U+00A0-00FF,U+0152-0153,U+0160-0161,U+0178,U+017D-017E,U+2010-2027,U+2030,U+2039-203A,U+20AC,U+2122,U+2190-2193,U+2212,U+00D7,U+2715,U+2713"
def sub(f, out):
    opts=subset.Options(); opts.layout_features=['kern','liga','smcp','c2sc','onum','lnum','pnum','tnum','calt','ccmp','locl','mark','mkmk']; opts.name_IDs=['*']; opts.notdef_outline=True
    s=subset.Subsetter(opts); s.populate(unicodes=subset.parse_unicodes(U)); s.subset(f); f.save(out)
for src,w,out in [("src/ebg.ttf",400,"ebgaramond_regular"),("src/ebg.ttf",600,"ebgaramond_semibold"),("src/aleg.ttf",400,"alegreya_regular"),("src/aleg.ttf",600,"alegreya_semibold"),("src/cinzel.ttf",600,"cinzel_semibold"),("src/fell.ttf",None,"imfell_regular"),("src/alegsc_m.ttf",None,"alegreya_sc_medium")]:
    f=TTFont("src/"+src.split('/')[1])
    if w: f=instantiateVariableFont(f,{"wght":w})
    sub(f,"out/"+out+".ttf")
