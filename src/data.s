.section .data

# Paths
exercises_dir:      .asciz "exercises"
tmp_obj:            .asciz "/tmp/asmlings_tmp.o"
tmp_exe:            .asciz "/tmp/asmlings_tmp"
hints_dir:          .asciz "hints/"
cmd_as:             .asciz "/usr/bin/as"
cmd_ld:             .asciz "/usr/bin/ld"
as_arg0:            .asciz "as"
as_arg1:            .asciz "--64"
as_arg2:            .asciz "-o"
ld_arg0:            .asciz "ld"
ld_arg2:            .asciz "-o"

# The only marker we check for
marker_not_done:    .asciz "I AM NOT DONE"

# Terminal control
clear_screen:       .asciz "\033[2J\033[H"

# Colors (only used ones)
color_reset:        .asciz "\033[0m"
color_green:        .asciz "\033[92m"
color_yellow:       .asciz "\033[93m"

# Banner
banner:
    .ascii "\n\033[96m\033[1m"
    .ascii "                        | |(_)                   \n"
    .ascii "  __ _  ___  _ __ ___   | | _  _ __    __ _  ___ \n"
    .ascii " / _` |/ __|| '_ ` _ \\  | || || '_ \\  / _` |/ __|\n"
    .ascii "| (_| |\\__ \\| | | | | | | || || | | || (_| |\\__ \\\n"
    .ascii " \\__,_||___/|_| |_| |_| |_||_||_| |_| \\__, ||___/\n"
    .ascii "                                       __/ |     \n"
    .ascii "                                      |___/      \n"
    .ascii "\033[0m\n"
    .byte 0

# Messages
msg_watching:       .asciz "\033[2mWatching for changes... (Ctrl+C to quit)\033[0m\n"
msg_checking:       .asciz "Checking \033[1m"
msg_passed:         .asciz "\033[92m✓ Exercise passed!\033[0m\n"
msg_failed:         .asciz "\033[91m✗ Compilation failed\033[0m\n"
msg_wrong_exit:     .asciz "\033[91m✗ Wrong exit code: got "
msg_expected:       .asciz ", expected "
msg_not_done:       .asciz "\033[93m→ Exercise not done yet\033[0m\n"
msg_next:           .asciz "\n\033[96mNext exercise: \033[1m"
msg_complete:       .asciz "\n\033[92m\033[1m★ All exercises complete! ★\033[0m\n\n"
msg_progress:       .asciz "Progress: ["
msg_newline:        .asciz "\n"
msg_bracket_close:  .asciz "] "
msg_slash:          .asciz "/"
msg_pct_close:      .asciz "%)\n"
msg_no_exercises:   .asciz "\033[91mNo exercises found in exercises/\033[0m\n"
msg_error:          .asciz "\033[91mError initializing watcher\033[0m\n"
msg_hint_for:       .asciz "\n\033[93mHint for \033[1m"
msg_hint_end:       .asciz "\033[0m:\n\n"
msg_no_hint:        .asciz "\033[92mNo hint needed - all exercises complete!\033[0m\n"
msg_not_found:      .asciz "\033[91mExercise not found\033[0m\n"
msg_remove_marker:  .asciz "\033[2mRemove '# I AM NOT DONE' when ready.\033[0m\n"
msg_hint_tip:       .asciz "\033[2mRun './asmlings hint' for help.\033[0m\n\n"

# Symbols
symbol_check:       .asciz "✓"

# Progress bar
progress_filled:    .asciz "\033[92m█\033[0m"
progress_empty:     .asciz "\033[2m░\033[0m"

# File extensions
ext_s:              .asciz ".s"

.align 8
sleeptime:
    .quad 0
    .quad 100000000     # 100ms

.section .bss

.align 8
dirent_buffer:      .skip DIRENT_BUFFER_SIZE
source_buffer:      .skip SOURCE_BUFFER_SIZE
hint_buffer:        .skip HINT_BUFFER_SIZE
hint_path_buf:      .skip 16

.align 8
exercises:          .skip MAX_EXERCISES * EXERCISE_SIZE
exercise_count:     .skip 8
current_exercise:   .skip 8

inotify_fd:         .skip 8
inotify_buffer:     .skip INOTIFY_BUF_SIZE
last_exit_actual:   .skip 8
last_exit_expected: .skip 8
