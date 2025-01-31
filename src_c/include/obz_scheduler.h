/**
 * @file: obz_scheduler.h
 * @author: Obz Team
 * This file contains the signature for the dynamically linked funtion that's gonna be used when compiling
 * the sample program with our statically linked library.
 * Each function is well documented in its appropriate file .
*/

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
#define TIME_SLICE_MS 256 // this is what sets the context switichign ( a hack )




#endif // OBZ_SCHEDULER_H_
