"use client";

// =====================================================================
// Scène animée du panneau gauche de /login (concept A+ « Le Convoi »,
// validé client). Monte un canvas plein panneau derrière le contenu et
// pilote le moteur (components/auth/login-scene-engine.ts) :
//   - import() dynamique au mount → le moteur est code-splitté et ne
//     pèse pas sur le First Load ;
//   - états reliés au formulaire via l'événement window "mft:auth-scene"
//     (détail : "idle" | "connecting" | "success"), émis par LoginForm ;
//   - parallaxe souris, prefers-reduced-motion suivi en direct ;
//   - destroy() complet au démontage (navigation).
// =====================================================================

import { useEffect, useRef } from "react";
import type { LoginSceneApi } from "./login-scene-engine";

/** Nom de l'événement émis par le formulaire de connexion. */
export const AUTH_SCENE_EVENT = "mft:auth-scene";

export type AuthSceneState = "idle" | "connecting" | "success";

export function LoginScene() {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    let api: LoginSceneApi | null = null;
    let disposed = false;
    const mq = window.matchMedia("(prefers-reduced-motion: reduce)");

    void import("./login-scene-engine").then((mod) => {
      if (disposed) return;
      api = mod.initLoginScene(canvas);
      api.setReduced(mq.matches);
    });

    const onPointer = (e: PointerEvent) => {
      api?.setPointer(e.clientX / window.innerWidth, e.clientY / window.innerHeight);
    };
    const onState = (e: Event) => {
      const detail = (e as CustomEvent<AuthSceneState>).detail;
      if (detail === "idle" || detail === "connecting" || detail === "success") {
        api?.setState(detail);
      }
    };
    const onMotionPref = () => api?.setReduced(mq.matches);

    window.addEventListener("pointermove", onPointer, { passive: true });
    window.addEventListener(AUTH_SCENE_EVENT, onState);
    mq.addEventListener("change", onMotionPref);

    return () => {
      disposed = true;
      window.removeEventListener("pointermove", onPointer);
      window.removeEventListener(AUTH_SCENE_EVENT, onState);
      mq.removeEventListener("change", onMotionPref);
      api?.destroy();
      api = null;
    };
  }, []);

  return (
    <canvas
      ref={canvasRef}
      aria-hidden="true"
      className="absolute inset-0 h-full w-full"
    />
  );
}
