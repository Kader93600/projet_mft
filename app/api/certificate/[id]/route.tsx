import { createClient } from "@/lib/supabase/server";
import { isStaff } from "@/lib/permissions";
import { NextRequest, NextResponse } from "next/server";
import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  renderToBuffer,
} from "@react-pdf/renderer";
import React from "react";
import { PdfLogoMark } from "@/lib/pdf-logo";

export const runtime = "nodejs";
export const dynamic = "force-dynamic";

const styles = StyleSheet.create({
  page: { padding: 60, fontSize: 11, fontFamily: "Helvetica", color: "#0f172a" },
  outerBorder: {
    position: "absolute",
    top: 25,
    left: 25,
    right: 25,
    bottom: 25,
    borderWidth: 2,
    borderColor: "#f5b100",
  },
  // Variante "Gold" : bordure plus épaisse et double pour les certificats
  // délivrés à un stagiaire ayant déjà 1+ certificat final (loyalty Gold).
  outerBorderGold: {
    position: "absolute",
    top: 20,
    left: 20,
    right: 20,
    bottom: 20,
    borderWidth: 4,
    borderColor: "#d97706",
  },
  outerBorderGoldInner: {
    position: "absolute",
    top: 28,
    left: 28,
    right: 28,
    bottom: 28,
    borderWidth: 1,
    borderColor: "#f5b100",
  },
  innerBorder: {
    position: "absolute",
    top: 30,
    left: 30,
    right: 30,
    bottom: 30,
    borderWidth: 0.5,
    borderColor: "#0E1240",
  },
  // Sceau "Stagiaire fidèle Gold" en haut à droite
  loyaltySeal: {
    position: "absolute",
    top: 45,
    right: 50,
    width: 90,
    height: 90,
    borderWidth: 2,
    borderColor: "#d97706",
    borderRadius: 45,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#fef3c7",
  },
  loyaltySealTopText: {
    fontSize: 7,
    fontWeight: "bold",
    color: "#92400e",
    letterSpacing: 1,
    textTransform: "uppercase",
  },
  loyaltySealMainText: {
    fontSize: 14,
    fontWeight: "bold",
    color: "#92400e",
    letterSpacing: 2,
    marginTop: 4,
  },
  loyaltySealBottomText: {
    fontSize: 6,
    color: "#92400e",
    marginTop: 4,
    letterSpacing: 0.5,
  },
  brand: {
    fontSize: 26,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
    marginTop: 30,
    letterSpacing: 2,
  },
  sub: {
    fontSize: 9,
    color: "#64748b",
    textAlign: "center",
    marginTop: 4,
    marginBottom: 50,
    letterSpacing: 1,
    textTransform: "uppercase",
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
    marginBottom: 6,
    textTransform: "uppercase",
    letterSpacing: 3,
  },
  titleUnderline: {
    width: 100,
    height: 3,
    backgroundColor: "#f5b100",
    alignSelf: "center",
    marginBottom: 30,
  },
  intro: {
    fontSize: 11,
    lineHeight: 1.8,
    color: "#334155",
    textAlign: "center",
    marginBottom: 20,
  },
  nameBlock: {
    padding: 16,
    marginVertical: 20,
    borderTopWidth: 1,
    borderBottomWidth: 1,
    borderColor: "#f5b100",
  },
  nameText: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
  },
  body: {
    fontSize: 11,
    lineHeight: 1.8,
    color: "#334155",
    textAlign: "center",
    marginBottom: 16,
    paddingHorizontal: 20,
  },
  blocTitle: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#0E1240",
    textAlign: "center",
    marginVertical: 10,
  },
  serial: {
    fontSize: 9,
    color: "#64748b",
    textAlign: "center",
    fontFamily: "Courier",
    marginTop: 40,
  },
  footer: {
    position: "absolute",
    bottom: 50,
    left: 60,
    right: 60,
    fontSize: 8,
    color: "#94a3b8",
    textAlign: "center",
  },
});

function fmtDate(d: string | Date | null) {
  if (!d) return "—";
  const date = typeof d === "string" ? new Date(d) : d;
  return date.toLocaleDateString("fr-FR", {
    day: "2-digit",
    month: "long",
    year: "numeric",
  });
}

function CertificatePDF({
  user,
  cert,
  bloc,
}: {
  user: any;
  cert: any;
  bloc: any | null;
}) {
  const C = React.createElement;
  const isFinal = cert.type === "final";
  const isLoyalty = cert.is_loyalty === true;
  return C(
    Document,
    {},
    C(
      Page,
      { size: "A4", orientation: "landscape", style: styles.page },
      // Bordure : double + plus épaisse pour les certificats Gold
      isLoyalty
        ? C(
            View,
            {},
            C(View, { style: styles.outerBorderGold }),
            C(View, { style: styles.outerBorderGoldInner })
          )
        : C(View, { style: styles.outerBorder }),
      C(View, { style: styles.innerBorder }),
      // Sceau loyalty visible uniquement sur les certifs Gold
      isLoyalty
        ? C(
            View,
            { style: styles.loyaltySeal },
            C(Text, { style: styles.loyaltySealTopText }, "Stagiaire"),
            C(Text, { style: styles.loyaltySealMainText }, "GOLD"),
            C(Text, { style: styles.loyaltySealBottomText }, "Fidèle MFT")
          )
        : null,

      C(
        View,
        { style: { alignItems: "center", marginTop: 28 } },
        C(PdfLogoMark, { size: 56 })
      ),
      C(Text, { style: [styles.brand, { marginTop: 10 }] }, "MA FORMATION TRANSPORT"),
      C(
        Text,
        { style: styles.sub },
        "Organisme de formation · Titre pro RNCP 40990"
      ),

      C(
        Text,
        { style: styles.title },
        isFinal ? "Certificat de fin de formation" : "Attestation de bloc"
      ),
      C(View, { style: styles.titleUnderline }),

      C(
        Text,
        { style: styles.intro },
        "Nous attestons que"
      ),

      C(
        View,
        { style: styles.nameBlock },
        C(Text, { style: styles.nameText }, user?.full_name || user?.email || "—")
      ),

      isFinal
        ? C(
            Text,
            { style: styles.body },
            "a validé l'intégralité des blocs de compétence requis pour la préparation au titre professionnel « Gestionnaire des Opérations de Transport Routier de Marchandises » (RNCP 40990)."
          )
        : C(
            View,
            {},
            C(
              Text,
              { style: styles.body },
              "a validé le bloc de compétence suivant :"
            ),
            C(
              Text,
              { style: styles.blocTitle },
              bloc ? `${bloc.code} — ${bloc.title}` : "Bloc"
            )
          ),

      C(
        Text,
        { style: styles.body },
        `Délivré le ${fmtDate(cert.issued_at)}.`
      ),

      C(
        Text,
        { style: styles.serial },
        `N° ${cert.serial}`
      ),

      C(
        Text,
        { style: styles.footer },
        "Ce certificat atteste de la réussite d'un parcours d'évaluation formatif MA FORMATION TRANSPORT. Il ne se substitue pas à la délivrance officielle du titre professionnel par le jury RNCP."
      )
    )
  );
}

export async function GET(
  req: NextRequest,
  { params }: { params: { id: string } }
) {
  const supabase = createClient();
  const {
    data: { user: authUser },
  } = await supabase.auth.getUser();
  if (!authUser) return NextResponse.json({ error: "unauth" }, { status: 401 });

  const { data: cert } = await supabase
    .from("certificates")
    .select("*")
    .eq("id", params.id)
    .single();
  if (!cert) return NextResponse.json({ error: "not_found" }, { status: 404 });

  // Auto-only OR admin
  if (cert.user_id !== authUser.id) {
    const { data: me } = await supabase
      .from("profiles")
      .select("role")
      .eq("id", authUser.id)
      .single();
    if (!isStaff(me?.role)) {
      return NextResponse.json({ error: "forbidden" }, { status: 403 });
    }
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, email")
    .eq("id", cert.user_id)
    .single();

  let bloc: any = null;
  if (cert.bloc_id) {
    const { data: b } = await supabase
      .from("blocs")
      .select("code, title")
      .eq("id", cert.bloc_id)
      .single();
    bloc = b;
  }

  const buffer = await renderToBuffer(
    React.createElement(CertificatePDF, {
      user: profile,
      cert,
      bloc,
    }) as any
  );

  return new NextResponse(buffer as any, {
    headers: {
      "Content-Type": "application/pdf",
      "Content-Disposition": `inline; filename="certificat-${cert.serial}.pdf"`,
      "Cache-Control": "private, max-age=300",
    },
  });
}
