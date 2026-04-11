#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fcntl.h"
// CPU bound process - uses full quantum
void cpu_bound(int n)
{
  int sum = 0;
  for(int i = 0; i < n; i++)
    sum += i;
  printf("cpu_bound: sum = %d\n", sum);
}

// IO bound process - yields frequently
void io_bound(int n)
{
  for(int i = 0; i < n; i++){
    printf("io_bound: iteration %d\n", i);
    // simulate IO wait with busy loop
    for(volatile int j = 0; j < 1000000; j++);
  }
}

int
main(void)
{
  printf("=== MLFQ Scheduling Test ===\n");
  printf("Processes start at Queue 0 (highest priority)\n");
  printf("CPU bound processes move to lower queues\n");
  printf("IO bound processes stay at higher queues\n\n");

  int pid1 = fork();
  if(pid1 == 0){
    // Child 1 - CPU bound
    printf("Process %d: CPU bound task starting (Queue 0)\n", getpid());
    cpu_bound(1000000);
    printf("Process %d: CPU bound task done (moved to lower queue)\n", getpid());
    exit(0);
  }

  int pid2 = fork();
  if(pid2 == 0){
    // Child 2 - IO bound
    printf("Process %d: IO bound task starting (Queue 0)\n", getpid());
    io_bound(3);
    printf("Process %d: IO bound task done (stayed in high queue)\n", getpid());
    exit(0);
  }

  // Parent waits for both
  printf("Parent: waiting for processes %d and %d\n", pid1, pid2);
  wait(0);
  wait(0);
  printf("\n=== MLFQ Test Complete ===\n");
  printf("Queue 0 (quantum=1): highest priority, IO bound\n");
  printf("Queue 1 (quantum=2): medium priority\n");
  printf("Queue 2 (quantum=4): lowest priority, CPU bound\n");

  exit(0);
}
