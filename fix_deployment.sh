#!/bin/bash

# Script de Solución Rápida - Error de Despliegue TomEE
# Oh Hell! API - UPV

echo "🔧 Solucionando Error de Despliegue..."
echo ""

# Variables
PROJECT_DIR="/home/tommy/Programacion/CURSOS/Java/OhHellAPI"
TOMEE_DIR="/home/tommy/Programacion/servidores/apache-tomee-webprofile-10.1.2"
WEBAPPS_DIR="$TOMEE_DIR/webapps"

# Paso 1: Verificar rutas
echo "📁 Verificando rutas del proyecto..."
if [ ! -d "$PROJECT_DIR" ]; then
    echo "❌ ERROR: No se encuentra el directorio del proyecto: $PROJECT_DIR"
    exit 1
fi

if [ ! -d "$TOMEE_DIR" ]; then
    echo "❌ ERROR: No se encuentra TomEE en: $TOMEE_DIR"
    exit 1
fi

echo "✓ Rutas verificadas"
echo ""

# Paso 2: Limpiar despliegues anteriores
echo "🧹 Limpiando despliegues anteriores..."
rm -rf "$WEBAPPS_DIR/OhHellAPI"
rm -f "$WEBAPPS_DIR/OhHellAPI.war"
rm -rf "$PROJECT_DIR/out/artifacts"
echo "✓ Limpieza completada"
echo ""

# Paso 3: Crear estructura de directorios
echo "📦 Creando estructura de WAR..."
WAR_DIR="$PROJECT_DIR/out/artifacts/OhHellAPI_war_exploded"
mkdir -p "$WAR_DIR/WEB-INF/classes"
mkdir -p "$WAR_DIR/WEB-INF/lib"
echo "✓ Estructura creada"
echo ""

# Paso 4: Copiar clases compiladas
echo "📋 Copiando clases compiladas..."
if [ -d "$PROJECT_DIR/out/production/OhHellAPI" ]; then
    cp -r "$PROJECT_DIR/out/production/OhHellAPI/"* "$WAR_DIR/WEB-INF/classes/"
    echo "✓ Clases copiadas"
else
    echo "⚠️  No se encontraron clases compiladas. Compila el proyecto primero en IntelliJ:"
    echo "   Build → Rebuild Project"
    exit 1
fi
echo ""

# Paso 5: Copiar PostgreSQL driver
echo "🔌 Buscando PostgreSQL JDBC driver..."
POSTGRES_JAR=$(find ~/.m2/repository/org/postgresql/postgresql -name "*.jar" 2>/dev/null | head -1)
if [ -n "$POSTGRES_JAR" ]; then
    cp "$POSTGRES_JAR" "$WAR_DIR/WEB-INF/lib/"
    echo "✓ Driver PostgreSQL copiado"
else
    echo "⚠️  No se encontró el driver PostgreSQL en Maven local"
    echo "   Descárgalo de: https://jdbc.postgresql.org/download/"
    echo "   Y cópialo a: $WAR_DIR/WEB-INF/lib/"
fi
echo ""

# Paso 6: Crear web.xml si no existe
echo "📝 Verificando web.xml..."
if [ ! -f "$WAR_DIR/WEB-INF/web.xml" ]; then
    cat > "$WAR_DIR/WEB-INF/web.xml" << 'WEBXML'
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee 
         https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
         version="6.0">
    
    <display-name>Oh Hell! API</display-name>
    
    <servlet>
        <servlet-name>jersey</servlet-name>
        <servlet-class>org.glassfish.jersey.servlet.ServletContainer</servlet-class>
        <init-param>
            <param-name>jersey.config.server.provider.packages</param-name>
            <param-value>com.ohhell.ohhellapi.resources</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>
    
    <servlet-mapping>
        <servlet-name>jersey</servlet-name>
        <url-pattern>/api/*</url-pattern>
    </servlet-mapping>
</web-app>
WEBXML
    echo "✓ web.xml creado"
else
    echo "✓ web.xml existe"
fi
echo ""

# Paso 7: Copiar contenido estático si existe
echo "🌐 Copiando archivos estáticos..."
if [ -d "$PROJECT_DIR/src/main/webapp" ]; then
    cp -r "$PROJECT_DIR/src/main/webapp/"* "$WAR_DIR/" 2>/dev/null || true
elif [ -d "$PROJECT_DIR/web" ]; then
    cp -r "$PROJECT_DIR/web/"* "$WAR_DIR/" 2>/dev/null || true
fi
echo "✓ Archivos estáticos copiados"
echo ""

# Paso 8: Copiar todo al webapps de TomEE
echo "🚀 Desplegando en TomEE..."
cp -r "$WAR_DIR" "$WEBAPPS_DIR/OhHellAPI"
echo "✓ Aplicación desplegada"
echo ""

# Paso 9: Instrucciones finales
echo "=========================================="
echo "✅ DESPLIEGUE COMPLETADO"
echo "=========================================="
echo ""
echo "Ahora sigue estos pasos:"
echo ""
echo "1. En IntelliJ, DETÉN el servidor TomEE si está corriendo"
echo ""
echo "2. Ve a Run → Edit Configurations..."
echo ""
echo "3. En la pestaña 'Deployment':"
echo "   - ELIMINA el artefacto actual"
echo "   - Haz click en '+' → 'External Source'"
echo "   - Selecciona: $WEBAPPS_DIR/OhHellAPI"
echo "   - Application context: /OhHellAPI"
echo ""
echo "4. Guarda y ejecuta Run → Run 'TomEE'"
echo ""
echo "5. Prueba el endpoint:"
echo "   curl http://localhost:8080/OhHellAPI/api/v1/hello"
echo ""
echo "=========================================="
