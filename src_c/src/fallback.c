/**
 * @file: fallback.c
 * @author: Obz team
 *
 * This file contains functions concerning handling for interupts and other signals besides the `SIGALRM`
 * that's used in the scheduling of the green threads
 */

#include "obz_scheduler.h"
#include "scheduler.h"
#include <stdlib.h>


// scheduler is a global object defined in the scheduler.c
extern Scheduler scheduler;


/**
 * This function is a rudimentary fallback signal handler , the sleep is to make the printf micro task run the last ,
 * since other green processes will be printing theirs
 */
void fallback(int signum) {
    // TODO: Add a crash Log mechanism to record all processes crashes
    if (signum == SIGINT){
        printf("[Error] This is an interrupt C^c  \n");
        exit(SIGINT);
    }

    if (signum == SIGFPE){
        printf("[Error] Floating point exception raised  \n");
    }

    if (signum == SIGSEGV){
        printf("[Error] SegFault exception raised, leaving ....   \n");
    }
    sleep(4000);
}


/**
 * This function does set the interput handler for bootstraping rudimentary fault tolerance for the failure of the
 * Green threads
 */
void setup_fault_tolerance_signal_handler() {
    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = &fallback;
    sigaction(SIGFPE, &sa, &scheduler.old_action);
    sigaction(SIGSEGV, &sa, &scheduler.old_action);
    sigaction(SIGINT, &sa, &scheduler.old_action);
}
