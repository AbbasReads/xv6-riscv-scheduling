#include "defs.h"
#include "msgqueue.h"
#include "param.h"
#include "proc.h"
#include "riscv.h"
#include "spinlock.h"
#include "types.h"

static int enqueue_msg(struct proc *dst, int sender_pid, char *data, int size) {
  if (size <= 0 || size > MAX_MSG_SIZE)
    return -1;

  acquire(&dst->mq.lock);

  if (dst->mq.count == MSG_QUEUE_LEN) {
    release(&dst->mq.lock);
    return -1;
  }

  struct message *m = &dst->mq.buf[dst->mq.tail];
  m->sender_pid = sender_pid;
  m->size = size;
  memmove(m->data, data, size);

  dst->mq.tail = (dst->mq.tail + 1) % MSG_QUEUE_LEN;
  dst->mq.count++;

  wakeup(&dst->mq);
  release(&dst->mq.lock);
  return 0;
}

uint64 sys_sendmsg(void) {
  int target_pid, size;
  uint64 buf_addr;

  argint(0, &target_pid);
  argaddr(1, &buf_addr);
  argint(2, &size);

  if (size <= 0 || size > MAX_MSG_SIZE)
    return -1;

  char kbuf[MAX_MSG_SIZE];
  if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    return -1;

  struct proc *target = 0;
  extern struct proc proc[];
  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    if (p->pid == target_pid && p->state != UNUSED) {
      target = p;
      break;
    }
  }
  if (!target)
    return -1;

  return enqueue_msg(target, myproc()->pid, kbuf, size);
}

uint64 sys_recvmsg(void) {
  uint64 buf_addr;
  int size;

  argaddr(0, &buf_addr);
  argint(1, &size);

  struct proc *p = myproc();

  acquire(&p->mq.lock);

  while (p->mq.count == 0) {
    sleep(&p->mq, &p->mq.lock);
  }

  struct message *m = &p->mq.buf[p->mq.head];
  int copy_len = (m->size < size) ? m->size : size;

  if (copyout(p->pagetable, buf_addr, m->data, copy_len) < 0) {
    release(&p->mq.lock);
    return -1;
  }

  p->mq.head = (p->mq.head + 1) % MSG_QUEUE_LEN;
  p->mq.count--;

  release(&p->mq.lock);
  return m->sender_pid;
}

uint64 sys_broadcast(void) {
  uint64 buf_addr;
  int size;

  argaddr(0, &buf_addr);
  argint(1, &size);

  if (size <= 0 || size > MAX_MSG_SIZE)
    return -1;

  char kbuf[MAX_MSG_SIZE];
  if (copyin(myproc()->pagetable, kbuf, buf_addr, size) < 0)
    return -1;

  int sender_pid = myproc()->pid;
  int count = 0;
  extern struct proc proc[];

  for (struct proc *p = proc; p < &proc[NPROC]; p++) {
    if (p->pid != sender_pid && p->state != UNUSED) {
      if (enqueue_msg(p, sender_pid, kbuf, size) == 0)
        count++;
    }
  }

  return count;
}
