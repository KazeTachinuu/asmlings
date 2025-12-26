.section .text

# Load expected file for exercise
# rdi = exercise path (e.g., "exercises/02_exit_code.s")
# Returns: 1 on success, 0 if file not found
# Populates: test_exit_code, test_is_predict, test_predict_ans,
#            expected_output/expected_out_len, expected_input/expected_in_len
load_expected_file:
    push rbx
    push r12
    push r13
    push r14
    push r15
    mov r12, rdi                    # save exercise path

    # Initialize test variables
    mov dword ptr [rip + test_exit_code], 0
    mov byte ptr [rip + test_is_predict], 0
    mov dword ptr [rip + test_predict_ans], 0
    mov qword ptr [rip + expected_out_len], 0
    mov qword ptr [rip + expected_in_len], 0
    mov dword ptr [rip + test_args_count], 0
    # Initialize args buffer pointer (will be used during parsing)
    lea rax, [rip + test_args_buffer]
    mov [rip + test_args_buf_ptr], rax
    # Initialize file directives
    mov byte ptr [rip + test_has_file], 0
    mov byte ptr [rip + test_has_cleanup], 0
    mov qword ptr [rip + test_file_len], 0
    # Initialize gcc mode
    mov byte ptr [rip + test_use_gcc], 0

    # Extract exercise number from path
    # Find the filename part (after last /)
    mov rdi, r12
    call get_filename_ptr
    mov r13, rax                    # r13 = filename pointer

    # Build expected path: "expected/XX.txt"
    lea rdi, [rip + expected_path_buf]
    lea rsi, [rip + expected_dir]
    call str_copy

    # Append first 2 chars of filename (exercise number)
    lea rdi, [rip + expected_path_buf]
    call str_len
    lea rdi, [rip + expected_path_buf]
    add rdi, rax
    mov al, [r13]
    mov [rdi], al
    mov al, [r13 + 1]
    mov [rdi + 1], al
    mov byte ptr [rdi + 2], 0

    # Append ".txt"
    lea rdi, [rip + expected_path_buf]
    lea rsi, [rip + ext_txt]
    call str_append

    # Open expected file
    mov rax, SYS_OPEN
    lea rdi, [rip + expected_path_buf]
    xor esi, esi                    # O_RDONLY
    xor edx, edx
    syscall
    test rax, rax
    js .lef_not_found
    mov r14, rax                    # r14 = fd

    # Read file
    mov rax, SYS_READ
    mov rdi, r14
    lea rsi, [rip + expected_buffer]
    mov rdx, EXPECTED_BUF_SIZE - 1
    syscall
    mov r15, rax                    # r15 = bytes read

    # Close file
    mov rax, SYS_CLOSE
    mov rdi, r14
    syscall

    test r15, r15
    jle .lef_not_found

    # Null terminate
    lea rdi, [rip + expected_buffer]
    mov byte ptr [rdi + r15], 0

    # Parse lines
    lea rbx, [rip + expected_buffer]

.lef_parse_loop:
    # Check for end of buffer
    movzx eax, byte ptr [rbx]
    test al, al
    jz .lef_done

    # Check directive code
    cmp al, '#'
    je .lef_next_line
    cmp al, 10                      # newline
    je .lef_skip_newline
    cmp al, 'X'
    je .lef_parse_exit
    cmp al, 'P'
    je .lef_parse_predict
    cmp al, 'O'
    je .lef_parse_output
    cmp al, 'I'
    je .lef_parse_input
    cmp al, 'A'
    je .lef_parse_arg
    cmp al, 'F'
    je .lef_parse_file
    cmp al, 'C'
    je .lef_parse_cleanup
    cmp al, 'G'
    je .lef_parse_gcc
    jmp .lef_next_line

.lef_skip_newline:
    inc rbx
    jmp .lef_parse_loop

.lef_parse_exit:
    # Format: "X 42"
    add rbx, 2                      # skip "X "
    mov rdi, rbx
    call parse_decimal
    mov [rip + test_exit_code], eax
    mov rbx, rdi                    # update position
    jmp .lef_next_line

.lef_parse_predict:
    # Format: "P 67"
    mov byte ptr [rip + test_is_predict], 1
    add rbx, 2                      # skip "P "
    mov rdi, rbx
    call parse_decimal
    mov [rip + test_predict_ans], eax
    mov rbx, rdi                    # update position
    jmp .lef_next_line

.lef_parse_output:
    # Format: "O Hello World"
    add rbx, 2                      # skip "O "
    lea rdi, [rip + expected_output]
    xor r12d, r12d                  # length counter
.lef_copy_output:
    movzx eax, byte ptr [rbx]
    cmp al, 10                      # newline
    je .lef_output_done
    cmp al, 0
    je .lef_output_done
    cmp r12d, 255
    jge .lef_output_done
    # Check for escape sequences
    cmp al, '\\'
    jne .lef_store_output
    movzx ecx, byte ptr [rbx + 1]
    cmp cl, 'n'
    jne .lef_check_out_bs
    # \n -> newline
    mov byte ptr [rdi + r12], 10
    inc r12d
    add rbx, 2
    jmp .lef_copy_output
.lef_check_out_bs:
    cmp cl, '\\'
    jne .lef_store_output
    # \\ -> single backslash
    mov byte ptr [rdi + r12], '\\'
    inc r12d
    add rbx, 2
    jmp .lef_copy_output
.lef_store_output:
    mov [rdi + r12], al
    inc r12d
    inc rbx
    jmp .lef_copy_output
.lef_output_done:
    mov byte ptr [rdi + r12], 0
    mov [rip + expected_out_len], r12
    jmp .lef_next_line

.lef_parse_input:
    # Format: "I Hello World"
    add rbx, 2                      # skip "I "
    lea rdi, [rip + expected_input]
    xor r12d, r12d                  # length counter
.lef_copy_input:
    movzx eax, byte ptr [rbx]
    cmp al, 10                      # newline
    je .lef_input_done
    cmp al, 0
    je .lef_input_done
    cmp r12d, 255
    jge .lef_input_done
    # Check for escape sequences
    cmp al, '\\'
    jne .lef_store_input
    movzx ecx, byte ptr [rbx + 1]
    cmp cl, 'n'
    jne .lef_check_in_bs
    # \n -> newline
    mov byte ptr [rdi + r12], 10
    inc r12d
    add rbx, 2
    jmp .lef_copy_input
.lef_check_in_bs:
    cmp cl, '\\'
    jne .lef_store_input
    # \\ -> single backslash
    mov byte ptr [rdi + r12], '\\'
    inc r12d
    add rbx, 2
    jmp .lef_copy_input
.lef_store_input:
    mov [rdi + r12], al
    inc r12d
    inc rbx
    jmp .lef_copy_input
.lef_input_done:
    mov byte ptr [rdi + r12], 0
    mov [rip + expected_in_len], r12
    jmp .lef_next_line

.lef_parse_arg:
    # Format: "A argvalue"
    add rbx, 2                      # skip "A "
    # Get current buffer position and args count
    mov rdi, [rip + test_args_buf_ptr]
    mov eax, [rip + test_args_count]
    cmp eax, 7                      # max 8 args (stored in 64 bytes = 8 ptrs)
    jge .lef_next_line              # too many args, skip
    # Store pointer to this arg
    lea rcx, [rip + test_args_ptrs]
    mov [rcx + rax*8], rdi
    inc eax
    mov [rip + test_args_count], eax
    # Copy arg until newline
.lef_copy_arg:
    movzx eax, byte ptr [rbx]
    cmp al, 10                      # newline
    je .lef_arg_done
    cmp al, 0
    je .lef_arg_done
    mov [rdi], al
    inc rdi
    inc rbx
    jmp .lef_copy_arg
.lef_arg_done:
    mov byte ptr [rdi], 0           # null terminate
    inc rdi                         # advance past null
    mov [rip + test_args_buf_ptr], rdi
    jmp .lef_next_line

.lef_parse_file:
    # Format: "F filename:content"
    mov byte ptr [rip + test_has_file], 1
    add rbx, 2                      # skip "F "
    # Copy filename until ':'
    lea rdi, [rip + test_file_path]
.lef_copy_filename:
    movzx eax, byte ptr [rbx]
    cmp al, ':'
    je .lef_filename_done
    cmp al, 10
    je .lef_next_line               # malformed, skip
    cmp al, 0
    je .lef_next_line
    mov [rdi], al
    inc rdi
    inc rbx
    jmp .lef_copy_filename
.lef_filename_done:
    mov byte ptr [rdi], 0           # null terminate filename
    inc rbx                         # skip ':'
    # Copy content until newline
    lea rdi, [rip + test_file_content]
    xor r12d, r12d                  # length counter
.lef_copy_content:
    movzx eax, byte ptr [rbx]
    cmp al, 10
    je .lef_content_done
    cmp al, 0
    je .lef_content_done
    cmp r12d, 1023
    jge .lef_content_done
    # Check for escape sequences
    cmp al, '\\'
    jne .lef_store_char
    # Check next char for escape
    movzx ecx, byte ptr [rbx + 1]
    cmp cl, 'n'
    jne .lef_check_backslash
    # \n -> newline
    mov byte ptr [rdi + r12], 10
    inc r12d
    add rbx, 2
    jmp .lef_copy_content
.lef_check_backslash:
    cmp cl, '\\'
    jne .lef_store_char
    # \\ -> single backslash
    mov byte ptr [rdi + r12], '\\'
    inc r12d
    add rbx, 2
    jmp .lef_copy_content
.lef_store_char:
    mov [rdi + r12], al
    inc r12d
    inc rbx
    jmp .lef_copy_content
.lef_content_done:
    mov byte ptr [rdi + r12], 0
    mov [rip + test_file_len], r12
    jmp .lef_next_line

.lef_parse_cleanup:
    # Format: "C filename"
    mov byte ptr [rip + test_has_cleanup], 1
    add rbx, 2                      # skip "C "
    lea rdi, [rip + test_cleanup_path]
.lef_copy_cleanup:
    movzx eax, byte ptr [rbx]
    cmp al, 10
    je .lef_cleanup_done
    cmp al, 0
    je .lef_cleanup_done
    mov [rdi], al
    inc rdi
    inc rbx
    jmp .lef_copy_cleanup
.lef_cleanup_done:
    mov byte ptr [rdi], 0           # null terminate
    jmp .lef_next_line

.lef_parse_gcc:
    # Format: "G" or "G path/to/file.c"
    mov byte ptr [rip + test_use_gcc], 1
    lea rdi, [rip + test_c_file]
    mov byte ptr [rdi], 0           # default empty
    inc rbx                         # skip "G"
    # Check if there's more content (space + path)
    movzx eax, byte ptr [rbx]
    cmp al, ' '
    jne .lef_next_line              # just "G", no path
    inc rbx                         # skip space
.lef_copy_c_file:
    movzx eax, byte ptr [rbx]
    cmp al, 10
    je .lef_c_file_done
    cmp al, 0
    je .lef_c_file_done
    mov [rdi], al
    inc rdi
    inc rbx
    jmp .lef_copy_c_file
.lef_c_file_done:
    mov byte ptr [rdi], 0           # null terminate
    jmp .lef_next_line

.lef_next_line:
    # Find next line
    movzx eax, byte ptr [rbx]
    test al, al
    jz .lef_done
    cmp al, 10
    je .lef_found_newline
    inc rbx
    jmp .lef_next_line
.lef_found_newline:
    inc rbx
    jmp .lef_parse_loop

.lef_done:
    mov eax, 1
    jmp .lef_return

.lef_not_found:
    xor eax, eax

.lef_return:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    ret
