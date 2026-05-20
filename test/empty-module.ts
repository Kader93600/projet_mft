// Stub vide pour aliaser "server-only" en environnement de test (vitest).
// Le package "server-only" lève une erreur hors contexte serveur ; en test
// unitaire on neutralise cet import pour pouvoir tester la logique pure des
// modules marqués server-only (ex. lib/module-unlock.ts).
export {};
