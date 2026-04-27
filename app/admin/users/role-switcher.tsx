"use client";
import { useState, useTransition } from "react";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export function RoleSwitcher({
  userId,
  role,
}: {
  userId: string;
  role: "student" | "admin";
}) {
  const [value, setValue] = useState(role);
  const [pending, start] = useTransition();
  const router = useRouter();

  function onChange(e: React.ChangeEvent<HTMLSelectElement>) {
    const newRole = e.target.value as "student" | "admin";
    setValue(newRole);
    start(async () => {
      const supabase = createClient();
      await supabase.from("profiles").update({ role: newRole }).eq("id", userId);
      router.refresh();
    });
  }

  return (
    <select
      value={value}
      onChange={onChange}
      disabled={pending}
      className="text-xs rounded-lg border border-navy-200 bg-white text-navy-900 px-2.5 py-1.5 font-medium focus:outline-none focus:ring-2 focus:ring-navy-600/15 focus:border-navy-600 disabled:opacity-50"
    >
      <option value="student">Étudiant</option>
      <option value="admin">Admin</option>
    </select>
  );
}
