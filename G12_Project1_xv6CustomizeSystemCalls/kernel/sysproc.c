#include "defs.h"
#include "memlayout.h"
#include "param.h"
#include "proc.h"
#include "riscv.h"
#include "spinlock.h"
#include "types.h"
#include "vm.h"

extern struct proc proc[NPROC];

uint64 sys_exit(void) {
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
}

uint64 sys_getpid(void) { return myproc()->pid; }

uint64 sys_fork(void) { return kfork(); }

uint64 sys_wait(void) {
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64 sys_sbrk(void) {
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64 sys_pause(void) {
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64 sys_kill(void) {
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64 sys_uptime(void) {
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// Shared memory array
struct sharedmem shmtable[MAX_SHAREDMEM];

int shmget(int id, int size) {
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    if (shmtable[i].valid && shmtable[i].id == id)
      return id;
  }
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    if (!shmtable[i].valid) {
      shmtable[i].id = id;
      shmtable[i].size = size;
      shmtable[i].refcount = 0;
      shmtable[i].addr = (uint64)kalloc();
      shmtable[i].valid = 1;
      return id;
    }
  }
  return -1;
}

uint64 shmat(int id) {
  struct proc *p = myproc();
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    if (shmtable[i].valid && shmtable[i].id == id) {
      shmtable[i].refcount++;
      // map physical address to process virtual address space
      uint64 va = PGROUNDUP(p->sz);
      if (mappages(p->pagetable, va, PGSIZE, shmtable[i].addr,
                   PTE_R | PTE_W | PTE_U) < 0)
        return -1;
      p->sz = va + PGSIZE;
      return va;
    }
  }
  return -1;
}

int shmdt(int id) {
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    if (shmtable[i].valid && shmtable[i].id == id) {
      shmtable[i].refcount--;
      return 0;
    }
  }
  return -1;
}

int shmctl(int id) {
  for (int i = 0; i < MAX_SHAREDMEM; i++) {
    if (shmtable[i].valid && shmtable[i].id == id) {
      if (shmtable[i].refcount == 0) {
        kfree((void *)shmtable[i].addr);
        shmtable[i].valid = 0;
        return 0;
      }
    }
  }
  return -1;
}

uint64 sys_shmget(void) {
  int id, size;
  argint(0, &id);
  argint(1, &size);
  return shmget(id, size);
}

uint64 sys_shmat(void) {
  int id;
  argint(0, &id);
  return shmat(id);
}

uint64 sys_shmdt(void) {
  int id;
  argint(0, &id);
  return shmdt(id);
}

uint64 sys_shmctl(void) {
  int id;
  argint(0, &id);
  return shmctl(id);
}

// Lock table
struct userlock locktable[MAX_LOCKS];

int lockinit(int id) {
  for (int i = 0; i < MAX_LOCKS; i++) {
    if (locktable[i].valid && locktable[i].id == id)
      return id;
  }
  for (int i = 0; i < MAX_LOCKS; i++) {
    if (!locktable[i].valid) {
      locktable[i].id = id;
      locktable[i].held = 0;
      locktable[i].pid = -1;
      locktable[i].valid = 1;
      return id;
    }
  }
  return -1;
}

int lockacquire(int id) {
  for (int i = 0; i < MAX_LOCKS; i++) {
    if (locktable[i].valid && locktable[i].id == id) {
      if (locktable[i].held)
        return -1;
      locktable[i].held = 1;
      locktable[i].pid = myproc()->pid;
      return 0;
    }
  }
  return -1;
}

int lockrelease(int id) {
  for (int i = 0; i < MAX_LOCKS; i++) {
    if (locktable[i].valid && locktable[i].id == id) {
      if (!locktable[i].held)
        return -1;
      locktable[i].held = 0;
      locktable[i].pid = -1;
      return 0;
    }
  }
  return -1;
}

int locktry(int id) {
  for (int i = 0; i < MAX_LOCKS; i++) {
    if (locktable[i].valid && locktable[i].id == id) {
      if (locktable[i].held)
        return 0;
      locktable[i].held = 1;
      locktable[i].pid = myproc()->pid;
      return 1;
    }
  }
  return -1;
}

int lockcheck(int id) {
  for (int i = 0; i < MAX_LOCKS; i++) {
    if (locktable[i].valid && locktable[i].id == id)
      return locktable[i].held;
  }
  return -1;
}

uint64 sys_lockinit(void) {
  int id;
  argint(0, &id);
  return lockinit(id);
}

uint64 sys_lockacquire(void) {
  int id;
  argint(0, &id);
  return lockacquire(id);
}

uint64 sys_lockrelease(void) {
  int id;
  argint(0, &id);
  return lockrelease(id);
}

uint64 sys_locktry(void) {
  int id;
  argint(0, &id);
  return locktry(id);
}

uint64 sys_lockcheck(void) {
  int id;
  argint(0, &id);
  return lockcheck(id);
}

uint64 sys_getprocsinfo(void) {
  struct proc *p;

  printf("PID\tSTATE\tSIZE\n");

  for (p = proc; p < &proc[NPROC]; p++) {
    if (p->state != UNUSED) {
      printf("%d\t%d\t%ld\n", p->pid, p->state, p->sz);
    }
  }

  return 0;
}

uint64 sys_getppid(void) {
  struct proc *p = myproc();
  if (p->parent)
    return p->parent->pid;
  return -1;
}

uint64 sys_sleep2(void) {
  int n;
  argint(0, &n);

  struct proc *p = myproc();

  acquire(&tickslock);
  uint ticks0 = ticks;

  while (ticks - ticks0 < n) {
    if (p->killed) {
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }

  release(&tickslock);
  return 0;
}

uint64 sys_signal(void) {
  uint64 handler;
  argaddr(1, &handler);

  struct proc *p = myproc();
  p->handler = (void (*)(int))handler;

  return 0;
}

uint sys_setchildlimit(void){
  int limit;
  argint(0,&limit);
  myproc()->child_limit=limit;
  return 0;
}