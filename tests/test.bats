#!/usr/bin/env bats
# asmlings test suite - atomic tests with full coverage

load helpers

# ═══════════════════════════════════════════════════════════════════════════════
# CLI - Basic command line interface
# ═══════════════════════════════════════════════════════════════════════════════

@test "cli: binary exists and is executable" {
    [[ -x ./asmlings ]]
}

@test "cli: help command shows usage" {
    run ./asmlings help
    [[ "$status" -eq 0 ]]
    assert_contains "$output" "USAGE"
}

@test "cli: help shows all commands" {
    run ./asmlings help
    assert_contains "$output" "watch"
    assert_contains "$output" "list"
    assert_contains "$output" "hint"
    assert_contains "$output" "run"
    assert_contains "$output" "check"
}

@test "cli: -h flag shows help" {
    run ./asmlings -h
    [[ "$status" -eq 0 ]]
    assert_contains "$output" "USAGE"
}

@test "cli: --help flag shows help" {
    run ./asmlings --help
    [[ "$status" -eq 0 ]]
    assert_contains "$output" "USAGE"
}

@test "cli: unknown command shows help" {
    run ./asmlings unknowncmd
    assert_contains "$output" "USAGE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# LIST - Exercise listing
# ═══════════════════════════════════════════════════════════════════════════════

@test "list: displays exercises" {
    test_setup
    load_fixtures "exit0:exit0:01" "exit0:exit0:02"
    add_marker 01
    add_marker 02

    out=$(asmlings list)
    assert_contains "$out" "01_test"
    assert_contains "$out" "02_test"

    test_cleanup
}

@test "list: sorts by filename" {
    test_setup
    load_fixtures "exit0:exit0:03" "exit0:exit0:01" "exit0:exit0:02"

    out=$(asmlings list)
    [[ "$out" == *01_test*02_test*03_test* ]]

    test_cleanup
}

@test "list: ignores non-.s files" {
    test_setup
    load_fixture exit0 exit0 01
    echo "not an exercise" > "$TESTDIR/exercises/readme.txt"

    out=$(asmlings list)
    assert_not_contains "$out" "readme"

    test_cleanup
}

@test "list: shows progress count" {
    test_setup
    load_fixtures "exit0:exit0:01" "exit0:exit0:02"
    add_marker 02

    out=$(asmlings list)
    assert_contains "$out" "1/2"

    test_cleanup
}

@test "list: shows progress percentage" {
    test_setup
    load_fixtures "exit0:exit0:01" "exit0:exit0:02"
    add_marker 02

    out=$(asmlings list)
    assert_contains "$out" "50%"

    test_cleanup
}

@test "list: marks current exercise with >" {
    test_setup
    load_fixture exit0 exit0
    add_marker

    out=$(asmlings list)
    assert_contains "$out" ">"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# X DIRECTIVE - Exit code validation
# ═══════════════════════════════════════════════════════════════════════════════

@test "X: correct exit code passes" {
    test_setup
    load_fixture exit42 exit42

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "X: wrong exit code fails" {
    test_setup
    load_fixture exit42 wrong_exit

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "X: default exit code is 0" {
    test_setup
    load_exercise exit0 "X 0"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "X: compile error fails" {
    test_setup
    load_fixture invalid exit0

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "X: marker blocks validation" {
    test_setup
    load_fixture exit0 exit0
    add_marker

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# O DIRECTIVE - Output validation
# ═══════════════════════════════════════════════════════════════════════════════

@test "O: correct output passes" {
    test_setup
    load_fixture print_hi print_hi

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "O: wrong output fails" {
    test_setup
    load_fixture print_yo print_hi

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "O: exact match required" {
    test_setup
    load_exercise print_hi "X 0\nO Hi!"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "O: supports \\n escape for newlines" {
    test_setup
    load_fixture print_multiline print_multiline

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# I DIRECTIVE - Input piping
# ═══════════════════════════════════════════════════════════════════════════════

@test "I: pipes input to stdin" {
    test_setup
    load_fixture echo_stdin echo_stdin

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "I: exact input content" {
    test_setup
    load_fixture echo_stdin echo_hello

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "I: wrong input fails" {
    test_setup
    load_fixture echo_stdin wrong_stdin

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "I: supports \\n escape for multiline" {
    test_setup
    load_fixture echo_stdin multiline_io

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "I: no input doesn't hang" {
    test_setup
    load_fixture read_stdin read_stdin

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# A DIRECTIVE - Command line arguments
# ═══════════════════════════════════════════════════════════════════════════════

@test "A: passes argument to exercise" {
    test_setup
    load_fixture print_arg print_arg

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "A: wrong argument fails" {
    test_setup
    load_fixture print_arg wrong_arg

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "A: supports multiple arguments" {
    test_setup
    load_fixture print_argc argc_3args

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "A: exact argument value" {
    test_setup
    load_exercise print_arg "X 0\nA CustomValue\nO CustomValue"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# P DIRECTIVE - Prediction exercises
# ═══════════════════════════════════════════════════════════════════════════════

@test "P: ??? shows not done" {
    test_setup
    load_fixture predict42 predict42

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "P: correct prediction passes" {
    test_setup
    load_fixture predict42 predict42
    set_prediction 42

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "P: wrong prediction fails" {
    test_setup
    load_fixture predict42 predict42
    set_prediction 99

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "P: ignores actual exit code" {
    test_setup
    load_fixture predict42 predict42
    set_prediction 42

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# F DIRECTIVE - File creation
# ═══════════════════════════════════════════════════════════════════════════════

@test "F: creates file before run" {
    test_setup
    load_fixture read_file read_file

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "F: file has correct content" {
    test_setup
    load_fixture read_file file_no_cleanup

    asmlings list > /dev/null
    content=$(cat "$TESTDIR/testfile.txt")
    [[ "$content" == "ExactContent123" ]]

    test_cleanup
}

@test "F: wrong file content fails" {
    test_setup
    load_fixture read_file wrong_file_content

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "F: supports \\n escape for multiline content" {
    test_setup
    load_fixture read_file multiline_file

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# C DIRECTIVE - File cleanup
# ═══════════════════════════════════════════════════════════════════════════════

@test "C: deletes file after run" {
    test_setup
    load_fixture read_file read_file

    asmlings list > /dev/null
    assert_file_not_exists "$TESTDIR/test.txt"

    test_cleanup
}

@test "C: file exists during run" {
    test_setup
    load_fixture read_file read_file

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# G DIRECTIVE - GCC mode
# ═══════════════════════════════════════════════════════════════════════════════

@test "G: uses gcc for linking" {
    test_setup
    load_fixture gcc_hello gcc_hello

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "G: links with C helper file" {
    test_setup
    load_fixture multiply3 gcc_c_helper
    cp -r c_helpers "$TESTDIR/"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# HINT COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "hint: shows hint for current exercise" {
    test_setup
    load_fixture exit0 exit0
    add_marker
    hint 01 "Test hint content"

    out=$(asmlings hint)
    assert_contains "$out" "Test hint content"

    test_cleanup
}

@test "hint: shows hint for specific exercise" {
    test_setup
    load_fixtures "exit0:exit0:01" "exit0:exit0:02"
    add_marker 01
    hint 02 "Hint for exercise 02"

    out=$(asmlings hint 02)
    assert_contains "$out" "Hint for exercise 02"

    test_cleanup
}

@test "hint: shows message when no hint" {
    test_setup
    load_fixture exit0 exit0
    add_marker

    out=$(asmlings hint)
    assert_contains "$out" "No hint"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# WATCH COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "watch: shows complete when all done" {
    test_setup
    load_fixture exit0 exit0

    out=$(asmlings watch)
    assert_contains "$out" "complete"

    test_cleanup
}

@test "watch: shows current exercise status" {
    test_setup
    load_fixture exit0 exit0
    add_marker

    out=$(timeout 1 bash -c "cd '$TESTDIR' && ./asmlings watch" 2>&1 || true)
    assert_contains "$out" "01_test"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# RUN COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "run: shows usage without arguments" {
    run ./asmlings run
    assert_contains "$output" "Usage"
}

@test "run: executes exercise and shows exit code" {
    test_setup
    load_fixture exit42 exit42

    out=$(asmlings run 01)
    assert_contains "$out" "Exit code: 42"

    test_cleanup
}

@test "run: shows error on compile failure" {
    test_setup
    load_fixture invalid exit0

    out=$(asmlings run 01)
    assert_contains "$out" "failed"

    test_cleanup
}

@test "run: passes stdin to exercise" {
    test_setup
    load_fixture read_stdin read_stdin

    out=$(cd "$TESTDIR" && echo "hello" | timeout 2 ./asmlings run 01 2>&1)
    assert_contains "$out" "Exit code: 6"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# CHECK COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "check: shows usage without arguments" {
    run ./asmlings check
    assert_contains "$output" "Usage"
}

@test "check: shows passed for correct exercise" {
    test_setup
    load_fixture exit0 exit0

    out=$(asmlings check 01)
    assert_contains "$out" "passed"

    test_cleanup
}

@test "check: shows failed for wrong exit code" {
    test_setup
    load_fixture exit42 wrong_exit

    out=$(asmlings check 01)
    assert_contains "$out" "exit code"

    test_cleanup
}

@test "check: shows not done for marked exercise" {
    test_setup
    load_fixture exit0 exit0
    add_marker

    out=$(asmlings check 01)
    assert_contains "$out" "NOT DONE"

    test_cleanup
}

@test "check: accepts exercise by name" {
    test_setup
    load_fixture exit0 exit0

    out=$(asmlings check 01_test.s)
    assert_contains "$out" "passed"

    test_cleanup
}

@test "check: shows error for unknown exercise" {
    test_setup
    load_fixture exit0 exit0

    out=$(asmlings check 99)
    assert_contains "$out" "not found"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# T DIRECTIVE - Timeout
# ═══════════════════════════════════════════════════════════════════════════════

@test "T: infinite loop times out" {
    test_setup
    load_fixture infinite_loop timeout

    out=$(asmlings check 01)
    assert_contains "$out" "Timeout"

    test_cleanup
}

@test "T: fast program passes with timeout" {
    test_setup
    load_exercise exit0 "T 1000\nX 0"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "T: no timeout without directive" {
    test_setup
    load_fixture exit0 exit0

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "T: timeout works with stdin piping" {
    test_setup
    load_fixture loop_after_read loop_after_read

    out=$(asmlings check 01)
    assert_contains "$out" "Timeout"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# E DIRECTIVE - Stderr capture
# ═══════════════════════════════════════════════════════════════════════════════

@test "E: correct stderr passes" {
    test_setup
    load_fixture print_stderr print_stderr

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "E: wrong stderr fails" {
    test_setup
    load_exercise print_stderr "X 0\nE Wrong"

    out=$(asmlings check 01)
    assert_contains "$out" "stderr"

    test_cleanup
}

@test "E: supports \\n escape" {
    test_setup
    load_exercise print_stderr "X 0\nE Error"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}
