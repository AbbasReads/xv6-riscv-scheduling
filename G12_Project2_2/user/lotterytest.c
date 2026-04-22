#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

#define NCHILD 5
#define START_DELAY 10
#define RUN_TICKS 120
#define CHECK_INTERVAL 256

struct result {
  int slot;
  int pid;
  int work;
};

static void
worker(int slot, int writefd, int start_tick, int end_tick)
{
  struct result r;
  int work = 0;

  while(uptime() < start_tick)
    ;

  for(;;){
    for(volatile int i = 0; i < 2000; i++)
      ;

    work++;

    if((work % CHECK_INTERVAL) == 0 && uptime() >= end_tick)
      break;
  }

  r.slot = slot;
  r.pid = getpid();
  r.work = work;
  write(writefd, &r, sizeof(r));
  close(writefd);
  exit(0);
}

int
main(void)
{
  int fds[2];
  struct result results[NCHILD];
  int got = 0;
  int start_tick;
  int end_tick;

  printf("lotterytest: equal-ticket fairness test\n");
  printf("lotterytest: %d CPU-bound children, %d ticks\n", NCHILD, RUN_TICKS);
  printf("lotterytest: all children use the kernel default ticket count\n");

  if(pipe(fds) < 0){
    printf("lotterytest: pipe failed\n");
    exit(1);
  }

  start_tick = uptime() + START_DELAY;
  end_tick = start_tick + RUN_TICKS;

  for(int i = 0; i < NCHILD; i++){
    int pid = fork();

    if(pid < 0){
      printf("lotterytest: fork failed\n");
      exit(1);
    }

    if(pid == 0){
      close(fds[0]);
      worker(i, fds[1], start_tick, end_tick);
    }
  }

  close(fds[1]);

  while(got < NCHILD){
    int n = read(fds[0], &results[got], sizeof(results[got]));
    if(n == 0)
      break;
    if(n != sizeof(results[got])){
      printf("lotterytest: short read: %d bytes\n", n);
      exit(1);
    }
    got++;
  }

  close(fds[0]);

  for(int i = 0; i < NCHILD; i++)
    wait(0);

  if(got != NCHILD){
    printf("lotterytest: expected %d results, got %d\n", NCHILD, got);
    exit(1);
  }

  int min = results[0].work;
  int max = results[0].work;
  int total = 0;

  for(int i = 0; i < got; i++){
    if(results[i].work < min)
      min = results[i].work;
    if(results[i].work > max)
      max = results[i].work;
    total += results[i].work;
  }

  for(int i = 0; i < got; i++){
    int pct = results[i].work * 100 / total;
    printf("child slot=%d pid=%d work=%d share=%d%%\n",
           results[i].slot, results[i].pid, results[i].work, pct);
  }

  printf("lotterytest: min=%d max=%d total=%d\n", min, max, total);

  if(max > min * 4){
    printf("lotterytest: WARN distribution is wider than expected\n");
    printf("lotterytest: randomness, short runs, or multiple CPUs can affect this\n");
  } else {
    printf("lotterytest: PASS equal-ticket children received comparable CPU time\n");
  }

  exit(0);
}
