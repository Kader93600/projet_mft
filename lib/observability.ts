// Wrapper minimal d'observabilité.
// - Si Sentry est installé (@sentry/nextjs) ET NEXT_PUBLIC_SENTRY_DSN est défini,
//   les évènements y sont envoyés.
// - Sinon : POST direct vers l'API Sentry "store" via fetch (compatible serverless).
// - Sinon : console fallback.

type Sev = "fatal" | "error" | "warning" | "info" | "debug";

interface CaptureOptions {
  level?: Sev;
  user?: { id?: string; email?: string };
  tags?: Record<string, string>;
  extra?: Record<string, unknown>;
}

const DSN = process.env.NEXT_PUBLIC_SENTRY_DSN;
const ENV = process.env.SENTRY_ENVIRONMENT || process.env.NODE_ENV || "development";

function parseDsn(dsn: string) {
  // ex : https://PUBLIC_KEY@o123.ingest.sentry.io/PROJECT_ID
  const m = dsn.match(/^https:\/\/([^@]+)@([^/]+)\/(\d+)$/);
  if (!m) return null;
  return { publicKey: m[1], host: m[2], projectId: m[3] };
}

async function sendToSentry(payload: any) {
  if (!DSN) return;
  const parsed = parseDsn(DSN);
  if (!parsed) return;
  const url = `https://${parsed.host}/api/${parsed.projectId}/store/`;
  try {
    await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Sentry-Auth":
          `Sentry sentry_version=7, sentry_key=${parsed.publicKey}, ` +
          `sentry_client=ma-formation-transport/1.0`,
      },
      body: JSON.stringify(payload),
      cache: "no-store",
    });
  } catch {
    // ne casse jamais l'app si Sentry est down
  }
}

export async function captureException(err: unknown, opts: CaptureOptions = {}) {
  const level: Sev = opts.level ?? "error";
  const e = err instanceof Error ? err : new Error(String(err));

  // Si le SDK Sentry global est dispo (client), on l'utilise
  try {
    // @ts-expect-error injection runtime
    const S = typeof window !== "undefined" ? window.Sentry : undefined;
    if (S?.captureException) {
      S.captureException(e, { level, tags: opts.tags, extra: opts.extra });
      return;
    }
  } catch {}

  if (DSN) {
    await sendToSentry({
      event_id: crypto.randomUUID().replace(/-/g, ""),
      timestamp: new Date().toISOString(),
      platform: "javascript",
      level,
      environment: ENV,
      user: opts.user,
      tags: opts.tags,
      extra: opts.extra,
      exception: {
        values: [
          {
            type: e.name,
            value: e.message,
            stacktrace: e.stack
              ? {
                  frames: e.stack
                    .split("\n")
                    .slice(1)
                    .map((line) => ({ filename: line.trim() })),
                }
              : undefined,
          },
        ],
      },
    });
    return;
  }

  // Fallback dev
  // eslint-disable-next-line no-console
  console.error(`[${level}]`, e, opts);
}

export async function captureMessage(message: string, opts: CaptureOptions = {}) {
  const level: Sev = opts.level ?? "info";
  if (DSN) {
    await sendToSentry({
      event_id: crypto.randomUUID().replace(/-/g, ""),
      timestamp: new Date().toISOString(),
      platform: "javascript",
      level,
      environment: ENV,
      message: { formatted: message },
      tags: opts.tags,
      extra: opts.extra,
      user: opts.user,
    });
    return;
  }
  // eslint-disable-next-line no-console
  console.log(`[${level}]`, message, opts);
}
