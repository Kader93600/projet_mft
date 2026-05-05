#!/usr/bin/env python3
"""
Corrige les apostrophes simples non doublées dans les chaînes PG `'...'` des
fichiers SQL GOTRM, en respectant les blocs dollar-quoted ($lessonN$...$lessonN$).

Heuristique : dans une chaîne PG, une apostrophe SEULE qui est suivie d'une
lettre, d'un chiffre, d'une espace+lettre, etc. est une apostrophe non
échappée → la doubler. Une apostrophe suivie de `,`, `)`, `;`, `::jsonb`,
`\n  '...'` (autre chaîne adjacente) ou whitespace+`,)` est la fin de chaîne.

Cette heuristique est assez sûre pour notre format SQL très régulier mais doit
être vérifiée manuellement (le validateur JSON Python servira de gardien).
"""

import re
import sys
from pathlib import Path

# Patterns de fin de chaîne (apostrophe TERMINATRICE)
# Si après l'apostrophe on voit un de ces patterns, c'est une fin de chaîne.
END_OF_STRING_PATTERN = re.compile(
    r"^"
    r"(?:"
    r"::jsonb"          # cast jsonb
    r"|\s*[,;)]"         # virgule, semicolon, paren fermante
    r"|\s*\n\s*[,;)]"    # même chose après newline
    r")"
)


def fix_string_content(text):
    """Reçoit le contenu d'une chaîne PG (entre les ' délimiteurs).
    Double les apostrophes simples non doublées."""
    out = []
    i = 0
    while i < len(text):
        c = text[i]
        if c == "'":
            # Si c'est déjà ''  (deux apostrophes), c'est échappé : on garde tel quel
            if i + 1 < len(text) and text[i + 1] == "'":
                out.append("''")
                i += 2
                continue
            # Sinon, apostrophe seule à doubler
            out.append("''")
            i += 1
            continue
        out.append(c)
        i += 1
    return "".join(out)


def find_string_boundaries(text, start):
    """Cherche dans `text` à partir de `start` la prochaine chaîne PG `'...'`.
    Retourne (début_quote_ouvrante, contenu_string, fin_quote_fermante_pos+1)
    ou None si pas trouvé.

    Gère les apostrophes échappées `''` et reconnaît la fin de chaîne via
    les patterns END_OF_STRING_PATTERN."""
    n = len(text)
    pos = start

    # Trouver l'ouverture de chaîne
    while pos < n:
        if text[pos] == "'":
            # Vérifier que ce n'est pas un cast '::jsonb' précédent ou une fin
            break
        # Skip dollar-quoted blocks: $tag$ ... $tag$
        if text[pos] == "$":
            m = re.match(r"\$(lesson\w*)\$", text[pos:])
            if m:
                tag = m.group(0)
                end_idx = text.find(tag, pos + len(tag))
                if end_idx == -1:
                    return None
                pos = end_idx + len(tag)
                continue
        pos += 1

    if pos >= n:
        return None

    open_pos = pos
    pos += 1
    content_start = pos

    # Lire le contenu de la chaîne, à la recherche de la fin
    while pos < n:
        if text[pos] == "'":
            # Cas 1 : '' échappement
            if pos + 1 < n and text[pos + 1] == "'":
                pos += 2
                continue
            # Cas 2 : potentielle fin de chaîne
            after = text[pos + 1 : pos + 1 + 50]  # lookahead
            if END_OF_STRING_PATTERN.match(after) or pos + 1 == n:
                return (open_pos, text[content_start:pos], pos + 1)
            # Cas 3 : ni '', ni fin → apostrophe NON échappée dans la chaîne
            # On la traite comme un caractère normal et on continue
            pos += 1
            continue
        pos += 1

    # Chaîne non terminée → on retourne quand même ce qu'on a
    return (open_pos, text[content_start:pos], pos)


def fix_file(text):
    """Parcourt le fichier, identifie les chaînes PG, double les apostrophes non échappées."""
    out = []
    pos = 0
    n = len(text)
    while pos < n:
        # Skip blocs dollar-quoted en entier
        if text[pos] == "$":
            m = re.match(r"\$(lesson\w*)\$", text[pos:])
            if m:
                tag = m.group(0)
                end_idx = text.find(tag, pos + len(tag))
                if end_idx == -1:
                    out.append(text[pos:])
                    return "".join(out)
                # Inclure tout le bloc tel quel
                out.append(text[pos : end_idx + len(tag)])
                pos = end_idx + len(tag)
                continue

        # Trouver la prochaine chaîne PG
        result = find_string_boundaries(text, pos)
        if result is None:
            out.append(text[pos:])
            return "".join(out)

        open_pos, content, end_pos = result

        # Texte avant la chaîne (inchangé)
        out.append(text[pos:open_pos])

        # Chaîne corrigée : on remet les ' délimiteurs et on échappe le contenu
        fixed_content = fix_string_content(content)
        out.append("'" + fixed_content + "'")

        pos = end_pos

    return "".join(out)


if __name__ == "__main__":
    files = sys.argv[1:]
    if not files:
        print("Usage: fix_unescaped_apostrophes.py file1.sql [file2.sql ...]")
        sys.exit(1)
    for f in files:
        text = Path(f).read_text(encoding="utf-8")
        new_text = fix_file(text)
        if new_text != text:
            Path(f).write_text(new_text, encoding="utf-8")
            print(f"✓ {f} : apostrophes doublées")
        else:
            print(f"- {f} : rien à corriger")
