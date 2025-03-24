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

# Проверка Docker Compose
if command -v docker-compose &> /dev/null; then
    echo -e "${GREEN}Docker Compose уже установлен. Пропускаем установку.${NC}"
else
    echo -e "${BLUE}Устанавливаем Docker Compose...${NC}"
    VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
    sudo curl -L "https://github.com/docker/compose/releases/download/$VER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose успешно установлен!${NC}"
fi

# Добавление пользователя в группу Docker
if ! groups $USER | grep -q '\bdocker\b'; then
    echo -e "${BLUE}Добавляем текущего пользователя в группу Docker...${NC}"
    sudo groupadd docker
    sudo usermod -aG docker $USER
else
    echo -e "${GREEN}Пользователь уже находится в группе Docker.${NC}"
fi

# Загрузка Docker-образа Titan
echo -e "${BLUE}Загружаем Docker-образ Titan...${NC}"
docker pull nezha123/titan-edge

# Создание директории Titan
mkdir -p ~/.titanedge

# Запуск Titan
echo -e "${BLUE}Запускаем контейнер Titan...${NC}"
docker run --name titan --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge

# Привязка кода идентификации
echo -e "${YELLOW}Введите ваш Titan identity code:${NC}"
read identity_code
docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash="$identity_code" https://api-test1.container1.titannet.io/api/v2/device/binding

# Заключительный вывод
echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Команда для проверки логов:${NC}"
echo "docker logs -f titan"
echo -e "${PURPLE}-----------------------------------------------------------------------${NC}"
echo -e "${GREEN}CRYPTO FORTOCHKA — вся крипта в одном месте!${NC}"
echo -e "${CYAN}Наш Telegram https://t.me/cryptoforto${NC}"

# Проверка логов
docker logs -f titan
