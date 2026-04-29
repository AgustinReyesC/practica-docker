#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'


loading() {
    local message=$1
    local duration=$2
    local pid=$3

    local elapsed=0
    local interval=0.3
    local dot_count=0
    local max_dots=10

    while kill -0 "$pid" 2>/dev/null; do
        local percent=$(( elapsed * 100 / duration ))
        [ "$percent" -gt 95 ] && percent=95

        local dots=""
        for ((i=0; i<dot_count; i++)); do dots+="."; done
        local spaces=""
        for ((i=dot_count; i<max_dots; i++)); do spaces+=" "; done

        printf "\r  ${CYAN}%s${NC} [${YELLOW}%-10s${NC}] ${GREEN}%3d%%${NC}" \
            "$message" "$dots$spaces" "$percent"

        dot_count=$(( (dot_count + 1) % (max_dots + 1) ))
        elapsed=$(echo "$elapsed + $interval" | bc)
        sleep "$interval"
    done

    wait "$pid"
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r  ${CYAN}%s${NC} [${GREEN}..........${NC}] ${GREEN}100%% ✔${NC}\n" "$message"
    else
        printf "\r  ${CYAN}%s${NC} [${RED}..........${NC}] ${RED}FAILED ✘${NC}\n" "$message"
        echo -e "\n${RED}── Error log ────────────────────────────────────${NC}"
        cat /tmp/deploy_step.log
        echo -e "${RED}─────────────────────────────────────────────────${NC}\n"
        exit 1
    fi
}



run_step() {
    local message=$1
    local duration=$2
    shift 2
    # Todo lo que queda son el comando + sus argumentos
    "$@" > /tmp/deploy_step.log 2>&1 &
    loading "$message" "$duration" $!
}





# ─── DESPLIEGUE ───────────────────────────────────────────────────────────────

echo -e "\n${BOLD}🚀 Iniciando despliegue$(date +'  %d/%m/%Y %H:%M:%S')${NC}\n"

# 1. Pull de GitHub
run_step "Pulling desde GitHub     " 15 \
    git pull origin main

# 2. Bajar contenedores viejos
run_step "Bajando contenedores     " 20 \
    docker compose -f docker-compose.prod.yml down

# 3. Build y levantar
run_step "Levantando contenedores  " 120 \
    docker compose -f docker-compose.prod.yml up -d --build

echo -e "\n${GREEN}${BOLD}  ✔ Despliegue completado$(date +'  %d/%m/%Y %H:%M:%S')${NC}\n"





#traer de git
git pull origin main

#tumbar contenedores
docker compose down

#levantar contenedores
echo "levantando contenedores..."



docker compose -f docker-compose.prod.yml up -d --build

echo "