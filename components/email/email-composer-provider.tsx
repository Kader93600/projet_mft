"use client";

import { createContext, useContext, useState, useCallback } from "react";
import { EmailComposer, type ComposeOpts } from "./email-composer";

interface Ctx {
  open: (opts?: ComposeOpts) => void;
}

const EmailCtx = createContext<Ctx | null>(null);

/** Ouvre le composer email depuis n'importe quel composant client.
 *  No-op si le provider n'est pas monté (sécurité). */
export function useEmailComposer(): Ctx {
  return useContext(EmailCtx) ?? { open: () => {} };
}

export function EmailComposerProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<ComposeOpts | null>(null);
  const open = useCallback((opts?: ComposeOpts) => setState(opts ?? {}), []);
  return (
    <EmailCtx.Provider value={{ open }}>
      {children}
      {state !== null && <EmailComposer opts={state} onClose={() => setState(null)} />}
    </EmailCtx.Provider>
  );
}
