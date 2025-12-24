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

# Check exercise: compile and run
# rdi = exercise path pointer
# Returns: STATE_NOT_DONE, STATE_PASSED, STATE_FAILED, or STATE_WRONG_EXIT
check_exercise:
    push r12
    push r13
    push r14
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
    movzx r14, al

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
    pop r14
    pop r13
    pop r12
    ret

# Compile exercise (AT&T syntax only)
# rdi = path
# Returns: 1 on success, 0 on failure
compile_exercise:
    push rbx
    push r12
    sub rsp, 8
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
    add rsp, 8
    pop r12
    pop rbx
    ret

# Run compiled exercise
# Returns: exit code
run_exercise:
    push r12
    sub rsp, 8

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
    add rsp, 8
    pop r12
    ret
