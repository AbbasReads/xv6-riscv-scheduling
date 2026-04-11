# Project 1: Custom System Calls in xv6 (Shared Memory)

---

## Introduction
This project implements shared memory system calls in the xv6 operating system.
Shared memory allows multiple processes to communicate by accessing the same
memory region, which is a form of Inter-Process Communication (IPC).

---

## System Calls Implemented

### 1. shmget(int id, int size)
- Creates a new shared memory segment
- Returns the shared memory id on success, -1 on failure

### 2. shmat(int id)
- Attaches shared memory segment to process virtual address space
- Returns virtual address of shared memory on success, -1 on failure

### 3. shmdt(int id)
- Detaches shared memory segment from process
- Returns 0 on success, -1 on failure

### 4. shmctl(int id)
- Deletes shared memory segment when no process is using it
- Returns 0 on success, -1 on failure

---

## Files Modified

| File | Changes Made |
|------|-------------|
| kernel/proc.h | Added sharedmem struct and MAX_SHAREDMEM definition |
| kernel/defs.h | Added shared memory function declarations |
| kernel/syscall.h | Added syscall numbers for shared memory calls |
| kernel/syscall.c | Registered shared memory syscalls |
| kernel/sysproc.c | Implemented shared memory syscall logic |
| user/usys.pl | Added user space stubs |
| user/user.h | Added user space declarations |
| user/shmtest.c | Demo program for shared memory |
| Makefile | Added shmtest to build |

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
git checkout meghana-branch
cd G12_Project1_xv6CustomizeSystemCalls

# Build and run xv6
make qemu

# Inside xv6 shell run
$ shmtest
```

---

## Expected Output
shmget: created shared memory with id 1

shmat: attached shared memory at address 0x0000000000004000

wrote to shared memory: Hi!

shmdt: detached shared memory

shmctl: deleted shared memory

Shared memory test complete!

---

 ## shmtest program
<img width="1905" height="1016" alt="shmtest_program" src="https://github.com/user-attachments/assets/a33a85a9-1b8d-4b53-9269-bdfbb216c86a" />

 ## output
<img width="1915" height="1007" alt="shmtest_output" src="https://github.com/user-attachments/assets/fb00084b-06e7-4b0a-960a-c650bedff85f" /> 

---

## How Shared Memory Works in xv6

1. **shmget** allocates a physical memory page using kalloc()
2. **shmat** maps physical page to process virtual address space using mappages()
3. Process can read/write to virtual address directly
4. **shmdt** decrements reference count
5. **shmctl** frees physical memory using kfree() when refcount is 0

---

## References
- xv6 RISC-V book: https://pdos.csail.mit.edu/6.828/2023/xv6/book-riscv-rev3.pdf
- MIT xv6 source: https://github.com/mit-pdos/xv6-riscv
- xv6 system call implementation guide
