# Question 2 Explanation

The program uses `fork()` to create multiple child processes, where each child simulates a web worker handling a request. The parent process manages these children by keeping track of their status and monitoring their execution. This design allows the system to work in parallel and gives the parent control over how long each child is allowed to run.

Process creation, waiting, and signal handling work together to solve the problem effectively. The `SIGCHLD` handler uses `waitpid()` to reap finished child processes and prevent zombies from accumulating. The `SIGALRM` signal is used as a timeout mechanism, and `SIGTERM` is sent to children that remain unresponsive so the program can terminate them safely and finish cleanup.
