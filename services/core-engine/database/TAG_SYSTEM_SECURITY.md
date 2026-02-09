# TAG SYSTEM SECURITY ARCHITECTURE

## 🎯 OBJETIVO PRINCIPAL
**NADA debe estar expuesto en el frontend** - Todo el manejo de tags es backend-driven con IDs, nunca con nombres expuestos.

## 🏗️ ARQUITECTURA DE CAPAS

```
Frontend (Astro) → API Gateway (NestJS) → Core Engine (Go) → Postgres
```

### 1. FRONTEND (Solo recibe datos procesados)
- **NO** accede directamente a Supabase
- **NO** conoce los IDs internos de los tags
- **NO** tiene lógica de negocio
- **SÍ** recibe solo: `{ name: "FAN", color: "#6366F1", animation: "member-shine" }`

### 2. API GATEWAY (Seguridad y validación)
- Valida headers `x-user-id` para autenticación
- Procesa requests y las envía al Core Engine
- Aplica lógica de negocio y validaciones
- Retorna datos procesados al frontend

### 3. CORE ENGINE (Lógica de negocio)
- Maneja todas las operaciones de base de datos
- Implementa la lógica de roles invisibles
- Procesa y formatea los datos antes de enviarlos
- Mantiene la integridad de los datos

### 4. POSTGRES (Almacenamiento seguro)
- Tablas normalizadas con relaciones correctas
- Triggers para mantener consistencia
- Índices para performance
- Datos sensibles protegidos

## 🔒 SEGURIDAD POR CAPAS

### Frontend → API Gateway
```javascript
// Frontend solo envía IDs, nunca nombres
const response = await fetch('/api/tags/assign', {
  method: 'POST',
  headers: {
    'x-user-id': userId, // Header para autenticación
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ tagId: 123 }) // ID numérico, nunca nombre
});
```

### API Gateway → Core Engine
```typescript
// NestJS valida y procesa
async assignTagToUser(userId: string, tagId: number) {
  // Validación de seguridad
  if (!userId || !tagId) {
    throw new BadRequestException('Missing required fields');
  }
  
  // Envia al Core Engine con header de seguridad
  return this.httpService.post(`/api/v1/users/${userId}/tags/${tagId}`, {}, {
    headers: { 'X-User-Id': userId }
  });
}
```

### Core Engine → Postgres
```go
// Go maneja la lógica compleja
func assignTagToUser(userID string, tagID int) error {
    // Validaciones de seguridad
    if userID == "" || tagID == 0 {
        return fmt.Errorf("invalid parameters")
    }
    
    // Query segura con prepared statements
    query := `
        INSERT INTO user_has_tags (user_id, tag_id)
        VALUES ($1, $2)
        ON CONFLICT (user_id, tag_id) DO NOTHING
    `
    
    _, err := db.Exec(query, userID, tagID)
    return err
}
```

## 🎭 SISTEMA DE ROLES INVISIBLES

### Tabla de Roles (Invisible para usuarios)
```sql
CREATE TABLE public.roles (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  permissions JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Roles invisibles (solo para permisos)
INSERT INTO public.roles (name, permissions) VALUES
  ('admin', '{"can_manage_tags": true, "can_manage_users": true}'),
  ('moderator', '{"can_manage_tags": true, "can_manage_users": false}'),
  ('member', '{"can_manage_tags": false, "can_manage_users": false}');
```

### Relación Usuario-Rol (Invisible)
```sql
CREATE TABLE public.user_has_roles (
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  role_id INTEGER REFERENCES public.roles(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  PRIMARY KEY (user_id, role_id)
);
```

### Backend verifica permisos sin exponer roles
```go
func canUserManageTags(userID string) bool {
    var hasPermission bool
    query := `
        SELECT EXISTS (
            SELECT 1 
            FROM user_has_roles uhr
            JOIN roles r ON uhr.role_id = r.id
            WHERE uhr.user_id = $1 
            AND (r.permissions->>'can_manage_tags')::boolean = true
        )
    `
    db.QueryRow(query, userID).Scan(&hasPermission)
    return hasPermission
}
```

## 🎯 FLUJO COMPLETO DE EJEMPLO

### 1. Usuario quiere ver sus tags
```
Frontend → GET /api/tags/me
API Gateway → GET /api/v1/users/{userId}/tags
Core Engine → Query con JOIN de tags + user_has_tags
Response → [{"name": "FAN", "color": "#6366F1", "animation": "member-shine"}]
```

### 2. Admin quiere asignar un tag
```
Frontend → POST /api/tags/assign {tagId: 123}
API Gateway → Valida header x-user-id y permisos
Core Engine → INSERT INTO user_has_tags (user_id, tag_id)
Response → {"status": "success"}
```

### 3. Sistema aplica tag por defecto
```go
func getUserTags(userID string) ([]UserTag, error) {
    tags, err := queryUserTags(userID)
    if err != nil || len(tags) == 0 {
        // Fallback: asignar y retornar tag FAN
        assignTagToUser(userID, 1) // ID 1 = FAN
        return []UserTag{{TagName: "FAN", Color: "#6366F1", Animation: "member-shine"}}, nil
    }
    return tags, nil
}
```

## 🔐 PUNTOS CRÍTICOS DE SEGURIDAD

### ✅ SEGURO
- Frontend solo recibe datos procesados (nombre, color, animación)
- Todos los IDs se manejan internamente en el backend
- Header `x-user-id` para autenticación en cada request
- Validación de permisos en backend antes de cualquier operación
- Default FAN tag para usuarios sin tags

### ❌ NUNCA HACER
- Frontend no debe conocer IDs de tags
- Frontend no debe hacer queries directas a base de datos
- Frontend no debe tener lógica de negocio
- No exponer nombres de roles o permisos
- No permitir operaciones sin validar permisos

## 🚀 VENTAJAS DE ESTA ARQUITECTURA

1. **Seguridad Total**: Frontend nunca ve datos sensibles
2. **Flexibilidad**: Cambiar lógica sin tocar frontend
3. **Performance**: Backend puede optimizar queries
4. **Mantenibilidad**: Separación clara de responsabilidades
5. **Escalabilidad**: Cada capa puede escalar independientemente
6. **Testing**: Cada capa es testeable por separado

## 📊 RESUMEN DE TABLAS

| Tabla | Propósito | Expuesto al Frontend |
|-------|-----------|---------------------|
| `tags` | Tags visibles | ✅ Solo nombre/color/animación |
| `user_has_tags` | Relaciones usuario-tag | ❌ Nunca |
| `roles` | Permisos (invisible) | ❌ Nunca |
| `user_has_roles` | Relaciones usuario-rol | ❌ Nunca |
| `users.user_tags` | Cache de IDs | ❌ Nunca |

Esta arquitectura garantiza que **nada esté expuesto en el frontend** y que todo el manejo de tags sea completamente backend-driven con IDs, exactamente como solicitaste.