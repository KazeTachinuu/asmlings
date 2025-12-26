.section .text

# Get hint from file
# rdi = exercise path
# Returns: pointer to hint text
get_hint:
    push r12
    push r13

    call get_filename_ptr
    mov r12, rax

    # Build hint path: hints/XX.txt
    lea rdi, [rip + hint_path_buf]
    lea rsi, [rip + hints_dir]
    call str_copy

    lea rdi, [rip + hint_path_buf + 6]
    mov al, [r12]
    mov [rdi], al
    mov al, [r12 + 1]
    mov [rdi + 1], al
    mov byte ptr [rdi + 2], '.'
    mov byte ptr [rdi + 3], 't'
    mov byte ptr [rdi + 4], 'x'
    mov byte ptr [rdi + 5], 't'
    mov byte ptr [rdi + 6], 0

    # Open hint file
    mov rax, SYS_OPEN
    lea rdi, [rip + hint_path_buf]
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall
    test rax, rax
    js .gh_not_found
    mov r13, rax

    # Read
    mov rax, SYS_READ
    mov rdi, r13
    lea rsi, [rip + hint_buffer]
    mov rdx, HINT_BUFFER_SIZE - 1
    syscall
    lea rdi, [rip + hint_buffer]
    test rax, rax
    js .gh_close
    mov byte ptr [rdi + rax], 0

.gh_close:
    mov rax, SYS_CLOSE
    mov rdi, r13
    syscall

    lea rax, [rip + hint_buffer]
    jmp .gh_done

.gh_not_found:
    lea rax, [rip + hint_default]

.gh_done:
    pop r13
    pop r12
    ret

hint_default: .asciz "No hint available for this exercise."
