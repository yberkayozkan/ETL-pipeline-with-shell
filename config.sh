#!/bin/bash

# --- AYARLAR ---
# Başlangıç URL'i
INITIAL_API_URL="https://rickandmortyapi.com/api/character"

# Veri klasörleri
RAW_DATA_DIR="data/raw"
PROCESSED_DATA_DIR="data/processed"

# Dosya isimleri (Sadece ana CSV dosyası için)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
PROCESSED_FILE="$PROCESSED_DATA_DIR/characters_$TIMESTAMP.csv"