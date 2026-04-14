#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

static void
fail(const char *msg)
{
  printf("msgtest: FAIL: %s\n", msg);
  exit(1);
}

static void
check_status(int status, const char *phase)
{
  if(status != 0){
    printf("msgtest: FAIL: child failed during %s\n", phase);
    exit(1);
  }
}

int
main(void)
{
  int status;
  int parent = getpid();
  char direct[] = "direct hello";
  char group[] = "broadcast hello";

  int child = fork();
  if(child < 0)
    fail("fork failed for direct sendmsg/recvmsg check");
  if(child == 0){
    char buf[32];
    int sender = recvmsg(buf, sizeof(buf));
    if(sender != getppid()){
      printf("msgtest: child expected sender %d, got %d\n", getppid(), sender);
      exit(1);
    }
    if(strcmp(buf, direct) != 0){
      printf("msgtest: child received unexpected direct message '%s'\n", buf);
      exit(1);
    }
    exit(0);
  }

  pause(20);
  if(sendmsg(child, direct, strlen(direct) + 1) != 0)
    fail("sendmsg should succeed");
  if(wait(&status) < 0)
    fail("wait failed after direct message test");
  check_status(status, "direct message");

  int child1 = fork();
  if(child1 < 0)
    fail("first fork failed for broadcast test");
  if(child1 == 0){
    char buf[32];
    int sender = recvmsg(buf, sizeof(buf));
    if(sender != getppid() || strcmp(buf, group) != 0){
      printf("msgtest: broadcast receiver 1 saw sender=%d msg='%s'\n",
             sender, buf);
      exit(1);
    }
    exit(0);
  }

  int child2 = fork();
  if(child2 < 0)
    fail("second fork failed for broadcast test");
  if(child2 == 0){
    char buf[32];
    int sender = recvmsg(buf, sizeof(buf));
    if(sender != getppid() || strcmp(buf, group) != 0){
      printf("msgtest: broadcast receiver 2 saw sender=%d msg='%s'\n",
             sender, buf);
      exit(1);
    }
    exit(0);
  }

  pause(20);
  if(broadcast(group, strlen(group) + 1) < 2)
    fail("broadcast should deliver to at least the two child processes");

  if(wait(&status) < 0)
    fail("wait failed for first broadcast child");
  check_status(status, "broadcast child 1");
  if(wait(&status) < 0)
    fail("wait failed for second broadcast child");
  check_status(status, "broadcast child 2");

  if(parent != getpid())
    fail("parent PID changed unexpectedly");

  printf("msgtest: all checks passed\n");
  exit(0);
}
