# QuickServe 🚀

Servidor HTTP instantáneo con un solo comando. Comparte archivos locales fácilmente desde cualquier directorio.

## ✨ Características

- **Un comando**: Solo escribe `server` en cualquier directorio
- **Auto-detección de IPs**: Muestra todas tus IPs de red
- **Copia automática de URL**: La URL se copia al portapapeles
- **Puerto automático**: Encuentra puertos libres automáticamente
- **Sin configuración**: Funciona inmediatamente después de instalar

## 📦 Instalación

### Instalación Manual
```bash
git clone https://github.com/GonzaHit/python-sever
cd quickserve
chmod +x setup_server.sh
./setup_server.sh
source ~/.bashrc
```

## 🎯 Uso Básico

```bash
# Navega a cualquier directorio
cd ~/proyectos/mi-app

# Inicia el servidor
server

# Salida:
# 🚀 SERVIDOR HTTP PYTHON
# ================================
# Directorio: /home/usuario/proyectos/mi-app
# 
# ✅ Servidor iniciado exitosamente!
# 📁 Directorio: /home/usuario/proyectos/mi-app
# 🔌 Puerto: 8000
# 
# 🌐 URLs disponibles:
#    Local:  http://localhost:8000
#    Red:    http://192.168.1.100:8000
# 
# 📋 URL copiada al portapapeles
# 
# 🛑 Para detener: Ctrl+C
```

## 🔧 Comandos Adicionales

```bash
# Usar puerto específico
PORT=8080 server

# Verificar versión
server --version

# Mostrar ayuda
server --help
```

## 🚨 Solución Rápida de Problemas

**Puerto ocupado:**
```bash
PORT=9000 server  # Especifica otro puerto
```

**No copia al portapapeles:**
```bash
sudo apt install xclip  # Linux
# o en macOS ya funciona con pbcopy
```

## 📁 Estructura

```
~/.local/bin/
├── python_server.py  # Script principal
└── server            # Wrapper/alias

~/.bashrc
└── alias server='~/.local/bin/server'
```



