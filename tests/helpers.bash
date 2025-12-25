# BATS test helpers for asmlings

FIXTURES="${BATS_TEST_DIRNAME}/fixtures"
TESTDIR="/tmp/asmlings_test_$$"

# Setup test environment
test_setup() {
    rm -rf "$TESTDIR"
    mkdir -p "$TESTDIR/exercises" "$TESTDIR/hints"
    cp ./asmlings "$TESTDIR/"
}

# Cleanup test environment
test_cleanup() {
    rm -rf "$TESTDIR"
}

# Run asmlings in test directory (stdin from /dev/null)
asmlings() {
    (cd "$TESTDIR" && timeout 2 ./asmlings "$@" 2>&1) </dev/null
}

# Create exercise from fixture
# Usage: exercise NAME FIXTURE [MARKER] [EXIT_CODE]
exercise() {
    local name="$1" fixture="$2" marker="${3:-1}" exit_code="${4:-0}"
    local dest="$TESTDIR/exercises/$name"

    : > "$dest"
    [[ "$marker" == 1 ]] && echo "# I AM NOT DONE" >> "$dest"
    echo "# Expected exit code: $exit_code" >> "$dest"
    cat "$FIXTURES/$fixture" >> "$dest"
}

# Create exercise with expected output
# Usage: exercise_output NAME FIXTURE EXPECTED_OUTPUT
exercise_output() {
    local name="$1" fixture="$2" expected="$3"
    local dest="$TESTDIR/exercises/$name"

    echo "# Expected output: \"$expected\"" > "$dest"
    echo "# Expected exit code: 0" >> "$dest"
    cat "$FIXTURES/$fixture" >> "$dest"
}

# Create predict exercise (with ??? or specific value)
# Usage: exercise_predict NAME FIXTURE PREDICTION
exercise_predict() {
    local name="$1" fixture="$2" prediction="$3"
    local dest="$TESTDIR/exercises/$name"

    echo "# Expected exit code: $prediction" > "$dest"
    cat "$FIXTURES/$fixture" >> "$dest"
}

# Create hint file
hint() {
    echo "$2" > "$TESTDIR/hints/$1.txt"
}

# Assert output contains string
assert_contains() {
    [[ "$1" == *"$2"* ]] || {
        echo "Expected '$1' to contain '$2'" >&2
        return 1
    }
}

# Assert output does not contain string
assert_not_contains() {
    [[ "$1" != *"$2"* ]] || {
        echo "Expected '$1' to NOT contain '$2'" >&2
        return 1
    }
}
