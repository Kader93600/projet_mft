import { AuthLayout } from "@/components/auth-layout";

export default function FideliteLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
