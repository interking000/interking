#!/bin/bash
set -e

echo "========================================"
echo "       INICIANDO PANEL DTunnel"
echo "========================================"

PROJECT_DIR="/root/DTunnel"
PORT=8080

cd "$PROJECT_DIR"

# --------------------------
# 1. Matar procesos PM2 previos
# --------------------------
echo "[+] Eliminando procesos previos..."
pm2 delete panelweb 2>/dev/null || true

# --------------------------
# 2. Limpiar logs y archivos temporales
# --------------------------
echo "[+] Limpiando logs y temporales..."
find "$PROJECT_DIR" -type f \( -name "*.log" -o -name "*.tmp" -o -name "*.tsbuildinfo" \) -delete

# --------------------------
# 3. Iniciar panel con PM2
# --------------------------
echo "[+] Iniciando panel con PM2..."
pm2 start npm --name panelweb -- start
pm2 save

# --------------------------
# 4. Recargar NGINX
# --------------------------
echo "[+] Verificando configuración de NGINX..."
nginx -t && systemctl reload nginx

echo "========================================"
echo "   PANEL LISTO!"
echo "   URL: https://panel.interking.online"
echo "   Logs: pm2 logs panelweb"
echo "========================================"
