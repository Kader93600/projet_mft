// Layout transparent : le AuthLayout est déjà appliqué par le segment
// parent /quiz/layout.tsx. Le double-wrapping causait un rendu en
// "page dans la page" (visible sur la capture client mai 2026).
export default function ResultsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}
