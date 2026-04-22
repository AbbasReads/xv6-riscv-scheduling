#include <stdio.h>
#include <stdlib.h>

#define NTASKS 3

struct task {
  const char *name;
  int period;
  int burst;
  int remaining;
  int next_release;
  int jobs_done;
};

static int
priority(const struct task *t)
{
  return 1000 / t->period;
}

static int
pick_task(struct task tasks[], int now)
{
  int best = -1;

  for(int i = 0; i < NTASKS; i++){
    if(tasks[i].remaining == 0 && now >= tasks[i].next_release)
      tasks[i].remaining = tasks[i].burst;

    if(tasks[i].remaining == 0)
      continue;

    if(best < 0 || tasks[i].period < tasks[best].period)
      best = i;
  }

  return best;
}

int
main(void)
{
  struct task tasks[NTASKS] = {
    { "T1", 4, 1, 0, 0, 0 },
    { "T2", 6, 2, 0, 0, 0 },
    { "T3", 12, 3, 0, 0, 0 },
  };
  int total_ticks = 24;

  printf("RMS demo reference\n");
  printf("Shorter period means higher static priority.\n\n");

  for(int i = 0; i < NTASKS; i++){
    printf("Task %s | period=%d | burst=%d | priority=%d\n",
           tasks[i].name, tasks[i].period, tasks[i].burst,
           priority(&tasks[i]));
  }

  printf("\nTimeline:\n");

  for(int now = 0; now < total_ticks; now++){
    int selected = pick_task(tasks, now);

    if(selected < 0){
      printf("Time %d: Idle\n", now);
      continue;
    }

    printf("Time %d: %s\n", now, tasks[selected].name);

    tasks[selected].remaining--;
    if(tasks[selected].remaining == 0){
      tasks[selected].jobs_done++;
      tasks[selected].next_release += tasks[selected].period;
    }
  }

  printf("\nSummary:\n");
  for(int i = 0; i < NTASKS; i++)
    printf("%s completed jobs=%d\n", tasks[i].name, tasks[i].jobs_done);

  return EXIT_SUCCESS;
}
