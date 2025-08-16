# ETL Pipeline (Shell)

Kısa açıklama

Bu depo, Rick and Morty API'sinden karakter verilerini çekip (extract), JSON'u CSV'ye dönüştürüp (transform) ve sonuçları işlenmiş klasörüne kaydeden basit bir bash tabanlı ETL hattı içerir. Aşağıda dosyalar, çalışma adımları ve hata ayıklama notları yer almaktadır.

## İçerik (dosyalar ve amaçları)

- `config.sh` — Proje ayarlarını içerir (başlangıç URL, veri dizinleri, zaman damgası ile çıktı dosyaları).
- `1_extract.sh` — Veriyi verilen API URL'inden indirir ve geçici JSON dosyasına yazar. (curl kullanır, JSON doğrulaması için `jq` gerektirir)
- `2_transform.sh` — Geçici JSON dosyasını okuyup CSV satırları olarak `PROCESSED_FILE`'a ekler, stdout'a sonraki sayfa URL'ini yazdırır.
- `3_load.sh` — Basit yükleme kontrolleri yapar (işlenmiş dosyanın varlığı vb.) ve rapora ekler.
- `run_etl.sh` — Tüm süreci koordine eder: sayfalama döngüsü, extract → transform adımları, geçici dosya temizliği ve rapor oluşturma.
- `data/raw/` — İndirilmiş ham JSON sayfa dosyalarının tutulduğu klasör (örn. `temp_page.json`).
- `data/processed/` — Oluşturulmuş CSV ve ETL raporu dosyalarının bulunduğu klasör.

## Gereksinimler

- Bash kabuğu (Linux, macOS veya Windows için WSL/Git Bash/Cygwin).
- `curl` — HTTP istekleri için.
- `jq` — JSON ayrıştırma ve dönüştürme için.
- Standart Unix araçları: `stat`, `wc`, `mv`, `rm`, `mkdir`, `tail`.

Not: Windows PowerShell doğrudan bash betiklerini çalıştırmaz; Windows üzerinde çalıştırmak için WSL veya Git Bash önerilir.

## Nasıl çalıştırılır

1. Gerekli araçların kurulu olduğundan emin olun (`jq`, `curl`, bash).
2. Proje kökünde çalışın:

```bash
bash run_etl.sh
```

Bu komut `config.sh`'i okur, `data/raw` ve `data/processed` dizinlerini oluşturur, başlık satırını CSV'ye yazar ve API sayfalarını teker teker indirip işler. Çıktı dosyası: `data/processed/characters_YYYYMMDD_hhmmss.csv` ve rapor: `data/processed/etl_report_YYYYMMDD_hhmmss.txt`.

## Rapor ve çıktı açıklaması

- CSV başlığı: `ID,Isim,Durum,Tur,Cinsiyet` (Türkçe başlıklar betiklerde sabittir).
- Rapor dosyası (`etl_report_*.txt`) her sayfa için: `PageFile: <temp_json> | Records: <n> | Next: <next_url>` satırları içerir. Son satır `Next: null` olduğunda döngü biter.

## Hata ayıklama (common issues)

- "'jq' is required but not installed." → `jq` yükleyin.
- Ağ hataları / HTTP 4xx-5xx → İnternet bağlantısını kontrol edin veya API URL'sinin erişilebilir olduğunu doğrulayın.
- İzin hataları → Betiklerin çalıştırılabilir olduğundan emin olun: `chmod +x *.sh` (WSL/Git Bash altında).
- Windows üzerinde doğrudan `./run_etl.sh` hata veriyorsa, WSL/Git Bash kullanın: `bash run_etl.sh`.

## Notlar ve tavsiyeler

- `run_etl.sh` geçici dosya olarak `data/raw/temp_page.json` kullanır ve işlemler tamamlandığında bu dosyayı siler.
- Mevcut CSV'ye ekleme yapıldığı için daha önce oluşturulmuş bir `PROCESSED_FILE` üzerine dikkat: `run_etl.sh` varsayılan olarak yeni bir isimle (zaman damgası) dosya oluşturur.
- Küçük iyileştirmeler: yeniden başlatma (resume) desteği, paralel indirme veya daha sağlam hata denemeleri eklenebilir.

## İletişim
