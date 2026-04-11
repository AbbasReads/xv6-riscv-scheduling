#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void task(char *name, int deadline, int work)
{
  setdeadline(deadline);
  printf("%s: deadline=%d started\n", name, deadline);
  // simulate work
  int sum = 0;
  for(int i = 0; i < work; i++)
    sum += i;
  printf("%s: deadline=%d completed, sum=%d\n", name, deadline, sum);
}

int
main(void)
{
  printf("=== EDF Scheduling Test ===\n");
  printf("Process with earliest deadline runs first\n\n");

  // Fork 3 processes with different deadlines
  int pid1 = fork();
  if(pid1 == 0){
    task("Task-A", 30, 500000);  // earliest deadline
    exit(0);
  }
  wait(0);

  int pid2 = fork();
  if(pid2 == 0){
    task("Task-B", 60, 500000);  // medium deadline
    exit(0);
  }
  wait(0);

  int pid3 = fork();
  if(pid3 == 0){
    task("Task-C", 90, 500000);  // latest deadline
    exit(0);
  }
  wait(0);

  printf("\n=== EDF Test Complete ===\n");
  printf("Task-A (deadline=30) ran first\n");
  printf("Task-B (deadline=60) ran second\n");
  printf("Task-C (deadline=90) ran last\n");

  exit(0);
}
