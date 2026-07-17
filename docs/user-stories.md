# User Stories — API de Sensores Agrícolas

Histórias de usuário que definem o escopo funcional da **API**, organizadas por épico. O domínio é inspirado em plataformas de agtech, reduzido a um escopo coerente e demonstrável para fins de estudo de Ruby on Rails.

## Personas

- **Produtor/Gestor** — dono da conta; cadastra fazendas, talhões e sensores e consome as leituras e resumos **via API**. Persona principal.
- **Dispositivo/Simulador** — origem das leituras; envia valores periodicamente para os sensores.

## Convenções das histórias

- Formato: **Como** \<persona>, **quero** \<ação>, **para** \<benefício>.
- Cada história tem **critérios de aceite** verificáveis, que servem de base para os testes RSpec.
- Identificadores de código em inglês; texto de produto em português.

---

## Épico 1 — Autenticação e Conta

### US-1.1 — Cadastro
**Como** produtor, **quero** criar uma conta com nome, e-mail e senha, **para** acessar a API.
- **Aceite:**
  - `POST /api/v1/signup` com dados válidos cria o usuário e retorna um JWT.
  - E-mail é único e validado; senha tem comprimento mínimo.
  - Senha nunca é armazenada em texto puro (`has_secure_password`).
  - Payload de erro claro (422) quando dados são inválidos.

### US-1.2 — Login
**Como** produtor, **quero** autenticar com e-mail e senha, **para** receber um token de acesso.
- **Aceite:**
  - `POST /api/v1/login` com credenciais válidas retorna `{ token }`.
  - Credenciais inválidas retornam 401 sem revelar qual campo falhou.

### US-1.3 — Acesso autenticado
**Como** produtor, **quero** que os endpoints de negócio exijam um token válido, **para** que meus dados fiquem protegidos.
- **Aceite:**
  - Requisições sem header `Authorization: Bearer <token>` válido retornam 401.
  - Um `before_action` decodifica o token e define `current_user`.
  - Token inválido ou expirado é rejeitado com mensagem clara.

---

## Épico 2 — Fazendas (Farms)

### US-2.1 — Cadastrar fazenda
**Como** produtor, **quero** cadastrar uma fazenda com nome e localização, **para** organizar meus talhões.
- **Aceite:** `POST /api/v1/farms` cria a fazenda vinculada ao `current_user`; nome obrigatório.

### US-2.2 — Listar minhas fazendas
**Como** produtor, **quero** ver apenas as minhas fazendas, **para** navegar entre elas.
- **Aceite:** `GET /api/v1/farms` retorna somente fazendas do usuário autenticado; nunca de outros usuários.

### US-2.3 — Editar/remover fazenda
**Como** produtor, **quero** atualizar ou remover uma fazenda, **para** manter os dados corretos.
- **Aceite:** update/destroy só permitidos ao dono; remover a fazenda remove talhões/sensores/leituras em cascata.

---

## Épico 3 — Talhões (Fields)

### US-3.1 — Cadastrar talhão
**Como** produtor, **quero** cadastrar um talhão em uma fazenda, informando a cultura plantada, **para** agrupar sensores por área.
- **Aceite:** talhão pertence a uma fazenda do usuário; cultura e nome registrados.

### US-3.2 — Listar talhões de uma fazenda
**Como** produtor, **quero** listar os talhões de uma fazenda, **para** escolher onde instalar/consultar sensores.
- **Aceite:** listagem escopada por fazenda e por usuário.

> **Nota (Fase 4):** talhões expõem CRUD completo (show/update/destroy além de index/create), sempre escopado ao dono. Coleção e criação usam shallow nesting sob `/farms/:farm_id/fields`; as demais ações usam `/fields/:id`. Recurso de outro usuário responde 404.

---

## Épico 4 — Sensores (Sensors)

### US-4.1 — Cadastrar sensor
**Como** produtor, **quero** cadastrar um sensor em um talhão informando o tipo (umidade, temperatura, pH), **para** começar a coletar leituras.
- **Aceite:** `sensor_type` restrito ao enum (`humidity`, `temperature`, `ph`); sensor pertence a um talhão do usuário.

### US-4.2 — Listar sensores
**Como** produtor, **quero** listar sensores (por talhão ou todos), **para** ter visão do que está instalado.
- **Aceite:** listagem escopada por usuário; filtro opcional por talhão e por tipo.

> **Nota (Fase 4):** sensores expõem CRUD completo, escopado ao dono. Coleção e criação usam shallow nesting sob `/fields/:field_id/sensors`; as demais ações usam `/sensors/:id`. `sensor_type` fora do enum retorna 422 (não 500). A listagem flat `GET /api/v1/sensors` retorna todos os sensores do usuário, com filtros opcionais por talhão (`?field_id=`, talhão alheio → 404) e por tipo (`?sensor_type=`, valor fora do enum → 422).

---

## Épico 5 — Leituras (Readings)

### US-5.1 — Registrar leitura
**Como** dispositivo/simulador, **quero** enviar uma leitura (valor + data/hora) para um sensor, **para** alimentar o histórico.
- **Aceite:**
  - `POST /api/v1/sensors/:id/readings` cria a leitura.
  - `value` é decimal; `recorded_at` aceita timestamp; default = agora se ausente.
  - O model valida apenas presença de `value`/`recorded_at`. Valor fora da faixa realista **não** é rejeitado na persistência — faixa é tratada como alerta (Épico 6), não como validação.

### US-5.2 — Histórico de leituras
**Como** produtor, **quero** consultar o histórico de leituras de um sensor por período, **para** analisar tendências.
- **Aceite:**
  - `GET /api/v1/sensors/:id/readings` retorna leituras ordenadas por `recorded_at`.
  - Suporta filtro por intervalo de datas e paginação.

> **Nota (Fase 5):** rota real `GET /api/v1/sensors/:sensor_id/readings`, escopada ao dono (sensor alheio → 404). Ordem cronológica (mais antigas primeiro). Filtro por `?from=&to=` (ISO 8601) e paginação `?page=&per_page=` (padrão 50, teto 100), sem gem externa. `POST` usa `Time.current` quando `recorded_at` é omitido; valor fora da faixa é aceito (vira alerta, não erro).

---

## Épico 6 — Médias e Alertas

### US-6.1 — Resumo do sensor (médias por período)
**Como** produtor, **quero** ver médias, mínimos e máximos de um sensor por período, **para** entender o comportamento sem ler leitura a leitura.
- **Aceite:**
  - `GET /api/v1/sensors/:id/summary?period=7d` retorna média/mín/máx e contagem.
  - `period` aceita `24h`, `7d`, `30d` (padrão `7d`).
  - Cálculo isolado em um Service Object (testável independentemente).

### US-6.2 — Alertas por faixa ideal
**Como** produtor, **quero** ser avisado quando a média/última leitura sai da faixa ideal do tipo de sensor, **para** agir rápido.
- **Aceite:**
  - O `summary` inclui um status de alerta (`ok`, `low`, `high`) por faixa configurável por tipo.
  - Faixas padrão: umidade 20–80%, temperatura 10–40 °C, pH 4–8.
  - Regra de alerta isolada em Service Object.

> **Nota (Fase 5):** dois service objects — `ReadingsSummary` (agrega `count`/`average`/`min`/`max` via SQL no período) e `AlertEvaluator` (traduz um valor em `ok`/`low`/`high` pela faixa do tipo). `GET /api/v1/sensors/:id/summary?period=24h|7d|30d` (padrão `7d`; valor desconhecido cai no padrão). O `alert` é calculado sobre a **média** do período; sem leituras, `average`/`alert` vêm `null`.

---

## Épico 7 — Simulação de Dados

### US-7.1 — Seeds
**Como** desenvolvedor, **quero** popular o banco com dados plausíveis, **para** exercitar a API sem hardware.
- **Aceite:** `db/seeds.rb` cria usuário demo, fazenda, talhões, sensores e leituras dentro das faixas realistas.

> **Nota (Fase 6):** conta demo `demo@fazenda.com` / `password123` com 2 fazendas, 4 talhões, 12 sensores e ~1.440 leituras (30 dias, uma a cada 6h). Idempotente (recria só a conta demo). As faixas de geração vêm de `AlertEvaluator::IDEAL_RANGES` (fonte única); dois sensores são enviesados para fora da faixa para demonstrar alertas `low`/`high` no `summary`. Leituras gravadas via `insert_all`.

### US-7.2 — Simulador ao vivo (opcional)
**Como** desenvolvedor, **quero** um script que faça POST periódico de leituras, **para** simular dispositivos enviando dados em tempo real.
- **Aceite:** script parametrizável (intervalo, sensores) gerando valores dentro das faixas de cada tipo.

---

## Requisitos não-funcionais

- **Segurança:** todo endpoint de negócio exige JWT; dados sempre escopados ao `current_user`.
- **Qualidade:** cada história entregue com teste RSpec; RuboCop sem offenses.
- **API:** RESTful, versionada sob `/api/v1/`, respostas via `jsonapi-serializer`, erros com status HTTP e corpo consistentes.

## Definition of Done

Uma história está "pronta" quando: endpoint implementado conforme aceite; testes passando; linter limpo; documentação (README/docs) atualizada se o contrato mudou; sem segredos commitados.

---

## Futuro / Backlog (fora do escopo atual)

Ideias registradas para evolução futura do produto. **Não fazem parte do MVP** e não têm implementação prevista nesta fase — ficam documentadas para não se perderem.

### BKLG-1 — Geolocalização e mapas
**Como** produtor, **quero** visualizar fazendas, talhões e sensores em um mapa, **para** enxergar espacialmente a operação (agricultura de precisão).

- **Contexto de modelagem:** cada entidade tem uma geometria distinta — o talhão (`Field`) é uma *área* (polígono), o sensor (`Sensor`) é um *ponto* (lat/lng), e a fazenda (`Farm`) pode ser ponto (sede) ou polígono (perímetro). Hoje `Farm.location` é apenas texto livre, sem valor geográfico.
- **Abordagens possíveis (da mais simples à mais robusta):**
  - Colunas `latitude`/`longitude` (decimal) para "pins" simples no mapa.
  - GeoJSON em coluna `jsonb` para guardar polígonos sem consultas espaciais.
  - **PostGIS** (extensão do PostgreSQL + gem `activerecord-postgis-adapter`) para geometrias e consultas espaciais reais ("sensores dentro deste talhão", distâncias, áreas).
- **Nota técnica:** é uma evolução **puramente aditiva** (novas colunas/tabelas via migration), então adiar não gera retrabalho sobre o schema atual.
