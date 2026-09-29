import re

files = [
    'default_theme.tres',
    'assets/sprites/fondo_cielo.png.import',
    'assets/sprites/fondo_montana.png.import',
    'assets/sprites/instagram_logo.png.import',
    'assets/sprites/linkedin_logo.png.import',
    'assets/sprites/youtube_logo.png.import',
    'assets/sprites/github_logo.png.import',
    'assets/sprites/twitch_logo.png.import',
]
for f in files:
    with open(f, 'r', encoding='utf-8', errors='ignore') as fp:
        c = fp.read()
        m = re.search(r'uid=[\"\'](uid://[^\"]+)[\"\']', c)
        print(f, "->", m.group(1) if m else 'NO UID')
