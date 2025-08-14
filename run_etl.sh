#!/bin/bash

echo "ETL Süreci Başlatıldı: Tüm karakterler çekiliyor..."
set -e
source config.sh

mkdir -p $RAW_DATA_DIR
mkdir -p $PROCESSED_DATA_DIR

# 1. Adım: Nihai CSV dosyası için başlık satırını oluştur.
echo "ID,Isim,Durum,Tur,Cinsiyet" > "$PROCESSED_FILE"

# Rapor dosyasını başlat
echo "ETL Report - $(date)" > "$REPORT_FILE"
echo "Initial API URL: $INITIAL_API_URL" >> "$REPORT_FILE"
echo "Processed file: $PROCESSED_FILE" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. Adım: Döngü için başlangıç ayarları
CURRENT_URL="$INITIAL_API_URL"
TEMP_JSON_FILE="$RAW_DATA_DIR/temp_page.json"
PAGE_NUMBER=1

# 3. Adım: Sayfalama döngüsü
# CURRENT_URL değişkeni "null" olmadığı sürece döngü devam edecek.
while [ "$CURRENT_URL" != "null" ]; do
  
  echo "[Sayfa $PAGE_NUMBER] Çekiliyor: $CURRENT_URL"
  
  # Extract: Veriyi geçici bir dosyaya çek.
  if ! source 1_extract.sh "$CURRENT_URL" "$TEMP_JSON_FILE"; then
    echo "ERROR: Extract failed for $CURRENT_URL" >&2
    echo "[Page $PAGE_NUMBER] Extract failed for $CURRENT_URL" >> "$REPORT_FILE"
    break
  fi
  
  # Transform: Geçici dosyayı işle ve CSV'ye ekle.
  # 'bash 2_transform.sh' komutunun çıktısını (yeni URL) yakala.
  NEXT_URL=$(source 2_transform.sh "$TEMP_JSON_FILE" "$PROCESSED_FILE")
  TRANSFORM_EXIT=$?
  if [ $TRANSFORM_EXIT -ne 0 ]; then
    echo "ERROR: Transform failed for $TEMP_JSON_FILE (exit $TRANSFORM_EXIT)" >&2
    echo "[Page $PAGE_NUMBER] Transform failed for $TEMP_JSON_FILE (exit $TRANSFORM_EXIT)" >> "$REPORT_FILE"
    break
  fi
  
  # Bir sonraki döngü için URL'i güncelle.
  CURRENT_URL="$NEXT_URL"
  
  # Sayfa numarasını bir artır.
  ((PAGE_NUMBER++))

done

# 4. Adım: Temizlik
# Geçici JSON dosyasını sil.
rm "$TEMP_JSON_FILE"

TOTAL_PAGES=$(($PAGE_NUMBER - 1))
TOTAL_RECORDS=$(tail -n +2 "$PROCESSED_FILE" | wc -l || echo "0")

echo "ETL Süreci Tamamlandı." | tee -a "$REPORT_FILE"
echo "Toplamda ${TOTAL_PAGES} sayfa işlendi." | tee -a "$REPORT_FILE"
echo "Toplam kayıt: ${TOTAL_RECORDS}" | tee -a "$REPORT_FILE"
echo "Çıktı dosyası: $PROCESSED_FILE" | tee -a "$REPORT_FILE"

echo "ETL Süreci Başarıyla Tamamlandı."
echo "Toplamda ${TOTAL_PAGES} sayfa işlendi."
echo "Tüm karakterlerin verisi şu dosyaya kaydedildi: $PROCESSED_FILE"
echo "Rapor: $REPORT_FILE"