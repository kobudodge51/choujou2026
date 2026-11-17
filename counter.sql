create table if not exists public.cj26_visits (d date primary key, n bigint not null default 0);
alter table public.cj26_visits enable row level security;
create or replace function public.cj26_hit(p_inc boolean default true)
returns json language plpgsql security definer set search_path = public as $$
declare t date := (now() at time zone 'Asia/Tokyo')::date;
begin
  if p_inc then
    insert into cj26_visits(d, n) values (t, 1)
    on conflict (d) do update set n = cj26_visits.n + 1;
  end if;
  return json_build_object(
    'total', (select coalesce(sum(n), 0) from cj26_visits),
    'today', coalesce((select n from cj26_visits where d = t), 0));
end $$;
grant execute on function public.cj26_hit(boolean) to anon;
