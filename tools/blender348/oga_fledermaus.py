# 510 (Chef 03.11., 10:28–10:57, aus 494): die freie Fledermaus „Vampire Bat (Animated)“ von rubberduck (OpenGameArt, CC0,
# https://opengameart.org/content/vampire-bat-animated, animated_vampire_bat.zip -> bat_v5.blend; Texturen CC0 von yughues) mit
# unseren drei Fellen (fledermaus.py COATS, HELL) und in unserer Größe (Spannweite wie fledermaus.py) als GLB, damit der Chef sie im
# Film neben der eigenen sieht und wählt. Bewegungen nur wie vorhanden (10:45: „nichts neu bauen“, Lücken nennen).
# Die Farbe: Helligkeit der Originaltextur (bat_tex.jpg) relativ zu ihrem Mittel, mal Fellfarbe; die Flughaut wird so von selbst
# dunkler, wo das Original dunkler ist. Augen, Zähne o. ä. mit eigenem Stoff ohne diese Textur behalten ihre Farbe.
# Aufruf: OGA=<ausgepackter Ordner> OUT=<ordner> python -I oga_fledermaus.py -> <OUT>/oga_bat-<fell>.glb, oga_bat-info.json
# Druckt zuerst den Inhalt der Datei (OBJ, AKTION, BILD, STOFF), damit ein Lauf ohne Blender am Rechner nachvollziehbar ist.
import os, sys, json, math, time, glob
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
T0 = time.time()
import bpy
import numpy as np
from mathutils import Vector

OGA = os.environ.get('OGA', '')
OUT = os.environ.get('OUT', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'out'))
os.makedirs(OUT, exist_ok=True)
ID = 'oga_bat'
# wie fledermaus.py: Fell, Flughaut; Helligkeit je Fell; Spannweite und Größe je Fell
COATS = {'braun': 0x6E3E24, 'schwarz': 0x221E20, 'grau': 0x766E6A}
HELL = {'braun': 0.45, 'schwarz': 0.3, 'grau': 0.38}
GROESSE = {'braun': 1.0, 'schwarz': 1.07, 'grau': 0.9}
SPANNWEITE = 1.68


def zeige(h, f=1.0):
    """wie fledermaus.py zeige(): Farbe, die im Kampfort im Sonnenlicht etwa die Bildfarbe h ergibt."""
    c = np.array([((h >> s) & 255) for s in (16, 8, 0)], float) * f / 216.0
    return np.clip(c, 0, 1) ** (1 / 2.2)


def blend_datei():
    t = sorted(glob.glob(os.path.join(OGA, '**', 'bat_v5.blend'), recursive=True))
    if not t:
        sys.exit('FEHLT bat_v5.blend unter %s' % OGA)
    return t[0]


def inhalt():
    for o in bpy.data.objects:
        mods = ','.join('%s:%s' % (m.type, getattr(getattr(m, 'object', None), 'name', '-')) for m in getattr(o, 'modifiers', []))
        print('OBJ %s %s Eltern=%s Maß=%s Mods=%s Teile=%d' % (o.name, o.type, o.parent.name if o.parent else '-',
              tuple(round(x, 3) for x in o.dimensions), mods or '-', len(o.data.vertices) if o.type == 'MESH' else 0))
    for a in bpy.data.actions:
        print('AKTION %s Bilder %s Nutzer %d' % (a.name, tuple(round(x, 1) for x in a.frame_range), a.users))
    for im in bpy.data.images:
        print('BILD %s %s %s gepackt=%s' % (im.name, im.filepath, tuple(im.size), bool(im.packed_file)))
    for m in bpy.data.materials:
        bilder = [n.image.name for n in (m.node_tree.nodes if m.use_nodes and m.node_tree else []) if n.type == 'TEX_IMAGE' and n.image]
        print('STOFF %s Knoten=%s Bilder=%s Farbe=%s' % (m.name, m.use_nodes, bilder, tuple(round(x, 2) for x in m.diffuse_color)))
    print('BILDRATE', bpy.context.scene.render.fps)


def welt_ecken(meshes):
    dg = bpy.context.evaluated_depsgraph_get(); P = []
    for o in meshes:
        e = o.evaluated_get(dg); me = e.to_mesh()
        P += [tuple(e.matrix_world @ v.co) for v in me.vertices]
        e.to_mesh_clear()
    return np.array(P)


def haupttextur():
    """bat_tex.jpg als Pixel (sRGB 0..1), aus der Datei im Paket (unabhängig vom alten Stoff)."""
    t = [p for p in sorted(glob.glob(os.path.join(OGA, '**', 'bat_tex.jpg'), recursive=True))]
    if not t:
        sys.exit('FEHLT bat_tex.jpg unter %s' % OGA)
    im = bpy.data.images.load(t[0])
    w, h = im.size
    px = np.array(im.pixels[:], np.float32).reshape(h, w, 4)
    print('TEXTUR %s %dx%d Mittel %s' % (t[0], w, h, tuple(round(float(x), 3) for x in px[..., :3].reshape(-1, 3).mean(0))))
    return im, px


def faerbe(px, fell):
    L = px[..., 0] * 0.2126 + px[..., 1] * 0.7152 + px[..., 2] * 0.0722
    rel = np.clip(L / max(1e-3, float(L.mean())), 0.25, 2.0)
    out = np.empty_like(px)
    out[..., :3] = np.clip(zeige(COATS[fell], HELL[fell])[None, None, :] * rel[..., None], 0, 1)
    out[..., 3] = 1.0
    return out


def ist_haupt(m):
    if m is None or not m.use_nodes or not m.node_tree:
        return False
    for n in m.node_tree.nodes:
        if n.type == 'TEX_IMAGE' and n.image and 'bat_tex' in (n.image.name + n.image.filepath).lower() and '_n' not in n.image.name.lower():
            return True
    return False


def neuer_stoff(name, bild=None, farbe=None):
    m = bpy.data.materials.new(name); m.use_nodes = True
    bsdf = next(n for n in m.node_tree.nodes if n.type == 'BSDF_PRINCIPLED')
    if bild is not None:
        tx = m.node_tree.nodes.new('ShaderNodeTexImage'); tx.image = bild
        m.node_tree.links.new(tx.outputs['Color'], bsdf.inputs['Base Color'])
    elif farbe is not None:
        bsdf.inputs['Base Color'].default_value = (farbe[0], farbe[1], farbe[2], 1.0)
    return m


def main():
    # Lauf 235 nachgestellt: nach open_mainfile rechnet das Bpy-Modul die Szene nicht nach (Spannweite in jeder Bewegung 10,322 wie
    # in Ruhe, der Maßstab am Gerüst kam nicht in die Datei, die Auswahl blieb leer); darum leere Szene, alles aus bat_v5.blend
    # hineinladen (ohne Skripte), Bildpfade der Datei auf ihren Ordner
    src = blend_datei()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    with bpy.data.libraries.load(src, link=False) as (von, nach):
        nach.objects = list(von.objects)
        nach.actions = list(von.actions)
    for o in nach.objects:
        if o is not None:
            bpy.context.scene.collection.objects.link(o)
    for im in bpy.data.images:
        if im.filepath.startswith('//'):
            im.filepath = os.path.join(os.path.dirname(src), im.filepath[2:])
    inhalt()
    rigs = [o for o in bpy.data.objects if o.type == 'ARMATURE']
    if not rigs:
        sys.exit('FEHLT Gerüst (ARMATURE) in bat_v5.blend')
    rig = max(rigs, key=lambda o: len(o.data.bones))
    meshes = [o for o in bpy.data.objects if o.type == 'MESH' and (o.parent == rig or any(m.type == 'ARMATURE' and m.object == rig for m in o.modifiers))]
    if not meshes:
        sys.exit('FEHLT Netz am Gerüst %s' % rig.name)
    for o in list(bpy.data.objects):
        if o != rig and o not in meshes:
            bpy.data.objects.remove(o, do_unlink=True)
    print('GERUEST %s Knochen %d, Netze %s' % (rig.name, len(rig.data.bones), [m.name for m in meshes]))
    for m in meshes:
        if m.parent != rig:
            mw = m.matrix_world.copy(); m.parent = rig; m.matrix_world = mw
    # Ruhehaltung ohne Bewegung: Spannweite (größte waagerechte Ausdehnung) und Höhe
    if rig.animation_data is None:
        rig.animation_data_create()
    rig.animation_data.action = None
    rig.data.pose_position = 'REST'
    bpy.context.view_layer.update()
    P = welt_ecken(meshes)
    span0 = float(max(np.ptp(P[:, 0]), np.ptp(P[:, 1])))
    print('RUHE Spannweite %.3f, Höhe %.3f bis %.3f (Blender-Einheiten)' % (span0, P[:, 2].min(), P[:, 2].max()))
    rig.data.pose_position = 'POSE'
    for tr in list(rig.animation_data.nla_tracks):
        rig.animation_data.nla_tracks.remove(tr)
    # Lauf 235 nachgestellt (Knochen in Godot 8 m weit, Maßstab 1): „SunAction“ und „Frost_Bat_preview_position“ gehören der Sonne und
    # der Frostfledermaus und setzen Ort, Drehung, Maßstab des Objekts; als Spur am Gerüst hoben sie dessen Maßstab auf. Nur
    # Bewegungen, die allein Knochen dieses Gerüsts bewegen
    def nur_knochen(a):
        pfade = [f.data_path for L in getattr(a, 'layers', []) for st in L.strips for cb in getattr(st, 'channelbags', []) for f in cb.fcurves]
        pfade += [f.data_path for f in getattr(a, 'fcurves', []) or []] if not hasattr(a, 'layers') else []
        return bool(pfade) and all(p.startswith('pose.bones["') and p.split('"')[1] in rig.data.bones for p in pfade)
    acts = [a for a in bpy.data.actions if not any(w in a.name.lower() for w in ('cam', 'light', 'lamp')) and nur_knochen(a)]
    print('BEWEGUNGEN genommen', [a.name for a in acts], 'weggelassen', [a.name for a in bpy.data.actions if a not in acts])
    fps = bpy.context.scene.render.fps / bpy.context.scene.render.fps_base
    dauer = {a.name: round((a.frame_range[1] - a.frame_range[0]) / fps, 3) for a in acts}
    # Spannweite je Bewegung (an 7 Stellen), vor den NLA-Spuren, damit nur diese Bewegung wirkt
    weit = {}
    for a in acts:
        rig.animation_data.action = a
        if hasattr(a, 'slots') and len(a.slots) and hasattr(rig.animation_data, 'action_slot'):
            rig.animation_data.action_slot = a.slots[0]
        spans = []
        for f in np.linspace(a.frame_range[0], a.frame_range[1], 7):
            bpy.context.scene.frame_set(int(round(f)))
            Q = welt_ecken(meshes)
            spans.append(float(max(np.ptp(Q[:, 0]), np.ptp(Q[:, 1]))))
        weit[a.name] = round(max(spans), 3)
    rig.animation_data.action = None
    bpy.context.scene.frame_set(0)
    print('SPANNWEITE je Bewegung', weit)
    for a in acts:
        tr = rig.animation_data.nla_tracks.new(); tr.name = a.name
        st = tr.strips.new(a.name, int(a.frame_range[0]), a)
        if hasattr(a, 'slots') and len(a.slots) and hasattr(st, 'action_slot'):
            st.action_slot = a.slots[0]
    # Bezug: die größte Spannweite im Flug (Fliegen, sonst die größte überhaupt) soll unsere Spannweite sein
    flug = [v for k, v in weit.items() if 'fly' in k.lower()]
    bezug = max(flug) if flug else max(list(weit.values()) + [span0])
    base_scale = rig.scale.copy()
    src_im, px = haupttextur()
    info = {'quelle': 'Vampire Bat (Animated), rubberduck, OpenGameArt, CC0', 'bewegungen': dauer, 'spannweite_quelle': bezug}
    alte = {}
    for m in meshes:
        alte[m.name] = [s.material for s in m.material_slots]
    gross = max(meshes, key=lambda o: len(o.data.vertices))
    def hat_bild(mt):
        return mt is not None and mt.use_nodes and mt.node_tree and any(n.type == 'TEX_IMAGE' and n.image for n in mt.node_tree.nodes)
    for fell in COATS:
        s = SPANNWEITE * GROESSE[fell] / bezug
        rig.scale = base_scale * s
        bild = bpy.data.images.new('%s-%s' % (ID, fell), src_im.size[0], src_im.size[1])
        bild.pixels.foreach_set(faerbe(px, fell).ravel())
        bild.filepath_raw = os.path.join(OUT, '%s-%s.png' % (ID, fell)); bild.file_format = 'PNG'; bild.save()
        haupt = neuer_stoff('%s-%s' % (ID, fell), bild=bild)
        for m in meshes:
            for i, sl in enumerate(m.material_slots):
                alt = alte[m.name][i]
                if ist_haupt(alt) or (m == gross and not hat_bild(alt)):
                    sl.material = haupt
                elif alt is not None and not alt.use_nodes:
                    sl.material = neuer_stoff(alt.name + '-' + fell, farbe=alt.diffuse_color)
        # Lauf 235: mit use_selection=True kam eine leere Datei (132 Byte): ohne Fenster bleibt die Auswahl des Bpy-Moduls leer
        # (context.selected_objects = []); alles andere ist oben schon entfernt, darum die ganze Szene
        path = os.path.join(OUT, '%s-%s.glb' % (ID, fell))
        bpy.ops.export_scene.gltf(filepath=path, export_format='GLB', use_selection=False, export_animations=True, export_skins=True,
                                  export_animation_mode='NLA_TRACKS', export_yup=True, export_apply=False, export_image_format='JPEG',
                                  export_jpeg_quality=88)
        try:
            from glbquat import quat_stetig
            quat_stetig(path)
        except Exception as e:  # nur Glättung der Drehschlüssel; ohne sie bleibt die Datei brauchbar
            print('GLBQUAT', e)
        info[fell] = {'massstab': round(s, 4), 'spannweite': round(SPANNWEITE * GROESSE[fell], 3)}
        print('GLB', path, os.path.getsize(path), 'Maßstab %.4f' % s)
        if os.path.getsize(path) < 20000:
            sys.exit('FEHLT Inhalt in %s (%d Byte)' % (path, os.path.getsize(path)))
    json.dump(info, open(os.path.join(OUT, '%s-info.json' % ID), 'w'), indent=1)
    print('OGA_FLEDERMAUS FERTIG %.1f s' % (time.time() - T0), json.dumps(info, ensure_ascii=False))


if __name__ == '__main__':
    main()
