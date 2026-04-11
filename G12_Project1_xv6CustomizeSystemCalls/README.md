# Project 1: Custom System Calls in xv6 (User Space Locks)

---

## Introduction
This project implements user space lock system calls in the xv6 operating
system. Locks are synchronization primitives that prevent multiple processes
from accessing shared resources simultaneously, avoiding race conditions.

---

## System Calls Implemented

### 1. lockinit(int id)
- Initializes a new lock with given id
- Returns lock id on success, -1 on failure

### 2. lockacquire(int id)
- Acquires the lock with given id
- Returns 0 on success, -1 if lock already held

### 3. lockrelease(int id)
- Releases the lock with given id
- Returns 0 on success, -1 if lock not held

### 4. locktry(int id)
- Tries to acquire lock without blocking
- Returns 1 on success, 0 if lock already held

### 5. lockcheck(int id)
- Checks if lock is currently held
- Returns 1 if held, 0 if free, -1 if invalid

---

## Files Modified

| File | Changes Made |
|------|-------------|
| kernel/proc.h | Added userlock struct and MAX_LOCKS definition |
| kernel/defs.h | Added lock function declarations |
| kernel/syscall.h | Added syscall numbers for lock calls |
| kernel/syscall.c | Registered lock syscalls |
| kernel/sysproc.c | Implemented lock syscall logic |
| user/usys.pl | Added user space stubs |
| user/user.h | Added user space declarations |
| user/locktest.c | Demo program for locks |
| Makefile | Added locktest to build |

---

## How to Run

### Prerequisites
- RISC-V gcc compiler
- QEMU emulator
- make

### Steps
```bash
# Clone the repository
git clone https://github.com/AbbasReads/xv6-riscv-scheduling.git
cd xv6-riscv-scheduling
git checkout satya-branch
cd G12_Project1_xv6CustomizeSystemCalls

# Build and run xv6
make qemu

# Inside xv6 shell run
$ locktest
```

---

## Expected Output
lockinit: lock 1 initialized

lockcheck: lock held? 0 (0=free)

lockacquire: lock 1 acquired

lockcheck: lock held? 1 (1=held)

locktry: tried to acquire held lock, result: 0 (0=failed as expected)

lockrelease: lock 1 released

locktry: tried to acquire free lock, result: 1 (1=success)

Lock test complete!

---

## Screenshot
[Attach screenshot of execution here]

---

## How Locks Work in xv6

1. **lockinit** creates a lock entry in locktable[]
2. **lockacquire** sets held=1 and stores process pid
3. Process safely accesses shared resource
4. **lockrelease** sets held=0 and clears pid
5. **locktry** checks and acquires atomically without blocking
6. **lockcheck** reads current held status

---

## References
- xv6 RISC-V book: https://pdos.csail.mit.edu/6.828/2023/xv6/book-riscv-rev3.pdf
- MIT xv6 source: https://github.com/mit-pdos/xv6-riscv
- xv6 system call implementation guide
