import { AuthLayout } from "@/components/auth-layout";

export default function GlossaireLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
