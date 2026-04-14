#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
fail(const char *msg)
{
  printf("locktest: FAIL: %s\n", msg);
  exit(1);
}

int
main(void)
{
  int lockid = 7;
  int pid;
  int status;

  if(lockinit(lockid, "demo-lock") != lockid)
    fail("lockinit should return the lock id");
  if(lockcheck(lockid) != 0)
    fail("new lock should start unlocked");

  if(lockacquire(lockid) != 0)
    fail("lockacquire should succeed on an unlocked lock");
  if(lockcheck(lockid) != 1)
    fail("lockcheck should report held after lockacquire");
  if(locktry(lockid) != 0)
    fail("locktry should report busy when the lock is held");

  pid = fork();
  if(pid < 0)
    fail("fork failed while testing inter-process lock state");
  if(pid == 0){
    if(locktry(lockid) != 0){
      printf("locktest: child acquired a lock that parent already holds\n");
      exit(1);
    }
    exit(0);
  }

  if(wait(&status) < 0 || status != 0)
    fail("child should observe the lock as busy");

  if(lockrelease(lockid) != 0)
    fail("lockrelease should succeed");
  if(lockcheck(lockid) != 0)
    fail("lock should be unlocked after lockrelease");
  if(locktry(lockid) != 1)
    fail("locktry should acquire the lock once it is free");
  if(lockrelease(lockid) != 0)
    fail("lockrelease should succeed after locktry");

  printf("locktest: all checks passed\n");
  exit(0);
}
