import { supabase } from "./supabase";

export async function getUserTags(userId) {
  // Query user_has_tags joined with tags where user_id = userId
  const { data, error } = await supabase
    .from("user_has_tags")
    .select("tag_id, tags(id, name, color, animation)")
    .eq("user_id", userId);

  if (error) {
    console.error("Error fetching user tags:", error);
    return {
      tags: [
        {
          id: 0,
          name: "FAN",
          color: "#666666",
          animation: "none",
          cssClass: "role-fan",
          isOwner: false,
        },
      ],
    };
  }

  return {
    tags: data.map((ut) => ({
      ...ut.tags,
      cssClass: `tag-${ut.tags?.name?.toLowerCase().replace(/\s+/g, "-")}`,
      isOwner: false,
    })),
  };
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
