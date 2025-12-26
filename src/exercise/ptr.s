.section .text

# Get pointer to exercise at index rdi
# Returns pointer in rax
get_exercise_ptr:
    lea rax, [rip + exercises]
    imul rdi, rdi, EXERCISE_SIZE
    add rax, rdi
    ret
