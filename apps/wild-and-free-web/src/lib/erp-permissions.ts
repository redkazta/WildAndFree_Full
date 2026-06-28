import { getRole } from "./role";

/**
 * Wait for ErpLayout to finish loading permissions, then return them.
 * If role is 'admin', returns a wildcard that grants all permissions.
 */
export const waitForPermissions = async (
  timeout = 3000,
): Promise<{ perms: string[]; role: string }> => {
  const start = Date.now();

  // Check if already loaded
  if ((window as any).__wildPermissions) {
    const role = (window as any).__wildRole || (await getRole()).role;
    return {
      perms: role === "admin" ? ["*"] : (window as any).__wildPermissions,
      role,
    };
  }

  // Wait for ErpLayout to set data-auth-loaded (end of its async script)
  while (Date.now() - start < timeout) {
    await new Promise((r) => setTimeout(r, 50));
    if ((window as any).__wildPermissions) {
      const role = (window as any).__wildRole || (await getRole()).role;
      return {
        perms: role === "admin" ? ["*"] : (window as any).__wildPermissions,
        role,
      };
    }
  }

  // Fallback: resolve role ourselves
  const { role } = await getRole();
  if (role === "admin") return { perms: ["*"], role };

  // Last resort: read from data attribute
  const attr = document.documentElement.getAttribute("data-permissions") || "";
  return { perms: attr ? attr.split(",") : [], role };
};

export const hasPermission = (perms: string[], perm: string): boolean => {
  return perms.includes("*") || perms.includes(perm);
};
