"use client";

// =====================================================================
// Aperçu temps réel de la convocation — reflète fidèlement les trois
// templates PDF (même résolution de contenu via resolveConvocation).
// Rendu dans un cadre au ratio A4, mis à jour à chaque frappe.
// =====================================================================

import {
  resolveConvocation, formatDateFr, sessionText, civiliteLongue,
  type ConvocationPayload, type ConvocationTemplate,
} from "@/lib/convocations";
import { cn } from "@/lib/utils";

function LogoMini({ size = 30 }: { size?: number }) {
  return (
    <svg viewBox="0 0 64 64" width={size} height={size} aria-hidden="true">
      <circle cx="32" cy="36" r="22" fill="none" stroke="#2530D9" strokeWidth="3.5" />
      <path d="M22 56 L42 56 L36 22 L28 22 Z" fill="#9FE220" />
      <rect x="31.2" y="26" width="1.6" height="4" fill="#fff" />
      <rect x="31.1" y="33" width="1.8" height="5" fill="#fff" />
      <rect x="30.9" y="42" width="2.2" height="6" fill="#fff" />
      <rect x="30.6" y="51" width="2.8" height="4" fill="#fff" />
      <path d="M32 6 L52 14 L32 22 L12 14 Z" fill="#2530D9" />
      <circle cx="48" cy="14" r="1.6" fill="#2530D9" />
      <line x1="48" y1="14" x2="48" y2="22" stroke="#2530D9" strokeWidth="1.4" strokeLinecap="round" />
      <circle cx="48" cy="22.5" r="1.4" fill="#2530D9" />
    </svg>
  );
}

const LABEL = "text-[7px] font-bold uppercase tracking-[0.14em] text-slate-400";

function Consignes({ items, dense }: { items: ReturnType<typeof resolveConvocation>["consignes"]; dense?: boolean }) {
  return (
    <ul className={cn("space-y-[3px]", dense && "space-y-[1px]")}>
      {items.map((c, i) => (
        <li key={i} className="flex gap-1.5 text-[8.5px] leading-snug text-slate-800">
          <span className="mt-[4px] h-1 w-1 flex-none rounded-full bg-[#5a7f12]" />
          <span>
            {c.label}
            {c.detail ? <span className="text-slate-500"> ({c.detail})</span> : null}
          </span>
        </li>
      ))}
    </ul>
  );
}

function Signature({ p }: { p: ConvocationPayload }) {
  return (
    <div className="mt-4 flex justify-end">
      <div className="w-[42%]">
        <div className="text-[8px] text-slate-500">{p.signataire.fonction}</div>
        <div className="text-[9px] font-bold text-navy-950">{p.signataire.nom || " "}</div>
        <div className="mt-1 h-9 rounded border border-dashed border-slate-200 bg-slate-50/60" />
        <div className="mt-0.5 text-center text-[6px] uppercase tracking-widest text-slate-400">
          Signature et cachet du centre
        </div>
      </div>
    </div>
  );
}

function Footer({ p }: { p: ConvocationPayload }) {
  return (
    <div className="absolute inset-x-6 bottom-3 flex items-baseline justify-between border-t border-slate-200 pt-1.5 text-[6.5px] text-slate-400">
      <span className="truncate">
        MA FORMATION TRANSPORT · {p.lieu.adresse || "39 avenue des Sablons Bouillants"}, {p.lieu.code_postal || "77100"} {p.lieu.ville || "MEAUX"} · {p.contact.telephone}
      </span>
      <span className="pl-2 whitespace-nowrap">Réf. {p.reference || "—"}</span>
    </div>
  );
}

export function ConvocationPreview({
  payload: p,
  template,
  className,
}: {
  payload: ConvocationPayload;
  template: ConvocationTemplate;
  className?: string;
}) {
  const r = resolveConvocation(p);

  return (
    <div
      className={cn(
        "relative aspect-[210/297] w-full overflow-hidden rounded-lg border border-navy-100 bg-white shadow-raised",
        className,
      )}
      aria-label="Aperçu de la convocation"
    >
      <div className="absolute inset-x-0 top-0 h-[5px] bg-signal-500" />
      <div className="absolute inset-0 overflow-hidden p-6 pt-5 text-[9px] leading-relaxed text-slate-900">
        {template === "classique" ? (
          <>
            <div className="flex flex-col items-center pt-1 text-center">
              <LogoMini size={34} />
              <div className="mt-1 text-[11px] font-bold tracking-wide text-navy-950">
                MA FORMATION <span className="text-[#5a7f12]">TRANSPORT</span>
              </div>
              <div className="mt-2 text-[15px] font-bold uppercase tracking-[0.25em] text-navy-950">
                {r.titreDoc}
              </div>
              <div className="mt-0.5 h-[2px] w-14 bg-signal-500" />
              <div className="mt-1 text-[8px] text-slate-500">
                {r.sousTitre} · Réf. {p.reference || "—"}
              </div>
            </div>
            <table className="mt-3 w-full border border-slate-200 text-[8.2px]">
              <tbody>
                {[
                  ["Destinataire", r.destinataireLignes],
                  ["Formation", [p.formation.titre || "—"]],
                  ...(p.session.label ? [["Session", [p.session.label]] as [string, string[]]] : []),
                  ["Épreuve", [`${p.epreuve.type}${p.epreuve.intitule ? ` : ${p.epreuve.intitule}` : ""}`]],
                  ...r.infosGrid.map((c) => [c.label, c.lines] as [string, string[]]),
                ].map(([label, lines], i) => (
                  <tr key={i} className="border-b border-slate-200 last:border-b-0">
                    <td className={cn("w-[30%] border-r border-slate-200 bg-[#FAF9F5] px-2 py-1 align-top", LABEL)}>
                      {label as string}
                    </td>
                    <td className="px-2 py-1">
                      {(lines as string[]).map((l, j) => (
                        <div key={j} className={j === 0 ? "font-semibold text-navy-950" : "text-slate-700"}>{l}</div>
                      ))}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            {r.consignes.length > 0 && (
              <div className="mt-2">
                <div className={cn(LABEL, "mb-1")}>{p.kind === "jury" ? "Informations et documents" : "Consignes à respecter"}</div>
                <Consignes items={r.consignes} dense />
              </div>
            )}
            <Signature p={p} />
          </>
        ) : template === "compact" ? (
          <>
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <LogoMini size={26} />
                <div>
                  <div className="text-[10px] font-bold text-navy-950">
                    MA FORMATION <span className="text-[#5a7f12]">TRANSPORT</span>
                  </div>
                  <div className="text-[7px] text-slate-500">{r.titreDoc} · {r.sousTitre}</div>
                </div>
              </div>
              <div className="text-right text-[7px] text-slate-400">
                <div>Réf. {p.reference || "—"}</div>
                <div>{formatDateFr(p.horaires.date) || "Date à définir"}</div>
              </div>
            </div>
            <div className="mt-2 h-[1.5px] bg-navy-950" />
            <div className="mt-3 flex gap-3">
              <div className="flex-[1.15] space-y-2">
                <div>
                  <div className={LABEL}>Destinataire</div>
                  {r.destinataireLignes.map((l, i) => (
                    <div key={i} className={i === 0 ? "text-[9.5px] font-bold text-navy-950" : "text-slate-600"}>{l}</div>
                  ))}
                </div>
                <div>
                  <div className={LABEL}>Formation</div>
                  <div>{p.formation.titre || "—"}</div>
                  {p.session.label && <div className="text-slate-500">{sessionText(p.session.label)}</div>}
                </div>
                <div>
                  <div className={LABEL}>Épreuve</div>
                  <div>{p.epreuve.type}{p.epreuve.intitule ? ` : ${p.epreuve.intitule}` : ""}</div>
                </div>
              </div>
              <div className="flex-1 space-y-2 rounded-md border border-slate-200 bg-[#FAF9F5] p-2">
                {r.infosGrid.map((cell) => (
                  <div key={cell.label}>
                    <div className={LABEL}>{cell.label}</div>
                    {cell.lines.map((l, j) => (
                      <div key={j} className={j === 0 ? "font-semibold text-navy-950" : "text-[8px] text-slate-700"}>{l}</div>
                    ))}
                  </div>
                ))}
              </div>
            </div>
            {r.consignes.length > 0 && (
              <div className="mt-2.5">
                <div className={cn(LABEL, "mb-1")}>Consignes</div>
                <Consignes items={r.consignes} dense />
              </div>
            )}
            <Signature p={p} />
          </>
        ) : (
          /* ── moderne ── */
          <>
            <div className="flex items-center gap-2">
              <LogoMini size={30} />
              <div>
                <div className="text-[10.5px] font-bold tracking-wide text-navy-950">
                  MA FORMATION <span className="text-[#5a7f12]">TRANSPORT</span>
                </div>
                <div className="text-[7px] text-slate-500">
                  Centre de formation aux métiers du transport et de la logistique
                </div>
              </div>
            </div>
            <div className="mt-1.5 flex h-[2px] overflow-hidden rounded">
              <span className="w-10 bg-navy-950" />
              <span className="w-4 bg-signal-500" />
              <span className="flex-1 bg-slate-200" />
            </div>

            <div className="mt-2.5 flex justify-between gap-3">
              <div>
                <div className={LABEL}>Centre organisateur</div>
                <div className="font-semibold text-navy-950">MA FORMATION TRANSPORT</div>
                <div className="text-slate-500">{p.lieu.adresse || "—"}</div>
                <div className="text-slate-500">{p.lieu.code_postal} {p.lieu.ville}</div>
                <div className="mt-0.5 text-slate-500">Tél. {p.contact.telephone}</div>
              </div>
              <div className="w-[44%] rounded-md border border-slate-200 bg-[#FAF9F5] p-2">
                <div className={LABEL}>Destinataire</div>
                {r.destinataireLignes.map((l, i) => (
                  <div key={i} className={i === 0 ? "font-semibold text-navy-950" : "text-slate-600"}>{l}</div>
                ))}
              </div>
            </div>

            <div className="mt-2.5 flex gap-1.5">
              <div className="w-[3px] rounded bg-signal-500" />
              <div className="min-w-0">
                <div className={LABEL}>Objet</div>
                <div className="text-[10px] font-bold leading-tight text-navy-950">
                  {r.titreDoc} · {r.sousTitre}
                </div>
                <div className="text-[8.5px]">{p.epreuve.type}{p.epreuve.intitule ? ` : ${p.epreuve.intitule}` : ""}</div>
                <div className="truncate text-[7px] text-slate-400">
                  {p.formation.titre || "Formation à sélectionner"}
                  {p.session.label ? ` · ${sessionText(p.session.label)}` : ""} · Réf. {p.reference || "—"}
                </div>
              </div>
            </div>

            <p className="mt-2 text-[8.5px] leading-snug text-slate-700">
              {civiliteLongue(p.destinataire.civilite)},{" "}
              {p.kind === "jury"
                ? "vous avez accepté d'être désigné en tant que membre de jury pour la session d'examen mentionnée ci-dessous."
                : "vous êtes convoqué à l'épreuve mentionnée ci-dessous dans le cadre de votre parcours de formation."}
            </p>

            <div className="mt-2 overflow-hidden rounded-md border border-slate-200">
              <div className="flex items-center justify-between bg-navy-950 px-2 py-1">
                <span className="text-[6.5px] font-bold uppercase tracking-[0.16em] text-white">Informations pratiques</span>
                <span className="text-[6.5px] font-bold uppercase tracking-[0.16em] text-signal-400">À conserver</span>
              </div>
              <div className="flex divide-x divide-slate-200">
                {r.infosGrid.map((cell) => (
                  <div key={cell.label} className="flex-1 p-2">
                    <div className={LABEL}>{cell.label}</div>
                    {cell.lines.map((l, j) => (
                      <div key={j} className={j === 0 ? "text-[8.5px] font-semibold text-navy-950" : "text-[7.8px] text-slate-700"}>{l}</div>
                    ))}
                  </div>
                ))}
              </div>
            </div>

            {r.consignes.length > 0 && (
              <div className="mt-2">
                <div className={cn(LABEL, "mb-1")}>{p.kind === "jury" ? "Informations et documents" : "Consignes à respecter"}</div>
                <Consignes items={r.consignes} />
              </div>
            )}
            {p.remarques ? (
              <div className="mt-1.5 rounded-md border border-slate-200 bg-[#FAF9F5] p-1.5 text-[8px] text-slate-700">
                <span className={LABEL}>Remarques&nbsp;</span>{p.remarques}
              </div>
            ) : null}
            <Signature p={p} />
          </>
        )}
        <Footer p={p} />
      </div>
    </div>
  );
}
