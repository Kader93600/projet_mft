import { AuthLayout } from "@/components/auth-layout";

export default function MesDonneesLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
