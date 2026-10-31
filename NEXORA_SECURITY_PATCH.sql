-- Apply on EXISTING Supabase project; for fresh projects run setup SQL first, then this patch.
create or replace function public.prevent_profile_status_changes()
returns trigger language plpgsql security invoker as $$
begin
 if auth.uid()=old.id and (new.premium is distinct from old.premium or new.banned is distinct from old.banned or new.verified is distinct from old.verified or new.premium_until is distinct from old.premium_until) then raise exception 'Admin-only fields'; end if;
 return new;
end $$;
create table if not exists public.admin_login_attempts(ip_hash text primary key, attempts integer not null default 0, window_started timestamptz not null default now(), locked_until timestamptz);
revoke all on public.admin_login_attempts from anon,authenticated;
create or replace function public.check_admin_login_attempt(p_hash text,p_success boolean)
returns boolean language plpgsql security definer set search_path=public as $$
declare r public.admin_login_attempts%rowtype;
begin
 if length(p_hash)<>64 then raise exception 'Invalid hash'; end if;
 insert into public.admin_login_attempts(ip_hash) values(p_hash) on conflict(ip_hash) do nothing;
 select * into r from public.admin_login_attempts where ip_hash=p_hash for update;
 if r.locked_until>now() then return false; end if;
 if p_success then update public.admin_login_attempts set attempts=0,locked_until=null,window_started=now() where ip_hash=p_hash; return true; end if;
 if r.window_started<now()-interval '15 minutes' then update public.admin_login_attempts set attempts=1,window_started=now(),locked_until=null where ip_hash=p_hash;
 else update public.admin_login_attempts set attempts=attempts+1,locked_until=case when attempts+1>=5 then now()+interval '15 minutes' else null end where ip_hash=p_hash; end if;
 return false;
end $$;
revoke all on function public.check_admin_login_attempt(text,boolean) from public,anon,authenticated;
grant execute on function public.check_admin_login_attempt(text,boolean) to service_role;
create or replace function public.admin_set_subscription(p_user uuid,p_plan_code text,p_days integer,p_enabled boolean)
returns void language plpgsql security definer set search_path=public as $$
declare v_plan public.subscription_plans.id%type; v_end timestamptz;
begin
 if auth.role()<>'service_role' then raise exception 'Forbidden'; end if;
 if not exists(select 1 from public.profiles where id=p_user) then raise exception 'User not found'; end if;
 if p_enabled then
  if p_days not in (7,30,90) or p_plan_code not in ('weekly','monthly','quarterly') then raise exception 'Invalid plan'; end if;
  select id into v_plan from public.subscription_plans where code=p_plan_code;
  if v_plan is null then raise exception 'Plan not found'; end if;
  v_end:=now()+make_interval(days=>p_days);
  update public.subscriptions set status='cancelled' where user_id=p_user and status='active';
  insert into public.subscriptions(user_id,plan_id,starts_at,ends_at,status) values(p_user,v_plan,now(),v_end,'active');
  update public.profiles set premium=true,premium_until=v_end where id=p_user;
 else
  update public.subscriptions set status='cancelled' where user_id=p_user and status='active';
  update public.profiles set premium=false,premium_until=null where id=p_user;
 end if;
end $$;
revoke all on function public.admin_set_subscription(uuid,text,integer,boolean) from public,anon,authenticated;
grant execute on function public.admin_set_subscription(uuid,text,integer,boolean) to service_role;
