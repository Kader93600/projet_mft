#!/usr/bin/env python3
"""
Fix les apostrophes échappées '' dans les contenus markdown des leçons GOTRM v3.

Les blocs $lessonGN$...$lessonGN$ sont du dollar-quoting PostgreSQL : à
l'intérieur, les apostrophes ne doivent PAS être doublées. Mon erreur :
j'ai écrit ''ordre'' au lieu de 'ordre' partout, ce qui rend littéralement
des doubles apostrophes à l'écran.

Ce script ne touche QUE le contenu entre $lessonGN$ et $lessonGN$.
"""

import re
import sys
from pathlib import Path

if len(sys.argv) < 2:
    print("Usage: python3 fix_gotrm_apostrophes.py <file.sql>")
    sys.exit(1)

path = Path(sys.argv[1])
src = path.read_text(encoding="utf-8")

# Pattern dollar-quoted : $tag$...$tag$
# On capture le tag pour matcher le bon délimiteur de fin
pattern = re.compile(r"(\$lesson[A-Z0-9]+\$)(.*?)(\1)", re.DOTALL)

def unescape(match: re.Match) -> str:
    open_tag, body, close_tag = match.group(1), match.group(2), match.group(3)
    # Remplacer '' par ' à l'intérieur du body uniquement
    fixed = body.replace("''", "'")
    return f"{open_tag}{fixed}{close_tag}"

new_src = pattern.sub(unescape, src)

# Compter le nombre de remplacements
count = src.count("''") - new_src.count("''")
path.write_text(new_src, encoding="utf-8")
print(f"✓ {path.name} : {count} apostrophes corrigées dans les blocs dollar-quoted.")
