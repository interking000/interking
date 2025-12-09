#!/bin/bash
set -e

echo "========================================"
echo "        DETENIENDO PANEL DTunnel"
echo "========================================"

PROJECT_DIR="/root/DTunnel"

cd "$PROJECT_DIR"

# --------------------------
# 1. Detener PM2
# --------------------------
echo "[+] Deteniendo procesos PM2..."
pm2 delete panelweb 2>/dev/null || true
pm2 save

# --------------------------
# 2. Limpiar logs y archivos temporales
# --------------------------
echo "[+] Limpiando logs y archivos temporales..."
find "$PROJECT_DIR" -type f \( \
    -name "*.log" -o \
    -name "*.tmp" -o \
    -name "*.tsbuildinfo" -o \
    -name "*.pid" \
\) -delete

# Limpiar carpeta build, node_modules opcional
# echo "[+] Limpiando carpeta build y node_modules..."
# rm -rf "$PROJECT_DIR/build"
# rm -rf "$PROJECT_DIR/node_modules"

# --------------------------
# 3. Mensaje final
# --------------------------
echo "========================================"
echo "     PANEL DETENIDO Y LIMPIADO"
echo "     Base de datos y .env preservados"
echo "========================================"
