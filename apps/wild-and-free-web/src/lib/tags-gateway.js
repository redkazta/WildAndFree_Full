/**
 * Servicio para gestionar tags de usuarios
 * Ahora usa el api-gateway en lugar de llamar directamente a Supabase
 */

/**
 * Obtiene los tags de un usuario desde el api-gateway
 * @param {string} userId - ID del usuario
 * @returns {Promise<Object>} Objeto con los tags procesados del usuario
 */
export async function getUserTags(userId) {
  try {
    const response = await fetch('/gateway/tags/my-tags', {
      headers: {
        'x-user-id': userId,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching user tags:', error);
    // Devolver tags por defecto en caso de error
    return {
      tags: [{
        id: 0,
        name: 'FAN',
        color: '#666666',
        animation: 'none',
        cssClass: 'role-fan',
        isOwner: false
      }]
    };
  }
}

/**
 * Obtiene todos los tags disponibles
 * @returns {Promise<Object>} Objeto con todos los tags disponibles
 */
export async function getAllTags() {
  try {
    const response = await fetch('/gateway/tags/available', {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error fetching all tags:', error);
    return { tags: [] };
  }
}

/**
 * Asigna un tag a un usuario
 * @param {string} userId - ID del usuario
 * @param {number} tagId - ID del tag
 * @returns {Promise<Object>} Resultado de la operación
 */
export async function assignTagToUser(userId, tagId) {
  try {
    const response = await fetch(`/gateway/tags/assign/${tagId}`, {
      method: 'POST',
      headers: {
        'x-user-id': userId,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error assigning tag to user:', error);
    return { success: false, error: error.message };
  }
}

/**
 * Remueve un tag de un usuario
 * @param {string} userId - ID del usuario
 * @param {number} tagId - ID del tag
 * @returns {Promise<Object>} Resultado de la operación
 */
export async function removeTagFromUser(userId, tagId) {
  try {
    const response = await fetch(`/gateway/tags/remove/${tagId}`, {
      method: 'DELETE',
      headers: {
        'x-user-id': userId,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error removing tag from user:', error);
    return { success: false, error: error.message };
  }
}