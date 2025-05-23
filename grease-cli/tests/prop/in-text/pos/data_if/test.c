/* Copyright (c) Galois, Inc. 2024 */

__attribute__((section(".data"))) int inc(int x) { return x + 1; }

__attribute__((noinline)) int dec(int x) { return x - 1; }

int test(int x) {
  if (x) {
    return inc(x);
  }
  return dec(x);
}
