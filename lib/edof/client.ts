import "server-only";
// =====================================================================
// Client EDOF — interface + fabrique.
//
// L'INTERFACE est stable : tout le reste du code (cron, actions, UI)
// dépend d'elle, pas de l'implémentation. Aujourd'hui :
//   - pas de credentials → NotConfiguredEdofClient (échoue proprement) ;
//   - credentials présents → HttpEdofClient, dont les méthodes lèvent
//     `EdofNotImplementedError` tant que l'adapter HTTP réel n'est pas
//     écrit (en attente des specs CDC).
//
// 👉 POUR FINIR L'INTÉGRATION : implémenter les méthodes de
//    HttpEdofClient (auth OAuth2 client_credentials + appels REST) à
//    partir de la doc officielle CDC. Voir lib/edof/README.md.
// =====================================================================

import { getEdofConfig, type EdofConfig } from "./config";
import type { EdofDossier, EdofDossierStatus } from "./types";

export class EdofNotConfiguredError extends Error {
  constructor() {
    super(
      "EDOF non configuré : variables EDOF_* absentes (accès CDC en attente).",
    );
    this.name = "EdofNotConfiguredError";
  }
}

export class EdofNotImplementedError extends Error {
  constructor(method: string) {
    super(
      `Adapter EDOF non implémenté (${method}). À compléter avec les specs CDC — cf. lib/edof/README.md.`,
    );
    this.name = "EdofNotImplementedError";
  }
}

export interface ListDossiersOptions {
  /** Récupération incrémentale : seulement les dossiers maj depuis cette date ISO. */
  since?: string;
  page?: number;
  pageSize?: number;
}

/** Contrat stable de l'intégration EDOF. */
export interface EdofClient {
  listDossiers(opts?: ListDossiersOptions): Promise<EdofDossier[]>;
  acceptDossier(edofId: string): Promise<void>;
  refuseDossier(edofId: string, reason: string): Promise<void>;
  declareEntry(edofId: string, entryDateIso: string): Promise<void>;
  declareServiceFait(
    edofId: string,
    opts: { completionDateIso: string; hoursDone?: number },
  ): Promise<void>;
}

/** Impl utilisée tant qu'aucun credential n'est présent : échoue clairement. */
class NotConfiguredEdofClient implements EdofClient {
  private fail(): never {
    throw new EdofNotConfiguredError();
  }
  listDossiers(): Promise<EdofDossier[]> {
    return this.fail();
  }
  acceptDossier(): Promise<void> {
    return this.fail();
  }
  refuseDossier(): Promise<void> {
    return this.fail();
  }
  declareEntry(): Promise<void> {
    return this.fail();
  }
  declareServiceFait(): Promise<void> {
    return this.fail();
  }
}

/**
 * Impl HTTP réelle — squelette. La config est injectée et conservée ;
 * les appels restent à écrire (auth + endpoints) avec les specs CDC.
 * Volume cible moyen → pagination (pageSize ~100) + récupération
 * incrémentale via `since`, traitement idempotent côté cron.
 */
class HttpEdofClient implements EdofClient {
  // Conservé pour l'implémentation future (base URL, SIRET, OAuth2…).
  constructor(private readonly config: EdofConfig) {}

  // Exemple de point d'extension : obtention/cache du token OAuth2.
  // private async getAccessToken(): Promise<string> { ... }

  async listDossiers(_opts?: ListDossiersOptions): Promise<EdofDossier[]> {
    void this.config;
    throw new EdofNotImplementedError("listDossiers");
  }
  async acceptDossier(_edofId: string): Promise<void> {
    throw new EdofNotImplementedError("acceptDossier");
  }
  async refuseDossier(_edofId: string, _reason: string): Promise<void> {
    throw new EdofNotImplementedError("refuseDossier");
  }
  async declareEntry(_edofId: string, _entryDateIso: string): Promise<void> {
    throw new EdofNotImplementedError("declareEntry");
  }
  async declareServiceFait(
    _edofId: string,
    _opts: { completionDateIso: string; hoursDone?: number },
  ): Promise<void> {
    throw new EdofNotImplementedError("declareServiceFait");
  }
}

/** Fabrique : renvoie l'impl adaptée à l'état de configuration. */
export function createEdofClient(): EdofClient {
  const config = getEdofConfig();
  return config ? new HttpEdofClient(config) : new NotConfiguredEdofClient();
}

// Ré-exports pratiques
export type { EdofDossier, EdofDossierStatus };
