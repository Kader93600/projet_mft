import { AuthLayout } from "@/components/auth-layout";

export default function RechercheLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
