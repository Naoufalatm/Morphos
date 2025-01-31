#include <stdio.h>
#include "obz_scheduler.h"


void thread_function(void *arg) {
    while (1)
        {
            int result = 1 + 1;
            printf("Thread %s: 1 + 1 = %d\n", arg, result);
        }
}


int main() {
    setup_fault_tolerance_signal_handler();
    /*
    code get inserted 👇
    */
    green_thread_create(thread_function, "1");
    green_thread_create(thread_function, "2");
    green_thread_create(thread_function, "3");
    green_thread_create(thread_function, "4");
    /*
    code get inserted 👆
    */
    green_thread_run();
    return 0;
}
