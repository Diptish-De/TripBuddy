-- ============================================================================
-- TripBuddy — Migration 20261022000000: Initial Schema & Security Policies
-- ============================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Profiles Table (mirrors auth.users)
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null,
  email text not null,
  avatar_url text,
  created_at timestamptz default now() not null
);

alter table public.profiles enable row level security;

create policy "Profiles are viewable by authenticated users" on public.profiles
  for select to authenticated using (true);

create policy "Users can update their own profile" on public.profiles
  for update to authenticated using (auth.uid() = id);

-- Auto-create profile trigger on signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, display_name, email, avatar_url)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      split_part(new.email, '@', 1)
    ),
    new.email,
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do update set
    display_name = excluded.display_name,
    email = excluded.email,
    avatar_url = coalesce(excluded.avatar_url, profiles.avatar_url);
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2. Trips Table
create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  destination text not null,
  description text,
  cover_image_url text,
  start_date date not null,
  end_date date not null,
  invite_code text unique not null,
  created_by uuid references auth.users(id) on delete cascade not null,
  created_at timestamptz default now() not null,
  constraint valid_trip_dates check (end_date >= start_date)
);

create index if not exists idx_trips_invite_code on public.trips(invite_code);
create index if not exists idx_trips_created_by on public.trips(created_by);

-- 3. Trip Members Table
create table if not exists public.trip_members (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  role text default 'member' not null check (role in ('admin', 'member')),
  joined_at timestamptz default now() not null,
  unique (trip_id, user_id)
);

create index if not exists idx_trip_members_user on public.trip_members(user_id);
create index if not exists idx_trip_members_trip on public.trip_members(trip_id);

-- Helper security function: Check membership without infinite recursion
create or replace function public.is_trip_member(lookup_trip_id uuid)
returns boolean as $$
  select exists (
    select 1 from public.trip_members
    where trip_members.trip_id = lookup_trip_id
      and trip_members.user_id = auth.uid()
  );
$$ language sql security definer;

-- Helper security function: Check if user is trip admin
create or replace function public.is_trip_admin(lookup_trip_id uuid)
returns boolean as $$
  select exists (
    select 1 from public.trip_members
    where trip_members.trip_id = lookup_trip_id
      and trip_members.user_id = auth.uid()
      and trip_members.role = 'admin'
  );
$$ language sql security definer;

-- Trips RLS Policies
alter table public.trips enable row level security;

create policy "Members can view trips" on public.trips
  for select to authenticated
  using (created_by = auth.uid() or public.is_trip_member(id));

create policy "Authenticated users can create trips" on public.trips
  for insert to authenticated
  with check (auth.uid() = created_by);

create policy "Trip admins can update trips" on public.trips
  for update to authenticated
  using (created_by = auth.uid() or public.is_trip_admin(id));

create policy "Trip creators can delete trips" on public.trips
  for delete to authenticated
  using (created_by = auth.uid());

-- Trip Members RLS Policies
alter table public.trip_members enable row level security;

create policy "Members can view trip members" on public.trip_members
  for select to authenticated
  using (public.is_trip_member(trip_id) or user_id = auth.uid());

create policy "Trip creators or joining members can insert membership" on public.trip_members
  for insert to authenticated
  with check (user_id = auth.uid());

create policy "Members can leave or admins can remove members" on public.trip_members
  for delete to authenticated
  using (user_id = auth.uid() or public.is_trip_admin(trip_id));

-- Atomic Trip Creation Function
create or replace function public.create_trip_atomic(
  p_name text,
  p_destination text,
  p_description text,
  p_start_date date,
  p_end_date date,
  p_invite_code text
)
returns json as $$
declare
  v_trip public.trips;
begin
  insert into public.trips (
    name, destination, description, start_date, end_date, invite_code, created_by
  ) values (
    p_name, p_destination, p_description, p_start_date, p_end_date, upper(p_invite_code), auth.uid()
  ) returning * into v_trip;

  insert into public.trip_members (
    trip_id, user_id, role
  ) values (
    v_trip.id, auth.uid(), 'admin'
  );

  return row_to_json(v_trip);
end;
$$ language plpgsql security definer;

-- Atomic Join Trip Function
create or replace function public.join_trip_by_code(p_invite_code text)
returns json as $$
declare
  v_trip public.trips;
begin
  select * into v_trip from public.trips
  where upper(invite_code) = upper(trim(p_invite_code));

  if v_trip.id is null then
    raise exception 'Trip not found with invite code: %', p_invite_code;
  end if;

  insert into public.trip_members (trip_id, user_id, role)
  values (v_trip.id, auth.uid(), 'member')
  on conflict (trip_id, user_id) do nothing;

  return row_to_json(v_trip);
end;
$$ language plpgsql security definer;

-- 4. Itinerary Items Table
create table if not exists public.itinerary_items (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade not null,
  title text not null,
  description text,
  location text,
  date date not null,
  start_time time,
  end_time time,
  category text default 'activity' not null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz default now() not null
);

create index if not exists idx_itinerary_trip_date on public.itinerary_items(trip_id, date);

alter table public.itinerary_items enable row level security;

create policy "Members can view itinerary" on public.itinerary_items
  for select to authenticated using (public.is_trip_member(trip_id));

create policy "Members can insert itinerary" on public.itinerary_items
  for insert to authenticated with check (public.is_trip_member(trip_id));

create policy "Members can update itinerary" on public.itinerary_items
  for update to authenticated using (public.is_trip_member(trip_id));

create policy "Members can delete itinerary" on public.itinerary_items
  for delete to authenticated using (public.is_trip_member(trip_id));

-- 5. Expenses & Expense Splits Tables
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade not null,
  paid_by uuid references auth.users(id) on delete cascade not null,
  title text not null,
  amount numeric(10,2) not null check (amount > 0),
  category text default 'other' not null,
  split_type text default 'equal' not null,
  created_at timestamptz default now() not null
);

create index if not exists idx_expenses_trip on public.expenses(trip_id);

create table if not exists public.expense_splits (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid references public.expenses(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  amount numeric(10,2) not null check (amount >= 0),
  created_at timestamptz default now() not null,
  unique (expense_id, user_id)
);

create index if not exists idx_expense_splits_expense on public.expense_splits(expense_id);

alter table public.expenses enable row level security;
alter table public.expense_splits enable row level security;

create policy "Members can view expenses" on public.expenses
  for select to authenticated using (public.is_trip_member(trip_id));

create policy "Members can insert expenses" on public.expenses
  for insert to authenticated with check (public.is_trip_member(trip_id));

create policy "Members can delete expenses" on public.expenses
  for delete to authenticated using (public.is_trip_member(trip_id));

create policy "Members can view splits" on public.expense_splits
  for select to authenticated using (
    exists (select 1 from public.expenses where expenses.id = expense_splits.expense_id and public.is_trip_member(expenses.trip_id))
  );

create policy "Members can insert splits" on public.expense_splits
  for insert to authenticated with check (
    exists (select 1 from public.expenses where expenses.id = expense_splits.expense_id and public.is_trip_member(expenses.trip_id))
  );

-- 6. Packing Items Table
create table if not exists public.packing_items (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade not null,
  name text not null,
  category text default 'other' not null,
  assigned_to uuid references auth.users(id) on delete set null,
  is_packed boolean default false not null,
  created_at timestamptz default now() not null
);

create index if not exists idx_packing_trip on public.packing_items(trip_id);

alter table public.packing_items enable row level security;

create policy "Members can view packing items" on public.packing_items
  for select to authenticated using (public.is_trip_member(trip_id));

create policy "Members can insert packing items" on public.packing_items
  for insert to authenticated with check (public.is_trip_member(trip_id));

create policy "Members can update packing items" on public.packing_items
  for update to authenticated using (public.is_trip_member(trip_id));

create policy "Members can delete packing items" on public.packing_items
  for delete to authenticated using (public.is_trip_member(trip_id));

-- 7. Notes Table
create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade not null,
  title text not null,
  content text not null,
  is_pinned boolean default false not null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz default now() not null
);

create index if not exists idx_notes_trip on public.notes(trip_id);

alter table public.notes enable row level security;

create policy "Members can view notes" on public.notes
  for select to authenticated using (public.is_trip_member(trip_id));

create policy "Members can insert notes" on public.notes
  for insert to authenticated with check (public.is_trip_member(trip_id));

create policy "Members can update notes" on public.notes
  for update to authenticated using (public.is_trip_member(trip_id));

create policy "Members can delete notes" on public.notes
  for delete to authenticated using (public.is_trip_member(trip_id));

-- 8. Polls, Poll Options & Votes Tables
create table if not exists public.polls (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade not null,
  question text not null,
  is_multiple_choice boolean default false not null,
  is_active boolean default true not null,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz default now() not null
);

create table if not exists public.poll_options (
  id uuid primary key default gen_random_uuid(),
  poll_id uuid references public.polls(id) on delete cascade not null,
  text text not null,
  sort_order int default 0 not null
);

create table if not exists public.poll_votes (
  id uuid primary key default gen_random_uuid(),
  option_id uuid references public.poll_options(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  created_at timestamptz default now() not null,
  unique (option_id, user_id)
);

create index if not exists idx_polls_trip on public.polls(trip_id);
create index if not exists idx_poll_options_poll on public.poll_options(poll_id);
create index if not exists idx_poll_votes_option on public.poll_votes(option_id);

alter table public.polls enable row level security;
alter table public.poll_options enable row level security;
alter table public.poll_votes enable row level security;

create policy "Members can view polls" on public.polls
  for select to authenticated using (public.is_trip_member(trip_id));

create policy "Members can insert polls" on public.polls
  for insert to authenticated with check (public.is_trip_member(trip_id));

create policy "Members can view poll options" on public.poll_options
  for select to authenticated using (
    exists (select 1 from public.polls where polls.id = poll_options.poll_id and public.is_trip_member(polls.trip_id))
  );

create policy "Members can insert poll options" on public.poll_options
  for insert to authenticated with check (
    exists (select 1 from public.polls where polls.id = poll_options.poll_id and public.is_trip_member(polls.trip_id))
  );

create policy "Members can view poll votes" on public.poll_votes
  for select to authenticated using (
    exists (select 1 from public.poll_options join public.polls on polls.id = poll_options.poll_id where poll_options.id = poll_votes.option_id and public.is_trip_member(polls.trip_id))
  );

create policy "Members can vote" on public.poll_votes
  for insert to authenticated with check (
    user_id = auth.uid() and exists (
      select 1 from public.poll_options join public.polls on polls.id = poll_options.poll_id
      where poll_options.id = poll_votes.option_id and public.is_trip_member(polls.trip_id)
    )
  );

create policy "Users can remove their vote" on public.poll_votes
  for delete to authenticated using (user_id = auth.uid());

-- 9. Chat Messages Table
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid references public.trips(id) on delete cascade not null,
  sender_id text not null,
  text text not null,
  timestamp timestamptz default now() not null
);

create index if not exists idx_messages_trip_timestamp on public.messages(trip_id, timestamp);

alter table public.messages enable row level security;

create policy "Members can view messages" on public.messages
  for select to authenticated using (public.is_trip_member(trip_id));

create policy "Members can post messages" on public.messages
  for insert to authenticated with check (public.is_trip_member(trip_id));

-- 10. Enable Supabase Realtime for Collaborative Tables
alter publication supabase_realtime add table public.itinerary_items;
alter publication supabase_realtime add table public.expenses;
alter publication supabase_realtime add table public.expense_splits;
alter publication supabase_realtime add table public.packing_items;
alter publication supabase_realtime add table public.notes;
alter publication supabase_realtime add table public.polls;
alter publication supabase_realtime add table public.poll_options;
alter publication supabase_realtime add table public.poll_votes;
alter publication supabase_realtime add table public.messages;
