.section .text
.global _start

_start:
    mov rbp, rsp
    mov rdi, [rsp]          # argc
    lea rsi, [rsp + 8]      # argv

    # Save envp (after argv NULL terminator)
    # envp = argv + (argc+1)*8
    mov rax, rdi
    inc rax
    lea rax, [rsi + rax*8]
    mov [rip + saved_envp], rax

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

    lea rdi, [rip + cmd_run_str]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_run

    lea rdi, [rip + cmd_check_str]
    mov rsi, r12
    call str_equals
    test al, al
    jnz .do_check

    # Unknown command - show help
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

.do_run:
    mov rdi, [rbp]          # argc
    lea rsi, [rbp + 8]      # argv
    call cmd_run
    jmp .exit_success

.do_check:
    mov rdi, [rbp]          # argc
    lea rsi, [rbp + 8]      # argv
    call cmd_check
    jmp .exit_success

.do_help:
    call cmd_help

.exit_success:
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall
