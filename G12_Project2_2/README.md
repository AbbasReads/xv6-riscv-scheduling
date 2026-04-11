# Project 2: EDF Scheduling in xv6


---

## Introduction
This project implements the Earliest Deadline First (EDF) scheduling
algorithm in the xv6 operating system. EDF is a real-time scheduling
algorithm that always runs the process with the nearest deadline first,
ensuring time critical processes meet their deadlines.

---

## How EDF Works

Each process is assigned a deadline.
Scheduler always picks process with smallest deadline.
Real-time guarantee: critical tasks always run first,
setdeadline() syscall lets processes set their own deadline.

---

## Files Modified

| File | Changes Made |
|------|-------------|
| kernel/proc.h | Added deadline and arrivaltime fields to proc struct |
| kernel/proc.c | Implemented EDF scheduler |
| kernel/syscall.h | Added setdeadline syscall number |
| kernel/syscall.c | Registered setdeadline syscall |
| kernel/sysproc.c | Implemented setdeadline syscall |
| kernel/defs.h | Added setdeadline declaration |
| user/usys.pl | Added setdeadline stub |
| user/user.h | Added setdeadline declaration |
| user/edftest.c | Demo program for EDF |
| Makefile | Added edftest to build |

---

## How to Run

### Steps
```bash
# Clone the repository
git clone https://github.com/AbbasReads/xv6-riscv-scheduling.git
cd xv6-riscv-scheduling
git checkout meghana-branch
cd G12_Project2_2

# Build and run xv6 with single CPU
make qemu CPUS=1

# Inside xv6 shell run
$ edftest
```

---

---

## Performance Metrics

| Task | Deadline | Priority | Result |
|------|----------|----------|--------|
| Task-A | 30 ticks | Highest | Ran first ✅ |
| Task-B | 60 ticks | Medium | Ran second ✅ |
| Task-C | 90 ticks | Lowest | Ran last ✅ |

---

## Screenshot

### Program
<img width="714" height="907" alt="edf" src="https://github.com/user-attachments/assets/d07df9ce-e306-4ecc-8e0d-07b41f59369d" />

### Output
<img width="530" height="486" alt="edf_output" src="https://github.com/user-attachments/assets/8acc0fa8-1e7c-49b9-aa05-017013245b7b" />


---

## References
- xv6 RISC-V book: https://pdos.csail.mit.edu/6.828/2023/xv6/book-riscv-rev3.pdf
- MIT xv6 source: https://github.com/mit-pdos/xv6-riscv
- EDF Scheduling: Operating Systems Three Easy Pieces (OSTEP)
