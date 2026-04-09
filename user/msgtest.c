#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void)
{
    // fork child 1
    int pid1 = fork();
    if (pid1 == 0) {
        char buf[256];
        int sender = recvmsg(buf, sizeof(buf));
        printf("Child 1 got broadcast from pid %d: %s\n", sender, buf);
        exit(0);
    }

    // fork child 2
    int pid2 = fork();
    if (pid2 == 0) {
        char buf[256];
        int sender = recvmsg(buf, sizeof(buf));
        printf("Child 2 got broadcast from pid %d: %s\n", sender, buf);
        exit(0);
    }

    // parent broadcasts
    char bmsg[] = "hello everyone";
    int n = broadcast(bmsg, sizeof(bmsg));
    printf("Parent broadcast to %d processes\n", n);

    wait(0);
    wait(0);
    exit(0);
}
