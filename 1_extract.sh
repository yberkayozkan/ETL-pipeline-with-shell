#!/bin/bash
set -e

# Parametre olarak gelen URL'den veriyi çek ve geçici bir dosyaya yaz.
API_URL=$1
TEMP_FILE=$2

curl -s -o "$TEMP_FILE" "$API_URL"