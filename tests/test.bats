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
    load_fixtures "exit0:exit0:01" "exit0:exit0:02"
    add_marker 01
    add_marker 02

    out=$(asmlings list)
    assert_contains "$out" "01_test"
    assert_contains "$out" "02_test"
    assert_contains "$out" "0/2"

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
    assert_contains "$out" "01_test"

    test_cleanup
}

@test "list: shows progress" {
    test_setup
    load_fixture exit0 exit0 01
    load_fixture exit0 exit0 02
    add_marker 02

    out=$(asmlings list)
    assert_contains "$out" "1/2"
    assert_contains "$out" "50%"

    test_cleanup
}

@test "list: marks incomplete with >" {
    test_setup
    load_fixture exit0 exit0 01
    add_marker 01

    out=$(asmlings list)
    assert_contains "$out" ">"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# X DIRECTIVE - EXIT CODE
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
    load_fixture exit42 wrong_exit  # expects 99, gets 42

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

@test "X: compile error fails" {
    test_setup
    load_fixture invalid exit0

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# O DIRECTIVE - OUTPUT
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
    load_fixture print_yo wrong_output  # expects "Hi", gets "Yo"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "O: exact match required" {
    test_setup
    load_exercise print_hi "X 0\nO Hi!"  # expects "Hi!" but prints "Hi"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "O: wrong output content fails" {
    test_setup
    load_fixture print_yo print_hi  # prints "Yo" but expects "Hi"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "O: multiline output matches" {
    test_setup
    load_fixture print_multiline print_multiline  # prints "A\nB\nC"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# I DIRECTIVE - INPUT
# ═══════════════════════════════════════════════════════════════════════════════

@test "I: stdin piped to exercise" {
    test_setup
    load_fixture echo_stdin echo_stdin

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "I: exact input content piped" {
    test_setup
    load_fixture echo_stdin echo_hello

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "I: no stdin doesn't hang" {
    test_setup
    load_fixture read_stdin read_stdin

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "I: wrong stdin content fails" {
    test_setup
    load_fixture echo_stdin wrong_stdin  # pipes "WrongInput" but expects output "TestInput"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "I: multiline stdin piped correctly" {
    test_setup
    load_fixture echo_stdin multiline_io  # pipes and expects "Line1\nLine2\nLine3"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# A DIRECTIVE - ARGUMENTS
# ═══════════════════════════════════════════════════════════════════════════════

@test "A: argument passed to exercise" {
    test_setup
    load_fixture print_arg print_arg

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "A: multiple arguments passed" {
    test_setup
    load_fixture print_argc argc_3args

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "A: exact argument value" {
    test_setup
    load_exercise print_arg "X 0\nA SpecificValue\nO SpecificValue"

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "A: wrong argument fails" {
    test_setup
    load_fixture print_arg wrong_arg  # passes "WrongArg" but expects output "TestArg"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# P DIRECTIVE - PREDICTION
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

@test "P: checks prediction not execution" {
    test_setup
    # predict42.s exits with 99, but answer is 42
    load_fixture predict42 predict42
    set_prediction 42

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# F/C DIRECTIVES - FILE CREATION/CLEANUP
# ═══════════════════════════════════════════════════════════════════════════════

@test "F: creates file with content" {
    test_setup
    load_fixture read_file read_file

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "F: exact file content" {
    test_setup
    load_fixture read_file read_specific

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "F: wrong file content fails" {
    test_setup
    load_fixture read_file wrong_file_content  # creates "WrongContent" but expects output "FileContent"

    out=$(asmlings list)
    assert_contains "$out" "0/1"

    test_cleanup
}

@test "F: file created with exact content" {
    test_setup
    load_fixture read_file file_no_cleanup

    asmlings list > /dev/null
    assert_file_exists "$TESTDIR/testfile.txt"
    content=$(cat "$TESTDIR/testfile.txt")
    [[ "$content" == "ExactContent123" ]] || {
        echo "Expected file content 'ExactContent123', got '$content'" >&2
        return 1
    }

    test_cleanup
}

@test "F: multiline file content" {
    test_setup
    load_fixture read_file multiline_file

    out=$(asmlings list)
    assert_contains "$out" "1/1"

    test_cleanup
}

@test "F: multiline file has correct content" {
    test_setup
    load_fixture read_file file_no_cleanup
    # Modify the expected to have multiline content
    echo -e "X 0\nF multi.txt:Line1\\\nLine2\\\nLine3\nA multi.txt\nO Line1\\\nLine2\\\nLine3" > "$TESTDIR/expected/01.txt"

    asmlings list > /dev/null
    assert_file_exists "$TESTDIR/multi.txt"
    # Verify exact multiline content
    expected=$'Line1\nLine2\nLine3'
    content=$(cat "$TESTDIR/multi.txt")
    [[ "$content" == "$expected" ]] || {
        echo "Expected content: '$expected'" >&2
        echo "Got content: '$content'" >&2
        return 1
    }

    test_cleanup
}

@test "C: cleans up file after run" {
    test_setup
    load_fixture read_file read_file

    asmlings list > /dev/null
    assert_file_not_exists "$TESTDIR/test.txt"

    test_cleanup
}

# ═══════════════════════════════════════════════════════════════════════════════
# HINT COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "hint: shows current exercise hint" {
    test_setup
    load_fixture exit0 exit0
    add_marker
    hint 01 "This is a hint"

    out=$(asmlings hint)
    assert_contains "$out" "This is a hint"

    test_cleanup
}

@test "hint: shows specific exercise hint" {
    test_setup
    load_fixtures "exit0:exit0:01" "exit0:exit0:02"
    add_marker 01
    add_marker 02
    hint 01 "Hint for 01"
    hint 02 "Hint for 02"

    out=$(asmlings hint 02)
    assert_contains "$out" "Hint for 02"

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

# ═══════════════════════════════════════════════════════════════════════════════
# RUN COMMAND
# ═══════════════════════════════════════════════════════════════════════════════

@test "run: shows usage without args" {
    run ./asmlings run
    assert_contains "$output" "Usage"
}

@test "run: shows error on compile failure" {
    test_setup
    load_fixture invalid exit0

    out=$(asmlings run 01)
    assert_contains "$out" "failed"

    test_cleanup
}

@test "run: executes and shows exit code" {
    test_setup
    load_fixture exit42 exit42

    out=$(asmlings run 01)
    assert_contains "$out" "Exit code: 42"

    test_cleanup
}

@test "run: passes stdin to exercise" {
    test_setup
    load_fixture read_stdin read_stdin

    # echo "hello" = 6 bytes (5 + newline)
    out=$(cd "$TESTDIR" && echo "hello" | timeout 2 ./asmlings run 01 2>&1)
    assert_contains "$out" "Exit code: 6"

    test_cleanup
}
