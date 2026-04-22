# Project 2: Scheduling Changes

This tree keeps the `integrated-kernel` project2 scheduler unchanged.

## Included Reference Files

- [mlfq.c](/home/abbas/Desktop/xv6-riscv/G12_Project2_2/mlfq.c): standalone MLFQ mock simulation from `24je0651`
- [user/rmstest.c](/home/abbas/Desktop/xv6-riscv/G12_Project2_2/user/rmstest.c): RMS demo source from `Yashwanth`

These files are included for reference only. They do not change the active kernel scheduler in this tree.

## Active Scheduler

The active kernel scheduler remains the original `integrated-kernel` project2 implementation in [kernel/proc.c](/home/abbas/Desktop/xv6-riscv/G12_Project2_2/kernel/proc.c).

## Build

From this directory:

```bash`
make qemu
```
