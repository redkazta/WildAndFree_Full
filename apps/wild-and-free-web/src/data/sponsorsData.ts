export type SponsorTier = 'main' | 'secondary'

export interface Sponsor {
  id: string
  name: string
  description: string
  /** Sitio web oficial. Si no existe, la tarjeta no muestra botón. */
  url?: string
  /** Ruta local o URL remota del logotipo. Si falta, se usa un lockup tipográfico. */
  logo?: string
  /** Iniciales para el fallback tipográfico del logo. */
  monogram: string
  tier: SponsorTier
  /** Etiqueta corta opcional (ej. "Patrocinador Principal"). */
  tag?: string
}

export const sponsors: Sponsor[] = [
  {
    id: 'showlow-caps',
    name: 'Showlow Caps',
    description:
      'Patrocinador oficial de la Liga de Freestyle y del colectivo. Apoyando el talento local desde el día uno.',
    url: 'https://showlowcaps.mx/',
    monogram: 'SC',
    tier: 'main',
    tag: 'Patrocinador Principal',
  },
  {
    id: 'wildforgelabs',
    name: 'WildForgeLabs',
    description:
      'Desarrollo tecnológico y estrategia digital detrás de WildGvng.',
    url: 'https://www.wildforgelabs.com/',
    monogram: 'WF',
    tier: 'secondary',
  },
  {
    id: 'diaz-design',
    name: 'Díaz Design',
    description:
      'Dirección creativa y diseño gráfico del colectivo.',
    monogram: 'DD',
    tier: 'secondary',
  },
]

const mainIndex = sponsors.map((s) => s.tier).indexOf('main')

export const mainSponsor = mainIndex >= 0 ? sponsors[mainIndex] : undefined
export const secondarySponsors = sponsors.filter((s) => s.tier !== 'main')
