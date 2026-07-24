#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>

#define NAME_LENGTH 32
#define DEPT_LENGTH 16
#define MAX_RECORDS 5
#define DB "employees.db"

typedef struct {
    int id;                        //  4 bytes
    char name[NAME_LENGTH];        // 32 bytes
    char department[DEPT_LENGTH];  // 16 bytes
    float salary;                  //  4 bytes
    int active;                    //  4 bytes (1=active, 0=deleted)
} EmployeeRecord;                  // TOTAL: 60 bytes per record

// open()   → Creates a new database file

int create_database() {
    int fd = open(DB, O_CREAT | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR);
    if (fd == -1) {
        perror("open() failed");
        return -1;
    }
    printf("[open] Created '%s' (fd=%d)\n", DB, fd);
    return fd;
}

// write() - Writes one record to the current file position
// Returns the number of bytes written. Must equal sizeof(record). & If less, the disk may be full or an error occurred.
int write_record(int fd, EmployeeRecord *rec) {
    ssize_t written = write(fd, rec, sizeof(EmployeeRecord));
    if (written != sizeof(EmployeeRecord)) {
        perror("write() failed");
        return -1;
    }
    printf("[write] ID %d: %s | %s | $%.2f (%ld bytes)\n",
           rec->id, rec->name, rec->department, rec->salary, (long)written);
    return 0;
}

// lseek() + read() - Reads a specific record by number
// lseek: moves file cursor to calculated offset (rec# × sizeof(record))
// SEEK_SET means offset from file beginning
// read: reads exactly sizeof(record) bytes at that position
int read_record_at(int fd, int rec_num, EmployeeRecord *rec) {
    off_t offset = (off_t)rec_num * sizeof(EmployeeRecord);
    off_t new_pos = lseek(fd, offset, SEEK_SET);

    if (new_pos == -1) {
        perror("lseek() failed");
        return -1;
    }
    printf("[lseek] Jumped to record %d (offset=%ld, position=%ld)\n",
           rec_num, (long)offset, (long)new_pos);

    ssize_t bytes = read(fd, rec, sizeof(EmployeeRecord));
    if (bytes != sizeof(EmployeeRecord)) {
        if (bytes == 0) printf("  -> EOF (no record)\n");
        else perror("read() failed");
        return -1;
    }
    printf("[read] Record %d: ID=%d, %s, %s, $%.2f (%ld bytes)\n",
           rec_num, rec->id, rec->name, rec->department, rec->salary, (long)bytes);
    return 0;
}

// lseek() + write() - Updates a record IN-PLACE &  Only rewrites 60 bytes — does NOT touch other records.
// This is the key efficiency advantage over reading/writing the entire file.
int update_record(int fd, int rec_num, EmployeeRecord *rec) {
    off_t offset = (off_t)rec_num * sizeof(EmployeeRecord);

    if (lseek(fd, offset, SEEK_SET) == -1) {
        perror("lseek() for update failed");
        return -1;
    }

    ssize_t written = write(fd, rec, sizeof(EmployeeRecord));
    if (written != sizeof(EmployeeRecord)) {
        perror("write() for update failed");
        return -1;
    }

    printf("[update] Record %d updated in-place — only 60 bytes written\n", rec_num);
    printf("  Now: ID=%d, %s, %s, $%.2f\n",
           rec->id, rec->name, rec->department, rec->salary);
    return 0;
}

int display_all(int fd) {
    EmployeeRecord rec;
    lseek(fd, 0, SEEK_SET);

    printf("\n-- All Active Employees -----\n");
    printf("%-5s %-22s %-14s %s\n", "ID", "Name", "Department", "Salary");
    printf("---------------------------------------------\n");

    int count = 0;
    while (read(fd, &rec, sizeof(EmployeeRecord)) == sizeof(EmployeeRecord)) {
        if (rec.active) {
            printf("%-5d %-22s %-14s $%.2f\n",
                   rec.id, rec.name, rec.department, rec.salary);
            count++;
        }
    }
    printf("---------------------------------------------\n");
    printf("Active employees: %d\n\n", count);

    lseek(fd, 0, SEEK_SET);
    return count;
}

// Retrieve record by employee ID (random access demonstration)
int find_by_id(int fd, int target_id) {
    EmployeeRecord rec;
    off_t size = lseek(fd, 0, SEEK_END);
    int total = size / sizeof(EmployeeRecord);

    printf("Searching for ID %d in %d records (%ld bytes)...\n",
           target_id, total, (long)size);

    for (int i = 0; i < total; i++) {
        lseek(fd, (off_t)i * sizeof(EmployeeRecord), SEEK_SET);
        read(fd, &rec, sizeof(EmployeeRecord));
        if (rec.id == target_id && rec.active) {
            printf("  FOUND (record %d): %s | %s | $%.2f\n",
                   i, rec.name, rec.department, rec.salary);
            lseek(fd, 0, SEEK_SET);
            return i;
        }
    }
    printf("  NOT FOUND: ID %d\n", target_id);
    lseek(fd, 0, SEEK_SET);
    return -1;
}

// Soft delete: marks active=0 without removing data
void soft_delete(int fd, int rec_num) {
    EmployeeRecord rec;
    off_t offset = (off_t)rec_num * sizeof(EmployeeRecord);

    lseek(fd, offset, SEEK_SET);
    read(fd, &rec, sizeof(EmployeeRecord));
    printf("[delete] Record %d (ID %d: %s) marked as inactive\n",
           rec_num, rec.id, rec.name);

    rec.active = 0;
    lseek(fd, offset, SEEK_SET);
    write(fd, &rec, sizeof(EmployeeRecord));
}

// MAIN
int main() {
    printf(" File Utility (open/read/write/lseek/close) ---\n");
    printf("  Record size: %lu bytes\n\n", sizeof(EmployeeRecord));

    int fd;

    printf("=== PHASE 1: Create Database ===\n");

    fd = create_database();
    if (fd == -1) return 1;

    EmployeeRecord employees[MAX_RECORDS] = {
        {101, "Alice Johnson",   "Engineering", 75000.0f, 1},
        {102, "Bob Smith",       "Marketing",   65000.0f, 1},
        {103, "Carol Davis",     "Finance",     70000.0f, 1},
        {104, "David Wilson",    "Engineering", 80000.0f, 1},
        {105, "Eve Martinez",    "HR",          60000.0f, 1}
    };

    for (int i = 0; i < MAX_RECORDS; i++) {
        if (write_record(fd, &employees[i]) != 0) {
            close(fd);
            return 1;
        }
    }
    printf("\nWrote %d records. File should be %ld bytes.\n\n",
           MAX_RECORDS, (long)(MAX_RECORDS * sizeof(EmployeeRecord)));

    printf("\n[Phase 2] Close & Reopen\n");
    close(fd);
    printf("[close] fd closed.\n");
    fd = open(DB, O_RDWR);
    printf("[open] Reopened '%s' (fd=%d)\n\n", DB, fd);

    printf("=== PHASE 3: Random Access (lseek + read) ===\n");
    EmployeeRecord rec;
    read_record_at(fd, 2, &rec);  // Direct jump to Carol
    read_record_at(fd, 0, &rec);  // Jump back to Alice
    printf("\n");

    printf("=== PHASE 4: Update Record Without File Rewrite ===\n");
    EmployeeRecord updated = {102, "Bob Smith", "Marketing", 72000.0f, 1};
    update_record(fd, 1, &updated);  // Only writes 60 bytes

    // Verify the update
    read_record_at(fd, 1, &rec);
    printf("\n");

    printf("=== PHASE 5: Display All Records ===\n");
    display_all(fd);

    printf("=== PHASE 6: Find by ID (Random Access) ===\n");
    find_by_id(fd, 101);
    find_by_id(fd, 104);
    printf("\n");

    printf("=== PHASE 7: Soft Delete ===\n");
    soft_delete(fd, 3);  // Delete David Wilson
    printf("\n");

    printf("=== Final Employee List (After Delete) ===\n");
    display_all(fd);

    close(fd);
    printf("[close] File closed. Program complete.\n");
    return 0;
}
