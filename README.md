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

| Método | Rota                                     | Descrição                       |
|--------|------------------------------------------|---------------------------------|
| POST   | `/api/v1/signup`                         | Cria usuário e retorna um JWT   |
| POST   | `/api/v1/login`                          | Autentica e retorna um JWT      |
| GET    | `/api/v1/farms`                          | Lista fazendas do usuário       |
| POST   | `/api/v1/farms`                          | Cria fazenda                    |
| GET    | `/api/v1/fields`                         | Lista talhões                   |
| GET    | `/api/v1/sensors`                        | Lista sensores                  |
| POST   | `/api/v1/sensors/:id/readings`           | Registra uma leitura            |
| GET    | `/api/v1/sensors/:id/readings`           | Histórico de leituras do sensor |
| GET    | `/api/v1/sensors/:id/summary?period=7d`  | Médias e alertas no período     |

O parâmetro `period` do `/summary` aceita valores como `24h`, `7d` ou `30d` (padrão: `7d`).

## Progresso

Diário de bordo do aprendizado. Cada fase é marcada conforme avançamos.

### Fase 0 — Ambiente e fundação
- [x] Ambiente de desenvolvimento (Ruby, Rails, PostgreSQL) montado no WSL2 / Ubuntu
- [x] Objetivos e escopo documentados (este README)
- [ ] Repositório git inicializado e publicado no GitHub

### Fase 1 — Scaffold da aplicação Rails
- [ ] Gerar aplicação Rails em modo API com PostgreSQL
- [ ] Configurar RSpec, FactoryBot e Faker
- [ ] Configurar RuboCop
- [ ] Criar e migrar o banco de dados

### Fase 2 — Modelagem do domínio
- [ ] Models: User, Farm, Field, Sensor, Reading
- [ ] Associations e validações
- [ ] Enum de tipo de sensor (umidade, temperatura, pH)
- [ ] Migrations

### Fase 3 — Autenticação JWT
- [ ] User com `has_secure_password` (bcrypt)
- [ ] `POST /signup` e `POST /login` retornando o token
- [ ] `before_action` que decodifica o token e define `current_user`
- [ ] Escopo de dados a partir de `current_user`

### Fase 4 — Endpoints REST (CRUD)
- [ ] Farms, Fields e Sensors escopados por usuário
- [ ] Respostas formatadas com jsonapi-serializer

### Fase 5 — Leituras e agregações
- [ ] Registrar e listar leituras
- [ ] Service object: médias por período
- [ ] Service object: alertas por faixa ideal
- [ ] Endpoint `summary`

### Fase 6 — Dados de simulação
- [ ] Seeds com dados plausíveis
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

## Testes

```bash
bundle exec rspec
```

## Qualidade de código

```bash
bundle exec rubocop
bundle exec rubocop -A   # autocorreção segura
```
