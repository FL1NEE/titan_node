#!/bin/bash

# Цвета текста
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Нет цвета (сброс цвета)

# Функция для настройки прокси
setup_proxy() {
    if [ -f /etc/environment ]; then
        echo -e "${BLUE}Настройка прокси из /etc/environment...${NC}"
        source /etc/environment
        export http_proxy=${http_proxy:-}
        export https_proxy=${https_proxy:-}
        export no_proxy=${no_proxy:-}
        echo -e "${GREEN}Прокси настроен: HTTP=$http_proxy, HTTPS=$https_proxy${NC}"
    else
        echo -e "${RED}Файл /etc/environment не найден. Прокси не настроен.${NC}"
    fi
}

# Проверка наличия curl и установка, если не установлен
if ! command -v curl &> /dev/null; then
    echo -e "${BLUE}Установка curl...${NC}"
    sudo apt update
    sudo apt install curl -y
fi

# Настройка прокси
setup_proxy

# Проверка ProxyChains
if ! command -v proxychains &> /dev/null; then
    echo -e "${BLUE}Установка ProxyChains...${NC}"
    sudo apt update
    sudo apt install proxychains -y
fi

# Проверка Docker
if command -v docker &> /dev/null; then
    echo -e "${GREEN}Docker уже установлен. Пропускаем установку.${NC}"
else
    echo -e "${BLUE}Устанавливаем Docker...${NC}"
    sudo apt remove -y docker docker-engine docker.io containerd runc
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common lsb-release gnupg2
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io
    echo -e "${GREEN}Docker успешно установлен!${NC}"
fi

# Проверка занятости порта 1234
if sudo netstat -tuln | grep -q ':1234'; then
    echo -e "${RED}Порт 1234 уже занят. Пожалуйста, освободите пор
