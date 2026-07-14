// =====================================================================
// File d'attente offline pour les tentatives de quiz QCM d'entraînement.
//
// Stockée dans IndexedDB pour persister à travers les rechargements
// (un localStorage volumineux serait synchrone et risque de bloquer
// le main thread sur des tentatives lourdes).
//
// Format d'une entrée :
//   {
//     client_id: string,          // uuid v4
//     payload:  QuizAttemptPayload,
//     enqueued_at: number (ms),
//     attempts: number            // nombre de tentatives de sync
//   }
//
// API minimale exposée :
//   enqueueAttempt(payload) → Promise<string>     // retourne client_id
//   listPendingAttempts()   → Promise<Pending[]>
//   removeAttempt(id)       → Promise<void>
//   markAttemptFailed(id)   → Promise<void>       // ++ attempts
//   clearAll()              → Promise<void>
//
// Tout est typé minimaliste : on n'oblige pas l'appelant à connaître
// le schéma exact de quiz_attempts, on stocke en JSON.
// =====================================================================

const DB_NAME = "mft-sync";
const DB_VERSION = 1;
const STORE = "quiz-attempts";

export type PendingAttempt = {
  client_id: string;
  payload: Record<string, unknown>;
  enqueued_at: number;
  attempts: number;
};

function isBrowser(): boolean {
  return typeof window !== "undefined" && typeof indexedDB !== "undefined";
}

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    if (!isBrowser()) {
      reject(new Error("IndexedDB indisponible (SSR ou environnement non-DOM)"));
      return;
    }
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onupgradeneeded = () => {
      const db = req.result;
      if (!db.objectStoreNames.contains(STORE)) {
        db.createObjectStore(STORE, { keyPath: "client_id" });
      }
    };
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error ?? new Error("openDb error"));
  });
}

function generateClientId(): string {
  if (
    typeof crypto !== "undefined" &&
    typeof crypto.randomUUID === "function"
  ) {
    return crypto.randomUUID();
  }
  // Fallback (navigateurs anciens) : timestamp + random
  return (
    Date.now().toString(36) +
    "-" +
    Math.random().toString(36).slice(2, 10) +
    "-" +
    Math.random().toString(36).slice(2, 10)
  );
}

/**
 * Enregistre une tentative quiz en attente de sync. Retourne le
 * client_id généré (à mettre dans le payload côté serveur comme
 * `client_attempt_id` pour la déduplication).
 */
export async function enqueueAttempt(
  payload: Record<string, unknown>
): Promise<string> {
  const db = await openDb();
  const client_id = generateClientId();
  const item: PendingAttempt = {
    client_id,
    payload: { ...payload, client_attempt_id: client_id },
    enqueued_at: Date.now(),
    attempts: 0,
  };
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE, "readwrite");
    tx.objectStore(STORE).put(item);
    tx.oncomplete = () => {
      db.close();
      resolve(client_id);
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("enqueue tx error"));
    };
  });
}

export async function listPendingAttempts(): Promise<PendingAttempt[]> {
  if (!isBrowser()) return [];
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE, "readonly");
    const req = tx.objectStore(STORE).getAll();
    req.onsuccess = () => {
      db.close();
      resolve((req.result as PendingAttempt[]) ?? []);
    };
    req.onerror = () => {
      db.close();
      reject(req.error ?? new Error("getAll error"));
    };
  });
}

export async function removeAttempt(client_id: string): Promise<void> {
  if (!isBrowser()) return;
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE, "readwrite");
    tx.objectStore(STORE).delete(client_id);
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("delete error"));
    };
  });
}

export async function markAttemptFailed(client_id: string): Promise<void> {
  if (!isBrowser()) return;
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE, "readwrite");
    const store = tx.objectStore(STORE);
    const getReq = store.get(client_id);
    getReq.onsuccess = () => {
      const item = getReq.result as PendingAttempt | undefined;
      if (item) {
        item.attempts = (item.attempts ?? 0) + 1;
        store.put(item);
      }
    };
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("markFailed error"));
    };
  });
}

export async function countPending(): Promise<number> {
  const all = await listPendingAttempts();
  return all.length;
}

export async function clearAll(): Promise<void> {
  if (!isBrowser()) return;
  const db = await openDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(STORE, "readwrite");
    tx.objectStore(STORE).clear();
    tx.oncomplete = () => {
      db.close();
      resolve();
    };
    tx.onerror = () => {
      db.close();
      reject(tx.error ?? new Error("clear error"));
    };
  });
}
