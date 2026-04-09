# OS_Project
Operating System Course Project - Development and Implementation of new system calls and scheduling algorithms.

# 1)xv6 Message Passing System Calls

## Overview
This project implements three new system calls in xv6-riscv for inter-process 
communication (IPC) using message passing:
- sendmsg
- recvmsg  
- broadcast

---

## Files Modified / Created

| File | What was done |
|------|--------------|
| kernel/msgqueue.h | Created — defines message and msgqueue data structures |
| kernel/proc.h | Added msgqueue field to struct proc |
| kernel/proc.c | Initialized message queue in allocproc() |
| kernel/sysmsg.c | Created — kernel handlers for all 3 syscalls |
| kernel/syscall.h | Added syscall numbers 22, 23, 24 |
| kernel/syscall.c | Registered syscall handlers |
| user/user.h | Added function declarations for user programs |
| user/usys.pl | Added trap entries for syscalls |
| user/msgtest.c | Created — test program to demonstrate syscalls |
| Makefile | Added sysmsg.o and msgtest |

---

## System Calls Implemented

### 1. sendmsg(int pid, char *buf, int size)
Sends a message directly to a specific process identified by its PID.
The message is copied from user space into the target process's 
message queue in the kernel.
Returns 0 on success, -1 on failure.

### 2. recvmsg(char *buf, int size)
Receives a message from the calling process's own message queue.
If no message is available, the process blocks (sleeps) until 
a message arrives.
Returns the sender's PID on success, -1 on failure.

### 3. broadcast(char *buf, int size)
Sends the same message to ALL currently running processes 
except the sender itself.
And most importantly it also broadcasts to 2 background running processes as shown below :-
 sh -> the xv6 shell
 init -> the init process(xv6 invoke this first process when it boots and then starts 'sh' shell)
Returns the number of processes the message was sent to.

---

## How It Works Internally

Each process has its own message queue (struct msgqueue) stored 
inside struct proc in the kernel.

The queue is a circular buffer with:
- Maximum 16 messages at a time
- Each message up to 256 bytes
- A spinlock for thread safety
- sleep/wakeup for blocking receive

---

## Execution 1 — sendmsg and recvmsg

Parent process forks a child.
Parent sends "hello child" directly to child using sendmsg.
Child was blocked on recvmsg, wakes up and prints the message.
Parent then broadcasts to all running processes.

[Insert Code1 Screenshot here]

Output:
Child got from pid 3: hello child
Parent broadcast to 3 processes

[Insert output1 ss here]
---

## Execution 2 — broadcast to multiple processes

Parent forks two children, both blocking on recvmsg.
Parent broadcasts "hello everyone" to all running processes.
Both children wake up and print the received message.

[Insert Code2 Screenshot here]

Output:
Parent broadcast to 4 processes
Child 1 got broadcast from pid 3: hello everyone
Child 2 got broadcast from pid 3: hello everyone

[Insert output2 ss here]
---

## How to Run
make clean
make qemu
msgtest (inside shell)

---

## Key Design Decisions

| Decision | Reason |
|----------|--------|
| Per-process queue | Each process owns its own mailbox, simpler locking |
| sleep/wakeup for blocking | Reuses xv6 existing sync mechanism |
| copyin/copyout for data | Safe memory copy across user-kernel boundary |
| recvmsg returns sender PID | Receiver can identify who sent the message |
| broadcast skips self | Prevents process from messaging itself |

