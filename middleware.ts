import { createServerClient, type CookieOptions } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request: { headers: request.headers } });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return request.cookies.get(name)?.value;
        },
        set(name: string, value: string, options: CookieOptions) {
          request.cookies.set({ name, value, ...options });
          response = NextResponse.next({ request: { headers: request.headers } });
          response.cookies.set({ name, value, ...options });
        },
        remove(name: string, options: CookieOptions) {
          request.cookies.set({ name, value: "", ...options });
          response = NextResponse.next({ request: { headers: request.headers } });
          response.cookies.set({ name, value: "", ...options });
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;
  const isAuthPage =
    (pathname.startsWith("/login") && !pathname.startsWith("/login/mfa")) ||
    pathname.startsWith("/signup");
  const isMfaChallenge = pathname.startsWith("/login/mfa");
  const isMfaSetup = pathname.startsWith("/admin/security");
  const isOnboarding = pathname.startsWith("/onboarding");
  const isPlacement = pathname.startsWith("/positionnement");
  const isSignature = pathname.startsWith("/signature-obligatoire");
  const isProtected =
    pathname.startsWith("/dashboard") ||
    pathname.startsWith("/modules") ||
    pathname.startsWith("/quiz") ||
    pathname.startsWith("/exercices") ||
    pathname.startsWith("/examens-blancs") ||
    pathname.startsWith("/stats") ||
    pathname.startsWith("/evaluation") ||
    pathname.startsWith("/mes-documents") ||
    pathname.startsWith("/messages") ||
    pathname.startsWith("/notifications") ||
    pathname.startsWith("/positionnement") ||
    pathname.startsWith("/glossaire") ||
    pathname.startsWith("/reussites") ||
    pathname.startsWith("/certificats") ||
    pathname.startsWith("/accompagnement") ||
    pathname.startsWith("/accessibilite") ||
    pathname.startsWith("/recherche") ||
    pathname.startsWith("/classement") ||
    pathname.startsWith("/inscription") ||
    pathname.startsWith("/financeur") ||
    pathname.startsWith("/formateur") ||
    pathname.startsWith("/mes-donnees") ||
    pathname.startsWith("/emargement") ||
    pathname.startsWith("/satisfaction") ||
    pathname.startsWith("/super-admin") ||
    isMfaChallenge ||
    pathname.startsWith("/admin");

  // Cas spécial : /inscription est le tableau de bord "Mon dossier" du
  // stagiaire connecté, mais d'anciens liens publics y pointaient. Pour un
  // visiteur non connecté, on bascule vers /contact (avec préservation des
  // query params formation= / financeur= / plan=) plutôt que /login, où il
  // n'aurait aucun moyen de créer un compte (signup public désactivé).
  if (!user && pathname.startsWith("/inscription")) {
    const url = new URL("/contact", request.url);
    request.nextUrl.searchParams.forEach((v, k) => url.searchParams.set(k, v));
    return NextResponse.redirect(url);
  }

  if (!user && (isProtected || isOnboarding || isSignature)) {
    return NextResponse.redirect(new URL("/login", request.url));
  }
  if (user && isAuthPage) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // Admin gate + onboarding gate (stagiaire uniquement, jamais admin)
  if (user && (isProtected || isOnboarding || isSignature)) {
    const { data: profile } = await supabase
      .from("profiles")
      .select(
        "role, onboarding_completed_at, placement_completed_at, mandatory_signature_at"
      )
      .eq("id", user.id)
      .single();

    // Super-admin : strict
    if (
      pathname.startsWith("/super-admin") &&
      profile?.role !== "super_admin"
    ) {
      return NextResponse.redirect(new URL("/dashboard", request.url));
    }
    // /admin : ouvert au staff (admin/super_admin), et partiellement
    // au trainer pour les routes pédagogiques (modules, quizzes,
    // banque-questions, placement). Scope par formation appliqué côté
    // server actions et requêtes.
    if (pathname.startsWith("/admin")) {
      const isStaff =
        profile?.role === "admin" || profile?.role === "super_admin";
      const isTrainer = profile?.role === "trainer";
      const TRAINER_ALLOWED = [
        "/admin/modules",
        "/admin/quizzes",
        "/admin/banque-questions",
        "/admin/placement",
        "/admin/emargement",
      ];
      const trainerAllowed =
        isTrainer && TRAINER_ALLOWED.some((p) => pathname.startsWith(p));
      if (!isStaff && !trainerAllowed) {
        return NextResponse.redirect(new URL("/dashboard", request.url));
      }
    }
    // L'espace formateur est ouvert à : trainer, admin, super_admin
    // (admin/super_admin = encadrement pédagogique légitime sur tous les stagiaires)
    if (
      pathname.startsWith("/formateur") &&
      profile?.role !== "trainer" &&
      profile?.role !== "admin" &&
      profile?.role !== "super_admin"
    ) {
      return NextResponse.redirect(new URL("/dashboard", request.url));
    }

    // === MFA enforcement (désactivé) ===
    // Réactiver une fois le rendu QR corrigé. Code conservé en commentaire :
    //
    // try {
    //   const { data: aalData } =
    //     await supabase.auth.mfa.getAuthenticatorAssuranceLevel();
    //   const currentLevel = aalData?.currentLevel ?? "aal1";
    //   const nextLevel = aalData?.nextLevel ?? "aal1";
    //   if (nextLevel === "aal2" && currentLevel !== "aal2" && !isMfaChallenge) {
    //     const url = new URL("/login/mfa", request.url);
    //     url.searchParams.set("next", pathname);
    //     return NextResponse.redirect(url);
    //   }
    //   if (profile?.role === "admin" && nextLevel !== "aal2" && !isMfaSetup) {
    //     return NextResponse.redirect(new URL("/admin/security", request.url));
    //   }
    // } catch {}

    // Stagiaire : forcer /onboarding si non complété
    if (
      profile?.role === "student" &&
      !profile?.onboarding_completed_at &&
      !isOnboarding
    ) {
      return NextResponse.redirect(new URL("/onboarding", request.url));
    }

    // Stagiaire déjà onboardé : pas de raison d'être sur /onboarding
    if (
      profile?.role === "student" &&
      profile?.onboarding_completed_at &&
      isOnboarding
    ) {
      return NextResponse.redirect(new URL("/dashboard", request.url));
    }

    // Stagiaire onboardé mais documents non signés : forcer la signature
    // obligatoire (blocage total de l'accès stagiaire tant que non signé).
    if (
      profile?.role === "student" &&
      profile?.onboarding_completed_at &&
      !profile?.mandatory_signature_at &&
      !isSignature
    ) {
      return NextResponse.redirect(
        new URL("/signature-obligatoire", request.url)
      );
    }

    // Stagiaire ayant déjà signé : pas de raison de rester sur la page de signature
    if (
      profile?.role === "student" &&
      profile?.mandatory_signature_at &&
      isSignature
    ) {
      return NextResponse.redirect(new URL("/dashboard", request.url));
    }

    // Stagiaire onboardé + signé mais sans positionnement : forcer /positionnement
    // (accessible aussi volontairement après coup ; gate seulement si non fait)
    if (
      profile?.role === "student" &&
      profile?.onboarding_completed_at &&
      profile?.mandatory_signature_at &&
      !profile?.placement_completed_at &&
      !isPlacement &&
      !isOnboarding &&
      !isSignature
    ) {
      return NextResponse.redirect(new URL("/positionnement", request.url));
    }
  }

  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|.*\\.).*)"],
};
