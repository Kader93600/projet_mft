import { describe, it, expect } from "vitest";
import { getRank, RANKS_LIST } from "./ranks";

describe("getRank", () => {
  it("mappe le niveau sur le bon rang", () => {
    expect(getRank(1).rank.id).toBe("debutant");
    expect(getRank(4).rank.id).toBe("debutant");
    expect(getRank(5).rank.id).toBe("intermediaire");
    expect(getRank(9).rank.id).toBe("intermediaire");
    expect(getRank(10).rank.id).toBe("avance");
    expect(getRank(15).rank.id).toBe("expert");
    expect(getRank(24).rank.id).toBe("expert");
    expect(getRank(25).rank.id).toBe("master");
    expect(getRank(99).rank.id).toBe("master");
  });

  it("borne les niveaux invalides", () => {
    expect(getRank(0).rank.id).toBe("debutant");
    expect(getRank(-3).rank.id).toBe("debutant");
    expect(getRank(NaN).rank.id).toBe("debutant");
  });

  it("calcule le rang suivant et les niveaux restants", () => {
    const d = getRank(3);
    expect(d.next?.id).toBe("intermediaire");
    expect(d.levelsToNext).toBe(2); // 5 - 3

    const master = getRank(30);
    expect(master.next).toBeNull();
    expect(master.levelsToNext).toBeNull();
  });

  it("expose 5 rangs ordonnés par niveau croissant", () => {
    expect(RANKS_LIST).toHaveLength(5);
    for (let i = 1; i < RANKS_LIST.length; i++) {
      expect(RANKS_LIST[i].minLevel).toBeGreaterThan(RANKS_LIST[i - 1].minLevel);
    }
  });
});
