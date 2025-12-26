# Expected Files Format

Each exercise has a corresponding `XX.txt` file that defines validation rules.

## Directive Codes

| Code | Purpose | Format |
|------|---------|--------|
| `#` | Comment | `# comment text` |
| `X` | Expected exit code | `X 42` |
| `P` | Prediction answer | `P 67` |
| `I` | Stdin input | `I Hello, World!` |
| `O` | Expected stdout | `O Hello, World!` |
| `A` | Command-line arg | `A argvalue` |
| `F` | Create test file | `F filename:content` |
| `C` | Cleanup file | `C filename` |

## Escape Sequences

For I, O, and F directives:
- `\n` = newline
- `\\` = literal backslash

## Examples

### Simple exit code
```
X 42
```

### Prediction exercise
```
P 67
```

### Input/output (cat-like)
```
X 0
I Hello, World!
O Hello, World!
```

### With arguments
```
X 0
A hello
A world
O hello world
```

### With test file
```
X 0
F input.txt:file content here
A input.txt
O file content here
C input.txt
```

### Multiline content
```
X 0
F data.txt:Line1\nLine2\nLine3
O Line1\nLine2\nLine3
```

## Notes

- One directive per line
- Order doesn't matter (except multiple A directives are passed in order)
- Exercise files use `# I AM NOT DONE` marker for incomplete exercises
- Prediction exercises use `# Prediction: ???` in the exercise file (student fills in the number)
