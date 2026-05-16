import type { Meta, StoryObj } from "@storybook/react";
import { ProgressBar, RadialProgress } from "./progress";

const meta = {
  title: "UI/ProgressBar",
  component: ProgressBar,
  parameters: { layout: "padded" },
  argTypes: {
    value: { control: { type: "range", min: 0, max: 100, step: 1 } },
  },
  args: { value: 65 },
} satisfies Meta<typeof ProgressBar>;

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {};

export const Empty: Story = { args: { value: 0 } };
export const Quarter: Story = { args: { value: 25 } };
export const Half: Story = { args: { value: 50 } };
export const Almost: Story = { args: { value: 85 } };
export const Complete: Story = { args: { value: 100 } };

export const Scale: Story = {
  render: () => (
    <div className="space-y-4 max-w-md">
      <div>
        <div className="text-xs text-slate-500 mb-1">0 %</div>
        <ProgressBar value={0} />
      </div>
      <div>
        <div className="text-xs text-slate-500 mb-1">25 %</div>
        <ProgressBar value={25} />
      </div>
      <div>
        <div className="text-xs text-slate-500 mb-1">50 %</div>
        <ProgressBar value={50} />
      </div>
      <div>
        <div className="text-xs text-slate-500 mb-1">75 %</div>
        <ProgressBar value={75} />
      </div>
      <div>
        <div className="text-xs text-slate-500 mb-1">100 %</div>
        <ProgressBar value={100} />
      </div>
    </div>
  ),
};

// ---------------------------------------------------------------------
// RadialProgress
// ---------------------------------------------------------------------
const radialMeta = {
  title: "UI/RadialProgress",
  component: RadialProgress,
  parameters: { layout: "centered" },
} satisfies Meta<typeof RadialProgress>;

export const Radial: StoryObj<typeof radialMeta> = {
  args: { value: 78, size: 160, strokeWidth: 12 },
  render: (args) => (
    <RadialProgress
      {...args}
      label={
        <div className="text-center">
          <div className="font-display text-4xl font-semibold text-navy-900">
            {args.value}%
          </div>
        </div>
      }
    />
  ),
};

export const RadialPassed: StoryObj<typeof radialMeta> = {
  args: { value: 85, size: 120 },
  render: (args) => (
    <RadialProgress
      {...args}
      label={
        <div className="text-emerald-700 font-display text-2xl font-semibold">
          {args.value}%
        </div>
      }
    />
  ),
};
