# Лабораторна робота 3

## Структура

```text
lab3/
├── README.md          # опис інструментів і приклади запуску
├── backup.sh          # резервне копіювання
├
├── config/            # конфігурація монітора
└── hooks/             # git-хуки
```

## Резервне копіювання

`backup.sh` створює архів `.tar.gz`, залишає вказану кількість останніх
архівів і записує результат у `backup.log` у папці резервних копій.
Потрібні Bash 4+, tar та GNU coreutils (Linux або WSL).
Запускайте з кореня репозиторію; папка призначення має бути поза джерелом.

```bash
bash lab3/backup.sh --help
bash lab3/backup.sh --source ./docs --dest ./backups --keep 5 --dry-run
bash lab3/backup.sh --source ./docs --dest ./backups --keep 5
```

## Git hooks

`hooks/pre-commit` запускає `shellcheck` тільки для staged-файлів `*.sh`,
які потраплять у наступний commit. Список отримується командою
`git diff --cached --name-only --diff-filter=ACMR` (із `-z` для назв із пробілами).
Видалені файли не перевіряються. Скрипт читає вміст зі staging через `git show`,
тому пізніші зміни у робочих файлах не впливають на перевірку.
Якщо staged `.sh` файлів немає, hook повертає `0` без запуску `shellcheck`.
Помилки `shellcheck` або відсутність цієї програми блокують commit.
Для використання потрібен встановлений `shellcheck`.

`hooks/pre-push` запускає `tests/test_backup.sh`. Тести перевіряють створення
архіву, `--dry-run`, неправильний `--source` та збереження двох архівів із
`--keep 2`. Вони використовують `mktemp -d`; тимчасова тека видаляється через
`trap` навіть при помилці. Успішні тести дають `push allowed` і код `0`.
Невдалі тести дають `push cancelled` і ненульовий код, блокуючи push.
Для тестів потрібні Bash 4+, tar та GNU coreutils (Linux або WSL).

Тести можна запустити вручну з кореня репозиторію:

```bash
bash lab-03/tests/test_backup.sh
```

### Встановлення вручну

Наведені команди — лише інструкція; автоматично hooks не встановлюються.
З кореня репозиторію:

```bash
chmod +x lab-03/hooks/pre-commit
chmod +x lab-03/hooks/pre-push
git config core.hooksPath lab-03/hooks
```


`.git` у цій структурі знаходиться у батьківській теці `deo`, поряд із `lab-03`.
Відносний `core.hooksPath` для цих hooks — `lab-03/hooks`, навіть якщо команду
налаштування запускають із `lab-03`: Git виконує ці hooks із кореня репозиторію.
Для перевірки кореня й налаштування вручну:

```bash
git rev-parse --show-toplevel
git config --get core.hooksPath
```

Альтернатива — копіювання файлів. Наступні команди виконують із кореня `deo`:

```bash
cp lab-03/hooks/pre-commit .git/hooks/pre-commit
cp lab-03/hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
```

Якщо `core.hooksPath` уже налаштований, спочатку поверніть типовий шлях:

```bash
git config --unset core.hooksPath
```

Ця команда також повертає типову поведінку Git після використання рекомендованого
способу. `.git/hooks/` не версіонується; `lab-03/hooks/` зберігається у репозиторії,
щоб кожен розробник міг встановити hooks локально. Наявний `.gitkeep` збережено.

### Демонстрація без commit або push

З кореня репозиторію, у Linux/WSL зі встановленим `shellcheck`:

```bash
bash lab-03/hooks/pre-commit
echo "Exit code: $?"
bash lab-03/hooks/pre-push
echo "Exit code: $?"
```

`pre-commit` перевіряє поточний staging. Без staged `.sh` файлів код буде `0`.
Для демонстрації lint success/failure потрібен відповідно коректний або помилковий
`.sh` файл у staging. Наприклад, рядок `echo $value` без визначення `value`
викликає попередження ShellCheck. Зміни тільки робочого файлу після staging
не впливають на результат. Не залишайте навмисно помилковий файл після демонстрації.
Жодна з наведених команд демонстрації не створює commit і не виконує push.

### Чому Git hooks не є повноцінним засобом контролю?

Hooks знаходяться на машині розробника. Їх можна не встановити, змінити
або видалити, а також вимкнути налаштований шлях hooks. Перевірки також можна обійти через `--no-verify`:

```bash
git commit --no-verify
git push --no-verify
```

Тому Git hooks — зручна локальна рання перевірка для розробника, але не гарантія.

CI виконується на інфраструктурі проєкту, а не на машині розробника, та запускає централізовані перевірки: `lint`, `tests`, `build`, `security checks`.
Якщо правила repository/branch protection вимагають успішного CI перед merge,
розробник не може просто використати `--no-verify`, щоб обійти ці перевірки.
CD відповідає за подальшу доставку або розгортання; у CI/CD можна вимагати
успішних перевірок перед deploy.

Git hooks = локальна рання перевірка для розробника.

CI required checks = централізований контроль перед merge/deploy.
