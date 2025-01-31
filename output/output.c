#include <stdio.h>
#include "obz_scheduler.h"

int main() {
    setup_fault_tolerance_signal_handler();
    /*
    code get inserted 👇
    */
    green_thread_create(
        lambda(void, (void* arg), { 
            while (1) {int x = 0    ;
            char* y = "hamid"    ;
            printf("%s \n", "yaay")    ;
            printf("%d \n", x)    ;
            printf("%s \n", y);} 
 }), NULL);
    /*
    code get inserted 👆
    */
    green_thread_run();
    return 0;
}

