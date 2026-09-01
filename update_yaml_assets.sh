#!/usr/bin/env bash

set -euo pipefail

DATA_DIR="_data/2025"
OLD="/dst/assets/"
NEW="/dst/assets/cb-2025/"

find "$DATA_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) | while read -r file
do
    echo "Updating $file"
    echo ./movesite.sh "$file" "$OLD" "$NEW"
done

OLD="/dsbristol/dst/blob/master/assets/"
NEW="/dsbristol/dst/cb-2025/blob/master/assets/"

#find "$DATA_DIR" -type f \( -name "*.yml" -o -name "*.yaml" \) | while read -r file
#do
#    echo "Updating $file"    
#done
