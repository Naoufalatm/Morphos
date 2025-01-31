#ifndef OBZ_SCHEDULER_H_
#define OBZ_SCHEDULER_H_

#include <stdio.h>
#include <stdlib.h>
#include <ucontext.h>
#include <signal.h>
#include <string.h>
#include <stdbool.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>


static void schedule_next_thread(void);
void thread_wrapper(void);
static void setup_timer(void);
static void timer_handler(int signum);
int green_thread_create(void (*function)(void*), void* arg);
void green_thread_run(void);
void setup_fault_tolerance_signal_handler();
void run();

#define STACK_SIZE (1024 * 1024)  // 1MB stack size ( arbitraire )
#define MAX_THREADS 64
#define TIME_SLICE_MS 40 // this is what sets the context switichign ( a hack )



#define lambda(lambda$_ret, lambda$_args, lambda$_body)\
  ({\
    lambda$_ret lambda$__anon$ lambda$_args\
      lambda$_body\
    &lambda$__anon$;\
  })

#endif // OBZ_SCHEDULER_H_
