# ======================================
# Exercise 36: C Calling Your Assembly
# ======================================
#
# In the real world, assembly is often written as small
# optimized functions that get called from C code.
#
# This exercise is compiled WITH a C file that provides
# main() and calls your function. You just write the function!
#
# System V AMD64 calling convention (what C uses):
#   Arguments in: %rdi, %rsi, %rdx, %rcx, %r8, %r9
#   Return value: %rax
#   You must preserve: %rbx, %rbp, %r12-%r15
#
# YOUR TASK: Write a function `multiply3` that multiplies
#            three numbers and returns the result.
#
# ---- The C code that calls your function: ----
#
#   extern long multiply3(long a, long b, long c);
#
#   int main(void) {
#       long result = multiply3(2, 3, 7);
#       return (result == 42) ? 0 : 1;
#   }
#
# ======================================

# I AM NOT DONE

.global multiply3

.text

# YOUR CODE HERE: implement multiply3(a, b, c) -> a * b * c
# Arguments: rdi=a, rsi=b, rdx=c
# Return: result in rax

