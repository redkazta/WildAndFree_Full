// Funciones para gestionar el sistema de tags

/**
 * Asignar un tag a un usuario
 * @param {string} userId - ID del usuario
 * @param {number} tagId - ID del tag
 * @returns {Promise<Object>} - Resultado de la operación
 */
export async function assignTagToUser(userId, tagId) {
  const { supabase } = await import('./supabase');
  
  try {
    const { data, error } = await supabase
      .from('user_has_tags')
      .upsert({
        user_id: userId,
        tag_id: tagId
      }, {
        onConflict: 'user_id,tag_id'
      });

    if (error) {
      console.error('Error assigning tag to user:', error);
      return { success: false, error };
    }

    return { success: true, data };
  } catch (err) {
    console.error('Exception assigning tag to user:', err);
    return { success: false, error: err };
  }
}

/**
 * Remover un tag de un usuario
 * @param {string} userId - ID del usuario
 * @param {number} tagId - ID del tag
 * @returns {Promise<Object>} - Resultado de la operación
 */
export async function removeTagFromUser(userId, tagId) {
  const { supabase } = await import('./supabase');
  
  try {
    const { data, error } = await supabase
      .from('user_has_tags')
      .delete()
      .eq('user_id', userId)
      .eq('tag_id', tagId);

    if (error) {
      console.error('Error removing tag from user:', error);
      return { success: false, error };
    }

    return { success: true, data };
  } catch (err) {
    console.error('Exception removing tag from user:', err);
    return { success: false, error: err };
  }
}

/**
 * Obtener todos los tags disponibles
 * @returns {Promise<Object>} - Lista de tags
 */
export async function getAllTags() {
  const { supabase } = await import('./supabase');
  
  try {
    const { data, error } = await supabase
      .from('tags')
      .select('*')
      .order('name', { ascending: true });

    if (error) {
      console.error('Error fetching tags:', error);
      return { success: false, error };
    }

    return { success: true, data };
  } catch (err) {
    console.error('Exception fetching tags:', err);
    return { success: false, error: err };
  }
}

/**
 * Obtener los tags de un usuario específico
 * @param {string} userId - ID del usuario
 * @returns {Promise<Object>} - Lista de tags del usuario
 */
export async function getUserTags(userId) {
  const { supabase } = await import('./supabase');
  
  try {
    const { data, error } = await supabase
      .from('user_has_tags')
      .select(`
        tag_id,
        tags (
          id,
          name,
          color,
          animation
        )
      `)
      .eq('user_id', userId);

    if (error) {
      console.error('Error fetching user tags:', error);
      return { success: false, error };
    }

    return { success: true, data };
  } catch (err) {
    console.error('Exception fetching user tags:', err);
    return { success: false, error: err };
  }
}

/**
 * Buscar un tag por nombre
 * @param {string} tagName - Nombre del tag
 * @returns {Promise<Object>} - Tag encontrado o null
 */
export async function getTagByName(tagName) {
  const { supabase } = await import('./supabase');
  
  try {
    const { data, error } = await supabase
      .from('tags')
      .select('*')
      .ilike('name', tagName)
      .single();

    if (error) {
      if (error.code === 'PGRST116') {
        // No se encontró el tag
        return { success: true, data: null };
      }
      console.error('Error fetching tag by name:', error);
      return { success: false, error };
    }

    return { success: true, data };
  } catch (err) {
    console.error('Exception fetching tag by name:', err);
    return { success: false, error: err };
  }
}