-- NEXORA 2026 — COMPLETE DATABASE MIGRATION
-- Matches the current Nexora ZIP schema and adds:
-- 249 countries, 750 professions, 15 languages, subscriptions, payments, payment proofs.
-- Safe to run more than once.

create extension if not exists pgcrypto;

-- =========================================================
-- 1. PROFILES (matches the current app)
-- =========================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  profession text not null,
  country_code text not null,
  country_name text not null,
  city text not null,
  address text not null,
  bio text not null,
  phone text not null,
  photo_url text,
  premium boolean not null default false,
  banned boolean not null default false,
  created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Public can read active profiles" on public.profiles;
create policy "Public can read active profiles" on public.profiles
for select using (banned = false);

drop policy if exists "Users can insert own profile" on public.profiles;
create policy "Users can insert own profile" on public.profiles
for insert to authenticated with check (auth.uid() = id);

drop policy if exists "Users can update own profile" on public.profiles;
create policy "Users can update own profile" on public.profiles
for update using (auth.uid() = id) with check (auth.uid() = id);

drop policy if exists "Users can delete own profile" on public.profiles;
create policy "Users can delete own profile" on public.profiles
for delete using (auth.uid() = id);

create or replace function public.prevent_profile_status_changes()
returns trigger
language plpgsql
security invoker
as $$
begin
  if auth.uid() = old.id
     and (new.premium is distinct from old.premium
          or new.banned is distinct from old.banned) then
    raise exception 'premium and banned are admin-only fields';
  end if;
  return new;
end;
$$;

drop trigger if exists prevent_profile_status_changes on public.profiles;
create trigger prevent_profile_status_changes
before update on public.profiles
for each row execute function public.prevent_profile_status_changes();

-- =========================================================
-- 2. STORAGE — AVATARS
-- =========================================================
insert into storage.buckets (id, name, public)
values ('avatars','avatars',true)
on conflict (id) do nothing;

drop policy if exists "Avatar public read" on storage.objects;
create policy "Avatar public read" on storage.objects
for select using (bucket_id = 'avatars');

drop policy if exists "Users upload own avatar" on storage.objects;
create policy "Users upload own avatar" on storage.objects
for insert to authenticated
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users update own avatar" on storage.objects;
create policy "Users update own avatar" on storage.objects
for update to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists "Users delete own avatar" on storage.objects;
create policy "Users delete own avatar" on storage.objects
for delete to authenticated
using (
  bucket_id = 'avatars'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- =========================================================
-- 3. COUNTRIES — 249
-- =========================================================
create table if not exists public.countries (
  code text primary key,
  name text not null unique,
  dial text,
  flag text,
  regions jsonb not null default '[]'::jsonb,
  police text,
  fire text,
  ambulance text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.countries enable row level security;
drop policy if exists "Public can read countries" on public.countries;
create policy "Public can read countries" on public.countries for select using (is_active = true);


insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AW','Aruba','','🇦🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AF','Afghanistan','','🇦🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AO','Angola','','🇦🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AI','Anguilla','','🇦🇮','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AX','Åland Islands','','🇦🇽','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AL','Albania','','🇦🇱','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AD','Andorra','','🇦🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AE','United Arab Emirates','+971','🇦🇪','["Dubaï", "Abou Dabi", "Sharjah", "Ajman"]','999','997','998') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AR','Argentina','+54','🇦🇷','["Buenos Aires", "Córdoba", "Rosario", "Mendoza", "La Plata"]','911','100','107') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AM','Armenia','','🇦🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AS','American Samoa','','🇦🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AQ','Antarctica','','🇦🇶','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TF','French Southern Territories','','🇹🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AG','Antigua and Barbuda','','🇦🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AU','Australia','+61','🇦🇺','["Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide"]','000','000','000') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AT','Austria','+43','🇦🇹','["Vienne", "Graz", "Linz", "Salzbourg"]','133','122','144') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('AZ','Azerbaijan','','🇦🇿','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BI','Burundi','','🇧🇮','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BE','Belgium','+32','🇧🇪','["Bruxelles", "Anvers", "Gand", "Liège"]','101','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BJ','Benin','','🇧🇯','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BQ','Bonaire, Sint Eustatius and Saba','','🇧🇶','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BF','Burkina Faso','','🇧🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BD','Bangladesh','','🇧🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BG','Bulgaria','','🇧🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BH','Bahrain','','🇧🇭','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BS','Bahamas','+1-242','🇧🇸','["Nassau", "Freeport", "Marsh Harbour"]','911','919','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BA','Bosnia and Herzegovina','','🇧🇦','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BL','Saint Barthélemy','','🇧🇱','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BY','Belarus','','🇧🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BZ','Belize','+501','🇧🇿','["Belmopan", "Belize City", "San Ignacio"]','911','990','90') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BM','Bermuda','','🇧🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BO','Bolivia, Plurinational State of','','🇧🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BR','Brazil','+55','🇧🇷','["São Paulo", "Rio de Janeiro", "Brasília", "Salvador", "Belo Horizonte", "Recife"]','190','193','192') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BB','Barbados','+1-246','🇧🇧','["Bridgetown", "Speightstown", "Oistins"]','211','311','511') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BN','Brunei Darussalam','','🇧🇳','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BT','Bhutan','','🇧🇹','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BV','Bouvet Island','','🇧🇻','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('BW','Botswana','','🇧🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CF','Central African Republic','','🇨🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CA','Canada','+1','🇨🇦','["Toronto", "Montréal", "Vancouver", "Ottawa", "Calgary", "Edmonton", "Québec", "Winnipeg"]','911','911','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CC','Cocos (Keeling) Islands','','🇨🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CH','Switzerland','+41','🇨🇭','["Zurich", "Genève", "Bâle", "Lausanne", "Berne"]','117','118','144') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CL','Chile','+56','🇨🇱','["Santiago", "Valparaíso", "Concepción", "Antofagasta", "Viña del Mar"]','133','132','131') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CN','China','+86','🇨🇳','["Pékin", "Shanghai", "Guangzhou", "Shenzhen"]','110','119','120') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CI','Côte d''Ivoire','+225','🇨🇮','["Abidjan", "Bouaké", "Yamoussoukro", "San-Pédro"]','170','180','185') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CM','Cameroon','','🇨🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CD','Congo, The Democratic Republic of the','','🇨🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CG','Congo','','🇨🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CK','Cook Islands','','🇨🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CO','Colombia','+57','🇨🇴','["Bogotá", "Medellín", "Cali", "Barranquilla", "Cartagena"]','123','119','125') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KM','Comoros','','🇰🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CV','Cabo Verde','','🇨🇻','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CR','Costa Rica','+506','🇨🇷','["San José", "Alajuela", "Heredia", "Cartago", "Liberia"]','911','911','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CU','Cuba','+53','🇨🇺','["La Havane", "Santiago de Cuba", "Camagüey", "Holguín"]','106','105','104') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CW','Curaçao','','🇨🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CX','Christmas Island','','🇨🇽','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KY','Cayman Islands','','🇰🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CY','Cyprus','','🇨🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('CZ','Czechia','+420','🇨🇿','["Prague", "Brno", "Ostrava", "Plzeň"]','158','150','155') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('DE','Germany','+49','🇩🇪','["Berlin", "Hambourg", "Munich", "Cologne", "Francfort"]','110','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('DJ','Djibouti','','🇩🇯','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('DM','Dominica','','🇩🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('DK','Denmark','+45','🇩🇰','["Copenhague", "Aarhus", "Odense", "Aalborg"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('DO','Dominican Republic','+1-809','🇩🇴','["Santo Domingo", "Santiago", "La Romana", "Puerto Plata", "San Pedro de Macorís", "Punta Cana"]','911','911','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('DZ','Algeria','+213','🇩🇿','["Alger", "Oran", "Constantine", "Annaba"]','1548','14','16') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('EC','Ecuador','','🇪🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('EG','Egypt','','🇪🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ER','Eritrea','','🇪🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('EH','Western Sahara','','🇪🇭','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ES','Spain','+34','🇪🇸','["Madrid", "Barcelone", "Valence", "Séville", "Bilbao"]','091','080','061') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('EE','Estonia','','🇪🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ET','Ethiopia','+251','🇪🇹','["Addis-Abeba", "Dire Dawa", "Mekelle", "Gondar"]','991','939','907') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('FI','Finland','+358','🇫🇮','["Helsinki", "Espoo", "Tampere", "Turku"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('FJ','Fiji','','🇫🇯','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('FK','Falkland Islands (Malvinas)','','🇫🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('FR','France','+33','🇫🇷','["Paris", "Marseille", "Lyon", "Toulouse", "Nice", "Nantes", "Bordeaux", "Lille"]','17','18','15') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('FO','Faroe Islands','','🇫🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('FM','Micronesia, Federated States of','','🇫🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GA','Gabon','','🇬🇦','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GB','United Kingdom','+44','🇬🇧','["London", "Birmingham", "Manchester", "Liverpool", "Leeds", "Glasgow"]','999/112','999/112','999/112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GE','Georgia','','🇬🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GG','Guernsey','','🇬🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GH','Ghana','+233','🇬🇭','["Accra", "Kumasi", "Tamale", "Takoradi"]','191','192','193') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GI','Gibraltar','','🇬🇮','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GN','Guinea','','🇬🇳','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GP','Guadeloupe','','🇬🇵','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GM','Gambia','','🇬🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GW','Guinea-Bissau','','🇬🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GQ','Equatorial Guinea','','🇬🇶','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GR','Greece','+30','🇬🇷','["Athènes", "Thessalonique", "Patras", "Héraklion"]','100','199','166') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GD','Grenada','','🇬🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GL','Greenland','','🇬🇱','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GT','Guatemala','+502','🇬🇹','["Guatemala City", "Quetzaltenango", "Escuintla", "Antigua Guatemala"]','110','122','128') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GF','French Guiana','','🇬🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GU','Guam','','🇬🇺','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GY','Guyana','','🇬🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('HK','Hong Kong','','🇭🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('HM','Heard Island and McDonald Islands','','🇭🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('HN','Honduras','+504','🇭🇳','["Tegucigalpa", "San Pedro Sula", "La Ceiba", "Choloma"]','911','198','195') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('HR','Croatia','','🇭🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('HT','Haiti','+509','🇭🇹','["Port-au-Prince", "Cap-Haïtien", "Delmas", "Pétion-Ville", "Les Cayes", "Jacmel", "Gonaïves", "Saint-Marc"]','114/122','115','116/922') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('HU','Hungary','','🇭🇺','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ID','Indonesia','','🇮🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IM','Isle of Man','','🇮🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IN','India','+91','🇮🇳','["Delhi", "Mumbai", "Bangalore", "Chennai", "Hyderabad"]','112','101','108') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IO','British Indian Ocean Territory','','🇮🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IE','Ireland','+353','🇮🇪','["Dublin", "Cork", "Limerick", "Galway"]','999/112','999/112','999/112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IR','Iran, Islamic Republic of','','🇮🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IQ','Iraq','','🇮🇶','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IS','Iceland','+354','🇮🇸','["Reykjavík", "Kópavogur", "Hafnarfjörður"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IL','Israel','','🇮🇱','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('IT','Italy','+39','🇮🇹','["Rome", "Milan", "Naples", "Turin", "Florence"]','112','115','118') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('JM','Jamaica','+1-876','🇯🇲','["Kingston", "Montego Bay", "Spanish Town", "Portmore"]','119','110','110') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('JE','Jersey','','🇯🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('JO','Jordan','','🇯🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('JP','Japan','+81','🇯🇵','["Tokyo", "Osaka", "Kyoto", "Yokohama", "Nagoya"]','110','119','119') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KZ','Kazakhstan','','🇰🇿','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KE','Kenya','+254','🇰🇪','["Nairobi", "Mombasa", "Kisumu", "Nakuru"]','999/112','999','999') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KG','Kyrgyzstan','','🇰🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KH','Cambodia','','🇰🇭','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KI','Kiribati','','🇰🇮','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KN','Saint Kitts and Nevis','','🇰🇳','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KR','Korea, Republic of','+82','🇰🇷','["Séoul", "Busan", "Incheon", "Daegu"]','112','119','119') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KW','Kuwait','','🇰🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LA','Lao People''s Democratic Republic','','🇱🇦','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LB','Lebanon','','🇱🇧','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LR','Liberia','','🇱🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LY','Libya','','🇱🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LC','Saint Lucia','','🇱🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LI','Liechtenstein','','🇱🇮','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LK','Sri Lanka','','🇱🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LS','Lesotho','','🇱🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LT','Lithuania','','🇱🇹','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LU','Luxembourg','','🇱🇺','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('LV','Latvia','','🇱🇻','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MO','Macao','','🇲🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MF','Saint Martin (French part)','','🇲🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MA','Morocco','+212','🇲🇦','["Rabat", "Casablanca", "Marrakech", "Fès", "Tanger"]','19','15','15') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MC','Monaco','','🇲🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MD','Moldova, Republic of','','🇲🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MG','Madagascar','','🇲🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MV','Maldives','','🇲🇻','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MX','Mexico','+52','🇲🇽','["Mexico City", "Guadalajara", "Monterrey", "Puebla", "Cancún", "Tijuana"]','911','911','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MH','Marshall Islands','','🇲🇭','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MK','North Macedonia','','🇲🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ML','Mali','','🇲🇱','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MT','Malta','','🇲🇹','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MM','Myanmar','','🇲🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ME','Montenegro','','🇲🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MN','Mongolia','','🇲🇳','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MP','Northern Mariana Islands','','🇲🇵','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MZ','Mozambique','','🇲🇿','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MR','Mauritania','','🇲🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MS','Montserrat','','🇲🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MQ','Martinique','','🇲🇶','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MU','Mauritius','','🇲🇺','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MW','Malawi','','🇲🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('MY','Malaysia','','🇲🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('YT','Mayotte','','🇾🇹','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NA','Namibia','','🇳🇦','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NC','New Caledonia','','🇳🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NE','Niger','','🇳🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NF','Norfolk Island','','🇳🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NG','Nigeria','+234','🇳🇬','["Lagos", "Abuja", "Kano", "Ibadan"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NI','Nicaragua','+505','🇳🇮','["Managua", "León", "Masaya", "Granada"]','118','115','128') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NU','Niue','','🇳🇺','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NL','Netherlands','+31','🇳🇱','["Amsterdam", "Rotterdam", "La Haye", "Utrecht"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NO','Norway','+47','🇳🇴','["Oslo", "Bergen", "Trondheim", "Stavanger"]','112','110','113') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NP','Nepal','','🇳🇵','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NR','Nauru','','🇳🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('NZ','New Zealand','+64','🇳🇿','["Auckland", "Wellington", "Christchurch", "Hamilton"]','111','111','111') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('OM','Oman','','🇴🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PK','Pakistan','','🇵🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PA','Panama','+507','🇵🇦','["Panama City", "Colón", "David", "Santiago"]','104','103','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PN','Pitcairn','','🇵🇳','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PE','Peru','+51','🇵🇪','["Lima", "Arequipa", "Cusco", "Trujillo", "Piura"]','105','116','106') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PH','Philippines','+63','🇵🇭','["Manille", "Cebu City", "Davao City", "Quezon City"]','911','911','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PW','Palau','','🇵🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PG','Papua New Guinea','','🇵🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PL','Poland','+48','🇵🇱','["Varsovie", "Cracovie", "Wrocław", "Gdańsk"]','112','998','999') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PR','Puerto Rico','','🇵🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('KP','Korea, Democratic People''s Republic of','','🇰🇵','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PT','Portugal','+351','🇵🇹','["Lisbonne", "Porto", "Braga", "Coimbra"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PY','Paraguay','','🇵🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PS','Palestine, State of','','🇵🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PF','French Polynesia','','🇵🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('QA','Qatar','','🇶🇦','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('RE','Réunion','','🇷🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('RO','Romania','+40','🇷🇴','["Bucarest", "Cluj-Napoca", "Timișoara", "Iași"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('RU','Russian Federation','','🇷🇺','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('RW','Rwanda','','🇷🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SA','Saudi Arabia','+966','🇸🇦','["Riyad", "Djeddah", "La Mecque", "Médine"]','999','998','997') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SD','Sudan','','🇸🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SN','Senegal','+221','🇸🇳','["Dakar", "Thiès", "Saint-Louis", "Kaolack"]','17','18','15') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SG','Singapore','+65','🇸🇬','["Singapour"]','999','995','995') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('GS','South Georgia and the South Sandwich Islands','','🇬🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SH','Saint Helena, Ascension and Tristan da Cunha','','🇸🇭','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SJ','Svalbard and Jan Mayen','','🇸🇯','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SB','Solomon Islands','','🇸🇧','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SL','Sierra Leone','','🇸🇱','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SV','El Salvador','+503','🇸🇻','["San Salvador", "Santa Ana", "San Miguel", "Soyapango"]','911','913','132') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SM','San Marino','','🇸🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SO','Somalia','','🇸🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('PM','Saint Pierre and Miquelon','','🇵🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('RS','Serbia','','🇷🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SS','South Sudan','','🇸🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ST','Sao Tome and Principe','','🇸🇹','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SR','Suriname','','🇸🇷','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SK','Slovakia','','🇸🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SI','Slovenia','','🇸🇮','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SE','Sweden','+46','🇸🇪','["Stockholm", "Göteborg", "Malmö", "Uppsala"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SZ','Eswatini','','🇸🇿','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SX','Sint Maarten (Dutch part)','','🇸🇽','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SC','Seychelles','','🇸🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('SY','Syrian Arab Republic','','🇸🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TC','Turks and Caicos Islands','','🇹🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TD','Chad','','🇹🇩','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TG','Togo','','🇹🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TH','Thailand','','🇹🇭','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TJ','Tajikistan','','🇹🇯','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TK','Tokelau','','🇹🇰','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TM','Turkmenistan','','🇹🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TL','Timor-Leste','','🇹🇱','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TO','Tonga','','🇹🇴','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TT','Trinidad and Tobago','+1-868','🇹🇹','["Port of Spain", "San Fernando", "Chaguanas", "Arima"]','999','990','811') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TN','Tunisia','+216','🇹🇳','["Tunis", "Sfax", "Sousse", "Bizerte"]','197','198','190') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TR','Türkiye','+90','🇹🇷','["Istanbul", "Ankara", "Izmir", "Bursa"]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TV','Tuvalu','','🇹🇻','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TW','Taiwan, Province of China','','🇹🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('TZ','Tanzania, United Republic of','','🇹🇿','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('UG','Uganda','','🇺🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('UA','Ukraine','+380','🇺🇦','["Kyiv", "Lviv", "Odesa", "Kharkiv"]','102','101','103') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('UM','United States Minor Outlying Islands','','🇺🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('UY','Uruguay','','🇺🇾','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('US','United States','+1','🇺🇸','["New York", "Los Angeles", "Miami", "Chicago", "Houston", "Boston", "Atlanta", "Washington"]','911','911','911') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('UZ','Uzbekistan','','🇺🇿','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('VA','Holy See (Vatican City State)','','🇻🇦','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('VC','Saint Vincent and the Grenadines','','🇻🇨','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('VE','Venezuela, Bolivarian Republic of','','🇻🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('VG','Virgin Islands, British','','🇻🇬','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('VI','Virgin Islands, U.S.','','🇻🇮','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('VN','Viet Nam','','🇻🇳','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('VU','Vanuatu','','🇻🇺','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('WF','Wallis and Futuna','','🇼🇫','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('WS','Samoa','','🇼🇸','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('YE','Yemen','','🇾🇪','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ZA','South Africa','+27','🇿🇦','["Johannesburg", "Cape Town", "Durban", "Pretoria"]','10111','10177','10177') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ZM','Zambia','','🇿🇲','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;
insert into public.countries(code,name,dial,flag,regions,police,fire,ambulance) values ('ZW','Zimbabwe','','🇿🇼','[]','112','112','112') on conflict (code) do update set name=excluded.name,dial=excluded.dial,flag=excluded.flag,regions=excluded.regions,police=excluded.police,fire=excluded.fire,ambulance=excluded.ambulance,is_active=true;

-- =========================================================
-- 4. PROFESSIONS — 750
-- =========================================================
create table if not exists public.professions (
  id bigserial primary key,
  name text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.professions enable row level security;
drop policy if exists "Public can read professions" on public.professions;
create policy "Public can read professions" on public.professions for select using (is_active = true);


insert into public.professions(name) values ('Accordeur de piano') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Boucher') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Boulanger') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Carreleur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Carrossier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chaudronnier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chauffagiste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chef événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Chirurgien-dentiste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Climaticien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coach sportif') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coiffeur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Comptable') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Comédien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Conducteur d''engins') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Conseiller financier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Consultant événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Coordinateur événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Cordonnier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Couvreur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Cuisinier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Dentiste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Designer graphique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Diététicien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Décorateur d''intérieur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Développeur mobile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Développeur web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Enseignant') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Entrepreneur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Esthéticien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Expert-comptable') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Fleuriste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Forgeron') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur professionnel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Formateur événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Gestionnaire événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Graphiste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Guide touristique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Géologue') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Géomètre') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Horloger') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Ingénieur civil') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Ingénieur logiciel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Ingénieur mécanique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Installateur solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Jardinier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Journaliste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Kinésithérapeute') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Laborantin') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Libraire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Livreur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Magasinier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Manucure') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Manutentionnaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Maçon') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Menuisier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Moniteur auto-école') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Monteur vidéo') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Musicien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Mécanicien automobile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Mécanicien moto') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Médiateur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Nettoyeur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Notaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Opticien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Orthophoniste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Ostéopathe') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Paysagiste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Peintre en bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Photographe') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Plombier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Plâtrier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Podologue') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Polisseur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Professeur de musique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Programmeur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Psychologue') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Publicitaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Pédiatre') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable RH') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Responsable événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Restaurateur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Réceptionniste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Réparateur informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Réparateur électroménager') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Sage-femme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Sculpteur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Secrétaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Serrurier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Serveur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Soudeur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste cybersécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste SEO') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Spécialiste événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Tailleur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien agricole') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien biomédical') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien bâtiment') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien comptabilité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien data') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien fibre optique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien finance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien formation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien froid') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien immobilier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien industrie') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien informatique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien laboratoire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien logistique') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien marketing') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien réseau') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien réseaux') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien services à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien sécurité') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien tourisme') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien transport') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien télécom') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien vente') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien web') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien énergie solaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Technicien événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Toiturier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Traducteur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Traiteur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Urbaniste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Vitrier') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Vétérinaire') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Webdesigner') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Yoga instructor') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Ébéniste') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Électricien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Électromécanicien') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Éleveur') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Accordeur de piano — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Acousticien — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Actuaire — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Administrateur réseau — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent d''entretien — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agent immobilier — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Agriculteur — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Architecte — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Artisan cuir — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant administratif — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant agricole — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant bâtiment — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant commercial — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptabilité — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant comptable — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant data — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant dentaire — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant finance — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant formation — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant immobilier — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant industrie — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant informatique — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant logistique — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maintenance — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant marketing — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant maternel — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant réseaux — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant services à domicile — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant sécurité — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant tourisme — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant transport — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant télécom — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant vente — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant web — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant énergie solaire — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Assistant événementiel — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Audioprothésiste — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Avocat — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — installation') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Barbier — maintenance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — résidentiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — commercial') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — industriel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — événementiel') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — à domicile') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — freelance') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — certifié') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — urgence') on conflict (name) do update set is_active=true;
insert into public.professions(name) values ('Bijoutier — installation') on conflict (name) do update set is_active=true;

-- =========================================================
-- 5. LANGUAGES — 22
-- =========================================================
create table if not exists public.languages (
  code text primary key,
  name text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.languages enable row level security;
drop policy if exists "Public can read languages" on public.languages;
create policy "Public can read languages" on public.languages for select using (is_active = true);


insert into public.languages(code,name) values ('ht','Kreyòl Ayisyen') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('fr','Français') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('en','English') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('es','Español') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('pt','Português') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('ar','العربية') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('zh','中文') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('hi','हिन्दी') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('bn','বাংলা') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('ru','Русский') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('de','Deutsch') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('ja','日本語') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('ko','한국어') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('it','Italiano') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('nl','Nederlands') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('tr','Türkçe') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('pl','Polski') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('uk','Українська') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('sw','Kiswahili') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('vi','Tiếng Việt') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('yo','Yorùbá') on conflict (code) do update set name=excluded.name,is_active=true;
insert into public.languages(code,name) values ('id','Bahasa Indonesia') on conflict (code) do update set name=excluded.name,is_active=true;

-- =========================================================
-- 6. PAYMENT METHODS
-- =========================================================
create table if not exists public.payment_methods (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  phone text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.payment_methods enable row level security;
drop policy if exists "Public can read payment methods" on public.payment_methods;
create policy "Public can read payment methods" on public.payment_methods for select using (is_active = true);

insert into public.payment_methods(code,name,phone,is_active)
values
('moncash','MonCash','36246316',true),
('natcash','NatCash','40061709',true),
('taptap_send','Taptap Send',null,true),
('international_transfer','Autres services internationaux',null,true)
on conflict (code) do update set name=excluded.name,phone=excluded.phone,is_active=true;

-- =========================================================
-- 7. SUBSCRIPTION PLANS
-- =========================================================
create table if not exists public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  duration_days integer not null check (duration_days > 0),
  price_htg numeric(12,2) not null check (price_htg >= 0),
  price_usd numeric(12,2) not null check (price_usd >= 0),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.subscription_plans enable row level security;
drop policy if exists "Public can read active plans" on public.subscription_plans;
create policy "Public can read active plans" on public.subscription_plans for select using (is_active = true);

insert into public.subscription_plans(code,name,duration_days,price_htg,price_usd)
values
('weekly','7 jours',7,130,0.99),
('monthly','30 jours',30,450,3.49),
('quarterly','3 mois',90,1200,9.49)
on conflict (code) do update set name=excluded.name,duration_days=excluded.duration_days,price_htg=excluded.price_htg,price_usd=excluded.price_usd,is_active=true;

-- =========================================================
-- 8. PAYMENTS
-- =========================================================
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_id uuid references public.subscription_plans(id) on delete set null,
  payment_method_id uuid references public.payment_methods(id) on delete set null,
  amount numeric(12,2) not null check (amount >= 0),
  currency text not null check (currency in ('HTG','USD')),
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  proof_url text,
  note text,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);
alter table public.payments enable row level security;
drop policy if exists "Users can create own payments" on public.payments;
create policy "Users can create own payments" on public.payments for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can read own payments" on public.payments;
create policy "Users can read own payments" on public.payments for select to authenticated using (auth.uid() = user_id);

-- =========================================================
-- 9. PAYMENT PROOFS
-- =========================================================
create table if not exists public.payment_proofs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  method text not null check (method in ('moncash','natcash')),
  amount numeric(12,2),
  proof_url text,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  submitted_at timestamptz not null default now(),
  reviewed_at timestamptz
);
alter table public.payment_proofs enable row level security;
drop policy if exists "Users can create own payment proof" on public.payment_proofs;
create policy "Users can create own payment proof" on public.payment_proofs
for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "Users can read own payment proof" on public.payment_proofs;
create policy "Users can read own payment proof" on public.payment_proofs
for select to authenticated using (auth.uid() = user_id);

-- =========================================================
-- 10. SUBSCRIPTIONS
-- =========================================================
create table if not exists public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  plan_id uuid not null references public.subscription_plans(id) on delete restrict,
  payment_id uuid references public.payments(id) on delete set null,
  starts_at timestamptz not null default now(),
  ends_at timestamptz not null,
  status text not null default 'active' check (status in ('pending','active','expired','cancelled')),
  created_at timestamptz not null default now()
);
alter table public.subscriptions enable row level security;
drop policy if exists "Users can read own subscriptions" on public.subscriptions;
create policy "Users can read own subscriptions" on public.subscriptions
for select to authenticated using (auth.uid() = user_id);

-- =========================================================
-- 11. INDEXES
-- =========================================================
create index if not exists idx_profiles_country on public.profiles(country_code);
create index if not exists idx_profiles_profession on public.profiles(profession);
create index if not exists idx_profiles_city on public.profiles(city);
create index if not exists idx_profiles_premium on public.profiles(premium);
create index if not exists idx_profiles_banned on public.profiles(banned);
create index if not exists idx_payments_user on public.payments(user_id);
create index if not exists idx_payment_proofs_user on public.payment_proofs(user_id);
create index if not exists idx_subscriptions_user on public.subscriptions(user_id);
create index if not exists idx_subscriptions_status on public.subscriptions(status);

-- =========================================================
-- 12. OPTIONAL: keep premium flag synchronized by active subscription
-- =========================================================
create or replace function public.sync_profile_premium()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.profiles
  set premium = (new.status = 'active' and new.ends_at > now())
  where id = new.user_id;
  return new;
end;
$$;

drop trigger if exists sync_profile_premium_after_subscription on public.subscriptions;
create trigger sync_profile_premium_after_subscription
after insert or update of status, ends_at on public.subscriptions
for each row execute function public.sync_profile_premium();

-- =========================================================
-- 13. VERIFICATION
-- =========================================================
select
  (select count(*) from public.countries where is_active) as countries,
  (select count(*) from public.professions where is_active) as professions,
  (select count(*) from public.languages where is_active) as languages,
  (select count(*) from public.payment_methods where is_active) as payment_methods,
  (select count(*) from public.subscription_plans where is_active) as subscription_plans;


-- =========================================================
-- 14. NEXORA SOCIAL / SERVICE FEATURES
-- =========================================================
alter table public.profiles add column if not exists verified boolean not null default false;
alter table public.profiles add column if not exists rating numeric(3,2) not null default 0;
alter table public.profiles add column if not exists review_count integer not null default 0;
alter table public.profiles add column if not exists premium_until timestamptz;

create table if not exists public.favorites (
  user_id uuid not null,
  professional_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id, professional_id)
);
create table if not exists public.pinned_professionals (
  user_id uuid not null,
  professional_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id, professional_id)
);

create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  reviewer_id uuid not null,
  professional_id uuid not null references public.profiles(id) on delete cascade,
  rating integer not null check(rating between 1 and 5),
  comment text,
  created_at timestamptz not null default now(),
  unique(reviewer_id, professional_id)
);
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null,
  receiver_id uuid not null references public.profiles(id) on delete cascade,
  body text not null check(length(trim(body)) between 1 and 5000),
  created_at timestamptz not null default now(),
  read_at timestamptz
);
create table if not exists public.booking_requests (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null,
  professional_id uuid not null references public.profiles(id) on delete cascade,
  requested_date date not null,
  requested_time time not null,
  note text,
  status text not null default 'pending' check(status in ('pending','accepted','rejected','cancelled')),
  created_at timestamptz not null default now()
);
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  kind text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.notifications add column if not exists kind text;
alter table public.favorites drop constraint if exists favorites_user_id_fkey;
alter table public.booking_requests drop constraint if exists booking_requests_customer_id_fkey;
alter table public.messages drop constraint if exists messages_sender_id_fkey;
alter table public.favorites enable row level security;
alter table public.pinned_professionals enable row level security;
alter table public.reviews enable row level security;
alter table public.messages enable row level security;
alter table public.booking_requests enable row level security;
alter table public.notifications enable row level security;

drop policy if exists "Users manage own favorites" on public.favorites;
create policy "Users manage own favorites" on public.favorites for all to authenticated
using(auth.uid()=user_id) with check(auth.uid()=user_id);

drop policy if exists "Users manage own pinned professionals" on public.pinned_professionals;
create policy "Users manage own pinned professionals" on public.pinned_professionals for all to authenticated
using(auth.uid()=user_id) with check(auth.uid()=user_id);

drop policy if exists "Public read reviews" on public.reviews;
create policy "Public read reviews" on public.reviews for select using(true);
drop policy if exists "Users create reviews" on public.reviews;
create policy "Users create reviews" on public.reviews for insert to authenticated
with check(auth.uid()=reviewer_id);

drop policy if exists "Users read own messages" on public.messages;
create policy "Users read own messages" on public.messages for select to authenticated
using(auth.uid()=sender_id or auth.uid()=receiver_id);
drop policy if exists "Users send messages" on public.messages;
create policy "Users send messages" on public.messages for insert to authenticated
with check(auth.uid()=sender_id);

-- Customer accounts are authenticated users; customer IDs do not require a profiles row.
drop policy if exists "Users update own message read state" on public.messages;
create policy "Users update own message read state" on public.messages for update to authenticated
using(auth.uid()=receiver_id) with check(auth.uid()=receiver_id);

drop policy if exists "Users read bookings" on public.booking_requests;
create policy "Users read bookings" on public.booking_requests for select to authenticated
using(auth.uid()=customer_id or auth.uid()=professional_id);
drop policy if exists "Users create bookings" on public.booking_requests;
create policy "Users create bookings" on public.booking_requests for insert to authenticated
with check(auth.uid()=customer_id);
drop policy if exists "Participants update bookings" on public.booking_requests;
create policy "Participants update bookings" on public.booking_requests for update to authenticated
using(auth.uid()=customer_id or auth.uid()=professional_id)
with check(auth.uid()=customer_id or auth.uid()=professional_id);

drop policy if exists "Users read own notifications" on public.notifications;
create policy "Users read own notifications" on public.notifications for select to authenticated
using(auth.uid()=user_id);
drop policy if exists "Users update own notifications" on public.notifications;
create policy "Users update own notifications" on public.notifications for update to authenticated
using(auth.uid()=user_id) with check(auth.uid()=user_id);


-- Create in-app notifications for professional activity.
create or replace function public.notify_professional_activity()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  if TG_TABLE_NAME='messages' then
    insert into public.notifications(user_id,title,body,kind) values (new.receiver_id,'New message','You received a new Nexora message.','new_message');
  elsif TG_TABLE_NAME='booking_requests' then
    insert into public.notifications(user_id,title,body,kind) values (new.professional_id,'New booking request','You received a new booking request.','new_booking');
  elsif TG_TABLE_NAME='reviews' then
    insert into public.notifications(user_id,title,body,kind) values (new.professional_id,'New review','A client left a new review.','new_review');
  end if;
  return new;
end $$;
drop trigger if exists notify_message_trigger on public.messages;
create trigger notify_message_trigger after insert on public.messages for each row execute function public.notify_professional_activity();
drop trigger if exists notify_booking_trigger on public.booking_requests;
create trigger notify_booking_trigger after insert on public.booking_requests for each row execute function public.notify_professional_activity();
drop trigger if exists notify_review_trigger on public.reviews;
create trigger notify_review_trigger after insert on public.reviews for each row execute function public.notify_professional_activity();

create or replace function public.refresh_profile_rating()
returns trigger language plpgsql security definer set search_path=public as $$
declare target_id uuid;
begin
  if TG_OP='DELETE' then target_id:=old.professional_id; else target_id:=new.professional_id; end if;
  update public.profiles
  set rating=coalesce((select round(avg(r.rating)::numeric,2) from public.reviews r where r.professional_id=target_id),0),
      review_count=(select count(*) from public.reviews r where r.professional_id=target_id)
  where id=target_id;
  if TG_OP='DELETE' then return old; else return new; end if;
end $$;
drop trigger if exists refresh_profile_rating_trigger on public.reviews;
create trigger refresh_profile_rating_trigger after insert or update or delete on public.reviews
for each row execute function public.refresh_profile_rating();

-- Verified is admin-only, just like Premium/Banned.
create or replace function public.prevent_profile_status_changes()
returns trigger language plpgsql security invoker as $$
begin
  if auth.uid()=old.id and (
    new.premium is distinct from old.premium or
    new.banned is distinct from old.banned or
    new.verified is distinct from old.verified or
    new.premium_until is distinct from old.premium_until
  ) then raise exception 'premium, banned and verified are admin-only fields'; end if;
  return new;
end $$;
drop trigger if exists prevent_profile_status_changes on public.profiles;
create trigger prevent_profile_status_changes before update on public.profiles
for each row execute function public.prevent_profile_status_changes();

create or replace function public.sync_profile_premium()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  update public.profiles
  set premium=(new.status='active' and new.ends_at>now()),
      premium_until=case when new.status='active' then new.ends_at else null end
  where id=new.user_id;
  return new;
end $$;
drop trigger if exists sync_profile_premium_after_subscription on public.subscriptions;
create trigger sync_profile_premium_after_subscription after insert or update of status, ends_at on public.subscriptions
for each row execute function public.sync_profile_premium();

create index if not exists idx_profiles_rating on public.profiles(rating);
create index if not exists idx_reviews_professional on public.reviews(professional_id);
create index if not exists idx_messages_receiver on public.messages(receiver_id,created_at desc);
create index if not exists idx_bookings_professional on public.booking_requests(professional_id,requested_date);

-- Add Ria as a supported manual receiving method.
insert into public.payment_methods(code,name,phone,is_active)
values ('ria','Ria Money Transfer',null,true)
on conflict (code) do update set name=excluded.name,is_active=true;

-- Keep manual-payment records available to the signed-in professional.


-- =========================================================
-- 15. PREMIUM EXPIRATION SAFETY
-- =========================================================
create or replace function public.expire_premium_profiles()
returns void language plpgsql security definer set search_path=public as $$
begin
  update public.profiles
  set premium=false, premium_until=null
  where premium=true and premium_until is not null and premium_until <= now();
  update public.subscriptions
  set status='expired'
  where status='active' and ends_at <= now();
end $$;

create or replace function public.sync_expired_subscription()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  if new.ends_at <= now() and new.status='active' then new.status := 'expired'; end if;
  return new;
end $$;
drop trigger if exists sync_expired_subscription_before_write on public.subscriptions;
create trigger sync_expired_subscription_before_write before insert or update of ends_at,status on public.subscriptions
for each row execute function public.sync_expired_subscription();
