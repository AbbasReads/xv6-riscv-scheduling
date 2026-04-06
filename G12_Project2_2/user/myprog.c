#include "kernel/types.h"
#include "user/user.h"

int main()
{
    int p;
    p = fork();
    if (p == 0)
    {
        // printf("HI THERE IM CHILD\n");

        // pause(50);

        printf("CHILD end\n");
    }
    else
    {
        // int *x = (int *)1;
        // pause(25);
        // printf("HI THERE IM PARENT\n");
        // pause(25);
        // printf("HI THERE IM PARENT\n");
        // wait(x);
        printf("PARENT end");
    }
}