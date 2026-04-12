# xv6 Kernel Enhancements: Documentation

This document summarizes the custom features and enhancements integrated into the xv6-riscv kernel across Project 1 and Project 2.

---

## Project 1: Custom System Calls
The core focus of Project 1 was expanding the kernel's capabilities with advanced inter-process communication (IPC) and process utility system calls.

### Syscall Infrastructure
- **Syscall Group**: All new syscalls are registered in the range 22-37 to prevent conflicts with standard xv6 calls.
- **Header Synchronization**: Standardized header inclusion order and added include guards to prevent redefinitions across kernel and user space.

### 1. User Locks
New syscalls for managing user-level locks with kernel-level tracking:
- `lock_init(id, name)`: Initializes a new user lock with a unique ID and descriptive name.
- `lock_acquire(id)`: Attempts to acquire the specified lock, blocking if currently held.
- `lock_release(id)`: Releases a held lock, waking up any waiting processes.

### 2. Message Queues (IPC)
A robust messaging system for inter-process communication:
- `msgget(key, flags)`: Creates or retrieves a message queue based on a numeric key.
- `msgsnd(msqid, msgp, msgsz, msgflg)`: Sends a message to the specified queue.
- `msgrcv(msqid, msgp, msgsz, msgtyp, msgflg)`: Receives a message from the queue.
- `msgctl(msqid, cmd, buf)`: Performs control operations (e.g., removal) on the queue.

### 3. Process Utilities
Enhanced system calls for process management and signaling:
- `getprocinfo(pinfo)`: Copies process table data to user space for monitoring.
- `sleep2(ticks)`: An improved sleep mechanism for precise timing.
- `sigsend(pid, signal)`: Sends a specific signal to a target process.
- `sigresv(handler)`: Registers a user-defined signal handler for the current process.
- `shmctl(shmid, cmd, buf)`: Shared memory control operations.

---

## Project 2: Lottery Scheduler
Project 2 replaced the default round-robin scheduler with a lottery-based scheduling algorithm.

### 1. Ticket-Based Selection
- **Process Structure**: Each process in `struct proc` now includes `tickets` and `sched_count`.
- **Initialization**: Every process is initialized with 10 tickets by default in `allocproc()`.
- **Inheritance**: Child processes inherited the same number of tickets as their parent in `kfork()`.
- **Winning Draw**: The `scheduler()` function calculates the total number of tickets across all `RUNNABLE` processes and performs a random draw using a custom `krand()` generator. The process that "holds" the winning ticket is selected for execution.

### 2. Random Number Generation
- **`krand()`**: A linear congruential generator implemented in `kernel/proc.c` provides the randomness required for the lottery draw.

### 3. Kernel Stabilization
- **Header Guards**: Added `#ifndef __ASSEMBLER__` and symbolic guards to `types.h`, `param.h`, `riscv.h`, `spinlock.h`, and `proc.h`.
- **Type Dependencies**: Ensured `uint64`, `pagetable_t`, and other core types are correctly visible across all kernel components.

---

## Technical Details
- **Build System**: All changes are integrated into the standard xv6 `Makefile`.
- **CPUs**: The scheduler is designed to work with variable CPU counts, but optimal fairness is achieved on single-core (`CPUS=1`) configurations (common in lottery scheduling simulations).
