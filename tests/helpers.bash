# BATS test helpers for asmlings

FIXTURES="${BATS_TEST_DIRNAME}/fixtures"
TESTDIR="/tmp/asmlings_test_$$"

# Setup test environment
test_setup() {
    rm -rf "$TESTDIR"
    mkdir -p "$TESTDIR/exercises" "$TESTDIR/hints" "$TESTDIR/expected" "$TESTDIR/scripts"
    cp ./asmlings "$TESTDIR/"
    cp ./scripts/*.sh "$TESTDIR/scripts/"
}

# Cleanup test environment
test_cleanup() {
    rm -rf "$TESTDIR"
}

# Run asmlings in test directory (stdin from /dev/null)
asmlings() {
    (cd "$TESTDIR" && timeout 2 ./asmlings "$@" 2>&1) </dev/null
}

# Load a test case from fixtures
# Usage: load_fixture EXERCISE_FIXTURE EXPECTED_FIXTURE [EXERCISE_NUM]
# Example: load_fixture exit0 exit0 01
load_fixture() {
    local exercise="$1"
    local expected="$2"
    local num="${3:-01}"

    cp "$FIXTURES/exercises/${exercise}.s" "$TESTDIR/exercises/${num}_test.s"
    cp "$FIXTURES/expected/${expected}.txt" "$TESTDIR/expected/${num}.txt"
}

# Load exercise with custom expected file content
# Usage: load_exercise EXERCISE_FIXTURE EXPECTED_CONTENT [EXERCISE_NUM]
load_exercise() {
    local exercise="$1"
    local expected_content="$2"
    local num="${3:-01}"

    cp "$FIXTURES/exercises/${exercise}.s" "$TESTDIR/exercises/${num}_test.s"
    echo -e "$expected_content" > "$TESTDIR/expected/${num}.txt"
}

# Load multiple fixtures for multi-exercise tests
# Usage: load_fixtures "exit0:exit0:01" "exit42:exit42:02"
load_fixtures() {
    for spec in "$@"; do
        IFS=':' read -r exercise expected num <<< "$spec"
        load_fixture "$exercise" "$expected" "$num"
    done
}

# Add marker to exercise file
add_marker() {
    local num="${1:-01}"
    local file="$TESTDIR/exercises/${num}_test.s"
    local tmp=$(mktemp)
    echo "# I AM NOT DONE" > "$tmp"
    cat "$file" >> "$tmp"
    mv "$tmp" "$file"
}

# Set prediction in exercise file
set_prediction() {
    local value="$1"
    local num="${2:-01}"
    sed -i "s/Prediction: ???/Prediction: $value/" "$TESTDIR/exercises/${num}_test.s"
}

# Create hint file
hint() {
    local num="$1"
    local content="$2"
    echo "$content" > "$TESTDIR/hints/${num}.txt"
}

# Assert output contains string
assert_contains() {
    [[ "$1" == *"$2"* ]] || {
        echo "Expected output to contain '$2'" >&2
        echo "Got: $1" >&2
        return 1
    }
}

# Assert output does not contain string
assert_not_contains() {
    [[ "$1" != *"$2"* ]] || {
        echo "Expected output to NOT contain '$2'" >&2
        return 1
    }
}

# Assert file exists
assert_file_exists() {
    [[ -f "$1" ]] || {
        echo "Expected file to exist: $1" >&2
        return 1
    }
}

# Assert file does not exist
assert_file_not_exists() {
    [[ ! -f "$1" ]] || {
        echo "Expected file to NOT exist: $1" >&2
        return 1
    }
}
