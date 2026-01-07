#!/usr/bin/env sh
set -e

WORKDIR=/workdir
OUTPUTDIR=/processed

if ! find "$WORKDIR" -type f -print -quit | grep -q .; then
  echo "No files to process"
  exit 1
fi

find "$WORKDIR" -type f | while read -r file; do
  RELATIVE_PATH="${file#$WORKDIR/}"
  OUTPUT_PATH="$OUTPUTDIR/$RELATIVE_PATH"

  echo "Processing $RELATIVE_PATH"

  mkdir -p "$(dirname "$OUTPUT_PATH")"
  envsubst < "$file" > "$OUTPUT_PATH"
done

echo "All files have been processed"
