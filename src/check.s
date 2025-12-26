.section .text

# Create test file if F directive was parsed
# Returns: 1 on success, 0 on failure
create_test_file:
    movzx eax, byte ptr [rip + test_has_file]
    test al, al
    jz .ctf_no_file

    # Create/truncate file
    mov rax, SYS_OPEN
    lea rdi, [rip + test_file_path]
    mov rsi, 0x241                  # O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0644                   # permissions
    syscall
    test rax, rax
    js .ctf_fail
    mov r12, rax                    # fd

    # Write content
    mov rax, SYS_WRITE
    mov rdi, r12
    lea rsi, [rip + test_file_content]
    mov rdx, [rip + test_file_len]
    syscall

    # Close
    mov rax, SYS_CLOSE
    mov rdi, r12
    syscall

.ctf_no_file:
    mov eax, 1
    ret
.ctf_fail:
    xor eax, eax
    ret

# Cleanup test file if C directive was parsed
cleanup_test_file:
    movzx eax, byte ptr [rip + test_has_cleanup]
    test al, al
    jz .clf_done

    mov rax, 87                     # SYS_UNLINK
    lea rdi, [rip + test_cleanup_path]
    syscall

.clf_done:
    ret

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

    # Load source file first (needed for both marker check and prediction)
    mov rdi, r12
    call file_has_marker            # loads source into source_buffer
    mov r13d, eax                   # save marker result

    # Load expected file
    mov rdi, r12
    call load_expected_file
    test al, al
    jz .check_failed                # expected file not found

    # Check if prediction exercise
    movzx eax, byte ptr [rip + test_is_predict]
    test al, al
    jnz .check_prediction

    # Regular exercise: check for "I AM NOT DONE" marker
    test r13d, r13d
    jnz .check_not_done

    # Regular exercise - compile and run
    mov rdi, r12
    call compile_exercise
    test al, al
    jz .check_failed

    # Create test file if needed (F directive)
    call create_test_file
    test al, al
    jz .check_failed

    # Get expected output and input lengths
    mov r15, [rip + expected_out_len]   # r15 = expected output length
    mov rbx, [rip + expected_in_len]    # rbx = expected input length

    # Run exercise
    mov rdi, r15                    # expected output length
    mov rsi, rbx                    # expected input length
    call run_exercise
    mov r13, rax                    # r13 = actual exit code

    # Cleanup test file if needed (C directive)
    call cleanup_test_file

    # Compare exit codes
    mov r14d, [rip + test_exit_code]
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

.check_prediction:
    # Get student's prediction from source file
    call get_student_prediction
    cmp eax, 256
    je .check_not_done              # "???" not filled in yet

    # Compare with expected answer
    mov r13d, eax                   # student's prediction
    mov r14d, [rip + test_predict_ans]
    cmp r13d, r14d
    jne .check_wrong_predict

    mov eax, STATE_PASSED
    jmp .check_done

.check_wrong_predict:
    mov eax, STATE_WRONG_PREDICT
    jmp .check_done

.check_wrong_output:
    mov eax, STATE_WRONG_OUTPUT
    jmp .check_done

.check_wrong_exit:
    mov [rip + last_exit_actual], r13
    movsx r14, r14d
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

# Run compiled exercise with optional stdout capture and stdin input
# rdi = expected output length (0 = don't capture, >0 = capture)
# rsi = expected input length (0 = redirect stdin to /dev/null, >0 = pipe input, -1 = passthrough)
# Returns: exit code in eax, actual output in actual_output buffer
run_exercise:
    push r12
    push r13
    push r14
    push r15
    sub rsp, 32                     # out pipe [rsp], in pipe [rsp+8], status [rsp+16]

    mov r15, rdi                    # save expected output length
    mov r13, rsi                    # save expected input length
    mov qword ptr [rip + actual_out_len], 0

    # If we need to capture output, create output pipe
    test r15, r15
    jz .run_no_out_pipe

    mov rax, SYS_PIPE
    lea rdi, [rsp]                  # out pipe fds: [rsp]=read, [rsp+4]=write
    syscall
    test rax, rax
    js .run_error

.run_no_out_pipe:
    # If we have expected input, create input pipe
    test r13, r13
    jz .run_no_in_pipe

    mov rax, SYS_PIPE
    lea rdi, [rsp + 8]              # in pipe fds: [rsp+8]=read, [rsp+12]=write
    syscall
    test rax, rax
    js .run_error

.run_no_in_pipe:
    mov rax, SYS_FORK
    syscall
    test rax, rax
    js .run_error
    mov r12, rax                    # save child pid
    jnz .run_parent

    # ===== CHILD PROCESS =====

    # Handle stdin: passthrough (-1), /dev/null (0), or pipe (>0)
    cmp r13, -1
    je .run_child_stdout              # passthrough: don't touch stdin
    test r13, r13
    jz .run_child_stdin_null

    # Redirect stdin from input pipe read end
    mov rax, SYS_CLOSE
    mov edi, [rsp + 12]             # close write end
    syscall

    mov rax, SYS_DUP2
    mov edi, [rsp + 8]              # input pipe read end
    xor esi, esi                    # fd 0 = stdin
    syscall

    mov rax, SYS_CLOSE
    mov edi, [rsp + 8]              # close original read fd
    syscall
    jmp .run_child_stdout

.run_child_stdin_null:
    # Redirect stdin to /dev/null
    mov rax, SYS_OPEN
    lea rdi, [rip + dev_null]
    xor esi, esi                    # O_RDONLY
    xor edx, edx
    syscall
    test rax, rax
    js .run_child_stdout            # skip on error

    mov rdi, rax                    # null_fd
    push rdi
    xor esi, esi                    # fd 0 = stdin
    mov rax, SYS_DUP2
    syscall

    pop rdi
    mov rax, SYS_CLOSE
    syscall

.run_child_stdout:
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
    # Build argv array: [tmp_exe, arg1, arg2, ..., NULL]
    # Reserve space for: program path + up to 8 args + NULL = 10 * 8 = 80 bytes
    sub rsp, 80
    lea rax, [rip + tmp_exe]
    mov [rsp], rax                  # argv[0] = program path

    # Copy argument pointers if any
    mov ecx, [rip + test_args_count]
    test ecx, ecx
    jz .run_no_args

    lea rsi, [rip + test_args_ptrs]
    mov rdi, rsp
    add rdi, 8                      # start at argv[1]
    xor eax, eax
.run_copy_args:
    cmp eax, ecx
    jge .run_args_done
    mov r8, [rsi + rax*8]           # get arg pointer
    mov [rdi + rax*8], r8           # store in argv
    inc eax
    jmp .run_copy_args
.run_args_done:
    # NULL terminate after last arg
    mov qword ptr [rdi + rax*8], 0
    jmp .run_do_exec

.run_no_args:
    mov qword ptr [rsp + 8], 0      # argv[1] = NULL

.run_do_exec:
    lea rdi, [rip + tmp_exe]
    mov rsi, rsp                    # argv
    xor rdx, rdx                    # envp = NULL
    mov rax, SYS_EXECVE
    syscall
    mov rax, SYS_EXIT
    mov rdi, 127
    syscall

    # ===== PARENT PROCESS =====
.run_parent:
    # If we have expected input, write it to input pipe
    test r13, r13
    jz .run_parent_no_input

    # Close input pipe read end (child uses it)
    mov rax, SYS_CLOSE
    mov edi, [rsp + 8]
    syscall

    # Write expected input to input pipe
    mov rax, SYS_WRITE
    mov edi, [rsp + 12]             # input pipe write fd
    lea rsi, [rip + expected_input]
    mov rdx, r13                    # input length
    syscall

    # Close input pipe write end (signals EOF to child)
    mov rax, SYS_CLOSE
    mov edi, [rsp + 12]
    syscall

.run_parent_no_input:
    # If capturing output, close write end and read from pipe
    test r15, r15
    jz .run_wait

    # Close output pipe write end
    mov rax, SYS_CLOSE
    mov edi, [rsp + 4]
    syscall

    # Read output from pipe
    mov rax, SYS_READ
    mov edi, [rsp]                  # output pipe read fd
    lea rsi, [rip + actual_output]
    mov rdx, OUTPUT_MAX_LEN         # max bytes
    syscall
    test rax, rax
    js .run_read_done
    mov [rip + actual_out_len], rax

.run_read_done:
    # Close output pipe read end
    mov rax, SYS_CLOSE
    mov edi, [rsp]
    syscall

.run_wait:
    mov rax, SYS_WAIT4
    mov rdi, r12
    lea rsi, [rsp + 16]             # status at new offset
    xor rdx, rdx
    xor r10, r10
    syscall

    mov eax, [rsp + 16]             # status at new offset
    shr eax, 8
    and eax, 0xff
    jmp .run_done

.run_error:
    mov rax, -1

.run_done:
    add rsp, 32
    pop r15
    pop r14
    pop r13
    pop r12
    ret
