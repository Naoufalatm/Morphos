#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

void* thread_function(void* arg) {
  while (1)
  {
    int result = 1 + 1;
    printf("Thread %ld: 1 + 1 = %d\n", (long)arg, result);
  }
}

int main() {
    pthread_t threads[4];
    int i;

    for (i = 0; i < 4; i++) {
        if (pthread_create(&threads[i], NULL, thread_function, (void*)(long)i) != 0) {
            fprintf(stderr, "Error creating thread %d\n", i);
            return 1;
        }
    }

    for (i = 0; i < 4; i++) {
        if (pthread_join(threads[i], NULL) != 0) {
            fprintf(stderr, "Error joining thread %d\n", i);
            return 2;
        }
    }

    return 0;
}
