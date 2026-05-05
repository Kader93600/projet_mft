#!/usr/bin/env python3
"""
Aligne les INSERT quizzes et quiz_question_bank des fichiers GOTRM
sur le vrai schéma de production.

Transforme :
- INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description,
                              pass_threshold, time_limit_min, is_mock_exam, "order")
  VALUES (v_module, v_lesson_X | NULL, 'TITLE', 'SLUG', 'DESC',
          PASS, MIN | NULL, BOOL, N)
  → INSERT INTO public.quizzes (module_id, title, description, type,
                                time_limit_s, pass_threshold)
    VALUES (v_module, 'TITLE', 'DESC', 'entrainement' | 'examen_blanc',
            MIN*60 | NULL, PASS)

- INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")
  → INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)
"""

import re
import sys
from pathlib import Path


# Header marker to spot the start of an old-format INSERT
QUIZ_HEADER_OLD = 'INSERT INTO public.quizzes (module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, "order")'


def parse_pg_string(s, pos):
    if s[pos] != "'":
        raise ValueError(f"Expected ' at pos {pos}")
    pos += 1
    out = []
    while pos < len(s):
        c = s[pos]
        if c == "'":
            if pos + 1 < len(s) and s[pos + 1] == "'":
                out.append("''")
                pos += 2
                continue
            return ("'" + "".join(out) + "'", pos + 1)
        out.append(c)
        pos += 1
    raise ValueError("Unterminated PG string")


def parse_quiz_values(values_str):
    """Parse les 9 valeurs du tuple VALUES (séparées par virgules, avec respect des chaînes)."""
    pos = 0
    s = values_str.strip()
    parts = []
    current = []
    depth = 0
    while pos < len(s):
        c = s[pos]
        if c == "'":
            string, new_pos = parse_pg_string(s, pos)
            current.append(string)
            pos = new_pos
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
        if c == "," and depth == 0:
            parts.append("".join(current).strip())
            current = []
            pos += 1
            continue
        current.append(c)
        pos += 1
    if current:
        parts.append("".join(current).strip())
    return parts


def transform_quiz_block(values_str, var_name):
    parts = parse_quiz_values(values_str)
    if len(parts) != 9:
        raise ValueError(f"Expected 9 values, got {len(parts)}: {parts}")

    module_id, lesson_id, title, slug, description, pass_threshold, time_limit_min, is_mock_exam, order_n = parts

    # Map is_mock_exam → type
    if is_mock_exam.strip() == "true":
        quiz_type = "'examen'"
    else:
        quiz_type = "'entrainement'"

    # Map time_limit_min → time_limit_s
    tlm = time_limit_min.strip()
    if tlm.upper() == "NULL":
        time_limit_s = "NULL"
    else:
        try:
            mins = int(tlm)
            time_limit_s = str(mins * 60)
        except ValueError:
            time_limit_s = tlm  # garde tel quel si non numérique

    return (
        f"INSERT INTO public.quizzes (module_id, title, description, type, time_limit_s, pass_threshold)\n"
        f"  VALUES ({module_id}, {title}, {description}, {quiz_type}, {time_limit_s}, {pass_threshold})\n"
        f"  RETURNING id INTO {var_name};"
    )


def find_paren_balanced(text, start):
    """À partir de start (qui pointe sur '('), retourne la position de la
    parenthèse fermante équilibrée, en gérant les chaînes PG."""
    assert text[start] == "("
    pos = start + 1
    depth = 1
    while pos < len(text):
        c = text[pos]
        if c == "'":
            _, pos = parse_pg_string(text, pos)
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return pos
        pos += 1
    raise ValueError("Unbalanced parens")


def transform_file(path):
    text = Path(path).read_text(encoding="utf-8")
    original = text
    out = []
    pos = 0

    while True:
        idx = text.find(QUIZ_HEADER_OLD, pos)
        if idx == -1:
            out.append(text[pos:])
            break

        out.append(text[pos:idx])
        pos = idx + len(QUIZ_HEADER_OLD)

        # Skip whitespace and find VALUES
        while pos < len(text) and text[pos] in " \t\n\r":
            pos += 1
        if not text[pos:pos + 6] == "VALUES":
            raise ValueError(f"Expected VALUES at pos {pos}")
        pos += 6
        while pos < len(text) and text[pos] in " \t\n\r":
            pos += 1
        if text[pos] != "(":
            raise ValueError(f"Expected ( at pos {pos}")

        # Find balanced closing paren
        end_paren = find_paren_balanced(text, pos)
        values_str = text[pos + 1:end_paren]

        # Find RETURNING id INTO <var>;
        after = text[end_paren + 1:]
        m = re.match(r"\s*RETURNING id INTO (\w+);", after)
        if not m:
            raise ValueError(f"Expected RETURNING id INTO ...; after pos {end_paren}")
        var_name = m.group(1)

        new_block = transform_quiz_block(values_str, var_name)
        out.append(new_block)
        pos = end_paren + 1 + m.end()

    text = "".join(out)

    # 2. Transform quiz_question_bank "order" → display_order
    text = text.replace(
        'INSERT INTO public.quiz_question_bank (quiz_id, question_id, "order")',
        "INSERT INTO public.quiz_question_bank (quiz_id, question_id, display_order)",
    )

    if text != original:
        Path(path).write_text(text, encoding="utf-8")
        return True
    return False


if __name__ == "__main__":
    files = sys.argv[1:]
    if not files:
        print("Usage: fix_quizzes_schema.py file1.sql [file2.sql ...]")
        sys.exit(1)
    for f in files:
        try:
            changed = transform_file(f)
            print(f"{'✓' if changed else '-'} {f}")
        except Exception as e:
            print(f"✗ {f} : {e}")
            sys.exit(1)
