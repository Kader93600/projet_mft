import { AuthLayout } from "@/components/auth-layout";

export default function TuteurLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
