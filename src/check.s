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
# Returns: STATE_NOT_DONE, STATE_PASSED, STATE_FAILED, STATE_WRONG_EXIT, or STATE_WRONG_OUTPUT
check_exercise:
    push r12
    push r13
    push r14
    push r15
    push rbx
    mov r12, rdi

    # Check for marker first
    mov rdi, r12
    call file_has_marker
    test al, al
    jnz .check_not_done

    # Get expected exit code (parses from source_buffer loaded by file_has_marker)
    mov rdi, r12
    call get_expected_exit
    mov r14d, eax

    # Check if expected is 256 (means "???" prediction not filled)
    cmp r14d, 256
    je .check_not_done

    # Get expected output (if any)
    call get_expected_output
    mov r15, rax                    # r15 = expected output length (0 if none)

    # Compile
    mov rdi, r12
    call compile_exercise
    test al, al
    jz .check_failed

    # Run (captures stdout if r15 > 0)
    mov rdi, r15
    call run_exercise
    mov r13, rax                    # r13 = exit code

    # Compare exit codes
    cmp r13d, r14d
    jne .check_wrong_exit

    # If expected output, compare it
    test r15, r15
    jz .check_passed

    # Compare actual output with expected
    mov rdi, [rip + actual_out_len]
    cmp rdi, r15
    jne .check_wrong_output

    lea rdi, [rip + actual_output]
    lea rsi, [rip + expected_output]
    mov rcx, r15
    call memcmp
    test eax, eax
    jnz .check_wrong_output

.check_passed:
    mov eax, STATE_PASSED
    jmp .check_done

.check_wrong_output:
    mov eax, STATE_WRONG_OUTPUT
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
    pop rbx
    pop r15
    pop r14
    pop r13
    pop r12
    ret

# Get expected output from source file
# Parses "Expected output: "xxx"" from source_buffer
# Returns: length of expected output in rax (0 if none), output stored in expected_output
get_expected_output:
    push rbx
    push r12

    # Clear expected output length
    mov qword ptr [rip + expected_out_len], 0

    # Search for "Expected output:" in source_buffer
    lea rdi, [rip + source_buffer]
    lea rsi, [rip + marker_output]
    call str_find
    test rax, rax
    jz .geo_not_found

    # Found it - skip past the prefix (16 chars: "Expected output:")
    add rax, 16
    mov rbx, rax

    # Skip whitespace
.geo_skip_ws:
    movzx ecx, byte ptr [rbx]
    cmp cl, ' '
    je .geo_next_ws
    cmp cl, '\t'
    je .geo_next_ws
    jmp .geo_find_quote

.geo_next_ws:
    inc rbx
    jmp .geo_skip_ws

.geo_find_quote:
    # Look for opening quote
    cmp byte ptr [rbx], '"'
    jne .geo_not_found
    inc rbx                         # skip opening quote

    # Copy until closing quote
    lea rdi, [rip + expected_output]
    xor r12, r12                    # length counter

.geo_copy_loop:
    movzx eax, byte ptr [rbx]
    cmp al, '"'
    je .geo_done_copy
    cmp al, 0
    je .geo_done_copy
    cmp al, 10                      # newline
    je .geo_done_copy
    cmp r12, OUTPUT_MAX_LEN         # max length
    jge .geo_done_copy
    mov [rdi + r12], al
    inc r12
    inc rbx
    jmp .geo_copy_loop

.geo_done_copy:
    mov byte ptr [rdi + r12], 0     # null terminate
    mov [rip + expected_out_len], r12
    mov rax, r12
    jmp .geo_done

.geo_not_found:
    xor eax, eax

.geo_done:
    pop r12
    pop rbx
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

# Run compiled exercise with optional stdout capture
# rdi = expected output length (0 = don't capture, >0 = capture)
# Returns: exit code in eax, actual output in actual_output buffer
run_exercise:
    push r12
    push r15
    sub rsp, 24                     # pipe fds [rsp], status [rsp+8]

    mov r15, rdi                    # save expected length
    mov qword ptr [rip + actual_out_len], 0

    # If we need to capture output, create a pipe
    test r15, r15
    jz .run_no_pipe

    mov rax, SYS_PIPE
    lea rdi, [rsp]                  # pipe fds: [rsp]=read, [rsp+4]=write
    syscall
    test rax, rax
    js .run_error

.run_no_pipe:
    mov rax, SYS_FORK
    syscall
    test rax, rax
    js .run_error
    mov r12, rax                    # save child pid
    jnz .run_parent

    # ===== CHILD PROCESS =====
    # If capturing, redirect stdout to pipe write end
    test r15, r15
    jz .run_child_exec

    # Close pipe read end
    mov rax, SYS_CLOSE
    mov edi, [rsp]
    syscall

    # dup2(pipe_write, stdout)
    mov rax, SYS_DUP2
    mov edi, [rsp + 4]
    mov rsi, 1                      # stdout
    syscall

    # Close pipe write end (now duplicated to stdout)
    mov rax, SYS_CLOSE
    mov edi, [rsp + 4]
    syscall

.run_child_exec:
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

    # ===== PARENT PROCESS =====
.run_parent:
    # If capturing, close write end and read from pipe
    test r15, r15
    jz .run_wait

    # Close pipe write end
    mov rax, SYS_CLOSE
    mov edi, [rsp + 4]
    syscall

    # Read output from pipe
    mov rax, SYS_READ
    mov edi, [rsp]                  # pipe read fd
    lea rsi, [rip + actual_output]
    mov rdx, OUTPUT_MAX_LEN         # max bytes
    syscall
    test rax, rax
    js .run_read_done
    mov [rip + actual_out_len], rax

.run_read_done:
    # Close pipe read end
    mov rax, SYS_CLOSE
    mov edi, [rsp]
    syscall

.run_wait:
    mov rax, SYS_WAIT4
    mov rdi, r12
    lea rsi, [rsp + 8]
    xor rdx, rdx
    xor r10, r10
    syscall

    mov eax, [rsp + 8]
    shr eax, 8
    and eax, 0xff
    jmp .run_done

.run_error:
    mov rax, -1

.run_done:
    add rsp, 24
    pop r15
    pop r12
    ret
