.section .text

# Print exercise result message
# rdi = state (STATE_PASSED, STATE_FAILED, etc.)
# Returns: state in eax (for chaining)
print_result:
    push rbx
    mov ebx, edi                    # save state

    cmp ebx, STATE_PASSED
    je .pr_passed
    cmp ebx, STATE_NOT_DONE
    je .pr_not_done
    cmp ebx, STATE_WRONG_EXIT
    je .pr_wrong_exit
    cmp ebx, STATE_WRONG_OUTPUT
    je .pr_wrong_output
    cmp ebx, STATE_WRONG_PREDICT
    je .pr_wrong_predict

    # Compilation failed
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_failed]
    call print_colored
    jmp .pr_done

.pr_passed:
    lea rdi, [rip + color_green]
    lea rsi, [rip + msg_passed]
    call print_colored
    jmp .pr_done

.pr_not_done:
    lea rdi, [rip + color_yellow]
    lea rsi, [rip + msg_not_done]
    call print_colored
    lea rdi, [rip + style_dim]
    call print_str
    lea rdi, [rip + msg_remove_marker]
    call print_str
    call print_reset
    jmp .pr_done

.pr_wrong_exit:
    lea rdi, [rip + color_red]
    call print_str
    lea rdi, [rip + msg_wrong_exit]
    call print_str
    mov rdi, [rip + last_exit_actual]
    call print_number
    lea rdi, [rip + msg_expected]
    call print_str
    mov rdi, [rip + last_exit_expected]
    call print_number
    call print_reset
    call print_newline
    jmp .pr_done

.pr_wrong_output:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_wrong_output]
    call print_colored
    # Show expected
    lea rdi, [rip + style_dim]
    call print_str
    lea rdi, [rip + msg_expected_out]
    call print_str
    lea rdi, [rip + expected_output]
    call print_str
    lea rdi, [rip + msg_quote_end]
    call print_str
    # Show actual
    lea rdi, [rip + msg_actual_out]
    call print_str
    lea rdi, [rip + actual_output]
    call print_str
    lea rdi, [rip + msg_quote_end]
    call print_str
    call print_reset
    jmp .pr_done

.pr_wrong_predict:
    lea rdi, [rip + color_red]
    lea rsi, [rip + msg_wrong_predict]
    call print_colored

.pr_done:
    mov eax, ebx                    # return state
    pop rbx
    ret

# Print hint tip (for watch mode)
print_hint_tip:
    lea rdi, [rip + style_dim]
    lea rsi, [rip + msg_hint_tip]
    jmp print_colored
