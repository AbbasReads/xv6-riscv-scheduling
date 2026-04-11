#include "kernel/types.h"
#include "user/user.h"

static void
worker(int tickets, int rounds)
{
    volatile int sink = 0;

    if(settickets(tickets) < 0){
        printf("pid=%d failed settickets(%d)\n", getpid(), tickets);
        exit(1);
    }

    for(int i = 0; i < rounds; i++){
        sink += i & 7;
    }

    printf("pid=%d done tickets=%d sink=%d\n", getpid(), tickets, sink);
    exit(0);
}

int
main(void)
{
    int tickets[3] = {1, 30000, 60000000 };
    int rounds = 120000000;
    int pids[3];
    int start_ticks[3];
    int finish_ticks[3];

    for(int i = 0; i < 3; i++){
        finish_ticks[i] = -1;
    }

    for(int i = 0; i < 3; i++){
        int t0 = uptime();
        int pid = fork();
        if(pid < 0){
            printf("fork failed\n");
            exit(1);
        }
        if(pid == 0){
            worker(tickets[i], rounds);
        }
        pids[i] = pid;
        start_ticks[i] = t0;
    }

    for(int i = 0; i < 3; i++){
        int status = 0;
        int pid = wait(&status);
        int t1 = uptime();
        int idx = -1;
        for(int j = 0; j < 3; j++){
            if(pids[j] == pid){
                idx = j;
                break;
            }
        }
        if(idx >= 0){
            finish_ticks[idx] = t1;
            printf("reaped pid=%d tickets=%d turnaround=%d ticks\n",
                   pid, tickets[idx], finish_ticks[idx] - start_ticks[idx]);
        } else {
            printf("reaped pid=%d status=%d\n", pid, status);
        }
    }

    printf("summary (lower turnaround is better):\n");
    for(int i = 0; i < 3; i++){
        int tat = finish_ticks[i] - start_ticks[i];
        int count = getschedcount(pids[i]);
        printf("pid=%d tickets=%d turnaround=%d sched_count=%d\n",
               pids[i], tickets[i], tat, count);
    }

    printf("myprog complete\n");
    exit(0);
}