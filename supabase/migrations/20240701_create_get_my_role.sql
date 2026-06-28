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
