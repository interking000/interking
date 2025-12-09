#!/bin/bash

echo "========================================"
echo "      INSTALADOR COMPLETO DTunnel"
echo "========================================"

PROJECT_DIR="/root/DTunnel"
NGINX_DIR="$PROJECT_DIR/nginx"

# ----------------------------------------
# 1. Crear .env si no existe
# ----------------------------------------
if [ -f "$PROJECT_DIR/.env" ]; then
    echo "[OK] .env ya existe — No se modificará."
else
    echo "[+] Creando archivo .env..."

    read -p "Puerto del panel (ej: 8080): " PORT
    PORT=${PORT:-3000}

    read -p "Usuario administrador: " ADMIN_USER
    read -p "Password administrador: " ADMIN_PASSWORD

    # Claves generadas automáticamente
    JWT_SECRET=$(openssl rand -hex 32)
    JWT_SECRET_REFRESH=$(openssl rand -hex 32)
    CSRF_SECRET=$(openssl rand -hex 16)

    cat <<EOF > "$PROJECT_DIR/.env"
PORT=${PORT}
NODE_ENV=production

JWT_SECRET_KEY=${JWT_SECRET}
JWT_SECRET_REFRESH=${JWT_SECRET_REFRESH}
CSRF_SECRET=${CSRF_SECRET}
EOF

    echo "[OK] Archivo .env generado correctamente."
fi

cd "$PROJECT_DIR"

# ----------------------------------------
# 2. Actualizar sistema
# ----------------------------------------
echo "[+] Actualizando sistema..."
apt update -y
apt upgrade -y

# ----------------------------------------
# 3. Instalar Node.js + PM2
# ----------------------------------------
echo "[+] Instalando Node.js 18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "[+] Instalando PM2 globalmente..."
npm install -g pm2

# ----------------------------------------
# 4. Instalar dependencias del panel
# ----------------------------------------
echo "[+] Instalando dependencias del proyecto..."
npm install

# ----------------------------------------
# 5. Prisma
# ----------------------------------------
echo "[+] Sincronizando base de datos Prisma..."
npx prisma db push

# ----------------------------------------
# 6. Build del panel
# ----------------------------------------
echo "[+] Construyendo proyecto..."
npm run build

# ----------------------------------------
# 7. Generar certificados autofirmados si no existen
# ----------------------------------------
if [ ! -f "$NGINX_DIR/fullchain.pem" ] || [ ! -f "$NGINX_DIR/privkey.pem" ]; then
    echo "[+] Generando certificados SSL autofirmados..."

    openssl req -x509 -nodes -days 365 \
      -newkey rsa:2048 \
      -keyout "$NGINX_DIR/privkey.pem" \
      -out "$NGINX_DIR/fullchain.pem" \
      -subj "/C=AR/ST=BuenosAires/L=BA/O=DTunnel/OU=IT/CN=panel.interking.online"

    echo "[OK] Certificados generados y copiados en $NGINX_DIR"
else
    echo "[OK] Certificados ya existen en $NGINX_DIR — No se sobrescriben."
fi

echo "========================================"
echo "   Instalación Completa de DTunnel"
echo "========================================"
echo "  - Panel listo → usar ./start.sh"
echo "  - Certificados → $NGINX_DIR"
echo "  - Archivo .env → $PROJECT_DIR/.env"
echo "========================================"