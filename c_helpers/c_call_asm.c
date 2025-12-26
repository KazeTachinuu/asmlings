// C driver that calls your assembly function
// Your task: implement multiply3 in assembly

extern long multiply3(long a, long b, long c);

int main(void) {
    long result = multiply3(2, 3, 7);
    // Return 0 if correct (42), non-zero otherwise
    return (result == 42) ? 0 : 1;
}
