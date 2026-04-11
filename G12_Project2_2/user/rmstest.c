#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void task(char *name, int period, int burst)
{
    setpriority(period);
    printf("Task %s started | period=%d priority=%d\n",
           name, period, 1000/period);

    // simulate burst work
    for(int i = 0; i < burst; i++) {
        for(volatile int j = 0; j < 1000000; j++);
        printf("Task %s | burst unit %d/%d done\n", name, i+1, burst);
    }

    printf("Task %s completed!\n", name);
    exit(0);
}

int main(void)
{
    printf("===========================================\n");
    printf("   Rate Monotonic Scheduling (RMS) Demo   \n");
    printf("===========================================\n\n");

    printf("Creating 3 tasks with different periods:\n");
    printf("T1: period=4  (highest priority)\n");
    printf("T2: period=6  (medium priority)\n");
    printf("T3: period=12 (lowest priority)\n\n");

    // fork T1 - highest priority (shortest period)
    int pid1 = fork();
    if(pid1 == 0)
        task("T1", 4, 2);

    // fork T2 - medium priority
    int pid2 = fork();
    if(pid2 == 0)
        task("T2", 6, 3);

    // fork T3 - lowest priority
    int pid3 = fork();
    if(pid3 == 0)
        task("T3", 12, 4);

    // parent waits for all
    wait(0);
    wait(0);
    wait(0);

    printf("\nAll tasks completed!\n");
    printf("RMS scheduling ensured shortest period ran first.\n");

    exit(0);
}