# Project 2: Scheduling Changes in xv6

This xv6 tree is focused on scheduling behavior. The kernel code in this
project implements a lottery scheduler in place of the default xv6 runnable
process selection logic.

## Implemented Scheduler

### Lottery Scheduling

The active scheduler implementation is in [kernel/proc.c](/home/abbas/Desktop/xv6-riscv/G12_Project2_2/kernel/proc.c) and uses per-process ticket counts to choose the next runnable process.

Relevant code-level changes:

- [kernel/proc.h](/home/abbas/Desktop/xv6-riscv/G12_Project2_2/kernel/proc.h) adds:
  - `tickets`
  - `sched_count`
- [kernel/proc.c](/home/abbas/Desktop/xv6-riscv/G12_Project2_2/kernel/proc.c) initializes:
  - `tickets = 10`
  - `sched_count = 0`
- Child processes inherit the parent ticket count during `fork`.
- The scheduler:
  - scans the `RUNNABLE` processes
  - sums their effective ticket counts
  - draws a winning ticket with `krand()`
  - selects the process whose cumulative ticket range contains that draw
  - increments `sched_count` when the process is chosen to run
