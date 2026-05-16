/**
 * Layout vide pour la page TV — pas de sidebar, pas de header.
 * Override le admin/layout parent qui inclut AdminShell.
 */
export default function TvLayout({ children }: { children: React.ReactNode }) {
  return <>{children}</>;
}
