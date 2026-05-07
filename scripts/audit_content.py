#!/usr/bin/env python3
"""
Audit du contenu pédagogique : retire les tableaux ARRAY[...] qui contiennent
'qcm'/'qr' comme tags, puis compte les vrais types de questions.
"""

import re
from pathlib import Path
from collections import defaultdict

ROOT = Path("/Users/abdelkader/Desktop/projet_gotrm/supabase")

# Mapping module → titre lisible (pour le rapport client)
TITLES = {
    "capa_module_a_v3_dense.sql": "Module A · Cadre juridique",
    "capa_module_b_v3_dense.sql": "Module B · Activité commerciale",
    "capa_module_c_v3_dense.sql": "Module C · Cadre réglementaire transport",
    "capa_module_d_v3_dense.sql": "Module D · Activité financière",
    "capa_module_e_v3_dense.sql": "Module E · Salariés et droit social",
    "capa_module_f_v3_dense.sql": "Module F · Sécurité",
    "gotrm_bc01_01_v3_dense.sql": "BC01-01 · Traiter une demande",
    "gotrm_bc01_02_v2.sql": "BC01-02 · Contrat de transport (CMR)",
    "gotrm_bc01_03_v2.sql": "BC01-03 · Élaborer une cotation",
    "gotrm_bc01_04_v2.sql": "BC01-04 · Réglementation sociale R561/AETR",
    "gotrm_bc01_05_v2.sql": "BC01-05 · Documents et formalités douanières",
    "gotrm_bc01_06_v2.sql": "BC01-06 · Planifier les tournées",
    "gotrm_bc01_07_v2.sql": "BC01-07 · TMD/ADR, ATP, exceptionnel",
    "gotrm_bc01_08_v2.sql": "BC01-08 · Relation client et SLA",
    "gotrm_bc01_09_v2.sql": "BC01-09 · Litiges et indemnisations",
    "gotrm_bc01_10_v2.sql": "BC01-10 · KPI exploitation",
    "gotrm_bc02_01_v2.sql": "BC02-01 · Appel d'offres et sous-traitance",
    "gotrm_bc02_02_v2.sql": "BC02-02 · Suivi qualité et conformité",
    "gotrm_bc03_01_v2.sql": "BC03-01 · Coût de revient",
    "gotrm_bc03_02_v2.sql": "BC03-02 · Démarche RSE et transition",
    "gotrm_module_exploitation.sql": "Module exploitation transport",
    "gotrm_dossier_pro_entretien.sql": "Dossier professionnel · entretien",
    "gotrm_msp_final.sql": "Mise en Situation Professionnelle (MSP)",
    "gotrm_examen_blanc_bc01.sql": "Examen blanc synthétique BC01",
    "gotrm_examen_blanc_bc02.sql": "Examen blanc synthétique BC02",
    "gotrm_examen_blanc_bc03.sql": "Examen blanc synthétique BC03",
}

GROUPS = {
    "Capacité ≤ 3,5 tonnes": [
        "capa_module_a_v3_dense.sql",
        "capa_module_b_v3_dense.sql",
        "capa_module_c_v3_dense.sql",
        "capa_module_d_v3_dense.sql",
        "capa_module_e_v3_dense.sql",
        "capa_module_f_v3_dense.sql",
    ],
    "GOTRM — RNCP 40990 (modules pédagogiques)": [
        "gotrm_bc01_01_v3_dense.sql",
        "gotrm_bc01_02_v2.sql",
        "gotrm_bc01_03_v2.sql",
        "gotrm_bc01_04_v2.sql",
        "gotrm_bc01_05_v2.sql",
        "gotrm_bc01_06_v2.sql",
        "gotrm_bc01_07_v2.sql",
        "gotrm_bc01_08_v2.sql",
        "gotrm_bc01_09_v2.sql",
        "gotrm_bc01_10_v2.sql",
        "gotrm_bc02_01_v2.sql",
        "gotrm_bc02_02_v2.sql",
        "gotrm_bc03_01_v2.sql",
        "gotrm_bc03_02_v2.sql",
        "gotrm_module_exploitation.sql",
        "gotrm_dossier_pro_entretien.sql",
        "gotrm_msp_final.sql",
    ],
    "GOTRM — Examens blancs synthétiques": [
        "gotrm_examen_blanc_bc01.sql",
        "gotrm_examen_blanc_bc02.sql",
        "gotrm_examen_blanc_bc03.sql",
    ],
}


def strip_arrays(text: str) -> str:
    """Retire les ARRAY[...] qui contiennent 'qcm'/'qr' comme tags."""
    # ARRAY['a','b','qcm','c'] → vidé
    return re.sub(r"ARRAY\s*\[[^\]]*\]", "", text)


def count_in_file(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    text_clean = strip_arrays(text)

    lessons = len(re.findall(r"INSERT\s+INTO\s+public\.lessons\s*\(", text, re.I))
    qcm = len(re.findall(r"'qcm'\s*,", text_clean))
    qr = len(re.findall(r"'qr'\s*,", text_clean))

    quiz_inserts = len(re.findall(r"INSERT\s+INTO\s+public\.quizzes\s*\(", text, re.I))
    mock = len(re.findall(r"is_mock_exam[^,)]*?true", text, re.I))
    if mock == 0:
        # Fallback : titres de quiz contenant "Examen"
        mock = len(
            re.findall(
                r"INSERT\s+INTO\s+public\.quizzes[^;]*?'(?:Examen|Mock)\s",
                text,
                re.I | re.DOTALL,
            )
        )
    practice = max(quiz_inserts - mock, 0)

    return {
        "file": path.name,
        "lessons": lessons,
        "qcm": qcm,
        "qr": qr,
        "practice": practice,
        "mock": mock,
    }


def main():
    print()
    grand = defaultdict(int)
    for group_name, names in GROUPS.items():
        files = [ROOT / n for n in names if (ROOT / n).exists()]
        if not files:
            continue
        print(f"### {group_name}\n")
        print(
            f"| {'Module':<48} | {'Leçons':>6} | {'QCM':>4} | {'QR':>3} | {'Entr.':>5} | {'Exam.':>5} |"
        )
        print(
            f"| {'-' * 48} | {'-' * 6} | {'-' * 4} | {'-' * 3} | {'-' * 5} | {'-' * 5} |"
        )
        totals = defaultdict(int)
        for p in files:
            c = count_in_file(p)
            label = TITLES.get(c["file"], c["file"])[:48]
            print(
                f"| {label:<48} | {c['lessons']:>6} | {c['qcm']:>4} | "
                f"{c['qr']:>3} | {c['practice']:>5} | {c['mock']:>5} |"
            )
            for k in ("lessons", "qcm", "qr", "practice", "mock"):
                totals[k] += c[k]
                grand[k] += c[k]
        print(
            f"| **{'TOTAL ' + group_name:<46}** | **{totals['lessons']:>4}** | "
            f"**{totals['qcm']:>2}** | **{totals['qr']:>1}** | "
            f"**{totals['practice']:>3}** | **{totals['mock']:>3}** |"
        )
        print()

    print("### Synthèse globale\n")
    total_questions = grand["qcm"] + grand["qr"]
    total_evals = grand["practice"] + grand["mock"]
    print(f"| Indicateur | Volume |")
    print(f"|---|---|")
    print(f"| Leçons rédigées | **{grand['lessons']}** |")
    print(f"| Questions QCM | **{grand['qcm']}** |")
    print(f"| Questions rédigées (QR) | **{grand['qr']}** |")
    print(f"| **Total questions** | **{total_questions}** |")
    print(f"| Quiz d'entraînement | **{grand['practice']}** |")
    print(f"| Examens blancs | **{grand['mock']}** |")
    print(f"| **Total évaluations** | **{total_evals}** |")


if __name__ == "__main__":
    main()
