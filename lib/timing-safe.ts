import { timingSafeEqual } from "node:crypto";

/**
 * Compare deux chaînes en TEMPS CONSTANT (résistant aux attaques temporelles).
 *
 * Une comparaison `a === b` sur un secret court-circuite au premier octet qui
 * diffère : le temps de réponse fuit la longueur du préfixe correct, ce qui
 * permet de reconstruire le secret octet par octet. À utiliser pour tout
 * secret comparé côté serveur (secrets de cron, de webhook…).
 *
 * Retourne false si l'une des entrées est absente, sans court-circuit
 * observable sur le contenu.
 */
export function timingSafeEqualStr(
  a: string | null | undefined,
  b: string | null | undefined
): boolean {
  if (typeof a !== "string" || typeof b !== "string") return false;
  const bufA = Buffer.from(a, "utf8");
  const bufB = Buffer.from(b, "utf8");
  // timingSafeEqual exige des longueurs égales ; on compare d'abord une
  // longueur factice pour ne pas révéler l'écart de longueur par une exception.
  if (bufA.length !== bufB.length) {
    // Compare bufA à lui-même pour consommer un temps comparable, puis échoue.
    timingSafeEqual(bufA, bufA);
    return false;
  }
  return timingSafeEqual(bufA, bufB);
}
