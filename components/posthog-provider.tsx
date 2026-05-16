"use client";

// =====================================================================
// PostHogProvider — initialise PostHog côté client une seule fois,
// gère les pageviews automatiques sur changement de route App Router,
// et identifie l'utilisateur si un profil est fourni.
//
// À placer dans le layout authentifié (AuthLayout) pour avoir le user
// directement identifié dès le mount.
// =====================================================================

import { useEffect, Suspense } from "react";
import { usePathname, useSearchParams } from "next/navigation";
import posthog from "posthog-js";
import { identifyUser } from "@/lib/analytics";

const KEY = process.env.NEXT_PUBLIC_POSTHOG_KEY;
// API host : on utilise notre PROXY interne /ingest (rewrites Next.js) au
// lieu de eu.i.posthog.com directement → bypass des ad-blockers.
// Le ui_host pointe toujours vers PostHog pour que les liens dans la
// session toolbar et les replays cliquent vers eu.posthog.com.
const TUNNEL_HOST = "/ingest";
const UI_HOST = "https://eu.posthog.com";

interface PostHogProviderProps {
  children: React.ReactNode;
  profile?: {
    id: string;
    email: string;
    role: string;
    full_name?: string | null;
    active_formation_slug?: string | null;
  } | null;
}

export function PostHogProvider({ children, profile }: PostHogProviderProps) {
  // Init PostHog une seule fois au mount du provider
  useEffect(() => {
    if (!KEY) return;
    if (typeof window === "undefined") return;
    // Évite la double-init lors d'un hot-reload en dev
    if ((window as any).__posthog_inited) return;
    (window as any).__posthog_inited = true;

    posthog.init(KEY, {
      api_host: TUNNEL_HOST,
      ui_host: UI_HOST,
      // ─── RGPD & vie privée ───────────────────────────────────────
      // Anonymise l'IP : PostHog tronque le dernier octet (ex. 1.2.3.0)
      ip: false,
      // Pas de session recording par défaut (consentement explicite requis)
      disable_session_recording: true,
      // Pas de surveillance des inputs (mot de passe, etc.)
      mask_all_text: false,
      // Capture les pageviews manuellement (sinon double-tracking avec
      // le useEffect plus bas qui écoute les changements de pathname).
      capture_pageview: false,
      // Capture pageleave (utile pour mesurer le time-on-page).
      capture_pageleave: true,
      // Active les bundles persona, web vitals, etc.
      autocapture: true,
      // Important : pas d'analyse de la chaîne URL (peut leak des tokens)
      sanitize_properties: (properties, _event) => {
        // Supprime tout query param ressemblant à un token / mot de passe
        if (typeof properties.$current_url === "string") {
          properties.$current_url = stripSensitiveQuery(
            properties.$current_url
          );
        }
        if (typeof properties.$referrer === "string") {
          properties.$referrer = stripSensitiveQuery(properties.$referrer);
        }
        return properties;
      },
      // Respect du flag Do Not Track du navigateur
      respect_dnt: true,
      // Cookie 1ère partie (pas tiers — moins de friction côté ad-blockers)
      persistence: "localStorage+cookie",
    });

    // expose pour le wrapper lib/analytics.ts
    (window as any).posthog = posthog;
  }, []);

  // Identification du user dès qu'il est disponible
  useEffect(() => {
    if (!profile?.id) return;
    identifyUser(profile.id, {
      email: profile.email,
      role: profile.role,
      full_name: profile.full_name ?? undefined,
      active_formation_slug: profile.active_formation_slug ?? undefined,
    });
  }, [profile?.id, profile?.email, profile?.role, profile?.full_name, profile?.active_formation_slug]);

  return (
    <>
      <Suspense fallback={null}>
        <PageviewTracker />
      </Suspense>
      {children}
    </>
  );
}

/**
 * Capture un pageview à chaque changement de route App Router.
 * Doit être dans un Suspense boundary car useSearchParams peut suspendre.
 */
function PageviewTracker() {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  useEffect(() => {
    if (!KEY) return;
    if (typeof window === "undefined") return;
    if (!pathname) return;
    const url = `${window.location.origin}${pathname}${
      searchParams?.toString() ? `?${searchParams.toString()}` : ""
    }`;
    posthog.capture("$pageview", {
      $current_url: stripSensitiveQuery(url),
    });
  }, [pathname, searchParams]);

  return null;
}

/**
 * Retire les query params sensibles de l'URL avant capture.
 * Ex : /reset-password?token=ABC → /reset-password?token=[REDACTED]
 */
function stripSensitiveQuery(url: string): string {
  try {
    const u = new URL(url);
    const sensitive = [
      "token",
      "code",
      "access_token",
      "refresh_token",
      "password",
      "email",
      "api_key",
      "session",
    ];
    for (const key of sensitive) {
      if (u.searchParams.has(key)) {
        u.searchParams.set(key, "[REDACTED]");
      }
    }
    return u.toString();
  } catch {
    return url;
  }
}
