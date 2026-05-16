import type { Meta, StoryObj } from "@storybook/react";
import { Badge } from "./badge";
import { CheckCircle2, AlertTriangle, Sparkles, Crown } from "lucide-react";

const meta = {
  title: "UI/Badge",
  component: Badge,
  parameters: { layout: "centered" },
  argTypes: {
    tone: {
      control: "select",
      options: ["navy", "gold", "success", "slate", "rose", "bc1", "bc2", "bc3"],
    },
    size: {
      control: "select",
      options: ["sm", "md"],
    },
  },
  args: {
    children: "Badge MFT",
    tone: "navy",
    size: "md",
  },
} satisfies Meta<typeof Badge>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Navy: Story = {};

export const Success: Story = {
  args: {
    tone: "success",
    children: (
      <>
        <CheckCircle2 className="h-3 w-3" /> Réussi
      </>
    ),
  },
};

export const Gold: Story = {
  args: {
    tone: "gold",
    children: (
      <>
        <Crown className="h-3 w-3" /> Premium
      </>
    ),
  },
};

export const Warning: Story = {
  args: {
    tone: "rose",
    children: (
      <>
        <AlertTriangle className="h-3 w-3" /> À risque
      </>
    ),
  },
};

export const SmallSize: Story = {
  args: { size: "sm", children: "Petit badge" },
};

export const CCPBlocks: Story = {
  render: () => (
    <div className="flex gap-2">
      <Badge tone="bc1">CCP 1</Badge>
      <Badge tone="bc2">CCP 2</Badge>
      <Badge tone="bc3">CCP 3</Badge>
    </div>
  ),
};

export const AllTones: Story = {
  render: () => (
    <div className="flex flex-wrap gap-2">
      <Badge tone="navy">Navy</Badge>
      <Badge tone="gold">Gold</Badge>
      <Badge tone="success">Success</Badge>
      <Badge tone="slate">Slate</Badge>
      <Badge tone="rose">Rose</Badge>
      <Badge tone="bc1">BC1</Badge>
      <Badge tone="bc2">BC2</Badge>
      <Badge tone="bc3">BC3</Badge>
    </div>
  ),
};
