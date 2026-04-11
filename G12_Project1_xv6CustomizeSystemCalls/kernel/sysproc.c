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

// Lock table
struct userlock locktable[MAX_LOCKS];

int
lockinit(int id)
{
  for(int i = 0; i < MAX_LOCKS; i++){
    if(locktable[i].valid && locktable[i].id == id)
      return id;
  }
  for(int i = 0; i < MAX_LOCKS; i++){
    if(!locktable[i].valid){
      locktable[i].id = id;
      locktable[i].held = 0;
      locktable[i].pid = -1;
      locktable[i].valid = 1;
      return id;
    }
  }
  return -1;
}

int
lockacquire(int id)
{
  for(int i = 0; i < MAX_LOCKS; i++){
    if(locktable[i].valid && locktable[i].id == id){
      if(locktable[i].held)
        return -1;
      locktable[i].held = 1;
      locktable[i].pid = myproc()->pid;
      return 0;
    }
  }
  return -1;
}

int
lockrelease(int id)
{
  for(int i = 0; i < MAX_LOCKS; i++){
    if(locktable[i].valid && locktable[i].id == id){
      if(!locktable[i].held)
        return -1;
      locktable[i].held = 0;
      locktable[i].pid = -1;
      return 0;
    }
  }
  return -1;
}

int
locktry(int id)
{
  for(int i = 0; i < MAX_LOCKS; i++){
    if(locktable[i].valid && locktable[i].id == id){
      if(locktable[i].held)
        return 0;
      locktable[i].held = 1;
      locktable[i].pid = myproc()->pid;
      return 1;
    }
  }
  return -1;
}

int
lockcheck(int id)
{
  for(int i = 0; i < MAX_LOCKS; i++){
    if(locktable[i].valid && locktable[i].id == id)
      return locktable[i].held;
  }
  return -1;
}

uint64
sys_lockinit(void)
{
  int id;
  argint(0, &id);
  return lockinit(id);
}

uint64
sys_lockacquire(void)
{
  int id;
  argint(0, &id);
  return lockacquire(id);
}

uint64
sys_lockrelease(void)
{
  int id;
  argint(0, &id);
  return lockrelease(id);
}

uint64
sys_locktry(void)
{
  int id;
  argint(0, &id);
  return locktry(id);
}

uint64
sys_lockcheck(void)
{
  int id;
  argint(0, &id);
  return lockcheck(id);
}
