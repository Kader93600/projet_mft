import type { Meta, StoryObj } from "@storybook/react";
import { Card, CardBody, CardTitle } from "./card";
import { Button } from "./button";
import { Badge } from "./badge";
import { Sparkles, ArrowRight } from "lucide-react";

const meta = {
  title: "UI/Card",
  component: Card,
  parameters: { layout: "padded" },
  argTypes: {
    variant: {
      control: "select",
      options: ["default", "outline", "solid-navy", "gold"],
    },
  },
} satisfies Meta<typeof Card>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  render: (args) => (
    <Card {...args} className="max-w-md">
      <CardBody>
        <CardTitle>Titre de la carte</CardTitle>
        <p className="text-sm text-slate-600 mt-2">
          Une carte par défaut MFT. Sert de conteneur pour les sections
          du dashboard et des pages.
        </p>
      </CardBody>
    </Card>
  ),
};

export const WithAction: Story = {
  render: (args) => (
    <Card {...args} className="max-w-md">
      <CardBody>
        <div className="flex items-start justify-between gap-3">
          <div>
            <Badge tone="gold" size="sm">
              <Sparkles className="h-3 w-3" />
              Premium
            </Badge>
            <CardTitle className="mt-2">Session présentielle</CardTitle>
            <p className="text-sm text-slate-600 mt-1">
              Webinaire avec votre formateur, mardi 20 mai à 14 h.
            </p>
          </div>
        </div>
        <div className="mt-4 flex justify-end">
          <Button size="sm" variant="gold">
            S'inscrire <ArrowRight className="h-3.5 w-3.5" />
          </Button>
        </div>
      </CardBody>
    </Card>
  ),
};

export const Outline: Story = {
  args: { variant: "outline" },
  render: Default.render,
};

export const SolidNavy: Story = {
  args: { variant: "solid-navy" },
  render: (args) => (
    <Card {...args} className="max-w-md">
      <CardBody>
        <CardTitle>Section premium navy</CardTitle>
        <p className="text-sm text-white/80 mt-2">
          Fond navy pour les sections héro ou des CTA importants.
        </p>
      </CardBody>
    </Card>
  ),
};

export const Gold: Story = {
  args: { variant: "gold" },
  render: (args) => (
    <Card {...args} className="max-w-md">
      <CardBody>
        <CardTitle>Pack Premium</CardTitle>
        <p className="text-sm text-slate-700 mt-2">
          Variante or pour mettre en avant les offres premium.
        </p>
      </CardBody>
    </Card>
  ),
};

export const AllVariants: Story = {
  render: () => (
    <div className="grid sm:grid-cols-2 gap-4 max-w-3xl">
      <Card>
        <CardBody>
          <CardTitle>Default</CardTitle>
          <p className="text-sm text-slate-600 mt-1">Carte par défaut</p>
        </CardBody>
      </Card>
      <Card variant="outline">
        <CardBody>
          <CardTitle>Outline</CardTitle>
          <p className="text-sm text-slate-600 mt-1">Sans ombre</p>
        </CardBody>
      </Card>
      <Card variant="solid-navy">
        <CardBody>
          <CardTitle>Solid Navy</CardTitle>
          <p className="text-sm text-white/80 mt-1">Fond plein</p>
        </CardBody>
      </Card>
      <Card variant="gold">
        <CardBody>
          <CardTitle>Gold</CardTitle>
          <p className="text-sm text-slate-700 mt-1">Premium</p>
        </CardBody>
      </Card>
    </div>
  ),
};
