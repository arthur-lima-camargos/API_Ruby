# Sensores Agrícolas — API REST em Ruby on Rails

API REST para coleta e monitoramento de dados de sensores agrícolas — umidade do solo, temperatura e pH. O domínio é inspirado em agtech: fazendas possuem talhões, que possuem sensores, que enviam leituras periódicas. A API armazena e consulta essas leituras, calcula médias por período e emite alertas simples quando os valores saem de faixas ideais. O acesso é autenticado por **token JWT**, e cada usuário só enxerga os próprios recursos.

> **Projeto de estudo pessoal.** O objetivo aqui não é um produto final, e sim **aprender Ruby on Rails na prática** construindo uma API REST do zero, seguindo as convenções da comunidade (Rails Way). O andamento do aprendizado é acompanhado na seção [Progresso](#progresso).

## Objetivos de aprendizado

- Entender o fluxo de uma **API Rails em modo `--api`** de ponta a ponta.
- Modelar um domínio com **associations, validações e migrations**.
- Implementar **autenticação stateless com JWT** (`has_secure_password` + `bcrypt`), sem depender de gems de autenticação prontas.
- Escrever endpoints **RESTful e versionados** (`/api/v1/`), com dados **escopados pelo usuário autenticado**.
- Extrair regra de negócio para **service objects** e formatar respostas com **serializers**.
- Cobrir o código com **testes (RSpec)** e manter o estilo com **RuboCop**.

## Stack

- **Ruby on Rails** (modo API)
- **PostgreSQL** (banco de dados)
- **JWT** para autenticação — gems `jwt` + `has_secure_password` (bcrypt)
- **jsonapi-serializer** (serialização das respostas JSON)
- **RSpec** + **FactoryBot** + **Faker** (testes)
- **RuboCop** (linter, seguindo o Ruby Style Guide)

## Modelo de domínio

```
User     → fazendas   (Farm)
Farm     → talhões    (Field)
Field    → sensores   (Sensor)
Sensor   → leituras   (Reading)
```

| Model    | Descrição                                                    |
|----------|--------------------------------------------------------------|
| User     | Dono dos recursos (nome, e-mail único, senha)                |
| Farm     | Fazenda (nome, localização)                                  |
| Field    | Talhão dentro de uma fazenda (cultura plantada)              |
| Sensor   | Sensor em um talhão (tipo: umidade, temperatura ou pH)       |
| Reading  | Leitura registrada por um sensor (valor, data/hora)          |

Faixas usadas na simulação de dados: umidade 20–80%, temperatura 10–40 °C, pH 4–8.

## Endpoints planejados

Versionados sob `/api/v1/`. Exceto `signup` e `login`, todas as rotas exigem o header `Authorization: Bearer <token>`.

Talhões e sensores usam **shallow nesting**: coleção e criação carregam o pai na URL; as demais ações usam o id próprio do recurso.

| Método            | Rota                                     | Descrição                        |
|-------------------|------------------------------------------|----------------------------------|
| POST              | `/api/v1/signup`                         | Cria usuário e retorna um JWT    |
| POST              | `/api/v1/login`                          | Autentica e retorna um JWT       |
| GET               | `/api/v1/farms`                          | Lista fazendas do usuário        |
| POST              | `/api/v1/farms`                          | Cria fazenda                     |
| GET/PATCH/DELETE  | `/api/v1/farms/:id`                      | Mostra, atualiza ou remove       |
| GET               | `/api/v1/farms/:farm_id/fields`          | Lista talhões da fazenda         |
| POST              | `/api/v1/farms/:farm_id/fields`          | Cria talhão na fazenda           |
| GET/PATCH/DELETE  | `/api/v1/fields/:id`                     | Mostra, atualiza ou remove       |
| GET               | `/api/v1/fields/:field_id/sensors`       | Lista sensores do talhão         |
| POST              | `/api/v1/fields/:field_id/sensors`       | Cria sensor no talhão            |
| GET/PATCH/DELETE  | `/api/v1/sensors/:id`                    | Mostra, atualiza ou remove       |
| POST              | `/api/v1/sensors/:sensor_id/readings`    | Registra uma leitura             |
| GET               | `/api/v1/sensors/:sensor_id/readings`    | Histórico de leituras do sensor  |
| GET               | `/api/v1/sensors/:id/summary?period=7d`  | Médias e alertas no período      |

O histórico (`GET .../readings`) aceita recorte por intervalo (`?from=&to=`, ISO 8601) e paginação (`?page=&per_page=`, padrão 50, teto 100), em ordem cronológica.

O parâmetro `period` do `/summary` aceita valores como `24h`, `7d` ou `30d` (padrão: `7d`). A resposta traz `count`, `average`, `min`, `max` e um `alert` (`ok`/`low`/`high`) calculado sobre a média conforme a faixa ideal do tipo de sensor (umidade 20–80, temperatura 10–40, pH 4–8).

## Progresso

Diário de bordo do aprendizado. Cada fase é marcada conforme avançamos.

### Fase 0 — Ambiente e fundação
- [x] Ambiente de desenvolvimento (Ruby, Rails, PostgreSQL) montado no WSL2 / Ubuntu
- [x] Objetivos e escopo documentados (este README)
- [x] Repositório git inicializado e publicado no GitHub

### Fase 1 — Scaffold da aplicação Rails
- [x] Gerar aplicação Rails em modo API com PostgreSQL
- [x] Configurar RSpec, FactoryBot e Faker
- [x] Configurar RuboCop
- [x] Criar e migrar o banco de dados

### Fase 2 — Modelagem do domínio
- [x] Models: User, Farm, Field, Sensor, Reading
- [x] Associations e validações
- [x] Enum de tipo de sensor (umidade, temperatura, pH)
- [x] Migrations

### Fase 3 — Autenticação JWT
- [x] User com `has_secure_password` (bcrypt)
- [x] `POST /signup` e `POST /login` retornando o token
- [x] `before_action` que decodifica o token e define `current_user` (`Api::V1::BaseController`)
- [ ] Escopo de dados a partir de `current_user` (aplicado nos endpoints da Fase 4)

### Fase 4 — Endpoints REST (CRUD)
- [x] Farms, Fields e Sensors escopados por usuário (CRUD completo)
- [x] Respostas formatadas com jsonapi-serializer

### Fase 5 — Leituras e agregações
- [x] Registrar e listar leituras (com filtro por intervalo e paginação)
- [x] Service object: médias por período (`ReadingsSummary`)
- [x] Service object: alertas por faixa ideal (`AlertEvaluator`)
- [x] Endpoint `summary`

### Fase 6 — Dados de simulação
- [x] Seeds com dados plausíveis (usuário demo, 2 fazendas, 4 talhões, 12 sensores, ~1.440 leituras)
- [ ] (Opcional) simulador de leituras ao vivo

### Fase 7 — Testes e qualidade
- [ ] Specs de model e de request
- [ ] RuboCop sem offenses

## Como rodar

Pré-requisitos: Ruby, Rails, Bundler e PostgreSQL instalados.

```bash
git clone <url-do-repo>
cd API_Ruby

bundle install
rails db:create db:migrate db:seed

rails server   # API em http://localhost:3000
```

O `db:seed` cria uma conta demo — **`demo@fazenda.com` / `password123`** — com fazendas, talhões, sensores e ~1.440 leituras dos últimos 30 dias. Dois sensores são propositalmente enviesados para fora da faixa, então o `summary` deles demonstra alertas `low`/`high`. O seed é idempotente (recria só a conta demo a cada execução).

## Testes

```bash
bundle exec rspec
```

## Qualidade de código

```bash
bundle exec rubocop
bundle exec rubocop -A   # autocorreção segura
```
