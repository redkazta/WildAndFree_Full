-- Create cart_items table
create table public.cart_items (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  product_id text not null,
  quantity int not null default 1,
  metadata jsonb default '{}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  unique(user_id, product_id)
);

-- Create wishlist_items table
create table public.wishlist_items (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  product_id text not null,
  metadata jsonb default '{}'::jsonb,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  
  unique(user_id, product_id)
);

-- RLS Policies
alter table public.cart_items enable row level security;
alter table public.wishlist_items enable row level security;

create policy "Users can manage their own cart"
  on public.cart_items for all
  using (auth.uid() = user_id);

create policy "Users can manage their own wishlist"
  on public.wishlist_items for all
  using (auth.uid() = user_id);
