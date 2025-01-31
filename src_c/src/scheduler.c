/**
 * @file: scheduler.c
 * @author: Obz team
 *
 * This file contains functions concerning the initialization of the global scheduler object  , and function concerning the internals
 * of the scheduler ( runtime )
*/


#include "obz_scheduler.h"
#include "scheduler.h"

// Main scheduler, globally defined here with deffault values ;
Scheduler scheduler = {
    .thread_count = 0,
    .current_thread = -1,
    .is_switching = false
};


/**
 * this function does setup initial `SIGALRM` signal handler , this concept of scheduling is based on signal scheduling
 * which relies on the kernel signaling capabilities in order to switch contexts between different green threads
*/
static void setup_timer(void) {
    struct sigaction sa; //
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = &timer_handler;
    sigaction(SIGALRM, &sa, &scheduler.old_action);

    // Configure timer for TIME_SLICE_MS milliseconds
    struct itimerval timer; //
    timer.it_value.tv_sec = 0;
    timer.it_value.tv_usec = TIME_SLICE_MS ; // initial bootstrapping of the timer !
    timer.it_interval = timer.it_value; // the interval of the timer !

    setitimer(ITIMER_REAL, &timer, NULL);
}

/**
 * this function does call schedule_next_thread(), upon finding if the currently running green thread has the state `RUNNING`
 * otherwise leave
*/
static void timer_handler(int signum) {
    /*
     * Bootstrapping the time handler  */
    if (scheduler.current_thread != -1) {
        GreenThread* current = scheduler.threads[scheduler.current_thread];
        if (current->state == RUNNING) {
            current->state = READY;
            schedule_next_thread();
        }
    }
}

/**
 * this function does change the state of the green thread in order to execute the code in the anonymous function
*/
void thread_wrapper(void) {
    GreenThread* current = scheduler.threads[scheduler.current_thread];

    current->state = RUNNING;
    current->function(current->arg);
    current->state = FINISHED;
}

/**
 * this function does change the context of green threads , basically scheduling between green threads ;
*/
static void schedule_next_thread(void) {
    scheduler.is_switching = true;

    int next_thread = -1;
    int current = scheduler.current_thread;

    // Simple round-robin scheduling
    for (int i = 1; i <= scheduler.thread_count; i++) {
        int idx = (current + i) % scheduler.thread_count;
        if (scheduler.threads[idx]->state == READY) {
            next_thread = idx;
            break;
        }
    }

    if (next_thread == -1) {
        scheduler.is_switching = false;
        setcontext(&scheduler.main_context);
        return;
    }

    int prev_thread = scheduler.current_thread;
    scheduler.current_thread = next_thread;
    scheduler.threads[next_thread]->state = RUNNING;

    scheduler.is_switching = false;

    if (prev_thread == -1) {
        // First thread being scheduled
        setcontext(&scheduler.threads[next_thread]->context);
    } else {
        // Switch from current thread to next thread
        swapcontext(&scheduler.threads[prev_thread]->context,
                    &scheduler.threads[next_thread]->context);
    }
}

/**
 * this function kickstarts the scheduler
*/
void green_thread_run(void) {
    if (scheduler.thread_count == 0) {
        return;
    }

    // Save the main context
    if (getcontext(&scheduler.main_context) == -1) {
        perror("getcontext");
        return;
    }

    // Set up timer for preemptive scheduling
    setup_timer();

    // Schedule first thread
    schedule_next_thread();

    // Restore original timer and signal handler
    setitimer(ITIMER_REAL, &scheduler.old_timer, NULL);
    sigaction(SIGALRM, &scheduler.old_action, NULL);

    // Clean up finished threads
    for (int i = 0; i < scheduler.thread_count; i++) {
        if (scheduler.threads[i]->state == FINISHED) {
            free(scheduler.threads[i]->stack);
            free(scheduler.threads[i]);
        }
    }
}
