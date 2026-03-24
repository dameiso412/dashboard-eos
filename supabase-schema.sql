-- ============================================================
-- DASHBOARD EOS - Schema Completo para Supabase
--
-- INSTRUCCIONES:
-- 1. Ve a tu proyecto en supabase.com
-- 2. Click en "SQL Editor" en el menu izquierdo
-- 3. Click en "New query"
-- 4. Pega TODO este contenido
-- 5. Click en "Run" (o Cmd+Enter)
-- 6. Deberia decir "Success. No rows returned"
-- ============================================================

-- =====================
-- TABLA: dashboard_config
-- Configuracion global del dashboard (trimestre/semana actual)
-- =====================
CREATE TABLE IF NOT EXISTS dashboard_config (
    id TEXT PRIMARY KEY DEFAULT 'main',
    current_year INTEGER NOT NULL DEFAULT 2026,
    current_quarter INTEGER NOT NULL DEFAULT 1,
    current_week INTEGER,
    updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO dashboard_config (id, current_year, current_quarter)
VALUES ('main', 2026, 1)
ON CONFLICT (id) DO NOTHING;

-- =====================
-- TABLA: team_members
-- Miembros del equipo (global, no por trimestre)
-- =====================
CREATE TABLE IF NOT EXISTS team_members (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    role TEXT DEFAULT '',
    avatar TEXT DEFAULT '',
    color TEXT DEFAULT '#2979ff',
    created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO team_members (id, name, role, avatar, color) VALUES
    ('tomas', 'Tomás', 'Director / Ventas', 'T', '#2979ff'),
    ('nicolas', 'Nicolás', 'Account Management', 'N', '#7c4dff'),
    ('christian', 'Christian', 'Marketing / Ads', 'C', '#00c853'),
    ('roberto', 'Roberto', 'Operaciones / Entrega', 'R', '#ff3d57')
ON CONFLICT (id) DO NOTHING;

-- =====================
-- TABLA: pulso
-- Facturacion y utilidad por trimestre
-- =====================
CREATE TABLE IF NOT EXISTS pulso (
    quarter_key TEXT PRIMARY KEY,  -- "2026-Q1"
    revenue_current NUMERIC DEFAULT 0,
    revenue_goal NUMERIC DEFAULT 100000,
    utility_current NUMERIC DEFAULT 0,
    utility_goal NUMERIC DEFAULT 60000,
    updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO pulso (quarter_key, revenue_current, revenue_goal, utility_current, utility_goal)
VALUES ('2026-Q1', 82400, 100000, 48200, 60000)
ON CONFLICT (quarter_key) DO NOTHING;

-- =====================
-- TABLA: rocks
-- Proyectos clave por trimestre
-- =====================
CREATE TABLE IF NOT EXISTS rocks (
    id TEXT PRIMARY KEY,
    quarter_key TEXT NOT NULL,
    name TEXT NOT NULL,
    owner_id TEXT REFERENCES team_members(id),
    status TEXT DEFAULT 'on-track' CHECK (status IN ('on-track', 'off-track')),
    progress INTEGER DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    deadline DATE,
    milestones JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO rocks (id, quarter_key, name, owner_id, status, progress, deadline, milestones) VALUES
    ('r1', '2026-Q1', 'Lanzar 3 nuevos verticales de servicio', 'tomas', 'on-track', 70, '2026-03-31',
     '[{"text":"Investigación de mercado","done":true},{"text":"MVP listo","done":true},{"text":"Lanzamiento público","done":false}]'),
    ('r2', '2026-Q1', 'Alcanzar NRR del 110%', 'nicolas', 'on-track', 80, '2026-03-31',
     '[{"text":"Identificar cuentas clave","done":true},{"text":"Ejecutar plan de upsell","done":true},{"text":"Cerrar expansiones Q1","done":false}]'),
    ('r3', '2026-Q1', 'Reducir churn rate al 3%', 'roberto', 'off-track', 45, '2026-03-31',
     '[{"text":"Análisis de razones de churn","done":true},{"text":"Implementar alertas tempranas","done":false},{"text":"Programa de retención","done":false}]')
ON CONFLICT (id) DO NOTHING;

-- =====================
-- TABLA: scorecard_metrics
-- Definicion de metricas del scorecard por trimestre
-- =====================
CREATE TABLE IF NOT EXISTS scorecard_metrics (
    id TEXT PRIMARY KEY,
    quarter_key TEXT NOT NULL,
    metric TEXT NOT NULL,
    owner_id TEXT REFERENCES team_members(id),
    goal TEXT DEFAULT '',
    direction TEXT DEFAULT 'gte' CHECK (direction IN ('gte', 'lte')),
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO scorecard_metrics (id, quarter_key, metric, owner_id, goal, direction, sort_order) VALUES
    ('m1',  '2026-Q1', 'Facturación semanal',           'tomas',     '$25,000', 'gte', 1),
    ('m2',  '2026-Q1', 'Nuevos leads calificados',      'christian', '15',      'gte', 2),
    ('m3',  '2026-Q1', 'Tasa de conversión de leads',   'christian', '25%',     'gte', 3),
    ('m4',  '2026-Q1', 'ROAS promedio clientes',        'christian', '4.0x',    'gte', 4),
    ('m5',  '2026-Q1', 'NRR (Net Revenue Retention)',   'nicolas',   '105%',    'gte', 5),
    ('m6',  '2026-Q1', 'Churn rate mensual',            'roberto',   '3%',      'lte', 6),
    ('m7',  '2026-Q1', 'Tasa de entrega a tiempo',      'roberto',   '95%',     'gte', 7),
    ('m8',  '2026-Q1', 'Tickets de soporte resueltos',  'roberto',   '50',      'gte', 8),
    ('m9',  '2026-Q1', 'Reuniones de upsell realizadas','nicolas',   '8',       'gte', 9),
    ('m10', '2026-Q1', 'Propuestas enviadas',           'tomas',     '10',      'gte', 10),
    ('m11', '2026-Q1', 'Costo de adquisición (CAC)',    'christian', '$800',    'lte', 11),
    ('m12', '2026-Q1', 'Satisfacción del cliente (NPS)','roberto',   '70',      'gte', 12),
    ('m13', '2026-Q1', 'Horas facturables del equipo',  'tomas',     '160h',    'gte', 13)
ON CONFLICT (id) DO NOTHING;

-- =====================
-- TABLA: scorecard_results
-- Resultados semanales por metrica
-- =====================
CREATE TABLE IF NOT EXISTS scorecard_results (
    id TEXT PRIMARY KEY,
    metric_id TEXT NOT NULL REFERENCES scorecard_metrics(id) ON DELETE CASCADE,
    week INTEGER NOT NULL CHECK (week >= 1 AND week <= 13),
    result TEXT NOT NULL,
    good BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (metric_id, week)
);

INSERT INTO scorecard_results (id, metric_id, week, result, good) VALUES
    ('sr1',  'm1',  12, '$27,300', true),
    ('sr2',  'm2',  12, '18',      true),
    ('sr3',  'm3',  12, '22%',     false),
    ('sr4',  'm4',  12, '4.3x',    true),
    ('sr5',  'm5',  12, '108%',    true),
    ('sr6',  'm6',  12, '4.1%',    false),
    ('sr7',  'm7',  12, '97%',     true),
    ('sr8',  'm8',  12, '47',      false),
    ('sr9',  'm9',  12, '10',      true),
    ('sr10', 'm10', 12, '12',      true),
    ('sr11', 'm11', 12, '$720',    true),
    ('sr12', 'm12', 12, '74',      true),
    ('sr13', 'm13', 12, '152h',    false)
ON CONFLICT (id) DO NOTHING;

-- =====================
-- TABLA: leaderboard_entries
-- Metricas de display del leaderboard por miembro y trimestre
-- =====================
CREATE TABLE IF NOT EXISTS leaderboard_entries (
    id TEXT PRIMARY KEY,
    member_id TEXT NOT NULL REFERENCES team_members(id),
    quarter_key TEXT NOT NULL,
    metric_label TEXT DEFAULT '',
    metric_value TEXT DEFAULT '',
    progress INTEGER DEFAULT 0,
    goal TEXT DEFAULT '',
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (member_id, quarter_key)
);

INSERT INTO leaderboard_entries (id, member_id, quarter_key, metric_label, metric_value, progress, goal) VALUES
    ('lb1', 'tomas',     '2026-Q1', 'Tasa de Cumplimiento de Rocks', '85%',  85, '80%'),
    ('lb2', 'nicolas',   '2026-Q1', 'NRR (Net Revenue Retention)',   '108%', 90, '105%'),
    ('lb3', 'christian', '2026-Q1', 'ROAS Promedio',                 '4.3x', 78, '4.5x'),
    ('lb4', 'roberto',   '2026-Q1', 'Tasa de Entrega a Tiempo',     '97%',  97, '95%')
ON CONFLICT (id) DO NOTHING;

-- =====================
-- TABLA: fame_wall
-- Muro de la fama - Casos de exito
-- =====================
CREATE TABLE IF NOT EXISTS fame_wall (
    id TEXT PRIMARY KEY,
    quarter_key TEXT NOT NULL,
    name TEXT NOT NULL,
    initials TEXT NOT NULL,
    retention_months INTEGER DEFAULT 0,
    roas NUMERIC DEFAULT 0,
    added_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT now()
);

INSERT INTO fame_wall (id, quarter_key, name, initials, retention_months, roas, added_date) VALUES
    ('f1', '2026-Q1', 'Grupo Madera MX', 'GM', 14, 5.2, '2025-07-01'),
    ('f2', '2026-Q1', 'AutoParts Pro',   'AP', 11, 6.1, '2025-09-01'),
    ('f3', '2026-Q1', 'Dental Plus',     'DP',  9, 4.8, '2025-11-01'),
    ('f4', '2026-Q1', 'Fit Academy',     'FA',  8, 4.5, '2025-12-01'),
    ('f5', '2026-Q1', 'TechStore MX',    'TS',  7, 5.7, '2026-01-15'),
    ('f6', '2026-Q1', 'Casa & Diseño',   'CD',  7, 4.2, '2026-03-10'),
    ('f7', '2026-Q1', 'Nutrilab',        'NL',  6, 4.9, '2026-03-18')
ON CONFLICT (id) DO NOTHING;

-- =====================
-- TABLA: comments
-- Sistema de comentarios para IA y equipo
-- =====================
CREATE TABLE IF NOT EXISTS comments (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    section TEXT NOT NULL CHECK (section IN ('pulso', 'rocks', 'scorecard', 'leaderboard', 'fame_wall', 'general')),
    reference_id TEXT,           -- ID del rock, metrica, miembro, o cliente al que se refiere
    quarter_key TEXT NOT NULL,
    author TEXT NOT NULL,        -- Nombre del autor (persona o IA)
    author_type TEXT DEFAULT 'human' CHECK (author_type IN ('human', 'ai')),
    content TEXT NOT NULL,
    resolved BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- =====================
-- VISTA: scorecard_full
-- Vista consolidada del scorecard con metricas y resultados
-- =====================
CREATE OR REPLACE VIEW scorecard_full AS
SELECT
    sm.id AS metric_id,
    sm.quarter_key,
    sm.metric,
    sm.owner_id,
    tm.name AS owner_name,
    sm.goal,
    sm.direction,
    sm.sort_order,
    sr.week,
    sr.result,
    sr.good
FROM scorecard_metrics sm
LEFT JOIN scorecard_results sr ON sr.metric_id = sm.id
LEFT JOIN team_members tm ON tm.id = sm.owner_id
ORDER BY sm.sort_order, sr.week;

-- =====================
-- VISTA: leaderboard_full
-- Vista del leaderboard con datos de miembro
-- =====================
CREATE OR REPLACE VIEW leaderboard_full AS
SELECT
    le.*,
    tm.name AS member_name,
    tm.role AS member_role,
    tm.avatar AS member_avatar,
    tm.color AS member_color
FROM leaderboard_entries le
JOIN team_members tm ON tm.id = le.member_id;

-- =====================
-- VISTA: rocks_full
-- Vista de rocks con datos del dueno
-- =====================
CREATE OR REPLACE VIEW rocks_full AS
SELECT
    r.*,
    tm.name AS owner_name,
    tm.avatar AS owner_avatar
FROM rocks r
JOIN team_members tm ON tm.id = r.owner_id;

-- =====================
-- TRIGGERS: auto-update updated_at
-- =====================
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_config BEFORE UPDATE ON dashboard_config
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_timestamp_pulso BEFORE UPDATE ON pulso
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_timestamp_rocks BEFORE UPDATE ON rocks
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_timestamp_lb BEFORE UPDATE ON leaderboard_entries
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();
CREATE TRIGGER set_timestamp_comments BEFORE UPDATE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_timestamp();

-- =====================
-- ROW LEVEL SECURITY (RLS)
-- Acceso publico con anon key (equipo pequeno)
-- Para mas seguridad: agregar Supabase Auth despues
-- =====================
ALTER TABLE dashboard_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE pulso ENABLE ROW LEVEL SECURITY;
ALTER TABLE rocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE scorecard_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE scorecard_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE fame_wall ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Politicas: permitir todo con anon key
DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN SELECT unnest(ARRAY[
        'dashboard_config', 'team_members', 'pulso', 'rocks',
        'scorecard_metrics', 'scorecard_results', 'leaderboard_entries',
        'fame_wall', 'comments'
    ]) LOOP
        EXECUTE format('CREATE POLICY "Allow all select on %I" ON %I FOR SELECT USING (true)', tbl, tbl);
        EXECUTE format('CREATE POLICY "Allow all insert on %I" ON %I FOR INSERT WITH CHECK (true)', tbl, tbl);
        EXECUTE format('CREATE POLICY "Allow all update on %I" ON %I FOR UPDATE USING (true)', tbl, tbl);
        EXECUTE format('CREATE POLICY "Allow all delete on %I" ON %I FOR DELETE USING (true)', tbl, tbl);
    END LOOP;
END $$;

-- ============================================================
-- LISTO! Tu base de datos esta configurada.
-- Ahora ve a Settings > API y copia tu Project URL y anon key.
-- ============================================================
