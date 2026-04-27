// Player vidéo : détecte YouTube/Vimeo → iframe ; sinon <video>
export function LessonVideo({ url, title }: { url: string; title?: string }) {
  const embed = toEmbedUrl(url);
  if (embed) {
    return (
      <div className="relative overflow-hidden rounded-2xl border border-navy-100 shadow-soft aspect-video bg-navy-950">
        <iframe
          src={embed}
          title={title ?? "Vidéo de la leçon"}
          loading="lazy"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
          className="absolute inset-0 w-full h-full"
        />
      </div>
    );
  }
  return (
    <div className="rounded-2xl overflow-hidden border border-navy-100 shadow-soft bg-black">
      <video
        src={url}
        controls
        preload="metadata"
        className="w-full aspect-video"
      />
    </div>
  );
}

function toEmbedUrl(raw: string): string | null {
  try {
    const u = new URL(raw);
    // YouTube
    if (u.hostname.includes("youtu.be")) {
      const id = u.pathname.slice(1);
      if (id) return `https://www.youtube.com/embed/${id}`;
    }
    if (u.hostname.includes("youtube.com")) {
      if (u.pathname === "/watch") {
        const id = u.searchParams.get("v");
        if (id) return `https://www.youtube.com/embed/${id}`;
      }
      if (u.pathname.startsWith("/embed/")) return u.toString();
    }
    // Vimeo
    if (u.hostname.includes("vimeo.com")) {
      const id = u.pathname.split("/").filter(Boolean)[0];
      if (id && /^\d+$/.test(id)) return `https://player.vimeo.com/video/${id}`;
    }
    return null;
  } catch {
    return null;
  }
}
