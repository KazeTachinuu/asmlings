#!/bin/bash
# Exercise reordering script for asmlings

EXERCISES_DIR="exercises"
EXPECTED_DIR="expected"
HINTS_DIR="hints"
TMP_DIR="/tmp/asmlings_reorder_$$"

show() {
    echo "=== Current Exercise Order ==="
    for f in $(ls -1 "$EXERCISES_DIR"/*.s 2>/dev/null | sort); do
        num=$(basename "$f" | cut -d_ -f1)
        name=$(basename "$f" .s | cut -d_ -f2-)
        expected=""
        [ -f "$EXPECTED_DIR/$num.txt" ] && expected=$(head -1 "$EXPECTED_DIR/$num.txt")
        printf "%s: %-20s %s\n" "$num" "$name" "$expected"
    done
}

# Apply new order from a file
# File format: one exercise name per line (without number), in desired order
# Example:
#   intro
#   exit_code
#   mov
#   ...
apply_order() {
    local orderfile="$1"

    if [ ! -f "$orderfile" ]; then
        echo "Error: Order file not found: $orderfile"
        exit 1
    fi

    mkdir -p "$TMP_DIR"/{exercises,expected,hints}

    local n=1
    while IFS= read -r name || [ -n "$name" ]; do
        # Skip empty lines and comments
        [[ -z "$name" || "$name" =~ ^# ]] && continue

        local new=$(printf "%02d" $n)

        # Find the current file with this name
        local oldfile=$(ls "$EXERCISES_DIR"/*_${name}.s 2>/dev/null | head -1)

        if [ -z "$oldfile" ]; then
            echo "Warning: Exercise '$name' not found, skipping"
            continue
        fi

        local old=$(basename "$oldfile" | cut -d_ -f1)

        # Copy to temp with new number
        cp "$oldfile" "$TMP_DIR/exercises/${new}_${name}.s"
        [ -f "$EXPECTED_DIR/$old.txt" ] && cp "$EXPECTED_DIR/$old.txt" "$TMP_DIR/expected/$new.txt"
        [ -f "$HINTS_DIR/$old.txt" ] && cp "$HINTS_DIR/$old.txt" "$TMP_DIR/hints/$new.txt"

        echo "$old -> $new: $name"
        n=$((n+1))
    done < "$orderfile"

    # Replace original with reordered
    rm -f "$EXERCISES_DIR"/*.s
    rm -f "$EXPECTED_DIR"/*.txt
    rm -f "$HINTS_DIR"/*.txt

    cp "$TMP_DIR/exercises"/*.s "$EXERCISES_DIR/" 2>/dev/null
    cp "$TMP_DIR/expected"/*.txt "$EXPECTED_DIR/" 2>/dev/null
    cp "$TMP_DIR/hints"/*.txt "$HINTS_DIR/" 2>/dev/null

    # Keep README in expected
    [ -f "/tmp/asmlings_backup/expected/README.md" ] && cp "/tmp/asmlings_backup/expected/README.md" "$EXPECTED_DIR/"

    rm -rf "$TMP_DIR"
    echo "Done! New order applied."
}

# Generate current order file
generate_order() {
    local outfile="${1:-order.txt}"
    for f in $(ls -1 "$EXERCISES_DIR"/*.s 2>/dev/null | sort); do
        basename "$f" .s | cut -d_ -f2-
    done > "$outfile"
    echo "Generated order file: $outfile"
}

case "$1" in
    show)
        show
        ;;
    apply)
        if [ -z "$2" ]; then
            echo "Usage: $0 apply <order-file>"
            echo "Order file format: one exercise name per line (e.g., 'intro', 'exit_code')"
            exit 1
        fi
        apply_order "$2"
        ;;
    generate)
        generate_order "$2"
        ;;
    *)
        echo "Usage: $0 {show|apply <order-file>|generate [output-file]}"
        echo ""
        echo "Commands:"
        echo "  show                Show current exercise order"
        echo "  generate [file]     Generate order file from current order"
        echo "  apply <file>        Apply new order from file"
        echo ""
        echo "To reorder:"
        echo "  1. $0 generate order.txt"
        echo "  2. Edit order.txt (rearrange lines, add new exercise names)"
        echo "  3. $0 apply order.txt"
        ;;
esac
