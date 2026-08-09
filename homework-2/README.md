# PCLP2 - Homework 2

Four tasks written in x86 (32-bit) assembly, NASM syntax. The functions are
called from C, so they follow the cdecl calling convention: parameters are read
from the stack relative to `ebp`, and the return value is passed back in `eax`.

| Task | File | Implemented functions |
| --- | --- | --- |
| 1 | `task-1/remove_numbers.asm` | `remove_numbers` |
| 2 | `task-2/subtask1.asm` | `check_events` |
| 2 | `task-2/subtask2.asm` | `sort_events` |
| 3 | `task-3/base64.asm` | `base64` |
| 4 | `task-4/sudoku.asm` | `check_row`, `check_column`, `check_box` |

---

## Task 1 - Filtering an array

```c
void remove_numbers(int *a, int n, int *target, int *ptr_len);
```

The function copies into `target` only those elements of `a` that are **even**
and **not powers of two**, then writes the resulting length through `ptr_len`.

**Register layout**

- `esi` = source array `a`
- `ebx` = `n`
- `edi` = destination array `target`
- `eax` = index used to walk through `a`
- `ecx` = counter for the elements written into `target`

**How it works**

The two registers left unused by the skeleton, `eax` and `ecx`, are initialised
with `0`. Inside a loop running from `0` to `n - 1`, the current element is
loaded into `edx` and first tested for parity with `test edx, 1`. If the result
is non-zero the number is odd, so the flow jumps to `skip` and the element is
discarded.

Otherwise the element is checked against the power-of-two condition. Since no
free register is left at this point, `ebx` is pushed on the stack so it can be
temporarily reused and restored afterwards. The classic trick is applied: `ebx`
receives the current value, is decremented by one, and is then ANDed with the
original number. For a power of two the result is `0`, which sends the flow to
`skip` as well.

If both filters are passed, the element is written as `target[ecx]`, both `ecx`
and `eax` are incremented, and the loop continues. The `skip` label only advances
`eax` and jumps back to `start_loop`.

When `eax` reaches `n`, `end_loop` reloads the `ptr_len` pointer from `[ebp + 20]`,
`edx` was overwritten during the loop, and stores the final value of `ecx`
at that address.

## Task 2 - Events: validation and sorting

Both subtasks share the same two structures, declared with `struc` / `endstruc`:

```
struc date          struc event         ; 31 + 1 + 4 = 36 bytes
    .day:  resb 1       .name:  resb 31
    .month:resb 1       .valid: resb 1
    .year: resw 1       .date:  istruc date ...
endstruc            endstruc
```

Because `date` is embedded through `istruc`, the offsets of its fields inside an
`event` follow directly from their position: `day` sits at offset 32, `month` at
33 and `year` at 34. Fields are therefore addressed as
`[ebx + event.date + date.year]` and similar.

### Subtask 1 - `check_events(event *v, int len)`

Marks every event as valid or invalid by setting its `valid` field.

`edx` is initialised with `0` and used as the index over the array of events.
For each event the checks are performed in order:

1. **Year** = must be between 1990 and 2030.
2. **Month** = must be between 1 and 12.
3. **Day** = must be at least 1.

The upper bound for the day depends on the month, so the month is first tested
for parity, and each branch routes to the appropriate check:

- **Odd months** = 1, 3, 5 and 7 have 31 days and go to `verificare_31`;
  9 and 11 have 30 days and go to `verificare_30`.
- **Even months** = month 2 goes to `verificare_februarie`; 4 and 6 go to
  `verificare_30`; 8, 10 and 12 go to `verificare_31`.

If the day fits within the limit of its month, `valid` receives `1` and the loop
moves on through `continue_loop`. Any failed check jumps straight to the `false`
label, which sets `valid` to `0` before continuing with the next event.

### Subtask 2 - `sort_events(event *v, int len)`

Sorts the events with **BubbleSort**, using five auxiliary variables declared in
`.bss`:

| Variable | Role |
| --- | --- |
| `i`, `j` | counters for the two nested loops of the algorithm |
| `k` | index used when comparing names letter by letter |
| `indice` | index used when swapping names letter by letter |
| `ok` | flag set to `1` whenever a swap happens |

The outer loop runs from `0` to `n - 1` and the inner one from `0` to `n - i - 1`.
At each step the addresses of events `[j]` and `[j + 1]` are computed and the
pair is compared against a cascade of criteria:

1. **Validity** = valid events come first. If the second event is valid and the
   first is not, the flow jumps to `swap_event`; in the opposite case the pair is
   already in order; if both share the same validity, the comparison continues.
2. **Year** (`verificare_an`) = a larger first year triggers a swap; a smaller
   one means the pair is fine; equal years fall through to the month.
3. **Month** (`verificare_luna`) and then **day** (`verificare_zi`), the same
   logic repeats.
4. **Name** (`sortare_strcmp`) = for identical dates the names are compared
   letter by letter. As long as the letters match, `continuare_verificare`
   increments `k` and the comparison goes on. The first letter that is greater in
   the first name triggers a swap; otherwise the order is already correct.

`swap_event` sets `ok = 1` and exchanges the fields one by one — `valid`, `day`,
`month`, `year`, and finally enters `interschimbare_nume`, which swaps the two
names character by character.

When the inner loop ends (`end_loop2`), `j` is reset to `0` and `i` is
incremented. Before starting a new pass, `ok` is checked: if no swap occurred
during the whole pass, the array is already sorted and the function exits early
through `end_loop`.

## Task 3 - Base64 encoding

```c
void base64(char *a, int n, char *target, int *ptr_len);
```

The Base64 alphabet is declared in `.data` as a 64-character string, and three
variables are used from `.bss`:

| Variable | Role |
| --- | --- |
| `i` | index used to walk through the source string |
| `contor` | number of characters produced so far, growing by 4 per group |
| `lungime` | a copy of `n`, since `ebx` gets overwritten inside the loop |

**How it works**

The loop consumes the input three characters at a time, because 3 × 8 bits map
exactly onto 4 × 6 bits. The three bytes are loaded with `movzx` into `eax`, `ebx`
and `ecx`, where they naturally occupy the lowest 8 bits of each 32-bit register.

They are then packed into a single 24-bit group inside `eax`: the first character
is shifted left by 16 positions, the second by 8, and the two are joined with
`or`. The third one already sits in the lowest 8 bits, so it can be ORed in
directly. The result has the layout `0000 0000 | c0 | c1 | c2`.

The 24-bit group is then split into four 6-bit values. Before each extraction the
group is copied from `eax` into `ebx`, because the working register gets modified
every time and the original group is still needed:

| Output character | Shift right by | Mask |
| --- | --- | --- |
| 1st | 18 | `and ebx, 63` |
| 2nd | 12 | `and ebx, 63` |
| 3rd | 6 | `and ebx, 63` |
| 4th | — | `and ebx, 63` |

The mask `63` is `0011 1111` in binary, so it keeps exactly the lowest six bits.
That value indexes the `alphabet` string, and the resulting character is written
into the destination buffer at `[edi]`, `[edi + 1]`, `[edi + 2]` and `[edi + 3]`.

At the end of each iteration `contor` grows by 4, `esi` and `i` advance by 3 to
reach the next group of input bytes, and `edi` advances by 4. Once the whole
source string has been processed, `end_loop` reloads the `ptr_len` pointer and
stores the final encoded length in it.

## Task 4 - Sudoku validation

Three independent functions, each returning `1` when the checked region is
correct and `2` when it is not.

### `• check_row(char *sudoku, int row)`

`edi` and `ebx` are initialised with `0`, with `ebx` counting the position inside
the row. For each of the nine positions the effective address is computed as
`esi + row * 9 + ebx`, since the board is stored as a flat array of 81 elements
and `esi` points to its beginning.

The value is first range-checked: anything negative or greater than 9 makes the
row invalid, so `eax` receives `2` and the function returns immediately. If the
value is acceptable, a second loop starts at `ecx = ebx + 1` and compares the
current element against all the following ones, two equal values mean a
duplicate on the row and the same error path is taken.

When an element passes both checks, `reluare_row` increments `ebx` and repeats
the process for the next position. If the whole row is covered without problems,
`end_loop_row` sets `eax = 1` and the function exits.

### `• check_column(char *sudoku, int column)`

Identical in structure to `check_row`; only the address computation differs. Here
the position is obtained as `esi + i * 9 + column`, walking down the board one
row at a time. The same two checks are applied, valid range and no duplicates,
with `reluare_column` advancing to the next cell and `end_loop_column` returning
`1` on success.

### `• check_box(char *sudoku, int box)`

The starting index of the 3 × 3 box is computed with the formula:

```
start = (box / 3) * 27 + (box % 3) * 3
```

Since `div` leaves the quotient in `eax` and the remainder in `edx`, the box
number is moved into `eax`, `edx` is zeroed, and the divisor `3` is placed in
`ecx`. After the division the two halves of the formula are computed with `imul`
and added together; the result is moved into `edi`, to which `esi` is added so
that `edi` points directly at the first cell of the box.

**Collecting the values.** A loop running from `0` to `8` copies the nine cells of
the box into `array`, a 9-byte buffer declared in `.bss`. Because the box spans
three separate rows of the board, whenever the counter reaches 3 or 6 the code
jumps to `next_row`, which adds 6 to `edi` in order to skip the rest of the
current row and land on the next line of the same box.

**Checking the values.** With everything gathered in a contiguous buffer, the
duplicate check becomes straightforward. `verificare_duplicate` takes each
element in turn and first validates its range: anything less than or equal to 0
or greater than 9 sends the flow to `incorect_box`, which sets `eax = 2` and
returns. Otherwise `start_loop_2` compares it against every element that follows
it in `array`; a match is again a jump to `incorect_box`. Once an element has been
compared with all the remaining ones, `end_loop_2` moves on to the next one.

If the outer loop completes, the box is correct and `end_loop` sets `eax = 1`.