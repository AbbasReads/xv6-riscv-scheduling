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





# Project 2: MLFQ Scheduling

## Overview

This program implements the Multilevel Feedback Queue (MLFQ) scheduling algorithm using a simple array-based approach.

It simulates how processes are scheduled across multiple priority queues based on their CPU usage.

---

## Algorithm

The scheduler uses 3 queues:

* Q0 → Time slice = 1 (highest priority)
* Q1 → Time slice = 2
* Q2 → Time slice = 4 (lowest priority)

### Working:

* All processes start in Q0
* If a process uses its full time slice → it is moved to a lower queue
* Scheduler always selects from the highest priority queue available

---

## Input

Processes used:

```
P1: AT=0, BT=5
P2: AT=1, BT=3
P3: AT=2, BT=4
```

---

## Output

### Timeline

```
| T0:P1(Q0) | T1:P2(Q0) | T2:P3(Q0) | T3:P1(Q1) | T4:P1(Q1) |
| T5:P2(Q1) | T6:P2(Q1) | T7:P3(Q1) | T8:P3(Q1) |
| T9:P1(Q2) | T10:P1(Q2) | T11:P3(Q2) |
```

---

### Metrics

* Completion Time (CT)
* Turnaround Time (TAT = CT - AT)
* Waiting Time (WT = TAT - BT)

Average values:

* Average Turnaround Time = 9.00
* Average Waiting Time = 5.00

---

## How to Run

```
gcc mlfq.c -o mlfq
./mlfq
```

---

## Key Features

* Array-based implementation
* Multiple priority queues
* Dynamic priority adjustment (demotion)
* Clear timeline visualization
* Performance metrics calculation
