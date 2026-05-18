import { AuthLayout } from "@/components/auth-layout";

export default function OrganisationLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
