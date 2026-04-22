#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int parent = getpid();
  int status;

  printf("getppidtest: testing getppid syscall\n");
  printf("getppidtest: parent pid is %d\n", parent);

  int child = fork();

  if(child < 0){
    printf("getppidtest: fork failed\n");
    exit(1);
  }

  if(child == 0){
    int ppid = getppid();
    printf("getppidtest: child pid=%d expected ppid=%d observed ppid=%d\n",
           getpid(), parent, ppid);
    if(ppid != parent){
      printf("getppidtest: expected %d got %d\n", parent, ppid);
      exit(1);
    }
    exit(0);
  }

  printf("getppidtest: forked child pid=%d\n", child);

  if(wait(&status) < 0 || status != 0){
    printf("getppidtest: child failed with status %d\n", status);
    exit(1);
  }

  printf("getppidtest: child exited with status 0\n");
  printf("getppidtest: PASS\n");
  exit(0);
}
