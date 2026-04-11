#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int id = 1;

  // Initialize lock
  if(lockinit(id) < 0){
    printf("lockinit failed\n");
    exit(1);
  }
  printf("lockinit: lock %d initialized\n", id);

  // Check lock status before acquiring
  printf("lockcheck: lock held? %d (0=free)\n", lockcheck(id));

  // Acquire lock
  if(lockacquire(id) < 0){
    printf("lockacquire failed\n");
    exit(1);
  }
  printf("lockacquire: lock %d acquired\n", id);

  // Check lock status after acquiring
  printf("lockcheck: lock held? %d (1=held)\n", lockcheck(id));

  // Try to acquire already held lock
  int ret = locktry(id);
  printf("locktry: tried to acquire held lock, result: %d (0=failed as expected)\n", ret);

  // Release lock
  if(lockrelease(id) < 0){
    printf("lockrelease failed\n");
    exit(1);
  }
  printf("lockrelease: lock %d released\n", id);

  // Try to acquire free lock
  ret = locktry(id);
  printf("locktry: tried to acquire free lock, result: %d (1=success)\n", ret);

  printf("Lock test complete!\n");
  exit(0);
}
