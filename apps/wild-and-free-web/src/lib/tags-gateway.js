import { supabase } from "./supabase";

const ROLE_PRIORITY = {
  owner: 1,
  admin: 2,
  staff_manager: 3,
  staff: 4,
  staff_marketing: 5,
  artist: 6,
  fan: 7,
};

function pickHighestRole(roles) {
  const normalized = roles.map((r) => String(r).trim().toLowerCase()).filter(Boolean);
  let best = null;
  let bestPriority = Infinity;
  for (const r of normalized) {
    const p = ROLE_PRIORITY[r] ?? 100;
    if (p < bestPriority) {
      bestPriority = p;
      best = r;
    }
  }
  return best;
}

export async function getUserTags(userId) {
  // 1) Fetch role from user_roles + roles
  let role = null;
  try {
    const { data: urRows } = await supabase
      .from("user_roles")
      .select("role_id")
      .eq("user_id", userId);

    if (Array.isArray(urRows) && urRows.length > 0) {
      const roleIds = [...new Set(urRows.map((r) => r.role_id).filter(Boolean))];
      if (roleIds.length > 0) {
        const { data: rolesRows } = await supabase
          .from("roles")
          .select("name")
          .in("id", roleIds);

        if (Array.isArray(rolesRows) && rolesRows.length > 0) {
          const names = rolesRows.map((r) => r.name).filter(Boolean);
          role = pickHighestRole(names);
        }
      }
    }
  } catch (e) {
    console.warn("Could not fetch role from user_roles:", e);
  }

  // 2) Fetch tags from user_has_tags + tags
  let tags = [];
  try {
    const { data, error } = await supabase
      .from("user_has_tags")
      .select("tag_id, tags(id, name, color, animation)")
      .eq("user_id", userId);

    if (!error && Array.isArray(data)) {
      tags = data
        .filter((ut) => ut.tags)
        .map((ut) => ({
          id: ut.tags.id,
          name: ut.tags.name,
          color: ut.tags.color || "#C98300",
          animation: ut.tags.animation || "none",
          cssClass: `tag-${ut.tags.name.toLowerCase().replace(/\s+/g, "-")}`,
          isOwner: false,
        }));
    } else if (error) {
      console.error("Error fetching user tags:", error);
    }
  } catch (e) {
    console.warn("Could not fetch user_has_tags:", e);
  }

  return { role, tags };
}

export async function getAllTags() {
  const { data, error } = await supabase.from("tags").select("*").order("name");
  if (error) return { tags: [] };
  return { tags: data };
}

export async function assignTagToUser(userId, tagId) {
  const { data, error } = await supabase
    .from("user_has_tags")
    .upsert(
      { user_id: userId, tag_id: tagId },
      { onConflict: "user_id,tag_id" },
    );
  if (error) return { success: false, error: error.message };
  return { success: true, data };
}

export async function removeTagFromUser(userId, tagId) {
  const { data, error } = await supabase
    .from("user_has_tags")
    .delete()
    .eq("user_id", userId)
    .eq("tag_id", tagId);
  if (error) return { success: false, error: error.message };
  return { success: true, data };
}
