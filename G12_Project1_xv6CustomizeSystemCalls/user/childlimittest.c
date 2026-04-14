#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
fail(const char *msg)
{
  printf("childlimittest: FAIL: %s\n", msg);
  exit(1);
}

static void
pass(const char *msg)
{
  printf("childlimittest: PASS: %s\n", msg);
}

int
main(void)
{
  int pid;
  int status;

  if(setchildlimit(2) != 0)
    fail("setchildlimit(2) should return 0");

  pid = fork();
  if(pid < 0)
    fail("first fork should succeed with limit=2");
  if(pid == 0){
    pause(200);
    exit(0);
  }

  pid = fork();
  if(pid < 0)
    fail("second fork should succeed with limit=2");
  if(pid == 0){
    pause(200);
    exit(0);
  }

  pid = fork();
  if(pid != -1)
    fail("third fork should fail when child limit is reached");
  pass("fork blocked at child limit");

  if(wait(&status) < 0)
    fail("wait after reaching limit (child 1)");
  if(wait(&status) < 0)
    fail("wait after reaching limit (child 2)");

  pid = fork();
  if(pid < 0)
    fail("fork should succeed again after children are reaped");
  if(pid == 0)
    exit(0);
  if(wait(&status) < 0)
    fail("wait for post-reap child");
  pass("fork allowed again after reaping children");

  if(setchildlimit(0) != 0)
    fail("setchildlimit(0) should return 0");
  pid = fork();
  if(pid != -1)
    fail("fork should fail when limit is 0");
  pass("limit=0 blocks fork");

  if(setchildlimit(-1) != 0)
    fail("setchildlimit(-1) should return 0");
  pid = fork();
  if(pid < 0)
    fail("fork should succeed again when limit=-1 (disabled)");
  if(pid == 0)
    exit(0);
  if(wait(&status) < 0)
    fail("wait for unlimited-mode child");
  pass("limit=-1 disables restriction");

  printf("childlimittest: all checks passed\n");
  exit(0);
}
