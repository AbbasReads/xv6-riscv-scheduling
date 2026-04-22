#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int requested = 5;
  int start = uptime();
  int elapsed;

  printf("sleep2test: testing sleep2 syscall\n");
  printf("sleep2test: start tick=%d requested ticks=%d\n", start, requested);

  if(sleep2(requested) != 0){
    printf("sleep2test: sleep2 returned failure\n");
    exit(1);
  }

  elapsed = uptime() - start;
  printf("sleep2test: elapsed ticks=%d\n", elapsed);

  if(elapsed < requested){
    printf("sleep2test: expected at least %d ticks\n", requested);
    exit(1);
  }

  printf("sleep2test: PASS\n");
  exit(0);
}
