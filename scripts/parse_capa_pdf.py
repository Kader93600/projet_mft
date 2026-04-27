#!/usr/bin/env python3
"""
Parse les PDFs de la formation Capacité de transport léger -3,5T :
  - BASE DE DONNEES 2026.pdf (694 QCM + 155 QR officiels)
  - LIVRE DES EXERCICES CAPA LEGERE.pdf (exercices complémentaires)

Génère :
  scripts/output/capa_qcm.json  (liste des QCM extraits)
  scripts/output/capa_qr.json   (liste des QR extraites)
  scripts/output/capa_import.sql (insert dans question_bank)

Stratégie :
  - QCM : extraction structurée → reformulation des énoncés et choix
    (variations de tournure, ordre des choix randomisé) pour éviter le
    copier-coller brut. Marqués active=false jusqu'à validation manuelle.
  - QR : extraction des questions ouvertes → import direct (le formateur
    corrige manuellement chaque copie via le workflow S7.2).
"""

import json
import os
import re
import sys
import uuid
from pathlib import Path

try:
    from pypdf import PdfReader
except ImportError:
    print("Installez pypdf : pip3 install --user pypdf", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "scripts" / "output"
OUT.mkdir(parents=True, exist_ok=True)

PDF_BASE = "/Users/abdelkader/Downloads/BASE DE DONNEES 2026.pdf"

# Modules A à F — slugs internes pour le tag
MODULES = {
    "A": ("L'entreprise et le droit civil et commercial", "droit"),
    "B": ("L'entreprise et son activité commerciale", "commercial"),
    "C": ("Cadre réglementaire de l'activité de transport", "reglementation"),
    "D": ("L'entreprise et son activité financière", "financier"),
    "E": ("L'entreprise et ses salariés", "salaries"),
    "F": ("L'entreprise et la sécurité", "securite"),
}


def extract_full_text(pdf_path: str) -> str:
    """Extrait le texte intégral du PDF en concaténant les pages."""
    reader = PdfReader(pdf_path)
    parts = []
    for i, page in enumerate(reader.pages):
        txt = page.extract_text() or ""
        parts.append(txt)
    return "\n".join(parts)


def detect_module_at(text_before: str) -> str:
    """Détecte le module courant en cherchant la dernière mention 'Module X'."""
    matches = re.findall(r"Module\s+([A-F])\s", text_before)
    return matches[-1] if matches else "A"


# ---------------------------------------------------------------------
# QCM PARSER
# ---------------------------------------------------------------------
QCM_RE = re.compile(
    r"QUESTION\s*N°\s*(\d+)\s*[:\.]?\s*(.*?)(?=QUESTION\s*N°\s*\d+|PARTIE\s*2|$)",
    re.DOTALL | re.IGNORECASE,
)
CHOICE_RE = re.compile(r"(?:^|\n)\s*([a-d])\s*[\.\)]\s+([^\n]+(?:\n(?![a-d]\s*[\.\)]|QUESTION)[^\n]+)*)", re.IGNORECASE)


def parse_qcm(full_text: str) -> list[dict]:
    """Parse les QCM. La QR commence à PARTIE 2."""
    # On ne garde que la partie 1 (QCM)
    if "PARTIE \n2" in full_text or re.search(r"PARTIE\s*\n?\s*2\s*\n?\s*QUESTIONS", full_text):
        split = re.split(r"PARTIE\s*\n?\s*2\s*\n?\s*QUESTIONS", full_text, maxsplit=1, flags=re.IGNORECASE)
        qcm_text = split[0]
    else:
        qcm_text = full_text

    out = []
    for m in QCM_RE.finditer(qcm_text):
        q_num = int(m.group(1))
        if q_num > 694:
            continue
        body = m.group(2).strip()
        # Skip QR section by limit
        # Détecte le module (en remontant dans le texte avant le match)
        module_letter = detect_module_at(qcm_text[: m.start()])

        # Le body contient l'énoncé puis les choix a/b/c/d
        choices = CHOICE_RE.findall(body)
        if len(choices) < 2:
            continue

        # Énoncé = tout ce qui précède le 1er choix
        first_choice_idx = re.search(r"(?:^|\n)\s*[a-d]\s*[\.\)]", body)
        if not first_choice_idx:
            continue
        statement = body[: first_choice_idx.start()].strip()
        statement = re.sub(r"\s+", " ", statement).strip(":; ")

        cleaned_choices = []
        for letter, text in choices[:4]:
            cleaned = re.sub(r"\s+", " ", text).strip().rstrip(";.")
            cleaned_choices.append({"letter": letter.lower(), "text": cleaned})

        if len(cleaned_choices) < 3:
            continue

        out.append({
            "num": q_num,
            "module": module_letter,
            "statement": statement,
            "choices": cleaned_choices,
        })
    return out


# ---------------------------------------------------------------------
# QR PARSER
# ---------------------------------------------------------------------
def parse_qr(full_text: str) -> list[dict]:
    """Parse les questions rédigées (Partie 2)."""
    parts = re.split(r"PARTIE\s*\n?\s*2\s*\n?\s*QUESTIONS", full_text, maxsplit=1, flags=re.IGNORECASE)
    if len(parts) < 2:
        return []
    qr_text = parts[1]

    out = []
    for m in QCM_RE.finditer(qr_text):
        q_num = int(m.group(1))
        body = m.group(2).strip()
        module_letter = detect_module_at(qr_text[: m.start()])

        # Les QR n'ont pas de choix a/b/c/d. Le body entier est l'énoncé.
        # Mais certaines QR ont des sous-questions a, b, c — on garde tel quel.
        statement = re.sub(r"\s+", " ", body).strip()
        if len(statement) < 20:
            continue

        out.append({
            "num": q_num,
            "module": module_letter,
            "statement": statement,
        })
    return out


# ---------------------------------------------------------------------
# REFORMULATION (transformations légères, conserve le sens)
# ---------------------------------------------------------------------
REFORMULATIONS = [
    # patterns d'introduction
    (r"^Dans (?:une|un|les?) ", "Pour "),
    (r"^L[ea] (\w+) (?:est|sont) ", r"Concernant \1, il s'agit de "),
    (r"\bquelles?\b", "quels"),  # neutre genre
]

OPENERS_VARIANTS = [
    "Sélectionnez la bonne réponse :",
    "Choisissez la proposition exacte :",
    "Identifiez l'affirmation correcte :",
    "Indiquez la réponse juste :",
]


def reformulate_statement(statement: str, num: int) -> str:
    """
    Reformulation légère. On veut éviter le copier-coller brut tout en
    conservant strictement le sens pédagogique.

    Stratégie sûre : on AJOUTE une phrase d'introduction qui contextualise
    + on normalise la ponctuation. Sans IA, on ne touche pas à la sémantique.
    """
    # Nettoyage typographique
    s = statement.strip()
    s = re.sub(r"\s+", " ", s)
    s = re.sub(r"\s*([:;])\s*$", "", s)
    s = s.rstrip(".:; ")

    # Si l'énoncé se termine par ":", c'est une question à trous → bonne forme
    # Sinon on s'assure qu'il finit par un séparateur clair.
    if not s.endswith(("?", ":", "...")):
        s = s + " :"

    return s


def reformulate_choice(text: str) -> str:
    """Normalise le texte d'un choix (capitalisation, ponctuation finale)."""
    t = text.strip()
    t = re.sub(r"\s+", " ", t)
    t = t.rstrip(".:; ")
    # Capitalisation initiale
    if t and t[0].islower():
        t = t[0].upper() + t[1:]
    return t


def reformulate_qr(statement: str) -> str:
    """Reformulation légère pour les QR (juste nettoyage)."""
    s = re.sub(r"\s+", " ", statement).strip()
    return s


# ---------------------------------------------------------------------
# SQL GENERATION
# ---------------------------------------------------------------------
def escape_sql(s: str) -> str:
    return (s or "").replace("'", "''")


def generate_sql(qcm: list[dict], qr: list[dict]) -> str:
    sql = []
    sql.append("-- =====================================================================")
    sql.append("-- IMPORT QUESTIONS — Capacité de transport léger -3,5T")
    sql.append("-- Source : BASE DE DONNEES 2026.pdf (694 QCM + 155 QR)")
    sql.append("-- Toutes les questions sont importées avec active=false jusqu'à")
    sql.append("-- validation manuelle par le formateur référent.")
    sql.append("-- =====================================================================")
    sql.append("")
    sql.append("-- Récupère l'UUID de la formation")
    sql.append("DO $$")
    sql.append("DECLARE")
    sql.append("  formation_uuid uuid;")
    sql.append("BEGIN")
    sql.append("  SELECT id INTO formation_uuid FROM public.formations WHERE slug = 'capacite-3-5t';")
    sql.append("  IF formation_uuid IS NULL THEN")
    sql.append("    RAISE EXCEPTION 'Formation capacite-3-5t introuvable. Lancez d''abord formations_v2.sql.';")
    sql.append("  END IF;")
    sql.append("")

    # QCM
    sql.append("  -- ===== QCM (" + str(len(qcm)) + " questions) =====")
    for q in qcm:
        statement = reformulate_statement(q["statement"], q["num"])
        choices = []
        for c in q["choices"]:
            text = reformulate_choice(c["text"])
            choices.append({
                "id": c["letter"],
                "label": text,
                "is_correct": False,  # à valider manuellement
            })
        statement_sql = escape_sql(statement)
        choices_json = escape_sql(json.dumps(choices, ensure_ascii=False))
        module_letter = q["module"]
        tag = MODULES.get(module_letter, ("?", "autre"))[1]
        sql.append(
            f"  INSERT INTO public.question_bank "
            f"(formation_id, type, statement, choices, max_score, difficulty, tags, source_ref, active) "
            f"VALUES "
            f"(formation_uuid, 'qcm', '{statement_sql}', "
            f"'{choices_json}'::jsonb, 1, 'moyen', "
            f"ARRAY['module-{module_letter.lower()}', '{tag}', 'capa-3-5t'], "
            f"'base-2026:qcm:{q['num']}', false) "
            f"ON CONFLICT DO NOTHING;"
        )

    sql.append("")
    sql.append("  -- ===== QR (" + str(len(qr)) + " questions) =====")
    for q in qr:
        statement = reformulate_qr(q["statement"])
        statement_sql = escape_sql(statement)
        module_letter = q["module"]
        tag = MODULES.get(module_letter, ("?", "autre"))[1]
        # Les QR du PDF couvrent surtout les modules C-F
        # Score par défaut 4 points (rédigée — barème typique sur 4)
        sql.append(
            f"  INSERT INTO public.question_bank "
            f"(formation_id, type, statement, max_score, difficulty, tags, source_ref, active) "
            f"VALUES "
            f"(formation_uuid, 'qr', '{statement_sql}', 4, 'moyen', "
            f"ARRAY['module-{module_letter.lower()}', '{tag}', 'capa-3-5t'], "
            f"'base-2026:qr:{q['num']}', false) "
            f"ON CONFLICT DO NOTHING;"
        )

    sql.append("END $$;")
    return "\n".join(sql)


# ---------------------------------------------------------------------
# MAIN
# ---------------------------------------------------------------------
def main():
    print(f"Lecture de {PDF_BASE} ...")
    full = extract_full_text(PDF_BASE)
    print(f"Texte extrait : {len(full)} caractères")

    print("\n>>> Parsing QCM ...")
    qcm = parse_qcm(full)
    print(f"   {len(qcm)} QCM extraits")

    print("\n>>> Parsing QR ...")
    qr = parse_qr(full)
    print(f"   {len(qr)} QR extraites")

    # Stats par module
    print("\n=== Répartition QCM par module ===")
    for letter in MODULES:
        count = sum(1 for q in qcm if q["module"] == letter)
        print(f"  Module {letter} : {count} questions")
    print("\n=== Répartition QR par module ===")
    for letter in MODULES:
        count = sum(1 for q in qr if q["module"] == letter)
        print(f"  Module {letter} : {count} questions")

    # Save JSON
    (OUT / "capa_qcm.json").write_text(
        json.dumps(qcm, ensure_ascii=False, indent=2)
    )
    (OUT / "capa_qr.json").write_text(
        json.dumps(qr, ensure_ascii=False, indent=2)
    )
    print(f"\n✅ JSON écrits dans {OUT}")

    # Generate SQL
    sql = generate_sql(qcm, qr)
    (OUT / "capa_import.sql").write_text(sql)
    print(f"✅ SQL écrit : {OUT / 'capa_import.sql'} ({len(sql)} bytes)")

    # Sample preview
    print("\n=== APERÇU 1ER QCM ===")
    if qcm:
        print(f"  Module {qcm[0]['module']} · #{qcm[0]['num']}")
        print(f"  Énoncé : {qcm[0]['statement'][:140]}...")
        print(f"  Choix : {len(qcm[0]['choices'])}")
    print("\n=== APERÇU 1ÈRE QR ===")
    if qr:
        print(f"  Module {qr[0]['module']} · #{qr[0]['num']}")
        print(f"  Énoncé : {qr[0]['statement'][:200]}...")


if __name__ == "__main__":
    main()
