import type { Preview } from "@storybook/react";
import "../app/globals.css";

const preview: Preview = {
  parameters: {
    actions: { argTypesRegex: "^on[A-Z].*" },
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/i,
      },
    },
    backgrounds: {
      default: "ivory",
      values: [
        { name: "ivory", value: "#FAF8F4" },
        { name: "white", value: "#ffffff" },
        { name: "navy", value: "#0E1240" },
      ],
    },
    layout: "padded",
  },
  tags: ["autodocs"],
};

export default preview;
