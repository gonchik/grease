/* Copyright (c) Galois, Inc. 2024 */

#include <stdlib.h>

void panic(void) {
    abort();
}

int test(void) {
    panic();
    return 0;
}
