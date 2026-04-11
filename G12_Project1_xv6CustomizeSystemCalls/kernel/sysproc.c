#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// Shared memory array
struct sharedmem shmtable[MAX_SHAREDMEM];

int
shmget(int id, int size)
{
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    if(shmtable[i].valid && shmtable[i].id == id)
      return id;
  }
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    if(!shmtable[i].valid){
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

uint64
shmat(int id)
{
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    if(shmtable[i].valid && shmtable[i].id == id){
      shmtable[i].refcount++;
      return shmtable[i].addr;
    }
  }
  return -1;
}

int
shmdt(int id)
{
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    if(shmtable[i].valid && shmtable[i].id == id){
      shmtable[i].refcount--;
      return 0;
    }
  }
  return -1;
}

int
shmctl(int id)
{
  for(int i = 0; i < MAX_SHAREDMEM; i++){
    if(shmtable[i].valid && shmtable[i].id == id){
      if(shmtable[i].refcount == 0){
        kfree((void*)shmtable[i].addr);
        shmtable[i].valid = 0;
        return 0;
      }
    }
  }
  return -1;
}

uint64
sys_shmget(void)
{
  int id, size;
  argint(0, &id);
  argint(1, &size);
  return shmget(id, size);
}

uint64
sys_shmat(void)
{
  int id;
  argint(0, &id);
  return shmat(id);
}

uint64
sys_shmdt(void)
{
  int id;
  argint(0, &id);
  return shmdt(id);
}

uint64
sys_shmctl(void)
{
  int id;
  argint(0, &id);
  return shmctl(id);
}
