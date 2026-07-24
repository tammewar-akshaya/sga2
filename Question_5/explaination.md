# Question 5 Explanation

When a file is being edited in `vi` and the system crashes, several recovery mechanisms can help. Swap files are the most useful because they automatically store the latest unsaved contents and allow recovery of the most recent editing session. Undo history is also helpful for small mistakes, but it may not be enough if the system crashed before the changes were saved.

Registers can restore copied or deleted text, while backup files preserve the previous version of the file before it was overwritten. The most reliable recovery strategy is to use the swap file first, because it contains the latest unsaved changes and is specifically designed for crash recovery. If the swap file is unavailable, backup files and undo history can be used as secondary recovery options.
