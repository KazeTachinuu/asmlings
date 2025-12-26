.section .text

# Run compiled exercise with optional stdout capture and stdin input
# rdi = expected output length (0 = don't capture, >0 = capture)
# rsi = expected input length (0 = redirect stdin to /dev/null, >0 = pipe input, -1 = passthrough)
# Also captures stderr if expected_err_len > 0
# Returns: exit code in eax, actual output in actual_output/actual_stderr buffers
run_exercise:
    push r12
    push r13
    push r14
    push r15
    sub rsp, 48                     # out pipe [rsp], in pipe [rsp+8], err pipe [rsp+32], status [rsp+16]

    mov r15, rdi                    # save expected output length
    mov r13, rsi                    # save expected input length
    mov r14, [rip + expected_err_len]  # save expected stderr length
    mov qword ptr [rip + actual_out_len], 0
    mov qword ptr [rip + actual_err_len], 0

    # If we need to capture output, create output pipe
    test r15, r15
    jz .run_no_out_pipe

    mov rax, SYS_PIPE
    lea rdi, [rsp]                  # out pipe fds: [rsp]=read, [rsp+4]=write
    syscall
    test rax, rax
    js .run_error

.run_no_out_pipe:
    # If we need to capture stderr, create stderr pipe
    test r14, r14
    jz .run_no_err_pipe

    mov rax, SYS_PIPE
    lea rdi, [rsp + 32]             # err pipe fds: [rsp+32]=read, [rsp+36]=write
    syscall
    test rax, rax
    js .run_error

.run_no_err_pipe:
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
    # If capturing stdout, redirect to pipe write end
    test r15, r15
    jz .run_child_stderr

    mov rax, SYS_CLOSE
    mov edi, [rsp]                  # close read end
    syscall

    mov rax, SYS_DUP2
    mov edi, [rsp + 4]              # write end
    mov rsi, 1                      # stdout
    syscall

    mov rax, SYS_CLOSE
    mov edi, [rsp + 4]
    syscall

.run_child_stderr:
    # If capturing stderr, redirect to pipe write end
    test r14, r14
    jz .run_child_exec

    mov rax, SYS_CLOSE
    mov edi, [rsp + 32]             # close read end
    syscall

    mov rax, SYS_DUP2
    mov edi, [rsp + 36]             # write end
    mov rsi, 2                      # stderr
    syscall

    mov rax, SYS_CLOSE
    mov edi, [rsp + 36]
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
    # If capturing output, close write end and read from pipe with timeout
    test r15, r15
    jz .run_read_stderr_only         # no stdout, but maybe stderr

    # Close output pipe write end (only child needs it)
    mov rax, SYS_CLOSE
    mov edi, [rsp + 4]
    syscall

    # Check if timeout is set
    mov eax, [rip + test_timeout]
    test eax, eax
    jz .run_read_blocking           # no timeout, do blocking read

    # Use poll with timeout to wait for output or child exit
    # pollfd: fd(4), events(2), revents(2) = 8 bytes
    mov edi, [rsp]                  # stdout pipe read fd
    mov [rsp + 24], edi             # pollfd.fd
    mov word ptr [rsp + 28], POLLIN | POLLHUP  # pollfd.events
    mov word ptr [rsp + 30], 0      # pollfd.revents

    mov rax, SYS_POLL
    lea rdi, [rsp + 24]             # pollfd array
    mov rsi, 1                      # nfds
    mov edx, [rip + test_timeout]   # timeout in ms
    syscall

    # poll returns: > 0 = events, 0 = timeout, < 0 = error
    cmp rax, 0
    jg .run_read_output             # data ready
    je .run_timeout                 # timeout
    jmp .run_error                  # error

.run_timeout:
    # Kill the child process
    mov rax, SYS_KILL
    mov rdi, r12
    mov rsi, SIGKILL
    syscall

    # Close pipe and reap child
    mov rax, SYS_CLOSE
    mov edi, [rsp]
    syscall

    mov rax, SYS_WAIT4
    mov rdi, r12
    lea rsi, [rsp + 16]
    xor rdx, rdx
    xor r10, r10
    syscall

    mov rax, -2                     # timeout
    jmp .run_done

.run_read_blocking:
.run_read_output:
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

    # Now read stderr if capturing
    test r14, r14
    jz .run_wait_blocking
    jmp .run_read_stderr

.run_read_stderr_only:
    # No stdout expected, but check if stderr is expected
    test r14, r14
    jz .run_wait_no_pipe

.run_read_stderr:
    # Close stderr pipe write end
    mov rax, SYS_CLOSE
    mov edi, [rsp + 36]
    syscall

    # Read stderr from pipe
    mov rax, SYS_READ
    mov edi, [rsp + 32]
    lea rsi, [rip + actual_stderr]
    mov rdx, OUTPUT_MAX_LEN
    syscall
    test rax, rax
    js .run_stderr_done
    mov [rip + actual_err_len], rax

.run_stderr_done:
    # Close stderr pipe read end
    mov rax, SYS_CLOSE
    mov edi, [rsp + 32]
    syscall
    jmp .run_wait_blocking

.run_wait_no_pipe:
    # For non-capturing runs (like interactive), also handle timeout
    mov eax, [rip + test_timeout]
    test eax, eax
    jz .run_wait_blocking           # no timeout

    # Wait with timeout using wait_for_child helper
    mov rdi, r12
    lea rsi, [rsp + 16]
    call wait_for_child
    cmp rax, -2
    je .run_done                    # propagate timeout
    cmp rax, -1
    je .run_done                    # propagate error
    jmp .run_extract_exit

.run_wait_blocking:
    mov rax, SYS_WAIT4
    mov rdi, r12
    lea rsi, [rsp + 16]
    xor rdx, rdx
    xor r10, r10
    syscall
    test rax, rax
    js .run_error

.run_extract_exit:
    # Extract exit code from status
    mov eax, [rsp + 16]
    shr eax, 8
    and eax, 0xff
    jmp .run_done

.run_error:
    mov rax, -1

.run_done:
    add rsp, 48
    pop r15
    pop r14
    pop r13
    pop r12
    ret
