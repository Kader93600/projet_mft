import { MfaChallengeForm } from "./challenge-form";
import { ShieldCheck } from "lucide-react";

export const dynamic = "force-dynamic";

export default function MfaChallengePage() {
  return (
    <div className="min-h-screen bg-ivory flex items-center justify-center px-4">
      <div className="max-w-md w-full">
        <div className="text-center mb-8">
          <div className="mx-auto h-12 w-12 rounded-2xl bg-navy-900 text-gold-400 flex items-center justify-center">
            <ShieldCheck className="h-6 w-6" />
          </div>
          <h1 className="mt-4 font-display text-2xl font-semibold text-navy-950">
            Vérification en deux étapes
          </h1>
          <p className="mt-2 text-sm text-slate-600">
            Saisissez le code à 6 chiffres généré par votre application
            d'authentification.
          </p>
        </div>
        <MfaChallengeForm />
      </div>
    </div>
  );
}
