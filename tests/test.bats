#!/usr/bin/env bats
# asmlings test suite

load helpers

# ═══════════════════════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════════════════════

@test "cli: binary exists" {
    [[ -x ./asmlings ]]
}

@test "cli: help command" {
    run ./asmlings help
    [[ "$status" -eq 0 ]]
    assert_contains "$output" "USAGE"
    assert_contains "$output" "watch"
    assert_contains "$output" "list"
    assert_contains "$output" "hint"
    assert_contains "$output" "run"
}

@test "cli: -h flag" {
    run ./asmlings -h
    [[ "$status" -eq 0 ]]
    assert_contains "$output" "USAGE"
}

@test "cli: --help flag" {
    run ./asmlings --help
    [[ "$status" -eq 0 ]]
    assert_contains "$output" "USAGE"
}

@test "cli: unknown command shows help" {
    run ./asmlings invalid_command
    assert_contains "$output" "USAGE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# LIST COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "list: finds exercises" {
    test_setup
    exercise "01_a.s" "exit0.s"
    exercise "02_b.s" "exit0.s"

    out=$(asmlings list)
    assert_contains "$out" "01_a"
    assert_contains "$out" "02_b"
    assert_contains "$out" "0/2"

    test_cleanup
}

@test "list: sorts by filename" {
    test_setup
    exercise "03_c.s" "exit0.s"
    exercise "01_a.s" "exit0.s"
    exercise "02_b.s" "exit0.s"

    out=$(asmlings list)
    # Verify order: 01 appears before 02, 02 before 03
    [[ "$out" == *01_a*02_b*03_c* ]]

    test_cleanup
}

@test "list: ignores non-.s files" {
    test_setup
    exercise "01_test.s" "exit0.s"
    echo "not an exercise" > "$TESTDIR/exercises/readme.txt"

    out=$(asmlings list)
    assert_not_contains "$out" "readme"
    assert_contains "$out" "01_test"

    test_cleanup
}

@test "list: shows progress" {
    test_setup
    exercise "01_done.s" "exit0.s" 0 0
    exercise "02_todo.s" "exit0.s" 1 0

    out=$(asmlings list)
    assert_contains "$out" "1/2"
    assert_contains "$out" "50%"

    test_cleanup
}

@test "list: marks incomplete with >" {
    test_setup
    exercise "01_todo.s" "exit0.s" 1 0

    out=$(asmlings list)
    assert_contains "$out" ">"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# EXERCISE VALIDATION
# ═══════════════════════════════════════════════════════════════════════════════

@test "validation: marker blocks pass" {
    test_setup
    exercise "01_test.s" "exit0.s" 1 0

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "validation: no marker allows pass" {
    test_setup
    exercise "01_test.s" "exit0.s" 0 0

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "validation: compile error fails" {
    test_setup
    exercise "01_bad.s" "invalid.s" 0 0

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "validation: wrong exit code fails" {
    test_setup
    exercise "01_test.s" "exit42.s" 0 0  # expects 0, gets 42

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "validation: correct exit code passes" {
    test_setup
    exercise "01_test.s" "exit42.s" 0 42  # expects 42, gets 42

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "validation: correct output passes" {
    test_setup
    exercise_output "01_test.s" "print_hi.s" "Hi"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "validation: wrong output fails" {
    test_setup
    exercise_output "01_test.s" "print_yo.s" "Hi"  # expects Hi, prints Yo

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "validation: predict ??? not done" {
    test_setup
    exercise_predict "01_test.s" "exit42.s" "???"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "validation: predict correct passes" {
    test_setup
    exercise_predict "01_test.s" "exit42.s" "42"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# HINT COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "hint: shows current exercise hint" {
    test_setup
    exercise "01_test.s" "exit0.s"
    hint "01" "This is a hint"

    out=$(asmlings hint)
    assert_contains "$out" "This is a hint"

    test_cleanup
}

@test "hint: shows specific exercise hint" {
    test_setup
    exercise "01_a.s" "exit0.s"
    exercise "02_b.s" "exit0.s"
    hint "01" "Hint for 01"
    hint "02" "Hint for 02"

    out=$(asmlings hint 02)
    assert_contains "$out" "Hint for 02"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# WATCH COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "watch: shows complete when all done" {
    test_setup
    exercise "01_test.s" "exit0.s" 0 0

    out=$(asmlings watch)
    assert_contains "$out" "complete"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# RUN COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "run: shows usage without args" {
    run ./asmlings run
    assert_contains "$output" "Usage"
}

@test "run: executes and shows exit code" {
    test_setup
    exercise "01_test.s" "exit42.s" 0 42

    out=$(asmlings run 01)
    assert_contains "$out" "Exit code: 42"

    test_cleanup
}

@test "run: passes stdin to exercise" {
    test_setup
    exercise "01_read.s" "read_stdin.s" 0 0

    # echo "hello" = 6 bytes (5 + newline)
    out=$(cd "$TESTDIR" && echo "hello" | timeout 2 ./asmlings run 01 2>&1)
    assert_contains "$out" "Exit code: 6"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# STDIN ISOLATION
# ═══════════════════════════════════════════════════════════════════════════════

@test "stdin: list does not hang on stdin-reading exercise" {
    test_setup
    exercise "01_read.s" "read_stdin.s" 0 0

    # Should complete quickly, not hang waiting for stdin
    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "stdin: watch does not hang on stdin-reading exercise" {
    test_setup
    exercise "01_read.s" "read_stdin.s" 0 0

    # Should complete quickly, not hang waiting for stdin
    out=$(asmlings watch)
    assert_contains "$out" "complete"

    test_cleanup
}
