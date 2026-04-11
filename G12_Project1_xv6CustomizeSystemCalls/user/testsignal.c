#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void myhandler() {
  printf("Signal received!\n");
}

int main() {
  signal(myhandler);

  int pid = fork();

  if(pid == 0){
    while(1);   // child runs forever
  } else {
    sleep2(10);
    kill(pid);   // send signal
  }

  exit(0);
}
