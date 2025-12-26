.section .text

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
