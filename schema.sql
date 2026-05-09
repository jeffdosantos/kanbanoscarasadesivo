
create extension if not exists "pgcrypto";

create table if not exists public.team_members (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  email text not null unique,
  cor text default '#2563eb',
  funcao text default 'Designer',
  ativo boolean default true,
  created_at timestamptz default now()
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  cliente text not null,
  titulo text not null,
  tipo_demanda text,
  descricao text,
  responsavel_id uuid references public.team_members(id) on delete set null,
  revisor_id uuid references public.team_members(id) on delete set null,
  prioridade text default 'media' check (prioridade in ('urgente','alta','media','baixa')),
  status text default 'em_andamento' check (status in ('em_andamento','revisao_interna','aguardando_cliente','bloqueado','aprovado','entregue')),
  etapa text default 'entrada',
  prazo date,
  data_entrada date default current_date,
  proxima_acao text,
  canal_solicitacao text,
  link_briefing text,
  link_arquivos text,
  link_figma_drive text,
  bloqueado boolean default false,
  motivo_bloqueio text,
  observacoes text,
  checklist jsonb default '[]'::jsonb,
  updated_by text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists set_tasks_updated_at on public.tasks;
create trigger set_tasks_updated_at before update on public.tasks
for each row execute function public.set_updated_at();

alter table public.team_members enable row level security;
alter table public.tasks enable row level security;

drop policy if exists "team members can read members" on public.team_members;
create policy "team members can read members" on public.team_members
for select using (
  exists(select 1 from public.team_members tm where tm.email = auth.email() and tm.ativo = true)
);

drop policy if exists "team members can read tasks" on public.tasks;
create policy "team members can read tasks" on public.tasks
for select using (
  exists(select 1 from public.team_members tm where tm.email = auth.email() and tm.ativo = true)
);

drop policy if exists "team members can insert tasks" on public.tasks;
create policy "team members can insert tasks" on public.tasks
for insert with check (
  exists(select 1 from public.team_members tm where tm.email = auth.email() and tm.ativo = true)
);

drop policy if exists "team members can update tasks" on public.tasks;
create policy "team members can update tasks" on public.tasks
for update using (
  exists(select 1 from public.team_members tm where tm.email = auth.email() and tm.ativo = true)
) with check (
  exists(select 1 from public.team_members tm where tm.email = auth.email() and tm.ativo = true)
);

drop policy if exists "team members can delete tasks" on public.tasks;
create policy "team members can delete tasks" on public.tasks
for delete using (
  exists(select 1 from public.team_members tm where tm.email = auth.email() and tm.ativo = true)
);

insert into public.team_members (nome,email,cor,funcao,ativo) values
('Pessoa 1','pessoa1@studio.com','#2563eb','Designer Sênior',true),
('Pessoa 2','pessoa2@studio.com','#16a34a','Designer',true),
('Pessoa 3','pessoa3@studio.com','#7c3aed','Designer Junior',true),
('Pessoa 4','pessoa4@studio.com','#ea580c','Motion Designer',true),
('Pessoa 5','pessoa5@studio.com','#db2777','UX/UI Designer',true)
on conflict (email) do nothing;

insert into public.tasks (cliente,titulo,tipo_demanda,responsavel_id,prioridade,prazo,data_entrada,etapa,status,proxima_acao,bloqueado,motivo_bloqueio,checklist)
select 'Cliente A','Carrossel institucional','Carrossel',tm.id,'alta',current_date + interval '1 day',current_date,'criacao','em_andamento','Finalizar primeira versão',false,null,'[{"text":"Briefing recebido","done":true},{"text":"Primeira versão criada","done":false}]'::jsonb from public.team_members tm where tm.email='pessoa1@studio.com'
union all
select 'Cliente B','Ajustes identidade visual','Identidade visual',tm.id,'media',current_date + interval '7 days',current_date,'revisao','revisao_interna','Conferir aplicação da marca',false,null,'[]'::jsonb from public.team_members tm where tm.email='pessoa2@studio.com'
union all
select 'Cliente C','Landing page promocional','Landing page',tm.id,'urgente',current_date + interval '1 day',current_date,'briefing','aguardando_cliente','Aguardar textos do cliente',true,'Cliente ainda não enviou textos finais','[]'::jsonb from public.team_members tm where tm.email='pessoa3@studio.com'
union all
select 'Cliente D','Campanha de lançamento','Campanha',tm.id,'alta',current_date + interval '5 days',current_date,'planejamento','em_andamento','Definir peças da campanha',false,null,'[]'::jsonb from public.team_members tm where tm.email='pessoa4@studio.com'
union all
select 'Cliente E','Apresentação comercial','Apresentação',tm.id,'media',current_date + interval '2 days',current_date,'enviado_cliente','aguardando_cliente','Cobrar retorno do cliente',false,null,'[]'::jsonb from public.team_members tm where tm.email='pessoa5@studio.com'
on conflict do nothing;

alter publication supabase_realtime add table public.tasks;
