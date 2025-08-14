#!/bin/bash
set -e

# Parametre olarak gelen URL'den veriyi çek ve geçici bir dosyaya yaz.
API_URL=$1
TEMP_FILE=$2

# Basit kullanım kontrolü
if [ -z "$API_URL" ] || [ -z "$TEMP_FILE" ]; then
	echo "ERROR: Usage: $0 <API_URL> <TEMP_FILE>" >&2
	return 2
fi

# Geçici dosya dizinini oluştur (varsa hata vermez)
mkdir -p "$(dirname "$TEMP_FILE")" || { echo "ERROR: Failed to create directory for $TEMP_FILE" >&2; return 3; }

# curl ile indir. --fail HTTP hatalarında non-zero döndürür ve --silent/--show-error kombinasyonu stderr'i korur.
TMP_CURL_OUTPUT="$TEMP_FILE.download"
if ! curl -sS --fail -o "$TMP_CURL_OUTPUT" "$API_URL"; then
	echo "ERROR: Failed to download $API_URL" >&2
	rm -f "$TMP_CURL_OUTPUT"
	return 4
fi

# İndirilen dosyanın boş olmadığını kontrol et
if [ ! -s "$TMP_CURL_OUTPUT" ]; then
	echo "ERROR: Downloaded file is empty: $TMP_CURL_OUTPUT" >&2
	rm -f "$TMP_CURL_OUTPUT"
	return 5
fi

# Dosya boyutu ve satır sayısı bilgisi (log)
FILE_SIZE=$(stat -c%s "$TMP_CURL_OUTPUT" 2>/dev/null || stat -f%z "$TMP_CURL_OUTPUT" 2>/dev/null || echo "unknown")
LINE_COUNT=$(wc -l < "$TMP_CURL_OUTPUT" 2>/dev/null || echo "?")

# JSON doğrulaması (jq gerektirir)
if ! jq -e . "$TMP_CURL_OUTPUT" >/dev/null 2>&1; then
	echo "ERROR: Downloaded file is not valid JSON: $TMP_CURL_OUTPUT" >&2
	rm -f "$TMP_CURL_OUTPUT"
	return 6
fi

# Geçici dosyayı hedefe taşı
mv "$TMP_CURL_OUTPUT" "$TEMP_FILE"

# Başarılı indirme mesajı (stderr) - boyut ve satır sayısı ile
echo "OK: Fetched $API_URL -> $TEMP_FILE (size=${FILE_SIZE}, lines=${LINE_COUNT})" >&2