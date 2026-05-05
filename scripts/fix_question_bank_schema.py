#!/usr/bin/env python3
"""
Transforme les fichiers GOTRM utilisant le MAUVAIS schema question_bank
(colonnes fictives `prompt`/`correct`) vers le BON schema utilisé en
production (colonnes `statement`, `choices` avec `is_correct` intégré,
`max_score`, `active`, etc.).

Mapping :
- (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags)
  → (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation)
- choices : `[{"key":"a","label":"…"},…]` + `correct=["c"]`
  → `[{"id":"a","label":"…","is_correct":false|true},…]`
- tags : `'{tag1,tag2}'` → `ARRAY['tag1','tag2']`
- difficulty : `moyenne` → `moyen`
- max_score = 1, active = true par défaut
"""

import json
import re
import sys
from pathlib import Path

OLD_HEADER = "INSERT INTO public.question_bank (formation_id, source_ref, type, prompt, choices, correct, explanation, difficulty, tags) VALUES"
NEW_HEADER = "INSERT INTO public.question_bank (formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active, explanation) VALUES"

DIFF_MAP = {
    "facile": "facile",
    "moyen": "moyen",
    "moyenne": "moyen",
    "difficile": "difficile",
}


def parse_pg_string(s, pos):
    """Parse une chaîne PG `'…''…'` (apostrophes doublées). Retourne
    (contenu_désechappé, position_après_quote_fermante)."""
    if s[pos] != "'":
        raise ValueError(f"Expected ' at pos {pos}, got {s[pos]!r} (context: {s[pos-20:pos+20]!r})")
    pos += 1
    out = []
    while pos < len(s):
        c = s[pos]
        if c == "'":
            if pos + 1 < len(s) and s[pos + 1] == "'":
                out.append("'")
                pos += 2
                continue
            return "".join(out), pos + 1
        out.append(c)
        pos += 1
    raise ValueError("Unterminated PG string")


def skip_ws(s, pos):
    while pos < len(s) and s[pos] in " \t\n\r":
        pos += 1
    return pos


def skip_ws_comma(s, pos):
    pos = skip_ws(s, pos)
    if pos < len(s) and s[pos] == ",":
        pos += 1
    return skip_ws(s, pos)


def parse_jsonb_value(s, pos):
    """Lit soit `jsonb '…'` soit `'…'::jsonb`. Retourne (contenu_str, position_après)."""
    if s[pos : pos + 5] == "jsonb":
        pos = skip_ws(s, pos + 5)
        content, pos = parse_pg_string(s, pos)
        # éventuel `::jsonb` derrière (improbable mais safe)
        if s[pos : pos + 7] == "::jsonb":
            pos += 7
        return content, pos
    content, pos = parse_pg_string(s, pos)
    if s[pos : pos + 7] == "::jsonb":
        pos += 7
    return content, pos


def parse_tuple(s, pos):
    """Parse un tuple `(v_formation, 'src', 'type', 'stmt', choices, correct, 'expl', 'diff', '{tags}')`.
    Retourne (dict, position_après_paren_fermante)."""
    if s[pos] != "(":
        raise ValueError(f"Expected ( at pos {pos}")
    pos = skip_ws(s, pos + 1)

    # 1. v_formation
    if s[pos : pos + 11] != "v_formation":
        raise ValueError(f"Expected v_formation at pos {pos}, got {s[pos:pos+20]!r}")
    pos = skip_ws_comma(s, pos + 11)

    # 2. source_ref
    source_ref, pos = parse_pg_string(s, pos)
    pos = skip_ws_comma(s, pos)

    # 3. type
    qtype, pos = parse_pg_string(s, pos)
    pos = skip_ws_comma(s, pos)

    # 4. statement
    statement, pos = parse_pg_string(s, pos)
    pos = skip_ws_comma(s, pos)

    # 5. choices (jsonb)
    choices_str, pos = parse_jsonb_value(s, pos)
    pos = skip_ws_comma(s, pos)

    # 6. correct (jsonb)
    correct_str, pos = parse_jsonb_value(s, pos)
    pos = skip_ws_comma(s, pos)

    # 7. explanation
    explanation, pos = parse_pg_string(s, pos)
    pos = skip_ws_comma(s, pos)

    # 8. difficulty
    difficulty, pos = parse_pg_string(s, pos)
    pos = skip_ws_comma(s, pos)

    # 9. tags
    tags_str, pos = parse_pg_string(s, pos)
    pos = skip_ws(s, pos)

    if pos >= len(s) or s[pos] != ")":
        raise ValueError(f"Expected ) at pos {pos}, got {s[pos] if pos < len(s) else 'EOF'!r}")
    pos += 1

    return {
        "source_ref": source_ref,
        "type": qtype,
        "statement": statement,
        "choices_str": choices_str,
        "correct_str": correct_str,
        "explanation": explanation,
        "difficulty": difficulty,
        "tags_str": tags_str,
    }, pos


def pg_escape(s):
    """Double les apostrophes pour insertion en chaîne PG."""
    return s.replace("'", "''")


def parse_tags(tags_str):
    """`'{a,b,c}'` → ['a', 'b', 'c']."""
    inner = tags_str.strip().lstrip("{").rstrip("}")
    if not inner:
        return []
    return [t.strip() for t in inner.split(",") if t.strip()]


def build_new_tuple(t):
    """Construit le nouveau tuple SQL au format BC01-01/02."""
    qtype = t["type"]
    difficulty = DIFF_MAP.get(t["difficulty"].lower(), t["difficulty"])

    tags = parse_tags(t["tags_str"])
    if tags:
        tags_sql = "ARRAY[" + ",".join(f"'{pg_escape(tag)}'" for tag in tags) + "]"
    else:
        tags_sql = "ARRAY[]::text[]"

    if qtype == "qcm":
        old_choices = json.loads(t["choices_str"])
        correct_keys = set(json.loads(t["correct_str"]))
        new_choices = []
        for ch in old_choices:
            key = ch.get("key") or ch.get("id")
            new_choices.append(
                {
                    "id": key,
                    "label": ch["label"],
                    "is_correct": key in correct_keys,
                }
            )
        # JSON compact, sans espace, avec ensure_ascii=False pour garder les accents
        choices_json = json.dumps(new_choices, ensure_ascii=False, separators=(",", ":"))
        choices_sql = f"'{pg_escape(choices_json)}'::jsonb"
    elif qtype == "qr":
        choices_sql = "NULL"
    else:
        raise ValueError(f"Unknown type: {qtype}")

    statement_sql = pg_escape(t["statement"])
    explanation_sql = pg_escape(t["explanation"])
    source_ref_sql = pg_escape(t["source_ref"])

    return (
        f"  (v_formation, '{qtype}', '{statement_sql}', {choices_sql}, 1, "
        f"'{difficulty}', {tags_sql}, '{source_ref_sql}', true, '{explanation_sql}')"
    )


def transform_content(content):
    """Transforme tous les blocs INSERT INTO public.question_bank (... ancien format)."""
    out = []
    pos = 0
    blocks_processed = 0

    while True:
        idx = content.find(OLD_HEADER, pos)
        if idx == -1:
            out.append(content[pos:])
            break

        out.append(content[pos:idx])
        out.append(NEW_HEADER)
        pos = idx + len(OLD_HEADER)
        pos = skip_ws(content, pos)

        new_tuples = []
        while True:
            t, pos = parse_tuple(content, pos)
            new_tuples.append(build_new_tuple(t))
            pos = skip_ws(content, pos)
            if pos < len(content) and content[pos] == ",":
                pos = skip_ws(content, pos + 1)
                continue
            if pos < len(content) and content[pos] == ";":
                pos += 1
                break
            raise ValueError(f"Expected , or ; at pos {pos}")

        out.append("\n" + ",\n".join(new_tuples) + ";\n")
        blocks_processed += 1

    return "".join(out), blocks_processed


def transform_file(path):
    text = Path(path).read_text(encoding="utf-8")
    if OLD_HEADER not in text:
        return False, 0
    new_text, n = transform_content(text)
    Path(path).write_text(new_text, encoding="utf-8")
    return True, n


if __name__ == "__main__":
    files = sys.argv[1:]
    if not files:
        print("Usage: fix_question_bank_schema.py file1.sql [file2.sql ...]")
        sys.exit(1)
    total = 0
    for f in files:
        try:
            changed, n = transform_file(f)
            if changed:
                print(f"✓ {f} : {n} blocs INSERT transformés")
                total += n
            else:
                print(f"- {f} : aucun bloc à transformer (déjà au bon format)")
        except Exception as e:
            print(f"✗ {f} : ERREUR — {e}")
            sys.exit(1)
    print(f"\nTotal : {total} blocs INSERT transformés.")
