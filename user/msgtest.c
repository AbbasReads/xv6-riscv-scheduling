#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(void)
{
    int pid = fork();

    if (pid == 0) {
        // child: receive
        char buf[256];
        int sender = recvmsg(buf, sizeof(buf));
        printf("Child got from pid %d: %s\n", sender, buf);
        exit(0);
    } else {
        // parent: send
        sendmsg(pid, "hello child", 12);
        wait(0);

        // broadcast
        char bmsg[] = "broadcast test";
        int n = broadcast(bmsg, sizeof(bmsg));
        printf("Parent broadcast to %d processes\n", n);

        exit(0);
    }
}
