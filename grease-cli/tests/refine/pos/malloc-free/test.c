/* Copyright (c) Galois, Inc. 2024 */

#include <stddef.h>

// A basic test that ensures the malloc and free overrides work as expected.
// The implementations of malloc and free below don't matter, since they will
// ultimately be overridden.
void* malloc(size_t size) {
  return 0;
}
void free(void* ptr) {}

int test(void) {
  int* p = malloc(sizeof(int));
  *p = 42;
  int x = *p;
  free(p);
  return x;
}
