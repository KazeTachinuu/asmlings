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

# Get expected exit code by parsing "Expected exit code: N" from source
# Assumes source_buffer already contains the file content (from file_has_marker)
# rdi = exercise path (unused, kept for compatibility)
# Returns: exit code in eax (0-255), or 256 if "???" or not found
get_expected_exit:
    push rbx
    push r12

    # Search for "Expected exit code:" in source_buffer
    lea rdi, [rip + source_buffer]
    lea rsi, [rip + marker_expected]
    call str_find
    test rax, rax
    jz .gee_not_found

    # Found it - skip past the prefix (19 chars: "Expected exit code:")
    add rax, 19
    mov rbx, rax

    # Skip whitespace
.gee_skip_ws:
    movzx ecx, byte ptr [rbx]
    cmp cl, ' '
    je .gee_next_ws
    cmp cl, '\t'
    je .gee_next_ws
    jmp .gee_check_predict

.gee_next_ws:
    inc rbx
    jmp .gee_skip_ws

.gee_check_predict:
    # Check if it's "???" (prediction not filled)
    cmp byte ptr [rbx], '?'
    jne .gee_parse_num
    cmp byte ptr [rbx + 1], '?'
    jne .gee_parse_num
    cmp byte ptr [rbx + 2], '?'
    jne .gee_parse_num
    # It's "???" - return 256
    mov eax, 256
    jmp .gee_done

.gee_parse_num:
    # Check if first char is a digit
    movzx ecx, byte ptr [rbx]
    sub ecx, '0'
    cmp ecx, 9
    ja .gee_not_found       # not a digit, no valid number

    # Parse decimal number
    xor r12d, r12d          # accumulator

.gee_digit_loop:
    movzx ecx, byte ptr [rbx]
    sub ecx, '0'
    cmp ecx, 9
    ja .gee_end_num         # not a digit, done
    imul r12d, r12d, 10
    add r12d, ecx
    inc rbx
    jmp .gee_digit_loop

.gee_end_num:
    # Return the parsed number (0-255)
    mov eax, r12d
    jmp .gee_done

.gee_not_found:
    # No "Expected exit code:" found - return 256
    mov eax, 256

.gee_done:
    pop r12
    pop rbx
    ret
