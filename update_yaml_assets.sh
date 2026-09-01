#!/usr/bin/env bash

set -euo pipefail

DATA_DIR="_data/2025"
OLD="/dst/assets/"
NEW="/dst/assets/2025/"

find "$DATA_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) | while read -r file
do
    echo "Updating $file"
    ./movesite.sh "$file" "$OLD" "$NEW"
done
