# asmlings

Learn x86-64 assembly by fixing small programs.

Inspired by [rustlings](https://github.com/rust-lang/rustlings). The tool itself is written entirely in x86-64 assembly.

## Features

- 28 exercises covering fundamentals to function calls
- Watch mode with auto-recompile on save
- Works with any editor (vim, vscode, etc.)
- Written in assembly - no libc, just raw syscalls
- No dependencies beyond `as` and `ld`

## Prerequisites

```bash
# You need GNU assembler and linker (usually pre-installed on Linux)
which as ld

# On Debian/Ubuntu if missing:
sudo apt install binutils
```

## Quick Start

```bash
# Build
make

# Start learning
./asmlings

# Other commands
./asmlings list      # Show all exercises
./asmlings hint      # Get hint for current exercise
./asmlings hint 05   # Get hint for specific exercise
./asmlings help      # Show help
```

## How It Works

1. Open exercises in your editor
2. Read the instructions in each file
3. Fix the code
4. Remove the `# I AM NOT DONE` marker
5. Save - asmlings detects changes and checks your solution

## Exercises

28 exercises in AT&T syntax:

| #  | Exercise       | Topic                    |
|----|----------------|--------------------------|
| 01 | intro          | Your first program       |
| 02 | exit_code      | Exit with specific code  |
| 03 | mov            | Moving data              |
| 04 | registers      | Register usage           |
| 05 | add            | Addition                 |
| 06 | sub            | Subtraction              |
| 07 | mul            | Multiplication           |
| 08 | div            | Division                 |
| 09 | and            | Bitwise AND              |
| 10 | or             | Bitwise OR               |
| 11 | xor            | Bitwise XOR              |
| 12 | shifts         | Bit shifting             |
| 13 | memory         | Loading from memory      |
| 14 | store          | Storing to memory        |
| 15 | cmp            | Comparisons              |
| 16 | jumps          | Conditional jumps        |
| 17 | loop           | Loops                    |
| 18 | push_pop       | Stack basics             |
| 19 | stack_save     | Saving registers         |
| 20 | call_ret       | Function calls           |
| 21 | stack_frame    | Stack frames             |
| 22 | alignment      | Stack alignment          |
| 23 | locals         | Local variables          |
| 24 | args           | Function arguments       |
| 25 | callee_save    | Callee-saved registers   |
| 26 | write          | Write syscall            |
| 27 | read           | Read syscall             |
| 28 | string_len     | String length            |

## AT&T Syntax Quick Reference

```asm
movq $60, %rax      # immediate to register
movq %rax, %rdi     # register to register
movq (%rax), %rdi   # memory to register
movq %rdi, (%rax)   # register to memory
```

- Source comes before destination: `src, dest`
- Registers prefixed with `%`
- Immediates prefixed with `$`
- Memory access with parentheses: `(%rax)`
- Size suffixes: `b` (byte), `w` (word), `l` (long), `q` (quad)

## Syscalls

Linux x86-64 syscall convention:
- Syscall number in `%rax`
- Arguments in `%rdi`, `%rsi`, `%rdx`, `%r10`, `%r8`, `%r9`
- Return value in `%rax`
- `syscall` instruction to invoke

Common syscalls:
| Number | Name  | Args                    |
|--------|-------|-------------------------|
| 0      | read  | fd, buf, count          |
| 1      | write | fd, buf, count          |
| 60     | exit  | status                  |

## Building

```bash
make          # Build asmlings
make test     # Run test suite
make clean    # Clean build artifacts
```

## Implementation

The tool uses Linux syscalls directly:
- `inotify` for file watching
- `getdents64` for directory listing
- `fork/execve/wait4` for running assembler/linker
- `read/write` for file and terminal I/O

## Resources

- [Linux Syscall Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)
- [x86-64 Registers](https://wiki.osdev.org/CPU_Registers_x86-64)
- [GAS Manual](https://sourceware.org/binutils/docs/as/)
- [System V AMD64 ABI](https://refspecs.linuxbase.org/elf/x86_64-abi-0.99.pdf)

## License

MIT
