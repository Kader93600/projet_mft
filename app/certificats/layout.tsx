import { AuthLayout } from "@/components/auth-layout";

export default function CertificatsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
