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

<img width="1710" height="1112" alt="Code1" src="https://github.com/user-attachments/assets/77a61750-9e24-4479-93fc-5b9f68376b41" />


## Output:

Child got from pid 3: hello child

Parent broadcast to 3 processes

<img width="1710" height="1112" alt="Output1" src="https://github.com/user-attachments/assets/c05bb732-7608-4b6c-a653-5b0ad2fbb52e" />

---

## Execution 2 — broadcast to multiple processes

Parent forks two children, both blocking on recvmsg.

Parent broadcasts "hello everyone" to all running processes.

Both children wake up and print the received message.

<img width="1710" height="1112" alt="Code2" src="https://github.com/user-attachments/assets/855ebaa6-7a68-4e03-84b0-cefedbe573e7" />


## Output:

Parent broadcast to 4 processes

Child 1 got broadcast from pid 3: hello everyone

Child 2 got broadcast from pid 3: hello everyone

<img width="1710" height="1112" alt="Output2" src="https://github.com/user-attachments/assets/c772b880-60cb-4ca6-9872-25a9a5520ae6" />

---

## How to Run
make clean

make qemu CPUS=1

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

