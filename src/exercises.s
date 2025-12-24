.section .text

# Get pointer to exercise at index rdi
# Returns pointer in rax
get_exercise_ptr:
    lea rax, [rip + exercises]
    imul rdi, rdi, EXERCISE_SIZE
    add rax, rdi
    ret

# Load exercises from exercises/ directory
load_exercises:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 8

    mov qword ptr [rip + exercise_count], 0

    # Open directory
    mov rax, SYS_OPEN
    lea rdi, [rip + exercises_dir]
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall
    test rax, rax
    js .load_done
    mov r14, rax

.load_read_dir:
    mov rax, SYS_GETDENTS64
    mov rdi, r14
    lea rsi, [rip + dirent_buffer]
    mov rdx, DIRENT_BUFFER_SIZE
    syscall
    test rax, rax
    jle .load_close_dir
    mov r15, rax
    xor rbx, rbx

.load_process_entry:
    cmp rbx, r15
    jge .load_read_dir

    lea rdi, [rip + dirent_buffer]
    add rdi, rbx
    movzx eax, word ptr [rdi + 16]
    mov [rsp], rax
    movzx eax, byte ptr [rdi + 18]
    cmp al, 8                       # DT_REG
    jne .load_next_entry

    lea r12, [rdi + 19]

    # Check if ends with .s
    mov rdi, r12
    lea rsi, [rip + ext_s]
    call str_ends_with
    test al, al
    jz .load_next_entry

    # Add exercise
    mov rax, [rip + exercise_count]
    cmp rax, MAX_EXERCISES
    jge .load_close_dir

    mov rdi, rax
    call get_exercise_ptr
    mov r13, rax

    # Build path: exercises/filename
    mov rdi, r13
    lea rsi, [rip + exercises_dir]
    call str_copy
    mov rdi, r13
    call str_len
    mov byte ptr [r13 + rax], '/'
    lea rdi, [r13 + rax + 1]
    mov rsi, r12
    call str_copy

    mov byte ptr [r13 + MAX_PATH], STATE_NOT_DONE
    inc qword ptr [rip + exercise_count]

.load_next_entry:
    add rbx, [rsp]
    jmp .load_process_entry

.load_close_dir:
    mov rax, SYS_CLOSE
    mov rdi, r14
    syscall
    call sort_exercises

.load_done:
    add rsp, 8
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

# Sort exercises alphabetically (bubble sort)
sort_exercises:
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 272

    mov r14, [rip + exercise_count]
    cmp r14, 2
    jl .sort_done

.sort_outer:
    xor r15, r15
    xor rbx, rbx

.sort_inner:
    lea rax, [rbx + 1]
    cmp rax, r14
    jge .sort_check

    mov rdi, rbx
    call get_exercise_ptr
    mov r12, rax
    lea rdi, [rbx + 1]
    call get_exercise_ptr
    mov r13, rax

    mov rdi, r12
    call get_filename_ptr
    push rax
    mov rdi, r13
    call get_filename_ptr
    mov rsi, rax
    pop rdi
    call str_compare
    cmp eax, 0
    jle .sort_no_swap

    # Swap using temp buffer on stack
    lea rdi, [rsp]
    mov rsi, r12
    mov rcx, EXERCISE_SIZE
    call memcpy
    mov rdi, r12
    mov rsi, r13
    mov rcx, EXERCISE_SIZE
    call memcpy
    mov rdi, r13
    lea rsi, [rsp]
    mov rcx, EXERCISE_SIZE
    call memcpy
    mov r15, 1

.sort_no_swap:
    inc rbx
    jmp .sort_inner

.sort_check:
    test r15, r15
    jnz .sort_outer

.sort_done:
    add rsp, 272
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret

# Find first incomplete exercise
# Returns: pointer or 0
find_incomplete:
    push rbx
    push r12
    xor rbx, rbx
    mov r12, [rip + exercise_count]

.fi_loop:
    cmp rbx, r12
    jge .fi_not_found

    mov rdi, rbx
    call get_exercise_ptr
    push rax
    mov rdi, rax
    call file_has_marker
    pop rdi
    test al, al
    jnz .fi_found

    push rdi
    call check_exercise
    pop rdi
    mov byte ptr [rdi + MAX_PATH], al
    cmp al, STATE_PASSED
    jne .fi_found

    inc rbx
    jmp .fi_loop

.fi_found:
    mov rax, rdi
    pop r12
    pop rbx
    ret

.fi_not_found:
    xor eax, eax
    pop r12
    pop rbx
    ret

# Find exercise by filename
# rdi = filename, Returns: pointer or 0
find_exercise_by_name:
    push rbx
    push r12
    push r13
    mov r13, rdi
    xor rbx, rbx
    mov r12, [rip + exercise_count]

.febn_name_loop:
    cmp rbx, r12
    jge .febn_name_fail

    mov rdi, rbx
    call get_exercise_ptr
    push rax
    mov rdi, rax
    call get_filename_ptr
    mov rdi, rax
    mov rsi, r13
    call str_equals
    pop rdi
    test al, al
    jnz .febn_name_done

    inc rbx
    jmp .febn_name_loop

.febn_name_fail:
    xor eax, eax
    jmp .febn_name_exit

.febn_name_done:
    mov rax, rdi

.febn_name_exit:
    pop r13
    pop r12
    pop rbx
    ret

# Find exercise by number (e.g., "02")
# rdi = number string, Returns: pointer or 0
find_exercise_by_num:
    push rbx
    push r12
    push r13
    mov r13, rdi
    xor rbx, rbx
    mov r12, [rip + exercise_count]

.febn_loop:
    cmp rbx, r12
    jge .febn_fail

    mov rdi, rbx
    call get_exercise_ptr
    push rax
    mov rdi, rax
    call get_filename_ptr
    movzx ecx, word ptr [rax]
    movzx edx, word ptr [r13]
    pop rax
    cmp cx, dx
    je .febn_done

    inc rbx
    jmp .febn_loop

.febn_fail:
    xor eax, eax

.febn_done:
    pop r13
    pop r12
    pop rbx
    ret
