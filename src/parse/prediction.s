.section .text

# Get student prediction from exercise file
# Parses "Prediction: N" or "Prediction: ???" from source_buffer
# Returns: prediction value in eax, or 256 if "???" or not found
get_student_prediction:
    push rbx

    # Search for "Prediction:" in source_buffer
    lea rdi, [rip + source_buffer]
    lea rsi, [rip + marker_prediction]
    call str_find
    test rax, rax
    jz .gsp_not_found

    # Found it - skip past the prefix (11 chars: "Prediction:")
    add rax, 11
    mov rbx, rax

    # Skip whitespace
.gsp_skip_ws:
    movzx ecx, byte ptr [rbx]
    cmp cl, ' '
    je .gsp_next_ws
    cmp cl, '\t'
    je .gsp_next_ws
    jmp .gsp_check_predict

.gsp_next_ws:
    inc rbx
    jmp .gsp_skip_ws

.gsp_check_predict:
    # Check if it's "???"
    cmp byte ptr [rbx], '?'
    jne .gsp_parse_num
    cmp byte ptr [rbx + 1], '?'
    jne .gsp_parse_num
    cmp byte ptr [rbx + 2], '?'
    jne .gsp_parse_num
    # It's "???" - return 256
    mov eax, 256
    jmp .gsp_done

.gsp_parse_num:
    # Parse decimal number
    mov rdi, rbx
    call parse_decimal
    jmp .gsp_done

.gsp_not_found:
    mov eax, 256

.gsp_done:
    pop rbx
    ret
