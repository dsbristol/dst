#!/usr/bin/env bash

set -euo pipefail

DATA_DIR="cb-2025"
OLD="site.data"
NEW="site.data.2025"

find "$DATA_DIR" -type f \( -name "*.md" \) | while read -r file
do
    echo "Updating $file"
    echo ./movesite.sh "$file" "$OLD" "$NEW"
done


OLD="/dst/assets"
NEW="/dst/cb-2025/assets"

find "$DATA_DIR" -type f \( -name "*.md" \) | while read -r file
do
    echo "Updating $file"
    echo ./movesite.sh "$file" "$OLD" "$NEW"
done

OLD="layout: coursebook"
NEW="layout: coursebook-2025"

find "$DATA_DIR" -type f \( -name "*.md" \) | while read -r file
do
    echo "Updating $file"
    ./movesite.sh "$file" "$OLD" "$NEW"
done
