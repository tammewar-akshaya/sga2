# Question 1 Explanation

This solution uses several Linux shell commands to handle file management in a reliable and automated way. The `find` command searches the submission directory for all files, while `md5sum` creates a checksum for each file so identical content can be detected accurately. The `sort | uniq -d` pipeline helps identify duplicate files by comparing checksum values, and the script uses `cp` to back up only the unique files into the backup directory.

Redirection operators are also important in this solution. The `>` and `>>` operators are used to create and update the report file, while `2>` sends error messages to `errors.log` so that normal output remains clean and separate. These techniques make the script efficient, organized, and suitable for handling a large number of student submissions.
