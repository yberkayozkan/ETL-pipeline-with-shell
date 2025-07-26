#!/bin/bash

echo "ETL Süreci Başlatıldı: Tüm karakterler çekiliyor..."
set -e
source config.sh

mkdir -p $RAW_DATA_DIR
mkdir -p $PROCESSED_DATA_DIR

# 1. Adım: Nihai CSV dosyası için başlık satırını oluştur.
echo "ID,Isim,Durum,Tur,Cinsiyet" > "$PROCESSED_FILE"

# 2. Adım: Döngü için başlangıç ayarları
CURRENT_URL="$INITIAL_API_URL"
TEMP_JSON_FILE="$RAW_DATA_DIR/temp_page.json"
PAGE_NUMBER=1

# 3. Adım: Sayfalama döngüsü
# CURRENT_URL değişkeni "null" olmadığı sürece döngü devam edecek.
while [ "$CURRENT_URL" != "null" ]; do
  
  echo "[Sayfa $PAGE_NUMBER] Çekiliyor: $CURRENT_URL"
  
  # Extract: Veriyi geçici bir dosyaya çek.
  source 1_extract.sh "$CURRENT_URL" "$TEMP_JSON_FILE"
  
  # Transform: Geçici dosyayı işle ve CSV'ye ekle.
  # 'bash 2_transform.sh' komutunun çıktısını (yeni URL) yakala.
  NEXT_URL=$(source 2_transform.sh "$TEMP_JSON_FILE" "$PROCESSED_FILE")
  
  # Bir sonraki döngü için URL'i güncelle.
  CURRENT_URL="$NEXT_URL"
  
  # Sayfa numarasını bir artır.
  ((PAGE_NUMBER++))

done

# 4. Adım: Temizlik
# Geçici JSON dosyasını sil.
rm "$TEMP_JSON_FILE"

echo "ETL Süreci Başarıyla Tamamlandı."
echo "Toplamda $(($PAGE_NUMBER - 1)) sayfa işlendi."
echo "Tüm karakterlerin verisi şu dosyaya kaydedildi: $PROCESSED_FILE"