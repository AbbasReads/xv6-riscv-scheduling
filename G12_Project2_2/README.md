# Project 2: MLFQ Scheduling in xv6

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

## Screenshots
### Program
<img width="633" height="865" alt="Screenshot 2026-04-12 032108" src="https://github.com/user-attachments/assets/aef8e558-c82f-413c-aa31-b5f1b1711804" />

### Output
<img width="1914" height="610" alt="Screenshot 2026-04-12 031112" src="https://github.com/user-attachments/assets/41cf0d22-e3d5-4d9e-984b-01dff2d99338" />


---

## References
- xv6 RISC-V book: https://pdos.csail.mit.edu/6.828/2023/xv6/book-riscv-rev3.pdf
- MIT xv6 source: https://github.com/mit-pdos/xv6-riscv
- MLFQ Scheduling: Operating Systems Three Easy Pieces (OSTEP)
