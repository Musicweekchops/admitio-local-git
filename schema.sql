-- ============================================
-- ADMITIO - Schema PostgreSQL para Supabase
-- ============================================

-- Habilitar extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLAS PRINCIPALES
-- ============================================

-- Organizaciones (Multi-tenant)
CREATE TABLE organizaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre VARCHAR(255) NOT NULL,
  slug VARCHAR(100) UNIQUE NOT NULL,
  logo_url TEXT,
  dominio_personalizado VARCHAR(255),
  config JSONB DEFAULT '{}',
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Usuarios
CREATE TABLE usuarios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  nombre VARCHAR(255) NOT NULL,
  avatar_url TEXT,
  rol VARCHAR(50) NOT NULL CHECK (rol IN ('backdoor', 'keymaster', 'encargado', 'asistente', 'rector')),
  auth_provider VARCHAR(50) DEFAULT 'email',
  auth_id VARCHAR(255),
  activo BOOLEAN DEFAULT true,
  oculto BOOLEAN DEFAULT false,
  config JSONB DEFAULT '{"notificaciones_email": true, "notificaciones_popup": true}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(org_id, email)
);

-- Carreras/Programas
CREATE TABLE carreras (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  color VARCHAR(50) DEFAULT 'bg-slate-500',
  activa BOOLEAN DEFAULT true,
  orden INT DEFAULT 0
);

-- Medios de contacto
CREATE TABLE medios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  codigo VARCHAR(50) NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  icono VARCHAR(50),
  color VARCHAR(50),
  activo BOOLEAN DEFAULT true
);

-- Leads/Consultas
CREATE TABLE leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  
  -- Datos del prospecto
  nombre VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL,
  telefono VARCHAR(50),
  carrera_id UUID REFERENCES carreras(id),
  medio_id UUID REFERENCES medios(id),
  tipo_alumno VARCHAR(20) DEFAULT 'nuevo' CHECK (tipo_alumno IN ('nuevo', 'antiguo')),
  
  -- Estado y asignación
  estado VARCHAR(50) DEFAULT 'nueva' CHECK (estado IN ('nueva', 'contactado', 'seguimiento', 'examen_admision', 'matriculado', 'descartado')),
  asignado_a UUID REFERENCES usuarios(id),
  en_cola BOOLEAN DEFAULT false,
  
  -- Seguimiento
  notas TEXT,
  emails_enviados INT DEFAULT 0,
  ultimo_whatsapp TIMESTAMPTZ,
  
  -- Fechas importantes
  created_at TIMESTAMPTZ DEFAULT NOW(),
  fecha_primer_contacto TIMESTAMPTZ,
  fecha_proximo_contacto TIMESTAMPTZ,
  fecha_examen_admision TIMESTAMPTZ,
  fecha_cierre TIMESTAMPTZ,
  
  -- Cierre
  matriculado BOOLEAN DEFAULT false,
  descartado BOOLEAN DEFAULT false,
  motivo_descarte TEXT,
  reactivado_de UUID REFERENCES leads(id),
  
  -- Formulario origen
  formulario_id UUID,
  datos_extra JSONB DEFAULT '{}'
);

-- Actividad/Historial
CREATE TABLE actividad (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
  user_id UUID REFERENCES usuarios(id),
  user_nombre VARCHAR(255),
  tipo VARCHAR(50) NOT NULL,
  descripcion TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Recordatorios
CREATE TABLE recordatorios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
  user_id UUID REFERENCES usuarios(id),
  tipo VARCHAR(50) NOT NULL CHECK (tipo IN ('whatsapp_followup', 'sin_avance', 'examen_lead', 'examen_encargado', 'personalizado')),
  descripcion TEXT,
  fecha_disparo TIMESTAMPTZ NOT NULL,
  disparado BOOLEAN DEFAULT false,
  resultado VARCHAR(50),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Formularios embebibles
CREATE TABLE formularios (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  descripcion TEXT,
  slug VARCHAR(100) NOT NULL,
  campos JSONB NOT NULL DEFAULT '[]',
  carreras_ids UUID[],
  activo BOOLEAN DEFAULT true,
  fecha_inicio TIMESTAMPTZ,
  fecha_fin TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(org_id, slug)
);

-- Plantillas de correo
CREATE TABLE plantillas_correo (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  nombre VARCHAR(255) NOT NULL,
  asunto VARCHAR(255) NOT NULL,
  contenido TEXT NOT NULL,
  tipo VARCHAR(50),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Correos enviados
CREATE TABLE correos_enviados (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
  user_id UUID REFERENCES usuarios(id),
  plantilla_id UUID REFERENCES plantillas_correo(id),
  asunto VARCHAR(255),
  contenido TEXT,
  destinatario VARCHAR(255),
  estado VARCHAR(50) DEFAULT 'enviado',
  provider VARCHAR(50),
  provider_id VARCHAR(255),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Métricas de encargados
CREATE TABLE metricas_encargados (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  user_id UUID REFERENCES usuarios(id),
  fecha DATE NOT NULL,
  leads_recibidos INT DEFAULT 0,
  leads_contactados INT DEFAULT 0,
  leads_matriculados INT DEFAULT 0,
  leads_descartados INT DEFAULT 0,
  tiempo_promedio_contacto INTERVAL,
  UNIQUE(user_id, fecha)
);

-- Cola de leads
CREATE TABLE cola_leads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
  prioridad INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Notificaciones
CREATE TABLE notificaciones (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE,
  user_id UUID REFERENCES usuarios(id),
  tipo VARCHAR(50) NOT NULL,
  mensaje TEXT NOT NULL,
  lead_id UUID REFERENCES leads(id),
  leida BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Configuración por organización
CREATE TABLE config_org (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  org_id UUID REFERENCES organizaciones(id) ON DELETE CASCADE UNIQUE,
  
  -- Asignación
  max_leads_diarios_encargado INT DEFAULT 15,
  horario_inicio TIME DEFAULT '09:00',
  horario_fin TIME DEFAULT '18:00',
  dias_laborales INT[] DEFAULT '{1,2,3,4,5}',
  
  -- Recordatorios
  horas_recordatorio_whatsapp INT DEFAULT 2,
  dias_sin_avance_alerta INT DEFAULT 3,
  dias_antes_examen_recordatorio INT DEFAULT 2,
  
  -- Correos
  email_remitente VARCHAR(255),
  smtp_config JSONB,
  
  -- Reportes
  enviar_reporte_semanal BOOLEAN DEFAULT true,
  enviar_reporte_mensual BOOLEAN DEFAULT true,
  email_rector VARCHAR(255),
  
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- ÍNDICES
-- ============================================
CREATE INDEX idx_leads_org ON leads(org_id);
CREATE INDEX idx_leads_asignado ON leads(asignado_a);
CREATE INDEX idx_leads_estado ON leads(estado);
CREATE INDEX idx_leads_created ON leads(created_at DESC);
CREATE INDEX idx_leads_no_cerrados ON leads(org_id) WHERE NOT matriculado AND NOT descartado;

CREATE INDEX idx_actividad_lead ON actividad(lead_id);
CREATE INDEX idx_actividad_created ON actividad(created_at DESC);

CREATE INDEX idx_recordatorios_pendientes ON recordatorios(fecha_disparo) WHERE NOT disparado;
CREATE INDEX idx_recordatorios_user ON recordatorios(user_id) WHERE NOT disparado;

CREATE INDEX idx_notificaciones_user ON notificaciones(user_id) WHERE NOT leida;

CREATE INDEX idx_usuarios_org ON usuarios(org_id);
CREATE INDEX idx_usuarios_rol ON usuarios(rol);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE organizaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE carreras ENABLE ROW LEVEL SECURITY;
ALTER TABLE medios ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE actividad ENABLE ROW LEVEL SECURITY;
ALTER TABLE recordatorios ENABLE ROW LEVEL SECURITY;
ALTER TABLE formularios ENABLE ROW LEVEL SECURITY;
ALTER TABLE plantillas_correo ENABLE ROW LEVEL SECURITY;
ALTER TABLE correos_enviados ENABLE ROW LEVEL SECURITY;
ALTER TABLE metricas_encargados ENABLE ROW LEVEL SECURITY;
ALTER TABLE cola_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE config_org ENABLE ROW LEVEL SECURITY;

-- Función helper para obtener org_id del usuario actual
CREATE OR REPLACE FUNCTION get_user_org_id()
RETURNS UUID AS $$
  SELECT org_id FROM usuarios WHERE auth_id = auth.uid()::text LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER;

-- Función helper para obtener rol del usuario actual
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
  SELECT rol FROM usuarios WHERE auth_id = auth.uid()::text LIMIT 1;
$$ LANGUAGE SQL SECURITY DEFINER;

-- Políticas para leads
CREATE POLICY "Leads: KeyMaster/Backdoor ve todos" ON leads
  FOR SELECT USING (
    org_id = get_user_org_id() AND 
    get_user_role() IN ('keymaster', 'backdoor')
  );

CREATE POLICY "Leads: Encargado ve los suyos" ON leads
  FOR SELECT USING (
    org_id = get_user_org_id() AND 
    get_user_role() = 'encargado' AND
    asignado_a = (SELECT id FROM usuarios WHERE auth_id = auth.uid()::text)
  );

CREATE POLICY "Leads: Crear" ON leads
  FOR INSERT WITH CHECK (
    org_id = get_user_org_id() AND
    get_user_role() IN ('keymaster', 'backdoor', 'encargado', 'asistente')
  );

CREATE POLICY "Leads: Editar" ON leads
  FOR UPDATE USING (
    org_id = get_user_org_id() AND (
      get_user_role() IN ('keymaster', 'backdoor') OR
      (get_user_role() = 'encargado' AND asignado_a = (SELECT id FROM usuarios WHERE auth_id = auth.uid()::text))
    )
  );

-- Políticas para notificaciones
CREATE POLICY "Notificaciones: Ver propias" ON notificaciones
  FOR SELECT USING (
    user_id = (SELECT id FROM usuarios WHERE auth_id = auth.uid()::text)
  );

-- ============================================
-- DATOS INICIALES PARA PROJAZZ
-- ============================================

-- Crear organización ProJazz
INSERT INTO organizaciones (id, nombre, slug, config) VALUES (
  'org-projazz-001',
  'ProJazz',
  'projazz',
  '{"color_primario": "#7c3aed"}'
);

-- Crear configuración
INSERT INTO config_org (org_id, email_remitente, email_rector) VALUES (
  'org-projazz-001',
  'admision@projazz.cl',
  'rector@projazz.cl'
);

-- Crear usuarios
INSERT INTO usuarios (id, org_id, email, nombre, rol, oculto) VALUES
  ('user-backdoor', 'org-projazz-001', 'owner@admitio.com', 'Acceso Propietario', 'backdoor', true),
  ('user-1', 'org-projazz-001', 'admin@projazz.cl', 'Carolina Vásquez', 'keymaster', false),
  ('user-2', 'org-projazz-001', 'maria@projazz.cl', 'María González', 'encargado', false),
  ('user-3', 'org-projazz-001', 'pedro@projazz.cl', 'Pedro Soto', 'encargado', false),
  ('user-4', 'org-projazz-001', 'secretaria@projazz.cl', 'Andrea Muñoz', 'asistente', false),
  ('user-5', 'org-projazz-001', 'rector@projazz.cl', 'Dr. Roberto Méndez', 'rector', false);

-- Crear carreras
INSERT INTO carreras (org_id, nombre, color, orden) VALUES
  ('org-projazz-001', 'Canto Popular', 'bg-pink-500', 1),
  ('org-projazz-001', 'Guitarra Eléctrica', 'bg-orange-500', 2),
  ('org-projazz-001', 'Batería', 'bg-red-500', 3),
  ('org-projazz-001', 'Bajo Eléctrico', 'bg-purple-500', 4),
  ('org-projazz-001', 'Piano/Teclados', 'bg-blue-500', 5),
  ('org-projazz-001', 'Producción Musical', 'bg-green-500', 6),
  ('org-projazz-001', 'Composición', 'bg-teal-500', 7),
  ('org-projazz-001', 'Audio', 'bg-cyan-500', 8);

-- Crear medios
INSERT INTO medios (org_id, codigo, nombre, icono, color) VALUES
  ('org-projazz-001', 'instagram', 'Instagram', 'Instagram', 'text-pink-500'),
  ('org-projazz-001', 'web', 'Sitio Web', 'Globe', 'text-blue-500'),
  ('org-projazz-001', 'whatsapp', 'WhatsApp', 'MessageCircle', 'text-green-500'),
  ('org-projazz-001', 'telefono', 'Teléfono', 'Phone', 'text-slate-500'),
  ('org-projazz-001', 'referido', 'Referido', 'Users', 'text-violet-500'),
  ('org-projazz-001', 'email', 'Email directo', 'Mail', 'text-amber-500');

-- Crear plantillas de correo
INSERT INTO plantillas_correo (org_id, nombre, asunto, contenido, tipo) VALUES
  ('org-projazz-001', 'Bienvenida', '¡Gracias por tu interés en ProJazz!', 
   'Hola {{nombre}},\n\n¡Gracias por contactarnos! Hemos recibido tu consulta sobre la carrera de {{carrera}}.\n\nSaludos,\n{{encargado}}',
   'bienvenida'),
  ('org-projazz-001', 'Seguimiento', '¿Cómo vas con tu decisión? - ProJazz',
   'Hola {{nombre}},\n\nHace un tiempo conversamos sobre tu interés en {{carrera}}. ¿Tienes alguna duda?\n\nSaludos,\n{{encargado}}',
   'seguimiento');

-- Crear formulario de admisión
INSERT INTO formularios (org_id, nombre, descripcion, slug, campos, activo) VALUES
  ('org-projazz-001', 'Admisión 2025', 'Formulario principal de admisión', 'admision-2025',
   '[{"id": "nombre", "label": "Nombre completo", "tipo": "text", "requerido": true},
     {"id": "email", "label": "Correo electrónico", "tipo": "email", "requerido": true},
     {"id": "telefono", "label": "Teléfono", "tipo": "tel", "requerido": true},
     {"id": "carrera", "label": "Carrera de interés", "tipo": "select", "requerido": true, "opciones": "carreras"}]',
   true);

-- ============================================
-- FUNCIONES ÚTILES
-- ============================================

-- Función para asignar lead automáticamente
CREATE OR REPLACE FUNCTION asignar_lead_automatico(p_org_id UUID)
RETURNS UUID AS $$
DECLARE
  v_encargado_id UUID;
  v_max_leads INT;
BEGIN
  -- Obtener configuración
  SELECT max_leads_diarios_encargado INTO v_max_leads
  FROM config_org WHERE org_id = p_org_id;
  
  -- Buscar encargado con menos leads activos
  SELECT u.id INTO v_encargado_id
  FROM usuarios u
  LEFT JOIN (
    SELECT asignado_a, COUNT(*) as total
    FROM leads
    WHERE org_id = p_org_id AND NOT matriculado AND NOT descartado
    GROUP BY asignado_a
  ) l ON l.asignado_a = u.id
  WHERE u.org_id = p_org_id 
    AND u.rol = 'encargado' 
    AND u.activo = true
    AND COALESCE(l.total, 0) < v_max_leads
  ORDER BY COALESCE(l.total, 0) ASC
  LIMIT 1;
  
  RETURN v_encargado_id;
END;
$$ LANGUAGE plpgsql;

-- Trigger para registrar actividad automáticamente
CREATE OR REPLACE FUNCTION log_lead_activity()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'UPDATE' THEN
    IF OLD.estado != NEW.estado THEN
      INSERT INTO actividad (org_id, lead_id, user_id, tipo, descripcion)
      VALUES (NEW.org_id, NEW.id, NEW.asignado_a, 'cambio_estado', 
              'Estado: ' || OLD.estado || ' → ' || NEW.estado);
    END IF;
    
    IF OLD.asignado_a IS DISTINCT FROM NEW.asignado_a THEN
      INSERT INTO actividad (org_id, lead_id, user_id, tipo, descripcion)
      VALUES (NEW.org_id, NEW.id, NEW.asignado_a, 'reasignacion', 
              'Lead reasignado');
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_lead_activity
  AFTER UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION log_lead_activity();

-- ============================================
-- FIN DEL SCHEMA
-- ============================================
