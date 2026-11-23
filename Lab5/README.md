## Хід роботи

### 1. Запуск контейнерів у Docker Desktop

Для запуску всіх сервісів проєкту Wishlist використано команду:

```powershell
docker compose up -d --build --wait
```

Після виконання команди в Docker Desktop було запущено чотири контейнери: `ui`, `api`, `postgres`, `redis`.
<img width="950" height="290" alt="image" src="https://github.com/user-attachments/assets/be4e9fe6-6a21-4ec1-973b-a92138c492c0" />
<img width="1228" height="692" alt="image" src="https://github.com/user-attachments/assets/575c1f71-b956-49f5-9315-5d8db58cc3d5" />



*Рисунок 1 — Запущені контейнери проєкту Wishlist у Docker Desktop.*

На рисунку 1 видно роботу всіх чотирьох сервісів. У журналі контейнерів відображаються HTTP-запити до API та UI з відповіддю `200 OK`, що підтверджує доступність застосунку.

### 2. Перевірка стану контейнерів

Для перевірки стану контейнерів виконано команду:

```powershell
docker compose ps
```
<img width="1222" height="212" alt="image" src="https://github.com/user-attachments/assets/dfe2e1e2-57ac-4668-a765-64300efc4f94" />

*Рисунок 2 — Перевірка стану сервісів Docker Compose.*

У результаті виконання команди всі чотири сервіси (`api`, `postgres`, `redis`, `ui`) мають статус `Up (healthy)`. Це означає, що перевірки готовності пройдено успішно. Також видно, що зовнішні порти опубліковані лише для API (`8000`) та UI (`5173`), а PostgreSQL і Redis працюють у внутрішній мережі Docker Compose.

### 3. Перевірка роботи вебінтерфейсу

Для перевірки клієнтської частини у браузері відкрито адресу:

```text
http://127.0.0.1:5173
```

Після входу в систему було створено тестовий список бажань.

<img width="827" height="578" alt="image" src="https://github.com/user-attachments/assets/0209d9e9-8c21-43b9-94a4-00df95010a78" />


*Рисунок 3 — Робота вебінтерфейсу Wishlist.*

На рисунку 3 показано сторінку `Your Wishlists` зі створеним списком бажань. Це підтверджує, що Vue-застосунок успішно завантажується через Nginx і дозволяє користувачу працювати зі списками.

### 4. Перевірка взаємодії UI з API

Для перевірки взаємодії між frontend і backend відкрито адресу:

```text
http://127.0.0.1:5173/api/health
```
<img width="720" height="128" alt="image" src="https://github.com/user-attachments/assets/eac6329a-7212-4e41-83dd-f748b03c7a18" />


*Рисунок 4 — Перевірка доступності FastAPI через Nginx.*

У браузері отримано JSON-відповідь:

```json
{
  "status": "healthy",
  "redis": "healthy",
  "timestamp": "2026-11-23T09:29:37.899975"
}
```

Отримана відповідь підтверджує, що Nginx успішно перенаправляє запити `/api/` до FastAPI, а сервер повідомляє про справний стан Redis.

### 5. Перевірка журналів контейнерів

Для перегляду журналів роботи сервісів використано команду:

```powershell
docker compose logs -f api ui
```
<img width="721" height="120" alt="image" src="https://github.com/user-attachments/assets/b4051c91-8d9f-494b-bf5a-ad459f345959" />

*Рисунок 5 — Журнали роботи контейнерів API та UI.*

У журналах видно успішні HTTP-запити `GET /health` до FastAPI та `GET /` до Nginx із кодом відповіді `200`. Це підтверджує, що серверна та клієнтська частини працюють і відповідають на запити.

### 6. Перевірка збереження даних PostgreSQL

Для перевірки збереження даних використано іменований том `postgres_data`. В ізольованому тестовому стеку було створено запис, після чого виконано команди:

```powershell
docker compose down
docker compose up -d --wait
```

Після повторного запуску запис залишився доступним, а API повернув `HTTP 200`.
<img width="876" height="147" alt="image" src="https://github.com/user-attachments/assets/0e080a8d-f0a2-4f8a-9ce1-460cecc1e3ab" />

Потім у тестовому стеку виконано:

```powershell
docker compose down -v
docker compose up -d --wait
```
<img width="1237" height="390" alt="image" src="https://github.com/user-attachments/assets/b2066fed-0b06-4151-a3bd-89d8d3923b57" />

Після видалення тому тестовий запис став недоступним, а API повернув `HTTP 404`.




У ході лабораторної роботи було налаштовано спільний Docker Compose для вебзастосунку Wishlist. Успішно запущено чотири сервіси: PostgreSQL, Redis, FastAPI та Vue/Nginx.

Перевірено готовність контейнерів, доступність вебінтерфейсу, взаємодію frontend із backend та збереження даних PostgreSQL в іменованому томі.

Усі сервіси отримали статус `healthy`, а HTTP-запити виконувалися успішно. Мету лабораторної роботи досягнуто.
