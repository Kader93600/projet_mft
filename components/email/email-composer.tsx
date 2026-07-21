"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import {
  X,
  Minus,
  Maximize2,
  Minimize2,
  Paperclip,
  Trash2,
  ChevronDown,
  Send,
  Sparkles,
  Smile,
  FileSignature,
  Loader2,
  CheckCircle2,
} from "lucide-react";
import { cn } from "@/lib/utils";
import { useToast } from "@/components/ui/toast";
import { RichTextEditor } from "@/components/rich-text/rich-text-editor-lazy";
import { LEGAL } from "@/lib/legal-config";
import {
  EMAIL_TEMPLATES,
  CATEGORY_LABELS,
  EMAIL_VARIABLES,
  DEFAULT_SIGNATURE,
  renderTemplate,
  type EmailCategory,
} from "@/lib/email-templates";
import { sendPlatformEmail, type ComposeAttachment } from "@/app/admin/emails/actions";

export interface ComposeOpts {
  to?: string | string[];
  cc?: string[];
  subject?: string;
  body?: string;
  /** Valeurs pour {{prenom}}, {{formation}}… lors de l'insertion d'un modèle. */
  variables?: Record<string, string | undefined>;
  context?: string;
  relatedUserId?: string;
}

const DRAFT_KEY = "mft.email.draft.v1";
const MAX_BYTES = 8 * 1024 * 1024;
const EMOJIS = ["🙂", "👍", "🎉", "✅", "📌", "📎", "📅", "⏰", "🚚", "🎓", "💼", "🙏", "✨", "⚠️", "❤️", "👏"];

function toList(v?: string | string[]): string[] {
  if (!v) return [];
  return Array.isArray(v) ? v : [v];
}
function fmtBytes(n: number) {
  if (n < 1024) return `${n} o`;
  if (n < 1024 * 1024) return `${Math.round(n / 1024)} Ko`;
  return `${(n / (1024 * 1024)).toFixed(1)} Mo`;
}
function fileToBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const r = new FileReader();
    r.onload = () => resolve(String(r.result).split(",")[1] ?? "");
    r.onerror = reject;
    r.readAsDataURL(file);
  });
}

export function EmailComposer({ opts, onClose }: { opts: ComposeOpts; onClose: () => void }) {
  const { toast } = useToast();
  const vars = { ecole: LEGAL.brand, ...(opts.variables ?? {}) };

  const [to, setTo] = useState<string[]>(toList(opts.to));
  const [cc, setCc] = useState<string[]>(opts.cc ?? []);
  const [bcc, setBcc] = useState<string[]>([]);
  const [showCc, setShowCc] = useState((opts.cc ?? []).length > 0);
  const [showBcc, setShowBcc] = useState(false);
  const [subject, setSubject] = useState(opts.subject ?? "");
  const [body, setBody] = useState(opts.body ?? "");
  const [atts, setAtts] = useState<{ name: string; base64: string; size: number }[]>([]);
  const [minimized, setMinimized] = useState(false);
  const [expanded, setExpanded] = useState(false);
  const [sending, setSending] = useState(false);
  const [savedAt, setSavedAt] = useState<number | null>(null);
  const [dragOver, setDragOver] = useState(false);
  const [tplOpen, setTplOpen] = useState(false);
  const [varOpen, setVarOpen] = useState(false);
  const [emoOpen, setEmoOpen] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);
  const fresh = !opts.to && !opts.body && !opts.subject;

  // Reprise de brouillon (uniquement en composition vierge).
  useEffect(() => {
    if (!fresh) return;
    try {
      const raw = localStorage.getItem(DRAFT_KEY);
      if (!raw) return;
      const d = JSON.parse(raw);
      setTo(d.to ?? []); setCc(d.cc ?? []); setBcc(d.bcc ?? []);
      setSubject(d.subject ?? ""); setBody(d.body ?? "");
      if ((d.cc ?? []).length) setShowCc(true);
      if ((d.bcc ?? []).length) setShowBcc(true);
    } catch {}
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Sauvegarde auto (debounce).
  useEffect(() => {
    const id = setTimeout(() => {
      try {
        localStorage.setItem(DRAFT_KEY, JSON.stringify({ to, cc, bcc, subject, body }));
        setSavedAt(Date.now());
      } catch {}
    }, 800);
    return () => clearTimeout(id);
  }, [to, cc, bcc, subject, body]);

  const addFiles = useCallback(
    async (files: FileList | File[]) => {
      const list = Array.from(files);
      let total = atts.reduce((s, a) => s + a.size, 0);
      const next: typeof atts = [];
      for (const f of list) {
        if (total + f.size > MAX_BYTES) {
          toast("Pièces jointes trop volumineuses (8 Mo max).", "error");
          break;
        }
        next.push({ name: f.name, base64: await fileToBase64(f), size: f.size });
        total += f.size;
      }
      if (next.length) setAtts((a) => [...a, ...next]);
    },
    [atts, toast]
  );

  function applyTemplate(id: string) {
    const tpl = EMAIL_TEMPLATES.find((t) => t.id === id);
    if (!tpl) return;
    if (body.replace(/<[^>]+>/g, "").trim() && !window.confirm("Remplacer le contenu actuel par ce modèle ?")) return;
    setSubject(renderTemplate(tpl.subject, vars));
    setBody(renderTemplate(tpl.body, vars));
    setTplOpen(false);
  }

  async function handleSend() {
    if (to.length === 0) { toast("Ajoutez au moins un destinataire.", "error"); return; }
    if (!subject.trim()) { toast("L'objet est obligatoire.", "error"); return; }
    setSending(true);
    try {
      const res = await sendPlatformEmail({
        to, cc, bcc, subject,
        html: body,
        attachments: atts as ComposeAttachment[],
        context: opts.context ?? null,
        relatedUserId: opts.relatedUserId ?? null,
      });
      if (res.ok) {
        toast("Email envoyé.", "success");
        try { localStorage.removeItem(DRAFT_KEY); } catch {}
        onClose();
      } else {
        toast(res.error ?? "Échec de l'envoi.", "error");
      }
    } catch (e: any) {
      toast(e?.message ?? "Erreur réseau.", "error");
    } finally {
      setSending(false);
    }
  }

  const byCat: Record<EmailCategory, typeof EMAIL_TEMPLATES> = {
    stagiaire: [], formateur: [], administratif: [], commercial: [],
  };
  for (const t of EMAIL_TEMPLATES) byCat[t.category].push(t);

  // ── Fenêtre minimisée ───────────────────────────────────────────────
  if (minimized) {
    return (
      <button
        type="button"
        onClick={() => setMinimized(false)}
        className="fixed bottom-0 right-6 z-[60] flex items-center gap-3 rounded-t-xl bg-navy-900 px-4 py-2.5 text-white shadow-float hover:bg-navy-800 motion-safe:animate-fade-up"
      >
        <Send className="h-3.5 w-3.5 text-signal-400" />
        <span className="text-sm font-medium max-w-[200px] truncate">
          {subject.trim() || "Nouveau message"}
        </span>
        <Maximize2 className="h-3.5 w-3.5 opacity-70" />
      </button>
    );
  }

  const shellPos = expanded
    ? "inset-4 md:inset-x-auto md:right-8 md:left-auto md:top-8 md:bottom-8 md:w-[760px]"
    : "inset-x-2 bottom-2 md:inset-x-auto md:right-6 md:bottom-0 md:w-[560px]";

  return (
    <div
      className={cn("fixed z-[60] flex flex-col", shellPos)}
      role="dialog"
      aria-modal="false"
      aria-label="Nouveau message"
      onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
      onDragLeave={(e) => { e.preventDefault(); setDragOver(false); }}
      onDrop={(e) => { e.preventDefault(); setDragOver(false); if (e.dataTransfer.files?.length) addFiles(e.dataTransfer.files); }}
    >
      <div className="flex flex-col h-full rounded-t-2xl md:rounded-2xl border border-navy-200 bg-white shadow-float overflow-hidden dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))] motion-safe:animate-fade-up">
        {/* En-tête */}
        <div className="flex items-center justify-between bg-navy-900 px-4 py-2.5 text-white shrink-0">
          <span className="text-sm font-semibold">Nouveau message</span>
          <div className="flex items-center gap-1">
            <HdrBtn label="Réduire" onClick={() => setMinimized(true)}><Minus className="h-3.5 w-3.5" /></HdrBtn>
            <HdrBtn label={expanded ? "Réduire la fenêtre" : "Agrandir"} onClick={() => setExpanded((v) => !v)}>
              {expanded ? <Minimize2 className="h-3.5 w-3.5" /> : <Maximize2 className="h-3.5 w-3.5" />}
            </HdrBtn>
            <HdrBtn label="Fermer" onClick={onClose}><X className="h-4 w-4" /></HdrBtn>
          </div>
        </div>

        <div className="flex-1 overflow-y-auto">
          {/* Destinataires */}
          <RecipientRow label="À" value={to} onChange={setTo}
            right={
              <div className="flex items-center gap-2 text-[11px] text-slate-400">
                {!showCc && <button type="button" onClick={() => setShowCc(true)} className="hover:text-navy-700">Cc</button>}
                {!showBcc && <button type="button" onClick={() => setShowBcc(true)} className="hover:text-navy-700">Cci</button>}
              </div>
            }
          />
          {showCc && <RecipientRow label="Cc" value={cc} onChange={setCc} />}
          {showBcc && <RecipientRow label="Cci" value={bcc} onChange={setBcc} />}

          {/* Objet */}
          <div className="border-b border-navy-50 dark:border-[hsl(var(--border))] px-4">
            <input
              value={subject}
              onChange={(e) => setSubject(e.target.value)}
              placeholder="Objet"
              className="w-full bg-transparent py-2.5 text-sm font-medium text-navy-900 placeholder:text-slate-400 focus:outline-none dark:text-[hsl(var(--text))]"
            />
          </div>

          {/* Barre d'outils email (modèles / variables / signature / emoji / PJ) */}
          <div className="flex flex-wrap items-center gap-1.5 px-3 py-2 border-b border-navy-50 dark:border-[hsl(var(--border))]">
            <Menu open={tplOpen} setOpen={setTplOpen} label="Modèles" icon={<Sparkles className="h-3.5 w-3.5" />}>
              <div className="max-h-72 w-64 overflow-y-auto p-1">
                {(Object.keys(byCat) as EmailCategory[]).map((cat) => (
                  <div key={cat}>
                    <div className="px-2 pt-2 pb-1 text-[10px] font-bold uppercase tracking-wider text-lime-700 dark:text-signal-400">
                      {CATEGORY_LABELS[cat]}
                    </div>
                    {byCat[cat].map((t) => (
                      <button key={t.id} type="button" onClick={() => applyTemplate(t.id)}
                        className="block w-full rounded-md px-2 py-1.5 text-left text-[12.5px] text-navy-800 hover:bg-navy-50 dark:text-[hsl(var(--text))] dark:hover:bg-white/5">
                        {t.label}
                      </button>
                    ))}
                  </div>
                ))}
              </div>
            </Menu>

            <Menu open={varOpen} setOpen={setVarOpen} label="Variables" icon={<ChevronDown className="h-3 w-3" />}>
              <div className="w-52 p-1">
                <div className="px-2 py-1 text-[10px] text-slate-400">Insère un champ dynamique</div>
                {EMAIL_VARIABLES.map((v) => (
                  <button key={v.key} type="button"
                    onClick={() => { setBody((b) => b + ` {{${v.key}}}`); setVarOpen(false); }}
                    className="flex w-full items-center justify-between rounded-md px-2 py-1.5 text-left text-[12.5px] text-navy-800 hover:bg-navy-50 dark:text-[hsl(var(--text))] dark:hover:bg-white/5">
                    <span>{v.label}</span>
                    <code className="text-[10px] text-slate-400">{`{{${v.key}}}`}</code>
                  </button>
                ))}
              </div>
            </Menu>

            <ToolBtn onClick={() => setBody((b) => b + DEFAULT_SIGNATURE)} icon={<FileSignature className="h-3.5 w-3.5" />} label="Signature" />

            <Menu open={emoOpen} setOpen={setEmoOpen} label="" icon={<Smile className="h-3.5 w-3.5" />}>
              <div className="grid grid-cols-8 gap-0.5 p-2 w-56">
                {EMOJIS.map((e) => (
                  <button key={e} type="button" onClick={() => { setBody((b) => b + e); setEmoOpen(false); }}
                    className="h-7 w-7 rounded hover:bg-navy-50 dark:hover:bg-white/5 text-base">{e}</button>
                ))}
              </div>
            </Menu>

            <ToolBtn onClick={() => fileRef.current?.click()} icon={<Paperclip className="h-3.5 w-3.5" />} label="Joindre" />
            <input ref={fileRef} type="file" multiple className="hidden"
              accept=".pdf,.doc,.docx,.xls,.xlsx,.png,.jpg,.jpeg,.gif,.webp,.csv,.txt"
              onChange={(e) => { if (e.target.files) addFiles(e.target.files); e.target.value = ""; }} />
          </div>

          {/* Corps — éditeur riche */}
          <div className="p-3">
            <RichTextEditor value={body} onChange={setBody} placeholder="Rédigez votre message…" minHeight={expanded ? 320 : 200} />
          </div>

          {/* Pièces jointes */}
          {atts.length > 0 && (
            <div className="px-3 pb-3 flex flex-wrap gap-2">
              {atts.map((a, i) => (
                <div key={i} className="flex items-center gap-2 rounded-lg border border-navy-100 bg-navy-50/50 px-2.5 py-1.5 dark:border-[hsl(var(--border))] dark:bg-white/5">
                  <Paperclip className="h-3 w-3 text-slate-400" />
                  <span className="text-[11px] text-navy-800 max-w-[160px] truncate dark:text-[hsl(var(--text))]">{a.name}</span>
                  <span className="text-[10px] text-slate-400">{fmtBytes(a.size)}</span>
                  <button type="button" onClick={() => setAtts((x) => x.filter((_, j) => j !== i))} aria-label="Retirer" className="text-slate-400 hover:text-rose-600">
                    <Trash2 className="h-3 w-3" />
                  </button>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Pied : envoyer */}
        <div className="flex items-center justify-between gap-3 border-t border-navy-100 px-3 py-2.5 shrink-0 dark:border-[hsl(var(--border))]">
          <button type="button" onClick={handleSend} disabled={sending}
            className="inline-flex items-center gap-2 rounded-xl bg-navy-900 px-5 py-2 text-sm font-semibold text-white transition hover:bg-navy-800 disabled:opacity-60 active:scale-[0.98] motion-reduce:active:scale-100">
            {sending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Send className="h-4 w-4 text-signal-400" />}
            {sending ? "Envoi…" : "Envoyer"}
          </button>
          <div className="flex items-center gap-3">
            {savedAt && (
              <span className="inline-flex items-center gap-1 text-[10.5px] text-slate-400">
                <CheckCircle2 className="h-3 w-3 text-lime-600" /> Brouillon enregistré
              </span>
            )}
            <button type="button" onClick={() => { try { localStorage.removeItem(DRAFT_KEY); } catch {} onClose(); }}
              aria-label="Supprimer le brouillon" className="text-slate-400 hover:text-rose-600">
              <Trash2 className="h-4 w-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Overlay drag & drop */}
      {dragOver && (
        <div className="pointer-events-none absolute inset-0 z-10 flex items-center justify-center rounded-2xl border-2 border-dashed border-signal-500 bg-navy-900/70 text-white">
          <div className="text-center">
            <Paperclip className="mx-auto h-6 w-6 text-signal-400" />
            <p className="mt-2 text-sm font-semibold">Déposez vos fichiers</p>
          </div>
        </div>
      )}
    </div>
  );
}

function HdrBtn({ children, label, onClick }: { children: React.ReactNode; label: string; onClick: () => void }) {
  return (
    <button type="button" onClick={onClick} aria-label={label} title={label}
      className="inline-flex h-7 w-7 items-center justify-center rounded-md text-white/80 hover:bg-white/10 hover:text-white">
      {children}
    </button>
  );
}

function ToolBtn({ icon, label, onClick }: { icon: React.ReactNode; label: string; onClick: () => void }) {
  return (
    <button type="button" onClick={onClick} title={label}
      className="inline-flex items-center gap-1.5 rounded-lg border border-navy-100 bg-white px-2.5 h-7 text-[11.5px] font-medium text-navy-700 hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:bg-transparent dark:text-[hsl(var(--text))] dark:hover:bg-white/5">
      {icon}{label && <span>{label}</span>}
    </button>
  );
}

function Menu({ open, setOpen, label, icon, children }: {
  open: boolean; setOpen: (v: boolean) => void; label: string; icon: React.ReactNode; children: React.ReactNode;
}) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!open) return;
    const h = (e: MouseEvent) => { if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false); };
    document.addEventListener("mousedown", h);
    return () => document.removeEventListener("mousedown", h);
  }, [open, setOpen]);
  return (
    <div className="relative" ref={ref}>
      <button type="button" onClick={() => setOpen(!open)}
        className="inline-flex items-center gap-1.5 rounded-lg border border-navy-100 bg-white px-2.5 h-7 text-[11.5px] font-medium text-navy-700 hover:bg-navy-50 dark:border-[hsl(var(--border))] dark:bg-transparent dark:text-[hsl(var(--text))] dark:hover:bg-white/5">
        {icon}{label && <span>{label}</span>}
      </button>
      {open && (
        <div className="absolute top-full left-0 mt-1 z-20 rounded-xl border border-navy-100 bg-white shadow-raised dark:bg-[hsl(var(--surface))] dark:border-[hsl(var(--border))] motion-safe:animate-fade-up">
          {children}
        </div>
      )}
    </div>
  );
}

// Champ destinataires avec chips.
function RecipientRow({ label, value, onChange, right }: {
  label: string; value: string[]; onChange: (v: string[]) => void; right?: React.ReactNode;
}) {
  const [input, setInput] = useState("");
  const commit = (raw: string) => {
    const e = raw.trim().replace(/[,;]$/, "").toLowerCase();
    if (e && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e) && !value.includes(e)) onChange([...value, e]);
    setInput("");
  };
  return (
    <div className="flex items-center gap-2 border-b border-navy-50 dark:border-[hsl(var(--border))] px-4 py-1.5 min-h-[42px]">
      <span className="text-xs text-slate-400 w-7 shrink-0">{label}</span>
      <div className="flex flex-1 flex-wrap items-center gap-1.5">
        {value.map((e) => (
          <span key={e} className="inline-flex items-center gap-1 rounded-full bg-navy-50 px-2 py-0.5 text-[11px] text-navy-800 dark:bg-white/10 dark:text-[hsl(var(--text))]">
            {e}
            <button type="button" onClick={() => onChange(value.filter((x) => x !== e))} aria-label="Retirer" className="text-slate-400 hover:text-rose-600">
              <X className="h-3 w-3" />
            </button>
          </span>
        ))}
        <input
          value={input}
          onChange={(ev) => setInput(ev.target.value)}
          onKeyDown={(ev) => {
            if (ev.key === "Enter" || ev.key === "," || ev.key === ";") { ev.preventDefault(); commit(input); }
            else if (ev.key === "Backspace" && !input && value.length) onChange(value.slice(0, -1));
          }}
          onBlur={() => commit(input)}
          placeholder={value.length === 0 ? "adresse@email.fr" : ""}
          className="min-w-[120px] flex-1 bg-transparent py-1 text-sm text-navy-900 placeholder:text-slate-400 focus:outline-none dark:text-[hsl(var(--text))]"
        />
      </div>
      {right}
    </div>
  );
}
