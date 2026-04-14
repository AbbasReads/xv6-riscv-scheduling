#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
handler(int signum)
{
  printf("signaltest: handler invoked for signal %d\n", signum);
}

int
main(void)
{
  if(signal(2, handler) != 0){
    printf("signaltest: FAIL: signal registration returned an error\n");
    exit(1);
  }

  printf("signaltest: registration syscall succeeded\n");
  printf("signaltest: current project stores the handler pointer but does not\n");
  printf("signaltest: include a full signal delivery path to invoke it\n");
  exit(0);
}
