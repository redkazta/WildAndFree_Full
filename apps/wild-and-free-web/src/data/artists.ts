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
    power: number;
    speed: number;
    technique: number;
  };
  bio: string;
  tracks: string[];
  estilo: string;
  origen: string;
  redes?: Record<string, string>;
}

export const artistsData: Artist[] = [
  {
    id: 1,
    nombre: 'Lil Kiro',
    slug: 'lil-kiro',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1514525253361-bee871871771?w=1600&q=80',
    },
    stats: { seguidores: '2.1M', oyentes: '1.2M', power: 95, speed: 88, technique: 92 },
    bio: 'El pionero del trap en el desierto. Sus rimas queman como arena caliente.',
    tracks: ['Tormenta de Arena', 'Rey del Desierto', 'Espejismo', 'Trampa en el Oasis'],
    estilo: 'Trap Pesado',
    origen: 'Sonora, MX',
    redes: { Instagram: '#', Spotify: '#' },
  },
  {
    id: 2,
    nombre: 'Fantasma Neón',
    slug: 'fantasma-neon',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=1600&q=80',
    },
    stats: { seguidores: '1.8M', oyentes: '900K', power: 85, speed: 98, technique: 90 },
    bio: 'Misterio y drill futurista. Nadie ha visto su rostro real.',
    tracks: ['Ciudad Cibernética', 'Noches de Neón', 'Sombra Digital', 'Modo Glitch'],
    estilo: 'Cyber Drill',
    origen: 'CDMX, MX',
    redes: { Instagram: '#', YouTube: '#' },
  },
  {
    id: 3,
    nombre: 'Sombra V',
    slug: 'sombra-v',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=1600&q=80',
    },
    stats: { seguidores: '1.5M', oyentes: '750K', power: 78, speed: 85, technique: 96 },
    bio: 'Lírica consciente sobre ritmos lo-fi. La voz de la melancolía.',
    tracks: ['Sueños Lo-Fi', 'Verso Silencioso', 'Pensamientos Profundos', 'Vinilo Rayado'],
    estilo: 'Lo-Fi Consciente',
    origen: 'Guadalajara, MX',
    redes: { X: '#', Spotify: '#' },
  },
  {
    id: 4,
    nombre: 'Onda Cristal',
    slug: 'onda-cristal',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=1600&q=80',
    },
    stats: { seguidores: '890K', oyentes: '1.1M', power: 82, speed: 90, technique: 88 },
    bio: 'Fusión de synthwave con reggaetón. Rompiendo esquemas.',
    tracks: ['Amor Sintético', 'Ritmo Retro', 'Jinete de Onda', 'Futuro Pasado'],
    estilo: 'Synth-Reggaetón',
    origen: 'Monterrey, MX',
    redes: { Instagram: '#', SoundCloud: '#' },
  },
  {
    id: 5,
    nombre: 'Jinete Nocturno',
    slug: 'jinete-nocturno',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=1600&q=80',
    },
    stats: { seguidores: '2.7M', oyentes: '2.4M', power: 98, speed: 80, technique: 85 },
    bio: 'Flow vieja escuela con agresividad. El rey de las calles oscuras.',
    tracks: ['Crucero Nocturno', 'Reglas de la Vieja Escuela', 'Rugido de Motor', 'Leyenda Callejera'],
    estilo: 'Gangsta Rap',
    origen: 'Tijuana, MX',
    redes: { Spotify: '#', TikTok: '#' },
  },
  {
    id: 6,
    nombre: 'Nova K',
    slug: 'nova-k',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=1600&q=80',
    },
    stats: { seguidores: '2.4M', oyentes: '1.8M', power: 90, speed: 92, technique: 94 },
    bio: 'Reina del drill melódico. Elegancia letal en cada barra.',
    tracks: ['Flow de Reina', 'Princesa del Drill', 'Tormenta Melódica', 'Joya de la Corona'],
    estilo: 'Melodic Drill',
    origen: 'Puebla, MX',
    redes: { Instagram: '#', YouTube: '#' },
  },
  {
    id: 7,
    nombre: 'Sable',
    slug: 'sable',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=1600&q=80',
    },
    stats: { seguidores: '1.2M', oyentes: '3.5M', power: 88, speed: 95, technique: 98 },
    bio: 'Arquitecto de sonidos oscuros. Corta el beat como katana.',
    tracks: ['Materia Oscura', 'Caminante del Vacío', 'Llamada del Abismo', 'Reino de Sombras'],
    estilo: 'Dark Trap',
    origen: 'Tokio, JP / CDMX',
    redes: { Instagram: '#', Spotify: '#' },
  },
  {
    id: 8,
    nombre: 'Tormenta',
    slug: 'tormenta',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=1600&q=80',
    },
    stats: { seguidores: '950K', oyentes: '600K', power: 92, speed: 88, technique: 80 },
    bio: 'Energía pura de Gómez Palacio. Imparable como un huracán.',
    tracks: ['Golpe de Trueno', 'Velocidad del Rayo', 'Alerta de Tormenta', 'Lluvia Pesada'],
    estilo: 'Hardcore Rap',
    origen: 'Gómez Palacio, DGO',
    redes: { Instagram: '#', TikTok: '#' },
  },
  {
    id: 9,
    nombre: 'Víbora X',
    slug: 'vibora-x',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1615109398623-88346a601842?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1615109398623-88346a601842?w=1600&q=80',
    },
    stats: { seguidores: '3.1M', oyentes: '2.8M', power: 96, speed: 99, technique: 95 },
    bio: 'El veneno lírico más potente del norte. Nadie sobrevive a su tiradera.',
    tracks: ['Mordida de Veneno', 'Ojos de Serpiente', 'Flow Tóxico', 'Golpe Mortal'],
    estilo: 'Fast Flow',
    origen: 'Chihuahua, MX',
  },
  {
    id: 10,
    nombre: 'Luna Negra',
    slug: 'luna-negra',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1517423568366-69755581d826?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1517423568366-69755581d826?w=1600&q=80',
    },
    stats: { seguidores: '1.9M', oyentes: '2.2M', power: 85, speed: 90, technique: 92 },
    bio: 'Voces etéreas sobre bajos pesados. La bruja del R&B.',
    tracks: ['Luz de Luna', 'Cielo Oscuro', 'Eclipse Total', 'Susurro Nocturno'],
    estilo: 'Dark R&B',
    origen: 'Veracruz, MX',
  },
  {
    id: 11,
    nombre: 'Rojo Fuego',
    slug: 'rojo-fuego',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?w=1600&q=80',
    },
    stats: { seguidores: '500K', oyentes: '800K', power: 94, speed: 96, technique: 85 },
    bio: 'La nueva promesa del trap duro. Incendiando escenarios.',
    tracks: ['Iniciador de Fuego', 'Al Rojo Vivo', 'Quémalo Todo', 'Infierno'],
    estilo: 'Trap Metal',
    origen: 'Ecatepec, MX',
  },
  {
    id: 12,
    nombre: 'Ciber Punk',
    slug: 'ciber-punk',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1618641986557-1ecd23095910?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1618641986557-1ecd23095910?w=1600&q=80',
    },
    stats: { seguidores: '4.5M', oyentes: '5.1M', power: 90, speed: 92, technique: 99 },
    bio: 'Sonidos del futuro hoy. Hackeando el sistema musical.',
    tracks: ['Ciudad Futura', 'Alma Cibernética', 'Ritmo Tech', 'Lluvia Neón'],
    estilo: 'Glitch Hop',
    origen: 'Zapopan, MX',
  },
  {
    id: 13,
    nombre: 'Fantasma G',
    slug: 'fantasma-g',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=1600&q=80',
    },
    stats: { seguidores: '1.4M', oyentes: '980K', power: 88, speed: 94, technique: 90 },
    bio: 'El espectro del beat, apareciendo donde menos lo esperas.',
    tracks: ['Modo Fantasma', 'Golpe Invisible', 'Dolor Fantasma', 'Mundo Espiritual'],
    estilo: 'Horrorcore',
    origen: 'Toluca, MX',
  },
  {
    id: 14,
    nombre: 'Micrófono de Hierro',
    slug: 'microfono-de-hierro',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1531384441138-2736e62e0919?w=1600&q=80',
    },
    stats: { seguidores: '3.2M', oyentes: '2.9M', power: 99, speed: 70, technique: 85 },
    bio: 'Barras de acero y voluntad inquebrantable. Peso pesado.',
    tracks: ['Voluntad de Hierro', 'Metal Pesado', 'Barras de Acero', 'Óxido y Polvo'],
    estilo: 'Boom Bap',
    origen: 'Torreón, COAH',
  },
  {
    id: 15,
    nombre: 'Rosa de Terciopelo',
    slug: 'rosa-de-terciopelo',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1600&q=80',
    },
    stats: { seguidores: '4.1M', oyentes: '5.5M', power: 80, speed: 90, technique: 98 },
    bio: 'Suavidad que mata. R&B con espinas.',
    tracks: ['Muerte Suave', 'Pinchazo de Espina', 'Pétalos Rojos', 'Camino de Seda'],
    estilo: 'Soul Trap',
    origen: 'Mérida, MX',
  },
  {
    id: 16,
    nombre: 'Tóxico B',
    slug: 'toxico-b',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=1600&q=80',
    },
    stats: { seguidores: '2.0M', oyentes: '1.5M', power: 92, speed: 95, technique: 88 },
    bio: 'El veneno está en la dosis. Trap ácido que corroe.',
    tracks: ['Lluvia Ácida', 'Amor Tóxico', 'Hiedra Venenosa', 'Peligro'],
    estilo: 'Acid Rap',
    origen: 'León, MX',
  },
  {
    id: 17,
    nombre: 'Llamarada Solar',
    slug: 'llamarada-solar',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=1600&q=80',
    },
    stats: { seguidores: '1.1M', oyentes: '800K', power: 95, speed: 85, technique: 90 },
    bio: 'Brillando más fuerte que el sol de mediodía. Cega a la competencia.',
    tracks: ['Quemadura', 'Ola de Calor', 'Poder Solar', 'Luz Cegadora'],
    estilo: 'Reggaetón',
    origen: 'Cancún, MX',
  },
  {
    id: 18,
    nombre: 'Hielo Seco',
    slug: 'hielo-seco',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=1600&q=80',
    },
    stats: { seguidores: '1.9M', oyentes: '2.1M', power: 85, speed: 92, technique: 96 },
    bio: 'Flow helado que congela la pista. Sangre fría.',
    tracks: ['Congelación', 'Cero Grados', 'Era de Hielo', 'Glaciar'],
    estilo: 'Drill',
    origen: 'Saltillo, MX',
  },
  {
    id: 19,
    nombre: 'La Bestia',
    slug: 'la-bestia',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1581382575275-97901c2635b7?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1581382575275-97901c2635b7?w=1600&q=80',
    },
    stats: { seguidores: '5.0M', oyentes: '6.2M', power: 99, speed: 85, technique: 80 },
    bio: 'Fuerza bruta desatada. Rompiendo bocinas desde el 2010.',
    tracks: ['Modo Bestia', 'Rugido', 'Fuerza Bruta', 'Sin Cadenas'],
    estilo: 'Hardcore',
    origen: 'Culiacán, MX',
  },
  {
    id: 20,
    nombre: 'Karmma',
    slug: 'karmma',
    imagenes: {
      profile: 'https://images.unsplash.com/photo-1534030347209-7147fd9e791a?w=800&q=80',
      banner: 'https://images.unsplash.com/photo-1534030347209-7147fd9e791a?w=1600&q=80',
    },
    stats: { seguidores: '800K', oyentes: '1.5M', power: 88, speed: 94, technique: 97 },
    bio: 'Lo que das, recibes. Barras que regresan para golpearte.',
    tracks: ['Causa y Efecto', 'Justicia Divina', 'Ciclo Sin Fin', 'Destino'],
    estilo: 'Consciente',
    origen: 'Morelia, MX',
  },
];

export const getArtistBySlug = (slug: string): Artist | undefined =>
  artistsData.find((a) => a.slug === slug);

export const getAllSlugs = (): string[] => artistsData.map((a) => a.slug);
