import { AuthLayout } from "@/components/auth-layout";

export default function SessionsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
