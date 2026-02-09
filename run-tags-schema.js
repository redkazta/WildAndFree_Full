#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read the SQL schema file
const schemaPath = path.join(__dirname, 'services/core-engine/database/schema.sql');
const sqlContent = fs.readFileSync(schemaPath, 'utf8');

console.log('📋 SQL Schema Content:');
console.log('='.repeat(50));
console.log(sqlContent);
console.log('='.repeat(50));
console.log('\n🎯 Para ejecutar este SQL en Supabase:');
console.log('1. Ve a tu dashboard de Supabase: https://app.supabase.com');
console.log('2. Selecciona tu proyecto "wild-and-free-web"');
console.log('3. Ve a "SQL Editor" en el menú lateral');
console.log('4. Pega el código SQL de arriba');
console.log('5. Click en "Run"');
console.log('\n📊 El script creará:');
console.log('- Tabla tags (con tag FAN por defecto)');
console.log('- Tabla user_has_tags (relaciones)');
console.log('- Tabla roles (invisibles para permisos)');
console.log('- Tabla user_has_roles (relaciones de roles)');
console.log('- Triggers para mantener consistencia');
console.log('\n✅ El sistema quedará listo para usar con seguridad backend-only!');