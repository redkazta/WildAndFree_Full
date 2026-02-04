create or replace function public.get_my_role()
returns text
language sql
security definer
set search_path = public
as $$
  select r.name
  from public.user_roles ur
  join public.roles r on r.id = ur.role_id
  where ur.user_id = auth.uid()
  order by case
    when lower(r.name) = 'admin' then 1
    when lower(r.name) = 'artist' then 2
    when lower(r.name) = 'fan' then 3
    else 100
  end
  limit 1
$$;

revoke all on function public.get_my_role() from public;
grant execute on function public.get_my_role() to anon, authenticated;

alter table public.user_roles enable row level security;
alter table public.roles enable row level security;

create policy "user_roles_select_own"
on public.user_roles
for select
to authenticated
using (user_id = auth.uid());

create policy "roles_select_all"
on public.roles
for select
to authenticated
using (true);
