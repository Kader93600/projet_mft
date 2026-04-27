import { AuthLayout } from "@/components/auth-layout";

export default function ReussitesLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
