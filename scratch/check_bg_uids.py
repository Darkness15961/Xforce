import re

files = [
    'assets/sprites/fondo_cielo.png.import',
    'assets/sprites/nubes_fondo.png.import',
    'assets/sprites/fondo_montana.png.import',
    'assets/sprites/nubes_frente.png.import',
    'assets/sprites/fondo_casas.png.import',
    'assets/sprites/fondo_cerca.png.import',
]
for f in files:
    with open(f) as fp:
        m = re.search(r'uid=[\"\'](uid://[^\"]+)[\"\']', fp.read())
        print(f, "->", m.group(1) if m else 'NONE')
