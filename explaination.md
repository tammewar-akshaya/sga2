# Explanation for the 5 Questions

## Question 1
This solution uses `find` to locate files, `md5sum` to generate checksums, and `sort | uniq -d` to identify duplicates. The script uses `cp` to back up unique files into `backup_unique`, while `>` and `>>` redirect output to the report and error files. Redirection `2>` is used to store errors separately, making the solution organized and easy to verify.

## Question 2
The program uses `fork()` to create child worker processes for the web server simulation. The parent uses `waitpid()` inside the `SIGCHLD` handler to reap finished children and prevent zombies. `SIGALRM` is used to detect timeout, and `SIGTERM` is sent to unresponsive children so the program can clean up safely.

## Question 3
`open()` creates or opens the employee database file, `write()` stores new records, and `lseek()` moves to the correct record position. `read()` retrieves records from any location efficiently, and `write()` is used again with `lseek()` to update one record in place without rewriting the whole file. `close()` finishes the file operation safely.

## Question 4
The monitoring pipeline uses `tail -f` to follow new log entries in real time, and `|` passes the output to `grep` to filter only `ERROR` lines. `>>` appends the filtered results to `error_report.txt`, while `2>/dev/null` suppresses unnecessary error messages. This makes the pipeline efficient and keeps the terminal output clean.

## Question 5
In `vi`, swap files are the best first recovery option because they store the latest unsaved changes automatically. Undo history is useful for small recent edits, registers help recover copied or deleted text, and backup files preserve the original file before overwrite. The most reliable strategy is to use the swap file first, then restore from backup if needed, because it is automatic and preserves the most recent work.
