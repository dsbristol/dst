#!/usr/bin/env bash

set -euo pipefail

DATA_DIR="_data/2025"
OLD="/dst/assets/cb-2025/"
NEW="/dst/cb-2025/assets/"

find "$DATA_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) | while read -r file
do
    echo "Updating $file"
    ./movesite.sh "$file" "$OLD" "$NEW"
done

OLD="/dsbristol/dst/blob/master/assets/"
NEW="/dsbristol/dst/blob/master/cb-2025/assets/"

find "$DATA_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) | while read -r file
do
    echo "Updating $file"    
    ./movesite.sh "$file" "$OLD" "$NEW"
done
