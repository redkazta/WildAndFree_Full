import { supabase } from "./supabase";

export async function getAllTags() {
  const { data, error } = await supabase
    .from("tags")
    .select("*, tag_categories(name)")
    .order("name");
  if (error) return { tags: [] };
  return { tags: data };
}

export async function createTag(tagData) {
  const {
    data: { session },
  } = await supabase.auth.getSession();
  if (!session) throw new Error("No authenticated user");

  const { data, error } = await supabase
    .from("tags")
    .insert({
      name: tagData.name,
      color: tagData.color,
      animation: tagData.animation || "none",
      category_id: tagData.category_id,
      token_price: tagData.token_price,
      is_purchasable: tagData.is_purchasable || false,
      achievement_key: tagData.achievement_key,
    })
    .select()
    .single();

  if (error) throw error;
  return { tag: data };
}

export async function deleteTag(tagId) {
  const { data, error } = await supabase.from("tags").delete().eq("id", tagId);
  if (error) throw error;
  return { success: true };
}

export async function getUsersWithTags() {
  const { data, error } = await supabase
    .from("profiles")
    .select("id, username, nombre, user_has_tags(tag_id, tags(name, color))");
  if (error) return { users: [] };
  return { users: data };
}

export async function assignTagToUser(userId, tagId) {
  const { data, error } = await supabase
    .from("user_has_tags")
    .upsert(
      { user_id: userId, tag_id: tagId },
      { onConflict: "user_id,tag_id" },
    );
  if (error) throw error;
  return { success: true };
}
