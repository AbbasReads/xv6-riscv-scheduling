#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
fail(const char *msg)
{
  printf("proctest: FAIL: %s\n", msg);
  exit(1);
}

int
main(void)
{
  int parent = getpid();
  int status;
  int start;
  int elapsed;

  int child = fork();
  if(child < 0)
    fail("fork failed while checking getppid");
  if(child == 0){
    int ppid = getppid();
    if(ppid != parent){
      printf("proctest: expected parent pid %d, got %d\n", parent, ppid);
      exit(1);
    }
    exit(0);
  }

  if(wait(&status) < 0 || status != 0)
    fail("getppid child should exit successfully");

  start = uptime();
  if(sleep2(5) != 0)
    fail("sleep2 should return 0");
  elapsed = uptime() - start;
  if(elapsed < 5){
    printf("proctest: sleep2 slept for only %d ticks\n", elapsed);
    exit(1);
  }

  printf("proctest: process table snapshot follows\n");
  if(getprocsinfo(0) != 0)
    fail("getprocsinfo should return 0");

  printf("proctest: getppid, sleep2, and getprocsinfo checks passed\n");
  exit(0);
}
