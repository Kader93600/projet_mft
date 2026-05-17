import { createClient } from "@/lib/supabase/server";
import { PlayCircle, Clock } from "lucide-react";

/**
 * Vidéo d'introduction d'un module — Server Component.
 *
 * Affiche un player HTML5 natif en haut du détail module, avec une signed
 * URL Storage (privée, valable 1h). Si le module n'a pas de
 * `intro_video_path`, le composant renvoie `null` (rien ne s'affiche).
 *
 * Style : aspect-vidéo 16:9, contrôles natifs, poster Navy si pas de
 * preview généré, bandeau gold avec libellé + durée.
 *
 * Sécurité : la signed URL est régénérée à chaque chargement de page,
 * la valeur n'est jamais cachée côté CDN. Le bucket Storage est privé
 * et son accès est gating par RLS (cf. migration 2026_05_17).
 */
export async function ModuleIntroVideo({
  videoPath,
  label,
  durationS,
}: {
  videoPath: string | null;
  label: string | null;
  durationS: number | null;
}) {
  if (!videoPath) return null;

  const supabase = createClient();
  const { data: signed, error } = await supabase.storage
    .from("module-intro-videos")
    .createSignedUrl(videoPath, 60 * 60); // 1h

  if (error || !signed?.signedUrl) {
    // Fail-soft : on n'affiche rien plutôt que d'exposer une erreur 500
    // (la suite du module reste accessible).
    return null;
  }

  const minutes =
    typeof durationS === "number" && durationS > 0
      ? Math.max(1, Math.round(durationS / 60))
      : null;

  return (
    <section
      aria-label="Vidéo d'introduction au module"
      className="relative overflow-hidden rounded-3xl border border-navy-100 bg-night-950 shadow-soft dark:border-[hsl(var(--border))]"
    >
      {/* Bandeau eyebrow */}
      <div className="absolute top-3 left-3 z-10 flex items-center gap-1.5 rounded-full bg-gold-500 px-2.5 py-1 text-[10px] font-semibold uppercase tracking-[0.18em] text-navy-900 shadow-soft">
        <PlayCircle className="h-3 w-3" />
        Intro vidéo
      </div>

      {minutes !== null && (
        <div className="absolute top-3 right-3 z-10 inline-flex items-center gap-1 rounded-full bg-black/55 px-2.5 py-1 text-[11px] font-medium text-white backdrop-blur">
          <Clock className="h-3 w-3" />
          {minutes} min
        </div>
      )}

      {/*
        Note : on met `src` directement sur <video> au lieu d'utiliser un
        <source> enfant. Avec <source>, certains browsers refusent de
        charger les métadonnées avant un play explicite, ce qui rend la
        vidéo "noire" tant qu'on n'a pas cliqué — comportement observé
        en prod sur Chrome avec preload="metadata" + <source>.
      */}
      <video
        src={signed.signedUrl}
        controls
        controlsList="nodownload"
        preload="metadata"
        playsInline
        className="block aspect-video w-full bg-night-950"
      >
        Votre navigateur ne supporte pas la lecture vidéo HTML5.
      </video>

      {label && (
        <div className="border-t border-white/10 bg-night-900 px-5 py-3 text-sm text-white/80">
          {label}
        </div>
      )}
    </section>
  );
}
