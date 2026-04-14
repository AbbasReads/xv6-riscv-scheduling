# Project 1: Custom System Calls

This tree extends xv6 with additional system calls and small user-space test programs.

## Added Syscalls

| Syscall(s) | Purpose | Main files | User test |
| --- | --- | --- | --- |
| `shmget`, `shmat`, `shmdt`, `shmctl` | Shared memory | `kernel/sysproc.c`, `kernel/proc.h`, `kernel/defs.h` | `shmtest` |
| `lockinit`, `lockacquire`, `lockrelease`, `locktry`, `lockcheck` | User-visible locks | `kernel/sysproc.c`, `kernel/proc.h` | `locktest` |
| `sendmsg`, `recvmsg`, `broadcast` | Message queue IPC | `kernel/sysmsg.c`, `kernel/msgqueue.h`, `kernel/proc.h` | `msgtest` |
| `getprocsinfo`, `getppid`, `sleep2` | Process info and sleep helper | `kernel/sysproc.c` | `proctest` |
| `setchildlimit` | Limit live child processes | `kernel/sysproc.c`, `kernel/proc.c`, `kernel/proc.h` | `childlimittest`, `sclimit` |
| `signal` | Store a handler pointer in the process table | `kernel/sysproc.c`, `kernel/proc.h` | `signaltest` |

## Interface Changes

- `sleep(int ticks)` is exposed as `pause(int ticks)` in this tree.
- `sbrk(int n)` was extended in the kernel to support eager and lazy allocation modes.

## Included User Programs

- `shmtest`
- `locktest`
- `msgtest`
- `proctest`
- `childlimittest`
- `sclimit`
- `signaltest`

## Build And Run

From this directory:

```bash
make qemu
```

Inside xv6:

```text
$ shmtest
$ locktest
$ msgtest
$ proctest
$ childlimittest
$ sclimit
$ signaltest
```

## Notes

- `msgtest` covers `sendmsg`, `recvmsg`, and `broadcast`.
- `proctest` covers `getppid`, `sleep2`, and `getprocsinfo`.
- `signaltest` only checks registration. Full signal delivery is not implemented.
