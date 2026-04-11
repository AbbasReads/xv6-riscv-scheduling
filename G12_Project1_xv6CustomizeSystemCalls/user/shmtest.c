#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  int id = 1;
  int size = 4096;

  // Create shared memory
  int shmid = shmget(id, size);
  if(shmid < 0){
    printf("shmget failed\n");
    exit(1);
  }
  printf("shmget: created shared memory with id %d\n", shmid);

  // Attach shared memory
  char *addr = (char*)shmat(shmid);
  if((int64)addr < 0){
    printf("shmat failed\n");
    exit(1);
  }
  printf("shmat: attached shared memory at address %p\n", addr);

  // Write to shared memory
  addr[0] = 'H';
  addr[1] = 'i';
  addr[2] = '!';
  addr[3] = '\0';
  printf("wrote to shared memory: %s\n", addr);

  // Detach shared memory
  if(shmdt(shmid) < 0){
    printf("shmdt failed\n");
    exit(1);
  }
  printf("shmdt: detached shared memory\n");

  // Delete shared memory
  if(shmctl(shmid) < 0){
    printf("shmctl failed\n");
    exit(1);
  }
  printf("shmctl: deleted shared memory\n");

  printf("Shared memory test complete!\n");
  exit(0);
}
