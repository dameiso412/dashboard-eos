# Dashboard EOS — API Reference

## Base URL

```
https://{PROJECT_ID}.supabase.co/rest/v1
```

## Authentication

All requests require the `apikey` header with your Supabase **anon public key**.

```
Headers:
  apikey: {SUPABASE_ANON_KEY}
  Authorization: Bearer {SUPABASE_ANON_KEY}
  Content-Type: application/json
  Prefer: return=representation    (for POST/PATCH to return the created/updated row)
```

---

## Tables & Endpoints

### 1. Dashboard Config

Current quarter and week selection.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/dashboard_config?id=eq.main` | Get current config |
| `PATCH` | `/dashboard_config?id=eq.main` | Update current quarter/week |

**Schema:**
```json
{
  "id": "main",
  "current_year": 2026,
  "current_quarter": 1,
  "current_week": 12,
  "updated_at": "2026-03-24T15:00:00Z"
}
```

**Example — Change to Q2:**
```bash
curl -X PATCH '{BASE_URL}/dashboard_config?id=eq.main' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -d '{"current_quarter": 2}'
```

---

### 2. Team Members

Global team roster.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/team_members` | List all members |
| `GET` | `/team_members?id=eq.tomas` | Get one member |
| `POST` | `/team_members` | Add a member |
| `PATCH` | `/team_members?id=eq.tomas` | Update a member |
| `DELETE` | `/team_members?id=eq.tomas` | Remove a member |

**Schema:**
```json
{
  "id": "tomas",
  "name": "Tomás",
  "role": "Director / Ventas",
  "avatar": "T",
  "color": "#2979ff",
  "created_at": "2026-01-01T00:00:00Z"
}
```

**Example — Add a new member:**
```bash
curl -X POST '{BASE_URL}/team_members' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -H 'Prefer: return=representation' \
  -d '{
    "id": "maria",
    "name": "María",
    "role": "Diseño / UX",
    "avatar": "M",
    "color": "#e91e63"
  }'
```

---

### 3. Pulso (Revenue & Utility)

Financial metrics per quarter.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/pulso` | List all quarters |
| `GET` | `/pulso?quarter_key=eq.2026-Q1` | Get one quarter |
| `POST` | `/pulso` | Create quarter entry |
| `PATCH` | `/pulso?quarter_key=eq.2026-Q1` | Update values |

**Schema:**
```json
{
  "quarter_key": "2026-Q1",
  "revenue_current": 82400,
  "revenue_goal": 100000,
  "utility_current": 48200,
  "utility_goal": 60000,
  "updated_at": "2026-03-24T15:00:00Z"
}
```

**Example — Update monthly revenue:**
```bash
curl -X PATCH '{BASE_URL}/pulso?quarter_key=eq.2026-Q1' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -d '{"revenue_current": 91500}'
```

---

### 4. Rocks

Quarterly strategic projects.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/rocks?quarter_key=eq.2026-Q1` | List rocks for a quarter |
| `GET` | `/rocks?id=eq.r1` | Get one rock |
| `GET` | `/rocks_full?quarter_key=eq.2026-Q1` | Rocks with owner details (VIEW) |
| `POST` | `/rocks` | Create a rock |
| `PATCH` | `/rocks?id=eq.r1` | Update a rock |
| `DELETE` | `/rocks?id=eq.r1` | Delete a rock |

**Schema:**
```json
{
  "id": "r1",
  "quarter_key": "2026-Q1",
  "name": "Lanzar 3 nuevos verticales de servicio",
  "owner_id": "tomas",
  "status": "on-track",
  "progress": 70,
  "deadline": "2026-03-31",
  "milestones": [
    {"text": "Investigación de mercado", "done": true},
    {"text": "MVP listo", "done": true},
    {"text": "Lanzamiento público", "done": false}
  ],
  "created_at": "2026-01-01T00:00:00Z",
  "updated_at": "2026-03-24T15:00:00Z"
}
```

**Example — Update rock progress and status:**
```bash
curl -X PATCH '{BASE_URL}/rocks?id=eq.r3' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -d '{"progress": 60, "status": "on-track"}'
```

**Example — Create a new rock:**
```bash
curl -X POST '{BASE_URL}/rocks' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -H 'Prefer: return=representation' \
  -d '{
    "id": "r4",
    "quarter_key": "2026-Q1",
    "name": "Implementar sistema de onboarding automatizado",
    "owner_id": "christian",
    "status": "on-track",
    "progress": 20,
    "deadline": "2026-03-31",
    "milestones": [
      {"text": "Diseñar flujo", "done": true},
      {"text": "Desarrollar emails", "done": false},
      {"text": "Testing y lanzamiento", "done": false}
    ]
  }'
```

**Filtros utiles:**
```
GET /rocks?owner_id=eq.tomas                     → Rocks de Tomás
GET /rocks?status=eq.off-track                    → Rocks en riesgo
GET /rocks?progress=lt.50                         → Rocks con menos del 50%
GET /rocks?quarter_key=eq.2026-Q1&order=progress  → Ordenados por progreso
```

---

### 5. Scorecard Metrics

Metric definitions per quarter.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/scorecard_metrics?quarter_key=eq.2026-Q1&order=sort_order` | List metrics |
| `GET` | `/scorecard_metrics?id=eq.m1` | Get one metric |
| `POST` | `/scorecard_metrics` | Create a metric |
| `PATCH` | `/scorecard_metrics?id=eq.m1` | Update a metric |
| `DELETE` | `/scorecard_metrics?id=eq.m1` | Delete metric (cascades results) |

**Schema:**
```json
{
  "id": "m1",
  "quarter_key": "2026-Q1",
  "metric": "Facturación semanal",
  "owner_id": "tomas",
  "goal": "$25,000",
  "direction": "gte",
  "sort_order": 1,
  "created_at": "2026-01-01T00:00:00Z"
}
```

---

### 6. Scorecard Results

Weekly results per metric.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/scorecard_results?metric_id=eq.m1` | Results for one metric |
| `GET` | `/scorecard_results?week=eq.12` | All results for week 12 |
| `GET` | `/scorecard_full?quarter_key=eq.2026-Q1` | Full scorecard (VIEW) |
| `POST` | `/scorecard_results` | Add a result |
| `PATCH` | `/scorecard_results?metric_id=eq.m1&week=eq.12` | Update a result |
| `DELETE` | `/scorecard_results?metric_id=eq.m1&week=eq.12` | Delete a result |

**Schema:**
```json
{
  "id": "sr1",
  "metric_id": "m1",
  "week": 12,
  "result": "$27,300",
  "good": true,
  "created_at": "2026-03-24T15:00:00Z"
}
```

**Example — Submit week 13 results:**
```bash
curl -X POST '{BASE_URL}/scorecard_results' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -H 'Prefer: return=representation' \
  -d '{
    "id": "sr14",
    "metric_id": "m1",
    "week": 13,
    "result": "$28,100",
    "good": true
  }'
```

**Scorecard Full View — Get everything in one call:**
```
GET /scorecard_full?quarter_key=eq.2026-Q1&order=sort_order,week
```
Returns:
```json
[
  {
    "metric_id": "m1",
    "quarter_key": "2026-Q1",
    "metric": "Facturación semanal",
    "owner_id": "tomas",
    "owner_name": "Tomás",
    "goal": "$25,000",
    "direction": "gte",
    "sort_order": 1,
    "week": 12,
    "result": "$27,300",
    "good": true
  }
]
```

---

### 7. Leaderboard Entries

Individual performance display per quarter.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/leaderboard_entries?quarter_key=eq.2026-Q1` | All entries for quarter |
| `GET` | `/leaderboard_full?quarter_key=eq.2026-Q1` | With member details (VIEW) |
| `POST` | `/leaderboard_entries` | Create entry |
| `PATCH` | `/leaderboard_entries?member_id=eq.tomas&quarter_key=eq.2026-Q1` | Update entry |

**Schema:**
```json
{
  "id": "lb1",
  "member_id": "tomas",
  "quarter_key": "2026-Q1",
  "metric_label": "Tasa de Cumplimiento de Rocks",
  "metric_value": "85%",
  "progress": 85,
  "goal": "80%",
  "updated_at": "2026-03-24T15:00:00Z"
}
```

---

### 8. Fame Wall

Client success showcase.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/fame_wall?quarter_key=eq.2026-Q1` | Clients for quarter |
| `GET` | `/fame_wall?roas=gte.5` | High-ROAS clients |
| `POST` | `/fame_wall` | Add client |
| `PATCH` | `/fame_wall?id=eq.f1` | Update client |
| `DELETE` | `/fame_wall?id=eq.f1` | Remove client |

**Schema:**
```json
{
  "id": "f1",
  "quarter_key": "2026-Q1",
  "name": "Grupo Madera MX",
  "initials": "GM",
  "retention_months": 14,
  "roas": 5.2,
  "added_date": "2025-07-01",
  "created_at": "2026-01-01T00:00:00Z"
}
```

**Filtros utiles:**
```
GET /fame_wall?retention_months=gte.6&roas=gte.4      → Solo los que cumplen criterios
GET /fame_wall?order=roas.desc                          → Ordenados por ROAS
GET /fame_wall?added_date=gte.2026-03-01               → Agregados este mes
```

---

### 9. Comments (Sistema de Comentarios para IA)

Comments can be attached to any section or specific item. Designed for AI agents and team members.

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/comments?quarter_key=eq.2026-Q1&order=created_at.desc` | All comments |
| `GET` | `/comments?section=eq.rocks&reference_id=eq.r1` | Comments on a rock |
| `GET` | `/comments?section=eq.scorecard&resolved=eq.false` | Unresolved scorecard comments |
| `GET` | `/comments?author_type=eq.ai` | All AI comments |
| `POST` | `/comments` | Add a comment |
| `PATCH` | `/comments?id=eq.{id}` | Update/resolve a comment |
| `DELETE` | `/comments?id=eq.{id}` | Delete a comment |

**Schema:**
```json
{
  "id": "auto-generated-uuid",
  "section": "rocks",
  "reference_id": "r3",
  "quarter_key": "2026-Q1",
  "author": "Claude AI",
  "author_type": "ai",
  "content": "El rock 'Reducir churn rate al 3%' está off-track con solo 45% de progreso. Sugiero priorizar las alertas tempranas esta semana.",
  "resolved": false,
  "created_at": "2026-03-24T15:00:00Z",
  "updated_at": "2026-03-24T15:00:00Z"
}
```

**`section` values:** `pulso`, `rocks`, `scorecard`, `leaderboard`, `fame_wall`, `general`

**`author_type` values:** `human`, `ai`

**Example — AI agent posts analysis:**
```bash
curl -X POST '{BASE_URL}/comments' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -H 'Prefer: return=representation' \
  -d '{
    "section": "scorecard",
    "reference_id": "m6",
    "quarter_key": "2026-Q1",
    "author": "Analytics AI",
    "author_type": "ai",
    "content": "Churn rate ha fallado 3 semanas consecutivas (S10-S12). Tendencia negativa. Recomiendo revisión urgente del programa de retención."
  }'
```

**Example — Mark comment as resolved:**
```bash
curl -X PATCH '{BASE_URL}/comments?id=eq.{COMMENT_ID}' \
  -H 'apikey: {KEY}' -H 'Authorization: Bearer {KEY}' \
  -H 'Content-Type: application/json' \
  -d '{"resolved": true}'
```

---

## Views (Read-Only Convenience Endpoints)

| View | Endpoint | Description |
|------|----------|-------------|
| `scorecard_full` | `GET /scorecard_full` | Metrics + results + owner names |
| `leaderboard_full` | `GET /leaderboard_full` | Entries + member details |
| `rocks_full` | `GET /rocks_full` | Rocks + owner details |

These views JOIN related tables so you get all the data in one call.

---

## Supabase Query Operators

Use these in query parameters:

| Operator | Meaning | Example |
|----------|---------|---------|
| `eq` | Equal | `?status=eq.on-track` |
| `neq` | Not equal | `?status=neq.off-track` |
| `gt` | Greater than | `?progress=gt.50` |
| `gte` | Greater or equal | `?roas=gte.4` |
| `lt` | Less than | `?progress=lt.30` |
| `lte` | Less or equal | `?week=lte.12` |
| `like` | Pattern match | `?name=like.*Dental*` |
| `ilike` | Case-insensitive like | `?metric=ilike.*factur*` |
| `in` | In list | `?owner_id=in.(tomas,nicolas)` |
| `is` | IS (null/true/false) | `?resolved=is.false` |
| `order` | Sort | `?order=created_at.desc` |
| `limit` | Limit rows | `?limit=5` |
| `offset` | Skip rows | `?offset=10` |
| `select` | Choose columns | `?select=name,progress,status` |

---

## Common AI Agent Workflows

### Read the entire dashboard state for a quarter:
```bash
# 1. Config
GET /dashboard_config?id=eq.main

# 2. Pulso
GET /pulso?quarter_key=eq.2026-Q1

# 3. Rocks with owner info
GET /rocks_full?quarter_key=eq.2026-Q1&order=created_at

# 4. Full scorecard
GET /scorecard_full?quarter_key=eq.2026-Q1&order=sort_order,week

# 5. Leaderboard with member info
GET /leaderboard_full?quarter_key=eq.2026-Q1

# 6. Fame wall
GET /fame_wall?quarter_key=eq.2026-Q1&order=roas.desc

# 7. Comments
GET /comments?quarter_key=eq.2026-Q1&resolved=eq.false&order=created_at.desc
```

### Weekly update workflow (AI agent):
```bash
# 1. Read unresolved comments
GET /comments?section=eq.scorecard&resolved=eq.false

# 2. Check which metrics missed this week
GET /scorecard_results?week=eq.12&good=eq.false

# 3. Post analysis
POST /comments
{
  "section": "general",
  "quarter_key": "2026-Q1",
  "author": "Weekly Analysis AI",
  "author_type": "ai",
  "content": "Resumen S12: 9/13 métricas cumplidas (69%). Churn y tickets de soporte siguen off-track. Rock de Roberto requiere atención."
}
```

### Create a new quarter:
```bash
# 1. Create pulso entry
POST /pulso
{"quarter_key": "2026-Q2", "revenue_goal": 120000, "utility_goal": 72000}

# 2. Create rocks
POST /rocks
{"id": "r-q2-1", "quarter_key": "2026-Q2", "name": "...", "owner_id": "tomas", ...}

# 3. Copy/create scorecard metrics
POST /scorecard_metrics
{"id": "m-q2-1", "quarter_key": "2026-Q2", "metric": "...", ...}

# 4. Create leaderboard entries
POST /leaderboard_entries
{"id": "lb-q2-1", "member_id": "tomas", "quarter_key": "2026-Q2", ...}

# 5. Update config
PATCH /dashboard_config?id=eq.main
{"current_quarter": 2}
```

---

## Rate Limits

Supabase free tier: 500 requests/minute. More than sufficient for a team dashboard.

## Data Format Notes

- Dates: ISO 8601 (`2026-03-24` for date, `2026-03-24T15:00:00Z` for timestamp)
- IDs: Free-form text strings. Use descriptive prefixes (`r1`, `m1`, `f1`, `lb1`, `sr1`)
- Milestones: JSONB array of `{"text": "...", "done": true/false}`
- Money values in results: Stored as text to preserve formatting (`$27,300`)
- ROAS: Numeric with decimals (`5.2`)
