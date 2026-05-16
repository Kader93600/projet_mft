import { describe, it, expect } from "vitest";
import {
  isStaff,
  isAdmin,
  isSuperAdmin,
  canManageStudents,
  isStudent,
  isTrainer,
  isTrainerAllowedAdminRoute,
  canAccessAdminRoute,
} from "./permissions";

describe("isStaff / isAdmin (alias)", () => {
  it("true pour admin et super_admin", () => {
    expect(isStaff("admin")).toBe(true);
    expect(isStaff("super_admin")).toBe(true);
    expect(isAdmin("admin")).toBe(true);
    expect(isAdmin("super_admin")).toBe(true);
  });
  it("false pour trainer et student", () => {
    expect(isStaff("trainer")).toBe(false);
    expect(isStaff("student")).toBe(false);
  });
  it("false pour null / undefined / inconnu", () => {
    expect(isStaff(null)).toBe(false);
    expect(isStaff(undefined)).toBe(false);
    expect(isStaff("guest")).toBe(false);
  });
});

describe("isSuperAdmin", () => {
  it("true uniquement pour super_admin", () => {
    expect(isSuperAdmin("super_admin")).toBe(true);
    expect(isSuperAdmin("admin")).toBe(false);
    expect(isSuperAdmin("trainer")).toBe(false);
    expect(isSuperAdmin("student")).toBe(false);
    expect(isSuperAdmin(null)).toBe(false);
  });
});

describe("canManageStudents", () => {
  it("true pour trainer, admin, super_admin", () => {
    expect(canManageStudents("trainer")).toBe(true);
    expect(canManageStudents("admin")).toBe(true);
    expect(canManageStudents("super_admin")).toBe(true);
  });
  it("false pour student", () => {
    expect(canManageStudents("student")).toBe(false);
    expect(canManageStudents(null)).toBe(false);
  });
});

describe("isStudent / isTrainer", () => {
  it("isStudent true uniquement pour student", () => {
    expect(isStudent("student")).toBe(true);
    expect(isStudent("trainer")).toBe(false);
    expect(isStudent("admin")).toBe(false);
  });
  it("isTrainer true uniquement pour trainer", () => {
    expect(isTrainer("trainer")).toBe(true);
    expect(isTrainer("admin")).toBe(false);
    expect(isTrainer("super_admin")).toBe(false);
  });
});

describe("isTrainerAllowedAdminRoute", () => {
  it("autorise les routes pédagogiques whitelistées", () => {
    expect(isTrainerAllowedAdminRoute("/admin/modules")).toBe(true);
    expect(isTrainerAllowedAdminRoute("/admin/modules/123")).toBe(true);
    expect(isTrainerAllowedAdminRoute("/admin/quizzes")).toBe(true);
    expect(isTrainerAllowedAdminRoute("/admin/banque-questions")).toBe(true);
    expect(isTrainerAllowedAdminRoute("/admin/placement")).toBe(true);
    expect(isTrainerAllowedAdminRoute("/admin/sessions")).toBe(true);
  });
  it("refuse les routes admin sensibles", () => {
    expect(isTrainerAllowedAdminRoute("/admin/users")).toBe(false);
    expect(isTrainerAllowedAdminRoute("/admin/security")).toBe(false);
    expect(isTrainerAllowedAdminRoute("/admin/audit")).toBe(false);
    expect(isTrainerAllowedAdminRoute("/admin/rgpd")).toBe(false);
    expect(isTrainerAllowedAdminRoute("/admin/settings")).toBe(false);
  });
});

describe("canAccessAdminRoute", () => {
  it("admin accède partout dans /admin", () => {
    expect(canAccessAdminRoute("admin", "/admin/users")).toBe(true);
    expect(canAccessAdminRoute("admin", "/admin/settings")).toBe(true);
    expect(canAccessAdminRoute("super_admin", "/admin/audit")).toBe(true);
  });
  it("trainer accède uniquement aux routes whitelistées", () => {
    expect(canAccessAdminRoute("trainer", "/admin/modules")).toBe(true);
    expect(canAccessAdminRoute("trainer", "/admin/quizzes")).toBe(true);
    expect(canAccessAdminRoute("trainer", "/admin/users")).toBe(false);
    expect(canAccessAdminRoute("trainer", "/admin/security")).toBe(false);
  });
  it("student n'accède à rien dans /admin", () => {
    expect(canAccessAdminRoute("student", "/admin/modules")).toBe(false);
    expect(canAccessAdminRoute("student", "/admin/users")).toBe(false);
    expect(canAccessAdminRoute(null, "/admin/anything")).toBe(false);
  });
});
