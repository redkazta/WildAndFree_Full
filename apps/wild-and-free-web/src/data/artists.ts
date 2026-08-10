import { createClient } from "@supabase/supabase-js";

export interface Artist {
  id: string;
  nombre: string;
  slug: string;
  imagenes: {
    profile: string;
    banner?: string;
  };
  stats: {
    seguidores: string;
    oyentes: string;
    partnean: number;
  };
  bio: string;
  tracks: { title: string; duration: string; spotify_url?: string }[];
  estilo: string;
  origen: string;
  redes?: Record<string, string>;
  tags?: { name: string; color: string; animation: string }[];
  role?: string;
}

export interface ArtistPost {
  id: string;
  artist_id: string;
  content: string;
  post_type: string;
  image_url: string | null;
  embed_url: string | null;
  embed_title: string | null;
  likes_count: number;
  comments_count: number;
  reposts_count: number;
  is_pinned: boolean;
  created_at: string;
}

// Fallback mock data (used if Supabase is unreachable at build time)
const mockArtists: Artist[] = [];

function parseSocialLinks(raw: string | null): Record<string, string> {
  if (!raw) return {};
  try {
    const parsed = JSON.parse(raw);
    const result: Record<string, string> = {};
    for (const [key, val] of Object.entries(parsed)) {
      if (typeof val === "string" && val.startsWith("http")) {
        result[key.charAt(0).toUpperCase() + key.slice(1)] = val;
      }
    }
    return result;
  } catch {
    return {};
  }
}

function mapProfileToArtist(profile: any): Artist {
  const genres = profile.genres || [];
  const estilo = genres.length > 0 ? genres.join(" / ") : "Urbano";
  return {
    id: profile.id,
    nombre: profile.stage_name || profile.nombre || profile.username,
    slug: profile.username || profile.id,
    imagenes: {
      profile: profile.avatar_url || '',
    },
    stats: { seguidores: "0", oyentes: "0", partnean: 0 },
    bio: profile.bio || "",
    tracks: [],
    estilo,
    origen: profile.ubicacion || "Torreón, Coahuila",
    redes: parseSocialLinks(profile.social_links),
  };
}

/**
 * Fetches ALL public profiles (any role) with their real role resolved
 * from user_roles (fallback to profiles.role). Used by /artista/[username]
 * so every member (artist, admin, staff, fan) gets a working public page.
 * Falls back to mock data if Supabase is unreachable.
 */
export async function getAllPublicProfiles(): Promise<Artist[]> {
  const url = import.meta.env.PUBLIC_SUPABASE_URL;
  const key = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

  if (!url || !key) return mockArtists;

  try {
    const supabase = createClient(url, key);

    // Resolve real role per user: user_roles join roles (admin > staff > artist > fan)
    const { data: allRoles } = await supabase.from("roles").select("id, name, internal_name");
    const { data: allUserRoles } = await supabase.from("user_roles").select("user_id, role_id");

    const roleRank: Record<string, number> = {
      owner: 5, admin: 5, staff: 4, staff_manager: 4, staff_marketing: 4,
      artist: 3, fan: 2, user: 1, guest: 0,
    };
    const roleById: Record<string, { name: string; internal_name: string }> = {};
    (allRoles || []).forEach((r: any) => {
      roleById[r.id] = { name: r.name, internal_name: r.internal_name };
    });

    const roleByUser: Record<string, string> = {};
    (allUserRoles || []).forEach((ur: any) => {
      const r = roleById[ur.role_id];
      if (!r) return;
      const name = r.name || r.internal_name;
      const current = roleByUser[ur.user_id];
      if (!current || (roleRank[name] ?? 0) > (roleRank[current] ?? 0)) {
        roleByUser[ur.user_id] = name;
      }
    });

    // Fetch ALL profiles that have a username (public identity)
    const { data: profiles, error } = await supabase
      .from("profiles")
      .select("*")
      .not("username", "is", null)
      .order("created_at", { ascending: true });

    if (error || !profiles || profiles.length === 0) {
      console.warn("[artists] Supabase fallback to mock data:", error?.message);
      return mockArtists;
    }

    // Fetch partnear counts
    const { data: partnearData } = await supabase
      .from("partnear")
      .select("artist_id");

    const partnearCounts: Record<string, number> = {};
    if (partnearData) {
      for (const row of partnearData) {
        const aid = row.artist_id;
        partnearCounts[aid] = (partnearCounts[aid] || 0) + 1;
      }
    }

    // Fetch tracks
    const { data: tracksData } = await supabase
      .from("artist_tracks")
      .select("*")
      .eq("is_published", true)
      .order("track_number", { ascending: true });

    const tracksByArtist: Record<string, any[]> = {};
    if (tracksData) {
      for (const t of tracksData) {
        if (!tracksByArtist[t.artist_id]) tracksByArtist[t.artist_id] = [];
        tracksByArtist[t.artist_id].push(t);
      }
    }

    // Fetch tags
    const profileIds = profiles.map((p: any) => p.id);
    const { data: allUserTags } = await supabase
      .from('user_has_tags')
      .select('user_id, tags:tag_id(name, color, animation)')
      .in('user_id', profileIds);

    const tagsByUser: Record<string, { name: string; color: string; animation: string }[]> = {};
    if (allUserTags) {
      for (const ut of allUserTags) {
        const tag = Array.isArray(ut.tags) ? ut.tags[0] : ut.tags;
        if (!tag) continue;
        if (!tagsByUser[ut.user_id]) tagsByUser[ut.user_id] = [];
        tagsByUser[ut.user_id].push({
          name: tag.name,
          color: tag.color || '#C98300',
          animation: tag.animation || 'none',
        });
      }
    }

    return profiles.map((p: any) => {
      const artist = mapProfileToArtist(p);
      artist.role = roleByUser[p.id] || p.role || 'fan';
      artist.stats.partnean = partnearCounts[p.id] || 0;
      artist.tracks = (tracksByArtist[p.id] || []).map((t: any) => ({
        title: t.title,
        duration: t.duration,
        spotify_url: t.spotify_url || undefined,
      }));
      artist.tags = tagsByUser[p.id] || [];
      return artist;
    });
  } catch (err) {
    console.warn("[artists] Network error, using mock data:", err);
    return mockArtists;
  }
}

/**
 * Fetches artists (role=artist) from Supabase at build time.
 * Falls back to mock data if Supabase is unreachable.
 */
export async function getArtistsFromDB(): Promise<Artist[]> {
  const all = await getAllPublicProfiles();
  const artists = all.filter((a) => a.role === 'artist');
  if (artists.length > 0) return artists;
  // If real data failed (mock fallback) return mock as-is
  return all.length > 0 ? artists : mockArtists;
}

/**
 * Find a single profile by username/slug (any role).
 */
export async function getArtistBySlug(slug: string): Promise<Artist | null> {
  const profiles = await getAllPublicProfiles();
  return profiles.find((a) => a.slug === slug) || null;
}

/**
 * Fetch feed posts for a specific artist.
 */
export async function getArtistPosts(artistId: string): Promise<ArtistPost[]> {
  const url = import.meta.env.PUBLIC_SUPABASE_URL;
  const key = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

  if (!url || !key) return [];

  try {
    const supabase = createClient(url, key);
    const { data, error } = await supabase
      .from('crew_posts')
      .select('*')
      .eq('author_id', artistId)
      .eq('status', 'published')
      .order('published_at', { ascending: false });

    if (error || !data || data.length === 0) {
      console.warn('[artists] Posts error:', error?.message);
      return [];
    }

    // Map crew_posts to ArtistPost interface - try RPC first for real counts
    try {
      const supabaseClient = createClient(url, key);
      const { data: feedData } = await supabaseClient
        .rpc('get_crew_feed', {
          p_author_id: artistId,
          p_limit: 20,
          p_offset: 0,
          p_user_id: null,
        });
      
      if (feedData && feedData.length > 0) {
        return feedData.map((p: any) => ({
          id: p.id,
          artist_id: p.author_id,
          content: p.content || '',
          post_type: p.post_type || 'general',
          image_url: p.image_url,
          embed_url: null,
          embed_title: p.title || null,
          likes_count: Number(p.likes_count) || 0,
          comments_count: Number(p.comments_count) || 0,
          reposts_count: Number(p.reposts_count) || 0,
          is_pinned: false,
          created_at: p.published_at || p.created_at,
        }));
      }
    } catch (rpcErr) {
      console.warn('[artists] RPC feed failed, using direct query:', rpcErr);
    }

    // Fallback: map from direct query
    const posts: ArtistPost[] = data.map((p: any) => ({
      id: p.id,
      artist_id: p.author_id,
      content: p.content || '',
      post_type: p.post_type || 'general',
      image_url: p.image_url,
      embed_url: null,
      embed_title: p.title || null,
      likes_count: 0,
      comments_count: 0,
      reposts_count: 0,
      is_pinned: false,
      created_at: p.published_at || p.created_at,
    }));

    return posts;
  } catch (err) {
    console.warn('[artists] Posts network error:', err);
    return [];
  }
}

// Re-export (vacío) para scripts que lo referencien directamente
const artistsData: ArtistPost[] = [];
export { artistsData as artistsData };
