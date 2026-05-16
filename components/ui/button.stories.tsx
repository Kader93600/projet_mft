import type { Meta, StoryObj } from "@storybook/react";
import { Button } from "./button";
import { CheckCircle2, Loader2, ArrowRight, Trash2 } from "lucide-react";

const meta = {
  title: "UI/Button",
  component: Button,
  parameters: { layout: "centered" },
  argTypes: {
    variant: {
      control: "select",
      options: ["primary", "secondary", "outline", "ghost", "gold", "danger"],
    },
    size: {
      control: "select",
      options: ["sm", "md", "lg"],
    },
    disabled: { control: "boolean" },
  },
  args: {
    children: "Bouton MFT",
    variant: "primary",
    size: "md",
  },
} satisfies Meta<typeof Button>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Primary: Story = {};

export const Secondary: Story = {
  args: { variant: "secondary", children: "Annuler" },
};

export const Gold: Story = {
  args: {
    variant: "gold",
    children: (
      <>
        <CheckCircle2 className="h-4 w-4" /> Valider
      </>
    ),
  },
};

export const Danger: Story = {
  args: {
    variant: "danger",
    children: (
      <>
        <Trash2 className="h-4 w-4" /> Supprimer
      </>
    ),
  },
};

export const Outline: Story = {
  args: { variant: "outline" },
};

export const Ghost: Story = {
  args: { variant: "ghost", children: "Action discrète" },
};

export const Small: Story = {
  args: { size: "sm", children: "Petit" },
};

export const Large: Story = {
  args: {
    size: "lg",
    children: (
      <>
        Continuer <ArrowRight className="h-4 w-4" />
      </>
    ),
  },
};

export const Loading: Story = {
  args: {
    disabled: true,
    children: (
      <>
        <Loader2 className="h-4 w-4 animate-spin" /> Enregistrement…
      </>
    ),
  },
};

export const Disabled: Story = {
  args: { disabled: true, children: "Désactivé" },
};

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap gap-3">
      <Button variant="primary">Primary</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="gold">Gold</Button>
      <Button variant="danger">Danger</Button>
    </div>
  ),
};
