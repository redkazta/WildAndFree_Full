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

export const storeMockProducts: StoreMockProduct[] = [];
