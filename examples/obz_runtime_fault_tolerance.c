#include <stdio.h>
#include "obz_scheduler.h"


void thread_function(void *arg) {
 int result = 1 + 1;
 while (1) {
    printf("Thread %s: 1 + 1 = %d\n", arg, result);
    sleep(1000);
 }
}

void thread_fail_function(void *arg) {
  printf("Thread %s \n", arg);
  int result = 1 / 0 ; // this will fail
  printf("Thread %s: 1 + 1 = %d\n", arg, result); // this will never be executed
}


int main() {
    setup_fault_tolerance_signal_handler(); // setting up the signal handler for fault tolerance
    /*
    code get inserted 👇
    */
    green_thread_create(thread_function, "1");
    green_thread_create(thread_fail_function, "Faulty thread 1");
    green_thread_create(thread_fail_function, "Faulty thread 2");
    green_thread_create(thread_fail_function, "Faulty thread 3");
    green_thread_create(thread_fail_function, "Faulty thread 4");
    /*
    code get inserted 👆
    */
    green_thread_run();
    return 0;
}
