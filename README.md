# Kanban Estúdio v3 — baseado no Figma

Versão 3 do sistema de controle de clientes e fluxo de produção para estúdio de criação.

## Arquitetura

- HTML/CSS/JS puro
- Supabase para login, banco de dados e realtime
- GitHub Pages para publicação gratuita
- Sem React, sem Vercel, sem build

## Como instalar

1. Crie um projeto no Supabase.
2. Abra `schema.sql`, troque os e-mails `pessoa1@studio.com` etc. pelos e-mails reais da equipe.
3. Rode o conteúdo do `schema.sql` no SQL Editor do Supabase.
4. Em `config.js`, coloque:

```js
export const SUPABASE_URL = "https://seu-projeto.supabase.co";
export const SUPABASE_ANON_KEY = "sua-chave-publica";
```

Use apenas a `anon public key` ou `publishable key`. Nunca use `service_role`.

5. Envie os arquivos para o GitHub.
6. Ative o GitHub Pages em Settings > Pages > Deploy from branch > main > /(root).

## Arquivos

- `index.html` — estrutura do sistema
- `style.css` — visual baseado no Figma
- `app.js` — lógica, Supabase, abas, Kanban e CRUD
- `config.js` — credenciais públicas do Supabase
- `schema.sql` — tabelas e políticas
- `.nojekyll` — evita problemas no GitHub Pages

## Se aparecer erro de API

Confira se `SUPABASE_URL` está no formato:

```text
https://xxxxxxxxxxxx.supabase.co
```

E se a chave é a anon/public ou publishable do mesmo projeto.
