# Лабораторна робота №4

## Репозиторії
- Backend: https://github.com/Vitalina-ts/withlist-api
- Frontend: https://github.com/Vitalina-ts/wishlist-ui

## Локальний запуск

**1. Клонування проєктів**

```powershell
git clone https://github.com/Vitalina-ts/withlist-api.git
git clone https://github.com/Vitalina-ts/wishlist-ui.git
```

**2. Запуск Backend (FastAPI, PostgreSQL, Redis)**

Запустити Docker Desktop.

```powershell
cd withlist-api
```

У `docker-compose.yml` для сервісу `api` налаштувати:

```yaml
environment:
  DB_USER: username
  DB_PASSWORD: password
  DB_HOST: postgres
  DB_NAME: wishlist_db
  REDIS_URL: redis://redis:6379/0
```

У `database.py` для локального запуску встановити `sslmode=disable`.

```powershell
docker compose up -d --build
docker compose ps
```

Перевірити API: http://localhost:8000/docs

**3. Запуск Frontend (Vue 3)**

Відкрити новий термінал:

```powershell
cd wishlist-ui
npm ci
```

Створити файл `.env.local`:

```env
VITE_API_BASE=http://localhost:8000
```

Запустити:

```powershell
npm run dev
```

Відкрити сайт: http://localhost:5173

**4. Перевірка**

У браузері натиснути `F12 → Network → Fetch/XHR` і перевірити, що frontend отримує дані від API. Створити тестовий запис і перевірити його відображення.

## Мій внесок

Я клонувала обидва репозиторії, налаштувала Docker, запустила PostgreSQL, Redis і FastAPI, встановила залежності Vue та підготувала локальне середовище.

**Pull Requests:** додати посилання після створення.
