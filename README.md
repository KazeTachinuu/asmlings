# asmlings

Learn x86-64 assembly by fixing small programs. Inspired by [rustlings](https://github.com/rust-lang/rustlings).

## Prerequisites

Linux with `gcc`, `as`, `ld` (pre-installed on most systems).

## Usage

```bash
make                 # Build
./asmlings           # Start learning (watch mode)
./asmlings list      # Show all exercises
./asmlings hint      # Get hint for current exercise
./asmlings hint 05   # Get hint for exercise 05
```

## How It Works

1. Run `./asmlings` - it watches for file changes
2. Open `exercises/01_intro.s` in your editor
3. Read the instructions, fix the code
4. Remove `# I AM NOT DONE` when ready
5. Save - asmlings checks your solution automatically

## Compiling Assembly Manually

```bash
gcc -nostdlib -o program program.s   # Compile
./program                            # Run
echo $?                              # Check exit code
```


## Resources

- [ASM-101 (English)](docs/ASM-101-EN.pdf) - Comprehensive x86-64 assembly guide
- [ASM-101 (Français)](docs/ASM-101-FR.pdf) - Guide complet d'assembleur x86-64
- [Syscall Table](https://blog.rchapman.org/posts/Linux_System_Call_Table_for_x86_64/)
- [x86-64 Registers](https://wiki.osdev.org/CPU_Registers_x86-64)

## AI Usage

Claude Code (Opus 4.5) assisted with:
- Dynamic exercise validation (parsing `Expected exit code:` and `Expected output:` from comments)
- Stdout capture via pipes for output verification
- Code cleanup and refactoring for modularity
- Test suite (`tests/test_asmlings.c`)
- Documentation

The core watcher, exercises, and hints were written mostly manually and polished by Claude.
