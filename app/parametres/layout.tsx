import { AuthLayout } from "@/components/auth-layout";

export default function ParametresLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
