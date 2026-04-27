import { AuthLayout } from "@/components/auth-layout";

export default function ResultsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
