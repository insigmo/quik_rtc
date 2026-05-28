#!/usr/bin/env fish

echo "🔧 olcrtc setup — генерация конфигов"
echo ""

# --- Генерация криптографических значений ---
set ROOM_ID    (openssl rand -hex 6)
set CRYPTO_KEY (openssl rand -hex 32)   # 64 hex-символа — требование olcrtc

# --- Выбор рабочего Jitsi-сервера ---
set JITSI_HOST ""
set JITSI_CANDIDATES meet1.arbitr.ru meet.cryptopro.ru meet.jit.si

echo "🌐 Проверка доступных Jitsi-серверов..."
for host in $JITSI_CANDIDATES
    if curl -sf --max-time 5 "https://$host/" > /dev/null 2>&1
        set JITSI_HOST $host
        echo "   ✅ $host — доступен"
        break
    else
        echo "   ❌ $host — недоступен"
    end
end

if test -z "$JITSI_HOST"
    echo ""
    echo "⚠️  Ни один Jitsi-сервер не ответил."
    echo "   Вставь хост вручную: замени значение room.id в server.yaml и client.yaml"
    set JITSI_HOST "meet1.arbitr.ru"
else
    echo "   → Выбран: $JITSI_HOST"
end

set ROOM_URL "https://$JITSI_HOST/$ROOM_ID"

# --- server.yaml ---
printf 'mode: srv
auth:
  provider: jitsi
room:
  id: "%s"
crypto:
  key: "%s"
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
' $ROOM_URL $CRYPTO_KEY > server.yaml

# --- client.yaml ---
printf 'mode: cnc
auth:
  provider: jitsi
room:
  id: "%s"
crypto:
  key: "%s"
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
' $ROOM_URL $CRYPTO_KEY > client.yaml

mkdir -p data

echo ""
echo "✅ Готово! Созданы файлы:"
echo "   server.yaml"
echo "   client.yaml"
echo "   data/"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ROOM URL:   $ROOM_URL"
echo "  CRYPTO KEY: $CRYPTO_KEY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Запуск:"
echo "  Сервер:  olcrtc server.yaml"
echo "  Клиент:  olcrtc client.yaml"
echo ""
echo "SOCKS5 на клиенте слушает 127.0.0.1:8998"
