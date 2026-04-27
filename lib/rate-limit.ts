// Rate-limiter sliding window minimal.
// - Mode "memory" par défaut : suffisant pour 1 instance / dev.
// - Mode "upstash" si UPSTASH_REDIS_REST_URL est défini : utilisable derrière
//   un déploiement multi-instance (Vercel Edge / Serverless).
//
// Usage :
//
//   const { ok, remaining, reset } = await rateLimit({
//     key: `login:${ip}`, limit: 5, windowSec: 60,
//   });
//   if (!ok) return new Response("Too Many Requests", { status: 429, ... });

type Result = { ok: boolean; remaining: number; reset: number };

const memoryStore = new Map<string, { count: number; resetAt: number }>();

function memoryLimit(key: string, limit: number, windowSec: number): Result {
  const now = Date.now();
  const ttlMs = windowSec * 1000;
  const e = memoryStore.get(key);
  if (!e || e.resetAt < now) {
    memoryStore.set(key, { count: 1, resetAt: now + ttlMs });
    return { ok: true, remaining: limit - 1, reset: now + ttlMs };
  }
  e.count += 1;
  if (e.count > limit) {
    return { ok: false, remaining: 0, reset: e.resetAt };
  }
  return { ok: true, remaining: limit - e.count, reset: e.resetAt };
}

async function upstashLimit(
  key: string,
  limit: number,
  windowSec: number
): Promise<Result> {
  const url = process.env.UPSTASH_REDIS_REST_URL!;
  const token = process.env.UPSTASH_REDIS_REST_TOKEN!;
  // Pipeline : INCR + EXPIRE (NX) en une requête
  const res = await fetch(`${url}/pipeline`, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify([
      ["INCR", key],
      ["EXPIRE", key, String(windowSec), "NX"],
      ["PTTL", key],
    ]),
    cache: "no-store",
  });
  if (!res.ok) {
    // Si Upstash est down, on n'ouvre pas grand : on bloque par sécurité ? Non,
    // on laisse passer pour ne pas couper la prod. Logger l'incident.
    console.error("[rateLimit] Upstash error", res.status);
    return { ok: true, remaining: limit, reset: Date.now() + windowSec * 1000 };
  }
  const data = (await res.json()) as Array<{ result: number }>;
  const count = Number(data[0]?.result ?? 0);
  const pttl = Number(data[2]?.result ?? windowSec * 1000);
  return {
    ok: count <= limit,
    remaining: Math.max(0, limit - count),
    reset: Date.now() + (pttl > 0 ? pttl : windowSec * 1000),
  };
}

export async function rateLimit(opts: {
  key: string;
  limit: number;
  windowSec: number;
}): Promise<Result> {
  const useUpstash =
    !!process.env.UPSTASH_REDIS_REST_URL &&
    !!process.env.UPSTASH_REDIS_REST_TOKEN;
  return useUpstash
    ? upstashLimit(opts.key, opts.limit, opts.windowSec)
    : memoryLimit(opts.key, opts.limit, opts.windowSec);
}

export function rateLimitHeaders(r: Result, limit: number) {
  return {
    "X-RateLimit-Limit": String(limit),
    "X-RateLimit-Remaining": String(r.remaining),
    "X-RateLimit-Reset": String(Math.ceil(r.reset / 1000)),
    "Retry-After": String(Math.max(1, Math.ceil((r.reset - Date.now()) / 1000))),
  };
}

// Helper : extrait l'IP depuis les headers Vercel / Cloudflare / standard.
export function clientIp(headers: Headers): string {
  return (
    headers.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    headers.get("x-real-ip") ||
    headers.get("cf-connecting-ip") ||
    "anon"
  );
}
