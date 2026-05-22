import { Logo } from "@/components/ui/logo";
import { LogoutButton } from "./logout-button";

// Layout plein écran, sans navigation : le stagiaire doit signer avant tout.
// Une déconnexion reste possible (la page est bloquante).
export default function SignatureObligatoireLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-ivory">
      <header className="bg-night border-b border-white/5">
        <div className="max-w-3xl mx-auto px-6 h-16 flex items-center justify-between gap-4">
          <Logo variant="light" size="sm" />
          <LogoutButton />
        </div>
      </header>
      <main className="max-w-3xl mx-auto px-6 py-8 md:py-12">{children}</main>
    </div>
  );
}
