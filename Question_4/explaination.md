# Question 4 Explanation

This monitoring solution uses a simple but powerful pipeline of Linux commands. The `tail -f` command follows the log file in real time so new entries are displayed as soon as they appear. The pipe operator `|` sends this output to `grep`, which filters only the lines containing `[ERROR]`, making the output much more focused and useful for system administration.

The `>>` redirection operator appends the filtered error messages to a separate report file, so previous errors are preserved. The `2>/dev/null` redirection is used to hide unnecessary error messages from the terminal, keeping the output clean. Together, these tools make the monitoring process efficient, automated, and easy to maintain.
