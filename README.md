# 🌍 Steam POP Ping & Traceroute Tool

> 🇷🇺 Русская версия | 🇬🇧 English version below

Этот скрипт позволяет быстро и наглядно оценить задержку (пинг) и трассировку до различных **POP-серверов Steam** в **европейских городах**. Утилита идеально подходит для геймеров, инженеров сетей и всех, кто хочет протестировать подключение к Steam-инфраструктуре.

---

## 🚀 Возможности

- 📡 **Пинг всех европейских POP-ов** — автоматический сбор и тестирование всех серверов в регионе.
- 🏙️ **Выбор города** — возможность вручную выбрать город для получения детальной статистики.
- 🔍 **Трассировка маршрута (traceroute)** — построчное отображение всех хопов до выбранного сервера с геолокацией, DNS и временем отклика.
- 🌐 **Автоматическое получение серверов** — IP-адреса получаются в реальном времени через API Steam.
- 🎨 **Цветовая индикация задержек** — быстрое визуальное различие между хорошей, средней и плохой задержкой.

## 📦 Зависимости

```bash
jq curl dig bc traceroute
```

Установить можно, например:

```bash
sudo apt install jq curl dnsutils bc traceroute -y
```

## ⚡ Быстрый запуск без установки

```bash
bash <(curl -s https://raw.githubusercontent.com/peg4/steam_ping/refs/heads/main/steam_ping.sh)
```

## 🧰 Ручная установка

```bash
git clone https://github.com/peg4/steam_ping.git
cd steam_ping
chmod +x steam_ping.sh
./steam_ping.sh
```

## 🖼️ Примеры вывода

### 📊 Результаты пинга:
```
City         Total IPs  OK         Avg Latency
------------ ---------  ---------  -------------
Amsterdam    5          5          12.45 ms ✅
Frankfurt    6          6          18.33 ms ✅
Madrid       4          4          52.91 ms ⚠️
```

### 🌐 Трассировка:
```
┌────┬──────────────────────────────┬────────────┬──────────┬──────────┬──────────┬─────────────────────────────┐
│ Хоп │ DNS                          │ IP         │ Пинг #1  │ Пинг #2  │ Пинг #3  │ Геолокация                  │
├────┼──────────────────────────────┼────────────┼──────────┼──────────┼──────────┼─────────────────────────────┤
│ 1  │ router.local                 │ 192.168.1.1 │ 1.23 ms  │ 1.11 ms  │ 1.17 ms  │ -                           │
│ 2  │ 100.64.0.1                   │ 100.64.0.1  │ 3.45 ms  │ 3.40 ms  │ 3.43 ms  │ ISP Router, RU, Rostelecom  │
└────┴──────────────────────────────┴────────────┴──────────┴──────────┴──────────┴─────────────────────────────┘
```

## 🌍 Поддерживаемые города

- Amsterdam 🇳🇱
- Frankfurt 🇩🇪
- London 🇬🇧
- Madrid 🇪🇸
- Paris 🇫🇷
- Stockholm 🇸🇪
- Vienna 🇦🇹
- Warsaw 🇵🇱
- Helsinki 🇫🇮

_(автоматически подгружается с API Steam)_

## 📃 Лицензия

MIT License

---

## 🇬🇧 English Version

This script helps quickly test latency and traceroutes to various **Steam POP servers** in **European cities**. It's ideal for gamers, network engineers, and anyone wanting to measure connection quality to the Steam infrastructure.

---

### 🚀 Features

- 📡 **Ping all EU POPs** — automatically tests all European Steam nodes.
- 🏙️ **Choose a city** — manually select a city to view detailed latency.
- 🔍 **Traceroute with Geo** — view all hops to a target server with DNS, location and latency per hop.
- 🌐 **Real-time Steam API data** — server IPs are fetched dynamically.
- 🎨 **Latency color display** — easily spot low, medium, or high latency.

### 📦 Dependencies

```bash
jq curl dig bc traceroute
```

Install via:

```bash
sudo apt install jq curl dnsutils bc traceroute -y
```

### ⚡ One-line Quick Start

```bash
bash <(curl -s https://raw.githubusercontent.com/peg4/steam_ping/refs/heads/main/steam_ping.sh)
```

### 🧰 Manual Setup

```bash
git clone https://github.com/peg4/steam_ping.git
cd steam_ping
chmod +x steam_ping.sh
./steam_ping.sh
```

### 🖼️ Sample Output

#### 📊 Ping Results:
```
City         Total IPs  OK         Avg Latency
------------ ---------  ---------  -------------
Amsterdam    5          5          12.45 ms ✅
Frankfurt    6          6          18.33 ms ✅
Madrid       4          4          52.91 ms ⚠️
```

#### 🌐 Traceroute:
```
┌────┬──────────────────────────────┬────────────┬──────────┬──────────┬──────────┬─────────────────────────────┐
│ Hop │ DNS                          │ IP         │ Ping #1  │ Ping #2  │ Ping #3  │ Location                    │
├────┼──────────────────────────────┼────────────┼──────────┼──────────┼──────────┼─────────────────────────────┤
│ 1  │ router.local                 │ 192.168.1.1 │ 1.23 ms  │ 1.11 ms  │ 1.17 ms  │ -                           │
│ 2  │ 100.64.0.1                   │ 100.64.0.1  │ 3.45 ms  │ 3.40 ms  │ 3.43 ms  │ ISP Router, RU, Rostelecom  │
└────┴──────────────────────────────┴────────────┴──────────┴──────────┴──────────┴─────────────────────────────┘
```

### 🌍 Supported Cities

Amsterdam, Frankfurt, London, Madrid, Paris, Stockholm, Vienna, Warsaw, Helsinki  
_(automatically updated from Steam API)_

---

### 📃 License

MIT License
