.section .text

# Get pointer to exercise at index rdi
# Returns pointer in rax
get_exercise_ptr:
    lea rax, [rip + exercises]
    imul rdi, rdi, EXERCISE_SIZE
    add rax, rdi
    ret

# Load exercises from exercises/ directory
# Only loads .s files (AT&T syntax)
load_exercises:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 24

    mov qword ptr [rip + exercise_count], 0

    # Open directory
    mov rax, SYS_OPEN
    lea rdi, [rip + exercises_dir]
    mov rsi, O_RDONLY
    xor rdx, rdx
    syscall
    test rax, rax
    js .load_done
    mov r14, rax                    # r14 = dir fd

.load_read_dir:
    mov rax, SYS_GETDENTS64
    mov rdi, r14
    lea rsi, [rip + dirent_buffer]
    mov rdx, DIRENT_BUFFER_SIZE
    syscall
    test rax, rax
    jle .load_close_dir
    mov r15, rax                    # r15 = bytes read
    xor rbx, rbx                    # rbx = offset

.load_process_entry:
    cmp rbx, r15
    jge .load_read_dir

    lea rdi, [rip + dirent_buffer]
    add rdi, rbx
    movzx eax, word ptr [rdi + 16]  # d_reclen
    mov [rsp], rax                  # save reclen
    movzx eax, byte ptr [rdi + 18]  # d_type
    cmp al, 8                       # DT_REG (regular file)
    jne .load_next_entry

    lea r12, [rdi + 19]             # r12 = filename

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
    mov r13, rax                    # r13 = exercise ptr

    # Build full path: exercises/filename
    mov rdi, r13
    lea rsi, [rip + exercises_dir]
    call str_copy
    mov rdi, r13
    call str_len
    mov byte ptr [r13 + rax], '/'
    lea rdi, [r13 + rax + 1]
    mov rsi, r12
    call str_copy

    # Initialize state
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
    add rsp, 24
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

# Sort exercises alphabetically (bubble sort)
sort_exercises:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 280

    mov r14, [rip + exercise_count]
    cmp r14, 2
    jl .sort_done

.sort_outer:
    xor r15, r15                    # swapped flag
    xor rbx, rbx                    # index

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

    # Compare filenames
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

    # Swap
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
    add rsp, 280
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

# Check if file contains "I AM NOT DONE" marker
# rdi = path
# Returns: 1 if found (not done), 0 if not found (done)
file_has_marker:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 16

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
    mov rdx, 65535
    syscall
    mov r12, rax

    # Close file
    push rax
    mov rax, SYS_CLOSE
    mov rdi, rbx
    syscall
    pop rax

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
    add rsp, 16
    pop r12
    pop rbx
    pop rbp
    ret

# Check exercise: compile and run
# rdi = exercise path pointer
# Returns: STATE_NOT_DONE, STATE_PASSED, or STATE_FAILED
check_exercise:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    sub rsp, 32
    mov r12, rdi

    # Check for marker first
    mov rdi, r12
    call file_has_marker
    test al, al
    jnz .check_not_done

    # Compile
    mov rdi, r12
    call compile_exercise
    test al, al
    jz .check_failed

    # Run
    call run_exercise
    mov r13, rax

    # Get expected exit code
    mov rdi, r12
    call get_expected_exit
    movsx r14, eax

    # Compare
    cmp r13, r14
    jne .check_wrong_exit

    mov eax, STATE_PASSED
    jmp .check_done

.check_wrong_exit:
    mov [rip + last_exit_actual], r13
    mov [rip + last_exit_expected], r14
    mov eax, STATE_WRONG_EXIT
    jmp .check_done

.check_failed:
    mov eax, STATE_FAILED
    jmp .check_done

.check_not_done:
    mov eax, STATE_NOT_DONE

.check_done:
    add rsp, 32
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

# Compile exercise (AT&T syntax only)
# rdi = path
# Returns: 1 on success, 0 on failure
compile_exercise:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 48
    mov r12, rdi

    # Fork for assembler
    mov rax, SYS_FORK
    syscall
    test rax, rax
    js .compile_error
    jnz .compile_wait_as

    # Child: exec as
    lea rdi, [rip + cmd_as]
    sub rsp, 48
    lea rax, [rip + as_arg0]
    mov [rsp], rax
    lea rax, [rip + as_arg1]
    mov [rsp + 8], rax
    lea rax, [rip + as_arg2]
    mov [rsp + 16], rax
    lea rax, [rip + tmp_obj]
    mov [rsp + 24], rax
    mov [rsp + 32], r12
    mov qword ptr [rsp + 40], 0
    mov rsi, rsp
    xor rdx, rdx
    mov rax, SYS_EXECVE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.compile_wait_as:
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

    # Fork for linker
    mov rax, SYS_FORK
    syscall
    test rax, rax
    js .compile_error
    jnz .compile_wait_ld

    # Child: exec ld
    lea rdi, [rip + cmd_ld]
    sub rsp, 40
    lea rax, [rip + ld_arg0]
    mov [rsp], rax
    lea rax, [rip + tmp_obj]
    mov [rsp + 8], rax
    lea rax, [rip + ld_arg2]
    mov [rsp + 16], rax
    lea rax, [rip + tmp_exe]
    mov [rsp + 24], rax
    mov qword ptr [rsp + 32], 0
    mov rsi, rsp
    xor rdx, rdx
    mov rax, SYS_EXECVE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 1
    syscall

.compile_wait_ld:
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
    add rsp, 48
    pop r12
    pop rbx
    pop rbp
    ret

# Run compiled exercise
# Returns: exit code
run_exercise:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    sub rsp, 16

    mov rax, SYS_FORK
    syscall
    test rax, rax
    js .run_error
    jnz .run_wait

    # Child: exec exercise
    lea rdi, [rip + tmp_exe]
    sub rsp, 16
    lea rax, [rip + tmp_exe]
    mov [rsp], rax
    mov qword ptr [rsp + 8], 0
    mov rsi, rsp
    xor rdx, rdx
    mov rax, SYS_EXECVE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 127
    syscall

.run_wait:
    mov r12, rax
    mov rax, SYS_WAIT4
    mov rdi, r12
    lea rsi, [rsp]
    xor rdx, rdx
    xor r10, r10
    syscall

    mov eax, [rsp]
    shr eax, 8
    and eax, 0xff
    jmp .run_done

.run_error:
    mov rax, -1

.run_done:
    add rsp, 16
    pop r12
    pop rbx
    pop rbp
    ret

# Get expected exit code for exercise
# Parses exercise number from filename (01-28)
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

    # ecx now has exercise number (1-28)
    cmp ecx, 28
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

# Expected exit codes for exercises 01-28
# Index 0 unused, 1=ex01, 2=ex02, etc.
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

# Get hint from file
# rdi = exercise path
get_hint:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    sub rsp, 8

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
    mov rdx, 2047
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
    add rsp, 8
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

hint_default: .asciz "No hint available for this exercise."

# Find first incomplete exercise
# Returns: pointer to exercise, or 0 if all done
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

    # Check if it passes
    push rdi
    call check_exercise
    pop rdi
    mov byte ptr [rdi + MAX_PATH], al  # Save state
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

# Find exercise by filename (e.g., "01_intro.s")
# rdi = filename
# Returns: pointer to exercise, or 0 if not found
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
    pop rdi                         # rdi = exercise ptr
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
