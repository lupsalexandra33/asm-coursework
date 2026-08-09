# x86 Assembly Coursework

Solutions to two university assignments written in **32-bit x86 assembly (NASM
syntax)**, with the functions called from C. Each homework lives in its own
directory and has a README explaining, task by task, how the implementation
works, register layout, auxiliary variables, and the role of every label.

## Contents

### [Homework 2](homework-2)

| Task | Problem | Key idea |
| --- | --- | --- |
| 1 | Filter an array, keeping even numbers that are not powers of two | `test` for parity, `x & (x - 1)` for the power-of-two check |
| 2 | Validate and sort a list of dated events | `struc` / `istruc` for nested structures, BubbleSort with a cascade of criteria |
| 3 | Base64 encoding | packing 3 × 8 bits into a 24-bit group, then splitting it into 4 × 6 bits with shifts and masks |
| 4 | Sudoku validation | range and duplicate checks on rows, columns and 3 × 3 boxes |

### [Homework 3](homework-3)

| Task | Problem | Key idea |
| --- | --- | --- |
| 1 | Link array nodes into a sorted linked list | building the list in place while tracking head and tail |
| 2 | Split a text into words and sort them | custom comparator passed to libc `qsort` |
| 3 | Recursive k-Fibonacci | recursion with the registers preserved across each call |
| 4 | Longest composite palindrome | bitmask enumeration of every subset, with `malloc` / `free` for the candidates |

## Techniques covered

- cdecl calling convention: arguments pushed in reverse order, return value in
  `eax`, caller-side stack cleanup
- stack frames with `enter` / `leave`, register preservation with `pusha` /
  `popa` and explicit `push` / `pop`
- recursion in assembly
- calling libc from assembly: `qsort`, `malloc`, `free`, `strlen`, `strcpy`,
  `strcat`, `strcmp`
- bit manipulation: shifts, masks, subset enumeration with bitmasks
- data structures: linked lists, nested structures via `struc` / `istruc`,
  arrays of strings

## Building

The sources are assembled for 32-bit x86 and linked against a C driver:

```bash
nasm -f elf32 task-1/sortari.asm -o sortari.o
gcc -m32 main.c sortari.o -o task1
```
All nine sources assemble cleanly on their own. The C drivers and test suites
were provided by the course and are not part of this repository, so the functions
here are meant to be linked against your own main.