import { createClient } from "@/lib/supabase/server";
import { NextResponse } from "next/server";
import { captureException } from "@/lib/observability";

export const dynamic = "force-dynamic";

export async function GET() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return NextResponse.json({ error: "unauthenticated" }, { status: 401 });
  }

  const { data, error } = await supabase.rpc("export_my_data");
  if (error) {
    await captureException(error, { tags: { route: "me/export" } });
    return NextResponse.json({ error: "export_failed" }, { status: 500 });
  }

  const filename = `gotrm-export-${user.id}-${new Date()
    .toISOString()
    .slice(0, 10)}.json`;
  return new NextResponse(JSON.stringify(data, null, 2), {
    status: 200,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Content-Disposition": `attachment; filename="${filename}"`,
      "Cache-Control": "no-store",
    },
  });
}
