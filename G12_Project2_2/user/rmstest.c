#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
task(char *name, int period, int burst)
{
  printf("Task %s | period=%d | priority=%d\n", name, period, 1000 / period);

  for (int i = 0; i < burst; i++) {
    for (volatile int j = 0; j < 1000000; j++)
      ;
    printf("Task %s | burst %d/%d\n", name, i + 1, burst);
  }

  exit(0);
}

int
main(void)
{
  printf("RMS demo reference\n");
  printf("T1: period=4\n");
  printf("T2: period=6\n");
  printf("T3: period=12\n");

  if (fork() == 0)
    task("T1", 4, 2);

  if (fork() == 0)
    task("T2", 6, 3);

  if (fork() == 0)
    task("T3", 12, 4);

  wait(0);
  wait(0);
  wait(0);

  printf("Demo complete\n");
  exit(0);
}
