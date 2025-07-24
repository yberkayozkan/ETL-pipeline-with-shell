#!/bin-bash
set -e
source config.sh

# Bu basit projede "Load" adımı, işlenmiş dosyanın
# "processed" klasöründe bulunmasıdır.
# Bu yüzden sadece bir onay mesajı yazdırıyoruz.
echo "İşlenmiş veri $PROCESSED_DATA_DIR klasöründe hazır."