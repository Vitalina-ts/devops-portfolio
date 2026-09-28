#!/usr/bin/env bash
set -euo pipefail

source_dir=""
dest_dir=""
keep=5
dry_run=false

# показуємо підказку
show_help() {
    echo "Usage:"
    echo "./backup.sh --source <path> --dest <path> [--keep <N>] [--dry-run]"
    echo
    echo "--source <path>  тека, яку архівуємо"
    echo "--dest <path>    куди зберігати архіви"
    echo "--keep <N>       скільки копій залишити, типово 5"
    echo "--dry-run        тільки показати дії"
    echo "--help           показати довідку"
    echo
    echo 'Example:'
    echo './backup.sh --source "./my project" --dest "./backups" --keep 3'
}

# помилка + код виходу
fail() {
    echo "ERROR: $2" >&2
    exit "$1"
}

# читаємо параметри
while [[ $# -gt 0 ]]; do
    case "$1" in
        --source)
            [[ $# -ge 2 ]] || fail 1 "Не вказано шлях після --source"
            source_dir="$2"
            shift 2
            ;;

        --dest)
            [[ $# -ge 2 ]] || fail 1 "Не вказано шлях після --dest"
            dest_dir="$2"
            shift 2
            ;;

        --keep)
            [[ $# -ge 2 ]] || fail 1 "Не вказано число після --keep"
            keep="$2"
            shift 2
            ;;

        --dry-run)
            dry_run=true
            shift
            ;;

        --help)
            show_help
            exit 0
            ;;

        *)
            fail 1 "Невідомий параметр: $1"
            ;;
    esac
done

# перевіряємо обов'язкові параметри
[[ -n "$source_dir" ]] || fail 1 "Потрібно вказати --source"
[[ -n "$dest_dir" ]] || fail 1 "Потрібно вказати --dest"

# перевіряємо source
[[ -d "$source_dir" ]] || fail 2 "Тека source не існує"
[[ -r "$source_dir" ]] || fail 3 "Тека source недоступна для читання"

# keep має бути додатним числом
[[ "$keep" =~ ^[1-9][0-9]*$ ]] || fail 1 "--keep має бути додатним числом"

# створюємо destination, якщо його ще немає
if [[ ! -d "$dest_dir" ]]; then
    if "$dry_run"; then
        echo "[DRY-RUN] Було б створено теку: $dest_dir"
    else
        mkdir -p "$dest_dir" || fail 4 "Не вдалося створити destination"
    fi
fi

source_name="$(basename "$source_dir")"
source_parent="$(dirname "$source_dir")"

timestamp="$(date +%Y-%m-%d-%H%M%S)"
archive="$dest_dir/$source_name-$timestamp.tar.gz"

# якщо запусків кілька за одну секунду, чекаємо нове ім'я
while [[ -e "$archive" ]]; do
    sleep 1
    timestamp="$(date +%Y-%m-%d-%H%M%S)"
    archive="$dest_dir/$source_name-$timestamp.tar.gz"
done

# рахуємо файли, які підуть в архів
files_count="$(find "$source_dir" -type f | wc -l)"

if "$dry_run"; then
    echo "[DRY-RUN] Було б створено архів: $archive"
else
    tar -czf "$archive" -C "$source_parent" "$source_name" \
        || fail 5 "Не вдалося створити архів"

    echo "Створено архів: $archive"
fi

# шукаємо тільки архіви цього source
mapfile -t archives < <(
    find "$dest_dir" \
        -maxdepth 1 \
        -type f \
        -name "$source_name-????-??-??-??????.tar.gz" \
        -print | sort
)

# у dry-run враховуємо архів, який був би створений
if "$dry_run"; then
    archives+=("$archive")
    mapfile -t archives < <(printf '%s\n' "${archives[@]}" | sort)
fi

count="${#archives[@]}"
removed=0

# якщо архівів забагато - видаляємо найстаріші
if (( count > keep )); then
    to_remove=$((count - keep))

    for ((i = 0; i < to_remove; i++)); do
        if "$dry_run"; then
            echo "[DRY-RUN] Було б видалено: ${archives[$i]}"
        else
            rm "${archives[$i]}" || fail 6 "Не вдалося видалити старий архів"
            echo "Видалено: ${archives[$i]}"
        fi

        removed=$((removed + 1))
    done
fi

# записуємо результат
if "$dry_run"; then
    echo "[DRY-RUN] Було б записано в журнал:"
    echo "$(date -Iseconds) | source=$source_dir | files=$files_count | removed=$removed"
else
    archive_size="$(stat -c %s "$archive")"

    echo "$(date -Iseconds) | source=$source_dir | result=SUCCESS | files=$files_count | removed=$removed | size=$archive_size" \
        >> "$dest_dir/backup.log" \
        || fail 7 "Не вдалося записати журнал"
fi
