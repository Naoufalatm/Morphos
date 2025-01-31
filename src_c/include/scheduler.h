/**
 * @file: scheduler.h
 * @author: Obz Team
 * This file contains foundational data structure Scheduler , that comprises all the data about the global scheduler object
*/

#ifndef SCHEDULER_H_
#define SCHEDULER_H_

#include "thread.h"
#include "obz_scheduler.h"

/**
 * scheduler is a struct that holds metadata about the scheduler global object , the one that will do the scheduling of the green thread :
 * threads: is an allocated array that holds a pointer to greenthread objects
 * current_thread: is the current thread with the `RUNNING` state , the concept of holding the number as an int is used mainly for indexing the threads[] array
 * main_context : is the current ucontext_t of the current_thread ( or threads[current_thread] )
 * old_timer: is used to set and hold the timer that's gonna be consumed by the kernel to send the `SIGALRM` signal
 * old_action  & is_switching : are not used !
*/
typedef struct Scheduler {
    GreenThread* threads[MAX_THREADS];
    int thread_count;
    int current_thread;
    ucontext_t main_context;
    struct sigaction old_action; // place holder for context switching
    struct itimerval old_timer;
    bool is_switching;
} Scheduler;


#endif // SCHEDULER_H_
