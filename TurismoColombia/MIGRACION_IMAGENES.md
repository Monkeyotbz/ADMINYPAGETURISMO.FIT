# Guía para Migrar Imágenes a Supabase Storage

## 📋 Requisitos previos
- ✅ Bucket `property-images` creado en Supabase Storage
- ✅ Bucket configurado como PÚBLICO
- ✅ Políticas de Storage aplicadas (storage-config.sql)
- ✅ Node.js instalado

## 🔧 Configuración

### 1. Obtener las credenciales de Supabase

Ve a tu proyecto en Supabase Dashboard:

1. Click en **Settings** (⚙️ en la barra lateral)
2. Click en **API**
3. Copia estos valores:

   - **Project URL**: Algo como `https://xxxxxxxxxx.supabase.co`
   - **service_role key** (⚠️ NO la anon key): Es un token largo que comienza con `eyJ...`

### 2. Editar el archivo migrate-images.js

Abre `migrate-images.js` y reemplaza estas líneas:

```javascript
const SUPABASE_URL = 'TU_SUPABASE_URL'; 
const SUPABASE_SERVICE_KEY = 'TU_SUPABASE_SERVICE_KEY';
```

Por tus valores reales:

```javascript
const SUPABASE_URL = 'https://xxxxxxxxxx.supabase.co';
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJI...tu-token-completo-aqui';
```

⚠️ **IMPORTANTE**: La `service_role key` tiene acceso total a tu base de datos. NO la compartas ni la subas a GitHub.

## 🚀 Ejecutar la migración

### Opción 1: Ejecución directa (recomendada)

```powershell
cd "C:\PROGRAMACION GABRIEL CARVAJAL\TurismoColombia\project"
node migrate-images.js
```

### Opción 2: Si tienes problemas con ES Modules

El archivo usa `import` (ES6), si tienes errores:

1. Verifica que tu `package.json` tenga: `"type": "module"`
2. O cambia la extensión del archivo a `.mjs`: `migrate-images.mjs`

## 📊 Qué hace el script

1. **Lee las carpetas** de imágenes en `public/`:
   - `JARDIN/` → Cabaña Las Águilas
   - `OPERA/` → Hotel Opera Medellín
   - `CARABELAS/` → Hospedajes Penthouse Cartagena
   - etc.

2. **Sube cada imagen** al Storage de Supabase:
   - Bucket: `property-images`
   - Path: `{property_id}/{timestamp}-{order}.jpg`

3. **Crea registros** en la tabla `property_images`:
   - Vincula la imagen a la propiedad
   - Establece el orden de visualización
   - Guarda la URL pública

## 🎯 Después de la migración

1. Ve a **Storage** en Supabase Dashboard
2. Click en el bucket `property-images`
3. Deberías ver carpetas con el ID de cada propiedad
4. Cada carpeta contendrá las imágenes de esa propiedad

5. Ve a **Admin → Propiedades** en tu aplicación
6. Deberías ver las miniaturas en la tabla
7. Al editar una propiedad, verás todas sus imágenes en la galería

## ⚠️ Solución de problemas

### Error: "Failed to upload"
- Verifica que el bucket esté marcado como PÚBLICO
- Confirma que las políticas de Storage estén aplicadas

### Error: "Property not found"
- La propiedad no existe en la base de datos
- Verifica que ejecutaste `admin-schema.sql` completo

### Error: "Cannot find module"
- Ejecuta: `npm install @supabase/supabase-js`

### Las imágenes no se ven en la app
- Verifica que la URL pública sea accesible en el navegador
- Confirma que el bucket sea PÚBLICO (no privado)

## 🔄 Mapeo de carpetas

El script mapea estas carpetas automáticamente:

| Carpeta | Propiedad |
|---------|-----------|
| JARDIN | Cabaña Las Águilas |
| OPERA | Hotel Opera Medellín Centro |
| OPERA JACUZZI | Hotel Opera Habitación con Jacuzzi |
| OPERA SEMI SUITE | Hotel Opera Semi Suite |
| OPERA DOBLE CLASICA | Hotel Opera Doble Clásica |
| penthousemed | Penthouse Panorama Medellín |
| JERICO | Hospedaje Rural Jericó |
| ELLAGUITO | Hospedaje Delux Cartagena |
| CARABELAS | Hospedajes Penthouse Cartagena |
| TORRESDELLAGO | Hospedaje Cartagena Turismocolombia |
| ORO | Hospedajes Cartagena Tours |
| NUEVO CONQUISTADOR | Hoteles Cartagena Bocagrande |
| SAN JERONIMO | Alojamiento Rural San Jerónimo |
| PITALITO | Turismo Rural Rancho California |

Si tienes otras carpetas, agrégalas al objeto `PROPERTY_FOLDERS` en el script.

## 🗑️ Después de verificar

Una vez que confirmes que todas las imágenes están en Supabase y se ven correctamente:

1. Puedes eliminar las carpetas de imágenes de `public/`
2. O déjalas como respaldo hasta estar 100% seguro
3. NO elimines el script `migrate-images.js` (por si necesitas re-ejecutarlo)

---

**¿Necesitas ayuda?** Revisa los logs que imprime el script, te dirá exactamente qué se subió y qué falló.
