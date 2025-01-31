#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

void* thread_function(void* arg) {
  while(1)
  {
    int result = 1 + 1;
    printf("Thread %ld: 1 + 1 = %d\n", (long)arg, result);
  }
}

void* thread_fail_function(void *arg) {
  printf("Thread %s \n", arg);
  int result = 1 / 0 ; // this will fail
  printf("Thread %s: 1 + 1 = %d\n", arg, result); // this will never be executed
}


int main() {
  pthread_t threads[4];
  int i;

  for (i = 0; i < 3; i++) {
    if (pthread_create(&threads[i], NULL, thread_function, (void*)(long)i) != 0) {
      fprintf(stderr, "Error creating thread %d\n", i);
      return 1;
    }
  }

  if (pthread_create(&threads[4], NULL, thread_fail_function, (void*)(long)4) != 0) { // it will crash
    fprintf(stderr, "Error creating thread %d\n", 4);
    return 1;
  }


  // this block is unreachable
  for (i = 0; i < 4; i++) {
    if (pthread_join(threads[i], NULL) != 0) {
      fprintf(stderr, "Error joining thread %d\n", i);
      return 2;
    }
  }

  return 0;
}
