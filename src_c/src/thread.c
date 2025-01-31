/**
 * @file: thread.c
 * @author: Obz team
 *
 * This file contains functions concerning the scheduler , and the spawn function ( green_thread_create  ) , the
 * distincting between this name and 'spawn' is made because green_thread_create does create a wrapper around
 * our user-defined anonymous functions and append it into an already global allocated array for green_threads !
*/


#include "obz_scheduler.h"
#include "thread.h"
#include "scheduler.h"

extern Scheduler scheduler ;

/**
 * This function does create a wrapper around user-defined anonymous function and append it to the global thread array
 * 'scheduler.threads[]'
*/
int green_thread_create(void (*function)(void*), void* arg) {
    if (scheduler.thread_count >= MAX_THREADS) {
        return -1;
    }

    GreenThread* thread = (GreenThread*)malloc(sizeof(GreenThread));
    if (!thread) {
        return -1;
    }

    thread->stack = malloc(STACK_SIZE);
    if (!thread->stack) {
        free(thread);
        return -1;
    }

    if (getcontext(&thread->context) == -1) {
        free(thread->stack);
        free(thread);
        return -1;
    }

    thread->context.uc_stack.ss_sp = thread->stack;
    thread->context.uc_stack.ss_size = STACK_SIZE;
    thread->context.uc_link = &scheduler.main_context; // this one is to go to switch to other context whenever the thread is finished !

    thread->id = scheduler.thread_count;
    thread->state = READY;
    thread->function = function;
    thread->arg = arg;

    makecontext(&thread->context, (void (*)(void))thread_wrapper, 0);

    scheduler.threads[scheduler.thread_count++] = thread;

    return thread->id;
}
