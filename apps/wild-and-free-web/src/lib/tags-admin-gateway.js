// Servicio para administración de tags - usa API Gateway en lugar de Supabase directo
import { supabase } from './supabase';

export async function getAllTags() {
  try {
    const response = await fetch('/gateway/tags/all', {
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    return await response.json();
  } catch (error) {
    console.error('Error fetching all tags:', error);
    return { tags: [] };
  }
}

export async function createTag(tagData) {
  try {
    // Obtener el userId del perfil actual
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) throw new Error('No authenticated user');

    const response = await fetch('/gateway/tags/create', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': session.user.id
      },
      body: JSON.stringify(tagData)
    });
    
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    return await response.json();
  } catch (error) {
    console.error('Error creating tag:', error);
    throw error;
  }
}

export async function deleteTag(tagId) {
  try {
    // Obtener el userId del perfil actual
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) throw new Error('No authenticated user');

    const response = await fetch(`/gateway/tags/delete/${tagId}`, {
      method: 'DELETE',
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': session.user.id
      }
    });
    
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    return await response.json();
  } catch (error) {
    console.error('Error deleting tag:', error);
    throw error;
  }
}

export async function getUsersWithTags() {
  try {
    // Obtener el userId del perfil actual
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) throw new Error('No authenticated user');

    const response = await fetch('/gateway/tags/users-with-tags', {
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': session.user.id
      }
    });
    
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    return await response.json();
  } catch (error) {
    console.error('Error fetching users with tags:', error);
    return { users: [] };
  }
}

export async function assignTagToUser(userId, tagId) {
  try {
    // Obtener el userId del perfil actual
    const { data: { session } } = await supabase.auth.getSession();
    if (!session) throw new Error('No authenticated user');

    const response = await fetch('/gateway/tags/assign', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-user-id': session.user.id
      },
      body: JSON.stringify({ userId, tagId })
    });
    
    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
    return await response.json();
  } catch (error) {
    console.error('Error assigning tag to user:', error);
    throw error;
  }
}