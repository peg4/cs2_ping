#!/bin/bash

# Проверка зависимостей
for dep in jq dig curl bc traceroute; do
    if ! command -v "$dep" &> /dev/null; then
        echo "Ошибка: утилита '$dep' не установлена."
        exit 1
    fi
done

# Города
declare -A EU_POPs=(
    ["vie"]="Vienna"
    ["fra"]="Frankfurt"
    ["ams"]="Amsterdam"
    ["sto"]="Stockholm"
    ["mad"]="Madrid"
    ["lhr"]="London"
    ["waw"]="Warsaw"
    ["hel"]="Helsinki"
    ["par"]="Paris"
)

TMP_FILE=$(mktemp)
cleanup() { rm -f "$TMP_FILE" "$TMP_FILE.sorted"; }
trap cleanup EXIT

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
GRAY='\033[1;30m'
RESET='\033[0m'

colorize_ping() {
    local val=$1
    local pad_width=8
    local output
    if ! [[ "$val" =~ ^[0-9.]+$ ]]; then
        output=$(printf "%-${pad_width}s" "$val")
        echo -e "${GRAY}$output${RESET}"
    elif (( $(echo "$val < 30" | bc -l) )); then
        output=$(printf "%-${pad_width}s" "$val")
        echo -e "${GREEN}$output${RESET}"
    elif (( $(echo "$val < 60" | bc -l) )); then
        output=$(printf "%-${pad_width}s" "$val")
        echo -e "${YELLOW}$output${RESET}"
    else
        output=$(printf "%-${pad_width}s" "$val")
        echo -e "${RED}$output${RESET}"
    fi
}

ping_ip() {
    local city=$1
    local ip=$2
    local result
    result=$(ping -c 3 -q "$ip" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        local avg=$(echo "$result" | grep 'rtt' | cut -d '/' -f 5)
        echo "$city $ip OK $avg" >> "$TMP_FILE"
    else
        echo "$city $ip FAIL -" >> "$TMP_FILE"
    fi
}

print_results() {
    declare -A city_data
    declare -a valid_cities=()

    for city in "$@"; do
        total=$(grep "^$city " "$TMP_FILE" | wc -l)
        [[ "$total" -eq 0 ]] && continue
        ok=$(grep "^$city " "$TMP_FILE" | grep "OK" | wc -l)
        sum=$(grep "^$city " "$TMP_FILE" | grep "OK" | awk '{sum += $4} END {print sum + 0}')

        if [[ "$ok" -gt 0 ]]; then
            avg=$(echo "scale=2; $sum / $ok" | bc)
        else
            avg="NaN"
        fi

        city_data["$city"]="$total|$ok|$avg"
        valid_cities+=("$city")
    done

    sorted_cities=$(for city in "${valid_cities[@]}"; do
        IFS='|' read -r total ok avg <<< "${city_data[$city]}"
        [[ "$avg" == "NaN" ]] && continue
        echo "$avg $city"
    done | sort -n | awk '{print $2}')

    for city in "${valid_cities[@]}"; do
        if [[ "${city_data[$city]}" == *"NaN" ]]; then
            sorted_cities+=$'\n'"$city"
        fi
    done

    printf "\n%-12s %-10s %-10s %-15s\n" "City" "Total IPs" "OK" "Avg Latency"
    printf "%-12s %-10s %-10s %-15s\n" "------------" "---------" "---------" "-------------"

    while IFS= read -r city; do
        IFS='|' read -r total ok avg <<< "${city_data[$city]}"
        color_avg=$(colorize_ping "$avg")
        printf "%-12s %-10s %-10s %-15b\n" "$city" "$total" "$ok" "$color_avg"
    done <<< "$sorted_cities"
}

run_traceroute() {
    local ip=$1
    local city=$2
    echo -e "${CYAN}Трассировка до $ip ($city)${RESET}"
    mapfile -t lines < <(traceroute -q 3 -n "$ip" 2>/dev/null | tail -n +2)

    dns_names=()
    ip_addrs=()
    geos=()
    max_dns_len=30
    max_ip_len=12
    max_geo_len=28

    for line in "${lines[@]}"; do
        hop_ip=$(echo "$line" | awk '{print $2}')
        if [[ "$hop_ip" == "*" || -z "$hop_ip" ]]; then
            dns_names+=("*")
            ip_addrs+=("*")
            geos+=("-")
        else
            dns=$(dig +short -x "$hop_ip" | sed 's/\.$//')
            [[ -z "$dns" ]] && dns="$hop_ip"
            dns_names+=("$dns")
            ip_addrs+=("$hop_ip")

            geo=$(curl -s "https://ipinfo.io/$hop_ip" | jq -r '.city, .country, .org' | paste -sd ', ' -)
            [[ -z "$geo" || "$geo" == ", ," ]] && geo="-"
            geos+=("$geo")

            (( ${#dns} > max_dns_len )) && max_dns_len=${#dns}
            (( ${#hop_ip} > max_ip_len )) && max_ip_len=${#hop_ip}
            (( ${#geo} > max_geo_len )) && max_geo_len=${#geo}
        fi
    done

    local sep_dns=$(printf '─%.0s' $(seq 1 "$max_dns_len"))
    local sep_ip=$(printf '─%.0s' $(seq 1 "$max_ip_len"))
    local sep_geo=$(printf '─%.0s' $(seq 1 "$max_geo_len"))

    printf "\n┌────┬-%s-┬-%s-┬──────────┬──────────┬──────────┬-%s-┐\n" "$sep_dns" "$sep_ip" "$sep_geo"
    printf "│ %-2s │ %-*s │ %-*s │ %-8s │ %-8s │ %-8s │ %-*s │\n" "Хоп" "$max_dns_len" "DNS" "$max_ip_len" "IP" "Пинг #1" "Пинг #2" "Пинг #3" "$max_geo_len" "Геолокация"
    printf "├────┼-%s-┼-%s-┼──────────┼──────────┼──────────┼-%s-┤\n" "$sep_dns" "$sep_ip" "$sep_geo"

    for i in "${!lines[@]}"; do
        hop_num=$(echo "${lines[$i]}" | awk '{print $1}')
        dns="${dns_names[$i]}"
        ip="${ip_addrs[$i]}"
        geo="${geos[$i]}"

        line="${lines[$i]}"
        rtts=($(echo "$line" | grep -oE '[0-9]+\.[0-9]+ ms' | sed 's/ ms//'))
        cp1=$(colorize_ping "${rtts[0]:--}")
        cp2=$(colorize_ping "${rtts[1]:--}")
        cp3=$(colorize_ping "${rtts[2]:--}")

        printf "│ %-2s │ %-*s │ %-*s │ %-8b │ %-8b │ %-8b │ %-*s │\n" "$hop_num" "$max_dns_len" "$dns" "$max_ip_len" "$ip" "$cp1" "$cp2" "$cp3" "$max_geo_len" "$geo"
    done

    printf "└────┴-%s-┴-%s-┴──────────┴──────────┴──────────┴-%s-┘\n\n" "$sep_dns" "$sep_ip" "$sep_geo"
}

json=$(curl -s "https://api.steampowered.com/ISteamApps/GetSDRConfig/v1?appid=730")

echo -e "\nВыберите режим:"
echo "1) Пинг всех европейских серверов"
echo "2) Пинг по выбранному городу"
echo "3) Трассировка до города"
echo "4) Выход"
read -rp $'\nВаш выбор: ' choice

case $choice in
    1)
        echo -e "\n▶ Пинг всех POP-ов..."
        for pop in "${!EU_POPs[@]}"; do
            city="${EU_POPs[$pop]}"
            ips=$(echo "$json" | jq -r --arg pop "$pop" '.pops[$pop].relays[]?.ipv4')
            [[ -z "$ips" ]] && continue
            for ip in $ips; do
                ping_ip "$city" "$ip" &
            done
        done
        wait
        print_results "${EU_POPs[@]}"
        ;;
    2|3)
        declare -A sorted_map
        for pop in "${!EU_POPs[@]}"; do
            city="${EU_POPs[$pop]}"
            ips=$(echo "$json" | jq -r --arg pop "$pop" '.pops[$pop].relays[]?.ipv4')
            [[ -z "$ips" ]] && continue
            sorted_map["$city"]="$pop"
        done

        echo -e "\nДоступные города:"
        IFS=$'\n' sorted_cities=($(printf "%s\n" "${!sorted_map[@]}" | sort))
        for i in "${!sorted_cities[@]}"; do
            idx=$((i + 1))
            echo "$idx) ${sorted_cities[$i]}"
            cities[$idx]="${sorted_cities[$i]}"
            pops[$idx]="${sorted_map[${sorted_cities[$i]}]}"
        done

        read -rp $'\nВыберите город (номер): ' idx
        city="${cities[$idx]}"
        pop="${pops[$idx]}"
        ips=$(echo "$json" | jq -r --arg pop "$pop" '.pops[$pop].relays[]?.ipv4')

        ip=$(echo "$ips" | head -n1)

        if [[ "$choice" -eq 2 ]]; then
            echo -e "\n▶ Пинг $city..."
            for ip in $ips; do
                ping_ip "$city" "$ip" &
            done
            wait
            print_results "$city"
        else
            if [[ -z "$ip" ]]; then
                echo "❌ Нет доступных IP-адресов для трассировки в $city."
                exit 1
            fi
            run_traceroute "$ip" "$city"
        fi
        ;;
    4)
        echo "👋 Пока!"
        exit 0
        ;;
    *)
        echo "❌ Неверный выбор."
        exit 1
        ;;
esac
