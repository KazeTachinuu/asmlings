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

# Get expected exit code for exercise
# rdi = exercise path
# Returns: expected exit code in eax
get_expected_exit:
    push rbx
    call get_filename_ptr
    mov rbx, rax

    # Parse two-digit number from filename
    movzx ecx, byte ptr [rbx]
    sub ecx, '0'
    cmp ecx, 9
    ja .gee_default
    imul ecx, 10

    movzx edx, byte ptr [rbx + 1]
    sub edx, '0'
    cmp edx, 9
    ja .gee_default
    add ecx, edx

    # ecx now has exercise number
    cmp ecx, EXERCISE_COUNT
    ja .gee_default
    cmp ecx, 1
    jb .gee_default

    lea rdx, [rip + exit_code_table]
    movzx eax, byte ptr [rdx + rcx]
    pop rbx
    ret

.gee_default:
    xor eax, eax
    pop rbx
    ret

# =============================================================================
# EXIT CODE TABLE
# =============================================================================
# To add a new exercise:
#   1. Create exercises/NN_name.s
#   2. Create hints/NN.txt
#   3. Add expected exit code below
#   4. Update EXERCISE_COUNT in constants.s
# =============================================================================
exit_code_table:
    .byte 0     # 0: unused
    .byte 0     # 01: intro
    .byte 42    # 02: exit_code
    .byte 25    # 03: mov
    .byte 99    # 04: registers
    .byte 42    # 05: add
    .byte 77    # 06: sub
    .byte 56    # 07: mul (7*8)
    .byte 33    # 08: div (99/3)
    .byte 52    # 09: and (0x34)
    .byte 53    # 10: or (0x35)
    .byte 0     # 11: xor
    .byte 40    # 12: shifts (5*8)
    .byte 123   # 13: memory
    .byte 77    # 14: store
    .byte 0     # 15: cmp
    .byte 1     # 16: jumps
    .byte 5     # 17: loop
    .byte 42    # 18: push_pop
    .byte 55    # 19: stack_save
    .byte 66    # 20: call_ret
    .byte 88    # 21: stack_frame
    .byte 0     # 22: alignment
    .byte 30    # 23: locals
    .byte 44    # 24: args
    .byte 73    # 25: callee_save
    .byte 0     # 26: write
    .byte 5     # 27: read
    .byte 5     # 28: string_len
    # Add new exercises here:
    # .byte N   # 29: new_exercise
