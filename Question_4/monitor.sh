LOG_FILE="./server.log"
ERROR_REPORT="./error_report.txt"

if [ ! -f "$LOG_FILE" ]; then
    echo "ERROR: $LOG_FILE not found. Run simulate_logs.sh first."
    exit 1
fi

echo " Demo 1: Display All Log Entries ---"
echo "Command: cat $LOG_FILE"
cat "$LOG_FILE"

TOTAL=$(wc -l < "$LOG_FILE")
ERRS=$(grep -c '\[ERROR\]' "$LOG_FILE")
WARN=$(grep -c '\[WARNING\]' "$LOG_FILE")
INFO=$((TOTAL - ERRS - WARN))
echo "Log: $TOTAL total | $INFO INFO | $WARN WARN | $ERRS ERROR"
echo ""

echo " Demo 2: Extract ERROR Messages ---"
echo "Command: grep -n '\[ERROR\]' $LOG_FILE"
grep -n '\[ERROR\]' "$LOG_FILE"
echo "Total ERROR lines: $ERRS"
echo ""

echo " Demo 3: Save Errors to Separate Report ---"
echo "Command: grep '\[ERROR\]' $LOG_FILE > $ERROR_REPORT"
grep '\[ERROR\]' "$LOG_FILE" > "$ERROR_REPORT"
echo "Error report saved ($(wc -l < "$ERROR_REPORT") entries):"
cat "$ERROR_REPORT"
echo ""

echo " Demo 4: The Production Pipeline ---"
echo ""
echo "Full pipeline a sysadmin would run:"
echo "  tail -f $LOG_FILE | grep --line-buffered \"[ERROR]\" >> $ERROR_REPORT 2>/dev/null &"
echo ""
echo "How it works:"
echo "  tail -f           Follows file — outputs new lines as they're written"
echo "  |                 Pipe — sends data between commands in memory"
echo "  grep --line-buffered  Filters for [ERROR] with zero buffering delay"
echo "  >> $ERROR_REPORT  Appends — preserves all previous error history"
echo "  2>/dev/null       Suppresses stderr (tail/grep warnings)"
echo ""

echo " Demo 5: /dev/null (Suppress Output) "
echo "Command: ls nonexistent 2>/dev/null"
ls nonexistent 2>/dev/null
echo "(Error message was discarded — terminal stayed clean)"
echo ""

echo " Monitoring Summary "
echo "Log file    : $LOG_FILE ($(wc -l < "$LOG_FILE") entries)"
echo "Error report: $ERROR_REPORT ($(wc -l < "$ERROR_REPORT") entries)"
echo ""
echo "Filter efficiency: $ERRS ERROR out of $TOTAL total lines"

exit 0
