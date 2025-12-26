# asmlings

Learn x86-64 assembly by fixing small programs. Inspired by [rustlings](https://github.com/rust-lang/rustlings).

**46 exercises** covering:
- Basics (registers, arithmetic, logic)
- Memory operations (load, store, addressing)
- Control flow (comparisons, jumps, loops)
- Stack and functions (leaf functions, recursion, stack frames, calling conventions)
- System I/O (read, write, files, arguments)

## Prerequisites

Linux with `as`, `ld`, and optionally `gcc` (for C interop exercises).

## Quick Start

```bash
make                 # Build asmlings
./asmlings           # Start learning (watch mode)
```

## Commands

```bash
./asmlings           # Watch mode - auto-checks on save
./asmlings list      # Show all exercises with progress
./asmlings hint      # Get hint for current exercise
./asmlings hint 05   # Get hint for exercise 05
./asmlings check 05  # Check specific exercise
./asmlings run 35    # Run exercise with stdin passthrough
./asmlings help      # Show all commands
```

## How It Works

1. Run `./asmlings` - it watches for file changes
2. Open `exercises/01_intro.s` in your editor
3. Read the instructions, fix the code
4. Remove `# I AM NOT DONE` when ready
5. Save - asmlings checks your solution automatically

## Compiling Assembly Manually

```bash
as program.s -o program.o            # Assemble
ld program.o -o program              # Link
./program                            # Run
echo $?                              # Check exit code
```

## Resources

- [ASM-101 (English)](docs/ASM-101-EN.pdf) - Comprehensive x86-64 assembly guide
- [ASM-101 (Français)](docs/ASM-101-FR.pdf) - Guide complet d'assembleur x86-64
- [Syscall Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)
- [x86-64 Registers](https://wiki.osdev.org/CPU_Registers_x86-64)

## Development

```bash
make test            # Run test suite (requires bats)
make clean           # Clean build artifacts
```

## AI Usage

Claude Code (Opus 4.5) assisted with:
- Dynamic exercise validation system
- Stdout/stdin capture via pipes
- Modular architecture refactoring
- Test suite (56 BATS tests)
- Documentation

The core watcher, exercises, and hints were written mostly manually and polished by Claude.
