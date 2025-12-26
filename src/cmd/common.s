.section .text

# Find exercise by number or name
# rdi = string (number like "05" or filename)
# Returns: exercise pointer or 0
find_exercise:
    push rbx
    mov rbx, rdi

    # Try by number first
    mov rdi, rbx
    call find_exercise_by_num
    test rax, rax
    jnz .fe_done

    # Try by filename
    mov rdi, rbx
    call find_exercise_by_name

.fe_done:
    pop rbx
    ret

# Print "Checking <exercise>" header
# rdi = exercise pointer
print_checking_header:
    push rbx
    mov rbx, rdi

    lea rdi, [rip + msg_checking]
    call print_str
    lea rdi, [rip + style_bold]
    call print_str
    mov rdi, rbx
    call get_filename_ptr
    mov rdi, rax
    call print_str
    call print_reset
    call print_newline

    pop rbx
    ret
