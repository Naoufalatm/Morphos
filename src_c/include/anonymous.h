/**
 * @file: anonymous.h
 * @author: Obz Team
 * This file concerns
*/



#ifndef ANONYMOUS_H_
#define ANONYMOUS_H_
#include "obz_scheduler.h"


/**
 * This macro takes the return , the args (variable)  and the body ( as a block ) and
 * plugs it out and return the address of the function pointer to be consumed by
 * the green_thread_create() function ( takes it as a wrapper ).
*/
#define lambda(lambda$_ret, lambda$_args, lambda$_body)\
  ({\
    lambda$_ret lambda$__anon$ lambda$_args\
      lambda$_body\
    &lambda$__anon$;\
  })


#endif // ANONYMOUS_H_
