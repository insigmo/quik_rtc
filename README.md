## Сборка и запуск через Docker Compose
### Bash
```bash
ROOM_ID=$(openssl rand -hex 6)        # 12 hex символов
CLIENT_ID=$(openssl rand -hex 6)
ENCRYPTION_KEY=$(openssl rand -hex 16) # 32 hex символа

cat > .env <<EOF
ROOM_ID=${ROOM_ID}
CLIENT_ID=${CLIENT_ID}
ENCRYPTION_KEY=${ENCRYPTION_KEY}

# Остальные настройки под olcrtc:
CARRIER=jitsi
TRANSPORT=datachannel
LISTEN_ADDR=:8443
EOF

echo ".env сгенерирован:"
cat .env
```


### FISH
```shell
set ROOM_ID       (openssl rand -hex 6)
set CLIENT_ID     (openssl rand -hex 6)
set ENCRYPTION_KEY (openssl rand -hex 16)

printf "ROOM_ID=%s
CLIENT_ID=%s
ENCRYPTION_KEY=%s

# Остальные настройки под olcrtc:
CARRIER=jitsi
TRANSPORT=datachannel
LISTEN_ADDR=:8443
" $ROOM_ID $CLIENT_ID $ENCRYPTION_KEY > .env

echo ".env сгенерирован:"
cat .env
```