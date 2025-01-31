/**
 * @file: fault_tolerance.c
 * @author: Obz team
 *
 * This file contains functions concerning handling for interupts and other signals besides the `SIGALRM`
* that's used in the scheduling of the green threads
*/




#include "obz_scheduler.h"
#include <signal.h>

extern struct sigaction sa;
void signal_handler(int sig);


/**
 * This function does set the interput handler for bootstraping rudimentary fault tolerance for the failure of the
 * Green threads
*/
void setup_handle_signals() {
    sigaction(SIGSEGV, &sa, NULL);
    sigaction(SIGFPE, &sa, NULL);
    sigaction(SIGILL, &sa, NULL);
}

void signal_handler(int sig){

}
