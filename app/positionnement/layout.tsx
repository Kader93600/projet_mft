import { AuthLayout } from "@/components/auth-layout";

export default function PlacementLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <AuthLayout>{children}</AuthLayout>;
}
