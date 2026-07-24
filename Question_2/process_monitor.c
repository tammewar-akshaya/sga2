#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <signal.h>
#include <string.h>
#include <time.h>
#include <errno.h>

#define MAX_CHILDREN 5
#define TIMEOUT_SECONDS 8
#define CHECK_INTERVAL 2

pid_t child_pids[MAX_CHILDREN];
int child_status[MAX_CHILDREN]; // 0=running, 1=finished
int child_count = 0;

void sigchld_handler(int signo) {
    int saved_errno = errno;
    pid_t pid;
    int status;

    while ((pid = waitpid(-1, &status, WNOHANG)) > 0) {
        if (WIFEXITED(status)) {
            printf("\n[SIGCHLD] Child PID %d exited normally with status %d\n",
                   pid, WEXITSTATUS(status));
        } else if (WIFSIGNALED(status)) {
            printf("\n[SIGCHLD] Child PID %d was killed by signal %d\n",
                   pid, WTERMSIG(status));
        }

        // Mark as finished in tracking array
        for (int i = 0; i < child_count; i++) {
            if (child_pids[i] == pid) {
                child_status[i] = 1;
                break;
            }
        }
    }
    errno = saved_errno;
}

void sigalrm_handler(int signo) {
    printf("\n[SIGALRM] Timeout! Terminating unresponsive children...\n");
    for (int i = 0; i < child_count; i++) {
        if (child_status[i] == 0 && kill(child_pids[i], 0) == 0) {
            printf("[SIGALRM] Sending SIGTERM to PID %d\n", child_pids[i]);
            kill(child_pids[i], SIGTERM);
        }
    }
}

void simulate_web_worker(int worker_id) {
    srand(time(NULL) ^ (getpid() * (worker_id + 1)));
    int work_time = (rand() % 10) + 2;  // Random: 2 to 12 seconds

    printf("[Child PID %d] Worker %d: processing request (%d seconds)...\n",
           getpid(), worker_id, work_time);

    // Simulate processing. sleep() returns remaining time if interrupted.
    int remaining = work_time;
    while (remaining > 0) {
        remaining = sleep(remaining);
    }

    printf("[Child PID %d] Worker %d: completed successfully.\n",
           getpid(), worker_id);
    exit(0);
}

// Main Function
int main() {
    printf(" Web Server Process Monitor \n");
    printf("Parent PID: %d | Workers: %d | Timeout: %ds\n\n",
           getpid(), MAX_CHILDREN, TIMEOUT_SECONDS);

    struct sigaction sa;

    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigchld_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_NOCLDSTOP;
    sigaction(SIGCHLD, &sa, NULL);
    printf("[Parent] SIGCHLD handler installed — zombies will be auto-reaped.\n");

    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = sigalrm_handler;
    sigemptyset(&sa.sa_mask);
    sigaction(SIGALRM, &sa, NULL);
    printf("[Parent] SIGALRM handler installed — timeout = %d seconds.\n\n", TIMEOUT_SECONDS);

    // Step 2: Create child processes -
    printf("Creating Child Processes\n");
    for (int i = 0; i < MAX_CHILDREN; i++) {
        pid_t pid = fork();

        if (pid < 0) {
            perror("fork failed");
            break;
        }

        if (pid == 0) {
            // CHILD: Run worker function (never returns)
            simulate_web_worker(i + 1);
        }

        child_pids[i] = pid;
        child_status[i] = 0;
        child_count = i + 1;
        printf("[Parent] Created worker %d (PID %d)\n", i + 1, pid);
    }

    printf("\nAll %d children created. Starting monitor loop...\n\n", child_count);

    //Step 3: Monitor children
    printf("-- Monitoring (checking every %ds, timeout %ds) -----\n",
           CHECK_INTERVAL, TIMEOUT_SECONDS);

    alarm(TIMEOUT_SECONDS);
    int all_done = 0;

    while (!all_done) {
        all_done = 1;
        printf("[Monitor] Checking status...\n");

        for (int i = 0; i < child_count; i++) {
            if (child_status[i] == 0) {
                if (kill(child_pids[i], 0) == 0) {
                    printf("  Worker %d (PID %d): RUNNING\n", i + 1, child_pids[i]);
                    all_done = 0;
                } else {
                    // Process died without SIGCHLD catching it
                    child_status[i] = 1;
                    printf("  Worker %d (PID %d): GONE\n", i + 1, child_pids[i]);
                }
            } else {
                printf("  Worker %d (PID %d): DONE\n", i + 1, child_pids[i]);
            }
        }

        if (!all_done) {
            printf("[Monitor] Next check in %ds...\n\n", CHECK_INTERVAL);
            sleep(CHECK_INTERVAL);
        }
    }

    printf("\n Final Cleanup\n");
    pid_t zombie;
    int z_status;
    while ((zombie = waitpid(-1, &z_status, WNOHANG)) > 0) {
        printf("Reaped stray child PID %d\n", zombie);
    }
    printf("\n Summary ---\n");
    for (int i = 0; i < child_count; i++) {
        printf("  Worker %d (PID %d): %s\n",
               i + 1, child_pids[i],
               child_status[i] ? "Finished" : "Unknown");
    }
    printf("Children created: %d\n", child_count);
    printf("Zombie processes: 0 (all reaped)\n");

    return 0;
}
