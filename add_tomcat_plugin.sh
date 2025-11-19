#!/bin/bash

POM_FILE="$HOME/Programacion/CURSOS/Java/OhHellAPI/pom.xml"

echo "🔧 Añadiendo Tomcat Maven Plugin al pom.xml..."

# Verificar que el archivo existe
if [ ! -f "$POM_FILE" ]; then
    echo "❌ Error: No se encuentra pom.xml en $POM_FILE"
    exit 1
fi

# Backup del pom.xml original
cp "$POM_FILE" "$POM_FILE.backup"
echo "📦 Backup creado: pom.xml.backup"

# Verificar si ya existe el plugin
if grep -q "tomcat7-maven-plugin" "$POM_FILE"; then
    echo "✅ El plugin Tomcat ya está configurado"
    exit 0
fi

# Buscar la sección </plugins> y añadir el plugin antes de ella
cat > /tmp/tomcat_plugin.xml << 'PLUGIN_EOF'
            <plugin>
                <groupId>org.apache.tomcat.maven</groupId>
                <artifactId>tomcat7-maven-plugin</artifactId>
                <version>2.2</version>
                <configuration>
                    <path>/api</path>
                    <port>8080</port>
                    <useTestClasspath>false</useTestClasspath>
                </configuration>
            </plugin>
PLUGIN_EOF

# Insertar el plugin antes del cierre de </plugins>
awk '
    /<\/plugins>/ {
        while ((getline line < "/tmp/tomcat_plugin.xml") > 0) {
            print line
        }
        close("/tmp/tomcat_plugin.xml")
    }
    {print}
' "$POM_FILE" > /tmp/pom_new.xml

# Reemplazar el archivo original
mv /tmp/pom_new.xml "$POM_FILE"
rm /tmp/tomcat_plugin.xml

echo "✅ Plugin Tomcat añadido exitosamente"
echo ""
echo "Ahora puedes ejecutar:"
echo "  ./mvnw tomcat7:run"
echo ""
echo "La API estará disponible en:"
echo "  http://localhost:8080/api/v1/players"
echo ""
echo "Si algo sale mal, restaura el backup:"
echo "  cp pom.xml.backup pom.xml"
