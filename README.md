# PCLP2 - Homework 3
## Overview

This homework contains four tasks written in x86 (32-bit) assembly, using the
cdecl calling convention: parameters are pushed onto the stack in reverse order,
the return value is passed back in `eax`, and the caller is responsible for
cleaning up the stack after each call.

Every function opens its own stack frame with `enter 0, 0` and closes it with
`leave` / `ret`. Whenever an external function is called, the registers whose
values must survive the call are saved on the stack beforehand and restored
immediately afterwards.

| Task | File | Implemented functions |
| --- | --- | --- |
| 1 | `task-1/sortari.asm` | `sort` |
| 2 | `task-2/operatii.asm` | `get_words`, `sort`, `comparare_cuvinte` |
| 3 | `task-3/kfib.asm` | `kfib` |
| 4 | `task-4/composite_palindrome.asm` | `check_palindrome`, `composite_palindrome` |

---

## Task 1 - Linking the nodes into a sorted list

```c
struct node { int val; struct node *next; };
struct node *sort(int n, struct node *node);
```

The array already holds all the nodes; the job is to link them through their
`next` pointers so that the resulting list is sorted in ascending order, and to
return a pointer to the new head.

**Register layout**

- `eax` = the head of the list (this is also the return value, so it is kept
  here from the very beginning)
- `ebx` = `n`, the number of nodes
- `ecx` = pointer to the start of the array
- `edi` = the tail of the list built so far
- `edx` = counter for the inner loop
- `[i]` = variable declared in `.bss`, counter for the outer loop

**How it works**

The algorithm uses two nested loops. The outer loop (`start_loop_1`) walks
through every value from `1` to `n`, while the inner loop (`start_loop_2`) scans
the whole array looking for the node holding the current value. Both counters are
initialised before entering the loops: `[i]` with `1` and `edx` with `0`.

When the searched element is found, the code checks whether `eax` is still `0`:

- **`primul_element`** = nothing has been added yet, so the node becomes both the
  head (`eax`) and the tail (`edi`) of the list.
- **`adaugare_nod`** = the list already has elements, so the node is appended by
  updating `tail->next` (`[edi + 4]`) and then moving the tail forward
  (`edi = node`).

In both cases, once the node has been linked, `[i]` is incremented and `edx` is
reset to `0` so the next value can be searched for from the beginning of the
array. If the current array element does not match, only `edx` is incremented and
the search continues.

When `[i]` goes past `n` the sorting is finished, control falls into `end_loop`
and the function returns — the result is already sitting in `eax`.

## Task 2 - Splitting a text into words and sorting them

Two functions were required here, `get_words` and `sort`. I started with
`get_words`, and for `sort` I additionally implemented the comparator
`comparare_cuvinte`. A single variable, `i`, is declared in `.bss` and is used by
`get_words` to measure the length of the current word.

### `• get_words(char *s, char **words, int number_of_words)`

Splits the text into words and stores pointers to them in the `words` array.
The recognised delimiters are `.`, `,`, newline and space.

**Register layout**

- `ebx` = the input string
- `ecx` = the array of strings where the words are saved
- `edx` = the number of words
- `eax` = index of the character currently being inspected (reset for each word)
- `edi` = pointer to the beginning of the current word; unlike `eax`, it keeps
  advancing through the whole string
- `esi` = counter for the number of words found so far
- `[i]` = length of the current word

**How it works**

`loop_cuvinte` compares the current byte against each delimiter. If none matches,
`new_char` first checks for the string terminator and otherwise increments both
`eax` and `[i]`, growing the length of the current word.

When a delimiter is found, `cuvant_nou` writes a string terminator in its place
and advances `eax` by one. The address stored in `edi`, the beginning of the
current word, is saved into `words[esi]`, after which `edi` is moved past the
word and its terminator so that it stays aligned with `eax`.

`verificare_delimitatori` then skips over any remaining delimiters before the
next word: as long as delimiters keep appearing, `repeat` advances both `eax` and
`edi`. Once a real character is reached, `[i]` is reset to `0` for the new word,
`esi` is incremented and the flow returns to `loop_cuvinte`.

If the end of the string is reached, `ultimul_cuvant` checks whether `[i]` is
non-zero; if it is, one last word still needs to be recorded in the array.
Finally, `end_loop` loads `words[0]` into `eax` and returns.

### `• sort(char **words, int number_of_words, int size)`

Sorts the words **by length first, and lexicographically for equal lengths**.

The vector of words goes into `ebx`, the number of words into `ecx` and the size
of a word into `edx`. The four parameters required by `qsort` — the array, the
number of elements, the element size and the comparator `comparare_cuvinte` — are
pushed in reverse order, `qsort` is called, and the stack is cleaned up
afterwards. At the end, `eax` receives a pointer to the beginning of the sorted
array.

### `• comparare_cuvinte` - the comparator

The comparator retrieves both string pointers from the stack and dereferences
them to obtain the actual addresses of the two words.

1. **Length computation** = `edi` and `esi` are zeroed and used to count the
   characters of the first and the second word respectively. `strlen_1` and
   `strlen_2` do the same thing: they advance until the string terminator is
   found. Between them, `reatribuire_eax` resets `eax` to `0` so the second
   measurement can start from the first character.
2. **`comparare_rezultate`** = if the first word is longer the function returns
   `1`; if the second is longer it returns `-1`.
3. **lexicographic comparison** = for equal lengths, `edi` is reset to `0` and
   `strcmp_loop` walks both words letter by letter. At the first difference the
   flow jumps to `return_greater` (`eax = 1`) or `return_lower` (`eax = -1`).
   If the end of the words is reached without any difference, `egalitate` sets
   `eax = 0`.

## Task 3 - Recursive k-Fibonacci

```c
int kfib(int n, int k);
```

The recurrence follows three rules:

- `n < k` → return `0`
- `n == k` → return `1`
- `n > k` → return the sum of the previous `k` terms, computed recursively

**How it works**

`ebx` holds `n` and `edx` holds `k`. The two are compared right away: equality
jumps to `return_k1` (`eax = 1`), a smaller `n` jumps to `return_k0` (`eax = 0`),
and both exit the function through the common `end` label.

Otherwise the recursive sum is computed in `edi` (initialised with `0`), with
`ecx` acting as the loop counter running from `1` to `k`. At every iteration
`esi` receives `n - i`; `ecx` and `edx` are pushed to protect them across the
recursive call, the parameters `k` and `n - i` are pushed in reverse order, and
`kfib` calls itself. After the call the stack is cleaned, the registers are
popped back, the returned value is added to the running sum in `edi`, and the
loop moves on.

Once the loop finishes, `end_loop` copies the accumulated sum from `edi` into
`eax` and the function returns.

## Task 4 - The longest composite palindrome

Two functions were needed here: `check_palindrome` and `composite_palindrome`.
The second one relies on six external functions — `malloc`, `free`, `strlen`,
`strcpy`, `strcat` and `strcmp` — and on seven variables declared in `.bss`.

### `• check_palindrome(char *s, int len)`

`eax` receives the string and `ebx` its length. `eax` is pushed on the stack
because it is temporarily reused to compute half of the length; afterwards it is
popped back to its original value. `edi` is initialised with `0` and `esi` with
`len - 1`, since character indexing starts at `0` and the last character sits at
position `n - 1`.

The loop then compares the character at `edi` with its mirror at `esi`
(recomputed at each iteration by subtracting `edi` from the length). At the first
mismatch, `nu_e_palindrom` sets `eax = 0` and the function exits through
`end_loop`. If matching characters are found, `repeat` advances `edi` to the next
pair. If the loop finishes without a mismatch, `e_palindrom` sets `eax = 1`.

### `• composite_palindrome(char **strs, int len)`

The task is solved with the **bitmask** technique: every subset of the input
words is represented by a number, and bit `i` of that number tells whether word
`i` belongs to the subset.

**Variables in `.bss`**

| Variable | Role |
| --- | --- |
| `rezultat` | the best palindrome found so far |
| `rezultat_length` | the length of that palindrome |
| `lungimi` | array holding the length of every input word |
| `p` | the number of possible subsets, i.e. `2^len` (`2^15` in our case) |
| `copie` | a working copy of the current mask |
| `lungime_string` | total length of the words selected by the current mask |
| `temp` | the concatenation produced by the current mask |

**Step 1: precomputing the word lengths.**
`ebx` receives the array of words and `edx` the number of words; `rezultat` and
`lungimi` both start as `NULL`. The number of words is multiplied by `4` to
obtain `len * sizeof(int)`, and `malloc` allocates the `lungimi` array. Then
`loop_retinere_lungimi_cuvinte` walks through every word, calls `strlen` on
`strs[i]` and stores the result at position `ecx` of the array through the
`retinere_lungime` label. `rezultat_length` is initialised with `0`.

**Step 2: iterating over all masks.**
`shiftare` computes `1 << len` and stores it in `p`, after which `ecx` runs from
`1` to `p`, each value representing one possible subset of words.

For every mask, `copie` receives a copy of it, `lungime_string` is reset to `0`,
and `loop_digits` inspects the words one by one: the parity of `copie` tells
whether the current word belongs to the subset. If it does, `suma_lungimi` adds
its length from the `lungimi` array; either way, `next_word_loop` shifts `copie`
one bit to the right (a division by two) and advances `edi` to the next word.

**Step 3: filtering and building the candidate.**
`verif_length` compares the total length of the current subset against the best
palindrome found so far. If the subset cannot possibly beat it, the code jumps
straight to `next_masca`. Otherwise `malloc` allocates `lungime_string + 1` bytes
into `temp`, `temp[0]` is set to `'\0'`, and `loop_concatenare` walks the mask
again, calling `strcat` for every word that belongs to the subset.
`adauga_terminator_sir` then writes the string terminator at the end of the
concatenation.

**Step 4: validating and keeping the best result.**
`check_palindrome` is called on `temp`. If the concatenation is not a palindrome,
`clean_temp` frees the buffer and the loop moves on. If it is, the candidate
replaces the current result when:

- it is strictly longer than `rezultat_length`, **or**
- it has the same length and either `rezultat` is still `NULL`, or `strcmp` shows
  the new string is smaller lexicographically.

In those cases `alocare_sir` frees the previous result (if any), allocates
`lungime_string + 1` bytes and copies `temp` into `rezultat` with `strcpy`.
Either way, `temp` is released through `clean_temp` before `next_masca`
increments `ecx` and the process repeats for the following mask.

**Step 5: cleanup.**
Once every mask has been processed, `palindrom_rezultat` frees the `lungimi`
array, loads the resulting palindrome into `eax` and the function returns.