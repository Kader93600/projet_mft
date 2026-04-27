import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        // === MA FORMATION TRANSPORT — palette de marque ===
        // Bleu royal du logo
        brand: {
          50:  "#EEF0FF",
          100: "#DDE1FE",
          200: "#B7BEFC",
          300: "#8993F8",
          400: "#5C6AF2",
          500: "#3845E5",
          600: "#2530D9", // primaire logo
          700: "#1E26B0",
          800: "#1A2189",
          900: "#161B66",
          950: "#0E1240",
        },
        // Vert lime signal du logo
        signal: {
          50:  "#F4FCE0",
          100: "#E7F8C0",
          200: "#D2F087",
          300: "#BEE74E",
          400: "#A8D729",
          500: "#9FE220", // accent CTA
          600: "#7EBE17",
          700: "#609015",
          800: "#4E7218",
          900: "#42601A",
        },
        // Nuit profonde — fond home dark mode
        night: {
          DEFAULT: "#0B0F24",
          50:  "#1A2040",
          100: "#161B36",
          200: "#13182E",
          300: "#101526",
          400: "#0D121F",
          500: "#0B0F24",
          600: "#080C1B",
          700: "#060912",
          800: "#04060B",
          900: "#020306",
        },

        // === Aliases rétro-compat — pointent désormais vers brand / signal ===
        // Toutes les pages existantes (admin, stagiaire, formateur)
        // récupèrent automatiquement la nouvelle charte MA FORMATION TRANSPORT.
        navy: {
          50:  "#EEF0FF",
          100: "#DDE1FE",
          200: "#B7BEFC",
          300: "#8993F8",
          400: "#5C6AF2",
          500: "#3845E5",
          600: "#2530D9",
          700: "#1E26B0",
          800: "#1A2189",
          900: "#161B66",
          950: "#0E1240",
        },
        gold: {
          50:  "#F4FCE0",
          100: "#E7F8C0",
          200: "#D2F087",
          300: "#BEE74E",
          400: "#A8D729",
          500: "#9FE220",
          600: "#7EBE17",
          700: "#609015",
          800: "#4E7218",
          900: "#42601A",
        },
        // Or chaud conservé sous "amber" pour les badges Qualiopi spécifiques
        // (à utiliser ponctuellement si on veut une couleur "or de certification").
        amber: {
          50:  "#FEFAEC",
          100: "#FDF2CD",
          200: "#FBE595",
          300: "#F9D25D",
          400: "#F7BE2E",
          500: "#F59E0B",
          600: "#D07905",
          700: "#AD5A08",
          800: "#8C470E",
          900: "#733C10",
        },
        ivory: "#FAFAF7",
        ink:   "#0B1220",
        surface: {
          DEFAULT: "#FAFAF7",
          raised: "#FFFFFF",
          sunken: "#F3F4EE",
        },
      },
      fontFamily: {
        display: ["var(--font-fraunces)", "Georgia", "serif"],
        sans: ["var(--font-inter)", "system-ui", "sans-serif"],
        mono: ["var(--font-jetbrains)", "ui-monospace", "monospace"],
      },
      fontSize: {
        "2xs": ["0.6875rem", { lineHeight: "1rem" }],
      },
      boxShadow: {
        // Ombres neutres : on utilise désormais le bleu de marque pour la teinte
        "soft":   "0 1px 2px rgba(14,18,64,0.05), 0 1px 3px rgba(14,18,64,0.07)",
        "raised": "0 2px 4px rgba(14,18,64,0.05), 0 8px 24px rgba(14,18,64,0.10)",
        "float":  "0 8px 32px rgba(14,18,64,0.14), 0 2px 8px rgba(14,18,64,0.05)",
        // Aliases rétro-compat — pointent désormais vers brand / signal
        "ring-gold": "0 0 0 3px rgba(159,226,32,0.30)",
        "ring-navy": "0 0 0 3px rgba(37,48,217,0.20)",
        // Tokens marque (à utiliser dans le nouveau code)
        "ring-brand":  "0 0 0 3px rgba(37,48,217,0.20)",
        "ring-signal": "0 0 0 3px rgba(159,226,32,0.30)",
        "glow-brand":  "0 0 40px -8px rgba(37,48,217,0.55)",
        "glow-signal": "0 0 40px -8px rgba(159,226,32,0.50)",
      },
      borderRadius: {
        "4xl": "2rem",
        "5xl": "2.5rem",
      },
      backgroundImage: {
        "grid-navy":
          "linear-gradient(to right, rgba(37,48,217,0.06) 1px, transparent 1px), linear-gradient(to bottom, rgba(37,48,217,0.06) 1px, transparent 1px)",
        "mesh-navy":
          "radial-gradient(at 20% 20%, rgba(37,48,217,0.12) 0, transparent 50%), radial-gradient(at 80% 30%, rgba(159,226,32,0.10) 0, transparent 50%), radial-gradient(at 50% 90%, rgba(37,48,217,0.08) 0, transparent 50%)",
        // Mesh nuit pour la vitrine
        "mesh-night":
          "radial-gradient(at 18% 22%, rgba(37,48,217,0.30) 0, transparent 55%), radial-gradient(at 80% 30%, rgba(159,226,32,0.10) 0, transparent 55%), radial-gradient(at 60% 95%, rgba(37,48,217,0.20) 0, transparent 55%)",
        "grid-night":
          "linear-gradient(to right, rgba(255,255,255,0.04) 1px, transparent 1px), linear-gradient(to bottom, rgba(255,255,255,0.04) 1px, transparent 1px)",
      },
      keyframes: {
        "fade-up": {
          "0%": { opacity: "0", transform: "translateY(8px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
        shimmer: {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
        // Nouvelles animations vitrine
        "road-pulse": {
          "0%, 100%": { opacity: "0.4", transform: "scaleX(1)" },
          "50%": { opacity: "1", transform: "scaleX(1.02)" },
        },
        "float-slow": {
          "0%, 100%": { transform: "translateY(0)" },
          "50%": { transform: "translateY(-8px)" },
        },
        "spin-slow": {
          "0%": { transform: "rotate(0deg)" },
          "100%": { transform: "rotate(360deg)" },
        },
        "draw-path": {
          "0%": { strokeDashoffset: "1000" },
          "100%": { strokeDashoffset: "0" },
        },
        "marquee-x": {
          "0%": { transform: "translateX(0)" },
          "100%": { transform: "translateX(-50%)" },
        },
        "glow-pulse": {
          "0%, 100%": { opacity: "0.4" },
          "50%": { opacity: "0.9" },
        },
      },
      animation: {
        "fade-up": "fade-up 0.5s ease-out",
        shimmer: "shimmer 2s linear infinite",
        "road-pulse": "road-pulse 2.5s ease-in-out infinite",
        "float-slow": "float-slow 6s ease-in-out infinite",
        "spin-slow": "spin-slow 30s linear infinite",
        "draw-path": "draw-path 2s ease-out forwards",
        "marquee-x": "marquee-x 40s linear infinite",
        "glow-pulse": "glow-pulse 3s ease-in-out infinite",
      },
    },
  },
  plugins: [],
};

export default config;
