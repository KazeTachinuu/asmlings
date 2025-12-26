.section .text

# Check if file contains "I AM NOT DONE" marker
# rdi = path
# Returns: 1 if found (not done), 0 if not found (done)
file_has_marker:
    push rbx
    push r12

    # Open file
    mov rax, SYS_OPEN
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall
    test rax, rax
    js .marker_not_found
    mov rbx, rax

    # Read file
    mov rax, SYS_READ
    mov rdi, rbx
    lea rsi, [rip + source_buffer]
    mov rdx, SOURCE_BUFFER_SIZE - 1
    syscall
    mov r12, rax

    # Close file
    mov rax, SYS_CLOSE
    mov rdi, rbx
    syscall

    test r12, r12
    jle .marker_not_found

    # Null terminate
    lea rdi, [rip + source_buffer]
    mov byte ptr [rdi + r12], 0

    # Search for marker
    lea rdi, [rip + source_buffer]
    lea rsi, [rip + marker_not_done]
    call str_find
    test rax, rax
    jnz .marker_found

.marker_not_found:
    xor eax, eax
    jmp .marker_done

.marker_found:
    mov eax, 1

.marker_done:
    pop r12
    pop rbx
    ret
