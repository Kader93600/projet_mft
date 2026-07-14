import type { StorybookConfig } from "@storybook/nextjs";

const config: StorybookConfig = {
  stories: [
    "../components/**/*.stories.@(ts|tsx|js|jsx|mdx)",
    "../app/**/*.stories.@(ts|tsx|js|jsx|mdx)",
  ],
  framework: {
    name: "@storybook/nextjs",
    options: {},
  },
  staticDirs: ["../public"],
  typescript: {
    check: false,
    reactDocgen: false, // évite les erreurs sur les composants Next 14 avec generics
  },
};

export default config;
