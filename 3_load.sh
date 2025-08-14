#!/bin/bash
set -e
source config.sh

# Basit kontrol: işlenmiş dosya mevcut mu?
if [ ! -f "$PROCESSED_FILE" ]; then
	echo "ERROR: Processed file not found: $PROCESSED_FILE" >&2
	# also append to report if available
	if [ -n "$REPORT_FILE" ]; then
		echo "LOAD ERROR: Processed file not found: $PROCESSED_FILE" >> "$REPORT_FILE" 2>/dev/null || true
	fi
	return 2
fi

echo "İşlenmiş veri hazır: $PROCESSED_FILE"
if [ -n "$REPORT_FILE" ]; then
    echo "LOAD OK: Processed data ready: $PROCESSED_FILE" >> "$REPORT_FILE" 2>/dev/null || true
fi