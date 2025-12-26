.section .text

# Run compiled exercise with optional stdout capture and stdin input
# rdi = expected output length (0 = don't capture, >0 = capture)
# rsi = expected input length (0 = redirect stdin to /dev/null, >0 = pipe input, -1 = passthrough)
# Returns: exit code in eax, actual output in actual_output buffer
run_exercise:
    push r12
    push r13
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
    pop r13
    pop r12
    ret
