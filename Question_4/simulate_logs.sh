LOG_FILE="./server.log"
> "$LOG_FILE"  # Clear the file

echo "Generating 20 log entries with mixed INFO/WARNING/ERROR..."

for i in $(seq 1 20); do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    LEVEL="INFO"
    MESSAGE="Request processed successfully (endpoint /api/v$((RANDOM % 5)))"

    if [ $((RANDOM % 4)) -eq 0 ]; then
        LEVEL="ERROR"
        case $((RANDOM % 3)) in
            0) MESSAGE="Connection timeout from 192.168.1.$((RANDOM % 255))" ;;
            1) MESSAGE="Database connection pool exhausted" ;;
            2) MESSAGE="Disk space low on /var/log" ;;
        esac
    elif [ $((RANDOM % 5)) -eq 0 ]; then
        LEVEL="WARNING"
        MESSAGE="Response time exceeded threshold: $((RANDOM % 5000 + 1000))ms"
    fi

    echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" | tee -a "$LOG_FILE"
    sleep 0.3
done

echo ""
echo "=== Generation Complete ==="
echo "Total entries: $(wc -l < "$LOG_FILE")"
echo "ERROR entries: $(grep -c '\[ERROR\]' "$LOG_FILE")"
echo "WARNING entries: $(grep -c '\[WARNING\]' "$LOG_FILE")"
echo "INFO entries: $(grep -c '\[INFO\]' "$LOG_FILE")"
