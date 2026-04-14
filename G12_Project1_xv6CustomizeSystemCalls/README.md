# Project 1: Custom System Calls in xv6

This directory is the project-one xv6 tree. Compared with upstream xv6 at
commit `5474d4bf72fd95a6e5c735c2d7f208f58990ceab`, project one extends the
syscall layer in:

- `kernel/syscall.h`
- `kernel/syscall.c`
- `kernel/sysproc.c`
- `kernel/sysmsg.c`
- `user/user.h`
- `user/usys.pl`

The project now also includes user-space demo and smoke-test programs for the
custom syscall families so a fresh build places them in `fs.img`.

## Added Syscalls Over Original xv6

| Syscall(s) | Purpose | Main implementation files | Test program(s) |
| --- | --- | --- | --- |
| `shmget`, `shmat`, `shmdt`, `shmctl` | Shared memory IPC | `kernel/sysproc.c`, `kernel/proc.h`, `kernel/defs.h` | `shmtest` |
| `lockinit`, `lockacquire`, `lockrelease`, `locktry`, `lockcheck` | Simple user-visible lock table | `kernel/sysproc.c`, `kernel/proc.h` | `locktest` |
| `sendmsg`, `recvmsg`, `broadcast` | Message-queue-based IPC between processes | `kernel/sysmsg.c`, `kernel/msgqueue.h`, `kernel/proc.h` | `msgtest` |
| `getprocsinfo`, `getppid`, `sleep2` | Process inspection and alternate sleep helper | `kernel/sysproc.c` | `proctest` |
| `setchildlimit` | Limit the number of live child processes a process may have | `kernel/sysproc.c`, `kernel/proc.c`, `kernel/proc.h` | `childlimittest`, `sclimit` |
| `signal` | Register a handler pointer in the process struct | `kernel/sysproc.c`, `kernel/proc.h` | `signaltest` |

## Modified xv6 Syscall Interfaces

These are not brand-new syscall numbers compared with upstream xv6, but the
interface in this tree differs from stock xv6 and is worth calling out.

| Upstream xv6 | Project-one tree | How to exercise it |
| --- | --- | --- |
| `sleep(int ticks)` | Renamed to `pause(int ticks)` in this tree | `usertests`, `setchildlimittest`, `msgtest` |
| `sbrk(int n)` | Kernel side accepts `sbrk(int n, int mode)` and user wrappers expose eager/lazy growth helpers | `usertests` |

## User Programs Included In `fs.img`

Fresh builds now include the following project-one syscall demos:

- `shmtest`
- `locktest`
- `msgtest`
- `proctest`
- `childlimittest`
- `sclimit`
- `signaltest`

## How To Run

From this directory:

```bash
make qemu
```

Inside the xv6 shell:

```text
$ shmtest
$ locktest
$ msgtest
$ proctest
$ childlimittest
$ signaltest
```

Notes:

- `msgtest` exercises `sendmsg`, `recvmsg`, and `broadcast` together.
- `proctest` exercises `getppid`, `sleep2`, and `getprocsinfo` together.
- `childlimittest` is the xv6-safe runnable name for the child-limit test.
  The longer source file `setchildlimittest.c` is still present in the tree,
  but the executable name must stay within xv6's directory entry limit.
- `sclimit` is an additional child-limit regression test.
- `signaltest` is a registration smoke test. In the current project-one tree,
  the kernel stores the handler pointer but does not implement a full signal
  delivery path that invokes it.

## Expected High-Level Results

- `shmtest` should create, attach, write, detach, and delete a shared memory
  segment.
- `locktest` should report that lock acquire/release and `locktry` behavior
  work as expected across parent/child processes.
- `msgtest` should verify one direct message and one broadcast round.
- `proctest` should verify the parent PID, sleep for at least the requested
  number of ticks, and print a process table snapshot.
- `childlimittest` should show that forks fail once the configured child
  limit is reached and succeed again after children are reaped.

## Summary

Using `5474d4bf72fd95a6e5c735c2d7f208f58990ceab` as the upstream xv6 baseline,
project one adds or customizes shared memory, user locks, message passing,
process-inspection helpers, signal registration, child-limit enforcement, and
the `pause`/`sbrk` interface changes listed above. The README and `Makefile`
now line up with those syscall changes and the available test programs.
