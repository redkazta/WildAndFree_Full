export interface Artist {
  id: number;
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
  tracks: { title: string; duration: string }[];
  estilo: string;
  origen: string;
  redes?: Record<string, string>;
}

export const artistsData: Artist[] = [
  {
    id: 1,
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
    id: 2,
    nombre: "Sombra V",
    slug: "sombra_v",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1514525253361-bee871871771?w=1600&q=80",
    },
    stats: { seguidores: "890", oyentes: "2.1K", partnean: 89 },
    bio: "Lírica consciente sobre ritmos lo-fi. La voz de la melancolía del norte.",
    tracks: [
      { title: "Sueños Lo-Fi", duration: "3:45" },
      { title: "Verso Silencioso", duration: "2:33" },
      { title: "Pensamientos Profundos", duration: "4:01" },
    ],
    estilo: "Lo-Fi Consciente",
    origen: "Torreón, Coahuila",
    redes: { Instagram: "#", Spotify: "#" },
  },
  {
    id: 3,
    nombre: "Kira .MX",
    slug: "kira_mx",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=1600&q=80",
    },
    stats: { seguidores: "2.1K", oyentes: "5.8K", partnean: 203 },
    bio: "Reina del drill melódico. Elegancia letal en cada barra.",
    tracks: [
      { title: "Flow de Reina", duration: "2:48" },
      { title: "Princesa del Drill", duration: "3:15" },
      { title: "Tormenta Melódica", duration: "3:32" },
    ],
    estilo: "Melodic Drill",
    origen: "Torreón, Coahuila",
    redes: { Instagram: "#", YouTube: "#", TikTok: "#" },
  },
  {
    id: 4,
    nombre: "Fantom",
    slug: "fantom",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=1600&q=80",
    },
    stats: { seguidores: "670", oyentes: "1.9K", partnean: 56 },
    bio: "Flow vieja escuela con agresividad. El rey de las calles oscuras de la laguna.",
    tracks: [
      { title: "Crucero Nocturno", duration: "3:08" },
      { title: "Reglas de la Vieja Escuela", duration: "2:55" },
      { title: "Leyenda Callejera", duration: "3:41" },
    ],
    estilo: "Gangsta Rap",
    origen: "Torreón, Coahuila",
    redes: { Spotify: "#", Instagram: "#" },
  },
  {
    id: 5,
    nombre: "Luna Roja",
    slug: "luna_roja",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1600&q=80",
    },
    stats: { seguidores: "1.5K", oyentes: "4.2K", partnean: 178 },
    bio: "Fusión de synthwave con reggaetón. Rompiendo esquemas en el desierto.",
    tracks: [
      { title: "Amor Sintético", duration: "3:20" },
      { title: "Ritmo Retro", duration: "2:47" },
      { title: "Futuro Pasado", duration: "3:55" },
    ],
    estilo: "Synth-Reggaetón",
    origen: "Torreón, Coahuila",
    redes: { Instagram: "#", SoundCloud: "#" },
  },
  {
    id: 6,
    nombre: "Sable",
    slug: "sable",
    imagenes: {
      profile:
        "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800&q=80",
      banner:
        "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=1600&q=80",
    },
    stats: { seguidores: "430", oyentes: "1.1K", partnean: 34 },
    bio: "Rap underground puro. Sin filtros, sin compasión, sin excusas.",
    tracks: [
      { title: "Sin Cuartel", duration: "2:44" },
      { title: "Barro y Sangre", duration: "3:18" },
      { title: "Último Aliento", duration: "3:02" },
    ],
    estilo: "Underground Rap",
    origen: "Torreón, Coahuila",
    redes: { Instagram: "#" },
  },
];
