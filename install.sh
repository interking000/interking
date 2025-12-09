#!/bin/bash
set -e

echo "========================================"
echo "      INSTALADOR COMPLETO DTunnel"
echo "========================================"

PROJECT_DIR="/root/DTunnel"
NGINX_DIR="$PROJECT_DIR/nginx"

mkdir -p "$PROJECT_DIR"
mkdir -p "$NGINX_DIR"

# --------------------------
# 1. Instalar dependencias de sistema
# --------------------------
echo "[+] Actualizando sistema..."
apt update -y
apt upgrade -y
apt install -y curl build-essential openssl ufw nginx

# --------------------------
# 2. Instalar Node.js 18 + npm
# --------------------------
echo "[+] Instalando Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "[+] Instalando PM2 globalmente..."
npm install -g pm2

# --------------------------
# 3. Crear .env con claves secretas
# --------------------------
echo "[+] Generando archivo .env..."
DATABASE_PATH="file:./database.db"
CSRF_SECRET=$(openssl rand -hex 16)
JWT_SECRET_KEY=$(openssl rand -hex 32)
JWT_SECRET_REFRESH=$(openssl rand -hex 32)

cat <<EOF > "$PROJECT_DIR/.env"
PORT=8080
NODE_ENV=production
DATABASE_URL=$DATABASE_PATH
CSRF_SECRET=$CSRF_SECRET
JWT_SECRET_KEY=$JWT_SECRET_KEY
JWT_SECRET_REFRESH=$JWT_SECRET_REFRESH
EOF

echo "[OK] .env generado."

# --------------------------
# 4. Eliminar DB vieja si existe
# --------------------------
if [ -f "$PROJECT_DIR/database.db" ]; then
    echo "[+] Eliminando database.db antigua..."
    rm -f "$PROJECT_DIR/database.db"
fi

# --------------------------
# 5. Instalar dependencias del proyecto
# --------------------------
cd "$PROJECT_DIR"
echo "[+] Instalando dependencias del proyecto..."
npm install

# --------------------------
# 6. Prisma DB
# --------------------------
echo "[+] Sincronizando base de datos con Prisma..."
npx prisma db push

# --------------------------
# 7. Build del panel
# --------------------------
echo "[+] Construyendo proyecto..."
npm run build

# --------------------------
# 8. Certificados SSL autofirmados
# --------------------------
if [ ! -f "$NGINX_DIR/fullchain.pem" ] || [ ! -f "$NGINX_DIR/privkey.pem" ]; then
    echo "[+] Generando certificados SSL autofirmados..."
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$NGINX_DIR/privkey.pem" \
        -out "$NGINX_DIR/fullchain.pem" \
        -subj "/C=AR/ST=BuenosAires/L=BA/O=DTunnel/OU=IT/CN=panel.interking.online"
    echo "[OK] Certificados generados."
else
    echo "[OK] Certificados ya existen."
fi

# --------------------------
# 9. Configurar NGINX base (solo ejemplo)
# --------------------------
NGINX_CONF="/etc/nginx/sites-available/dtunnel.conf"

cat <<EOF > $NGINX_CONF
server {
    listen 80;
    server_name panel.interking.online;

    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name panel.interking.online;

    ssl_certificate $NGINX_DIR/fullchain.pem;
    ssl_certificate_key $NGINX_DIR/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

ln -sf $NGINX_CONF /etc/nginx/sites-enabled/dtunnel.conf
nginx -t && systemctl restart nginx

echo "========================================"
echo "   INSTALACIÓN COMPLETA"
echo "========================================"
echo "Archivo .env → $PROJECT_DIR/.env"
echo "Certificados → $NGINX_DIR"
echo "Base de datos → $PROJECT_DIR/database.db"
echo "Usar ./start.sh para iniciar el panel"
