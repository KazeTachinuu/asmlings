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
    mov rsi, O_WRONLY_CREAT_TRUNC
    mov rdx, FILE_PERM_RW
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

    mov rax, SYS_UNLINK
    lea rdi, [rip + test_cleanup_path]
    syscall

.clf_done:
    ret
