#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "proc.h"

// setpriority(int period)
// sets the period and computes priority for RMS
// shorter period = higher priority
uint64
sys_setpriority(void)
{
    int period;
    argint(0, &period);

    if(period <= 0)
        return -1;

    struct proc *p = myproc();
    p->period   = period;
    p->priority = 1000 / period;  // shorter period = higher priority

    return 0;
}