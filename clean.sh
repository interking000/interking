#!/bin/bash
set -e

PROJECT_DIR="/root/DTunnel"
CLEAN_SCRIPT="$PROJECT_DIR/ultra-clean-panel.sh"

echo "[+] Configurando limpieza ultra-optimizada del panel..."

# --------------------------
# 1. Crear el script de limpieza
# --------------------------
cat <<'EOF' > "$CLEAN_SCRIPT"
#!/bin/bash
PROJECT_DIR="/root/DTunnel"
NGINX_LOG_DIR="/var/log/nginx"
PM2_LOG_DIR="$HOME/.pm2/logs"

cleanup_all() {
    # --- Panel logs ---
    find "$PROJECT_DIR" -type f -name "*.log" -delete
    find "$PROJECT_DIR" -type f \( -name "*.tmp" -o -name "*.tsbuildinfo" -o -name "*.pid" \) -delete
    [ -d "$PROJECT_DIR/build" ] && rm -rf "$PROJECT_DIR/build"
    [ -d "$PROJECT_DIR/tmp" ] && rm -rf "$PROJECT_DIR/tmp"

    # --- Caché Node ---
    npm cache clean --force > /dev/null 2>&1

    # --- PM2 logs (mantener últimos 5) ---
    if [ -d "$PM2_LOG_DIR" ]; then
        ls -tp "$PM2_LOG_DIR"/*.log 2>/dev/null | grep -v '/$' | tail -n +6 | xargs -r rm --
    fi
    pm2 flush panelweb > /dev/null 2>&1 || true

    # --- Nginx logs (mantener últimos 5 por archivo) ---
    if [ -d "$NGINX_LOG_DIR" ]; then
        for logfile in "$NGINX_LOG_DIR"/*.log*; do
            [ -f "$logfile" ] || continue
            ls -tp "$logfile" 2>/dev/null | grep -v '/$' | tail -n +6 | xargs -r rm --
        done
    fi

    # --- Sistema /tmp ---
    find /tmp -type f -atime +1 -delete
    find /var/tmp -type f -atime +1 -delete
}

# --- Bucle silencioso cada 30s ---
while true; do
    cleanup_all
    sleep 30
done
EOF

# --------------------------
# 2. Dar permisos de ejecución
# --------------------------
chmod +x "$CLEAN_SCRIPT"

# --------------------------
# 3. Instalar PM2 si no existe
# --------------------------
if ! command -v pm2 &> /dev/null; then
    echo "[+] Instalando PM2..."
    npm install -g pm2
fi

# --------------------------
# 4. Iniciar script con PM2
# --------------------------
pm2 start "$CLEAN_SCRIPT" --name ultra-clean-panel
pm2 save

# --------------------------
# 5. Configurar PM2 autoarranque
# --------------------------
STARTUP_CMD=$(pm2 startup | tail -n 1)
eval "$STARTUP_CMD"
pm2 save

echo "[OK] Limpieza ultra-optimizada configurada y corriendo en segundo plano."
