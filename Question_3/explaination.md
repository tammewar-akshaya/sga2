# Question 3 Explanation

The file-processing utility uses Linux system calls instead of standard library functions to directly manage data on disk. The `open()` system call creates or opens the database file, while `write()` writes employee records into the file at the current position. The program stores each employee record in a fixed-size structure so every record has a known length and can be accessed easily.

The `lseek()` system call is important because it moves the file pointer to any desired record position without reading the entire file. This makes random access possible, which is useful for reading, updating, or deleting specific records quickly. `read()` retrieves the selected record from that location, and `close()` safely ends the file operation. This approach is efficient because records can be updated in place without rewriting the whole database.
