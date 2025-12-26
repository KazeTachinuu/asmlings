# Expected Files Format

Each exercise has a corresponding `XX.txt` file that defines validation rules.

## Directives

| Code | Purpose | Format | Example |
|------|---------|--------|---------|
| `#` | Comment | `# text` | `# This is a comment` |
| `X` | Exit code | `X <code>` | `X 42` |
| `O` | Expected output | `O <text>` | `O Hello` |
| `I` | Stdin input | `I <text>` | `I input data` |
| `A` | Argument | `A <value>` | `A filename.txt` |
| `P` | Prediction | `P <answer>` | `P 67` |
| `F` | Create file | `F <path>:<content>` | `F test.txt:data` |
| `C` | Cleanup file | `C <path>` | `C test.txt` |
| `G` | GCC mode | `G [c_file]` | `G` or `G helper.c` |
| `T` | Timeout | `T <ms>` | `T 2000` |
| `E` | Expected stderr | `E <text>` | `E Error message` |

## Escape Sequences

For `O`, `I`, `E`, and `F` directives:
- `\n` = newline
- `\\` = literal backslash

## Examples

### Exit code only
```
X 42
```

### Output matching
```
X 0
O Hello, World!\n
```

### Input/output
```
X 0
I Hello
O Hello
```

### With arguments
```
X 0
A arg1
A arg2
O arg1 arg2
```

### Prediction exercise
```
P 67
```
Student fills in `# Prediction: ???` in the exercise file.

### File creation and cleanup
```
X 0
F input.txt:file content
A input.txt
O file content
C input.txt
```

### Multiline content
```
X 0
O Line1\nLine2\nLine3
```

### GCC mode (C library calls)
```
G
X 0
O Hello from puts
```

### GCC mode with C helper file
```
G c_helpers/helper.c
X 0
```

### Timeout (prevent infinite loops)
```
T 1000
X 0
O Done
```
Exercise must complete within 1000ms or fail.

### Stderr validation
```
X 0
E Error: file not found
```
Validates output written to stderr (fd 2).

## Notes

- One directive per line
- Order doesn't matter (except multiple `A` directives are passed in order)
- `X` defaults to 0 if omitted
- Exercise files use `# I AM NOT DONE` marker for incomplete exercises
- Prediction exercises use `# Prediction: ???` (student replaces `???` with their answer)
