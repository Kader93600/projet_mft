import { AuthLayout } from "@/components/auth-layout";

export default function ClassementLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
