#!/usr/bin/env bash
set -euo pipefail

echo "🔧 olcrtc setup — генерация конфигов"
echo ""

# --- Генерация криптографических значений ---
ROOM_ID=$(openssl rand -hex 6)
CRYPTO_KEY=$(openssl rand -hex 32)   # 64 hex-символа — требование olcrtc

# --- Выбор рабочего Jitsi-сервера ---
JITSI_HOST=""
JITSI_CANDIDATES=(meet1.arbitr.ru meet.cryptopro.ru meet.jit.si)

echo "🌐 Проверка доступных Jitsi-серверов..."
for host in "${JITSI_CANDIDATES[@]}"; do
    if curl -sf --max-time 5 "https://$host/" > /dev/null 2>&1; then
        JITSI_HOST="$host"
        echo "   ✅ $host — доступен"
        break
    else
        echo "   ❌ $host — недоступен"
    fi
done

if [[ -z "$JITSI_HOST" ]]; then
    echo ""
    echo "⚠️  Ни один Jitsi-сервер не ответил."
    echo "   Вставь хост вручную: замени значение room.id в server.yaml и client.yaml"
    JITSI_HOST="meet1.arbitr.ru"
else
    echo "   → Выбран: $JITSI_HOST"
fi

ROOM_URL="https://$JITSI_HOST/$ROOM_ID"

# --- server.yaml ---
cat > server.yaml <<EOF
mode: srv
auth:
  provider: jitsi
room:
  id: "${ROOM_URL}"
crypto:
  key: "${CRYPTO_KEY}"
net:
  transport: datachannel
  dns: "8.8.8.8:53"
liveness:
  interval: 10s
  timeout: 5s
  failures: 3
lifecycle:
  max_session_duration: 6h
data: data
EOF

# --- client.yaml ---
cat > client.yaml <<EOF
mode: cnc
auth:
  provider: jitsi
room:
  id: "${ROOM_URL}"
crypto:
  key: "${CRYPTO_KEY}"
net:
  transport: datachannel
  dns: "8.8.8.8:53"
socks:
  host: "127.0.0.1"
  port: 8998
liveness:
  interval: 10s
  timeout: 5s
  failures: 3
lifecycle:
  max_session_duration: 6h
data: data
EOF

mkdir -p data

echo ""
echo "✅ Готово!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ROOM URL:   $ROOM_URL"
echo "  CRYPTO KEY: $CRYPTO_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "SOCKS5 на клиенте слушает 127.0.0.1:8998"