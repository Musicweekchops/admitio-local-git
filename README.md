# 🎓 Admitio - Sistema de Gestión de Admisiones

Sistema completo para gestionar el proceso de admisión de instituciones educativas.

## 📋 Características

- ✅ Gestión de leads/consultas
- ✅ Seguimiento de estados (Nueva → Contactado → Seguimiento → Examen → Matriculado)
- ✅ Múltiples roles (SuperAdmin, KeyMaster, Encargado, Asistente, Rector)
- ✅ Reportería con gráficos interactivos
- ✅ Importación masiva desde CSV/Excel
- ✅ Formularios embebibles para sitio web
- ✅ Detección de duplicados
- ✅ Registro de acciones de contacto

---

# 🚀 MANUAL DE DEPLOY EN RENDER

## Opción A: Deploy Automático (Recomendado) ⭐

### Paso 1: Subir a GitHub

1. Crea un repositorio en GitHub (público o privado)
2. Sube los archivos:

```bash
git init
git add .
git commit -m "Admitio v2.2"
git branch -M main
git remote add origin https://github.com/TU-USUARIO/admitio.git
git push -u origin main
```

### Paso 2: Conectar con Render

1. Ve a [render.com](https://render.com) y crea una cuenta (gratis)
2. Click en **"New +"** → **"Static Site"**
3. Conecta tu cuenta de GitHub
4. Selecciona el repositorio **admitio**
5. Render detectará automáticamente el `render.yaml`

### Paso 3: Configurar (automático)

Render leerá el archivo `render.yaml` y configurará:
- **Build Command:** `npm install && npm run build`
- **Publish Directory:** `dist`
- **Rutas SPA:** Configuradas automáticamente

### Paso 4: Deploy

1. Click en **"Create Static Site"**
2. Espera 2-3 minutos mientras se construye
3. ¡Listo! Tu URL será: `https://admitio-XXXX.onrender.com`

---

## Opción B: Deploy Manual

Si prefieres configurar manualmente:

### En Render Dashboard:

| Campo | Valor |
|-------|-------|
| **Name** | admitio |
| **Branch** | main |
| **Build Command** | `npm install && npm run build` |
| **Publish Directory** | `dist` |

### Agregar Rewrite Rule:

En **Redirects/Rewrites**, agregar:
- **Source:** `/*`
- **Destination:** `/index.html`
- **Action:** Rewrite

---

## 🔐 Credenciales por Defecto

### SuperAdmin (Propietario - Oculto)
```
Email: owner@admitio.cl
Password: Admitio2024!Secure
```

### KeyMaster (Administrador)
```
Email: admin@projazz.cl
Password: admin123
```

### Encargados
```
Email: maria@projazz.cl / pedro@projazz.cl
Password: 123456
```

### Otros roles
```
Email: secretaria@projazz.cl (Asistente)
Email: rector@projazz.cl (Rector)
Password: 123456 / rector123
```

---

## ⚙️ Configuración Post-Deploy

### 1. Cambiar Credenciales
Una vez en producción, entra como SuperAdmin y:
- Cambia las contraseñas de todos los usuarios
- Crea los usuarios reales de tu institución
- Elimina los usuarios de prueba

### 2. Personalizar Carreras
Edita el archivo `src/data/mockData.js`:
```javascript
export const CARRERAS = [
  { id: 1, nombre: 'Tu Carrera 1', color: 'bg-pink-500', activa: true },
  { id: 2, nombre: 'Tu Carrera 2', color: 'bg-orange-500', activa: true },
  // ...
]
```

### 3. Personalizar Medios de Contacto
En el mismo archivo:
```javascript
export const MEDIOS = [
  { id: 'instagram', nombre: 'Instagram', icono: 'Instagram', color: 'text-pink-500' },
  { id: 'web', nombre: 'Sitio Web', icono: 'Globe', color: 'text-blue-500' },
  // ...
]
```

---

## 🔄 Actualizar la Aplicación

Cada vez que hagas cambios:

```bash
git add .
git commit -m "Descripción del cambio"
git push
```

Render detectará el push y re-desplegará automáticamente (2-3 min).

---

## 📊 Monitoreo

En el dashboard de Render puedes ver:
- **Logs** de build y errores
- **Bandwidth** usado
- **Requests** por día

---

## 🆘 Solución de Problemas

### Error: "Page not found" al refrescar
→ Verifica que el archivo `_redirects` esté en `/public`

### Error: Build failed
→ Ejecuta `npm run build` localmente para ver el error

### No carga los estilos
→ Limpia caché del navegador (Ctrl+Shift+R)

### Los datos no se guardan
→ Esta versión usa localStorage. Para persistencia real, necesitas backend + base de datos.

---

## 🗄️ Próximos Pasos (Producción Real)

Para una versión de producción completa, se necesita:

1. **Backend:** Node.js/Express o similar
2. **Base de datos:** PostgreSQL (Render ofrece gratis)
3. **Autenticación:** JWT tokens
4. **API:** REST o GraphQL

El archivo `schema.sql` incluido tiene la estructura de base de datos lista para PostgreSQL.

---

## 📁 Estructura del Proyecto

```
admitio/
├── public/
│   ├── _redirects      # Rutas SPA
│   ├── _headers        # Control de caché
│   └── favicon.svg
├── src/
│   ├── components/     # Componentes React
│   ├── context/        # AuthContext
│   ├── data/           # Datos mock
│   ├── lib/            # Store (lógica)
│   └── pages/          # Vistas
├── render.yaml         # Config Render
├── package.json
└── vite.config.js
```

---

## 📞 Soporte

Desarrollado por MWC Estudio
Santiago, Chile

---

**Versión:** 2.2  
**Última actualización:** Diciembre 2024
