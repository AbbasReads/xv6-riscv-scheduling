# xv6 Modifications: Syscalls and Scheduling

This repository extends base xv6 in two main areas: system calls and process scheduling.

## Syscall-related changes

- Added a new syscall `pause(int ticks)` (`SYS_pause = 13`) that blocks the calling process for a number of timer ticks.
- Extended `sbrk` handling to support two allocation modes through `sys_sbrk(int n, int type)`:
  - `SBRK_EAGER`: allocate pages immediately (classic xv6 behavior).
  - `SBRK_LAZY`: grow virtual size now, allocate pages on first access.
- Added user-space helpers:
  - `sbrk(int n)` now calls eager mode.
  - `sbrklazy(int n)` calls lazy mode.
- Updated syscall wiring (number table, dispatcher mapping, user stubs, and user prototypes) to include the new/changed syscall interfaces.

## Scheduling-related changes

- Replaced the default runnable-process selection with a **lottery scheduler**.
- Added per-process scheduling metadata:
  - `tickets` (weight for lottery selection).
  - `sched_count` (how many times the process has been scheduled).
- Default process ticket count is initialized to `10`, and children inherit the parent ticket count on `fork`.
- On each scheduling round:
  - Gather runnable processes and cumulative ticket totals.
  - Draw a random winning ticket.
  - Run the selected process and increment its `sched_count`.

## Notes

- Lazy allocation support is integrated with trap/memory code so page faults on lazily reserved pages allocate memory on demand.
- Copy paths used by syscall argument/data transfer are updated to handle lazily allocated pages when needed.