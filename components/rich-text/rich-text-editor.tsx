"use client";

import { useEditor, EditorContent, type Editor } from "@tiptap/react";
import StarterKit from "@tiptap/starter-kit";
import Link from "@tiptap/extension-link";
import Image from "@tiptap/extension-image";
import TextAlign from "@tiptap/extension-text-align";
import Underline from "@tiptap/extension-underline";
import TextStyle from "@tiptap/extension-text-style";
import Color from "@tiptap/extension-color";
import FontFamily from "@tiptap/extension-font-family";
import Placeholder from "@tiptap/extension-placeholder";
import Table from "@tiptap/extension-table";
import TableRow from "@tiptap/extension-table-row";
import TableHeader from "@tiptap/extension-table-header";
import TableCell from "@tiptap/extension-table-cell";
import { useEffect, useMemo, useState } from "react";
import { isRichTextHtml, plainTextToHtml } from "@/lib/rich-text";
import {
  Bold,
  Italic,
  Underline as UnderlineIcon,
  Strikethrough,
  Heading1,
  Heading2,
  Heading3,
  List,
  ListOrdered,
  AlignLeft,
  AlignCenter,
  AlignRight,
  AlignJustify,
  Link as LinkIcon,
  Image as ImageIcon,
  Table as TableIcon,
  Quote,
  Minus,
  Code,
  Undo,
  Redo,
  Type,
} from "lucide-react";

const FONT_FAMILIES = [
  { label: "Sans-serif", value: "Inter, system-ui, sans-serif" },
  { label: "Serif", value: "Georgia, serif" },
  { label: "Mono", value: "ui-monospace, SFMono-Regular, monospace" },
  { label: "Tahoma", value: "Tahoma, sans-serif" },
  { label: "Arial", value: "Arial, sans-serif" },
  { label: "Times", value: '"Times New Roman", Times, serif' },
];

const COLORS = [
  "#0E1240", // navy-950
  "#2530D9", // brand-600
  "#609015", // signal-700
  "#92400E", // amber-800
  "#BE123C", // rose-700
  "#0369A1", // sky-700
  "#475569", // slate-600
  "#000000",
];

/**
 * Éditeur de texte enrichi basé sur TipTap, style Notion/Google Docs.
 *
 * Output : HTML qui sera sanitizé côté server avant persist en DB.
 *
 * Utilisation :
 *   <RichTextEditor
 *     value={statement}
 *     onChange={setStatement}
 *     placeholder="Saisir l'énoncé…"
 *   />
 */
export function RichTextEditor({
  value,
  onChange,
  placeholder = "Saisir le contenu…",
  minHeight = 200,
  className,
}: {
  value: string;
  onChange: (html: string) => void;
  placeholder?: string;
  minHeight?: number;
  className?: string;
}) {
  // Normalise la valeur initiale : si on reçoit du texte brut (cas
  // rétro-compat avec les questions historiques), on le convertit en
  // HTML simple pour préserver les sauts de ligne dans TipTap.
  const initialContent = useMemo(() => {
    if (!value) return "";
    return isRichTextHtml(value) ? value : plainTextToHtml(value);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  const editor = useEditor({
    extensions: [
      StarterKit.configure({
        heading: { levels: [1, 2, 3, 4] },
      }),
      Underline,
      TextAlign.configure({ types: ["heading", "paragraph"] }),
      TextStyle,
      Color,
      FontFamily,
      Link.configure({
        openOnClick: false,
        HTMLAttributes: {
          target: "_blank",
          rel: "noopener noreferrer nofollow",
          class: "text-brand-700 underline",
        },
      }),
      Image.configure({
        HTMLAttributes: { class: "rounded-lg my-2 max-w-full h-auto" },
      }),
      Table.configure({ resizable: false, HTMLAttributes: { class: "tiptap-table" } }),
      TableRow,
      TableHeader,
      TableCell,
      Placeholder.configure({ placeholder }),
    ],
    content: initialContent,
    editorProps: {
      attributes: {
        class:
          "tiptap-editor focus:outline-none px-3.5 py-3 text-[14.5px] text-navy-900 leading-relaxed",
        style: `min-height: ${minHeight}px`,
      },
    },
    onUpdate({ editor }) {
      onChange(editor.getHTML());
    },
    immediatelyRender: false,
  });

  // Sync externe : si la prop value change drastiquement (changement de
  // question affichée), on remet l'éditeur à jour. On évite la boucle
  // infinie en comparant à getHTML().
  useEffect(() => {
    if (!editor) return;
    const normalized = isRichTextHtml(value) ? value : plainTextToHtml(value);
    if (normalized === editor.getHTML()) return;
    editor.commands.setContent(normalized || "", false);
  }, [value, editor]);

  if (!editor) {
    return (
      <div
        className={
          "rounded-xl border border-navy-200 bg-white animate-pulse " +
          (className ?? "")
        }
        style={{ minHeight: minHeight + 50 }}
      />
    );
  }

  return (
    <div
      className={
        "rounded-xl border border-navy-200 bg-white overflow-hidden " +
        (className ?? "")
      }
    >
      <Toolbar editor={editor} />
      <EditorContent editor={editor} />
    </div>
  );
}

// =====================================================================
// Toolbar — style Notion / Google Docs
// =====================================================================
function Toolbar({ editor }: { editor: Editor }) {
  return (
    <div className="flex items-center gap-0.5 px-2 py-1.5 border-b border-navy-100 bg-ivory flex-wrap">
      {/* Style block */}
      <select
        value={
          editor.isActive("heading", { level: 1 })
            ? "h1"
            : editor.isActive("heading", { level: 2 })
              ? "h2"
              : editor.isActive("heading", { level: 3 })
                ? "h3"
                : editor.isActive("heading", { level: 4 })
                  ? "h4"
                  : "p"
        }
        onChange={(e) => {
          const v = e.target.value;
          if (v === "p") editor.chain().focus().setParagraph().run();
          else
            editor
              .chain()
              .focus()
              .toggleHeading({ level: parseInt(v[1], 10) as 1 | 2 | 3 | 4 })
              .run();
        }}
        className="h-7 rounded-md border border-navy-100 bg-white px-1.5 text-[11.5px] text-navy-900"
        title="Style du paragraphe"
      >
        <option value="p">Normal</option>
        <option value="h1">Titre 1</option>
        <option value="h2">Titre 2</option>
        <option value="h3">Titre 3</option>
        <option value="h4">Titre 4</option>
      </select>

      {/* Police */}
      <select
        onChange={(e) => {
          const v = e.target.value;
          if (v) editor.chain().focus().setFontFamily(v).run();
          else editor.chain().focus().unsetFontFamily().run();
        }}
        className="h-7 rounded-md border border-navy-100 bg-white px-1.5 text-[11.5px] text-navy-900"
        title="Police"
        defaultValue=""
      >
        <option value="">Police</option>
        {FONT_FAMILIES.map((f) => (
          <option key={f.value} value={f.value}>
            {f.label}
          </option>
        ))}
      </select>

      <Divider />

      {/* Bold / Italic / Underline / Strike */}
      <Btn
        active={editor.isActive("bold")}
        onClick={() => editor.chain().focus().toggleBold().run()}
        label="Gras (Ctrl+B)"
      >
        <Bold className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive("italic")}
        onClick={() => editor.chain().focus().toggleItalic().run()}
        label="Italique (Ctrl+I)"
      >
        <Italic className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive("underline")}
        onClick={() => editor.chain().focus().toggleUnderline().run()}
        label="Souligné (Ctrl+U)"
      >
        <UnderlineIcon className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive("strike")}
        onClick={() => editor.chain().focus().toggleStrike().run()}
        label="Barré"
      >
        <Strikethrough className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive("code")}
        onClick={() => editor.chain().focus().toggleCode().run()}
        label="Code en ligne"
      >
        <Code className="h-3.5 w-3.5" />
      </Btn>

      <Divider />

      {/* Couleur du texte */}
      <ColorPicker editor={editor} />

      <Divider />

      {/* Alignement */}
      <Btn
        active={editor.isActive({ textAlign: "left" })}
        onClick={() => editor.chain().focus().setTextAlign("left").run()}
        label="Aligner à gauche"
      >
        <AlignLeft className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive({ textAlign: "center" })}
        onClick={() => editor.chain().focus().setTextAlign("center").run()}
        label="Centrer"
      >
        <AlignCenter className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive({ textAlign: "right" })}
        onClick={() => editor.chain().focus().setTextAlign("right").run()}
        label="Aligner à droite"
      >
        <AlignRight className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive({ textAlign: "justify" })}
        onClick={() => editor.chain().focus().setTextAlign("justify").run()}
        label="Justifier"
      >
        <AlignJustify className="h-3.5 w-3.5" />
      </Btn>

      <Divider />

      {/* Listes */}
      <Btn
        active={editor.isActive("bulletList")}
        onClick={() => editor.chain().focus().toggleBulletList().run()}
        label="Liste à puces"
      >
        <List className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive("orderedList")}
        onClick={() => editor.chain().focus().toggleOrderedList().run()}
        label="Liste numérotée"
      >
        <ListOrdered className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        active={editor.isActive("blockquote")}
        onClick={() => editor.chain().focus().toggleBlockquote().run()}
        label="Citation"
      >
        <Quote className="h-3.5 w-3.5" />
      </Btn>

      <Divider />

      {/* Insertions */}
      <Btn
        onClick={() => {
          const url = window.prompt("URL du lien (ex. https://...) :");
          if (url) {
            editor.chain().focus().setLink({ href: url }).run();
          }
        }}
        active={editor.isActive("link")}
        label="Insérer un lien"
      >
        <LinkIcon className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        onClick={() => {
          const url = window.prompt("URL de l'image :");
          if (url) editor.chain().focus().setImage({ src: url }).run();
        }}
        label="Insérer une image"
      >
        <ImageIcon className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        onClick={() => {
          // Demande la taille à l'admin avec un default 15×15 (le plus
          // demandé pour les exercices type livret) tout en gardant la
          // flexibilité d'en choisir une autre.
          const sizeStr = window.prompt(
            "Taille du tableau (format : lignes×colonnes)",
            "15×15",
          );
          if (!sizeStr) return;
          const m = sizeStr
            .replace(/[xX]/g, "×")
            .match(/(\d{1,3})\s*×\s*(\d{1,3})/);
          const rows = m ? Math.max(1, Math.min(50, parseInt(m[1], 10))) : 15;
          const cols = m ? Math.max(1, Math.min(20, parseInt(m[2], 10))) : 15;
          editor
            .chain()
            .focus()
            .insertTable({ rows, cols, withHeaderRow: true })
            .run();
        }}
        label="Insérer un tableau (défaut 15×15)"
      >
        <TableIcon className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        onClick={() => editor.chain().focus().setHorizontalRule().run()}
        label="Séparateur horizontal"
      >
        <Minus className="h-3.5 w-3.5" />
      </Btn>

      <Divider />

      {/* Undo / Redo */}
      <Btn
        onClick={() => editor.chain().focus().undo().run()}
        disabled={!editor.can().undo()}
        label="Annuler (Ctrl+Z)"
      >
        <Undo className="h-3.5 w-3.5" />
      </Btn>
      <Btn
        onClick={() => editor.chain().focus().redo().run()}
        disabled={!editor.can().redo()}
        label="Refaire (Ctrl+Shift+Z)"
      >
        <Redo className="h-3.5 w-3.5" />
      </Btn>

      {/* Tableau : actions contextuelles si dans un tableau */}
      {editor.isActive("table") && (
        <>
          <Divider />
          <button
            type="button"
            onClick={() => editor.chain().focus().addRowAfter().run()}
            className="px-2 h-7 rounded-md border border-navy-100 text-[10.5px] text-navy-700 hover:bg-navy-50 font-semibold"
            title="Ajouter une ligne en dessous"
          >
            + ligne
          </button>
          <button
            type="button"
            onClick={() => editor.chain().focus().addColumnAfter().run()}
            className="px-2 h-7 rounded-md border border-navy-100 text-[10.5px] text-navy-700 hover:bg-navy-50 font-semibold"
            title="Ajouter une colonne à droite"
          >
            + col
          </button>
          <button
            type="button"
            onClick={() => editor.chain().focus().deleteRow().run()}
            className="px-2 h-7 rounded-md border border-rose-100 text-[10.5px] text-rose-700 hover:bg-rose-50 font-semibold"
            title="Supprimer la ligne courante"
          >
            − ligne
          </button>
          <button
            type="button"
            onClick={() => editor.chain().focus().deleteColumn().run()}
            className="px-2 h-7 rounded-md border border-rose-100 text-[10.5px] text-rose-700 hover:bg-rose-50 font-semibold"
            title="Supprimer la colonne courante"
          >
            − col
          </button>
          <button
            type="button"
            onClick={() => editor.chain().focus().deleteTable().run()}
            className="px-2 h-7 rounded-md border border-rose-200 text-[10.5px] text-rose-800 hover:bg-rose-100 font-semibold"
            title="Supprimer le tableau entier"
          >
            ⌫ table
          </button>
        </>
      )}
    </div>
  );
}

function Btn({
  children,
  onClick,
  active,
  disabled,
  label,
}: {
  children: React.ReactNode;
  onClick: () => void;
  active?: boolean;
  disabled?: boolean;
  label: string;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      title={label}
      aria-label={label}
      aria-pressed={active}
      className={
        "h-7 w-7 inline-flex items-center justify-center rounded-md border transition " +
        (active
          ? "bg-navy-900 text-white border-navy-900"
          : "bg-white text-navy-700 border-navy-100 hover:bg-navy-50 hover:border-navy-200 disabled:opacity-40 disabled:hover:bg-white")
      }
    >
      {children}
    </button>
  );
}

function Divider() {
  return <span className="inline-block h-5 w-px bg-navy-100 mx-0.5" />;
}

function ColorPicker({ editor }: { editor: Editor }) {
  const [open, setOpen] = useState(false);
  const current = editor.getAttributes("textStyle").color || "#0E1240";
  return (
    <div className="relative">
      <button
        type="button"
        onClick={() => setOpen(!open)}
        className="h-7 w-7 inline-flex items-center justify-center rounded-md border border-navy-100 bg-white hover:bg-navy-50"
        title="Couleur du texte"
        aria-label="Couleur du texte"
      >
        <Type className="h-3.5 w-3.5" style={{ color: current }} />
      </button>
      {open && (
        <div className="absolute top-full left-0 mt-1 z-50 rounded-lg border border-navy-100 bg-white shadow-raised p-2 flex gap-1">
          {COLORS.map((c) => (
            <button
              key={c}
              type="button"
              onClick={() => {
                editor.chain().focus().setColor(c).run();
                setOpen(false);
              }}
              className="h-5 w-5 rounded-md border border-navy-200 hover:scale-110 transition"
              style={{ backgroundColor: c }}
              aria-label={`Couleur ${c}`}
            />
          ))}
          <button
            type="button"
            onClick={() => {
              editor.chain().focus().unsetColor().run();
              setOpen(false);
            }}
            className="h-5 w-5 rounded-md border border-navy-200 hover:scale-110 transition bg-white text-[9px] text-slate-500"
            title="Couleur par défaut"
          >
            ×
          </button>
        </div>
      )}
    </div>
  );
}
