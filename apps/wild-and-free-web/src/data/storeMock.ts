export interface StoreMockProduct {
  id: string
  name: string
  price: number
  image: string
  category: string
  description: string
  slug: string
  stock: number
  isMock: true
}

export const storeMockProducts: StoreMockProduct[] = [
  {
    id: 'p1',
    name: 'Playera Wild Gvng Logo',
    price: 350,
    image: '',
    category: 'playeras',
    description: 'Playera negra bordada con el logo original de Wild Gvng.',
    slug: 'playera_wild_gvng_logo',
    stock: 10,
    isMock: true,
  },
  {
    id: 'p2',
    name: 'Gorra WG Snapback',
    price: 280,
    image: '',
    category: 'gorras',
    description: 'Gorra snapback negra con logo WG bordado.',
    slug: 'gorra_wg_snapback',
    stock: 10,
    isMock: true,
  },
  {
    id: 'p3',
    name: 'Sudadera Wild Gvng Premium',
    price: 650,
    image: '',
    category: 'sudaderas',
    description: 'Sudadera con capucha, diseño exclusivo.',
    slug: 'sudadera_wild_gvng_premium',
    stock: 10,
    isMock: true,
  },
]
