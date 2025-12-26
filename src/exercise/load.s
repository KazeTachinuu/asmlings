.section .text

# Load exercises using scripts/list_exercises.sh
load_exercises:
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 16                     # pipe fds at [rsp]

    mov qword ptr [rip + exercise_count], 0

    # Create pipe
    mov rax, SYS_PIPE
    lea rdi, [rsp]
    syscall
    test rax, rax
    js .load_done

    # Fork
    mov rax, SYS_FORK
    syscall
    test rax, rax
    js .load_done
    jnz .load_parent

    # Child: redirect stdout to pipe, exec script
    mov rax, SYS_CLOSE
    mov edi, [rsp]                  # close read end
    syscall

    mov rax, SYS_DUP2
    mov edi, [rsp + 4]              # write end -> stdout
    mov rsi, 1
    syscall

    mov rax, SYS_CLOSE
    mov edi, [rsp + 4]
    syscall

    sub rsp, 32
    lea rax, [rip + cmd_bash]
    mov [rsp], rax
    lea rax, [rip + list_script]
    mov [rsp + 8], rax
    mov qword ptr [rsp + 16], 0
    lea rdi, [rip + cmd_bash]
    mov rsi, rsp
    mov rdx, [rip + saved_envp]
    mov rax, SYS_EXECVE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.load_parent:
    mov r14, rax                    # child pid
    mov rax, SYS_CLOSE
    mov edi, [rsp + 4]              # close write end
    syscall

    mov r12d, [rsp]                 # read fd

.load_read_loop:
    mov rax, [rip + exercise_count]
    cmp rax, MAX_EXERCISES
    jge .load_wait

    mov rdi, rax
    call get_exercise_ptr
    mov r13, rax                    # current exercise slot

    # Read one line
    xor rbx, rbx
.load_read_char:
    mov rax, SYS_READ
    mov edi, r12d
    lea rsi, [r13 + rbx]
    mov rdx, 1
    syscall
    test rax, rax
    jle .load_line_done

    movzx eax, byte ptr [r13 + rbx]
    cmp al, 10                      # newline
    je .load_line_complete
    inc rbx
    cmp rbx, MAX_PATH - 1
    jl .load_read_char

.load_line_complete:
    mov byte ptr [r13 + rbx], 0     # null terminate
    test rbx, rbx
    jz .load_read_loop              # skip empty lines
    mov byte ptr [r13 + MAX_PATH], STATE_NOT_DONE
    inc qword ptr [rip + exercise_count]
    jmp .load_read_loop

.load_line_done:
    # Check if we have partial line
    test rbx, rbx
    jz .load_wait
    mov byte ptr [r13 + rbx], 0
    mov byte ptr [r13 + MAX_PATH], STATE_NOT_DONE
    inc qword ptr [rip + exercise_count]

.load_wait:
    mov rax, SYS_CLOSE
    mov edi, r12d
    syscall

    mov rax, SYS_WAIT4
    mov rdi, r14
    xor rsi, rsi
    xor rdx, rdx
    xor r10, r10
    syscall

.load_done:
    add rsp, 16
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
