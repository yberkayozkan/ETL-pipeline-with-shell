#!/bin/bash
set -e

TEMP_FILE=$1
PROCESSED_FILE=$2

# jq ile JSON'u işle ve CSV'ye çevir. '>>' ile dosyanın sonuna ekle.
jq -r '.results[] | [.id, .name, .status, .species, .gender] | @csv' "$TEMP_FILE" >> "$PROCESSED_FILE"

# Bir sonraki sayfanın URL'ini al ve ekrana yazdır.
# Ana script bu çıktıyı yakalayacak.
jq -r '.info.next' "$TEMP_FILE"