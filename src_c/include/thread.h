/**
 * @file: thread.h
 * @author: Obz Team
 * This file contains foundational data structures and Enums , GreenThread is struct comprising metadata about the green threads ,
 * the ThreadState enum contains possible state of a green thread.
*/

#ifndef THREAD_H_
#define THREAD_H_
#include <ucontext.h>


/**
 * This Enum is used to differentiate between the possible green threads states .
*/
typedef enum {
    READY,
    RUNNING,
    FINISHED
} ThreadState;

/**
 * GreenThread is a struct that holds metadata about green thread :
 * context: is the field that contains snapshot of all process , memory related data whilst running the green thread ( register's values ,
 * process register counter ...  ) .
 * stack: contains the custom stack that will hold the local variables for the wrapped anonymous functions ( not working properly  ) .
 * state: the current state of the green thread .
 * function: the function that the green thread in quesiton will run .
 * arg: the argument that are gonna be fed to the wrapped function .
*/
typedef struct GreenThread {
    ucontext_t context;
    void* stack;
    int id;
    ThreadState state;
    void (*function)(void*);
    void* arg;
} GreenThread;

#endif // THREAD_H_
