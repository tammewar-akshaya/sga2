SUBMISSION_DIR="./submissions"
BACKUP_DIR="./backup_unique"
REPORT_FILE="./report.txt"
ERROR_FILE="./errors.log"
TEMP_DIR="./temp_checksums"

rm -rf "$BACKUP_DIR" "$TEMP_DIR" 2>/dev/null
rm -f "$REPORT_FILE" "$ERROR_FILE" 2>/dev/null

mkdir -p "$BACKUP_DIR" || { echo "ERROR: Failed to create backup directory" | tee -a "$ERROR_FILE"; exit 1; }
mkdir -p "$TEMP_DIR" || { echo "ERROR: Failed to create temp directory" | tee -a "$ERROR_FILE"; exit 1; }

if [ ! -d "$SUBMISSION_DIR" ]; then
    echo "ERROR: Submission directory '$SUBMISSION_DIR' not found!" | tee -a "$ERROR_FILE"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Generating file checksums..." | tee -a "$REPORT_FILE"

find "$SUBMISSION_DIR" -type f -exec md5sum {} \; 2>>"$ERROR_FILE" > "$TEMP_DIR/all_checksums.txt"

TOTAL_FILES=$(wc -l < "$TEMP_DIR/all_checksums.txt" 2>>"$ERROR_FILE")
echo "Total files found: $TOTAL_FILES" | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo " Duplicate Files" >> "$REPORT_FILE"

DUPLICATE_HASHES=$(awk '{print $1}' "$TEMP_DIR/all_checksums.txt" | sort | uniq -d)
DUPLICATE_COUNT=0

for hash in $DUPLICATE_HASHES; do
    FILES=$(grep "^$hash " "$TEMP_DIR/all_checksums.txt" | awk '{$1=""; print $0}')
    echo "  Hash: $hash" >> "$REPORT_FILE"
    echo "  Files:$FILES" >> "$REPORT_FILE"
    COUNT=$(echo "$FILES" | wc -l)
    DUPLICATE_COUNT=$((DUPLICATE_COUNT + COUNT - 1))
done

echo "Total duplicate copies: $DUPLICATE_COUNT" | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo " Backup Summary" >> "$REPORT_FILE"

awk '!seen[$1]++' "$TEMP_DIR/all_checksums.txt" > "$TEMP_DIR/unique_files.txt"
BACKUP_COUNT=0

while IFS= read -r line; do
    FILENAME=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ //')
    if [ -n "$FILENAME" ] && [ -f "$FILENAME" ]; then
        DEST_DIR="$BACKUP_DIR/$(dirname "$FILENAME")"
        mkdir -p "$DEST_DIR"
        cp "$FILENAME" "$DEST_DIR/" 2>>"$ERROR_FILE"
        if [ $? -eq 0 ]; then
            BACKUP_COUNT=$((BACKUP_COUNT + 1))
            echo "  Backed up: $FILENAME" >> "$REPORT_FILE"
        else
            echo "  ERROR: Failed to backup $FILENAME" | tee -a "$ERROR_FILE"
        fi
    fi
done < "$TEMP_DIR/unique_files.txt"

echo "Unique files backed up: $BACKUP_COUNT" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "  Final Summary --" >> "$REPORT_FILE"
echo "  Date: $(date)" >> "$REPORT_FILE"
echo "  Total files: $TOTAL_FILES" >> "$REPORT_FILE"
echo "  Duplicates: $DUPLICATE_COUNT" >> "$REPORT_FILE"
echo "  Backed up: $BACKUP_COUNT" >> "$REPORT_FILE"

echo ""
echo "Report: $REPORT_FILE"
echo "Errors: $ERROR_FILE"

rm -rf "$TEMP_DIR"
exit 0
SUBMISSION_DIR="./submissions"
BACKUP_DIR="./backup_unique"
REPORT_FILE="./report.txt"
ERROR_FILE="./errors.log"
TEMP_DIR="./temp_checksums"

rm -rf "$BACKUP_DIR" "$TEMP_DIR" 2>/dev/null
rm -f "$REPORT_FILE" "$ERROR_FILE" 2>/dev/null

mkdir -p "$BACKUP_DIR" || { echo "ERROR: Failed to create backup directory" | tee -a "$ERROR_FILE"; exit 1; }
mkdir -p "$TEMP_DIR" || { echo "ERROR: Failed to create temp directory" | tee -a "$ERROR_FILE"; exit 1; }

if [ ! -d "$SUBMISSION_DIR" ]; then
    echo "ERROR: Submission directory '$SUBMISSION_DIR' not found!" | tee -a "$ERROR_FILE"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Generating file checksums..." | tee -a "$REPORT_FILE"

find "$SUBMISSION_DIR" -type f -exec md5sum {} \; 2>>"$ERROR_FILE" > "$TEMP_DIR/all_checksums.txt"

TOTAL_FILES=$(wc -l < "$TEMP_DIR/all_checksums.txt" 2>>"$ERROR_FILE")
echo "Total files found: $TOTAL_FILES" | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo " Duplicate Files" >> "$REPORT_FILE"

DUPLICATE_HASHES=$(awk '{print $1}' "$TEMP_DIR/all_checksums.txt" | sort | uniq -d)
DUPLICATE_COUNT=0

for hash in $DUPLICATE_HASHES; do
    FILES=$(grep "^$hash " "$TEMP_DIR/all_checksums.txt" | awk '{$1=""; print $0}')
    echo "  Hash: $hash" >> "$REPORT_FILE"
    echo "  Files:$FILES" >> "$REPORT_FILE"
    COUNT=$(echo "$FILES" | wc -l)
    DUPLICATE_COUNT=$((DUPLICATE_COUNT + COUNT - 1))
done

echo "Total duplicate copies: $DUPLICATE_COUNT" | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo " Backup Summary" >> "$REPORT_FILE"

awk '!seen[$1]++' "$TEMP_DIR/all_checksums.txt" > "$TEMP_DIR/unique_files.txt"
BACKUP_COUNT=0

while IFS= read -r line; do
    FILENAME=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ //')
    if [ -n "$FILENAME" ] && [ -f "$FILENAME" ]; then
        DEST_DIR="$BACKUP_DIR/$(dirname "$FILENAME")"
        mkdir -p "$DEST_DIR"
        cp "$FILENAME" "$DEST_DIR/" 2>>"$ERROR_FILE"
        if [ $? -eq 0 ]; then
            BACKUP_COUNT=$((BACKUP_COUNT + 1))
            echo "  Backed up: $FILENAME" >> "$REPORT_FILE"
        else
            echo "  ERROR: Failed to backup $FILENAME" | tee -a "$ERROR_FILE"
        fi
    fi
done < "$TEMP_DIR/unique_files.txt"

echo "Unique files backed up: $BACKUP_COUNT" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "  Final Summary --" >> "$REPORT_FILE"
echo "  Date: $(date)" >> "$REPORT_FILE"
echo "  Total files: $TOTAL_FILES" >> "$REPORT_FILE"
echo "  Duplicates: $DUPLICATE_COUNT" >> "$REPORT_FILE"
echo "  Backed up: $BACKUP_COUNT" >> "$REPORT_FILE"

echo ""
echo "Report: $REPORT_FILE"
echo "Errors: $ERROR_FILE"

rm -rf "$TEMP_DIR"
exit 0SUBMISSION_DIR="./submissions"
BACKUP_DIR="./backup_unique"
REPORT_FILE="./report.txt"
ERROR_FILE="./errors.log"
TEMP_DIR="./temp_checksums"

rm -rf "$BACKUP_DIR" "$TEMP_DIR" 2>/dev/null
rm -f "$REPORT_FILE" "$ERROR_FILE" 2>/dev/null

mkdir -p "$BACKUP_DIR" || { echo "ERROR: Failed to create backup directory" | tee -a "$ERROR_FILE"; exit 1; }
mkdir -p "$TEMP_DIR" || { echo "ERROR: Failed to create temp directory" | tee -a "$ERROR_FILE"; exit 1; }

if [ ! -d "$SUBMISSION_DIR" ]; then
    echo "ERROR: Submission directory '$SUBMISSION_DIR' not found!" | tee -a "$ERROR_FILE"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Generating file checksums..." | tee -a "$REPORT_FILE"

find "$SUBMISSION_DIR" -type f -exec md5sum {} \; 2>>"$ERROR_FILE" > "$TEMP_DIR/all_checksums.txt"

TOTAL_FILES=$(wc -l < "$TEMP_DIR/all_checksums.txt" 2>>"$ERROR_FILE")
echo "Total files found: $TOTAL_FILES" | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo " Duplicate Files" >> "$REPORT_FILE"

DUPLICATE_HASHES=$(awk '{print $1}' "$TEMP_DIR/all_checksums.txt" | sort | uniq -d)
DUPLICATE_COUNT=0

for hash in $DUPLICATE_HASHES; do
    FILES=$(grep "^$hash " "$TEMP_DIR/all_checksums.txt" | awk '{$1=""; print $0}')
    echo "  Hash: $hash" >> "$REPORT_FILE"
    echo "  Files:$FILES" >> "$REPORT_FILE"
    COUNT=$(echo "$FILES" | wc -l)
    DUPLICATE_COUNT=$((DUPLICATE_COUNT + COUNT - 1))
done

echo "Total duplicate copies: $DUPLICATE_COUNT" | tee -a "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo " Backup Summary" >> "$REPORT_FILE"

awk '!seen[$1]++' "$TEMP_DIR/all_checksums.txt" > "$TEMP_DIR/unique_files.txt"
BACKUP_COUNT=0

while IFS= read -r line; do
    FILENAME=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ //')
    if [ -n "$FILENAME" ] && [ -f "$FILENAME" ]; then
        DEST_DIR="$BACKUP_DIR/$(dirname "$FILENAME")"
        mkdir -p "$DEST_DIR"
        cp "$FILENAME" "$DEST_DIR/" 2>>"$ERROR_FILE"
        if [ $? -eq 0 ]; then
            BACKUP_COUNT=$((BACKUP_COUNT + 1))
            echo "  Backed up: $FILENAME" >> "$REPORT_FILE"
        else
            echo "  ERROR: Failed to backup $FILENAME" | tee -a "$ERROR_FILE"
        fi
    fi
done < "$TEMP_DIR/unique_files.txt"

echo "Unique files backed up: $BACKUP_COUNT" >> "$REPORT_FILE"

echo "" >> "$REPORT_FILE"
echo "  Final Summary --" >> "$REPORT_FILE"
echo "  Date: $(date)" >> "$REPORT_FILE"
echo "  Total files: $TOTAL_FILES" >> "$REPORT_FILE"
echo "  Duplicates: $DUPLICATE_COUNT" >> "$REPORT_FILE"
echo "  Backed up: $BACKUP_COUNT" >> "$REPORT_FILE"

echo ""
echo "Report: $REPORT_FILE"
echo "Errors: $ERROR_FILE"

rm -rf "$TEMP_DIR"
exit 0
