/* Copyright (c) Galois, Inc. 2024 */

int __attribute__((noinline)) deref(int *p) { return *p; }

int test(void) { return deref((int *)(void *)0xdeadbeef); }
