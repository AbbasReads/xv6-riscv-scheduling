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
  printf("proctest: testing getprocsinfo syscall\n");
  printf("proctest: expected output columns: PID STATE SIZE\n");
  printf("proctest: process table snapshot follows\n");

  if(getprocsinfo(0) != 0)
    fail("getprocsinfo should return 0");

  printf("proctest: getprocsinfo returned 0\n");
  printf("proctest: PASS\n");
  exit(0);
}
