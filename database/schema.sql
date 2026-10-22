-- MarketBrief tables (same six tables as the live Supabase database).
-- The important rules are enforced here, not in the workflows,
-- so a workflow bug cannot break them.

-- Who receives the morning report
create table if not exists mr_subscribers (
  chat_id     bigint primary key,
  first_name  text,
  active      boolean not null default true,
  joined_at   timestamptz not null default now()
);

-- Each person's stocks. Same stock twice is refused by the database.
-- Deleting a person deletes their stocks (cascade).
create table if not exists mr_watchlist (
  chat_id  bigint not null references mr_subscribers(chat_id) on delete cascade,
  symbol   text   not null,
  name     text,
  unique (chat_id, symbol)
);

-- Every report sent: never-send-twice check, daily /report limit, /status
create table if not exists mr_report_log (
  id             bigserial primary key,
  chat_id        bigint not null,
  report_date    date   not null,
  trigger        text   not null,          -- 'scheduled' or 'on_demand'
  status         text   not null,          -- 'sent', 'failed', ...
  sections_down  text,
  summary_by     text,                     -- 'ai' or 'template'
  sent_at        timestamptz
);
-- At most one successful scheduled report per person per day, even if the job runs twice
create unique index if not exists mr_report_log_one_scheduled_per_day
  on mr_report_log (chat_id, report_date)
  where trigger = 'scheduled' and status = 'sent';

-- One price row per symbol per day (upserted, so reruns never duplicate)
create table if not exists mr_market_history (
  report_date  date not null,
  symbol       text not null,
  price        double precision,
  change_pct   double precision,
  source       text,
  updated_at   timestamptz not null default now(),
  primary key (report_date, symbol)
);

-- Health of each data source: circuit breaker, /status and the /simulate demo switch
create table if not exists mr_source_health (
  source                text primary key,
  consecutive_failures  int not null default 0,
  last_status           text,
  last_checked          timestamptz,
  simulate_down         boolean not null default false
);

-- Written by the Error Workflow
create table if not exists mr_error_log (
  id          bigserial primary key,
  workflow    text,
  node        text,
  message     text,
  created_at  timestamptz not null default now()
);

-- Row-level security on (on Supabase this blocks the public web API; only n8n's login reaches the tables)
alter table mr_subscribers    enable row level security;
alter table mr_watchlist      enable row level security;
alter table mr_report_log     enable row level security;
alter table mr_market_history enable row level security;
alter table mr_source_health  enable row level security;
alter table mr_error_log      enable row level security;
