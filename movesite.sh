#!/usr/bin/env bash

set -euo pipefail

if [ $# -ne 3 ]; then
    echo "Usage: $0 file search_text replacement_text"
    exit 1
fi

FILE="$1"
SEARCH="$2"
REPLACE="$3"

perl -i -pe '
BEGIN {
  $s = shift;
  $r = shift;
}
s/\Q$s\E/$r/g;
' "$SEARCH" "$REPLACE" "$FILE"
