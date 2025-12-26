.section .text

# Wait for child process with optional timeout
# rdi = child pid
# rsi = pointer to status (4 bytes)
# Returns: 0 on success, -1 on error, -2 on timeout
wait_for_child:
    push r12
    push r13
    push r14
    sub rsp, 8

    mov r12, rdi                    # child pid
    mov r13, rsi                    # status pointer

    # Check if timeout is set
    mov eax, [rip + test_timeout]
    test eax, eax
    jz .wait_blocking               # no timeout, do blocking wait

    # Timeout loop: poll with WNOHANG
    mov r14d, eax                   # remaining timeout in ms

.wait_timeout_loop:
    # Try non-blocking wait
    mov rax, SYS_WAIT4
    mov rdi, r12
    mov rsi, r13                    # status pointer
    mov rdx, WNOHANG
    xor r10, r10
    syscall

    # rax > 0: child exited, rax = 0: still running, rax < 0: error
    test rax, rax
    jg .wait_success                # child exited
    js .wait_error                  # error

    # Child still running, check timeout
    sub r14d, 10                    # decrement by 10ms
    jle .wait_kill_child            # timeout reached

    # Sleep 10ms
    lea rdi, [rip + poll_sleeptime]
    xor esi, esi
    mov rax, SYS_NANOSLEEP
    syscall
    jmp .wait_timeout_loop

.wait_kill_child:
    # Kill the child process
    mov rax, SYS_KILL
    mov rdi, r12
    mov rsi, SIGKILL
    syscall

    # Wait for child to be reaped
    mov rax, SYS_WAIT4
    mov rdi, r12
    mov rsi, r13
    xor rdx, rdx
    xor r10, r10
    syscall

    mov rax, -2                     # timeout
    jmp .wait_done

.wait_blocking:
    mov rax, SYS_WAIT4
    mov rdi, r12
    mov rsi, r13
    xor rdx, rdx
    xor r10, r10
    syscall

    test rax, rax
    js .wait_error

.wait_success:
    xor eax, eax                    # success
    jmp .wait_done

.wait_error:
    mov rax, -1

.wait_done:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    ret
