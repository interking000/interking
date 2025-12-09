#!/bin/bash

echo "========================================"
echo "       INICIANDO PANEL DTunnel"
echo "========================================"

PROJECT_DIR="/root/DTunnel"
NGINX_CONF="/etc/nginx/sites-enabled/dtunnel.conf"
PORT=${PORT:-8080}  # Asegúrate de que coincida con tu .env

cd $PROJECT_DIR

# ----------------------------------------
# 1. Matar procesos previos de PM2 y puertos
# ----------------------------------------
echo "[+] Matando procesos PM2 previos..."
pm2 delete panelweb 2>/dev/null

echo "[+] Matando procesos que usen el puerto $PORT..."
fuser -k $PORT/tcp 2>/dev/null || true

# ----------------------------------------
# 2. Limpiar archivos basura y logs
# ----------------------------------------
cleanup() {
    echo "[+] Limpiando archivos temporales y logs..."
    find $PROJECT_DIR -type f \( -name "*.log" -o -name "*.tmp" -o -name "*.tsbuildinfo" \) -delete
    echo "[OK] Limpieza completa."
}

# Primer limpieza inmediata
cleanup

# Limpieza automática cada 30 segundos en background
(
while true; do
    sleep 30
    cleanup
done
) &

# ----------------------------------------
# 3. Iniciar panel con PM2
# ----------------------------------------
echo "[+] Iniciando panel con PM2..."
pm2 start "npm start" --name panelweb
pm2 save

# ----------------------------------------
# 4. Verificar y recargar NGINX
# ----------------------------------------
echo "[+] Verificando configuración de NGINX..."
nginx -t

if [ $? -eq 0 ]; then
    echo "[OK] Configuración válida, recargando NGINX..."
    systemctl reload nginx
else
    echo "[ERROR] La configuración de NGINX tiene errores."
fi

echo "========================================"
echo "   PANEL LISTO!"
echo "   URL: https://panel.interking.online"
echo "   Logs: pm2 logs panelweb"
echo "========================================"