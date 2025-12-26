.section .text

# Compile exercise using scripts/compile.sh
# rdi = path
# Returns: 1 on success, 0 on failure
compile_exercise:
    push rbx
    push r12
    sub rsp, 8
    mov r12, rdi

    mov rax, SYS_FORK
    syscall
    test rax, rax
    js .compile_error
    jnz .compile_wait

    # Child: exec bash scripts/compile.sh exercise tmp_exe [mode]
    sub rsp, 56
    lea rax, [rip + cmd_bash]
    mov [rsp], rax                  # argv[0] = bash
    lea rax, [rip + compile_script]
    mov [rsp + 8], rax              # argv[1] = script
    mov [rsp + 16], r12             # argv[2] = exercise.s
    lea rax, [rip + tmp_exe]
    mov [rsp + 24], rax             # argv[3] = output

    # Check gcc mode
    movzx eax, byte ptr [rip + test_use_gcc]
    test al, al
    jz .compile_no_mode

    # Check if c_file is set
    lea rax, [rip + test_c_file]
    movzx ecx, byte ptr [rax]
    test cl, cl
    jz .compile_gcc_only
    mov [rsp + 32], rax             # argv[4] = c_file.c
    jmp .compile_exec

.compile_gcc_only:
    lea rax, [rip + gcc_mode_str]
    mov [rsp + 32], rax             # argv[4] = "gcc"

.compile_exec:
    mov qword ptr [rsp + 40], 0
    jmp .compile_do_exec

.compile_no_mode:
    mov qword ptr [rsp + 32], 0

.compile_do_exec:
    lea rdi, [rip + cmd_bash]
    mov rsi, rsp
    mov rdx, [rip + saved_envp]
    mov rax, SYS_EXECVE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.compile_wait:
    mov rbx, rax
    mov rax, SYS_WAIT4
    mov rdi, rbx
    lea rsi, [rsp]
    xor rdx, rdx
    xor r10, r10
    syscall

    mov eax, [rsp]
    test eax, 0x7f
    jnz .compile_error
    shr eax, 8
    test eax, eax
    jnz .compile_error

    mov eax, 1
    jmp .compile_done

.compile_error:
    xor eax, eax

.compile_done:
    add rsp, 8
    pop r12
    pop rbx
    ret
