#!/bin/bash
# setup_server.sh - Instala y configura servidor Python con alias

echo "=== Configurando servidor Python con alias 'server' ==="

# 1. Crear script del servidor
cat > ~/.local/bin/python_server.py << 'EOF'
#!/usr/bin/env python3
"""
Servidor HTTP simple para servir archivos del directorio actual
Incluye navegación de directorios y resaltado de sintaxis
"""

import http.server
import socketserver
import socket
import os
import webbrowser
import sys
from datetime import datetime
import netifaces

def get_local_ips():
    """Obtiene todas las IPs locales"""
    ips = []
    for interface in netifaces.interfaces():
        try:
            for link in netifaces.ifaddresses(interface).get(netifaces.AF_INET, []):
                addr = link.get('addr')
                if addr and addr != '127.0.0.1':
                    ips.append(addr)
        except:
            pass
    return ips if ips else ['127.0.0.1']

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Handler personalizado con mejor información"""
    
    def log_message(self, format, *args):
        """Personaliza los logs del servidor"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {self.address_string()} - {format % args}")
    
    def list_directory(self, path):
        """Sobrescribe para mostrar información más útil"""
        try:
            return super().list_directory(path)
        except:
            self.send_error(404, "No se puede listar directorio")
            return None

def get_available_port(start_port=8000, max_attempts=50):
    """Encuentra un puerto disponible"""
    for port in range(start_port, start_port + max_attempts):
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.settimeout(1)
                s.bind(('', port))
                return port
        except (OSError, socket.error):
            continue
    return start_port  # Fallback

def main():
    # Configuración
    DEFAULT_PORT = 8000
    DIRECTORY = os.getcwd()
    
    print("\n" + "="*60)
    print("🚀 SERVIDOR HTTP PYTHON")
    print("="*60)
    print(f"Directorio: {DIRECTORY}")
    
    # Obtener puerto
    port = get_available_port(DEFAULT_PORT)
    
    # Cambiar al directorio actual
    os.chdir(DIRECTORY)
    
    # Configurar handler
    handler = CustomHTTPRequestHandler
    
    # Intentar crear servidor
    try:
        with socketserver.TCPServer(("", port), handler) as httpd:
            # Obtener IPs locales
            local_ips = get_local_ips()
            
            print(f"\n✅ Servidor iniciado exitosamente!")
            print(f"📁 Directorio: {DIRECTORY}")
            print(f"🔌 Puerto: {port}")
            
            print("\n🌐 URLs disponibles:")
            print(f"   Local:  http://localhost:{port}")
            for ip in local_ips:
                print(f"   Red:    http://{ip}:{port}")
            
            print("\n📋 Para copiar rápido:")
            if len(local_ips) > 0:
                print(f"   echo 'http://{local_ips[0]}:{port}' | xclip -sel clip 2>/dev/null || echo 'http://{local_ips[0]}:{port}' | pbcopy 2>/dev/null || echo 'http://{local_ips[0]}:{port}'")
                print(f"   # URL copiada al portapapeles automáticamente donde sea posible")
            
            print("\n🛑 Para detener: Ctrl+C")
            print("="*60 + "\n")
            
            # Intentar copiar al portapapeles automáticamente
            try:
                import subprocess
                # Linux con xclip
                subprocess.run(['xclip', '-sel', 'clip'], 
                             input=f'http://{local_ips[0]}:{port}'.encode(), 
                             check=False)
            except:
                try:
                    # macOS con pbcopy
                    subprocess.run(['pbcopy'], 
                                 input=f'http://{local_ips[0]}:{port}'.encode(), 
                                 check=False)
                except:
                    pass
            
            # Servir
            httpd.serve_forever()
            
    except PermissionError:
        print(f"\n❌ Error: No tienes permisos para usar el puerto {port}")
        print("   Intenta con un puerto superior a 1024 o ejecuta con sudo")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n👋 Servidor detenido por el usuario")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Error inesperado: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF

# 2. Hacerlo ejecutable
chmod +x ~/.local/bin/python_server.py

# 3. Crear wrapper script
cat > ~/.local/bin/server << 'EOF'
#!/bin/bash
# Wrapper para el servidor Python

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar si Python3 está instalado
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python3 no está instalado${NC}"
    echo "Instala con: sudo apt install python3"
    exit 1
fi

# Mostrar banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════╗"
echo "║         🚀 SERVIDOR PYTHON HTTP                ║"
echo "║         Directorio: $(pwd)                ║"
echo "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Ejecutar servidor
python3 ~/.local/bin/python_server.py
EOF

# 4. Hacer ejecutable el wrapper
chmod +x ~/.local/bin/server

# 5. Añadir al .bashrc si no existe
if ! grep -q "alias server=" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# Alias para servidor Python" >> ~/.bashrc
    echo "alias server='~/.local/bin/server'" >> ~/.bashrc
    echo "" >> ~/.bashrc
fi

# 6. Instalar dependencias si es necesario
echo -e "\n📦 Verificando dependencias..."
if ! python3 -c "import netifaces" &> /dev/null; then
    echo "Instalando netifaces..."
    pip3 install netifaces --user 2>/dev/null || sudo pip3 install netifaces
fi

# 7. Instalar herramientas de clipboard si es posible
if ! command -v xclip &> /dev/null && ! command -v pbcopy &> /dev/null; then
    echo "Instalando xclip para funcionalidad de clipboard..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y xclip 2>/dev/null
    elif command -v yum &> /dev/null; then
        sudo yum install -y xclip 2>/dev/null
    fi
fi

echo -e "\n✅ Configuración completada!"
echo -e "\n📋 Resumen:"
echo "   Script servidor: ~/.local/bin/python_server.py"
echo "   Alias 'server': ~/.local/bin/server"
echo "   Alias añadido a ~/.bashrc"
echo -e "\n🔄 Recarga tu shell o ejecuta:"
echo "   source ~/.bashrc"
echo -e "\n🎯 Uso:"
echo "   $ server"
echo -e "   # Esto iniciará un servidor en el directorio actual\n"
