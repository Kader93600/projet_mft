import { createClient } from "@/lib/supabase/server";
import { IntroVideoPlayer } from "./intro-video-player";

/**
 * Vidéo d'introduction d'un module — wrapper Server Component.
 *
 * Génère la signed URL Storage côté serveur (privé, 1h) puis délègue
 * l'affichage à un Client Component qui peut gérer onError visiblement
 * (sinon `<video>` HTML5 avale les erreurs silencieusement).
 *
 * Si pas de `videoPath` ou si la signed URL fail → on renvoie `null`
 * (fail-soft, la suite du module reste accessible).
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

  const supabase = await createClient();
  const { data: signed, error } = await supabase.storage
    .from("module-intro-videos")
    .createSignedUrl(videoPath, 60 * 60); // 1h

  if (error || !signed?.signedUrl) {
    if (error) {
      // eslint-disable-next-line no-console
      console.error(
        "[ModuleIntroVideo] createSignedUrl failed:",
        videoPath,
        error.message,
      );
    }
    return null;
  }

  return (
    <IntroVideoPlayer
      signedUrl={signed.signedUrl}
      label={label}
      durationS={durationS}
    />
  );
}
