# Project 2: MLFQ Scheduling in xv6

## Student Details
- **Name:** Satyakanth
- **Branch:** satya-branch
- **Project:** Multilevel Feedback Queue (MLFQ) Scheduling

---

## Introduction
This project implements the Multilevel Feedback Queue (MLFQ) scheduling
algorithm in the xv6 operating system. MLFQ manages process execution
by dynamically adjusting process priorities based on their CPU usage behavior.

---

## How MLFQ Works

Queue 0 (Highest Priority) → quantum = 1 tick
Queue 1 (Medium Priority)  → quantum = 2 ticks
Queue 2 (Lowest Priority)  → quantum = 4 ticks

All processes start at Queue 0
If process uses full quantum → moves down to lower queue
CPU bound processes sink to lower queues
IO bound processes stay at higher queues

---

## Files Modified

| File | Changes Made |
|------|-------------|
| kernel/proc.h | Added MLFQ fields to proc struct |
| kernel/proc.c | Implemented MLFQ scheduler |
| kernel/trap.c | Added quantum handling on timer interrupt |
| user/mlfqtest.c | Demo program for MLFQ |
| Makefile | Added mlfqtest to build |

---

## How to Run

### Steps
```bash
# Clone the repository
git clone https://github.com/AbbasReads/xv6-riscv-scheduling.git
cd xv6-riscv-scheduling
git checkout satya-branch
cd G12_Project2_2

# Build and run xv6 with single CPU
make qemu CPUS=1

# Inside xv6 shell run
$ mlfqtest
```

---

## Performance Metrics

| Process Type | Starting Queue | Final Queue | Behavior |
|-------------|---------------|-------------|----------|
| CPU Bound | Queue 0 | Queue 2 | Demoted due to full quantum usage |
| IO Bound | Queue 0 | Queue 0 | Stays due to frequent yields |

---

## Screenshot
[Attach screenshot of execution here]

---

## References
- xv6 RISC-V book: https://pdos.csail.mit.edu/6.828/2023/xv6/book-riscv-rev3.pdf
- MIT xv6 source: https://github.com/mit-pdos/xv6-riscv
- MLFQ Scheduling: Operating Systems Three Easy Pieces (OSTEP)
