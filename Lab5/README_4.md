## Завдання 4. Публікація Docker-образів у GitHub Container Registry

### 1. Перевірка GitHub Actions для Backend

Для автоматизації перевірки та збірки Docker-образу серверної частини було налаштовано GitHub Actions у файлі `.github/workflows/ci.yml`.

Під час створення Pull Request автоматично запускаються перевірка стилю Python-коду, тести API з PostgreSQL і Redis та збірка Docker-образу.

<img width="1205" height="682" alt="image" src="https://github.com/user-attachments/assets/7c4c940a-ea4f-487d-9d09-f9e4bd834405" />


*Рисунок 1 — Успішне виконання GitHub Actions для Backend.*

Усі перевірки завершилися успішно. Завдання `Docker publish` було пропущене, оскільки під час Pull Request образ повинен лише збиратися, без публікації в реєстрі.

### 2. Перевірка GitHub Actions для Frontend

Аналогічно було налаштовано GitHub Actions для клієнтської частини Wishlist.

Після створення Pull Request виконуються перевірки frontend та збірка Docker-образу на основі Node.js і Nginx.
<img width="1220" height="692" alt="image" src="https://github.com/user-attachments/assets/57d575a1-971a-4abe-b821-e99b56c31690" />

*Рисунок 2 — Успішне виконання GitHub Actions для Frontend.*

Усі перевірки завершилися успішно. Збірка Docker-образу виконалася після перевірок frontend. Публікація образу не здійснювалася, що відповідає вимогам роботи.

### 3. Перевірка публікації Docker-образів у GHCR

Після об'єднання змін із гілкою `main` GitHub Actions
