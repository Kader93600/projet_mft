"use client";

import { useEffect, useRef, useState } from "react";
import { PlayCircle, Clock, AlertTriangle } from "lucide-react";

/**
 * Player vidéo Client Component avec gestion d'erreur visible.
 *
 * Le `<video>` HTML5 standard avale les erreurs silencieusement par
 * défaut (écran noir, 0:00). On ajoute :
 *   - onError sur l'élément <video>
 *   - log explicite en console + état d'erreur visible côté UI
 *   - tentative de reload automatique avec load() une fois
 *
 * Le composant reçoit une signed URL pré-générée côté Server.
 */
export function IntroVideoPlayer({
  signedUrl,
  label,
  durationS,
}: {
  signedUrl: string;
  label: string | null;
  durationS: number | null;
}) {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [debugInfo, setDebugInfo] = useState<string>("");
  const reloadedRef = useRef(false);

  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;
    // Charge explicitement les métadonnées au mount.
    v.load();
  }, [signedUrl]);

  const minutes =
    typeof durationS === "number" && durationS > 0
      ? Math.max(1, Math.round(durationS / 60))
      : null;

  const handleError = (e: React.SyntheticEvent<HTMLVideoElement, Event>) => {
    const v = e.currentTarget;
    const code = v.error?.code;
    const message = v.error?.message ?? "";
    const codeName =
      code === 1
        ? "MEDIA_ERR_ABORTED"
        : code === 2
          ? "MEDIA_ERR_NETWORK"
          : code === 3
            ? "MEDIA_ERR_DECODE"
            : code === 4
              ? "MEDIA_ERR_SRC_NOT_SUPPORTED"
              : "UNKNOWN";
    const networkState = v.networkState;
    const readyState = v.readyState;
    const info = `code=${code} (${codeName}) networkState=${networkState} readyState=${readyState} src=${v.currentSrc?.slice(0, 80)}…`;
    // eslint-disable-next-line no-console
    console.error("[IntroVideoPlayer] erreur lecture :", info, message);
    setDebugInfo(info);

    // Auto-retry une fois (peut résoudre un glitch réseau initial)
    if (!reloadedRef.current) {
      reloadedRef.current = true;
      // eslint-disable-next-line no-console
      console.info("[IntroVideoPlayer] tentative de reload…");
      setTimeout(() => v.load(), 250);
      return;
    }

    setErrorMsg(
      codeName === "MEDIA_ERR_SRC_NOT_SUPPORTED"
        ? "Format vidéo non supporté par votre navigateur."
        : codeName === "MEDIA_ERR_NETWORK"
          ? "Erreur réseau lors du chargement de la vidéo."
          : codeName === "MEDIA_ERR_DECODE"
            ? "Erreur de décodage vidéo."
            : "Impossible de lire la vidéo.",
    );
  };

  const handleLoadedMetadata = () => {
    // eslint-disable-next-line no-console
    console.info("[IntroVideoPlayer] métadonnées chargées OK");
    setErrorMsg(null);
  };

  return (
    <section
      aria-label="Vidéo d'introduction au module"
      className="relative overflow-hidden rounded-3xl border border-navy-100 bg-night-950 shadow-soft dark:border-[hsl(var(--border))]"
    >
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
        NE PAS mettre `crossOrigin="anonymous"` ici : Supabase Storage
        signed URL renvoie bien `Access-Control-Allow-Origin: *` mais
        pas tous les headers CORS étendus exigés par ce mode, ce qui
        fait rejeter la source avec MEDIA_ERR_SRC_NOT_SUPPORTED.
        Sans crossOrigin, le browser charge la URL en mode "no-cors"
        et la lit sans souci (le streaming Range marche).
      */}
      <video
        ref={videoRef}
        src={signedUrl}
        controls
        controlsList="nodownload"
        preload="auto"
        playsInline
        onError={handleError}
        onLoadedMetadata={handleLoadedMetadata}
        className="block aspect-video w-full bg-night-950"
      >
        Votre navigateur ne supporte pas la lecture vidéo HTML5.
      </video>

      {errorMsg && (
        <div className="border-t border-rose-200 bg-rose-50 px-5 py-3 text-sm text-rose-900">
          <div className="font-semibold inline-flex items-center gap-2">
            <AlertTriangle className="h-4 w-4" />
            {errorMsg}
          </div>
          {debugInfo && (
            <details className="mt-2 text-xs text-rose-700">
              <summary className="cursor-pointer">Détails techniques</summary>
              <code className="mt-1 block break-all">{debugInfo}</code>
            </details>
          )}
        </div>
      )}

      {label && !errorMsg && (
        <div className="border-t border-white/10 bg-night-900 px-5 py-3 text-sm text-white/80">
          {label}
        </div>
      )}
    </section>
  );
}
