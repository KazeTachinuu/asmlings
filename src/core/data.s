.section .data

# Command strings
cmd_list_str:       .asciz "list"
cmd_watch_str:      .asciz "watch"
cmd_hint_str:       .asciz "hint"
cmd_run_str:        .asciz "run"
cmd_check_str:      .asciz "check"

# Paths
exercises_dir:      .asciz "exercises"
tmp_exe:            .asciz "/tmp/asmlings_tmp"
hints_dir:          .asciz "hints/"
dev_null:           .asciz "/dev/null"
cmd_bash:           .asciz "/bin/bash"
compile_script:     .asciz "scripts/compile.sh"
list_script:        .asciz "scripts/list_exercises.sh"
gcc_mode_str:       .asciz "gcc"

# Markers we check for
marker_not_done:    .asciz "I AM NOT DONE"
marker_prediction:  .asciz "Prediction:"

# Paths for expected files
expected_dir:       .asciz "expected/"
ext_txt:            .asciz ".txt"

# Terminal control
clear_screen:       .asciz "\033[2J\033[H"

# Colors and styles
color_reset:        .asciz "\033[0m"
color_red:          .asciz "\033[91m"
color_green:        .asciz "\033[92m"
color_yellow:       .asciz "\033[93m"
color_cyan:         .asciz "\033[96m"
style_bold:         .asciz "\033[1m"
style_dim:          .asciz "\033[2m"

# Banner
banner:
    .ascii "\n"
    .ascii "                        | |(_)                   \n"
    .ascii "  __ _  ___  _ __ ___   | | _  _ __    __ _  ___ \n"
    .ascii " / _` |/ __|| '_ ` _ \\  | || || '_ \\  / _` |/ __|\n"
    .ascii "| (_| |\\__ \\| | | | | | | || || | | || (_| |\\__ \\\n"
    .ascii " \\__,_||___/|_| |_| |_| |_||_||_| |_| \\__, ||___/\n"
    .ascii "                                       __/ |     \n"
    .ascii "                                      |___/      \n"
    .ascii "\n"
    .byte 0

# Messages (plain text - colors applied in code)
msg_watching:       .asciz "Watching for changes... (Ctrl+C to quit)\n"
msg_checking:       .asciz "Checking "
msg_passed:         .asciz "✓ Exercise passed!\n"
msg_failed:         .asciz "✗ Compilation failed\n"
msg_wrong_exit:     .asciz "✗ Wrong exit code: got "
msg_wrong_predict:  .asciz "✗ Wrong prediction! Try again.\n"
msg_wrong_output:   .asciz "✗ Wrong output\n"
msg_expected_out:   .asciz "Expected: \""
msg_actual_out:     .asciz "Got:      \""
msg_quote_end:      .asciz "\"\n"
msg_expected:       .asciz ", expected "
msg_not_done:       .asciz "→ Exercise not done yet\n"
msg_next:           .asciz "\nNext exercise: "
msg_complete:       .asciz "\n★ All exercises complete! ★\n\n"
msg_progress:       .asciz "Progress: ["
msg_newline:        .asciz "\n"
msg_bracket_close:  .asciz "] "
msg_slash:          .asciz "/"
msg_pct_close:      .asciz "%)\n"
msg_no_exercises:   .asciz "No exercises found in exercises/\n"
msg_error:          .asciz "Error initializing watcher\n"
msg_hint_for:       .asciz "\nHint for "
msg_hint_end:       .asciz ":\n\n"
msg_no_hint:        .asciz "No hint needed - all exercises complete!\n"
msg_not_found:      .asciz "Exercise not found\n"
msg_remove_marker:  .asciz "Remove '# I AM NOT DONE' when ready.\n"
msg_hint_tip:       .asciz "Run './asmlings hint' for help.\n\n"
msg_running:        .asciz "Running "
msg_exit_code:      .asciz "Exit code: "
msg_run_usage:      .asciz "Usage: ./asmlings run <exercise>\nExample: ./asmlings run 35\n"
msg_check_usage:    .asciz "Usage: ./asmlings check <exercise>\nExample: ./asmlings check 05\n"

# Symbols
symbol_check:       .asciz "✓"

# Progress bar
progress_filled:    .asciz "█"
progress_empty:     .asciz "░"

# File extensions
ext_s:              .asciz ".s"

.align 8
sleeptime:
    .quad 0
    .quad 100000000     # 100ms

.section .bss

.align 8
source_buffer:      .skip SOURCE_BUFFER_SIZE
hint_buffer:        .skip HINT_BUFFER_SIZE
hint_path_buf:      .skip 16

.align 8
exercises:          .skip MAX_EXERCISES * EXERCISE_SIZE
exercise_count:     .skip 8

inotify_fd:         .skip 8
inotify_buffer:     .skip INOTIFY_BUF_SIZE
last_exit_actual:   .skip 8
last_exit_expected: .skip 8

# Output buffers for exercises that print to stdout
expected_output:    .skip 256
actual_output:      .skip 256
expected_out_len:   .skip 8
expected_input:     .skip 256
expected_in_len:    .skip 8
actual_out_len:     .skip 8

# Expected file parsing
expected_buffer:    .skip 4096
expected_path_buf:  .skip 24
test_exit_code:     .skip 4
test_is_predict:    .skip 1
test_predict_ans:   .skip 4

# Command-line arguments for exercises
test_args_buffer:   .skip 1024
test_args_ptrs:     .skip 64
test_args_count:    .skip 4
test_args_buf_ptr:  .skip 8

# Test files (F/C directives)
test_file_path:     .skip 256
test_file_content:  .skip 1024
test_file_len:      .skip 8
test_cleanup_path:  .skip 256
test_has_file:      .skip 1
test_has_cleanup:   .skip 1

# GCC mode (G directive for C interop)
test_use_gcc:       .skip 1
test_c_file:        .skip 256

# Environment pointer (for gcc which needs PATH)
saved_envp:         .skip 8
