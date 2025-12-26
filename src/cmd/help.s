.section .text

# Help command
cmd_help:
    push rbx

    # Title
    lea rdi, [rip + color_cyan]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_title]
    call print_str
    call print_reset
    lea rdi, [rip + help_subtitle]
    call print_str

    # Usage section
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_usage_hdr]
    call print_str
    call print_reset
    lea rdi, [rip + help_usage]
    call print_str

    # Commands section
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_cmds_hdr]
    call print_str
    call print_reset
    lea rdi, [rip + help_cmds]
    call print_str

    # Getting started section
    lea rdi, [rip + style_bold]
    call print_str
    lea rdi, [rip + help_start_hdr]
    call print_str
    call print_reset
    lea rdi, [rip + help_start]
    call print_str

    pop rbx
    ret

.section .data
help_title:     .asciz "asmlings"
help_subtitle:  .asciz " - Learn x86-64 assembly by fixing exercises\n\n"
help_usage_hdr: .asciz "USAGE:\n"
help_usage:     .asciz "    ./asmlings [COMMAND]\n\n"
help_cmds_hdr:  .asciz "COMMANDS:\n"
help_cmds:
    .ascii "    watch      Watch for changes and check exercises (default)\n"
    .ascii "    run N      Run exercise N with stdin passthrough (e.g. run 35)\n"
    .ascii "    check N    Check status of exercise N (e.g. check 05)\n"
    .ascii "    list       Show all exercises with status\n"
    .ascii "    hint [N]   Show hint for current or exercise N (e.g. hint 05)\n"
    .ascii "    help       Show this help message\n\n"
    .byte 0
help_start_hdr: .asciz "GETTING STARTED:\n"
help_start:
    .ascii "    1. Run ./asmlings watch\n"
    .ascii "    2. Open exercises/01_intro.s in your editor\n"
    .ascii "    3. Read the instructions and fix the code\n"
    .ascii "    4. Remove '# I AM NOT DONE' when ready\n"
    .ascii "    5. Save - asmlings will check your solution!\n\n"
    .byte 0
