# Project 2: Rate Monotonic Scheduling (RMS) in xv6

## Overview
Rate Monotonic Scheduling (RMS) is a real-time scheduling algorithm where:
- Each task is assigned a fixed priority based on its period
- Shorter period = Higher priority
- It is preemptive — higher priority task always runs first
- It is optimal among fixed-priority scheduling algorithms

## Files Modified / Created

| File | What was done |
|------|--------------|
| kernel/proc.h | Added period and priority fields to struct proc |
| kernel/proc.c | Initialized period and priority in allocproc(), modified scheduler() to pick highest priority process |
| kernel/syscall.h | Added syscall number 22 for setpriority |
| kernel/syscall.c | Registered sys_setpriority handler |
| kernel/sysproc_rms.c | Created — kernel handler for setpriority syscall |
| user/user.h | Added setpriority function declaration |
| user/usys.pl | Added setpriority trap entry |
| user/rmstest.c | Created — test program to demonstrate RMS |
| Makefile | Added sysproc_rms.o and rmstest |

## How It Works

### Priority Assignment
Each process calls setpriority(period) to set its period.
The kernel computes priority as:

priority = 1000 / period

So shorter period gives higher priority value.

### Scheduler Modification
The default xv6 round-robin scheduler was replaced with
a priority based scheduler that:
1. Scans all RUNNABLE processes
2. Picks the one with highest priority value
3. Runs it until it yields or blocks

### setpriority System Call
- Syscall number: 22
- Usage: setpriority(int period)
- Sets p->period and p->priority in the kernel
- Returns 0 on success, -1 on failure

## Task Configuration Used in Demo

| Task | Period | Priority | Burst |
|------|--------|----------|-------|
| T1   | 4      | 250      | 2     |
| T2   | 6      | 166      | 3     |
| T3   | 12     | 83       | 4     |

## Execution Output

<img width="603" height="884" alt="rmstest" src="https://github.com/user-attachments/assets/1f7bcdd2-c271-40da-a1f7-5cc42afe06a6" />

<img width="1375" height="734" alt="rms_output" src="https://github.com/user-attachments/assets/e878db40-847e-4108-9fbe-4090b529dad1" />

## How to Run

make clean

make qemu CPUS=1

rmstest

## Key Design Decisions

| Decision | Reason |
|----------|--------|
| priority = 1000/period | Simple formula — shorter period gives higher priority |
| Per process period field | Each process stores its own RMS period |
| Modified scheduler() | Replaces round-robin with priority based selection |
| CPUS=1 for demo | Single CPU ensures clean sequential output |


