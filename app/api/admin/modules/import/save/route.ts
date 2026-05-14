// =====================================================================
// POST /api/admin/modules/import/save
//
// Reçoit le draft édité côté UI et crée en DB :
//   - 1 module par chapitre (table modules, rattaché à un bloc)
//   - 1 leçon par sous-section (table lessons.content_md = HTML rich)
//   - Lien formation_modules pour rattacher à la formation
//
// Sanitize server-side du HTML rich-text avant INSERT (defense in depth).
// =====================================================================

import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { requireAdmin } from "@/lib/admin-guard";
import { formatZodError } from "@/lib/validations";
import { isRichTextHtml, sanitizeRichTextServer } from "@/lib/rich-text";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";
export const maxDuration = 60;

const lessonSchema = z.object({
  ref: z.string().trim().max(10),
  title: z.string().trim().min(2).max(200),
  content_html: z.string().min(1).max(80_000),
});

const chapterSchema = z.object({
  number: z.number().int().min(1).max(99),
  title: z.string().trim().min(2).max(200),
  slug: z.string().trim().min(2).max(80),
  /** Résumé court (1-2 phrases) — généré côté UI ou laissé null. */
  summary: z.string().trim().max(500).optional().nullable(),
  /** Durée totale estimée du chapitre (somme des leçons). */
  duration_min: z.number().int().min(5).max(600).default(60),
  lessons: z.array(lessonSchema).min(1).max(40),
});

const payloadSchema = z.object({
  formation_slug: z.string().trim().min(2),
  bloc_code: z.string().trim().min(2).max(10), // BC1, BC2, BC3
  chapters: z.array(chapterSchema).min(1).max(20),
});

export async function POST(req: NextRequest) {
  try {
    const { supabase, admin } = await requireAdmin();

    const body = await req.json();
    const parsed = payloadSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: formatZodError(parsed.error) },
        { status: 400 },
      );
    }
    const { formation_slug, bloc_code, chapters } = parsed.data;

    // 1. Récupère le bloc + la formation cibles
    const { data: bloc } = await supabase
      .from("blocs")
      .select("id, code")
      .eq("code", bloc_code)
      .maybeSingle();
    if (!bloc) {
      return NextResponse.json(
        { error: `bloc_not_found:${bloc_code}` },
        { status: 404 },
      );
    }
    const { data: formation } = await supabase
      .from("formations")
      .select("id, slug")
      .eq("slug", formation_slug)
      .maybeSingle();
    if (!formation) {
      return NextResponse.json(
        { error: `formation_not_found:${formation_slug}` },
        { status: 404 },
      );
    }

    const insertedModules: Array<{
      id: string;
      slug: string;
      number: number;
      lessonsCount: number;
    }> = [];

    // 2. Pour chaque chapitre : crée le module + ses leçons
    for (const chapter of chapters) {
      // Module
      const { data: moduleRow, error: modErr } = await supabase
        .from("modules")
        .insert({
          bloc_id: bloc.id,
          slug: chapter.slug,
          title: chapter.title,
          summary: chapter.summary ?? null,
          difficulty: "debutant",
          duration_min: chapter.duration_min,
          order: chapter.number,
        })
        .select("id, slug")
        .single();
      if (modErr) {
        return NextResponse.json(
          {
            error: "module_insert_failed",
            details: modErr.message,
            chapter: chapter.number,
            inserted_so_far: insertedModules.length,
          },
          { status: 500 },
        );
      }

      // Rattachement formation_modules
      const { error: linkErr } = await supabase
        .from("formation_modules")
        .insert({
          formation_id: formation.id,
          module_id: moduleRow.id,
          display_order: chapter.number,
          required: true,
        });
      if (linkErr && !linkErr.message.toLowerCase().includes("duplicate")) {
        // Non bloquant : log mais continue
        // eslint-disable-next-line no-console
        console.warn(
          "[modules/import/save] formation_modules link failed:",
          linkErr.message,
        );
      }

      // Leçons (bulk insert)
      const lessonRows = chapter.lessons.map((l, i) => {
        // Sanitize HTML defense in depth
        const cleanHtml = isRichTextHtml(l.content_html)
          ? sanitizeRichTextServer(l.content_html)
          : l.content_html;
        return {
          module_id: moduleRow.id,
          slug: `${l.ref.replace(".", "-")}-${slugify(l.title)}`.slice(0, 80),
          title: l.title,
          content_md: cleanHtml,
          order: i + 1,
        };
      });
      const { error: lessonsErr, data: lessonsInserted } = await supabase
        .from("lessons")
        .insert(lessonRows)
        .select("id");
      if (lessonsErr) {
        return NextResponse.json(
          {
            error: "lessons_insert_failed",
            details: lessonsErr.message,
            chapter: chapter.number,
          },
          { status: 500 },
        );
      }

      insertedModules.push({
        id: moduleRow.id,
        slug: moduleRow.slug,
        number: chapter.number,
        lessonsCount: lessonsInserted?.length ?? 0,
      });
    }

    return NextResponse.json({
      ok: true,
      chapters: insertedModules,
      total_lessons: insertedModules.reduce(
        (s, c) => s + c.lessonsCount,
        0,
      ),
      formation_slug,
      bloc_code,
    });
  } catch (e: any) {
    // eslint-disable-next-line no-console
    console.error("[modules/import/save] error:", e);
    return NextResponse.json(
      { error: e?.message ?? "unknown_error" },
      { status: 500 },
    );
  }
}

function slugify(s: string): string {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "")
    .slice(0, 40);
}
