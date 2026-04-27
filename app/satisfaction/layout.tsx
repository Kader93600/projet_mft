import { AuthLayout } from "@/components/auth-layout";
export default function L({ children }: { children: React.ReactNode }) {
  return <AuthLayout>{children}</AuthLayout>;
}
