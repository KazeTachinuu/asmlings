.section .text
.global _start

_start:
    mov rbp, rsp
    mov rdi, [rsp]          # argc
    lea rsi, [rsp + 8]      # argv

    cmp rdi, 1
    jle .do_watch

    mov r12, [rsi + 8]      # argv[1]

    lea rdi, [rip + cmd_list_str]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_list

    lea rdi, [rip + cmd_watch_str]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_watch

    lea rdi, [rip + cmd_hint_str]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_hint

    lea rdi, [rip + cmd_help_str]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_help

    lea rdi, [rip + cmd_help_short]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_help

    lea rdi, [rip + cmd_help_long]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_help

    jmp .do_help

.do_list:
    call cmd_list
    jmp .exit_success

.do_watch:
    call cmd_watch
    jmp .exit_success

.do_hint:
    mov rdi, [rbp]          # argc
    lea rsi, [rbp + 8]      # argv
    call cmd_hint
    jmp .exit_success

.do_help:
    call cmd_help
    jmp .exit_success

.exit_success:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
