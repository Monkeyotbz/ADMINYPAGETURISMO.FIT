# Configuración de Vercel para Base de Datos

## ⚙️ Variables de Entorno en Vercel

Para que tu sitio funcione en producción con Supabase, sigue estos pasos:

### 1. Ve a Vercel Dashboard
- Abre: https://vercel.com/dashboard
- Selecciona tu proyecto (colombiaturismo.fit o el que corresponda)

### 2. Configura las Variables de Entorno
- Ve a **Settings** → **Environment Variables**
- Agrega las siguientes 2 variables:

#### Variable 1:
```
Name: VITE_SUPABASE_URL
Value: https://ckgxwrhyjnadbdixzsmq.supabase.co
Environment: Production, Preview, Development (selecciona las 3)
```

#### Variable 2:
```
Name: VITE_SUPABASE_ANON_KEY
Value: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNrZ3h3cmh5am5hZGJkaXh6c21xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0NTk4MDMsImV4cCI6MjA4MjAzNTgwM30.f3zTu3uuJbIKnQPbGHtzVUL2z019Uicjhzqa2P3F-k8
Environment: Production, Preview, Development (selecciona las 3)
```

### 3. Redeploy
- Después de agregar las variables, ve a **Deployments**
- Haz clic en los 3 puntos (...) del último deployment
- Selecciona **Redeploy**
- Marca la opción "Use existing Build Cache" (opcional)
- Haz clic en **Redeploy**

### 4. Verifica que funcione
Una vez que termine el deploy, abre tu sitio y verifica:
- ✅ Las propiedades se cargan desde la base de datos
- ✅ Los tours se muestran correctamente
- ✅ Las imágenes se ven (desde Supabase Storage)
- ✅ Puedes crear una cuenta
- ✅ Puedes hacer login

### 5. Crear tu cuenta de admin
1. Crea una cuenta normal desde el sitio en producción
2. Ve a Supabase Dashboard: https://supabase.com/dashboard/project/ckgxwrhyjnadbdixzsmq
3. Ve a **SQL Editor**
4. Ejecuta este query (cambia el email por el tuyo):

```sql
UPDATE users 
SET role = 'admin' 
WHERE email = 'tuemail@ejemplo.com';
```

5. Cierra sesión y vuelve a entrar
6. Ahora deberías ver el panel de administración

## 🔒 Seguridad

- ✅ El archivo `.env` está en `.gitignore` (no se sube a GitHub)
- ✅ La `ANON_KEY` es segura para el frontend (tiene permisos limitados)
- ✅ Las políticas RLS de Supabase protegen los datos
- ⚠️ NUNCA subas el `SERVICE_ROLE_KEY` a GitHub o Vercel frontend

## 📝 Notas

- Las variables de entorno en Vercel solo se aplican DESPUÉS de un redeploy
- Si cambias algo en Supabase (tablas, políticas), no necesitas redeploy
- Las imágenes están en Supabase Storage (no en Vercel), por eso funcionan automáticamente
