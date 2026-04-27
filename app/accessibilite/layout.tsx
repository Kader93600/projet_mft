import { AuthLayout } from "@/components/auth-layout";

export default function AccessibiliteLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
