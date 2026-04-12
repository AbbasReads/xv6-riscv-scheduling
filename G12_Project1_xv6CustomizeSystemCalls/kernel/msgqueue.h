#include "spinlock.h"
#include "types.h"

#define MAX_MSG_SIZE 256
#define MSG_QUEUE_LEN 16

struct message {
  int sender_pid;
  int size;
  char data[MAX_MSG_SIZE];
};

struct msgqueue {
  struct message buf[MSG_QUEUE_LEN];
  int head;
  int tail;
  int count;
  struct spinlock lock;
};
