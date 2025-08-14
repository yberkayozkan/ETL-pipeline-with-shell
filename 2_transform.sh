#!/bin/bash
set -e

TEMP_FILE=$1
PROCESSED_FILE=$2

# Basit argüman kontrolü
if [ -z "$TEMP_FILE" ] || [ -z "$PROCESSED_FILE" ]; then
	echo "ERROR: Usage: $0 <TEMP_FILE> <PROCESSED_FILE>" >&2
	return 2
fi

# jq'nin yüklü olduğunu kontrol et
if ! command -v jq >/dev/null 2>&1; then
	echo "ERROR: 'jq' is required but not installed." >&2
	return 3
fi

# Geçici dosyanın varlığını kontrol et
if [ ! -f "$TEMP_FILE" ]; then
	echo "ERROR: Temp file not found: $TEMP_FILE" >&2
	return 4
fi

# JSON içeriğini doğrula
if ! jq -e . "$TEMP_FILE" >/dev/null 2>&1; then
	echo "ERROR: Invalid JSON in $TEMP_FILE" >&2
	return 5
fi

# İşleme: CSV'ye ekle. Hata durumunda uygun kod döndür.
# Kaç kayıt olduğunu say
PAGE_COUNT=$(jq '.results | length' "$TEMP_FILE" 2>/dev/null || echo 0)

if ! jq -r '.results[] | [.id, .name, .status, .species, .gender] | @csv' "$TEMP_FILE" >> "$PROCESSED_FILE"; then
	echo "ERROR: Failed to transform JSON -> CSV for $TEMP_FILE" >&2
	return 6
fi

# Bir sonraki sayfanın URL'ini al ve stdout'a yaz (ana script bunu yakalayacak)
NEXT_URL=$(jq -r '.info.next' "$TEMP_FILE" 2>/dev/null || echo "null")
if [ -z "$NEXT_URL" ] || [ "$NEXT_URL" = "null" ]; then
	NEXT_URL="null"
fi

# Log detail to stderr: how many processed from this page
echo "OK: Transformed $TEMP_FILE -> $PROCESSED_FILE (records=${PAGE_COUNT})" >&2

# If REPORT_FILE is set, append a short line for this page
if [ -n "$REPORT_FILE" ]; then
	echo "PageFile: $TEMP_FILE | Records: $PAGE_COUNT | Next: $NEXT_URL" >> "$REPORT_FILE" 2>/dev/null || true
fi

# Output only the NEXT_URL on stdout so run_etl.sh can capture it
echo "$NEXT_URL"