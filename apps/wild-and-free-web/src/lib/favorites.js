import { supabase } from './supabase';

// Estado local
let favorites = new Set();
let isLoaded = false;

// Evento custom para notificar cambios
const FAVORITES_UPDATED = 'favorites-updated';

export const Favorites = {
    async init() {
        if (isLoaded) return;
        
        const { data: { session } } = await supabase.auth.getSession();
        if (!session) return;

        const { data, error } = await supabase
            .from('favorites')
            .select('track_id');

        if (!error && data) {
            favorites = new Set(data.map(f => f.track_id));
            isLoaded = true;
            window.dispatchEvent(new CustomEvent(FAVORITES_UPDATED));
        }
    },

    has(trackId) {
        return favorites.has(trackId);
    },

    async toggle(track) {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (!session) {
            window.location.href = '/login';
            return false;
        }

        const trackId = track.id;
        
        if (favorites.has(trackId)) {
            // Eliminar
            const { error } = await supabase
                .from('favorites')
                .delete()
                .match({ user_id: session.user.id, track_id: trackId });

            if (!error) {
                favorites.delete(trackId);
                window.dispatchEvent(new CustomEvent(FAVORITES_UPDATED, { detail: { action: 'remove', id: trackId } }));
                return false; // Ya no es favorito
            }
        } else {
            // Agregar
            const { error } = await supabase
                .from('favorites')
                .insert({
                    user_id: session.user.id,
                    track_id: trackId,
                    track_data: track // Guardamos metadata para no volver a consultar
                });

            if (!error) {
                favorites.add(trackId);
                window.dispatchEvent(new CustomEvent(FAVORITES_UPDATED, { detail: { action: 'add', id: trackId } }));
                return true; // Es favorito
            }
        }
        return favorites.has(trackId);
    }
};

// Auto-init si hay sesión
if (typeof window !== 'undefined') {
    Favorites.init();
}
