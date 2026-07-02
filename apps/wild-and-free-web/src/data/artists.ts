import { createClient } from "@supabase/supabase-js";

export interface Artist {
  id: string;
  nombre: string;
  slug: string;
  imagenes: {
    profile: string;
    banner: string;
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
}

// Fallback mock data (used if Supabase is unreachable at build time)
const mockArtists: Artist[] = [
  {
    id: "66fd9133-87bc-43eb-9095-23b11f44de5c",
    nombre: "Young Kazta",
    slug: "young_kazta",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&q=80",
    },
    stats: { seguidores: "1.2K", oyentes: "3.4K", partnean: 142 },
    bio: "CEO & Founder de Wild Gvng. Productor musical y freestyler nacido en Torreón. El desierto es su escenario.",
    tracks: [
      { title: "Fuego del Desierto", duration: "3:24" },
      { title: "Noche de Arena", duration: "2:58" },
      { title: "Torreón Nights", duration: "3:11" },
    ],
    estilo: "Trap / Freestyle",
    origen: "Torreón, Coahuila",
    redes: { Instagram: "#", Spotify: "#", YouTube: "#" },
  },
  {
    id: "2406328b-ad5b-4271-a923-36af6b9c5a29",
    nombre: "MC Delta",
    slug: "mc_delta",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=1600&q=80",
    },
    stats: { seguidores: "670", oyentes: "1.9K", partnean: 56 },
    bio: "Voz del bajo mundo. Flow imparable. Torreón represent.",
    tracks: [
      { title: "Crucero Nocturno", duration: "3:08" },
      { title: "Reglas de la Vieja Escuela", duration: "2:55" },
    ],
    estilo: "Gangsta Rap",
    origen: "Torreón, Coahuila",
    redes: { Instagram: "#", Spotify: "#" },
  },
  {
    id: "1a2eac9c-50e9-48d1-9026-54286147c149",
    nombre: "Lil Fuego",
    slug: "lil_fuego",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=1600&q=80",
    },
    stats: { seguidores: "430", oyentes: "1.1K", partnean: 34 },
    bio: "Joven promesa del freestyle torreonense. Fuego puro en cada verso.",
    tracks: [
      { title: "Sin Cuartel", duration: "2:44" },
      { title: "Barro y Sangre", duration: "3:18" },
    ],
    estilo: "Freestyle / Drill",
    origen: "Torreón, Coahuila",
    redes: { Instagram: "#", TikTok: "#" },
  },
];

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
      profile: profile.avatar_url || mockArtists[0].imagenes.profile,
      banner:
        "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1600&q=80",
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
 * Fetches artists from Supabase at build time.
 * Falls back to mock data if Supabase is unreachable.
 */
export async function getArtistsFromDB(): Promise<Artist[]> {
  const url = import.meta.env.PUBLIC_SUPABASE_URL;
  const key = import.meta.env.PUBLIC_SUPABASE_ANON_KEY;

  if (!url || !key) return mockArtists;

  try {
    const supabase = createClient(url, key);

    // Fetch profiles with role = 'artist'
    const { data: profiles, error } = await supabase
      .from("profiles")
      .select("*")
      .eq("role", "artist")
      .order("created_at", { ascending: true });

    if (error || !profiles || profiles.length === 0) {
      console.warn("[artists] Supabase fallback to mock data:", error?.message);
      return mockArtists;
    }

    // Fetch partnear counts per artist
    const artistIds = profiles.map((p: any) => p.id);
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

    // Fetch tracks for all artists
    const { data: tracksData } = await supabase
      .from("artist_tracks")
      .select("*")
      .eq("is_published", true)
      .order("track_number", { ascending: true });

    // Group tracks by artist_id
    const tracksByArtist: Record<string, any[]> = {};
    if (tracksData) {
      for (const t of tracksData) {
        if (!tracksByArtist[t.artist_id]) tracksByArtist[t.artist_id] = [];
        tracksByArtist[t.artist_id].push(t);
      }
    }

    return profiles.map((p: any) => {
      const artist = mapProfileToArtist(p);
      artist.stats.partnean = partnearCounts[p.id] || 0;
      artist.tracks = (tracksByArtist[p.id] || []).map((t: any) => ({
        title: t.title,
        duration: t.duration,
        spotify_url: t.spotify_url || undefined,
      }));
      return artist;
    });
  } catch (err) {
    console.warn("[artists] Network error, using mock data:", err);
    return mockArtists;
  }
}

/**
 * Find a single artist by username/slug.
 */
export async function getArtistBySlug(slug: string): Promise<Artist | null> {
  const artists = await getArtistsFromDB();
  return artists.find((a) => a.slug === slug) || null;
}

// Re-export mock data for client-side scripts that reference it directly
export const artistsData = mockArtists;
