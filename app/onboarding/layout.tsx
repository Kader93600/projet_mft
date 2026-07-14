import { redirect } from "next/navigation";
import Link from "next/link";
import { Logo } from "@/components/ui/logo";
import { createClient } from "@/lib/supabase/server";

export default async function OnboardingLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect("/login");

  return (
    <div className="min-h-screen bg-ivory text-ink">
      <header className="border-b border-navy-100 bg-white">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center">
          <Link href="/onboarding" className="flex items-center">
            <Logo className="h-8" />
          </Link>
        </div>
      </header>
      <main className="max-w-5xl mx-auto px-6 py-10">{children}</main>
    </div>
  );
}
